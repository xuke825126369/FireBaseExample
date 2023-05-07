RoyalPassUnlockRoyalUI = PopStackViewBase:New()

function RoyalPassUnlockRoyalUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "Lobby"
        local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "Assets/ResourceABs/Lobby/Missions/RoyalPass/PopPrefab/UnlockRoyalPassUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(MissionMainUIPop.m_trPopNode, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trContent = self.transform:FindDeepChild("Content")
        self.m_btnCollect = self.transform:FindDeepChild("BtnYeah"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCollect)
        self.m_btnCollect.onClick:AddListener(function()
            self:onCollectClicked()
        end)
    end
    
    if not ScreenHelper:isLandScape() then
        self.m_trContent.localScale = Unity.Vector3.one * 0.65
    else
        self.m_trContent.localScale = Unity.Vector3.one
    end

    GlobalAudioHandler:PlaySound("popup")
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self.m_btnCollect.interactable = true
    end)
end

function RoyalPassUnlockRoyalUI:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function RoyalPassUnlockRoyalUI:onCollectClicked()
    self.m_btnCollect.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    self:Hide()
end