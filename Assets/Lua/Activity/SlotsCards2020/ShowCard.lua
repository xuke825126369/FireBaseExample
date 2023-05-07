ShowCard = {}

function ShowCard:new(gameObject, albumKey, themeKey, cardKey)
	local temp = {}
    self.__index = self
	setmetatable(temp, self)
    temp:Init(gameObject, albumKey, themeKey, cardKey)
    return temp
end

function ShowCard:Init(gameObject, albumKey, themeKey, cardKey)
    self.gameObject = gameObject
    self.transform = gameObject.transform
    LuaAutoBindMonoBehaviour.Bind(gameObject, self)

    self.albumKey = albumKey
    local card = SlotsCardsHandler.data.activityData[self.albumKey].m_mapCardsInfo[cardKey]
    self.bIsLastOne = card.bIsGoldCard --判断是否为最后一个

    self.themeKey = themeKey --该卡对应的主题ID
    self.cardKey = cardKey --该卡在该主题ID下的ID

    self.mCommonResSerialization = self.transform:GetComponent(typeof(CS.CommonResSerialization))

    self.transform:FindDeepChild("CardName"):GetComponent(typeof(TextMeshProUGUI)).text = card.cardName
    self.goNew = self.transform:FindDeepChild("New").gameObject

    self.cardImg = self.transform:FindDeepChild("CardImg"):GetComponent(typeof(UnityUI.Image))
    local path = SlotsCardsHandler.m_strCurAlbumPath
    local assetImagePath = cardKey.."" --有此卡，用这个路径获取图片
    local sprite = self.mCommonResSerialization:GetSpriteByAtlas("Album", assetImagePath)
    self.cardImg.sprite = sprite
    
    local assetThemeImagePath = themeKey.."NotOwn" --没有此卡，用这个路径获取图片
    local sprite = self.mCommonResSerialization:GetSpriteByAtlas("Album", assetThemeImagePath)
    self.transform:FindDeepChild("CardNotOwnLogo"):GetComponent(typeof(UnityUI.Image)).sprite = sprite

    local assetThemeImagePath = "card_bg"
    local sprite = self.mCommonResSerialization:GetSpriteByAtlas("Album", assetThemeImagePath)   
    self.transform:FindDeepChild("CardBg"):GetComponent(typeof(UnityUI.Image)).sprite = sprite
    self.transform:FindDeepChild("CardNotOwn").gameObject:SetActive(false)
    self.transform:FindDeepChild("CardNotBG").gameObject:SetActive(false)
    
    self.cardBackImg = self.transform:FindDeepChild("BackBG"):GetComponent(typeof(UnityUI.Image))

    if self.bIsLastOne then
        assetImagePath = "card_album_gold_bg" --有此卡，用这个路径获取图片
        local sprite = self.mCommonResSerialization:FindSprite(assetImagePath)   
        self.cardBackImg.sprite = sprite
        self.transform:FindDeepChild("LastOneCardBg").gameObject:SetActive(true)
    end

    local cardOwn = self.transform:FindDeepChild("CardOwn")
    cardOwn.gameObject:SetActive(true)
    cardOwn:FindDeepChild("Star"..card.starCount).gameObject:SetActive(true)

    self.button = self.transform:GetComponent(typeof(UnityUI.Button))
    self.clickedStatus = self.transform:FindDeepChild("Select")
	return self
end

function ShowCard:OnDestroy()
    self.gameObject = nil
    self.transform = nil
end

function ShowCard:showBackBG()
    self.cardBackImg.gameObject:SetActive(true)
end

function ShowCard:showFlyAni(delay, to, maxOffset, cardCount)
    LeanTween.delayedCall(delay,function()
        if self.gameObject ~= nil and self.gameObject.activeInHierarchy then
            SlotsCardsAudioHandler:PlaySound("card_fly")

            local scale = 1
            if cardCount >= 6 then
                scale = -0.3 / 6 * cardCount + 1.3
            end
            if scale < 0.7 then
                scale = 0.7
            end
            LeanTween.scale(self.gameObject, Unity.Vector3.one * scale, 0.5)
            local path = CS.System.Array.CreateInstance(typeof(Unity.Vector3), 4)
            path:SetValue (Unity.Vector3(0, 115, 0), 0)
            path:SetValue (Unity.Vector3(-maxOffset, 182, 0), 1)
            path:SetValue (Unity.Vector3(-maxOffset + 40, 76, 0), 2)
            path:SetValue (to, 3)
            
            LeanTween.moveLocal(self.gameObject, path, 1):setEase(LeanTweenType.easeInOutQuad)
            LeanTween.delayedCall((cardCount + 1) * 0.5, function()
                if self.gameObject ~= nil and self.gameObject.activeInHierarchy then
                    if not (SlotsCardsHandler.data.activityData[self.cardKey].count > 1) then
                        self:showNewImg()
                    end
                end
            end)
        end
    end)
end

function ShowCard:showNewImg()
    LeanTween.delayedCall(0.8, function()
        if self.gameObject ~= nil then
            self.goNew:SetActive(true)
            self.goNew.transform.localScale = Unity.Vector3.one*1.4
            LeanTween.alpha(self.goNew.transform, 1, 0.5)
            LeanTween.scale(self.goNew,Unity.Vector3.one, 0.5)
        end
    end)
end