RepeatWinUnlock = {}
RepeatWinUnlock.m_textBoosterCountDownInfo = nil
RepeatWinUnlock.m_TextBonus = nil
RepeatWinUnlock.m_TextPrizeLimit = nil
RepeatWinUnlock.m_TipCollectPrize = nil -- TipCollectPrize

function RepeatWinUnlock:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end
    
    return true
end

function RepeatWinUnlock:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadAsset("lobby", "BoosterUI/RepeatWin/RepeatWinUnlock.prefab")
        if prefabObj == nil then
            return
        end

        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform:GetComponent(typeof(Unity.RectTransform))
        self.transform:SetParent(LobbyScene.popCanvas, false)
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

        local tr = self.transform:FindDeepChild("nTotalWinCoins")
        self.m_TextBonus = tr:GetComponent(typeof(TextMeshProUGUI))

        local tr = self.transform:FindDeepChild("nPrizeLimit")
        self.m_TextPrizeLimit = tr:GetComponent(typeof(TextMeshProUGUI))

        local tr = self.transform:FindDeepChild("InformationText3")
        self.m_TipCollectPrize = tr:GetComponent(typeof(TextMeshProUGUI))
        
        self.m_TipCollectPrize.enableAutoSizing = true
        self.m_TipCollectPrize.fontSizeMin = 18
        self.m_TipCollectPrize.fontSizeMax = 72

        self.mTimeOutGenerator = TimeOutGenerator:New()
    end

    self:refreshBonus()
    ViewScaleAni:Show(self.transform.gameObject)

    local nRemainTime = BoostHandler.m_nRepeatWinRemainTime
    local strTip = "COLLECT YOUR PRIZE IN INBOX AFTER PROMOTION END"
    if nRemainTime > BoostHandler.OneDay then
        strTip = "COLLECT YOUR PRIZE IN INBOX ON THE FOLLOWING DAY"
    end

    self.m_TipCollectPrize.text = strTip
end

function RepeatWinUnlock:refreshBonus()
    local nBonus = RepeatWinEntry.m_boosterParam.nBonus
    local strBonus = LuaUtil.numWithCommas(nBonus)
    self.m_TextBonus.text = strBonus

    local listTotalBet = GameLevelUtil:getTotalBetList()
    local cnt = #listTotalBet
    local nMaxBonus = listTotalBet[cnt] * 100
    local strMaxBonus = LuaUtil.numWithCommas(nMaxBonus)
    self.m_TextPrizeLimit.text = strMaxBonus
end

function RepeatWinUnlock:onBtnCloseClick()
    GlobalAudioHandler:PlayBtnSound()
    self.popController:Hide()
end

function RepeatWinUnlock:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self:RefreshCountDown()
    end
end

function RepeatWinUnlock:RefreshCountDown()
    if BoostHandler.m_nRepeatWinRemainTime > 0 then
        local nRemainTime = BoostHandler.m_nRepeatWinRemainTime
        local strRemainTime = BoostHandler:FormatTime(nRemainTime)
        self.m_textBoosterCountDownInfo.text = strRemainTime
    else
        if not ViewScaleAni:orInHideAni(self.transform.gameObject) then
            ViewScaleAni:Hide(self.transform.gameObject)
        end
    end
end
