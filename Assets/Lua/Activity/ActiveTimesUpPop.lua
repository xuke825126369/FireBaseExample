ActiveTimesUpPop = {}

function ActiveTimesUpPop:Init()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "ActivityCommon"
        local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "Assets/ResourceABs/ActivityCommon/ActiveTimesUpPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.btnClose = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnClose)
        self.btnClose.onClick:AddListener(function()
            self.btnClose.interactable = false
            ViewScaleAni:Hide(self.transform.gameObject)
            SlotsGameLua.m_bReelPauseFlag = false
            GlobalAudioHandler:StopActiveMusic()
        end)
    end

end

function ActiveTimesUpPop:Show(activeType)
    self:Init()
    self.btnClose.interactable = true
    ViewScaleAni:Show(self.transform.gameObject)
        
    local trLogo = self.transform:FindDeepChild("Logo")
    for i = 0, trLogo.childCount - 1 do
        local go = trLogo:GetChild(i).gameObject
        go:SetActive(go.name == activeType)
    end
end 