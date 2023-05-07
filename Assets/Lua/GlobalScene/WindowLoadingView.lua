WindowLoadingView = {}

function WindowLoadingView:Init()
	local bundleName = "Global"
	local assetPath = "Assets/ResourceABs/Global/View/WindowLoadingPanel.prefab"
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
    local go = Unity.Object.Instantiate(goPrefab)

    local goParent = GlobalScene.LoadingCanvas
    self.transform = go.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
        
    self.transform.gameObject:SetActive(false)
end

function WindowLoadingView:Show()
    self.transform.gameObject:SetActive(true)
end

function WindowLoadingView:Hide()
    self.transform.gameObject:SetActive(false)
end
