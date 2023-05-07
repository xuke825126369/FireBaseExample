RepeatWinLock = {}

function RepeatWinLock:isActiveShow()
    if self.transform.gameObject == nil then
        return false
    end

    if self.transform.gameObject:Equals(nil) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end
    
    return true
end

function RepeatWinLock:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadAsset("lobby", "BoosterUI/RepeatWin/RepeatWinLock.prefab")
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

        self.m_content = self.transform:FindDeepChild("Content")
        local btnClose = self.transform:FindDeepChild("ButtonClose"):GetComponent( typeof(UnityUI.Button) )
        DelegateCache:addOnClickButton(btnClose)
        btnClose.onClick:AddListener(function()
            self:onBtnCloseClick()
        end)

        local trBtn = self.transform:FindDeepChild("Button")
        local getCoinsBtn = trBtn:GetComponent( typeof(UnityUI.Button) )
        DelegateCache:addOnClickButton(getCoinsBtn)
        getCoinsBtn.onClick:AddListener(function()
            self:onBtnGetCoinsButtonClick()
        end)

        local tr = self.transform:FindDeepChild("TimeLeft")
        self.m_textBoosterCountDownInfo = tr:GetComponent(typeof(TextMeshProUGUI))

        self.mTimeOutGenerator = TimeOutGenerator:New()
    end

    ViewScaleAni:Show(self.transform.gameObject)
end

function RepeatWinLock:onBtnCloseClick()
    GlobalAudioHandler:PlayBtnSound()
    self.popController:Hide()
end

function RepeatWinLock:onBtnGetCoinsButtonClick()
    GlobalAudioHandler:PlayBtnSound()
    self.popController:Hide()
    
    LeanTween.delayedCall(0.5, function()
        if ShopPop:isActiveShow() then
            return
        end
    
        ShopPop:Show()
    end)
end

function RepeatWinLock:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self:RefreshCountDown()
    end
end

function RepeatWinLock:RefreshCountDown()
    local isActiveShow, toTime = BoostHandler:checkIsRepeatWinActive()
    if isActiveShow then
        local now = os.time()
        local nRemainTime = toTime - now
        local strRemainTime = BoostHandler:FormatTime(nRemainTime)
        self.m_textBoosterCountDownInfo.text = strRemainTime
    else 
        if not ViewScaleAni:orInHideAni(self.transform.gameObject) then
            ViewScaleAni:Hide(self.transform.gameObject)
        end
    end
end
