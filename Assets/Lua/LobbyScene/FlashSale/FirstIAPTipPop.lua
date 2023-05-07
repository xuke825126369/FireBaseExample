FirstIAPTipPop = PopStackViewBase:New()

function FirstIAPTipPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local go = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby", "FirstIAP/FirstIAPTipPop.prefab"))
        self.transform = go.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

        local closeBtn1 = self.transform:FindDeepChild("CloseButton1"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(closeBtn1)
        closeBtn1.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        local closeBtn2 = self.transform:FindDeepChild("CloseButton2"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(closeBtn2)
        closeBtn2.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)

        local goStoreBtn1 = self.transform:FindDeepChild("GoStoreButton1"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(goStoreBtn1)
        goStoreBtn1.onClick:AddListener(function()
            self:onGoStoreBtnClicked()
        end)
        local goStoreBtn2 = self.transform:FindDeepChild("GoStoreButton2"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(goStoreBtn2)
        goStoreBtn2.onClick:AddListener(function()
            self:onGoStoreBtnClicked()
        end)
    end
    
    ViewScaleAni:Show(self.transform.gameObject)
end

function FirstIAPTipPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function FirstIAPTipPop:onGoStoreBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
	BuyView:Show()
end