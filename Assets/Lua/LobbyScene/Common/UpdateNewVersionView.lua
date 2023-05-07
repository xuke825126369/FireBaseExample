UpdateNewVersionView = PopStackViewBase:New()

function UpdateNewVersionView:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end
    
    local bundleName = "Lobby"
	local assetPath = "Assets/ResourceABs/Lobby/View/UpdateNewVersionView.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local goPanel = Unity.Object.Instantiate(goPrefab)

    local goParent = LobbyScene.popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
	self.transform.gameObject:SetActive(false)

    self.DownloadBtn = self.transform:FindDeepChild("DownloadBtn"):GetComponent(typeof(UnityUI.Button))
    self.DownloadBtn.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:OnClickDownloadBtn()
    end)    

    self.CloseButton = self.transform:FindDeepChild("CloseButton"):GetComponent(typeof(UnityUI.Button))
    self.CloseButton.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:Hide()
    end)
    
end 

function UpdateNewVersionView:OnClickDownloadBtn()
    self:Hide()
    
    if GameConfig.PLATFORM_ANDROID then
        Unity.Application.OpenURL("market://details?id="..Unity.Application.identifier)
    elseif GameConfig.PLATFORM_IOS then
        Unity.Application.OpenURL("https://itunes.apple.com/app/id1523002041?action=write-review")
    end

end

function UpdateNewVersionView:Show()
    self:Init()
    ViewScaleAni:Show(self.transform.gameObject)
end

function UpdateNewVersionView:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end