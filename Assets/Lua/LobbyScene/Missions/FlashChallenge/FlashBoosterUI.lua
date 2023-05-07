FlashBoosterUI = {}
FlashBoosterUI.m_ConfigParam = {productId = AllBuyCFG[1].productId, boosterTime = 10*60}

function FlashBoosterUI:Show(parent)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/FlashChallenge/FlashBooster.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(parent, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        
        self.TextDollarPrice = self.transform:FindDeepChild("TextDollarPrice"):GetComponent(typeof(TextMeshProUGUI))
        self.TextCoinValue = self.transform:FindDeepChild("TextCoinValue"):GetComponent(typeof(UnityUI.Text))
        self.TextMeshProBoosterTime = self.transform:FindDeepChild("TextMeshProBoosterTime"):GetComponent(typeof(TextMeshProUGUI))
        self.TextMeshProCountDown = self.transform:FindDeepChild("TextMeshProCountDown"):GetComponent(typeof(TextMeshProUGUI))

        self.FullLoading = self.transform:FindDeepChild("FullLoading").gameObject

        local BtnBuy = self.transform:FindDeepChild("BtnBuy"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(BtnBuy)
        BtnBuy.onClick:AddListener(function()
            self:OnBuy()
        end)

        local BtnPurchaseBenefits = self.transform:FindDeepChild("BtnPurchaseBenefits"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(BtnPurchaseBenefits)
        BtnPurchaseBenefits.onClick:AddListener(function()
            self:OnPurchaseBenefits()
        end)

        local BtnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(BtnClose)
        BtnClose.onClick:AddListener(function()
            self:OnClose()
        end)

        self.animator = self.transform:GetComponentInChildren(typeof(Unity.Animator))
        self:updateTimeLeft()
    end

    self.transform.gameObject:SetActive(true)
    GlobalAudioHandler:PlaySound("popup")

    self:initUI()
    EventHandler:AddListener("onPurchaseDoneNotifycation", self)
    EventHandler:AddListener("onPurchaseFailedNotifycation", self)
end

function FlashBoosterUI:updateTimeLeft()
    self.co = StartCoroutine(function()
        local waitForSecend = Unity.WaitForSeconds(1)
        while self.transform.gameObject do
            self.TextMeshProCountDown.text = FlashChallengeUI.m_strCountDown
            yield_return(waitForSecend)
        end
        self.co = nil
    end)
end

function FlashBoosterUI:onPurchaseDoneNotifycation(data)
    self:hideLoading()
    self:OnClose()
    FlashChallengeUI:initBoosterUI()
    FlashChallengeUI:UpdateUI()
end

function FlashBoosterUI:onPurchaseFailedNotifycation()
    self:hideLoading()
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function FlashBoosterUI:showLoading()
	self.FullLoading:SetActive(true)
end

function FlashBoosterUI:hideLoading()
	self.FullLoading:SetActive(false)
end

function FlashBoosterUI:initUI()
    local minute = math.floor( self.m_ConfigParam.boosterTime / 60 )
    self.TextMeshProBoosterTime.text = minute
    
    local skuInfo = GameHelper:GetSimpleSkuInfoById(self.m_ConfigParam.productId)
    
    self.TextCoinValue.text = MoneyFormatHelper.coinCountOmit(skuInfo.baseCoins)
    
    self.TextDollarPrice.text = "$" .. skuInfo.nDollar

    self.TextMeshProCountDown.text = FlashChallengeUI.m_strCountDown
    
end

function FlashBoosterUI:OnDestroy()
    
end

function FlashBoosterUI:OnBuy()
    self:showLoading()
    local skuInfo = self:getSkuInfo()
    UnityPurchasingHandler:purchase(skuInfo)
end

function FlashBoosterUI:OnClose()
    GlobalAudioHandler:PlayBtnSound()
    self.animator:Play("FlashBoosterAnituichu", -1, 0) -- 退出动画..

    LeanTween.delayedCall(1.0, function()
        self.transform.gameObject:SetActive(false)
    end)
end

function FlashBoosterUI:OnPurchaseBenefits()
    GlobalAudioHandler:PlayBtnSound()
    local skuInfo = self:getSkuInfo()
    ShowPurchaseBenifitPop:Show(skuInfo)
end

function FlashBoosterUI:getSkuInfo()
    local skuInfo = GameHelper:GetSimpleSkuInfoById(self.m_ConfigParam.productId)

    skuInfo.finalCoins = math.floor( skuInfo.finalCoins / 2 )
    skuInfo.nBoosterTime = self.m_ConfigParam.boosterTime
    skuInfo.nType = SkuInfoType.FlashBooster
    
    return skuInfo
end