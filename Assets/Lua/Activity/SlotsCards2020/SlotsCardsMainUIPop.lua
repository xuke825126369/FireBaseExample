SlotsCardsMainUIPop = {}
SlotsCardsMainUIPop.m_mapThemeEntryUI = {}
SlotsCardsMainUIPop.m_LeanTweenIDs = {}
SlotsCardsMainUIPop.INIT_POSX = 200
SlotsCardsMainUIPop.ITEM_DISTANCE = 180

function SlotsCardsMainUIPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadSlotsCardsAsset("SlotsCardsMainUIPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

	    self.scrollContent = self.transform:FindDeepChild("ScrollViewContent")
        self.scrollRect = self.transform:FindDeepChild("ThemeScrollView"):GetComponent(typeof(UnityUI.ScrollRect))
        self.goBonusStampUI = self.transform:FindDeepChild("BonusStampUI").gameObject
        self.m_bonusStampCardAni = self.goBonusStampUI:GetComponentInChildren(typeof(Unity.Animator))
        self.aniBottomUI = self.transform:FindDeepChild("Bottom"):GetComponent(typeof(Unity.Animator))

        local btn = self.transform:FindDeepChild("IntroduceBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            SlotsCardsAudioHandler:PlaySound("click")
            SlotsCardsPrizesPop:Show()
        end)

        self.btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))

        self.totalReward = self.transform:FindDeepChild("TotalReward"):GetComponent(typeof(UnityUI.Text))

        DelegateCache:addOnClickButton(self.btnClose)
        self.btnClose.onClick:AddListener(function()
            SlotsCardsAudioHandler:PlaySound("click")
            self:Hide()
        end)

        self:UpdateSlotsCardsAlbum()

        self.starShopBtn = self.transform:FindDeepChild("StarShopBtn"):GetComponent(typeof(UnityUI.Button))
        self.starPopAni = self.starShopBtn.transform:GetComponent(typeof(Unity.Animator))
        DelegateCache:addOnClickButton(self.starShopBtn)
        self.starShopBtn.onClick:AddListener(function()
            SlotsCardsAudioHandler:PlaySound("button")
            SlotsCardsStarShopPop:Show()
        end)
        local btn = self.transform:FindDeepChild("ShopBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            SlotsCardsAudioHandler:PlaySound("button")
            BuyView:Show()
        end)
        self.starOneBtn = self.transform:FindDeepChild("CardPack1"):GetComponent(typeof(UnityUI.Button))
        self.starTwoBtn = self.transform:FindDeepChild("CardPack2"):GetComponent(typeof(UnityUI.Button))
        self.starThreeBtn = self.transform:FindDeepChild("CardPack3"):GetComponent(typeof(UnityUI.Button))
        self.starFourBtn = self.transform:FindDeepChild("CardPack4"):GetComponent(typeof(UnityUI.Button))
        self.starFiveBtn = self.transform:FindDeepChild("CardPack5"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.starOneBtn)
        DelegateCache:addOnClickButton(self.starTwoBtn)
        DelegateCache:addOnClickButton(self.starThreeBtn)
        DelegateCache:addOnClickButton(self.starFourBtn)
        DelegateCache:addOnClickButton(self.starFiveBtn)
        self.starOneBtn.onClick:AddListener(function()
            self:btnOneStarPackClicked()
        end)
        self.starTwoBtn.onClick:AddListener(function()
            self:btnTwoStarPackClicked()
        end)
        self.starThreeBtn.onClick:AddListener(function()
            self:btnThreeStarPackClicked()
        end)
        self.starFourBtn.onClick:AddListener(function()
            self:btnFourStarPackClicked()
        end)
        self.starFiveBtn.onClick:AddListener(function()
            self:btnFiveStarPackClicked()
        end)
        self.m_mapPackCount = {}
        self.m_mapPackCount[1] = self.starOneBtn.transform:FindDeepChild("PackCount"):GetComponent(typeof(TextMeshProUGUI))
        self.m_mapPackCount[2] = self.starTwoBtn.transform:FindDeepChild("PackCount"):GetComponent(typeof(TextMeshProUGUI))
        self.m_mapPackCount[3] = self.starThreeBtn.transform:FindDeepChild("PackCount"):GetComponent(typeof(TextMeshProUGUI))
        self.m_mapPackCount[4] = self.starFourBtn.transform:FindDeepChild("PackCount"):GetComponent(typeof(TextMeshProUGUI))
        self.m_mapPackCount[5] = self.starFiveBtn.transform:FindDeepChild("PackCount"):GetComponent(typeof(TextMeshProUGUI))
        self.m_mapPackCountBg = {}
        self.m_mapPackCountBg[1] = self.starOneBtn.transform:FindDeepChild("CountBg").gameObject
        self.m_mapPackCountBg[2] = self.starTwoBtn.transform:FindDeepChild("CountBg").gameObject
        self.m_mapPackCountBg[3] = self.starThreeBtn.transform:FindDeepChild("CountBg").gameObject
        self.m_mapPackCountBg[4] = self.starFourBtn.transform:FindDeepChild("CountBg").gameObject
        self.m_mapPackCountBg[5] = self.starFiveBtn.transform:FindDeepChild("CountBg").gameObject

        self.m_textStarCount = self.transform:FindDeepChild("StarCountText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_goAllCompleted = self.transform:FindDeepChild("Done").gameObject
        self.leftTimeContainer = self.transform:FindDeepChild("Container/EndIn").gameObject
        self.m_textTime = self.leftTimeContainer.transform:FindDeepChild("TimeLeft"):GetComponent(typeof(TextMeshProUGUI))

        if SlotsCardsManager.album == "Album2" then
            self.goShopFreePackMark = self.transform:FindDeepChild("Container/Bottom/StarShopBtn/Pack").gameObject
        end
    end

    if SlotsCardsManager.album == "Album2" then
        EventHandler:AddListener("onSecond", self)
        self:onSecond(TimeHandler:GetServerTimeStamp())
    end

    self.m_goAllCompleted:SetActive(SlotsCardsHandler.data.activityData[SlotsCardsManager.album].bIsGetCompletedGift)
    self.totalReward.text = MoneyFormatHelper.numWithCommas(SlotsCardsHandler.data.activityData[SlotsCardsManager.album].m_nCompleteAllReward)
    self:ShowMainUI()
    ViewAlphaAni:Show(self.transform.gameObject, function()
        self.aniBottomUI:SetInteger("nPlayMode", 2)
        SlotsCardsAudioHandler:PlayBackMusic("stamp_music")
        EventHandler:Brocast("ShowBonusStampPop")
        SlotsCardsHandler:checkThemeEnd()
    end)    

    self:UpdateStarCount()
    local endTime = SlotsCardsManager.nActivityEndTime
    if endTime ~= nil then
        if (endTime - TimeHandler:GetServerTimeStamp() // (3600*24)) < 30 then
            self:onSlotsCardsTimeChange()
            EventHandler:AddListener("onSlotsCardsTimeChange", self)
        else
            self.leftTimeContainer:SetActive(false)
        end
    end

end

function SlotsCardsMainUIPop:ShowMainUI()
    local id = LeanTween.scale(self.totalReward.gameObject, Unity.Vector3.one, 0.5).id
    table.insert( self.m_LeanTweenIDs, id )
    self.starShopBtn.interactable = true
    self:RefreshPackCountText()
    self.goBonusStampUI:SetActive(false)
end

function SlotsCardsMainUIPop:ShowBonusStampUI()
    if SlotsCardsBookPop.transform ~= nil then
        if SlotsCardsBookPop.transform.gameObject.activeSelf then
            SlotsCardsBookPop:Hide()
        end
    end
    local id = LeanTween.scale(self.totalReward.gameObject, Unity.Vector3.zero, 0.2).id
    table.insert( self.m_LeanTweenIDs, id )
    self.starShopBtn.interactable = false
    self.starOneBtn.interactable = false
    self.starTwoBtn.interactable = false
    self.starThreeBtn.interactable = false
    self.starFourBtn.interactable = false
    self.starFiveBtn.interactable = false
    self.goBonusStampUI:SetActive(true)
    self.aniBottomUI:SetInteger("nPlayMode", 1)
    for k,v in pairs(self.m_mapThemeEntryUI) do
        v:AddBonusStampCardListenerInEntry()
    end
end

function SlotsCardsMainUIPop:UpdateStarCount()
    local count = SlotsCardsHandler.data.activityData.nTatalStar
    if count == nil then
        count = 0
    end
    self.m_textStarCount.text = count
end

function SlotsCardsMainUIPop:DoStarCountUpdateAni()
    self.starPopAni:SetTrigger(Unity.Animator.StringToHash("ShowEffect"))
    local count = SlotsCardsHandler.data.activityData.nTatalStar
    if count == nil then
        count = 0
    end
    local startValue = tonumber(self.m_textStarCount.text)
    LeanTween.value(startValue, count, 0.5):setOnUpdate(function(value)
        self.m_textStarCount.text = string.format("%d", math.floor(value))
    end)
end

function SlotsCardsMainUIPop:RefreshPackCountText()
    local oneStarCount = SlotsCardsHandler.data.activityData.m_nOneStarPackCount
    if oneStarCount >= 1 then
        self.starOneBtn.interactable = true
        if not self.m_mapPackCountBg[1].activeSelf then
            self.m_mapPackCountBg[1]:SetActive(true)
        end
        self.m_mapPackCount[1].text = (oneStarCount > 99) and "+99" or oneStarCount
    else
        self.starOneBtn.interactable = false
        if self.m_mapPackCountBg[1].activeSelf then
            self.m_mapPackCountBg[1]:SetActive(false)
        end
    end
    local twoStarCount = SlotsCardsHandler.data.activityData.m_nTwoStarPackCount
    if twoStarCount >= 1 then
        self.starTwoBtn.interactable = true
        if not self.m_mapPackCountBg[2].activeSelf then
            self.m_mapPackCountBg[2]:SetActive(true)
        end
        self.m_mapPackCount[2].text = (twoStarCount > 99) and "+99" or twoStarCount
    else
        self.starTwoBtn.interactable = false
        if self.m_mapPackCountBg[2].activeSelf then
            self.m_mapPackCountBg[2]:SetActive(false)
        end
    end
    local threeStarCount = SlotsCardsHandler.data.activityData.m_nThreeStarPackCount
    if threeStarCount >= 1 then
        self.starThreeBtn.interactable = true
        if not self.m_mapPackCountBg[3].activeSelf then
            self.m_mapPackCountBg[3]:SetActive(true)
        end
        self.m_mapPackCount[3].text = (threeStarCount > 99) and "+99" or threeStarCount
    else
        self.starThreeBtn.interactable = false
        if self.m_mapPackCountBg[3].activeSelf then
            self.m_mapPackCountBg[3]:SetActive(false)
        end
    end
    local fourStarCount = SlotsCardsHandler.data.activityData.m_nFourStarPackCount
    if fourStarCount >= 1 then
        self.starFourBtn.interactable = true
        if not self.m_mapPackCountBg[4].activeSelf then
            self.m_mapPackCountBg[4]:SetActive(true)
        end
        self.m_mapPackCount[4].text = (fourStarCount > 99) and "+99" or fourStarCount
    else
        self.starFourBtn.interactable = false
        if self.m_mapPackCountBg[4].activeSelf then
            self.m_mapPackCountBg[4]:SetActive(false)
        end
    end
    local fiveStarCount = SlotsCardsHandler.data.activityData.m_nFiveStarPackCount
    if fiveStarCount >= 1 then
        self.starFiveBtn.interactable = true
        if not self.m_mapPackCountBg[5].activeSelf then
            self.m_mapPackCountBg[5]:SetActive(true)
        end
        self.m_mapPackCount[5].text = (fiveStarCount > 99) and "+99" or fiveStarCount
    else
        self.starFiveBtn.interactable = false
        if self.m_mapPackCountBg[5].activeSelf then
            self.m_mapPackCountBg[5]:SetActive(false)
        end
    end
end

--用来刷新卡牌数据UI
function SlotsCardsMainUIPop:refresh()
    if self.transform.gameObject == nil then
        return
    end
    local albumKey = SlotsCardsManager.album
    if LuaHelper.tableSize(self.m_mapThemeEntryUI) == 0 then
        return
    end
    --如果已经初始化过，重新刷新数据
    for i=1, #SlotsCardsConfig[albumKey] do
        local themeKey = SlotsCardsConfig[albumKey][i].ThemeKey
        self.m_mapThemeEntryUI[themeKey]:refreshUI()
    end
    self:refreshCompleteUI()
end

function SlotsCardsMainUIPop:refreshCompleteUI()
    self.m_goAllCompleted:SetActive(SlotsCardsHandler.data.activityData[SlotsCardsManager.album].bIsGetCompletedGift)
end

function SlotsCardsMainUIPop:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i=1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

function SlotsCardsMainUIPop:Hide()
    self:CancelLeanTween()
    EventHandler:RemoveListener("onSlotsCardsTimeChange", self)
    SlotsCardsAudioHandler:StopBackMusic()
    ViewAlphaAni:Hide(self.transform.gameObject)
end

function SlotsCardsMainUIPop:UpdateSlotsCardsAlbum()
    local albumeKey = SlotsCardsManager.album
    if LuaHelper.tableSize(self.m_mapThemeEntryUI) ~= 0 then
        for i = 1, #SlotsCardsConfig[albumeKey] do
            local themeKey = SlotsCardsConfig[albumeKey][i].ThemeKey
            self.m_mapThemeEntryUI[themeKey]:refreshUI()
        end
    else
        self:initEntryContent()
    end
    self.scrollRect.horizontalNormalizedPosition = 0
end

function SlotsCardsMainUIPop:btnOneStarPackClicked()
    local bIsGet, addProgressInfo = SlotsCardsGiftManager:OnPackClicked(SlotsCardsAllProbTable.PackType.One)
    if bIsGet then
        SlotsCardsAudioHandler:PlaySound("button")
        EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
        self:RefreshPackCountText()
        SlotsCardsOpenPackPop:Show(addProgressInfo, SlotsCardsAllProbTable.PackType.One)
    end
end

function SlotsCardsMainUIPop:btnTwoStarPackClicked()
    local bIsGet, addProgressInfo = SlotsCardsGiftManager:OnPackClicked(SlotsCardsAllProbTable.PackType.Two)
    if bIsGet then
        SlotsCardsAudioHandler:PlaySound("button")
        EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
        self:RefreshPackCountText()
        SlotsCardsOpenPackPop:Show(addProgressInfo, SlotsCardsAllProbTable.PackType.Two)
    end
end

function SlotsCardsMainUIPop:btnThreeStarPackClicked()
    local bIsGet, addProgressInfo = SlotsCardsGiftManager:OnPackClicked(SlotsCardsAllProbTable.PackType.Three)
    if bIsGet then
        SlotsCardsAudioHandler:PlaySound("button")
        EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
        self:RefreshPackCountText()
        SlotsCardsOpenPackPop:Show(addProgressInfo, SlotsCardsAllProbTable.PackType.Three)
    end
end

function SlotsCardsMainUIPop:btnFourStarPackClicked()
    local bIsGet, addProgressInfo = SlotsCardsGiftManager:OnPackClicked(SlotsCardsAllProbTable.PackType.Four)
    if bIsGet then
        SlotsCardsAudioHandler:PlaySound("button")
        EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
        self:RefreshPackCountText()
        SlotsCardsOpenPackPop:Show(addProgressInfo, SlotsCardsAllProbTable.PackType.Four)
    end
end

function SlotsCardsMainUIPop:btnFiveStarPackClicked()
    local bIsGet, addProgressInfo = SlotsCardsGiftManager:OnPackClicked(SlotsCardsAllProbTable.PackType.Five)
    if bIsGet then
        SlotsCardsAudioHandler:PlaySound("button")
        EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
        self:RefreshPackCountText()
        SlotsCardsOpenPackPop:Show(addProgressInfo, SlotsCardsAllProbTable.PackType.Five)
    end
end

function SlotsCardsMainUIPop:initEntryContent()
	--TODO 初始化scrollview的大小
	local cnt = #SlotsCardsConfig[SlotsCardsManager.album]
	local fx = self.INIT_POSX * 1.1 + self.ITEM_DISTANCE * (cnt - 1)
	self.scrollContent.sizeDelta = Unity.Vector2(fx, 0)

	for i=1, #SlotsCardsConfig[SlotsCardsManager.album] do
		local themeKey = SlotsCardsConfig[SlotsCardsManager.album][i].ThemeKey
		local themeName = SlotsCardsConfig[SlotsCardsManager.album][i].ThemeName
		local strPath = "ThemeEntry/".. themeKey .."Entry.prefab"
		local prefabObj = AssetBundleHandler:LoadSlotsCardsAsset(strPath)
		local go = Unity.Object.Instantiate(prefabObj)
		local themeItem = SlotsCardThemeEntry:new(go, themeKey, i)
		if self.m_mapThemeEntryUI[themeKey] == nil then
			self.m_mapThemeEntryUI[themeKey] = themeItem
		end
		self:setThemeEntryItemPos(i, themeKey, go.transform)
	end
end

--初始化位置，读取数据，更新界面数据
function SlotsCardsMainUIPop:setThemeEntryItemPos(index, themeKey, themeTr)
	themeTr:SetParent(self.scrollContent)
	if index % 2 == 0 then
		local fx = self.INIT_POSX + (index - 2) * self.ITEM_DISTANCE
		themeTr.anchoredPosition = Unity.Vector2(fx, -400)--150)
	else
		local fx = self.INIT_POSX + (index - 1) * self.ITEM_DISTANCE
		themeTr.anchoredPosition = Unity.Vector2(fx, -141)
	end
	themeTr.localScale = Unity.Vector3.one
end

function SlotsCardsMainUIPop:randomGetNotOwnCard(themeKey)
    SlotsCardsHandler.data.activityData.m_nStampBonusCount = 0
    SlotsCardsHandler:SaveDb()
    for k,v in pairs(self.m_mapThemeEntryUI) do
        local btn = v.button
        btn.onClick:RemoveAllListeners()
        btn.interactable = false
    end
    self.scrollRect.enabled = false
    self.btnClose.interactable = false
    local strCardKey = nil
    local cardsInfo = SlotsCardsHandler.data.activityData[SlotsCardsManager.album].m_mapCardsInfo
    for i = LuaHelper.tableSize(SlotsCardsConfig[SlotsCardsManager.album][1].ThemeCards), 1, -1 do
        local cardKey = themeKey..i
        if cardsInfo[cardKey].cardCount == 0 then
            strCardKey = cardKey
            break
        end
    end
    if strCardKey == nil then
        Debug.LogError("万能牌有错误!!!!!!")
    end
    local data = {}
    data[1] = {}
    data[1].themeKey = themeKey
    data[1].cardKey = strCardKey
    data[1].count = 1
    SlotsCardsHandler:addCard(data)
    SlotsCardsHandler.data.activityData[SlotsCardsManager.album].m_mapCardsInfo[strCardKey].cardCount = SlotsCardsHandler.data.activityData[strCardKey].count
    SlotsCardsHandler:updateThemeProgress()
    self:ShowGetCardAni(data)
end

function SlotsCardsMainUIPop:ShowGetCardAni(data)
	self.m_bonusStampCardAni:SetTrigger(Unity.Animator.StringToHash("ShowEffect"))
    
    local id = LeanTween.delayedCall(2.1, function()
        SlotsCardsAudioHandler:PlaySound("card_show")
        local path = "Card.prefab"
        local prefab = AssetBundleHandler:LoadSlotsCardsAsset(path)
        local card = Unity.Object.Instantiate(prefab).transform
        
        card:SetParent(self.goBonusStampUI.transform)
        card.localScale = Unity.Vector3.one
        card.anchoredPosition3D = Unity.Vector3.zero
        card.localRotation = Unity.Quaternion.Euler(0,0,0)
        local cardItem = ShowCard:new(card.gameObject, SlotsCardsManager.album, data[1].themeKey, data[1].cardKey)
        self:showFromBonusStampFlyAni(cardItem, 1.5, self.m_mapThemeEntryUI[data[1].themeKey].transform.position, data[1].themeKey)
    end).id
    table.insert( self.m_LeanTweenIDs, id )
end

function SlotsCardsMainUIPop:showFromBonusStampFlyAni(cardItem, delay, to, themeKey)
    local id = LeanTween.delayedCall(delay,function()
        if self.transform ~= nil and self.transform.gameObject.activeInHierarchy then
            SlotsCardsAudioHandler:PlaySound("card_fly")
            local id1 = LeanTween.scale(cardItem.gameObject, Unity.Vector3.one*0.5, 0.4).id
            table.insert( self.m_LeanTweenIDs, id1 )
            local id2 = LeanTween.rotate(cardItem.gameObject, Unity.Vector3(0, 0, 15), 0.4).id
            table.insert( self.m_LeanTweenIDs, id2 )
            local id3 = LeanTween.move(cardItem.gameObject, to, 0.5):setEase(LeanTweenType.easeInOutQuad):setOnComplete(function()
                self.m_mapThemeEntryUI[themeKey]:refreshUI()
                self.m_mapThemeEntryUI[themeKey].ani:SetTrigger(Unity.Animator.StringToHash("ThemeEntryPress"))
                self.m_mapThemeEntryUI[themeKey].effectGo:SetActive(true)
                local id4 = LeanTween.delayedCall(1.5, function()
                    self.m_mapThemeEntryUI[themeKey].effectGo:SetActive(false)
                end).id
                table.insert( self.m_LeanTweenIDs, id4 )
                Unity.GameObject.Destroy(cardItem.gameObject)
                -- 鬼牌换卡牌动画结束后，将所有入口的事件换成进入book
                for k,v in pairs(self.m_mapThemeEntryUI) do
                    v:AddThemeEntryListener()
                    v.button.interactable = true
                end
                self.scrollRect.enabled = true
                self:ShowMainUI()
                self.aniBottomUI:SetInteger("nPlayMode", 2)
                self.btnClose.interactable = true
                SlotsCardsHandler:checkThemeEnd()
            end).id
            table.insert( self.m_LeanTweenIDs, id3 )
        end
    end).id
    table.insert( self.m_LeanTweenIDs, id )
end

function SlotsCardsMainUIPop:SetThemeEntryActive(bShow)
    self.scrollRect.gameObject:SetActive(bShow)
end

function SlotsCardsMainUIPop:onSlotsCardsTimeChange()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local endTime = SlotsCardsManager.nActivityEndTime
    local time =  endTime - nowSecond
    local str = ActivityHelper:FormatTime(time)
    self.m_textTime.text = str
    if time <= 0 then
        self.leftTimeContainer:SetActive(false)
    else
        if not self.leftTimeContainer.activeSelf then
            self.leftTimeContainer:SetActive(true)
        end
    end
end

function SlotsCardsMainUIPop:onSecond(nowSecond)
    local lastFreeTime = SlotsCardsHandler:getFreePackTime()
    if lastFreeTime == nil then
        lastFreeTime = TimeHandler:GetServerTimeStamp()
        local nType = SlotsCardsStarShopPop:randomGetPackType()
        SlotsCardsHandler:setFreePackTime(nType)
    end
    local endTime = lastFreeTime + SlotsCardsHandler.FREEPACKTIMEDIFF
    local timediff = endTime - nowSecond
    self.goShopFreePackMark:SetActive(timediff <= 0)
end