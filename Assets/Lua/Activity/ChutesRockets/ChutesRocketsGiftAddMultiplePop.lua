

ChutesRocketsGiftAddMultiplePop = {}
ChutesRocketsGiftAddMultiplePop.m_btnKeep = nil
ChutesRocketsGiftAddMultiplePop.m_rewardText = nil

function ChutesRocketsGiftAddMultiplePop:Show(parentTransform)
    if self.transform.gameObject == nil then
        local strPath = "Assets/ActiveNeedLoad/ChutesRockets/ChutesRocketsGiftAddMultiplePop.prefab"
        local prefabObj = Util.getChutesRocketsPrefab(strPath)
        self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
        self.transform = self.transform.gameObject.transform
        local trKeep = self.transform:FindDeepChild("CollectBtn")
        local btnKeep = trKeep:GetComponent(typeof(UnityUI.Button))
        btnKeep.onClick:AddListener(function()
            self:onKeepBtnClick()
        end)
        DelegateCache:addOnClickButton(btnKeep)
        self.m_btnKeep = btnKeep
        self.popController = PopController:new(self.transform.gameObject)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    end

    self.m_btnKeep.interactable = true

    self.m_rewardText = self.transform:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
    local mul = math.ceil(GiftConfig[ChutesRocketsLevelManager.strGift].gift * 100)
    self.m_rewardText.text = string.format("%d", mul).." % BIGGER"
    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function ChutesRocketsGiftAddMultiplePop:onKeepBtnClick()
    self.m_btnKeep.interactable = false
    
    ViewScaleAni:Hide(self.transform.gameObject)
    ChutesRocketsMainUIPop:showWheel()
end

function ChutesRocketsGiftAddMultiplePop:OnDestroy()
    
end