MissionLevelEntry = {}
MissionLevelEntry.m_btnTaskUI = nil -- 有时可能设置不可点击
MissionLevelEntry.m_aniBtn = nil

MissionLevelEntry.m_fPreMissionPercent = 0
MissionLevelEntry.m_fPreChallengePercent = 0
local EnumPageType = {
    EnumDailyTaskType = 1,
    EnumFlashChallengeType = 2,
}
MissionLevelEntry.m_nCurPageType = EnumPageType.EnumDailyTaskType

function MissionLevelEntry:Show()
    local TopBottomTransform = Unity.GameObject.Find("TopBottomUI").transform
    self.m_goPayTableBtn = TopBottomTransform:FindDeepChild("Buttonpaytable").gameObject
    self.m_goDailyTaskBtn =  TopBottomTransform:FindDeepChild("BtnTaskUI").gameObject

    if DailyMissionHandler:orUnLock() then
        self.m_goPayTableBtn:SetActive(false)
        self.m_goDailyTaskBtn:SetActive(true)
    else
        self.m_goPayTableBtn:SetActive(true)
        self.m_goDailyTaskBtn:SetActive(false)
        return
    end

    if not LuaHelper.OrGameObjectExist(self.transform) then
        self.transform = self.m_goDailyTaskBtn.transform
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

        local trTaskFailedTipAni = self.transform:FindDeepChild("TaskFailedTipAni")
        self.m_goTaskFailedTipAni = trTaskFailedTipAni.gameObject
        self.m_aniTaskFailed = trTaskFailedTipAni:GetComponent(typeof(Unity.Animator))

        local trBtnNode = self.transform:FindDeepChild("fanzhuan")
        self.m_aniMissionBtn = trBtnNode:GetComponent(typeof(Unity.Animator))

        local trDailyTask = self.transform:FindDeepChild("DailyTaskBtnNode")
        self.m_goTaskCompletedLogo = trDailyTask:FindDeepChild("TaskCompletedLogo").gameObject

        local trChallenge = self.transform:FindDeepChild("FlashChallengeBtnNode")
        self.m_goChallengeCompletedLogo = trChallenge:FindDeepChild("TaskCompletedLogo").gameObject

        local tr = self.transform:FindDeepChild("TextMeshProSpinClaimCountDown")
        self.m_textMeshProSpinClaimCountDown = tr:GetComponent(typeof(TextMeshProUGUI))

        tr = trDailyTask:FindDeepChild("TaskProgress")
        self.m_imageMissionProgress = tr:GetComponent(typeof(UnityUI.Image))

        tr = trChallenge:FindDeepChild("TaskProgress")
        self.m_imageChallengeProgress = tr:GetComponent(typeof(UnityUI.Image))
            
        tr = trDailyTask:FindDeepChild("progressLightEffect")
        self.m_rectTrProgressLightEffectTask = tr:GetComponent(typeof(Unity.RectTransform))

        tr = trChallenge:FindDeepChild("progressLightEffect")
        self.m_rectTrProgressLightEffectChallenge = tr:GetComponent(typeof(Unity.RectTransform))

        local btnTaskUI = trDailyTask:GetComponentInChildren(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnTaskUI)
        btnTaskUI.onClick:AddListener(function()
            self:onTaskUIBtnClicked()
        end)
        self.m_btnTaskUI = btnTaskUI

        local btnChallengeUI = trChallenge:GetComponentInChildren(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnChallengeUI)
        btnChallengeUI.onClick:AddListener(function()
            self:onChallengeBtnClicked()
        end)
        self.m_btnChallengeUI = btnChallengeUI
        ----------------------------

        local tr = self.transform:FindDeepChild("TaskCompleted")
        self.TaskCompleted = tr.gameObject
        self.aniTaskCompleted = tr:GetComponent(typeof(Unity.Animator))

        self.m_aniDailyTaskBtn = trDailyTask:GetComponentInChildren(typeof(Unity.Animator))
        self.m_aniChallengeBtn = trChallenge:GetComponentInChildren(typeof(Unity.Animator))

        self.goTaskTip = self.transform:FindDeepChild("TaskDesTipAni").gameObject
        self.goTaskTip:SetActive(false)
        self.textTaskDes = self.goTaskTip.transform:FindDeepChild("TextTip1"):GetComponent(typeof(TextMeshProUGUI))

        self.mTimeOutGenerator1 = TimeOutGenerator:New(6)
        self.mTimeOutGenerator2 = TimeOutGenerator:New()
    end

    self.transform.gameObject:SetActive(true)

    self.TaskCompleted:SetActive(false)
    self.transform.gameObject:SetActive(true)
    self.m_goTaskFailedTipAni:SetActive(false)
    self.m_rectTrProgressLightEffectTask.gameObject:SetActive(false)
    self.m_rectTrProgressLightEffectChallenge.gameObject:SetActive(false)

    if FlashChallengeHandler:orUnLock() and FlashChallengeHandler:IsFlashChallengeTheme() then
        self.m_aniMissionBtn:Play("fanzhuanB", -1, 0)
        self.m_nCurPageType = EnumPageType.EnumFlashChallengeType
    elseif not DailyMissionHandler:orTodayAllTaskFinish() then
        self.m_aniMissionBtn:Play("fanzhuanA", -1, 0)
        self.m_nCurPageType = EnumPageType.EnumDailyTaskType
    else
        self.m_goPayTableBtn:SetActive(true)
        self.m_goDailyTaskBtn:SetActive(false)
    end 

    self:RefreshDailyTaskUIParam()
    self:RefreshChallengeUIParam()
end

function MissionLevelEntry:Update()
    if self.mTimeOutGenerator1:orTimeOut() then
        self:updateButtonStatus()
    end

    if self.mTimeOutGenerator2:orTimeOut() then
        self:updateTimeLeft()
    end
end

function MissionLevelEntry:onTaskUIBtnClicked()
    if DailyMissionHandler:orTodayAllTaskFinish() then
        return
    end 
    
    GlobalAudioHandler:PlayBtnSound()
    if DailyMissionHandler:orTaskFinish() then
        ThemeLoader:ReturnToLobby()
        MissionMainUIPop:Show()
    elseif FlashChallengeHandler:orTaskFinish() then
        ThemeLoader:ReturnToLobby()
        MissionMainUIPop:Show(2)
    else
        self.goTaskTip:SetActive(true)
        LeanTween.delayedCall(self.transform.gameObject, 2.0, function()
            self.goTaskTip:SetActive(false)
        end)
    end

end

function MissionLevelEntry:onChallengeBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    if FlashChallengeHandler:orTaskFinish() then
        ThemeLoader:ReturnToLobby()
        MissionMainUIPop:Show(2)
    elseif DailyMissionHandler:orTaskFinish() then
        ThemeLoader:ReturnToLobby()
        MissionMainUIPop:Show()
    else
        self.goTaskTip:SetActive(true)
        LeanTween.delayedCall(2.0, function()
            self.goTaskTip:SetActive(false)
        end)
    end
end

function MissionLevelEntry:TaskFailedTip()
    self.m_textMeshProSpinClaimCountDown.text = "0"
    self.m_goTaskFailedTipAni:SetActive(true)
    LeanTween.delayedCall(7.0, function()
        self.m_goTaskFailedTipAni:SetActive(false)
    end)
end

function MissionLevelEntry:RefreshChallengeUIParam()
    self.m_goChallengeCompletedLogo:SetActive(false)
    if not FlashChallengeHandler:orUnLock() then
        return
    end

    if not FlashChallengeHandler:IsFlashChallengeTheme() then
        self.m_rectTrProgressLightEffectChallenge.eulerAngles = Unity.Vector3(0, 0, 0)
        self.m_imageChallengeProgress.fillAmount = 0
        return
    end

    local nTaskIndex = FlashChallengeHandler:GetTaskIndex()
    local listPlayerData = FlashChallengeHandler.data.m_ChallengePlayerData
    local listConfigParam = FlashChallengeHandler.data.m_ChallengeConfigParam
    local playData = listPlayerData[nTaskIndex]
    local configParam = listConfigParam[nTaskIndex]
    local nTaskID = configParam.nTaskID
    local Mission = FlashChallengeConfig.m_Missions[nTaskID]

    local fCurChallengePercent = playData.count / configParam.count
    if fCurChallengePercent < 1 then
        self.m_aniChallengeBtn:SetInteger("nPlayMode", 0)
    else
        LeanTween.delayedCall(self.transform.gameObject, 0.5, function()
            if self.TaskCompleted.activeSelf then
                self.aniTaskCompleted:Play("TaskCompleted", -1, 0)
            else
                self.TaskCompleted:SetActive(true)
            end
            self.m_aniChallengeBtn:SetInteger("nPlayMode", 1)
        end)
    end 
        
    LeanTween.value(self.transform.gameObject, self.m_fPreChallengePercent, fCurChallengePercent, 0.5):setOnUpdate(function(value)
        local fAngle = -360 * value
        self.m_rectTrProgressLightEffectChallenge.eulerAngles = Unity.Vector3(0, 0, fAngle)
        self.m_imageChallengeProgress.fillAmount = value
    end):setOnComplete(function()
        self.m_fPreChallengePercent = fCurChallengePercent
    end)
    
    if self.m_nCurPageType == EnumPageType.EnumFlashChallengeType then
        if Mission.isCoinCoef then
            self.textTaskDes.text = string.format(Mission.descriptionFormat, MoneyFormatHelper.coinCountOmit(configParam.count))
        else
            self.textTaskDes.text = string.format(Mission.descriptionFormat, configParam.count)
        end
    end

end 

function MissionLevelEntry:RefreshDailyTaskUIParam()
    if DailyMissionHandler:orTodayAllTaskFinish() then
        self.m_goTaskCompletedLogo:SetActive(true)
        return
    else
        self.m_goTaskCompletedLogo:SetActive(false)
    end
    
    local m_nCurDayIndex = DailyMissionHandler.data.m_nCurDayIndex
    local nCurTaskIndex = DailyMissionHandler.data.m_curTaskIndex
    local tasks = DailyMissionConfig:getDailyMissionIndexs(m_nCurDayIndex)
    local missionID = tasks[nCurTaskIndex]
    local Mission = DailyMissionConfig.m_Missions[missionID]
    local targetNum = 0
    local targetMoneyNum = 0
    if Mission.isCoinCoef then
        targetNum = Mission.count[nCurTaskIndex] * DailyMissionHandler.data.m_OneDollarCoins
        targetMoneyNum = targetNum
    else
        targetNum = Mission.count[nCurTaskIndex] 
    end

    if missionID == 6 then
        targetNum = 5
    end

    local strBtnInfo = "Spin!"
    if DailyMissionHandler:orTaskFinish() then
        strBtnInfo = "Claim!"
        LeanTween.delayedCall(self.transform.gameObject, 0.5, function()
            self.m_aniDailyTaskBtn:SetInteger("nPlayMode", 1)
            if self.TaskCompleted.activeSelf then
                self.aniTaskCompleted:Play("TaskCompleted", -1, 0)
            else
                self.TaskCompleted:SetActive(true)
            end
        end)
    else
        self.m_aniDailyTaskBtn:SetInteger("nPlayMode", 0)
        if missionID == 8 then
            if DailyMissionHandler.data.m_MissionPlayerData[nCurTaskIndex].spinTimes == nil then
                DailyMissionHandler.data.m_MissionPlayerData[nCurTaskIndex].spinTimes = 0
                DailyMissionHandler:SaveDb()
            end
                
            local num = 100 - DailyMissionHandler.data.m_MissionPlayerData[nCurTaskIndex].spinTimes
            strBtnInfo = tostring(num)
        end
    end

    self.m_textMeshProSpinClaimCountDown.text = strBtnInfo
    local count = DailyMissionHandler.data.m_MissionPlayerData[nCurTaskIndex].count
    local fCurMissionPercent = count / targetNum
    LuaHelper.Clamp(fCurMissionPercent, 0, 1)
    LeanTween.value(self.transform.gameObject, self.m_fPreMissionPercent, fCurMissionPercent, 0.5):setOnUpdate(function(value)
        local fAngle = -360 * value
        self.m_rectTrProgressLightEffectTask.eulerAngles = Unity.Vector3(0, 0, fAngle)
        self.m_imageMissionProgress.fillAmount = value
    end):setOnComplete(function()
        self.m_fPreMissionPercent = fCurMissionPercent
    end)
    
    if self.m_nCurPageType == EnumPageType.EnumDailyTaskType then
        if Mission.isCoinCoef then
            self.textTaskDes.text = string.format(Mission.descriptionFormat, MoneyFormatHelper.coinCountOmit(targetMoneyNum))
        else
            self.textTaskDes.text = string.format(Mission.descriptionFormat, targetNum)
        end
    end

end

function MissionLevelEntry:updateButtonStatus()
    if self.m_nCurPageType == EnumPageType.EnumDailyTaskType then
        if not DailyMissionHandler:orTaskFinish() and FlashChallengeHandler:orUnLock() and FlashChallengeHandler:IsFlashChallengeTheme() then
            self.m_nCurPageType = EnumPageType.EnumFlashChallengeType
            self.m_aniMissionBtn:Play("fanzhuanAB", -1, 0)
            LeanTween.delayedCall(self.transform.gameObject, 1.0, function()
                self.m_aniMissionBtn:Play("fanzhuanB", -1, 0)
                if FlashChallengeHandler:orTaskFinish() then
                    self.m_aniChallengeBtn:SetInteger("nPlayMode", 1)
                else
                    self.m_aniChallengeBtn:SetInteger("nPlayMode", 0)
                end
            end)
        end
    else
        if not FlashChallengeHandler:orTaskFinish() and DailyMissionHandler:orUnLock() and not DailyMissionHandler:orTodayAllTaskFinish() then
            self.m_nCurPageType = EnumPageType.EnumDailyTaskType
            self.m_aniMissionBtn:Play("fanzhuanBA", -1, 0)
            LeanTween.delayedCall(self.transform.gameObject, 1.0, function()
                self.m_aniMissionBtn:Play("fanzhuanA", -1, 0)
                if DailyMissionHandler:orTaskFinish() then
                    self.m_aniDailyTaskBtn:SetInteger("nPlayMode", 1)
                else
                    self.m_aniDailyTaskBtn:SetInteger("nPlayMode", 0)
                end
            end)
        end
    end
end

function MissionLevelEntry:updateTimeLeft()
    if DailyMissionHandler:orTodayAllTaskFinish() then
        local nowSecond = TimeHandler:GetServerTimeStamp()
        local timediff = DailyMissionHandler:GetActivityEndTimeSeconds() - nowSecond

        if timediff < 0 then
            timediff = 0
        end

        local days = timediff // (3600*24)
        local hours = timediff // 3600 - 24 * days
        local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
        local seconds = timediff % 60

        if days > 0 then
            local strTimeInfo1 = string.format("%d DAYS LEFT!", days)
            self.m_textMeshProSpinClaimCountDown.text = strTimeInfo1
        else
            local strTimeInfo2 = string.format("%02d:%02d:%02d", hours, minutes, seconds)
            self.m_textMeshProSpinClaimCountDown.text = strTimeInfo2
        end
    end

    self:RefreshChallengeUIParam()
    self:RefreshDailyTaskUIParam()
end
