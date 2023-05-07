
require("Lua.BuildGame.BuildObj")
require("Lua.BuildGame.BuildShowObj")
require("Lua.BuildGame.BuildGameRulesPop")
require("Lua.BuildGame.BuildGameGiftBoxPop")
require("Lua.BuildGame.BuildGameAllCompletedPop")
require("Lua.BuildGame.BuildGameRestarPop")
require("Lua.BuildGame.BuildGameShowResultePop")

BuildGameMainUIPop = {}



BuildGameMainUIPop.m_gameObject = nil
BuildGameMainUIPop.m_transform = nil
BuildGameMainUIPop.m_mapBuildObjects = {}
BuildGameMainUIPop.m_nCurIndex = 1 --对应self.m_mapBuildObjects索引

function BuildGameMainUIPop:createAndShow()
    Scene.loadingAssetBundle:SetActive(true)
    local co = StartCoroutine(function()
        BuildGameAssetBundleHandler:LoadFromCache()
        local waitTime = Unity.WaitForSeconds(0.1)
        while not BuildGameUnloadedUI.m_bAssetReady do
            yield_return(waitTime)
        end
        self:Show()
        Scene.loadingAssetBundle:SetActive(false)
    end)
end

function BuildGameMainUIPop:Show()
    if self.m_gameObject == nil then
        local strPath = "Assets/BuildYourCity/BuildGameMainPop.prefab"
        local prefabObj = Util.getBuildGamePrefab(strPath)
        self.m_gameObject = Unity.Object.Instantiate(prefabObj)
        self.m_transform = self.m_gameObject.transform
        self.m_transform:SetParent(LobbyScene.popCanvas, false)
        self.popController = PopController:new(self.m_gameObject)

        self.m_textTotalReward = self.m_transform:FindDeepChild("TotalReward"):GetComponent(typeof(TextMeshProUGUI))
        self.m_trPrizeUIContainer = self.m_transform:FindDeepChild("PrizeUI")
        self.m_trIndexContainer = self.m_transform:FindDeepChild("IndexContainer")
        self.m_trTipContainer = self.m_transform:FindDeepChild("TiShiKuang")
        self.m_trBuildContainer = self.m_transform:FindDeepChild("BuildContainer")
        self.m_goBuildCompleted = self.m_transform:FindDeepChild("BuildCompleted").gameObject

        local btnGoShop = self.m_transform:FindDeepChild("BtnGoShop"):GetComponent(typeof(UnityUI.Button))
        btnGoShop.onClick:AddListener(function()
            BuyView:Show()
        end)

        local btnGo = self.m_trTipContainer:FindDeepChild("BtnGo"):GetComponent(typeof(UnityUI.Button))
        btnGo.onClick:AddListener(function()
            BuyView:Show()
        end)

        local btnRules = self.m_transform:FindDeepChild("BtnRules"):GetComponent(typeof(UnityUI.Button))
        btnRules.onClick:AddListener(function()
            self:btnRulesClicked()
        end)
        local btnClose = self.m_transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        btnClose.onClick:AddListener(function()
            self:hide()
        end)

        self.m_btnFreeDepot = self.m_transform:FindDeepChild("BtnCommonFree"):GetComponent(typeof(UnityUI.Button))
        self.m_btnFreeDepot.onClick:AddListener(function()
            self:btnFreeDepotClicked()
        end)

        self.btnCommonDepot = self.m_transform:FindDeepChild("BtnCommonDepot"):GetComponent(typeof(UnityUI.Button))
        self.btnCommonDepot.onClick:AddListener(function()
            self:btnCommonDepotClicked()
        end)

        self.btnRareDepot = self.m_transform:FindDeepChild("BtnRareDepot"):GetComponent(typeof(UnityUI.Button))
        self.btnRareDepot.onClick:AddListener(function()
            self:btnRareDepotClicked()
        end)

        self.btnEpicDepot = self.m_transform:FindDeepChild("BtnEpicDepot"):GetComponent(typeof(UnityUI.Button))
        self.btnEpicDepot.onClick:AddListener(function()
            self:btnEpicDepotClicked()
        end)

        self.btnLegendaryDepot = self.m_transform:FindDeepChild("BtnLegendaryDepot"):GetComponent(typeof(UnityUI.Button))
        self.btnLegendaryDepot.onClick:AddListener(function()
            self:btnLegendaryDepotClicked()
        end)

        self.btnLeft = self.m_transform:FindDeepChild("BtnLeft"):GetComponent(typeof(UnityUI.Button))
        self.btnLeft.onClick:AddListener(function()
            self:leftBtnClicked()
        end)
        self.btnRight = self.m_transform:FindDeepChild("BtnRight"):GetComponent(typeof(UnityUI.Button))
        self.btnRight.onClick:AddListener(function()
            self:rightBtnClicked()
        end)
        self.m_nCurIndex = 1
        self:initBuildObjects()
        NotificationHandler:addObserver(self,"onPurchaseDoneNotifycation")
    end
    if GameConfig.PLATFORM_EDITOR then
        if CS.BootBehaviour.instance.m_giveMangDepots then
            BuildGameDataHandler:sendMangDepots()
        end    
    end
    ViewScaleAni:Show(self.transform.gameObject)
    local isCompleted,reward = BuildGameDataHandler:checkIsAllBuildCompleted()
    if isCompleted then
        if reward == nil then
            --如果reward 为空，表示已经领取过奖励，但没有restar
            BuildGameRestarPop:createAndShow()
        else
            BuildGameAllCompletedPop:createAndShow(reward)
        end
    end
    self:refreshUI()
    AudioHandler:PlayBuildGameMusic("background")
end

function BuildGameMainUIPop:refreshUI()
    -- BuildGameDataHandler:changePointsToBuildProbs()
    for k,v in pairs(self.m_mapBuildObjects) do
        v:skipBtnClicked()
        v:refreshUI()
    end
    self.m_trTipContainer.gameObject:SetActive(false)
    self:refreshBtnStatus()
    self:refreshPrizeUI()
end

function BuildGameMainUIPop:initBuildObjects()
    self.btnLeft.interactable = false
    
    for k,v in pairs(BuildGameConfig.Build[BuildGameDataHandler.m_curSeason]) do
        local strType = k
        local path = "Assets/BuildYourCity/"..BuildGameDataHandler.m_curSeason.."/".. strType ..".prefab"
        local prefabObj = Util.getBuildGamePrefab(path)
        local obj = Unity.Object.Instantiate(prefabObj)
        obj.transform:SetParent(self.m_trBuildContainer)
        obj.transform.localScale = Unity.Vector3.one
        obj.transform.anchoredPosition3D = Unity.Vector3.zero
        local buildObj = BuildObj:new(obj, strType)
        buildObj:refreshUI()
        obj:SetActive( self:getIndexFromStrType(strType) == self.m_nCurIndex)
        self.m_mapBuildObjects[strType] = buildObj
    end
end

function BuildGameMainUIPop:refreshPrizeUI()
    local index = 0
    if self.m_nCurIndex <= 3 then
        index = 0
    elseif self.m_nCurIndex <= 6 then
        index = 1
    else
        index = 2
    end
    for i=0,self.m_trPrizeUIContainer.childCount-1 do
        self.m_trPrizeUIContainer:GetChild(i).gameObject:SetActive(i==index)
    end
    
    -- 刷新奖励UI显示
    local rewardContainer = self.m_trPrizeUIContainer:GetChild(index):FindDeepChild("RewardContainer")
    local rewardList = BuildGameDataHandler.m_runningData[BuildGameDataHandler.m_curSeason].rewardList[self:getStrTypeFromIndex(self.m_nCurIndex)]
    for i=0, rewardContainer.childCount-1 do
        rewardContainer:GetChild(i):GetComponent(typeof(TextMeshProUGUI)).text = MoneyFormatHelper.numWithCommas(MoneyFormatHelper.normalizeCoinCount(rewardList[i + 1]))
    end

    local blackBgContainer = self.m_trPrizeUIContainer:GetChild(index):FindDeepChild("BlackBGContainer")
    local data = self:getStrTypeDataFromIndex()
    if data.level >= 5 then
        self.m_goBuildCompleted:SetActive(true)
    else
        self.m_goBuildCompleted:SetActive(false)
    end
    for i=0, blackBgContainer.childCount - 1 do
        local level = 0
        if data ~= nil then
            level = data.level
        end
        blackBgContainer:GetChild(i).gameObject:SetActive( i < level )
    end
    self.m_textTotalReward.text = MoneyFormatHelper.numWithCommas(BuildGameDataHandler.m_runningData[BuildGameDataHandler.m_curSeason].m_nCompleteAllReward)
end

function BuildGameMainUIPop:refreshBtnStatus()
    self:refreshFreeDepot()
    self:refreshCommonDepot()
    self:refreshRareDepot()
    self:refreshEpicDepot()
    self:refreshLegendaryDepot()
end

function BuildGameMainUIPop:refreshFreeDepot()
    if BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason].m_bIsGetCompletedGift then
        self.m_btnFreeDepot.gameObject:SetActive(false)
    end
    local lastFreeTime = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason].m_nGetFreeDepotsTime
    local endTime = lastFreeTime + BuildGameDataHandler.FREEDEPOTSTIMEDIFF
    local co = StartCoroutine(function()
        local timeGo = self.m_btnFreeDepot.transform:FindDeepChild("TimeText").gameObject
        local countGo = self.m_btnFreeDepot.transform:FindDeepChild("CountContainer").gameObject
        timeGo:SetActive(true)
        countGo:SetActive(false)
        self.m_btnFreeDepot.interactable = false
        local timeText = timeGo:GetComponent(typeof(TextMeshProUGUI))
        local waitTime = Unity.WaitForSeconds(1)
        while self.m_gameObject ~= nil do
            local nowSecond = TimeHandler:GetServerTimeStamp()
            local timediff = endTime - nowSecond

            local days = timediff // (3600*24)
            local hours = timediff // 3600 - 24 * days
            local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
            local seconds = timediff % 60
            timeText.text = string.format("%02d:%02d:%02d", hours, minutes, seconds) --os.date("%H:%M:%S", time)
            if timediff <= 0 then
                timeGo:SetActive(false)
                countGo:SetActive(true)
                self.m_btnFreeDepot.interactable = true
                break
            end
            yield_return(waitTime)
        end
    end)
end

function BuildGameMainUIPop:refreshCommonDepot()
    local data = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason]
    self.btnCommonDepot.transform:FindDeepChild("HasDepot").gameObject:SetActive(data.m_nCommonCount>0)
    self.btnCommonDepot.transform:FindDeepChild("CountContainer").gameObject:SetActive(data.m_nCommonCount>0)
    self.btnCommonDepot.transform:FindDeepChild("CountText"):GetComponent(typeof(TextMeshProUGUI)).text = data.m_nCommonCount
end

function BuildGameMainUIPop:refreshRareDepot()
    local data = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason]
    self.btnRareDepot.transform:FindDeepChild("HasDepot").gameObject:SetActive(data.m_nRareCount>0)
    self.btnRareDepot.transform:FindDeepChild("CountContainer").gameObject:SetActive(data.m_nRareCount>0)
    self.btnRareDepot.transform:FindDeepChild("CountText"):GetComponent(typeof(TextMeshProUGUI)).text = data.m_nRareCount
end

function BuildGameMainUIPop:refreshEpicDepot()
    local data = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason]
    self.btnEpicDepot.transform:FindDeepChild("HasDepot").gameObject:SetActive(data.m_nEpicCount>0)
    self.btnEpicDepot.transform:FindDeepChild("CountContainer").gameObject:SetActive(data.m_nEpicCount>0)
    self.btnEpicDepot.transform:FindDeepChild("CountText"):GetComponent(typeof(TextMeshProUGUI)).text = data.m_nEpicCount
end

function BuildGameMainUIPop:refreshLegendaryDepot()
    local data = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason]
    self.btnLegendaryDepot.transform:FindDeepChild("HasDepot").gameObject:SetActive(data.m_nLegendaryCount>0)
    self.btnLegendaryDepot.transform:FindDeepChild("CountContainer").gameObject:SetActive(data.m_nLegendaryCount>0)
    self.btnLegendaryDepot.transform:FindDeepChild("CountText"):GetComponent(typeof(TextMeshProUGUI)).text = data.m_nLegendaryCount
end

function BuildGameMainUIPop:getStrTypeDataFromIndex()
    local strType = self:getStrTypeFromIndex(self.m_nCurIndex)
    return BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason][strType]
end

function BuildGameMainUIPop:getStrTypeFromIndex(index)
    local strType = ""
    if index == 1 then
        strType = "Silver1"
    elseif index == 2 then
        strType = "Silver2"
    elseif index == 3 then
        strType = "Silver3"
    elseif index == 4 then
        strType = "Gold1"
    elseif index == 5 then
        strType = "Gold2"
    elseif index == 6 then
        strType = "Gold3"
    elseif index == 7 then
        strType = "Diamond1"
    elseif index == 8 then
        strType = "Diamond2"
    end
    return strType
end

function BuildGameMainUIPop:getIndexFromStrType(strType)
    local index = 0
    if strType == "Silver1" then
        index = 1
    elseif strType == "Silver2" then
        index = 2
    elseif strType == "Silver3" then
        index = 3
    elseif strType == "Gold1" then
        index = 4
    elseif strType == "Gold2" then
        index = 5
    elseif strType == "Gold3" then
        index = 6
    elseif strType == "Diamond1" then
        index = 7
    elseif strType == "Diamond2" then
        index = 8
    end
    return index
end

function BuildGameMainUIPop:leftBtnClicked()
    self.m_nCurIndex = self.m_nCurIndex - 1
    local strType = self:getStrTypeFromIndex(self.m_nCurIndex)
    self.m_mapBuildObjects[strType].gameObject:SetActive(true)
    self.m_mapBuildObjects[strType]:refreshUI()
    self.m_mapBuildObjects[self:getStrTypeFromIndex(self.m_nCurIndex+1)].gameObject:SetActive(false)
    self.m_trIndexContainer:GetChild(self.m_nCurIndex-1).gameObject:SetActive(true)
    self.m_trIndexContainer:GetChild(self.m_nCurIndex).gameObject:SetActive(false)
    if self.m_nCurIndex == 1 then
        self.btnLeft.interactable = false
    else
        self.btnLeft.interactable = true
    end
    self.btnRight.interactable = true
    self:refreshPrizeUI()
end

function BuildGameMainUIPop:rightBtnClicked()
    self.m_nCurIndex = self.m_nCurIndex + 1
    local strType = self:getStrTypeFromIndex(self.m_nCurIndex)
    self.m_mapBuildObjects[strType].gameObject:SetActive(true)
    self.m_mapBuildObjects[strType]:refreshUI()
    self.m_mapBuildObjects[self:getStrTypeFromIndex(self.m_nCurIndex-1)].gameObject:SetActive(false)
    self.m_trIndexContainer:GetChild(self.m_nCurIndex-1).gameObject:SetActive(true)
    self.m_trIndexContainer:GetChild(self.m_nCurIndex-2).gameObject:SetActive(false)
    if self.m_nCurIndex == 8 then
        self.btnRight.interactable = false
    else
        self.btnRight.interactable = true
    end
    self.btnLeft.interactable = true
    self:refreshPrizeUI()
end

function BuildGameMainUIPop:hide()
    AudioHandler:PlayBuildGameSound("click")
    AudioHandler:StopBuildGameMusic()
    self.popController:hide(false, function()
        self:unloadAllAssetBundle()
    end)
end

function BuildGameMainUIPop:unloadAllAssetBundle()
    if GameConfig.PLATFORM_EDITOR then
        return
    end

    Unity.Object.Destroy(self.m_gameObject)
    self.m_gameObject = nil
    self.m_mapBuildObjects = {}
    NotificationHandler:removeObserver(self)

    if BuildGameRulesPop.m_gameObject ~= nil then
        Unity.Object.Destroy(BuildGameRulesPop.m_gameObject)
        BuildGameRulesPop.m_gameObject = nil
    end
    if BuildGameGiftBoxPop.m_gameObject ~= nil then
        Unity.Object.Destroy(BuildGameGiftBoxPop.m_gameObject)
        BuildGameGiftBoxPop.m_gameObject = nil
    end
    if BuildGameShowAddProgressPop.m_gameObject ~= nil then
        Unity.Object.Destroy(BuildGameShowAddProgressPop.m_gameObject)
        BuildGameShowAddProgressPop.m_gameObject = nil
        BuildGameShowAddProgressPop.m_mapLeanTweenIds = {}
        BuildGameShowAddProgressPop.m_mapBuildShowObjects = {}
    end
    if BuildGameAllCompletedPop.m_gameObject ~= nil then
        Unity.Object.Destroy(BuildGameAllCompletedPop.m_gameObject)
        BuildGameAllCompletedPop.m_gameObject = nil
    end
    if BuildGameRestarPop.m_gameObject ~= nil then
        Unity.Object.Destroy(BuildGameRestarPop.m_gameObject)
        BuildGameRestarPop.m_gameObject = nil
    end
    if BuildGameShowResultePop.m_gameObject ~= nil then
        Unity.Object.Destroy(BuildGameShowResultePop.m_gameObject)
        BuildGameShowResultePop.m_gameObject = nil
        BuildGameShowResultePop.buildContainer = nil
    end
    BuildGameAssetBundleHandler:unloadBuildGameAssetBundle()
end

function BuildGameMainUIPop:btnRulesClicked()
    AudioHandler:PlayBuildGameSound("click")
    --TODO 显示Rules
    BuildGameRulesPop:createAndShow()
end

function BuildGameMainUIPop:btnFreeDepotClicked()
    AudioHandler:PlayBuildGameSound("click")
    local bIsGetFree = BuildGameManager:getFreeDepotsClicked()
    if bIsGetFree then
        self:refreshBtnStatus()
    end
end

function BuildGameMainUIPop:btnCommonDepotClicked()
    local bIsGet, addProgressInfo, count = BuildGameManager:commonDepotsClicked()
    if bIsGet then
        AudioHandler:PlayBuildGameSound("open_vault")
        --TODO 显示获取哪些点数
        BuildGameShowAddProgressPop:createAndShow(BuildGameAllProbTable.DepotsType.Common, addProgressInfo, count)
    else
        if not self.m_trTipContainer.gameObject.activeInHierarchy then
            self.m_trTipContainer.anchoredPosition = Unity.Vector2(self.m_trTipContainer.anchoredPosition.x, self.btnCommonDepot.transform.anchoredPosition.y)
            self.m_trTipContainer.gameObject:SetActive(true)
            LeanTween.delayedCall(2.5,function()
                self.m_trTipContainer.gameObject:SetActive(false)
            end)
        end
    end
end

function BuildGameMainUIPop:btnRareDepotClicked()
    local bIsGet, addProgressInfo, count = BuildGameManager:rareDepotsClicked()
    if bIsGet then
        AudioHandler:PlayBuildGameSound("open_vault")
        --TODO 显示获取哪些点数
        BuildGameShowAddProgressPop:createAndShow(BuildGameAllProbTable.DepotsType.Rare, addProgressInfo, count)
    else
        if not self.m_trTipContainer.gameObject.activeInHierarchy then
            self.m_trTipContainer.anchoredPosition = Unity.Vector2(self.m_trTipContainer.anchoredPosition.x, self.btnRareDepot.transform.anchoredPosition.y)
            self.m_trTipContainer.gameObject:SetActive(true)
            LeanTween.delayedCall(2.5,function()
                self.m_trTipContainer.gameObject:SetActive(false)
            end)
        end
    end
end

function BuildGameMainUIPop:btnEpicDepotClicked()
    local bIsGet, addProgressInfo, count = BuildGameManager:epicDepotsClicked()
    if bIsGet then
        AudioHandler:PlayBuildGameSound("open_vault")
        --TODO 显示获取哪些点数
        BuildGameShowAddProgressPop:createAndShow(BuildGameAllProbTable.DepotsType.Epic, addProgressInfo, count)
    else
        if not self.m_trTipContainer.gameObject.activeInHierarchy then
            self.m_trTipContainer.anchoredPosition = Unity.Vector2(self.m_trTipContainer.anchoredPosition.x, self.btnEpicDepot.transform.anchoredPosition.y)
            self.m_trTipContainer.gameObject:SetActive(true)
            LeanTween.delayedCall(2.5,function()
                self.m_trTipContainer.gameObject:SetActive(false)
            end)
        end
    end
end

function BuildGameMainUIPop:btnLegendaryDepotClicked()
    local bIsGet, addProgressInfo, count = BuildGameManager:legendaryDepotsClicked()
    if bIsGet then
        AudioHandler:PlayBuildGameSound("open_vault")
        --TODO 显示获取哪些点数
        BuildGameShowAddProgressPop:createAndShow(BuildGameAllProbTable.DepotsType.Legendary, addProgressInfo, count)
    else
        if not self.m_trTipContainer.gameObject.activeInHierarchy then
            self.m_trTipContainer.anchoredPosition = Unity.Vector2(self.m_trTipContainer.anchoredPosition.x, self.btnLegendaryDepot.transform.anchoredPosition.y)
            self.m_trTipContainer.gameObject:SetActive(true)
            LeanTween.delayedCall(2.5,function()
                self.m_trTipContainer.gameObject:SetActive(false)
            end)
        end
    end
end

function BuildGameMainUIPop:onPurchaseDoneNotifycation(data)
    if self.m_gameObject.activeSelf then
        self:refreshUI()
    end
end