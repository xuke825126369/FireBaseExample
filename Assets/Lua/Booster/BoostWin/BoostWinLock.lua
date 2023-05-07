BoostWinLock = {}
function BoostWinLock:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end

    return true
end

function BoostWinLock:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadAsset("lobby", "BoosterUI/BoostWin/BoostWinLock.prefab")
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
        self.m_textMaxCoins = self.transform:FindDeepChild("Number"):GetComponent(typeof(TextMeshProUGUI))
        local max = BonusUtil.getShopSkuInfo("com.slots.goldfever.coins100").finalCoins
        self.m_textMaxCoins.text = " " .. LuaUtil.numWithCommas(max)

        self.m_textMaxCoins.enableAutoSizing = true
        self.m_textMaxCoins.fontSizeMin = 9
        self.m_textMaxCoins.fontSizeMax = 72

        self.mTimeOutGenerator = TimeOutGenerator:New()
    end

    ViewScaleAni:Show()
end

function BoostWinLock:onBtnCloseClick()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function BoostWinLock:onBtnGetCoinsButtonClick()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)

    LeanTween.delayedCall(0.5, function()
        if ShopPop:isActiveShow() then
            return
        end
        ShopPop:Show(nil, true)
    end)
    
end

function BoostWinLock:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self:RefreshCountDown()
    end
end

function BoostWinLock:RefreshCountDown()
    local isActiveShow, toTime = BoostHandler:checkIsBoostWinActive()
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
