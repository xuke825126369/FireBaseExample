ScreenSwitchView = {}

function ScreenSwitchView:Init()
	local bundleName = "Global"
	local assetPath = "Assets/ResourceABs/Global/View/ScreenSwitchView.prefab"
    local goPrefab = AssetBundleManager.Instance:LoadAsset(bundleName, assetPath)
    local go = Unity.Object.Instantiate(goPrefab)

    local goParent = GlobalScene.popCanvas
    self.transform = go.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)
end

function ScreenSwitchView:Show(textMessage)
	self.transform:SetAsLastSibling()
	self.transform.gameObject:SetActive(true)
end

function ScreenSwitchView:Hide()
	self.transform.gameObject:SetActive(false)
end

return ScreenSwitchView
















