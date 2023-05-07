NetConnectView = {}

function NetConnectView:Init()
    local goPrefab = AssetBundleHandler:LoadAsset("Global", "Assets/ResourceABs/Global/View/NetConnectView.prefab")
    local go = Unity.Object.Instantiate(goPrefab)

    local goParent = GlobalScene.LoadingCanvas
    self.transform = go.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.backBtn = self.transform:FindDeepChild("ReturnBtn"):GetComponent(typeof(UnityUI.Button))
    self.backBtn.onClick:AddListener(function()
        self:OnClick_BackBtn()
    end)

end

function NetConnectView:OnClick_BackBtn()
    self:Hide()
    if self.quitEvent then
        self.quitEvent()
    end
end

function NetConnectView:Show(quitEvent)
    self.transform.gameObject:SetActive(true)
    self.quitEvent = quitEvent
end

function NetConnectView:Hide()
    self.transform.gameObject:SetActive(false)
end

