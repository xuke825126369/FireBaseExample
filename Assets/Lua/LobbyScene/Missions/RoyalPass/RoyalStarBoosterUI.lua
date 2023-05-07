RoyalStarBoosterUI = {}

RoyalStarBoosterUI.m_bInitFlag = false
RoyalStarBoosterUI.m_ConfigParam = {productId = AllBuyCFG[1].productId, boosterTime = 10*60}

function RoyalStarBoosterUI:Show(parent)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "Lobby"
        local goPrefab = AssetBundleHandler:LoadAsset(bundleName, "Assets/ResourceABs/Lobby/Missions/RoyalPass/RoyalPassBoosterUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(parent, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trContent = self.transform:FindDeepChild("Content")
        self.TextDollarPrice = self.transform:FindDeepChild("TextDollarPrice"):GetComponent(typeof(TextMeshProUGUI))
        self.TextCoinValue = self.transform:FindDeepChild("TextCoinValue"):GetComponent(typeof(UnityUI.Text))
        self.TextMeshProBoosterTime = self.transform:FindDeepChild("TextMeshProBoosterTime"):GetComponent(typeof(TextMeshProUGUI))
        
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

        self.animator = self.transform:GetComponent(typeof(Unity.Animator))

    end

    if not ScreenHelper:isLandScape() then
        self.m_trContent.localScale = Unity.Vector3.one * 0.65
    else
        self.m_trContent.localScale = Unity.Vector3.one
    end

    self.transform.gameObject:SetActive(true)
    GlobalAudioHandler:PlaySound("popup")
    self:initUI()
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    EventHandler:AddListener(self, "onPurchaseFailedNotifycation")
end

function RoyalStarBoosterUI:onPurchaseDoneNotifycation(data)
    self:hideLoading()
    self:OnClose()
end

function RoyalStarBoosterUI:onPurchaseFailedNotifycation()
    self:hideLoading()
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function RoyalStarBoosterUI:showLoading()
	self.FullLoading:SetActive(true)
end

function RoyalStarBoosterUI:hideLoading()
	self.FullLoading:SetActive(false)
end

function RoyalStarBoosterUI:initUI()
    local minute = math.floor( self.m_ConfigParam.boosterTime / 60 )
    self.TextMeshProBoosterTime.text = minute

    local skuInfo = self:getSkuInfo()
    local nAddMoneyCount = FormulaHelper:GetAddMoneyBySpendDollar(skuInfo.nDollar)
    self.TextCoinValue.text = MoneyFormatHelper.coinCountOmit(nAddMoneyCount)
    self.TextDollarPrice.text = "$" .. skuInfo.nDollar
end

function RoyalStarBoosterUI:OnBuy()
    self:showLoading()
    local skuInfo = self:getSkuInfo()
    UnityPurchasingHandler:purchase(skuInfo)
end

function RoyalStarBoosterUI:OnClose()
    GlobalAudioHandler:PlayBtnSound()
    self.animator:Play("RoyalPassBoosterUItuichu", -1, 0) -- 退出动画..
    
    LeanTween.delayedCall(1.0, function()
        self.transform.gameObject:SetActive(false)
    end)
end

function RoyalStarBoosterUI:OnPurchaseBenefits()
    GlobalAudioHandler:PlayBtnSound()
    local skuInfo = self:getSkuInfo()
    ShowPurchaseBenifitPop:Show(skuInfo)
end

function RoyalStarBoosterUI:getSkuInfo()
    local skuInfo = AllBuyCFG[1]
    return skuInfo
end