LoungePassCardUI = {}
LoungePassCardUI.m_bInitFlag = false
LoungePassCardUI.m_nDayPass = 0

function LoungePassCardUI:Show(nDayPass)
    self.m_nDayPass = nDayPass

    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadGoldenLoungeAsset("LoungeDayPassUI/LoungePassCardUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        local btnCollect = self.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnCollect)
        btnCollect.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnBtnCollectClicked(btnCollect)
        end)
        
        local tr = self.transform:FindDeepChild("TextNumDayPass")
        self.m_TextNumDayPass = tr:GetComponent(typeof(UnityUI.Text))

        local tr = self.transform:FindDeepChild("TextMeshProInfo")
        self.m_TextMeshProInfo = tr:GetComponent(typeof(TextMeshProUGUI))
    end

    ViewAlphaAni:Show(self.transform.gameObject)
    self.m_TextNumDayPass.text = tostring(nDayPass)
    local strInfo = nDayPass .. " DAY LoungePass Card"
    if nDayPass > 1 then
        strInfo = nDayPass .. " DAYS LoungePass Card"
    end
    self.m_TextMeshProInfo.text = strInfo
    self.transform:SetAsLastSibling() -- SetAsFirstSibling -- SetSiblingIndex(0)
end

function LoungePassCardUI:Hide(normalHide)
    ViewAlphaAni:Hide(self.transform.gameObject)
end

function LoungePassCardUI:OnBtnCollectClicked(btnCollect)
    btnCollect.interactable = false
    LeanTween.delayedCall(1.0, function()
        btnCollect.interactable = true
    end)
    
    self:Hide()
    LoungeSpecialLevelBoosterUI:Show()
    EventHandler:Brocast("OnLoungeActivityStateChanged")
end