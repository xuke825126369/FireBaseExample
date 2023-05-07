require("Lua.LobbyScene.Missions.FlashChallenge.FlashChallengeRewardScollView")
require("Lua.LobbyScene.Missions.FlashChallenge.FlashBoosterUI")
require("Lua.LobbyScene.Missions.UseGemCompleteNowUI")

FlashChallengeUI = {}
FlashBoosterUI.bLastInFlashBoosterTime = false

function FlashChallengeUI:Show(parent)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/FlashChallenge/FlashChallengeUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(parent, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_listGoLevelIcon = {nil, nil, nil, nil, nil}
        self.TextMeshProChallengeCountDownTip = self.transform:FindDeepChild("TextMeshProChallengeCountDownTip"):GetComponent(typeof(TextMeshProUGUI))
        self.TextMissionCountDownTip = self.transform:FindDeepChild("TextMissionCountDownTip"):GetComponent(typeof(TextMeshProUGUI))
        self.FlashBoosterNode = self.transform:FindDeepChild("FlashBoosterNode").gameObject
        self.TextMeshProFlashBoosterCountDown = self.transform:FindDeepChild("TextMeshProFlashBoosterCountDown"):GetComponent(typeof(TextMeshProUGUI))
        self.FlashBoosterPurchaseNode = self.transform:FindDeepChild("FlashBoosterPurchaseNode").gameObject

        local tr = self.transform:FindDeepChild("BtnPurchaseFlashBooster")
        local btnPurchaseFlashBooster = tr:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnPurchaseFlashBooster)
        btnPurchaseFlashBooster.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnPurchaseFlashBooster()
        end)

        --BtnRewards
        local tr = self.transform:FindDeepChild("BtnRewards")
        local btnReward = tr:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnReward)
        btnReward.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnReward()
        end)
        self.goBtnRewards = tr.gameObject

        self.rewardCountContainer = self.transform:FindDeepChild("ImageTiShi").gameObject
        self.TextMeshProRewardCount = self.transform:FindDeepChild("TextMeshProRewardCount"):GetComponent(typeof(TextMeshProUGUI))

        --BtnMissions
        tr = self.transform:FindDeepChild("BtnMissions")
        local btnMissions = tr:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnMissions)
        btnMissions.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnMissions()
        end)
        self.goBtnMissions = tr.gameObject

        self.MissionCountTipNode = self.transform:FindDeepChild("MissionCountTipNode").gameObject
        self.TextMeshProMissionCount = self.transform:FindDeepChild("TextMeshProMissionCount"):GetComponent(typeof(TextMeshProUGUI))
        
        self.TextSeason = self.transform:FindDeepChild("SeasonText"):GetComponent(typeof(TextMeshProUGUI))
        
        self.btnLeft = self.transform:FindDeepChild("BtnLeft"):GetComponent(typeof(UnityUI.Button))
        self.btnRight = self.transform:FindDeepChild("BtnRight"):GetComponent(typeof(UnityUI.Button))

        self.TextLevel = self.transform:FindDeepChild("TextLevel"):GetComponent(typeof(UnityUI.Text))
        self.TextFlameCount = self.transform:FindDeepChild("TextFlameCount"):GetComponent(typeof(TextMeshProUGUI))
        self.ImageLevelProgress = self.transform:FindDeepChild("ImageLevelProgress"):GetComponent(typeof(UnityUI.Image))

	    self.m_trMissionNodeContent = self.transform:FindDeepChild("ChallengeMissionNodeContent")
        self.m_UnlockInfoNode = self.transform:FindDeepChild("UnlockFlameChallengeNode").gameObject
        self.m_UnLockShowInfo = self.transform:FindDeepChild("UnLockShowInfo").gameObject
        self.TextUnlockLevel = self.m_UnlockInfoNode.transform:FindDeepChild("TextUnlockLevel"):GetComponent(typeof(UnityUI.Text))
        -- 切换到奖励界面要隐藏的节点
        self.goChallengeMissionScrollView = self.transform:FindDeepChild("ChallengeMissionScrollView").gameObject

        self:initChallengeMissionNode()
        
        FlashChallengeRewardScollView:Init(self.transform)
        FlashChallengeRewardScollView.scrollRect.gameObject:SetActive(false)

        self.seasonEndUI = require("Lua.LobbyScene.Missions.FlashChallenge.FlashChallengeSeasonEndUI")
        self.seasonEndUI:create(parent)

        self.mTimeOutGenerator = TimeOutGenerator:New()
    end
    
    self.transform.gameObject:SetActive(true)
    if not FlashChallengeHandler:orUnLock() then
        self.m_UnlockInfoNode:SetActive(true)
        self.TextUnlockLevel.text = tostring(FlashChallengeConfig.UNLOCKLEVEL)
        self.m_UnLockShowInfo:SetActive(false)
        self.goChallengeMissionScrollView:SetActive(false)
        self.FlashBoosterNode:SetActive(false)
        return
    else
        self.m_UnlockInfoNode:SetActive(false)
        self.m_UnLockShowInfo:SetActive(true)
        self.goChallengeMissionScrollView:SetActive(true)
    end

    self:checkFlashBoosterPurchaseNode()
    self:OnMissions()
    self:UpdateUI()
end

function FlashChallengeUI:Hide()
    self.transform.gameObject:SetActive(false)
    self.seasonEndUI.transform.gameObject:SetActive(false)
end

function FlashChallengeUI:checkFlashBoosterPurchaseNode()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local timediff = FlashChallengeHandler:GetSeasonEndTime() - nowSecond
    if timediff < 24 * 3600 * 5 then -- 最后五天显示出booster购买界面
        self.FlashBoosterPurchaseNode:SetActive(true)
    else
        self.FlashBoosterPurchaseNode:SetActive(false)
    end
end

function FlashChallengeUI:RefreshCountDown()
    local now = TimeHandler:GetServerTimeStamp()
    local bInFlashBoosterTime = now < CommonDbHandler.data.FlashBoosterEndTime
    if bInFlashBoosterTime ~= self.bLastInFlashBoosterTime then
        self.bLastInFlashBoosterTime = bInFlashBoosterTime
        if bInFlashBoosterTime then
            self.FlashBoosterNode:SetActive(true)
            self.FlashBoosterPurchaseNode:SetActive(false)
            local nRemainTime = CommonDbHandler.data.FlashBoosterEndTime - now
            local strRemainTime = os.date("!%X", nRemainTime)
            self.TextMeshProFlashBoosterCountDown.text = strRemainTime
        else
            self.FlashBoosterNode:SetActive(false)
            FlashChallengeUI:checkFlashBoosterPurchaseNode()
        end
    end
end

function FlashChallengeUI:initChallengeMissionNode()
    self.m_listTaskNodes = {}
	local taskNodePrefab = AssetBundleHandler:LoadMissionAsset("Missions/FlashChallenge/ChallengeMissionNode.prefab")

    self.m_listChildNodes = {} -- cnt个子表
    local playerData = FlashChallengeHandler.data
    local configParams = FlashChallengeHandler.data.m_ChallengeConfigParam
    local cnt = #configParams
    local nContentWidth = cnt * 420
    local nContentHeight = self.m_trMissionNodeContent.sizeDelta.y
    self.m_trMissionNodeContent.sizeDelta = Unity.Vector2(nContentWidth, nContentHeight)

    for i = 1, cnt do
		local taskNode = Unity.Object.Instantiate(taskNodePrefab)
		local tr = taskNode:GetComponent(typeof(Unity.RectTransform))
		tr:SetParent(self.m_trMissionNodeContent, false)
        local fx = 227 + (i - 1) * 420
		tr.anchoredPosition = Unity.Vector2(fx, 0)
        table.insert(self.m_listTaskNodes, taskNode)

        local nodes = {}
        nodes.TextRoyalStarsPurchase = tr:FindDeepChild("TextRoyalstarPurchase"):GetComponent(typeof(TextMeshProUGUI))
        nodes.TextMeshProRoyalStarsMorePercent = tr:FindDeepChild("TextMeshProMorePercent"):GetComponent(typeof(TextMeshProUGUI))
        nodes.TextRoyalStarsFree = tr:FindDeepChild("TextRoyalstarFree"):GetComponent(typeof(TextMeshProUGUI))
        
        nodes.RoyalStarsPurchaseNode = tr:FindDeepChild("RoyalStarsLogoPurchase").gameObject
        nodes.RoyalStarsFreeNode = tr:FindDeepChild("RoyalStarsLogoFree").gameObject

        nodes.TextFlashCount = tr:FindDeepChild("TextFlashCount"):GetComponent(typeof(UnityUI.Text))
        
        nodes.goBtnGo = tr:FindDeepChild("BtnGo").gameObject
        nodes.goBtnCollect = tr:FindDeepChild("BtnCollect").gameObject
        -- 当任务完成了 显示 goBtnCollect 同时隐藏 goBtnGo 和 goBtnCompleteNow
        nodes.goBtnCompleteNow = tr:FindDeepChild("BtnCompleteNow").gameObject
        
        nodes.TextGOBtnTip = nodes.goBtnGo.transform:FindDeepChild("TextBtnTip"):GetComponent(typeof(TextMeshProUGUI))
        nodes.TextGOBtnTip.text = "GO"
        
        local btnGo = nodes.goBtnGo.transform:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnGo)
        btnGo.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnGo(i)
        end)

        nodes.btnGo = btnGo
        
        local btnCollect = nodes.goBtnCollect.transform:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnCollect)
        btnCollect.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnCollect(i)
        end)
        
        local btnCompleteNow = nodes.goBtnCompleteNow.transform:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnCompleteNow)
        btnCompleteNow.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnCompleteNow(i)
        end)

        nodes.TextGemValue = nodes.goBtnCompleteNow.transform:FindDeepChild("TextGemValue"):GetComponent(typeof(TextMeshProUGUI))
        nodes.ImageMissionProgress = tr:FindDeepChild("ImageMissionProgress"):GetComponent(typeof(UnityUI.Image))
        nodes.TextMeshProMissionProgress = tr:FindDeepChild("TextMeshProMissionProgress"):GetComponent(typeof(TextMeshProUGUI))
        nodes.TextMeshProMissionTip = tr:FindDeepChild("TextMeshProMissionTip"):GetComponent(typeof(TextMeshProUGUI))
        nodes.trLevelIconParent = tr:FindDeepChild("LevelIconNode")
        table.insert(self.m_listChildNodes, nodes)
        nodes.RoyalStarsPurchaseNode:SetActive(false)
        nodes.RoyalStarsFreeNode:SetActive(true)
        self:refreshLevelIcon(i)
    end
    
end

function FlashChallengeUI:refreshLevelIcon(nTaskIndex)
    local playerData = FlashChallengeHandler.data

    local configParams = FlashChallengeHandler.data.m_ChallengeConfigParam
    local configParam = configParams[nTaskIndex]
    local nTaskID = configParam.nTaskID

    local name = ""
    if nTaskIndex < 5 then
        name = FlashChallengeHandler:GetCurrentTaskThemeKey(nTaskIndex)
    end 

    if nTaskIndex == 5 then
        if nTaskID == 5 then
            name = "LuckyWheel"
        elseif nTaskID == 6 then
            name = "MegaBall"
        elseif nTaskID == 7 then
            name = "WatchAD"
        elseif nTaskID == 8 then
            name = "CardPacks"
        else
            Debug.LogError("nTaskID: "..nTaskID)
        end
    end

    local bundleName = "Lobby"
    local strPath = "Assets/ResourceABs/Lobby/Missions/FlashChallenge/LevelIconPrefab/" .. name .. ".prefab"
    if nTaskIndex < 5 then
        if ThemeHelper:isClassicLevel(name) then
            bundleName = "ThemeClassicEntry"
            strPath = "Assets/ResourceABs/ThemeClassicEntry/"..name .."/smallIcon.prefab"
        else
            bundleName = "ThemeVideoEntry"
            strPath = "Assets/ResourceABs/ThemeVideoEntry/"..name .."/smallIcon.prefab"
        end
    end

    local levelIconPrefab = AssetBundleHandler:LoadAsset(bundleName, strPath)
    local levelIcon = Unity.Object.Instantiate(levelIconPrefab)

    if self.m_listGoLevelIcon[nTaskIndex] ~= nil then
        Unity.GameObject.Destroy(self.m_listGoLevelIcon[nTaskIndex])
        self.m_listGoLevelIcon[nTaskIndex] = nil
    end
    self.m_listGoLevelIcon[nTaskIndex] = levelIcon

    local tr = levelIcon:GetComponent(typeof(Unity.RectTransform))
    local nodes = self.m_listChildNodes[nTaskIndex]
    tr:SetParent(nodes.trLevelIconParent, false)
    tr.anchoredPosition = Unity.Vector2.zero
end

function FlashChallengeUI:OnPurchaseFlashBooster()
    FlashBoosterUI:Show(MissionMainUIPop.m_trPopNode)
end

function FlashChallengeUI:OnReward()
    self.goChallengeMissionScrollView:SetActive(false)
    self.FlashBoosterNode:SetActive(false)

    FlashChallengeRewardScollView:UpdateAllItem()
    FlashChallengeRewardScollView:ShowToInitPos()
    self.goBtnRewards:SetActive(false)
    self.goBtnMissions:SetActive(true)
    self:UpdateMissionCount()
end

function FlashChallengeUI:testFlashChallengeGame()
    local nRespinCount = 1
    local tableRate = {25, 5}
    local nStickyNum = 0
    local fProb = 0

    local nFullTimes = 0
    local nNoFullTimes = 0

    for i=1, 100 do
        nStickyNum = 0

        while true do
            if nStickyNum < 9 then
                fProb = 0.7
                if nRespinCount == 2 then
                    fProb = 0.8
                elseif nRespinCount == 3 then
                    fProb = 1.0
                end
                tableRate = {25, 8}
            elseif nStickyNum < 11 then
                fProb = 0.65
                tableRate = {25, 3}
            elseif nStickyNum < 13 then
                fProb = 0.25
                if nRespinCount == 2 then
                    fProb = 0.5
                elseif nRespinCount == 3 then
                    fProb = 0.65
                end
                tableRate = {25, 1}
            else
                fProb = 0.25
                tableRate = {25, 0}
            end
        
            local bFlag = math.random() < fProb
            local nCount = 0
            if bFlag then
                nCount = LuaHelper.GetIndexByRate(tableRate)
                nRespinCount = 0
            end

            nStickyNum = nStickyNum + nCount
            if nStickyNum >= 15 then
                nFullTimes = nFullTimes + 1
                break
            end

            nRespinCount = nRespinCount + 1
            if nRespinCount > 3 then
                nNoFullTimes = nNoFullTimes + 1
                break
            end
        end
    end

end

function FlashChallengeUI:OnMissions()
    self.goChallengeMissionScrollView:SetActive(true)
    FlashChallengeRewardScollView.scrollRect.gameObject:SetActive(false)
    self.btnLeft.gameObject:SetActive(false)
    self.btnRight.gameObject:SetActive(false)
    self.goBtnRewards:SetActive(true)
    self.goBtnMissions:SetActive(false)
end

function FlashChallengeUI:OnGo(nTaskIndex)
    self.m_listChildNodes[nTaskIndex].btnGo.interactable = false

    if nTaskIndex == 5 then
        MissionMainUIPop:Hide(true)
        return
    end 
    
    MissionMainUIPop:Hide()
    local themeKey = FlashChallengeHandler:GetCurrentTaskThemeKey(nTaskIndex)
    local configItem = ThemeHelper:GetConfigItemByThemeName(themeKey)
    ThemeLoader:LoadGame(configItem)

end

function FlashChallengeUI:OnCollect(nTaskIndex)
    local listPlayerData = FlashChallengeHandler.data.m_ChallengePlayerData
    local playData = listPlayerData[nTaskIndex]
    local nDoneTime = playData.nDoneTime

    local values = FlashChallengeConfig:getMissionValues(nDoneTime)
    local nFlameCount = values.rewards.FlameCount
    local nMissionStars = values.rewards.missionStars

    if CommonDbHandler:orInMissionStarBoosterTime() then
        nMissionStars = math.floor(nMissionStars * 2.5)
    end

    if CommonDbHandler.data.FlashBoosterEndTime ~= nil then
        if CommonDbHandler.data.FlashBoosterEndTime > TimeHandler:GetServerTimeStamp() then
            nFlameCount = math.floor(nFlameCount * 2)
        end
    end
        
    FlashChallengeRewardDataHandler:addFiresCount(nFlameCount)
    FlashChallengeHandler:CollectThisTaskAndToNextTask(nTaskIndex)
    FlashChallengeHandler:SaveDb()

    self:UpdateChallengeTopUI()
    local bLevelUp, bHasPrize = RoyalPassHandler:addStars(nMissionStars)
    if bLevelUp then
        LeanTween.delayedCall(1.0, function()
            PopStackViewHandler:Show(RoyalPassLevelUpUI, bHasPrize)
        end)
    end
    
    LeanTween.delayedCall(0.5, function()
        self:refreshTaskNode(nTaskIndex) -- 更新这个任务的UI显示
    end)
end

function FlashChallengeUI:OnCompleteNow(nTaskIndex)
    local listPlayerData = FlashChallengeHandler.data.m_ChallengePlayerData
    local listConfigParam = FlashChallengeHandler.data.m_ChallengeConfigParam

    local playData = listPlayerData[nTaskIndex]
    local nDoneTime = playData.nDoneTime
    local values = FlashChallengeConfig:getMissionValues(nDoneTime)
    local nGemValue = values.gemValue
    local nDiamondCount = PlayerHandler.nSapphireCount

    if nDiamondCount < nGemValue then
        BuyView:Show(BuyView.SHOP_VIEW_TYPE.GEMTYPE)
        return
    end

    UseGemCompleteNowUI:Show(nGemValue, function()
        self:buyMission(nTaskIndex)
    end)
end

function FlashChallengeUI:buyMission(nTaskIndex)
    local listPlayerData = FlashChallengeHandler.data.m_ChallengePlayerData
    local listConfigParam = FlashChallengeHandler.data.m_ChallengeConfigParam

    local playData = listPlayerData[nTaskIndex]
    local configParam = listConfigParam[nTaskIndex]
    playData.count = configParam.count -- 让任务完成。。
    playData.isCompleted = true
    FlashChallengeHandler:SaveDb()

    self:refreshTaskNode(nTaskIndex)
    local nDoneTime = playData.nDoneTime
    local values = FlashChallengeConfig:getMissionValues(nDoneTime)
    local nGemValue = values.gemValue -- 购买该任务需要的钻石数
    PlayerHandler:AddSapphire(-nGemValue)
    
end

function FlashChallengeUI:refreshTaskNode(nTaskIndex)
    self:refreshLevelIcon(nTaskIndex)
    local listPlayerData = FlashChallengeHandler.data.m_ChallengePlayerData
    local listConfigParam = FlashChallengeHandler.data.m_ChallengeConfigParam
    
    local playData = listPlayerData[nTaskIndex]
    local configParam = listConfigParam[nTaskIndex]
    local nTaskID = configParam.nTaskID
    local mission = FlashChallengeConfig.m_Missions[nTaskID]
    local strDescription = mission.descriptionFormat
    local targetCount = configParam.count
    if mission.isCoinCoef then
        targetCount = MoneyFormatHelper.coinCountOmit(configParam.count)
    end
    
    local strTip = ""
    if configParam.miniBet > 0 then
        local strMiniBet = MoneyFormatHelper.coinCountOmit(configParam.miniBet)
        strTip = string.format(strDescription, targetCount, strMiniBet)
    else
        strTip = string.format(strDescription, targetCount)
    end
    
    local missionNode = self.m_listChildNodes[nTaskIndex]
    missionNode.TextMeshProMissionTip.text = strTip
    missionNode.btnGo.interactable = true

    local nDoneTime = playData.nDoneTime
    
    local values = FlashChallengeConfig:getMissionValues(nDoneTime)

    local nFlameCount = values.rewards.FlameCount
    local nMissionStars = values.rewards.missionStars
    local nGemValue = values.gemValue

    missionNode.TextGemValue.text = tostring(nGemValue)

    missionNode.TextFlashCount.text = tostring(nFlameCount) .. "F"
    missionNode.TextRoyalStarsFree.text = tostring(nMissionStars)
    
    local bHasBooster = false
    if CommonDbHandler:orInMissionStarBoosterTime() then
        bHasBooster = true
        missionNode.RoyalStarsPurchaseNode:SetActive(true)
        missionNode.RoyalStarsFreeNode:SetActive(false)
    end

    if not bHasBooster then
        missionNode.RoyalStarsPurchaseNode:SetActive(false)
        missionNode.RoyalStarsFreeNode:SetActive(true)
    end
    local nPurchaseStars = math.floor( nMissionStars * 2.5 )
    missionNode.TextRoyalStarsPurchase.text = tostring(nPurchaseStars)
    missionNode.TextMeshProRoyalStarsMorePercent.text = "150%"

    if CommonDbHandler.data.FlashBoosterEndTime ~= nil then
        if CommonDbHandler.data.FlashBoosterEndTime > TimeHandler:GetServerTimeStamp() then
            local nFlameCount = math.floor(nFlameCount * 2)
            missionNode.TextFlashCount.text = tostring(nFlameCount) .. "F"
        end
    end

    -- 看广告任务 如果检测到已经免广告了 就置为已完成
    if nTaskIndex == 5 then
        if nTaskID == 17 then
            if AdsConfigHandler:orInBlackList() then
                playData.count = configParam.count
                playData.isCompleted = true
            end
        end
    end

    local fcoef = playData.count / configParam.count
    if fcoef > 1.0 then
        fcoef = 1.0
    end

    missionNode.ImageMissionProgress.fillAmount = fcoef
    missionNode.TextMeshProMissionProgress.text = tostring( math.floor(fcoef*100) ) .. "%"
    
    if fcoef >= 1.0 then
        missionNode.goBtnGo:SetActive(false)
        missionNode.goBtnCompleteNow:SetActive(false)
        missionNode.goBtnCollect:SetActive(true)
    else
        missionNode.goBtnGo:SetActive(true)
        missionNode.TextGOBtnTip.text = "GO"
        missionNode.goBtnCompleteNow:SetActive(true)
        missionNode.goBtnCollect:SetActive(false)

        if GameConfig.Instance.orUseAssetBundle then
            if nTaskIndex < 5 then
                local themeKey = FlashChallengeHandler:GetCurrentTaskThemeKey(nTaskIndex)
                local bundleName = ThemeHelper:GetThemeBundleName(themeKey)
                -- 需要版本更新才能玩的关卡
                local mThemeWebItemDic = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig.mThemeWebItemDic
                local mItem = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig:GetHotUpdateItem(mThemeWebItemDic, bundleName)
                if not mItem:IsVersionCached() then
                    missionNode.TextGOBtnTip.text = "UPDATE REQUIRED"
                    missionNode.goBtnCompleteNow:SetActive(false)
                end
            end
        end
    end
end

function FlashChallengeUI:UpdateRewardCount()
    local nCount = FlashChallengeRewardDataHandler:getNumberOfRewardsNotReceived()
    self.rewardCountContainer:SetActive(nCount > 0)
    self.TextMeshProRewardCount.text = nCount
end

function FlashChallengeUI:UpdateMissionCount()
    local playerData = FlashChallengeHandler.data.m_ChallengePlayerData
    local cnt = 0
    for i=1, #playerData do
        if playerData[i].isCompleted then
            cnt = cnt + 1
        end
    end
    
    self.MissionCountTipNode:SetActive(cnt > 0)
    self.TextMeshProMissionCount.text = cnt
end

function FlashChallengeUI:UpdateUI()
    self:UpdateChallengeTopUI()
    for i = 1, 5 do
        self:refreshTaskNode(i)
    end
end

function FlashChallengeUI:UpdateChallengeTopUI()
    local nSeasonId = FlashChallengeHandler:GetSeasonId()
    local nLevel = FlashChallengeRewardDataHandler:GetCurrentLevel()

    self.TextSeason.text = string.format("%d", nSeasonId + 1)
    self.TextLevel.text = tostring(nLevel)
    self.TextFlameCount.text = tostring(FlashChallengeRewardDataHandler.data.nFiresCount)

    local nLevel = LuaHelper.Clamp(nLevel, 1, 5)
    local nLength = LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards[nLevel])
    local nNeedFire = FlashChallengeRewardConfig.m_mapAllRewards[nLevel][nLength].nFireCount
    self.ImageLevelProgress.fillAmount = 1 - FlashChallengeRewardDataHandler.data.nFiresCount / nNeedFire
    self:UpdateRewardCount()
end

function FlashChallengeUI:Update()
	if self.mTimeOutGenerator:orTimeOut() then
        self:RefreshCountDown()

        if FlashChallengeHandler:orDifferentSeason() then
            self:OnSeasonEndResetChallenge()
        end

        if FlashChallengeHandler:orDifferentDay() then
            FlashChallengeHandler:ResetTodayTaskData()
            self:RefreshChallengeDailyTaskUI()
        end

        local nowSecond = TimeHandler:GetServerTimeStamp()
        local timediff = FlashChallengeHandler:GetSeasonEndTime() - nowSecond
        local days = timediff // (3600*24)
        local hours = timediff // 3600 - 24 * days
        local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
        local seconds = timediff % 60

        local strTimeInfoChallenge = ""
        local strTimeInfoDailyMission = ""
        local strTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        self.m_strCountDown = strTime

        if days > 0 then
            strTimeInfoChallenge = string.format("%d DAYS LEFT!", days)
        else
            strTimeInfoChallenge = "Challenge End In " .. strTime
        end
        
        self.TextMeshProChallengeCountDownTip.text = strTimeInfoChallenge
        self.TextMissionCountDownTip.text = "Missions reset time " .. strTime
    end
end

function FlashChallengeUI:OnSeasonEndResetChallenge() -- 赛季结束任务重置
    if UseGemCompleteNowUI:isActiveShow() then
        UseGemCompleteNowUI:onClose()
    end
    
    local nLastLevel = FlashChallengeRewardDataHandler:GetCurrentLevel()

    FlashChallengeHandler:ResetTodayTaskData()
    FlashChallengeRewardDataHandler:StartNextSeason()

    self.transform.gameObject:SetActive(false)
    self.seasonEndUI:show(nLastLevel)
end

function FlashChallengeUI:RefreshChallengeDailyTaskUI()
    if UseGemCompleteNowUI:isActiveShow() then
        UseGemCompleteNowUI:onClose()
    end

    for i = 1, 5 do
        self:refreshTaskNode(i)
    end
end
