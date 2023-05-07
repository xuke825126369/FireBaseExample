SlotsCardsBookPop = {}
SlotsCardsBookPop.m_pageMap = nil
SlotsCardsBookPop.m_mapCards = {}

function SlotsCardsBookPop:Show(themeKeyIndex)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadSlotsCardsAsset("SlotsCardsBookPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_container = self.transform:FindDeepChild("Container")

        self.m_mapCards = {}
        self.m_pageMap = {}
        for i = 1, LuaHelper.tableSize(SlotsCardsConfig[SlotsCardsManager.album]) do
            local themeKey = SlotsCardsConfig[SlotsCardsManager.album][i].ThemeKey
            local page1 = self.transform:FindDeepChild("Theme"..i.."_1")
            local page2 = self.transform:FindDeepChild("Theme"..i.."_2")
            self.m_pageMap[themeKey] = {page1, page2}
            self:InitCards(i, self.m_pageMap[themeKey])
        end

        self.bookPro = self.transform:FindDeepChild("BookPro"):GetComponent(typeof(CS.BookCurlPro.BookPro))
        self.m_textPageIndex = self.transform:FindDeepChild("CurrentPageIndex"):GetComponent(typeof(TextMeshProUGUI))
        DelegateCache:addOther(self.bookPro, "OnFlip")
        self.bookPro.OnFlip:AddListener(function()
            self:UpdatePageCallBack()
        end)

        self.btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnClose)
        self.btnClose.onClick:AddListener(function()
            self:Hide()
        end)
        self.flipper = self.bookPro.gameObject:GetComponent(typeof(CS.BookCurlPro.AutoFlip))
        self.btnLeft = self.transform:FindDeepChild("BtnLeft"):GetComponent(typeof(UnityUI.Button))
        self.btnRight = self.transform:FindDeepChild("BtnRight"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnLeft)
        self.btnLeft.onClick:AddListener(function()
            self:btnLeftClicked()
        end)
        DelegateCache:addOnClickButton(self.btnRight)
        self.btnRight.onClick:AddListener(function()
            self:btnRightClicked()
        end)
    end

    for i = 1, LuaHelper.tableSize(SlotsCardsConfig[SlotsCardsManager.album]) do
        local themeKey = SlotsCardsConfig[SlotsCardsManager.album][i].ThemeKey
        self:refreshThemeUI(themeKey)
    end

    self.bookPro:SetCurrentPaper(themeKeyIndex)
    SlotsCardsAudioHandler:PlaySound("album_pop")
    ViewAlphaAni:Show(self.transform.gameObject, function()
        SlotsCardsMainUIPop:SetThemeEntryActive(false)
    end)    

    self:UpdatePageCallBack()
    self.bookPro.stopDraginPaperFlag = false

end

function SlotsCardsBookPop:Update()
    local index = self.transform:GetSiblingIndex() + 1
    local bIsStopDragin = false
    for i = index, self.transform.parent.childCount-1 do
        if self.transform.parent:GetChild(i).gameObject.activeSelf then
            bIsStopDragin = true
            break
        end
    end
    SlotsCardsBookPop.bookPro.stopDraginPaperFlag = bIsStopDragin
end

function SlotsCardsBookPop:UpdatePageCallBack()
    SlotsCardsAudioHandler:PlaySound("page_turn")
    self.m_textPageIndex.text = self.bookPro.CurrentPaper.."/"..(self.bookPro.papers.Length-1)
    self:SetBtnStatus()
    local strCurAlbumKey = SlotsCardsManager.album
    local themeKey = SlotsCardsConfig[strCurAlbumKey][self.bookPro.CurrentPaper].ThemeKey
    local themeCardsInfo = SlotsCardsConfig[strCurAlbumKey][self.bookPro.CurrentPaper].ThemeCards
    SlotsCardsHandler:SetThemeHasNew(themeKey, false)
    SlotsCardsMainUIPop.m_mapThemeEntryUI[themeKey]:refreshUI()
    for k,v in pairs(self.m_mapCards) do
        v.button.interactable = false
    end
    for i=1, #themeCardsInfo do
        local cardKey = themeKey .. themeCardsInfo[i].nID
        self.m_mapCards[cardKey].button.interactable = true
        SlotsCardsHandler:SetCardHasNew(cardKey, false)
    end
end

function SlotsCardsBookPop:SetBtnStatus()
    self.bookPro.interactable = true
    if self.bookPro.CurrentPaper <= 1 then
        self.btnLeft.interactable = false
        self.btnRight.interactable = true
    elseif self.bookPro.CurrentPaper >= (self.bookPro.papers.Length-1) then
        self.btnLeft.interactable = true
        self.btnRight.interactable = false
    else
        self.btnLeft.interactable = true
        self.btnRight.interactable = true
    end
end

function SlotsCardsBookPop:InitCards(index, parentArray)
    local strCurAlbumKey = SlotsCardsManager.album
    local themeCardsInfo = SlotsCardsConfig[strCurAlbumKey][index].ThemeCards
    local themeKey = SlotsCardsConfig[strCurAlbumKey][index].ThemeKey
    for i=1, #themeCardsInfo do
        local path = "Card.prefab"
        local prefab = AssetBundleHandler:LoadSlotsCardsAsset(path)
        local card = Unity.Object.Instantiate(prefab).transform
        local parent = nil
        if i > 6 then
            parent = parentArray[2]:FindDeepChild("CardsContainer")
        else
            parent = parentArray[1]:FindDeepChild("CardsContainer")
        end
        card:SetParent(parent)
        card.localScale = Unity.Vector3.one
        card.anchoredPosition3D = Unity.Vector3.zero
        local cardKey = themeKey .. themeCardsInfo[i].nID

        local cardItem = Card:new(card.gameObject, themeKey, cardKey, themeCardsInfo[i].nID)
        
        self.m_mapCards[cardKey] = cardItem
    end
end

-- 刷新该主题数据
function SlotsCardsBookPop:refreshThemeUI(themeKey)
    local strCurAlbumKey = SlotsCardsManager.album

    if SlotsCardsManager.album == "Album2" then
        local completeImg = self.m_pageMap[themeKey][2]:FindDeepChild("Done").gameObject
        if SlotsCardsHandler.data.activityData[themeKey].bIsCompleted then
            completeImg:SetActive(true)
        else
            completeImg:SetActive(false)
        end
    end

    local totalReward = self.m_pageMap[themeKey][2]:FindDeepChild("ThemeTotalRewardCount"):GetComponent(typeof(UnityUI.Text))
    totalReward.text = MoneyFormatHelper.numWithCommas(SlotsCardsHandler.data.activityData[strCurAlbumKey].m_arraySetPrize[themeKey]).." COINS!"
    local collectText = self.m_pageMap[themeKey][1]:FindDeepChild("ThemeProgressText"):GetComponent(typeof(TextMeshProUGUI))
	local progress = SlotsCardsHandler.data.activityData[strCurAlbumKey].dicThemeProgress[themeKey]
    collectText.text = progress .."/".. #SlotsCardsConfig[strCurAlbumKey][1].ThemeCards

    local index = 0
    for i=1,#SlotsCardsConfig[strCurAlbumKey] do
        if SlotsCardsConfig[strCurAlbumKey][i].ThemeKey == themeKey then
            index = i
            break
        end
    end
    local themeCardsInfo = SlotsCardsConfig[strCurAlbumKey][index].ThemeCards

    for i = 1, #themeCardsInfo do
        local cardKey = themeKey .. themeCardsInfo[i].nID
        self.m_mapCards[cardKey]:refreshCardStatus()
    end
end

function SlotsCardsBookPop:btnLeftClicked(btn)
    SlotsCardsAudioHandler:PlaySound("click")
    local nCurrent = self.bookPro.CurrentPaper
    local target = nCurrent - 1
    if target <= 0 or target > LuaHelper.tableSize(SlotsCardsConfig[SlotsCardsManager.album]) then
        return
    end
    self.flipper.enabled = true
    self.flipper.PageFlipTime = 0.4
    self.flipper.TimeBetweenPages = 0
    self.flipper:StartFlipping(target)
    self.btnLeft.interactable = false
    self.btnRight.interactable = false
end

function SlotsCardsBookPop:btnRightClicked(btn)
    SlotsCardsAudioHandler:PlaySound("click")
    local nCurrent = self.bookPro.CurrentPaper
    local target = nCurrent + 1
    if target <= 0 or target > LuaHelper.tableSize(SlotsCardsConfig[SlotsCardsManager.album]) then
        return
    end
    self.flipper.enabled = true
    self.flipper.PageFlipTime = 0.4
    self.flipper.TimeBetweenPages = 0
    self.flipper:StartFlipping(target)
    self.btnLeft.interactable = false
    self.btnRight.interactable = false
end

function SlotsCardsBookPop:Hide()
    SlotsCardsMainUIPop:SetThemeEntryActive(true)
    ViewAlphaAni:Hide(self.transform.gameObject)
end