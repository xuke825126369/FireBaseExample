UseGemCompleteNowUI = {}

function UseGemCompleteNowUI:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end

    return true
end

function UseGemCompleteNowUI:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end 

    local bundleName = "Lobby"
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "Assets/ResourceABs/Lobby/Missions/UseGemCompleteNowUI.prefab")
    local goPanel = Unity.Object.Instantiate(goPrefab)
    self.transform = goPanel.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.m_animator = self.transform:GetComponent(typeof(Unity.Animator))
    local btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:onClose()
    end)
    
    local tr = self.transform:FindDeepChild("BtnGemBuy")
    self.TextGemValue = tr:FindDeepChild("TextGemValue"):GetComponent(typeof(TextMeshProUGUI))

    self.m_btnBuy = tr:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.m_btnBuy)
    self.m_btnBuy.onClick:AddListener(function()
        GlobalAudioHandler:PlaySound("item_completed")
        self:onBuy()
    end)

end

function UseGemCompleteNowUI:Show(nGemValue, FUNCBUY)
    self:Init()
    
    self.m_nGemValue = nGemValue
    self.TextGemValue.text = tostring(nGemValue)
    self.m_functionBuy = FUNCBUY
    self.transform.gameObject:SetActive(true)
    self.m_btnBuy.interactable = true
end

function UseGemCompleteNowUI:onClose()
    self.m_animator:Play("UseGemCompleteNowUItuichu", -1, 0)
    LeanTween.delayedCall(0.75, function()
        self.transform.gameObject:SetActive(false)
    end)
end

function UseGemCompleteNowUI:onBuy()
    self.m_btnBuy.interactable = false

    self.m_animator:Play("UseGemCompleteNowUItuichu", -1, 0)
    LeanTween.delayedCall(0.75, function()
        self.transform.gameObject:SetActive(false)
    end)

    self.m_functionBuy()
end



