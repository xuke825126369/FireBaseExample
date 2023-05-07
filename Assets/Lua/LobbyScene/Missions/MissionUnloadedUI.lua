MissionUnloadedUI = {}

function MissionUnloadedUI:Init()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        self.transform = LobbyView.transform:FindDeepChild("DailyTaskBtn")
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(true)
        
        self.goCount = self.transform:FindDeepChild("goCount").gameObject
        self.textCollectCountText = self.transform:FindDeepChild("BottomChallengeProgressText"):GetComponent(typeof(TextMeshProUGUI))

        self.m_entryBtn = self.transform:Find("EntryBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_entryBtn.gameObject:SetActive(true)
        DelegateCache:addOnClickButton(self.m_entryBtn)
        self.m_entryBtn.onClick:AddListener(function()
            self:onMissionClicked()
        end)

        self.mTimeOutGenerator = TimeOutGenerator:New(3)
    end

    self:refreshButtonStatus()
end

function MissionUnloadedUI:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self:refreshButtonStatus()
    end
end

function MissionUnloadedUI:refreshButtonStatus()
    local nAllCount = MissionMainUIPop:GetAllCount()
    self.goCount:SetActive(nAllCount > 0)
    self.textCollectCountText.text = nAllCount
end

function MissionUnloadedUI:onMissionClicked()
    GlobalAudioHandler:PlayBtnSound()
    MissionMainUIPop:Show()
end