local FlashChallengeSeasonEndUI = {}

function FlashChallengeSeasonEndUI:create(parent)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "Lobby"
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/FlashChallenge/FlashChallengeSeasonEnd.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(parent, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_btnDone = self.transform:FindDeepChild("BtnDone"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnDone)
        self.m_btnDone.onClick:AddListener(function()
            self:onDoneClicked()
        end)

        local textInfo = self.transform:FindDeepChild("Level1FireCount"):GetComponent(typeof(TextMeshProUGUI))
        textInfo.text = FlashChallengeRewardConfig.TO_NEXT_SEASON_FIRES[1]
        local textInfo = self.transform:FindDeepChild("Level2FireCount"):GetComponent(typeof(TextMeshProUGUI))
        textInfo.text = FlashChallengeRewardConfig.TO_NEXT_SEASON_FIRES[2]
        local textInfo = self.transform:FindDeepChild("Level3FireCount"):GetComponent(typeof(TextMeshProUGUI))
        textInfo.text = FlashChallengeRewardConfig.TO_NEXT_SEASON_FIRES[3]
        local textInfo = self.transform:FindDeepChild("Level4FireCount"):GetComponent(typeof(TextMeshProUGUI))
        textInfo.text = FlashChallengeRewardConfig.TO_NEXT_SEASON_FIRES[4]
        local textInfo = self.transform:FindDeepChild("Level5FireCount"):GetComponent(typeof(TextMeshProUGUI))
        textInfo.text = FlashChallengeRewardConfig.TO_NEXT_SEASON_FIRES[5]
        local textInfo = self.transform:FindDeepChild("Level6FireCount"):GetComponent(typeof(TextMeshProUGUI))
        textInfo.text = FlashChallengeRewardConfig.TO_NEXT_SEASON_FIRES[6]

        self.m_mapLevel = {}
        for i = 1, 6 do
            local go = self.transform:FindDeepChild("HongLevel"..i).gameObject
            self.m_mapLevel[i] = go
        end
        self.m_textCurrenSeason = self.transform:FindDeepChild("nCurrenSeason"):GetComponent(typeof(TextMeshProUGUI))
    end
    self.transform.gameObject:SetActive(false)
end

function FlashChallengeSeasonEndUI:show(nLastLevel)
    for i = 1, 6 do
        self.m_mapLevel[i]:SetActive(i == nLastLevel)
    end
    
    local nSeasonId = FlashChallengeHandler:GetSeasonId()
    self.m_textCurrenSeason.text = string.format("%d", nSeasonId + 1)
    self.transform.gameObject:SetActive(true)
    GlobalAudioHandler:PlaySound("popup")
end

function FlashChallengeSeasonEndUI:onDoneClicked()
    GlobalAudioHandler:PlayBtnSound()
    self.transform.gameObject:SetActive(false)
    FlashChallengeUI:Show()
    MissionMainUIPop:UpdateCountUI()
end

return FlashChallengeSeasonEndUI