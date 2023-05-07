Card = {}

function Card:new(gameObject, themeKey, cardKey, cardIndex)
	local temp = {}
    self.__index = self
	setmetatable(temp, self)
    temp:Init(gameObject, themeKey, cardKey, cardIndex)
    return temp
end

function Card:Init(gameObject, themeKey, cardKey, cardIndex)
    self.transform = gameObject.transform
    self.bIsLastOne = SlotsCardsHandler:getCardIsGoldCard(SlotsCardsManager.album, cardKey) --判断是否为最后一个
    self.albumKey = SlotsCardsManager.album
    self.themeKey = themeKey --该卡对应的主题ID
    -- self.cardID = nID --该卡在该主题ID下的ID
    self.cardKey = cardKey --该卡在数据存储中的Index
    self.cardIndex = cardIndex
    self.nCardCount = SlotsCardsHandler.data.activityData[cardKey].count
    local card = SlotsCardsHandler.data.activityData[self.albumKey].m_mapCardsInfo[cardKey]
    self.starCount = card.starCount
    self.transform:FindDeepChild("CardName"):GetComponent(typeof(TextMeshProUGUI)).text = card.cardName
    self.cardImg = self.transform:FindDeepChild("CardImg"):GetComponent(typeof(UnityUI.Image))

    self.mCommonResSerialization = self.transform:GetComponent(typeof(CS.CommonResSerialization))

    local assetImagePath = cardKey --有此卡，用这个路径获取图片
    local sprite = self.mCommonResSerialization:GetSpriteByAtlas("Album", assetImagePath)
    self.cardImg.sprite = sprite

    local assetThemeImagePath = themeKey.."NotOwn" --没有此卡，用这个路径获取图片
    local sprite = self.mCommonResSerialization:GetSpriteByAtlas("Album", assetThemeImagePath)
    self.transform:FindDeepChild("CardNotOwnLogo"):GetComponent(typeof(UnityUI.Image)).sprite = sprite

    local assetThemeImagePath = "card_bg"
    local sprite = self.mCommonResSerialization:GetSpriteByAtlas("Album", assetThemeImagePath)   
    self.transform:FindDeepChild("CardBg"):GetComponent(typeof(UnityUI.Image)).sprite = sprite
    self.newGo = self.transform:FindDeepChild("New").gameObject
    self.cardNotOwnBG = self.transform:FindDeepChild("CardNotBG")
    self.cardNotOwn = self.transform:FindDeepChild("CardNotOwn").gameObject
    self.cardOwn = self.transform:FindDeepChild("CardOwn")
    self.ownStar = self.transform:FindDeepChild("CardOwn/Star"..self.starCount)
    self.notOwnStar = self.transform:FindDeepChild("CardNotOwn/Star"..self.starCount)
    self.lastOneCardsCountContainer = self.transform:FindDeepChild("CardsCountContainer")
    self.lastOneCardsCountText = self.lastOneCardsCountContainer:FindDeepChild("CardsCount"):GetComponent(typeof(TextMeshProUGUI))
    if self.bIsLastOne then
        self.hasLastOneGo = self.transform:FindDeepChild("LastOneCardBg").gameObject
        self.hasLastOneToOpenGo = self.transform:FindDeepChild("LastOneToOpen").gameObject
    end
    
    self.button = self.transform:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.button)
    self.button.onClick:AddListener(function()
        -- Debug.Log("CardInfo:"..self.themeID.."/"..self.cardID.."/"..self.cardIndex)
        --TODO 显示INFO界面
        SlotsCardsAudioHandler:PlaySound("click")
        IntroduceCardPop:Show(self.themeKey, self.cardIndex)
    end)

    self:refreshCardStatus()

	return self
end

function Card:refreshCardStatus()
    local card = SlotsCardsHandler.data.activityData[self.albumKey].m_mapCardsInfo[self.cardKey]
    self.nCardCount = card.cardCount --重新读取数量，防止数量变化
    local bIsOwn = self.nCardCount > 0

    if bIsOwn then
        --已经拥有的card
        self.cardNotOwnBG.gameObject:SetActive(false)
        self.cardNotOwn:SetActive(false)

        self.cardOwn.gameObject:SetActive(true)
        self.ownStar.gameObject:SetActive(true)
        if self.bIsLastOne then
            local count = SlotsCardsHandler.data.activityData[self.themeKey].nGoldSpinGameCount
            if count > 99 then
                self.lastOneCardsCountText.text = "99+"  
                self.lastOneCardsCountContainer.gameObject:SetActive(true)
            elseif count > 1 then
                self.lastOneCardsCountText.text = "+"..count
                self.lastOneCardsCountContainer.gameObject:SetActive(true)
            else
                self.lastOneCardsCountContainer.gameObject:SetActive(false)
            end
        else
            local bHasNew = SlotsCardsHandler:CheckCardHasNew(self.cardKey)
            if bHasNew then
                self.newGo:SetActive(true)
            else
                self.newGo:SetActive(false)
            end
        end

        if self.bIsLastOne and (not self.hasLastOneGo.activeSelf) then
            self.hasLastOneGo:SetActive(true)
        end
        --TODO 如果是最后一张卡牌，且有玩的次数，将button事件改变
        if self.bIsLastOne and SlotsCardsHandler.data.activityData[self.themeKey].nGoldSpinGameCount > 0 then
            if not self.hasLastOneToOpenGo.activeSelf then
                self.hasLastOneToOpenGo:SetActive(true)
            end
            self.button.onClick:RemoveAllListeners()
            DelegateCache:addOnClickButton(self.button)
            self.button.onClick:AddListener(function()
                SlotsCardsAudioHandler:PlaySound("click")
                FrenzySpinGamePop:Show(self.albumKey, self.themeKey, self.cardKey)
            end)
        else
            if self.bIsLastOne then
                if self.hasLastOneToOpenGo.activeSelf then
                    self.hasLastOneToOpenGo:SetActive(false)
                end
            end
            -- self.hasLastOneGo:SetActive(false)
            --刷新过后
            self.button.onClick:RemoveAllListeners()
            DelegateCache:addOnClickButton(self.button)
            self.button.onClick:AddListener(function()
                --TODO 显示INFO界面
                SlotsCardsAudioHandler:PlaySound("click")
                IntroduceCardPop:Show(self.themeKey, self.cardIndex)
            end)
        end
    else
        --没有拥有的card
        self.cardNotOwnBG.gameObject:SetActive(true)
        self.cardNotOwn:SetActive(true)
        self.cardOwn.gameObject:SetActive(false)
        self.notOwnStar.gameObject:SetActive(true)
    end
end