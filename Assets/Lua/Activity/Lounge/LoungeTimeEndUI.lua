LoungeTimeEndUI = {}

function LoungeTimeEndUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadGoldenLoungeAsset("LoungeUI/LoungeTimeEndUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        
        local btnCheckBenefits = self.transform:FindDeepChild("BtnCheckBenefits"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnCheckBenefits)
        btnCheckBenefits.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnBtnCheckBenefitsClicked(btnCheckBenefits)
        end)
    end

    ViewAlphaAni:Show(self.transform.gameObject)
    self.transform:SetAsLastSibling()
end

function LoungeTimeEndUI:Hide()
    ViewAlphaAni:Hide(self.transform.gameObject)
end

function LoungeTimeEndUI:OnBtnCheckBenefitsClicked(btnCheckBenefits)
    btnCheckBenefits.interactable = false
    LeanTween.delayedCall(1.0, function()
        btnCheckBenefits.interactable = true
    end)

    if ThemeLoader.themeKey == nil then
        LoungeHallUI:Show()
    end
        
    self:Hide()
end