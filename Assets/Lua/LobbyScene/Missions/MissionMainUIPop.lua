require("Lua.LobbyScene.Missions.DailyMission.DailyMissionUI")
require("Lua.LobbyScene.Missions.FlashChallenge.FlashChallengeUI")
require("Lua.LobbyScene.Missions.LuckyEgg.LuckyEggMainUI")
require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassMainUI")

MissionMainUIPop = {}
MissionMainUIPop.nShowLevelUpTipId = nil

function MissionMainUIPop:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local bundleName = "Lobby"
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "Assets/ResourceABs/Lobby/Missions/MissionsHallUI.prefab")
    local goPanel = Unity.Object.Instantiate(goPrefab)
    self.transform = goPanel.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.m_trContent = self.transform:FindDeepChild("Content")
    self.m_trParentNode = self.transform:FindDeepChild("ParentNode")
    self.m_trPopNode = self.transform:FindDeepChild("PopParentNode")

    local btnClose = self.transform:FindDeepChild("ButClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:Hide(true)
    end)

    local btnDailyTask = self.transform:FindDeepChild("ButDailyTask"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnDailyTask)
    self.goDailyTaskSelect = btnDailyTask.transform:FindDeepChild("ButDailyTaskHuang").gameObject
    self.goTextMeshProDailyTaskCountTip = btnDailyTask.transform:FindDeepChild("ImageTiShi").gameObject
    self.TextMeshProDailyTaskCountTip = btnDailyTask.transform:FindDeepChild("TextMeshProDailyTaskCountTip"):GetComponent(typeof(TextMeshProUGUI))
    btnDailyTask.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:ShowDailyTaskUI()
    end)

    local btnFlameChallenge = self.transform:FindDeepChild("ButFlameChallenge"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnFlameChallenge)
    self.goFlameChallengeSelect = btnFlameChallenge.transform:FindDeepChild("ButFlameChallengeHuang").gameObject
    self.goFlashChallengeCountTip = btnFlameChallenge.transform:FindDeepChild("ImageTiShi").gameObject
    self.TextMeshProFlameChallengeCountTip = btnFlameChallenge.transform:FindDeepChild("TextMeshProFlameChallengeCountTip"):GetComponent(typeof(TextMeshProUGUI))
    btnFlameChallenge.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:ShowFlameChallengeUI()
    end)

    local btnRoyalPass = self.transform:FindDeepChild("ButRoyalPass"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnRoyalPass)
    self.goRoyalPassSelect = btnRoyalPass.transform:FindDeepChild("ButRoyalPassHuang").gameObject
    self.goRoyalPassCountTip = btnRoyalPass.transform:FindDeepChild("ImageTiShi").gameObject
    self.textRoyalPassCount = btnRoyalPass.transform:FindDeepChild("RoyalPassCountText"):GetComponent(typeof(TextMeshProUGUI))
    btnRoyalPass.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:ShowRoyalPassUI()
    end)

    local btnEggSmash = self.transform:FindDeepChild("ButEggSmash"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnEggSmash)
    self.goEggSmashSelect = btnEggSmash.transform:FindDeepChild("ButEggSmashHuang").gameObject
    self.TextMeshProEggSmashCountTip = btnEggSmash.transform:FindDeepChild("TextMeshProEggSmashCountTip"):GetComponent(typeof(TextMeshProUGUI))
    btnEggSmash.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:ShowEggSmashUI()
    end)

    self.goLevelUpTiShi = self.transform:FindDeepChild("LevelUpTiShi").gameObject
end

function MissionMainUIPop:Show(nShowUIType)
    self:Init()
    if nShowUIType == nil then
        nShowUIType = 1
    end 
    
    self.goLevelUpTiShi:SetActive(false)
    GlobalAudioHandler:PlayBackMusic("bgm")
    ViewAlphaAni:Show(self.transform.gameObject)
    self:UpdateCountUI()

    if nShowUIType == 1 then
        self:ShowDailyTaskUI()
    else
        self:ShowFlameChallengeUI()
    end
end

function MissionMainUIPop:Hide()
    EventHandler:Brocast("onInboxMessageChangedNotifycation")
    GlobalAudioHandler:PlayLobbyBackMusic()
    ViewAlphaAni:Hide(self.transform.gameObject, function()
        if self.nShowLevelUpTipId and LeanTween.isTweening(self.nShowLevelUpTipId) then
            LeanTween.cancel(self.nShowLevelUpTipId)
        end
    end)
end

function MissionMainUIPop:GetAllCount()
    local nSumCount = 0
    local nRoyalCount = RoyalPassHandler:getNumberOfRewardsNotReceived()
    nSumCount = nSumCount + nRoyalCount  
    
    local nCount = FlashChallengeRewardDataHandler:getNumberOfRewardsNotReceived()
    nSumCount = nSumCount + nCount

    local nCount = DailyMissionHandler:getNumberOfRewardsNotReceived()
    nSumCount = nSumCount + nCount

    return nSumCount
end

function MissionMainUIPop:UpdateCountUI()
    local nRoyalCount = RoyalPassHandler:getNumberOfRewardsNotReceived()
    self.goRoyalPassCountTip:SetActive(nRoyalCount > 0)
    local str = nRoyalCount > 99 and "99+" or nRoyalCount
    self.textRoyalPassCount.text = str  

    local nCount = FlashChallengeRewardDataHandler:getNumberOfRewardsNotReceived()
    self.goFlashChallengeCountTip:SetActive(nCount > 0)
    local str = nCount > 99 and "99+" or nCount
    self.TextMeshProFlameChallengeCountTip.text = str

    local nCount = DailyMissionHandler:getNumberOfRewardsNotReceived()
    self.goTextMeshProDailyTaskCountTip:SetActive(nCount > 0)
    self.TextMeshProDailyTaskCountTip.text = tostring(nCount)
end

function MissionMainUIPop:ShowRoyalPassUI()
    if RoyalPassMainUI.transform and RoyalPassMainUI.transform.gameObject.activeSelf then
        return
    end

    RoyalPassMainUI:Show(self.m_trParentNode)
    
    if DailyMissionUI.transform ~= nil then
        DailyMissionUI.transform.gameObject:SetActive(false)
    end

    if FlashChallengeUI.transform ~= nil then
        FlashChallengeUI:Hide()
    end

    if LuckyEggMainUI.transform ~= nil then
        LuckyEggMainUI:Hide()
    end

    self.goDailyTaskSelect:SetActive(false)
    self.goFlameChallengeSelect:SetActive(false)
    self.goRoyalPassSelect:SetActive(true)
    self.goEggSmashSelect:SetActive(false)
end

function MissionMainUIPop:ShowDailyTaskUI()
    DailyMissionUI:Show(self.m_trParentNode)

    if RoyalPassMainUI.transform ~= nil then
        RoyalPassMainUI.transform.gameObject:SetActive(false)
    end
    if FlashChallengeUI.transform ~= nil then
        FlashChallengeUI:Hide()
    end
    if LuckyEggMainUI.transform ~= nil then
        LuckyEggMainUI:Hide()
    end
        
    self.goDailyTaskSelect:SetActive(true)
    self.goFlameChallengeSelect:SetActive(false)
    self.goRoyalPassSelect:SetActive(false)
    self.goEggSmashSelect:SetActive(false)
end

function MissionMainUIPop:ShowFlameChallengeUI()
    FlashChallengeUI:Show(self.m_trParentNode)

    if RoyalPassMainUI.transform ~= nil then
        RoyalPassMainUI.transform.gameObject:SetActive(false)
    end
    if DailyMissionUI.transform ~= nil then
        DailyMissionUI.transform.gameObject:SetActive(false)
    end
    if LuckyEggMainUI.transform ~= nil then
        LuckyEggMainUI:Hide()
    end
    self.goDailyTaskSelect:SetActive(false)
    self.goFlameChallengeSelect:SetActive(true)
    self.goRoyalPassSelect:SetActive(false)
    self.goEggSmashSelect:SetActive(false)
end

function MissionMainUIPop:ShowLevelUpTip()
    if self.nShowLevelUpTipId and LeanTween.isTweening(self.nShowLevelUpTipId) then
        LeanTween.cancel(self.nShowLevelUpTipId)
    end
    self.goLevelUpTiShi:SetActive(true)
    self.nShowLevelUpTipId = LeanTween.delayedCall(3, function()
        self.goLevelUpTiShi:SetActive(false)
    end).id
end

function MissionMainUIPop:ShowEggSmashUI()
    LuckyEggMainUI:Show(self.m_trParentNode)

    if RoyalPassMainUI.transform ~= nil then
        RoyalPassMainUI.transform.gameObject:SetActive(false)
    end
    if DailyMissionUI.transform ~= nil then
        DailyMissionUI.transform.gameObject:SetActive(false)
    end
    if FlashChallengeUI.transform ~= nil then
        FlashChallengeUI:Hide()
    end

    self.goDailyTaskSelect:SetActive(false)
    self.goFlameChallengeSelect:SetActive(false)
    self.goRoyalPassSelect:SetActive(false)
    self.goEggSmashSelect:SetActive(true)
end