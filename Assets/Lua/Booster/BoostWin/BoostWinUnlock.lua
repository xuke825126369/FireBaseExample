BoostWinUnlock = {}

function BoostWinUnlock:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end

    return true
end

function BoostWinUnlock:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadAsset("lobby", "BoosterUI/BoostWin/BoostWinUnlock.prefab")
        if goPrefab == nil then
            Debug.LogWithColor("BoostWinLock.prefab 不存在")
            return
        end

        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform:GetComponent(typeof(Unity.RectTransform))
        self.transform:SetParent(BoosterEntry.transform, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        local btnClose = self.transform:FindDeepChild("ButtonClose"):GetComponent( typeof(UnityUI.Button) )
        DelegateCache:addOnClickButton(btnClose)
        btnClose.onClick:AddListener(function()
            self:onBtnCloseClick()
        end)

        local tr = self.transform:FindDeepChild("TimeLeft")
        self.m_textBoosterCountDownInfo = tr:GetComponent(typeof(TextMeshProUGUI))
        self.m_TextBonus = self.transform:FindDeepChild("CoinNumber"):GetComponent(typeof(TextMeshProUGUI))
        self.m_TextPercentCoef = self.transform:FindDeepChild("fCoefText"):GetComponent(typeof(TextMeshProUGUI))

        self.mTimeOutGenerator = TimeOutGenerator:New()
    end

    self:refreshBonus()
    ViewScaleAni:Show(self.transform.gameObject)
    
end

function BoostWinUnlock:refreshBonus()
    self.m_TextPercentCoef.text = (BoostWinEntry.m_fBoostWinCoef * 100).. "%"
    local nBonus = BoostWinEntry.m_boosterParam.nBonus
    local strBonus = LuaUtil.numWithCommas(nBonus)
    self.m_TextBonus.text = strBonus
end

function BoostWinUnlock:onBtnCloseClick()
    GlobalAudioHandler:PlayBtnSound()
    self.popController:Hide()
end

function BoostWinUnlock:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self:RefreshCountDown()
    end
end

function BoostWinUnlock:RefreshCountDown()
    if BoostHandler.m_nBoostWinRemainTime > 0 then
        local nRemainTime = BoostHandler.m_nBoostWinRemainTime
        local strRemainTime = BoostHandler:FormatTime(nRemainTime)
        self.m_textBoosterCountDownInfo.text = strRemainTime
    else
        if not ViewScaleAni:orInHideAni(self.transform.gameObject) then
            ViewScaleAni:Hide(self.transform.gameObject)
        end
    end
end
