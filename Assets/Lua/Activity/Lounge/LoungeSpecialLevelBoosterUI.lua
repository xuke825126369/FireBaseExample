LoungeSpecialLevelBoosterUI = {}

function LoungeSpecialLevelBoosterUI:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    self.transform = UITop.m_transform:FindDeepChild("LoungeSpecialLevelBoosterUI")
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

    local btnTip = self.transform:FindDeepChild("BtnBoosterTip"):GetComponent( typeof(UnityUI.Button) )
    DelegateCache:addOnClickButton(btnTip)
    btnTip.onClick:RemoveAllListeners()
    btnTip.onClick:AddListener(function()
        self:onBtnTipClick(btnTip)
    end)
    self.btnTip = btnTip

    local tr = self.transform:FindDeepChild("TextBoosterCountDown")
    self.m_textBoosterCountDownInfo = tr:GetComponent(typeof(TextMeshProUGUI))
    self.m_goLoungeSpecialTipNode = self.transform:FindDeepChild("LoungeSpecialTipNode").gameObject
    self.m_goLoungeSpecialTipNode:SetActive(false)
    self.mTimeOutGenerator = TimeOutGenerator:New()
end

function LoungeSpecialLevelBoosterUI:Show()
    if not GameHelper:orInTheme() then
        return
    end

    self:Init()
    if not LoungeHandler:isLoungeMember() then
        self.transform.gameObject:SetActive(false)
        return
    end
    
    if LevelBurstBoosterUI.m_bHasLevelBooster then
        self.transform.gameObject:SetActive(false)
        return
    end

    self.transform.gameObject:SetActive(true)
    self.btnTip.interactable = true
end

function LoungeSpecialLevelBoosterUI:Hide()
    self.transform.gameObject:SetActive(false)
end

function LoungeSpecialLevelBoosterUI:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self:LevelBoosterCountDown()
    end
end

function LoungeSpecialLevelBoosterUI:LevelBoosterCountDown()
    if not LoungeHandler:isLoungeMember() then
        self.transform.gameObject:SetActive(false)
        EventHandler:Brocast("OnLoungeActivityStateChanged")
        LoungeTimeEndUI:Show()
    end

    if LevelBurstBoosterUI and LevelBurstBoosterUI.m_bHasLevelBooster then
        self.transform.gameObject:SetActive(false)
    end
    
    local diffTime = LoungeHandler:getLoungeMemberTime()
    local strCountDown = LoungeConfig:formatDiffTime(diffTime)
    self.m_textBoosterCountDownInfo.text = strCountDown

end

function LoungeSpecialLevelBoosterUI:onBtnTipClick(btnTip)
    GlobalAudioHandler:PlayBtnSound()
    btnTip.interactable = false
    self.m_goLoungeSpecialTipNode:SetActive(true)
    LeanTween.delayedCall(4.0, function()
        self.m_goLoungeSpecialTipNode:SetActive(false)
        btnTip.interactable = true
    end)
end
