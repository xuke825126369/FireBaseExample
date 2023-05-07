RoyalPassMissionChestUI = {}

function RoyalPassMissionChestUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/RoyalPass/PopPrefab/RoyalPassMissionChestUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(MissionMainUIPop.m_trPopNode, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trContent = self.transform:FindDeepChild("Content")
        self.m_goUnlockBlackBg = self.transform:FindDeepChild("JinBiKuangBlack").gameObject
        self.m_golockInfo = self.transform:FindDeepChild("TextNodeLan").gameObject
        self.m_goUnlockInfo = self.transform:FindDeepChild("TextNodeLan2").gameObject
        self.m_textReward = self.transform:FindDeepChild("MissionChestRewardText"):GetComponent(typeof(UnityUI.Text))
        local btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnClose)
        btnClose.onClick:AddListener(function()
            self:Hide()
        end)
    end 
    
    self.m_goUnlockBlackBg:SetActive( not RoyalPassDbHandler.data.m_bIsPurchase )
    self.m_golockInfo:SetActive(not RoyalPassDbHandler.data.m_bIsPurchase)
    self.m_goUnlockInfo:SetActive( RoyalPassDbHandler.data.m_bIsPurchase )
    local nCoins = RoyalPassHandler:GetLastChestLevelRewards()
    self.m_textReward.text = MoneyFormatHelper.numWithCommas(nCoins).." COINS"
    ViewScaleAni:Show(self.transform.gameObject)
    GlobalAudioHandler:PlaySound("popup")

end

function RoyalPassMissionChestUI:Hide()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end