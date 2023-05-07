

UpdateTipPop = {}

function UpdateTipPop:createAndShow(themeKey)
    if(not self.gameObject) then
        self.tableName = "UpdateTipPop"
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/Prefabs/UpdateTipPop.prefab"))
        self.transform = self.gameObject.transform
        self.popController = PopController:new(self.gameObject)
        local btn = self.transform:FindDeepChild("CloseButton"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn) 
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        self.btnUpdate = self.transform:FindDeepChild("UpdateBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnUpdate) 
        self.btnUpdate.onClick:AddListener(function()
            self:onUpdateBtnClicked()
        end)
    end
    self.themeKey = themeKey
    self.btnUpdate.interactable = true
    self.transform:SetParent(LobbyScene.popCanvas, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function UpdateTipPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function UpdateTipPop:onUpdateBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    if GameConfig.PLATFORM_IOS then
        Unity.Application.OpenURL("https://itunes.apple.com/app/id1523002041")
    elseif GameConfig.PLATFORM_ANDROID then
        Unity.Application.OpenURL("market://details?id="..Unity.Application.identifier)
    end
end

