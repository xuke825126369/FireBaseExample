RocketFortuneSendSpinPop = {}

function RocketFortuneSendSpinPop:Show(count)
    if self.transform.gameObject == nil then
        local strPath = "Assets/ActiveNeedLoad/RocketFortune/RocketFortuneSendSpinPop.prefab"
        local prefabObj = Util.getHotPrefab(strPath)
        self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
        self.transform = self.transform.gameObject.transform
        local trKeep = self.transform:FindDeepChild("CollectBtn")
        local btnKeep = trKeep:GetComponent(typeof(UnityUI.Button))
        btnKeep.onClick:AddListener(function()
            self:onKeepBtnClick()
        end)
        DelegateCache:addOnClickButton(btnKeep)
        self.popController = PopController:new(self.transform.gameObject, PopPriority.middlePriority)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    end

    local rewardText = self.transform:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
    rewardText.text = "+ "..count
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController:show(nil,nil,true)
end

function RocketFortuneSendSpinPop:onKeepBtnClick()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function RocketFortuneSendSpinPop:OnDestroy()
    
end