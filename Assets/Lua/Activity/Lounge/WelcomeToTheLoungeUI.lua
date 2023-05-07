WelcomeToTheLoungeUI = PopStackViewBase:New()
function WelcomeToTheLoungeUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local strPath = "LoungeUI/WelcomeToTheLoungeUI.prefab"
        local prefabObj = AssetBundleHandler:LoadGoldenLoungeAsset(strPath)
        local go = Unity.Object.Instantiate(prefabObj)
        self.transform = go.transform
        self.transform:SetParent(GlobalScene.popCanvas, false)

        self.btnCheckBenefits = self.transform:FindDeepChild("BtnCheckBenefits"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnCheckBenefits)
        self.btnCheckBenefits.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnBtnCheckBenefitsClicked()
        end)
    end
    
    ViewScaleAni:Show(self.transform.gameObject)
    self.transform:SetAsLastSibling()
    self.btnCheckBenefits.interactable = true
end

function WelcomeToTheLoungeUI:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function WelcomeToTheLoungeUI:OnBtnCheckBenefitsClicked()
    self.btnCheckBenefits.interactable = false
    self:Hide()
end