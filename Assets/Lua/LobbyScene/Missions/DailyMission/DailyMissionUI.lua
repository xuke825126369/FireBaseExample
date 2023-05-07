require("Lua.LobbyScene.Missions.DailyMission.DailyMissionBonusUI")
require("Lua.LobbyScene.Missions.UseGemCompleteNowUI")
require("Lua.LobbyScene.Missions.DailyMission.MissionPointBonusUI")

DailyMissionUI = {}
DailyMissionUI.m_listMissionPointBonusNode = {}

DailyMissionUI.m_MissionPointConfig = {
    KeyPoints = {500, 1000},
    rewards = {
        {fCoinsCoef = 1.2, },
        {fCoinsCoef = 2.2, }
    }
}

function DailyMissionUI:Init(parent)
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local bundleName = "Lobby"
	local assetPath = "Assets/ResourceABs/Lobby/Missions/DailyTask/DailyTask.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local goPanel = Unity.Object.Instantiate(goPrefab)

    self.transform = goPanel.transform
    self.transform:SetParent(parent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
	self.transform.gameObject:SetActive(false)

    self.mCommonResSerialization = self.transform:GetComponent(typeof(CS.CommonResSerialization))

    self.m_textTimeLeft = self.transform:FindDeepChild("TextRemainTime"):GetComponent(typeof(TextMeshProUGUI))
    self.m_textMissionPoint = self.transform:FindDeepChild("TextMissionPoint"):GetComponent(typeof(TextMeshProUGUI))
    self.m_imgProgress = self.transform:FindDeepChild("ImageProgress"):GetComponent(typeof(UnityUI.Image))
    self.TextMeshProDailyCountDown = self.transform:FindDeepChild("TextMeshProDailyCountDown"):GetComponent(typeof(TextMeshProUGUI))

    self.m_trMissionNodeContent = self.transform:FindDeepChild("MissionNodeContent")
    local trUnlockInfoNode = self.transform:FindDeepChild("UnlockInfoNode")
    self.m_UnlockInfoNode = trUnlockInfoNode.gameObject
    self.TextUnlockLevel = trUnlockInfoNode:FindDeepChild("TextUnlockLevel"):GetComponent(typeof(UnityUI.Text))
    
    self.m_listMissionPointBonusNode = {}
    for i = 1, 2 do
        local strNodeName = "BtnLiHeNode" .. i
        local trBtnNode = self.transform:FindDeepChild(strNodeName)
        local BtnBonus = trBtnNode:GetComponentInChildren(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(BtnBonus)
        BtnBonus.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnMissionPointBonusClick(i)
        end)

        local AniBonus = trBtnNode:GetComponentInChildren(typeof(Unity.Animator))
        local data = {BtnBonus = BtnBonus, AniBonus = AniBonus, }
        table.insert(self.m_listMissionPointBonusNode, data)
    end
        
    self:initTaskNode()
    self:updateTimeLeft()
end

function DailyMissionUI:Show(parent)
    self:Init(parent)
    self.transform.gameObject:SetActive(true)

    self:initScrollViewSize()
    self:UpdateUI()

    self:initMissionPointBtnStatus()
    
    if not DailyMissionHandler:orUnLock() then
        self.m_UnlockInfoNode:SetActive(true)
        self.m_trMissionNodeContent.gameObject:SetActive(false)
        self.TextUnlockLevel.text = tostring(DailyMissionHandler.m_nDailyMissionUnlockLevel)

        local tr = MissionMainUIPop.TextMeshProDailyTaskCountTip.transform.parent
        tr.gameObject:SetActive(false)
    else
        self.m_UnlockInfoNode:SetActive(false)
        self.m_trMissionNodeContent.gameObject:SetActive(true)
    end

end

function DailyMissionUI:initMissionPointBtnStatus()
    local nMissionPoint = DailyMissionHandler.data.m_nMissionPoint
    local points = self.m_MissionPointConfig.KeyPoints
    for i=1, 2 do
        local ani = self.m_listMissionPointBonusNode[i].AniBonus
        local bFlag = false
        if nMissionPoint >= points[i] then
            if not DailyMissionHandler.data.m_missionPointBonusFlag[i] then
                bFlag = true
                ani:Play("BonusWaitForCollect", -1, 0) -- 等待领奖
            else
                -- 已经领奖
                ani:Play("BonusCollected", -1, 0)
            end
        else
            -- 未完成
            ani:Play("BonusUncomplete", -1, 0)
        end
        if bFlag then
            self.m_listMissionPointBonusNode[i].BtnBonus.interactable = true
        else
            self.m_listMissionPointBonusNode[i].BtnBonus.interactable = false
        end
        
    end
    
end

-- 进度条上的任务点数奖励 
function DailyMissionUI:OnMissionPointBonusClick(index) -- index 1 2
    Debug.Log("---OnMissionPointBonusClick---index: " .. index)
    
    local ani = self.m_listMissionPointBonusNode[index].AniBonus
    ani:Play("BonusCollecting", -1, 0)
    
    LeanTween.delayedCall(1.0, function()
        ani:Play("BonusCollected", -1, 0)
    end)

    MissionPointBonusUI:Show(MissionMainUIPop.m_trPopNode, index)
end

function DailyMissionUI:initScrollViewSize() 
    -- 从3个任务变成4个或更多任务的时候改变滚动区域大小
    local playerData = DailyMissionHandler.data
    local tasks = DailyMissionConfig:getDailyMissionIndexs(playerData.m_nCurDayIndex)
    local cnt = #tasks

    local nContentWidth = cnt * 420
    if cnt == 3 then
        nContentWidth = 1473
    end
    local nContentHeight = self.m_trMissionNodeContent.sizeDelta.y
    self.m_trMissionNodeContent.sizeDelta = Unity.Vector2(nContentWidth, nContentHeight)
end

function DailyMissionUI:releaseTaskNode()
    local cnt = #self.m_listTaskNodes
    for i=1, cnt do
        Unity.GameObject.Destroy(self.m_listTaskNodes[i])
    end
    self.m_listTaskNodes = {}

    Debug.Log("----DailyMissionUI:releaseTaskNode-----")
end

function DailyMissionUI:initTaskNode()
    self.m_listTaskNodes = {}
	local taskNodePrefab = self.mCommonResSerialization:FindPrefab("MissionNode")

    self.m_listChildNodes = {} -- cnt个子表

    local playerData = DailyMissionHandler.data
    local tasks = DailyMissionConfig:getDailyMissionIndexs(playerData.m_nCurDayIndex)
    local cnt = #tasks
    for i = 1, cnt do
		local taskNode = Unity.Object.Instantiate(taskNodePrefab)
		local tr = taskNode:GetComponent(typeof(Unity.RectTransform))
		tr:SetParent(self.m_trMissionNodeContent, false)
        local fx = 230 + (i-1) * 420
        if cnt == 3 then
            fx = 300 + (i-1) * 450
        end
		tr.anchoredPosition = Unity.Vector2(fx, 0)

        table.insert(self.m_listTaskNodes, taskNode)

        local nodes = {}
        nodes.TextRoyalstarPurchase = tr:FindDeepChild("TextRoyalstarPurchase"):GetComponent(typeof(TextMeshProUGUI))
        nodes.TextMeshProMorePercent = tr:FindDeepChild("TextMeshProMorePercent"):GetComponent(typeof(TextMeshProUGUI))
        nodes.TextRoyalstarFree = tr:FindDeepChild("TextRoyalstarFree"):GetComponent(typeof(TextMeshProUGUI))
        
        nodes.RoyalStarsNode = tr:FindDeepChild("RoyalStarsNode").gameObject
        nodes.RoyalStarsLogoPurchase = tr:FindDeepChild("RoyalStarsLogoPurchase").gameObject
        nodes.RoyalStarsLogoFree = tr:FindDeepChild("RoyalStarsLogoFree").gameObject

        nodes.LockedNode = tr:FindDeepChild("LockedNode").gameObject
        nodes.CompletedNode = tr:FindDeepChild("CompletedNode").gameObject
        nodes.UnlockedNode = tr:FindDeepChild("UnlockedNode").gameObject
        nodes.ImageMissionProgress = tr:FindDeepChild("ImageMissionProgress"):GetComponent(typeof(UnityUI.Image))
        nodes.TextMeshProProgress = tr:FindDeepChild("TextMeshProProgress"):GetComponent(typeof(TextMeshProUGUI))

        nodes.TextMissionDescription = tr:FindDeepChild("TextMissionDescription"):GetComponent(typeof(TextMeshProUGUI))

        nodes.goBtnPurchase = tr:FindDeepChild("BtnPurchase").gameObject
        nodes.goBtnCollect = tr:FindDeepChild("BtnCollect").gameObject
        nodes.TextGemValue = tr:FindDeepChild("TextGemValue"):GetComponent(typeof(TextMeshProUGUI))
            
        table.insert(self.m_listChildNodes, nodes)

        local btnPurchase = nodes.goBtnPurchase.transform:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnPurchase)
        btnPurchase.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnPurchaseMission(i)
        end)
        
        local btnCollect = nodes.goBtnCollect.transform:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnCollect)
        btnCollect.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnCollectReward(i)
        end)
        
        local trMissionIndex = tr:FindDeepChild("MissionIndex")
        local childCount = trMissionIndex.childCount
        for index = 0, childCount - 1 do
            local childObj = trMissionIndex:GetChild(index).gameObject
            childObj:SetActive(false)
            if index+1 == i then
                childObj:SetActive(true)
            end
        end
    end

end

function DailyMissionUI:OnPurchaseMission(i)
    local nDiamondCount = PlayerHandler.nSapphireCount

    local MissionValues = DailyMissionConfig.m_MissionsValue[DailyMissionHandler.data.m_curTaskIndex]
    local nGemValue = MissionValues.gemValue

    if nDiamondCount < nGemValue then
        BuyView:Show(BuyView.SHOP_VIEW_TYPE.GEMTYPE)
        return
    end

    UseGemCompleteNowUI:Show(nGemValue, function()
        self:buyMission(i)
    end)
    
end

function DailyMissionUI:buyMission(i)
    Debug.Assert(i == DailyMissionHandler.data.m_curTaskIndex)

    local MissionValues = DailyMissionConfig.m_MissionsValue[DailyMissionHandler.data.m_curTaskIndex]
    local nGemValue = MissionValues.gemValue
    PlayerHandler:AddSapphire(-nGemValue)
    
    local missionPlayerData = DailyMissionHandler.data.m_MissionPlayerData[i]
    missionPlayerData.isCompleted = true
    DailyMissionHandler:SaveDb()
    self:UpdateUI()
end

function DailyMissionUI:OnCollectReward(i)
    DailyMissionBonusUI:Show(MissionMainUIPop.m_trPopNode, i)
end

function DailyMissionUI:UpdateUI()
    local nMissionPoint = DailyMissionHandler.data.m_nMissionPoint
    if nMissionPoint > 1000 then
        nMissionPoint = 1000
    end
    local strPointInfo = string.format("%d/1000", nMissionPoint)
    self.m_textMissionPoint.text = strPointInfo

    self.m_imgProgress.fillAmount = nMissionPoint / 1000
    local tasks = DailyMissionConfig:getDailyMissionIndexs(DailyMissionHandler.data.m_nCurDayIndex)
    local cnt = #tasks
    
    if cnt ~= #self.m_listChildNodes then
        self:releaseTaskNode()
        self:initTaskNode()
    end

    for i = 1, cnt do
        local missionID = tasks[i]
        local Mission = DailyMissionConfig.m_Missions[missionID]
        local value = Mission.count[i]
        local targetNum = value
        local descriptionFormat = Mission.descriptionFormat
        if Mission.isCoinCoef then
            value = value * DailyMissionHandler.data.m_OneDollarCoins
            targetNum = value
            value = MoneyFormatHelper.coinCountOmit(value)
        end

        if missionID == 6 then
            targetNum = 5
        end

        local nodes = self.m_listChildNodes[i]
        if not RoyalPassHandler:orUnLock() then
            nodes.RoyalStarsNode:SetActive(false)
        else
            nodes.RoyalStarsNode:SetActive(true)
            nodes.RoyalStarsLogoPurchase:SetActive(false)
            nodes.RoyalStarsLogoFree:SetActive(true)

            if CommonDbHandler:orInMissionStarBoosterTime() then
                nodes.RoyalStarsLogoPurchase:SetActive(true)
                nodes.RoyalStarsLogoFree:SetActive(false)
            end
        end
        
        local MissionValues = DailyMissionConfig.m_MissionsValue[i]
        nodes.TextRoyalstarFree.text = tostring(MissionValues.rewards.missionStars)
        local nPurchaseStars = math.floor( MissionValues.rewards.missionStars * 2.5 )
        nodes.TextRoyalstarPurchase.text = tostring(nPurchaseStars)
        nodes.TextMeshProMorePercent.text = "150%"
        
        local missionPlayerData = DailyMissionHandler.data.m_MissionPlayerData[i]
        if i < DailyMissionHandler.data.m_curTaskIndex then
            Debug.Assert(missionPlayerData.isCompleted and missionPlayerData.isReward, "m_curTaskIndex: "..DailyMissionHandler.data.m_curTaskIndex)
            nodes.LockedNode:SetActive(false)
            nodes.UnlockedNode:SetActive(false)
            nodes.CompletedNode:SetActive(true)

        elseif i == DailyMissionHandler.data.m_curTaskIndex then
            nodes.TextMissionDescription.text = string.format(descriptionFormat, value)
            
            local fcoef = missionPlayerData.count / targetNum
            if fcoef > 1.0 or missionPlayerData.isCompleted then
                fcoef = 1
            end
            
            nodes.ImageMissionProgress.fillAmount = fcoef
            nodes.TextMeshProProgress.text = tostring( math.floor(fcoef*100) ) .. "%"
            
            nodes.LockedNode:SetActive(false)
            nodes.CompletedNode:SetActive(false)
            nodes.UnlockedNode:SetActive(true)

            if missionPlayerData.isCompleted then
                Debug.Assert( not missionPlayerData.isReward )
                -- 等待领奖状态
                nodes.goBtnCollect:SetActive(true)
                nodes.goBtnPurchase:SetActive(false)

            else
                -- 未完成状态
                nodes.goBtnCollect:SetActive(false)
                nodes.goBtnPurchase:SetActive(true)
                nodes.TextGemValue.text = tostring(MissionValues.gemValue)
            end
        else
            -- 未解锁状态
            nodes.LockedNode:SetActive(true)
            nodes.UnlockedNode:SetActive(false)
            nodes.CompletedNode:SetActive(false)
        end
    end

end

DailyMissionUI.fLastUpdateTime = 0.0
function DailyMissionUI:Update()
    if Unity.Time.time - self.fLastUpdateTime > 1.0 then
        self.fLastUpdateTime = Unity.Time.time
        self:updateTimeLeft()
    end
end

function DailyMissionUI:updateTimeLeft()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local timediff = DailyMissionHandler:GetActivityEndTimeSeconds() - nowSecond

    if timediff <= 0 then
        self:StartNextActivity()
    else
        local diff = nowSecond - DailyMissionHandler.m_nBaseTimeSecond
        local index = diff // DailyMissionHandler.m_nOneDaySecond
        if index % 7 ~= DailyMissionHandler.data.m_nCurDayIndex then
            self:StartNextDayTask()
        end
    end

    local days = timediff // (3600*24)
    local hours = timediff // 3600 - 24 * days
    local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
    local seconds = timediff % 60
    
    local strTimeInfo1 = ""
    local strTimeInfo2 = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    if days > 0 then
        strTimeInfo1 = string.format("%d DAYS LEFT!", days)
    else
        strTimeInfo1 = strTimeInfo2
    end

    self.m_textTimeLeft.text = strTimeInfo1
    self.TextMeshProDailyCountDown.text = strTimeInfo2
end

function DailyMissionUI:StartNextActivity() -- 7天任务重置
    DailyMissionHandler:StartNextActivity()

    if DailyMissionBonusUI:isActiveShow() then
        DailyMissionBonusUI.transform.gameObject:SetActive(false)
    end

    if MissionPointBonusUI:isActiveShow() then
        MissionPointBonusUI.transform.gameObject:SetActive(false)
    end
    
    if UseGemCompleteNowUI:isActiveShow() then
        UseGemCompleteNowUI:onClose()
    end

    self:initScrollViewSize()
    self:UpdateUI()
end

function DailyMissionUI:StartNextDayTask() -- 24小时任务刷新
    DailyMissionHandler:StartNextDayTask()
    
    if DailyMissionBonusUI:isActiveShow() then
        DailyMissionBonusUI.transform.gameObject:SetActive(false)
    end
    if MissionPointBonusUI:isActiveShow() then
        MissionPointBonusUI.transform.gameObject:SetActive(false)
    end
    if UseGemCompleteNowUI:isActiveShow() then
        UseGemCompleteNowUI:onClose()
    end
        
    self:initScrollViewSize() -- 有可能任务个数改变了
    self:UpdateUI()
end