local UpdateNewVersionView = {}

function UpdateNewVersionView:Init()
    local bundleName = "InitScene"
	local assetPath = "Assets/ResourceABs/InitScene/View/UpdateNewVersionView.prefab"
    local goPrefab = AssetBundleManager.Instance:LoadAsset(bundleName, assetPath)
    local goPanel = Unity.Object.Instantiate(goPrefab)
    
    local goParent = InitScene.popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
	self.transform.gameObject:SetActive(false)

    self.DownloadBtn = self.transform:FindDeepChild("DownloadBtn"):GetComponent(typeof(UnityUI.Button))
    self.DownloadBtn.onClick:AddListener(function()
        self:OnClickDownloadBtn()
    end)
    DelegateCache:addOnClickButton(self.DownloadBtn)
end

function UpdateNewVersionView:OnClickDownloadBtn()
    Unity.Application.Quit()
    if GameConfig.PLATFORM_ANDROID then
        Unity.Application.OpenURL("market://details?id="..Unity.Application.identifier)
    elseif GameConfig.PLATFORM_IOS then
        Unity.Application.OpenURL("https://itunes.apple.com/app/id1523002041?action=write-review")
    end
end

function UpdateNewVersionView:Show()
    ViewScaleAni:Show(self.transform.gameObject)
end

function UpdateNewVersionView:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

return UpdateNewVersionView