RoyalPassLevelUpUI = PopStackViewBase:New()

function RoyalPassLevelUpUI:Show(bHasPrize)
    if RoyalPassHandler.m_nLevel >= 100 then
        RoyalPassTopLevelUI:Show()
        return
    end
    
    if not bHasPrize then
        MissionMainUIPop:ShowLevelUpTip()
        return
    end

    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/RoyalPass/PopPrefab/RoyalPassLevelUpUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(MissionMainUIPop.m_trPopNode, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_textLevel = self.transform:FindDeepChild("TextLevel"):GetComponent(typeof(UnityUI.Text))
        self.m_btnCollect = self.transform:FindDeepChild("BtnLater"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCollect)
        self.m_btnCollect.onClick:AddListener(function()
            self:onCollectClicked(self.m_btnCollect)
        end)

        self.m_btnCheckReward = self.transform:FindDeepChild("BtnCheckReward"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCheckReward)
        self.m_btnCheckReward.onClick:AddListener(function()
            self:onCheckRewardClicked(self.m_btnCollectAll)
        end)
    end

    self.m_textLevel.text = RoyalPassHandler.m_nLevel
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self.m_btnCollect.interactable = true
        self.m_btnCheckReward.interactable = true
    end)

end

function RoyalPassLevelUpUI:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function RoyalPassLevelUpUI:onCollectClicked()
    self.m_btnCollect.interactable = false
    self.m_btnCheckReward.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    self:Hide()
end

function RoyalPassLevelUpUI:onCheckRewardClicked()
    self.m_btnCheckReward.interactable = false
    self.m_btnCollect.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    self:Hide()
    MissionMainUIPop:ShowRoyalPassUI()
end