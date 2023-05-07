BingoSaleUIPop = {}

function BingoSaleUIPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadActivityAsset("BingoSaleUIPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_btnClose = self.transform:FindDeepChild("CloseButton"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnClose)
        self.m_btnClose.onClick:AddListener(function()
            ActivityAudioHandler:PlaySound("bingo_generic_click")
            self:Hide()
        end)

        local btnClose = self.transform:FindDeepChild("KeepButton"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnClose)
        btnClose.onClick:AddListener(function()
            ActivityAudioHandler:PlaySound("bingo_generic_click")
            self:Hide()
        end)

        -- boost 相关
        self.m_boosterContainer = self.transform:FindDeepChild("BtnBooster")
        self:RefreshBoostSaleUI()
        -- wild 相关
        self.m_wildContainer = self.transform:FindDeepChild("BtnWild")
        self:RefreshWildSaleUI()
        -- super 相关
        self.m_superContainer = self.transform:FindDeepChild("BtnSuper")
        self:RefreshSuperSaleUI()
    end
    
    EventHandler:AddListener("onPurchaseDoneNotifycation", self)
    EventHandler:AddListener("onPurchaseFailedNotifycation", self)
    ViewAlphaAni:Show(self.transform.gameObject)
end

function BingoSaleUIPop:RefreshBoostSaleUI()
    local skuInfo = self:getSkusInfo(BingoIAPConfig.Type.BingoBooster)
    local activeInfo = skuInfo.activeInfo

    local price = self.m_boosterContainer:FindDeepChild("PriceText"):GetComponent(typeof(TextMeshProUGUI))
    price.text = "ONLY $"..skuInfo.nDollar

    local boosterTime = self.m_boosterContainer:FindDeepChild("BoosterTime"):GetComponent(typeof(TextMeshProUGUI))
    boosterTime.text = string.format("%d", activeInfo.nBingoBoosterTime / 60)

    local coinsText = self.m_boosterContainer:FindDeepChild("CoinsText"):GetComponent(typeof(UnityUI.Text))
    coinsText.text = "$ "..MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)

    local sendBingoCount = self.m_boosterContainer:FindDeepChild("SendBingoCount"):GetComponent(typeof(TextMeshProUGUI))
    sendBingoCount.text = activeInfo.nAction

    local btnBuy = self.m_boosterContainer:FindDeepChild("BtnONLY"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnBuy)
    btnBuy.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("bingo_generic_click")
        WindowLoadingView:Show()
        UnityPurchasingHandler:purchase(skuInfo)
    end)

    local btnPurchase = self.m_boosterContainer:FindDeepChild("BtnPurxhase"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnPurchase)
    btnPurchase.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("bingo_generic_click")
        ShowPurchaseBenifitPop:Show(skuInfo)
    end)

end

function BingoSaleUIPop:RefreshWildSaleUI()
    local skuInfo = self:getSkusInfo(BingoIAPConfig.Type.WildBall)
    local activeInfo = skuInfo.activeInfo

    local price = self.m_wildContainer:FindDeepChild("PriceText"):GetComponent(typeof(TextMeshProUGUI))
    price.text = "ONLY $"..skuInfo.nDollar

    local coinsText = self.m_wildContainer:FindDeepChild("CoinsText"):GetComponent(typeof(UnityUI.Text))
    coinsText.text = "$ "..MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
    
    local sendBingoCount = self.m_wildContainer:FindDeepChild("SendBingoCount"):GetComponent(typeof(TextMeshProUGUI))
    sendBingoCount.text = activeInfo.nAction
    
    local sendWildCount = self.m_wildContainer:FindDeepChild("SendWildCount"):GetComponent(typeof(TextMeshProUGUI))
    sendWildCount.text = "+"..activeInfo.nWildBallCount

    local btnBuy = self.m_wildContainer:FindDeepChild("BtnONLY"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnBuy)
    btnBuy.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("bingo_generic_click")
        WindowLoadingView:Show()
        UnityPurchasingHandler:purchase(skuInfo)
    end)

    local btnPurchase = self.m_wildContainer:FindDeepChild("BtnPurxhase"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnPurchase)
    btnPurchase.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("bingo_generic_click")
        ShowPurchaseBenifitPop:Show(skuInfo)
    end)
end

function BingoSaleUIPop:RefreshSuperSaleUI()
    local skuInfo = self:getSkusInfo(BingoIAPConfig.Type.SuperBall)
    local activeInfo = skuInfo.activeInfo

    local price = self.m_superContainer:FindDeepChild("PriceText"):GetComponent(typeof(TextMeshProUGUI))
    price.text = "ONLY $"..skuInfo.nDollar

    local coinsText = self.m_superContainer:FindDeepChild("CoinsText"):GetComponent(typeof(UnityUI.Text))
    coinsText.text = "$ "..MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
    
    local sendBingoCount = self.m_superContainer:FindDeepChild("SendBingoCount"):GetComponent(typeof(TextMeshProUGUI))
    sendBingoCount.text = activeInfo.nAction
    
    local sendSuperCount = self.m_superContainer:FindDeepChild("SendSuperCount"):GetComponent(typeof(UnityUI.Text))
    sendSuperCount.text = activeInfo.nSuperBallCount

    local btnBuy = self.m_superContainer:FindDeepChild("BtnONLY"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnBuy)
    btnBuy.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("bingo_generic_click")
        WindowLoadingView:Show()
        UnityPurchasingHandler:purchase(skuInfo)
    end)

    local btnPurchase = self.m_superContainer:FindDeepChild("BtnPurxhase"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnPurchase)
    btnPurchase.onClick:AddListener(function()
        ActivityAudioHandler:PlaySound("bingo_generic_click")
        ShowPurchaseBenifitPop:Show(skuInfo)
    end)
end

function BingoSaleUIPop:Hide()
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    ViewAlphaAni:Hide(self.transform.gameObject)
    BingoMainUIPop:Show()
end

function BingoSaleUIPop:onPurchaseDoneNotifycation(skuInfo)
    WindowLoadingView:Hide()
    PlayerHandler:AddRecharge(skuInfo.nDollar)
    PlayerHandler:AddCoin(skuInfo.finalCoins)
        
    PopStackViewHandler:Show(ShopEndPop, skuInfo)
    self:Hide()
end

function BingoSaleUIPop:onPurchaseFailedNotifycation()
    WindowLoadingView:Hide()
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function BingoSaleUIPop:getSkusInfo(nActiveIAPType)
    local time = BingoHandler.data.endTime - TimeHandler:GetServerTimeStamp()
    local days = time // (3600 * 24)
    local nIndex = days % 3 + 1
    
    local activeInfo = BingoIAPConfig.skuMap[nActiveIAPType][nIndex]
    return self:getBingoSkuInfo(activeInfo.productId, nActiveIAPType, activeInfo)
end

function BingoSaleUIPop:getBingoSkuInfo(productId, nActiveIAPType, activeInfo)
    local skuInfo = GameHelper:GetSimpleSkuInfoById( productId)
    skuInfo.nType = SkuInfoType.Bingo
    skuInfo.activeInfo = activeInfo
    skuInfo.nActiveIAPType = nActiveIAPType
    skuInfo.finalCoins = skuInfo.finalCoins * 0.5
    return skuInfo
end
