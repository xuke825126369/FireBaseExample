CommonLoadingView = {}

function CommonLoadingView:Init()
	local bundleName = "Global"
	local assetPath = "Assets/ResourceABs/Global/View/CommonLoadingView.prefab"
    local goPrefab = AssetBundleManager.Instance:LoadAsset(bundleName, assetPath)
    local go = Unity.Object.Instantiate(goPrefab)

    local goParent = GlobalScene.popCanvas
    self.transform = go.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)
	
	self.textMessage = self.transform:FindDeepChild("InfoText"):GetComponent(typeof(TextMeshProUGUI)) 
end

function CommonLoadingView:Show(textMessage)
	self.transform:SetAsLastSibling()
	self.transform.gameObject:SetActive(true)
	self.textMessage.text = textMessage
end

function CommonLoadingView:Hide()
	self.transform.gameObject:SetActive(false)
end

return CommonLoadingView
















