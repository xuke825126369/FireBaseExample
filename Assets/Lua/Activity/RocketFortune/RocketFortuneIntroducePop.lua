RocketFortuneIntroducePop = {}

function RocketFortuneIntroducePop:Show(parentTransform)
    if self.transform.gameObject == nil then
        local strPath = "IntroducePop"
        self.transform.gameObject = Unity.Object.Instantiate(AssetBundleHandler:LoadActivityAsset(strPath))
        self.transform = self.transform.gameObject.transform
        local trOK = self.transform:FindDeepChild("OKBtn")
        local btnOK = trOK:GetComponent(typeof(UnityUI.Button))
        btnOK.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        DelegateCache:addOnClickButton(btnOK)
        local btn = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        DelegateCache:addOnClickButton(btn)
        self.popController = PopController:new(self.transform.gameObject)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    end

    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function RocketFortuneIntroducePop:onCloseBtnClicked()
    --TODO 关闭音效
    self.popController:hide(true)
end

function RocketFortuneIntroducePop:OnDestroy()
    Debug.Log("RocketFortuneIntroducePop Destroy")
end