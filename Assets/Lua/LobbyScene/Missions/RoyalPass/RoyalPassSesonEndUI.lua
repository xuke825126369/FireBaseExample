RoyalPassSesonEndUI = {}

function RoyalPassSesonEndUI:Show()
    if not RoyalPassHandler.m_bChangeToNextSeason then
        return
    end
    RoyalPassHandler.m_bChangeToNextSeason = false

    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "Lobby"
        local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "Assets/ResourceABs/Lobby/Missions/RoyalPass/PopPrefab/SeasonEndUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(MissionMainUIPop.m_trPopNode, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trContent = self.transform:FindDeepChild("Content")
        self.m_btnCollect = self.transform:FindDeepChild("BtnWow"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCollect)
        self.m_btnCollect.onClick:AddListener(function()
            self:onCollectClicked()
        end)
        self.m_textSeason = self.transform:FindDeepChild("SeasonText"):GetComponent(typeof(UnityUI.Text))
    end
    
    self.m_textSeason.text = string.format("%d", RoyalPassDbHandler.data.m_nSeason)

    self.m_btnCollect.interactable = false
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self.m_btnCollect.interactable = true
    end)

    if UseGemCompleteNowUI:isActiveShow() then
        UseGemCompleteNowUI:onClose()
    end
    
end

function RoyalPassSesonEndUI:Hide()
    ViewScaleAni:Hide(self.transform.gameObject, false)
end

function RoyalPassSesonEndUI:onCollectClicked()
    self.m_btnCollect.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    self:Hide()
end