RocketFortuneGiftRocketsPop = {}

function RocketFortuneGiftRocketsPop:Show(parentTransform)
    if self.transform.gameObject == nil then
        local strPath = "Assets/ActiveNeedLoad/RocketFortune/RocketFortuneGiftRocketsPop.prefab"
        self.transform.gameObject = Unity.Object.Instantiate(Util.getRocketFortunePrefab(strPath))
        self.transform = self.transform.gameObject.transform
        local trKeep = self.transform:FindDeepChild("CollectBtn")
        self.btnKeep = trKeep:GetComponent(typeof(UnityUI.Button))
        self.btnKeep.onClick:AddListener(function()
            self:onKeepBtnClick()
        end)
        DelegateCache:addOnClickButton(self.btnKeep)
        self.popController = PopController:new(self.transform.gameObject)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    end
    self.btnKeep.interactable = true
    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function RocketFortuneGiftRocketsPop:onKeepBtnClick()
    self.btnKeep.interactable = false
    ViewScaleAni:Hide(self.transform.gameObject)
    RocketFortuneLevelManager:beginPlayerFlyToLastOne()
end

function RocketFortuneGiftRocketsPop:OnDestroy()
    
end