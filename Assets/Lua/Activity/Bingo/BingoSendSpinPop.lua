

BingoSendSpinPop = {}

function BingoSendSpinPop:Show(count)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadActivityAsset("BingoSendSpinPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        local trKeep = self.transform:FindDeepChild("CollectBtn")
        local btnKeep = trKeep:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnKeep)
        btnKeep.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onKeepBtnClick()
        end)

        self.m_ani = self.transform:GetComponentInChildren(typeof(Unity.Animator))
        local rewardText = self.transform:FindDeepChild("ShuZi"):GetComponent(typeof(UnityUI.Text))
    end 

    rewardText.text = "+ "..count
    self.m_bCanHide = false
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self.m_ani:Play("Show", 0, 0)
        self.m_bCanHide = true
    end)
    
end 

function BingoSendSpinPop:onKeepBtnClick()
    if not self.m_bCanHide then return end
    ViewScaleAni:Hide(self.transform.gameObject)
end