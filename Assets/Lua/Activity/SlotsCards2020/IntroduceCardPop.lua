IntroduceCardPop = {}
IntroduceCardPop.m_cardItemContainer = nil
IntroduceCardPop.m_mapCards = {}

IntroduceCardPop.m_btnClose = nil
IntroduceCardPop.m_btnLeft = nil
IntroduceCardPop.m_btnRight = nil

local nCurIndex = 1
local bIsMoving = false

function IntroduceCardPop:Show(themeKey, cardIndex)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadSlotsCardsAsset("IntroduceCardPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        
        self.m_cardItemContainer = self.transform:FindDeepChild("CardItemContainer")
        self.m_btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnClose)
        self.m_btnClose.onClick:AddListener(function()
            SlotsCardsAudioHandler:PlaySound("click")
            self:Hide()
        end)

        self.m_btnLeft = self.transform:FindDeepChild("LeftBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnLeft)
        self.m_btnLeft.onClick:AddListener(function()
            SlotsCardsAudioHandler:PlaySound("click")
            self:changeIndex(-1)
        end)

        self.m_btnRight = self.transform:FindDeepChild("RightBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnRight)
        self.m_btnRight.onClick:AddListener(function()
            SlotsCardsAudioHandler:PlaySound("click")
            self:changeIndex(1)
        end)
        self.originSizeDelta = Unity.Vector2(218,305)
    end

    nCurIndex = cardIndex
    self.m_cardItemContainer.anchoredPosition = Unity.Vector2(-(nCurIndex-1)*1920, 0)
    if LuaHelper.tableSize(self.m_mapCards) > 0 then
        for k,v in pairs(self.m_mapCards) do
            Unity.GameObject.Destroy(v.gameObject)
            v = nil
        end
        self.m_mapCards = {}
    end
    self.themeKey = themeKey
    for i = 1,12 do
        local cardKey = themeKey..i
        if self.m_mapCards[cardKey] == nil then
            local path = "Card.prefab"
            local prefab = AssetBundleHandler:LoadSlotsCardsAsset(path)
            local card = Unity.Object.Instantiate(prefab).transform
            local cardItem = Card:new(card.gameObject, themeKey, cardKey, i)
            self.m_mapCards[cardKey] = cardItem
            cardItem.transform:SetParent(self.m_cardItemContainer)
            cardItem.transform.anchorMin = Unity.Vector2(0.5, 0.5)
            cardItem.transform.anchorMax = Unity.Vector2(0.5, 0.5)
            cardItem.transform.anchoredPosition3D = Unity.Vector3.zero
            cardItem.transform.sizeDelta = self.originSizeDelta
            cardItem.transform.localScale = Unity.Vector3.one*2
            cardItem.transform.anchoredPosition = Unity.Vector2((i-1)*1920, 0)
        else
            self.m_mapCards[cardKey]:refreshCardStatus()
        end
        if not self.m_mapCards[cardKey].bIsLastOne then
            self.m_mapCards[cardKey].button.onClick:RemoveAllListeners()
        else
            if SlotsCardsHandler.data.activityData[self.m_mapCards[cardKey].themeKey].nGoldSpinGameCount <= 0 then
                self.m_mapCards[cardKey].button.onClick:RemoveAllListeners()
            end
        end
        self.m_mapCards[cardKey].transform.gameObject:SetActive(i == nCurIndex)
    end
    
    ViewScaleAni:Show(self.transform.gameObject)
    self:refreshBtnStatus()
end

function IntroduceCardPop:OnDestroy()
    self.m_mapCards = {}
end

function IntroduceCardPop:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function IntroduceCardPop:beginMoving(lastKey)
    bIsMoving = true
    self.m_btnLeft.gameObject:SetActive(false)
    self.m_btnRight.gameObject:SetActive(false)    
    LeanTween.moveX(self.m_cardItemContainer, -1920 * (nCurIndex - 1), 0.5):setOnComplete(function()
        bIsMoving = false
        self:refreshBtnStatus()
        self.m_mapCards[lastKey].transform.gameObject:SetActive(false)
    end)
end

function IntroduceCardPop:changeIndex(count)
    SlotsCardsAudioHandler:PlaySound("click")
    local lastKey = self.themeKey..nCurIndex
    nCurIndex = nCurIndex + count
    local cardKey = self.themeKey..nCurIndex
    self.m_mapCards[cardKey].transform.gameObject:SetActive(true)
    self:beginMoving(lastKey)
end

function IntroduceCardPop:refreshBtnStatus()
    if nCurIndex == 1 then
        self.m_btnLeft.gameObject:SetActive(false)
        self.m_btnRight.gameObject:SetActive(true)
    elseif nCurIndex == 12 then
        self.m_btnLeft.gameObject:SetActive(true)
        self.m_btnRight.gameObject:SetActive(false)
    else
        self.m_btnLeft.gameObject:SetActive(true)
        self.m_btnRight.gameObject:SetActive(true)
    end
end