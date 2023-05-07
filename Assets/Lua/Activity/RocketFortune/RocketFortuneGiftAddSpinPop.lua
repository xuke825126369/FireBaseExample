RocketFortuneGiftAddSpinPop = {}

function RocketFortuneGiftAddSpinPop:Show(parentTransform)
    if self.transform.gameObject == nil then
        local prefabObj = AssetBundleHandler:LoadActivityAsset("GiftAddSpinPop")
        self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
        self.transform = self.transform.gameObject.transform
        local trKeep = self.transform:FindDeepChild("Button")
        local btnKeep = trKeep:GetComponent(typeof(UnityUI.Button))
        btnKeep.onClick:AddListener(function()
            self:onKeepBtnClick()
        end)
        DelegateCache:addOnClickButton(btnKeep)
        self.popController = PopController:new(self.transform.gameObject)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    end

    local rewardText = self.transform:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
    rewardText.text = "+ "..GiftConfig[RocketFortuneLevelManager.strGift].gift
    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function RocketFortuneGiftAddSpinPop:onKeepBtnClick()
    self.popController:hide(false, function()
        RocketFortuneMainUIPop.Wheel:Show()
    end)
end

function RocketFortuneGiftAddSpinPop:OnDestroy()
    
end