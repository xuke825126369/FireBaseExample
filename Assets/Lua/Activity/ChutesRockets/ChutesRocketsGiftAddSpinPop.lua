

ChutesRocketsGiftAddSpinPop = {}

function ChutesRocketsGiftAddSpinPop:Show(parentTransform)
    if self.transform.gameObject == nil then
        local strPath = "Assets/ActiveNeedLoad/ChutesRockets/ChutesRocketsGiftAddSpinPop.prefab"
        local prefabObj = Util.getChutesRocketsPrefab(strPath)
        self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
        self.transform = self.transform.gameObject.transform
        local trKeep = self.transform:FindDeepChild("CollectBtn")
        local btnKeep = trKeep:GetComponent(typeof(UnityUI.Button))
        btnKeep.onClick:AddListener(function()
            self:onKeepBtnClick()
        end)
        DelegateCache:addOnClickButton(btnKeep)
        self.popController = PopController:new(self.transform.gameObject)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    end

    local rewardText = self.transform:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
    rewardText.text = "+ "..GiftConfig[ChutesRocketsLevelManager.strGift].gift
    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function ChutesRocketsGiftAddSpinPop:onKeepBtnClick()
    ViewScaleAni:Hide(self.transform.gameObject)
    ChutesRocketsMainUIPop:showWheel()
end

function ChutesRocketsGiftAddSpinPop:OnDestroy()
    
end