MegaballPremiumPurchaseBegin = {}

MegaballPremiumBegin.ballSkuInfoArray = {
		{productId = AllBuyCFG[1].productId,    nDollar = 6.99,   vipPoint = 130,    baseCoins = 95000000}, -- ok
		{productId = AllBuyCFG[1].productId,    nDollar = 10.99,   vipPoint = 200,    baseCoins = 170000000},
		{productId = AllBuyCFG[1].productId,    nDollar = 12.99,   vipPoint = 235,    baseCoins = 200000000}, -- 
		{productId = AllBuyCFG[1].productId,    nDollar = 15.99,   vipPoint = 290,    baseCoins = 260000000},
		{productId = AllBuyCFG[1].productId,    nDollar = 34.99,   vipPoint = 650,    baseCoins = 720000000},
		{productId = AllBuyCFG[1].productId,    nDollar = 44.99,   vipPoint = 950,    baseCoins = 1000000000},
		{productId = AllBuyCFG[1].productId,    nDollar = 54.99,   vipPoint = 1250,   baseCoins = 1300000000}
	}

function MegaballPremiumPurchaseBegin:Init(goBeginUI)
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    self.transform = goBeginUI.transform

    local trPlay = self.transform:FindDeepChild("ButtonPlay")
    local btnPlay = trPlay:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnPlay)
    btnPlay.onClick:AddListener(function()
        self:onPlayBtnClicked()
    end)
    self.m_btnPlay = btnPlay

    local tr = self.transform:FindDeepChild("TextMeshProBaseCoins")
    self.m_TextMeshProBaseCoins = tr:GetComponent(typeof(TextMeshProUGUI))
    local nBaseCoins = MegaballPremiumUI.m_BonusData.nBaseCoins
    local strCoins = MoneyFormatHelper.numWithCommas(nBaseCoins)
    strCoins = strCoins .. " Coins"
    self.m_TextMeshProBaseCoins.text = strCoins

    local tr = self.transform:FindDeepChild("TextMultiplyCoef")
    self.m_TextMultiplyCoef = tr:GetComponent(typeof(UnityUI.Text))
    self.m_TextMultiplyCoef.text = "X5000"

    local tr = self.transform:FindDeepChild("ButtonClose")
    self.m_goButtonClose = tr.gameObject
    local btnClose = tr:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        self:onCloseBtnClicked()
    end)
    local btn = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btn)
    btn.onClick:AddListener(function()
        self:onDontMissCloseBtnClicked()
    end)
    
    local tr = self.transform:FindDeepChild("MegaballPremiumBeginAni")
    self.m_goPremiumBeginAni = tr.gameObject
    self.m_goPremiumBeginAni:SetActive(true)

    local trMissIt = self.transform:FindDeepChild("DontMissItUI")
    self.m_goDontMissItUI = trMissIt.gameObject
    self.m_goDontMissItUI:SetActive(false)

    self.m_TextFinalBonus = trMissIt:FindDeepChild("TextFinalBonus"):GetComponent(typeof(UnityUI.Text))
    self.m_TextMeshProMoney = trMissIt:FindDeepChild("TextMeshProMoney"):GetComponent(typeof(TextMeshProUGUI))

    local BtnClose = trMissIt:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(BtnClose)
    BtnClose.onClick:AddListener(function()
        self:Hide()
    end)

    local BtnPurchase = trMissIt:FindDeepChild("ButtonMoney"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(BtnPurchase)
    BtnPurchase.onClick:AddListener(function()
        self:onPurchaseBtnClicked()
    end)

    self.purchaseText = self.transform:FindDeepChild("PurchaseText"):GetComponent(typeof(TextMeshProUGUI))
    self.purchaseBtn = self.transform:FindDeepChild("ButtonPurchase"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.purchaseBtn)
    self.purchaseBtn.onClick:AddListener(function()
        self:onPurchaseBtnClicked()
    end)

end

function MegaballPremiumPurchaseBegin:Show()
    self:Init()
    LeanTween.delayedCall(0.3, function()
        GlobalAudioHandler:PlaySound("popup1")
    end)

    self.skuInfo = AllBuyCFG[math.random(1, #AllBuyCFG)]

    local nBaseCoins = FormulaHelper:GetAddMoneyBySpendDollar(self.skuInfo.nDollar) // 100
    local strCoins = MoneyFormatHelper.numWithCommas(nBaseCoins)
    strCoins = strCoins .. " Coins"
    self.m_TextMeshProBaseCoins.text = strCoins
    self.purchaseText.text = "$"..self.skuInfo.nDollar
    local nBonus = nBaseCoins * 5000
    local strBonus = MoneyFormatHelper.numWithCommas(nBonus)
    self.m_TextFinalBonus.text = strBonus
    self.m_TextMeshProMoney.text = "ONLY $" .. self.skuInfo.nDollar

    self.purchaseBtn.gameObject:SetActive(true)
    self.purchaseBtn.interactable = true
    self.m_goButtonClose:SetActive(true)
    self.transform.gameObject:SetActive(true)
    self.m_btnPlay.interactable = true
end

function MegaballPremiumPurchaseBegin:Hide()
    Unity.Object.Destroy(self.transform.gameObject)
end

function MegaballPremiumPurchaseBegin:onPlayBtnClicked()
    self.m_btnPlay.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    self.transform.gameObject:SetActive(false)
    MegaballPremiumUI:playAni()
end

function MegaballPremiumPurchaseBegin:onPurchaseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    self.purchaseBtn.interactable = false
    WindowLoadingView:Show()

    EventHandler:AddListener("onPurchaseFailedNotifycation", self)
    EventHandler:AddListener("onPurchaseDoneNotifycation", self)

    UnityPurchasingHandler:purchase(self.skuInfo)
end

function MegaballPremiumPurchaseBegin:onPurchaseDoneNotifycation()
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    WindowLoadingView:Hide()

    local listMultiply = MegaballPremiumUI.m_listMultiplyPurchase 
    local listProb = {660, 390, 280, 90, 60}
    local index = LuaHelper.GetIndexByRate(listProb)
    local nMultiplyCoef = listMultiply[index]
    local nBaseCoins = MegaballPremiumUI.m_BonusData.nBaseCoins 
    local vipMultiply = VipHandler:GetVipCoefInfo()
    local nFinalBonus = nBaseCoins * nMultiplyCoef * vipMultiply
    PlayerHandler:AddCoin(nFinalBonus)
    -- 界面展示

    local data = {nBaseCoins = nBaseCoins, nMultiplyCoef = nMultiplyCoef}
    MegaballPremiumUI.m_BonusData = data
    
    self.m_goPremiumBeginAni:SetActive(true)
    self.m_goDontMissItUI:SetActive(false)
    self.purchaseBtn.gameObject:SetActive(false)

    self.m_goButtonClose:SetActive(false)
end

function MegaballPremiumPurchaseBegin:onPurchaseFailedNotifycation()
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    self.purchaseBtn.interactable = true
    WindowLoadingView:Hide()
end

function MegaballPremiumPurchaseBegin:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    self.m_goPremiumBeginAni:SetActive(false)
    self.m_goDontMissItUI:SetActive(true)
end

function MegaballPremiumPurchaseBegin:onDontMissCloseBtnClicked()
    GlobalAudioHandler:PlaySound("dealoffun_cancel")

    self.m_goPremiumBeginAni:SetActive(false)
    self.m_goDontMissItUI:SetActive(true)
    self:Hide()
    MegaballPremiumUI:Hide()
end
