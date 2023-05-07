RoyalPassShopUI = {}

function RoyalPassShopUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "Lobby"
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/RoyalPass/PopPrefab/RoyalPassShopUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(MissionMainUIPop.m_trPopNode, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trContent = self.transform:FindDeepChild("Content")
        self.m_btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnClose)
        self.m_btnClose.onClick:AddListener(function()
            self.m_btnClose.interactable = false
            GlobalAudioHandler:PlayBtnSound()
            self:Hide()
        end)

        self.m_btnBuy1 = self.transform:FindDeepChild("BtnBuy1"):GetComponent(typeof(UnityUI.Button))
        self.m_btnBuy1Introduce = self.transform:FindDeepChild("PurchaseBenefits1Btn"):GetComponent(typeof(UnityUI.Button))
        local skuInfo1 = self:getSkuInfo(AllBuyCFG[5].productId, 0)
        local price = self.m_btnBuy1.transform:FindDeepChild("Text"):GetComponent(typeof(TextMeshProUGUI))
        price.text = "$"..skuInfo1.nDollar
        DelegateCache:addOnClickButton(self.m_btnBuy1)
        self.m_btnBuy1.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            WindowLoadingView:Show()

            EventHandler:AddListener("onPurchaseDoneNotifycation", self)
            EventHandler:AddListener("onPurchaseFailedNotifycation", self)
            UnityPurchasingHandler:purchase(skuInfo1)
        end)
        DelegateCache:addOnClickButton(self.m_btnBuy1Introduce)
        self.m_btnBuy1Introduce.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            ShowPurchaseBenifitPop:Show(skuInfo1)
        end)
        
        self.m_btnBuy2 = self.transform:FindDeepChild("BtnBuy2"):GetComponent(typeof(UnityUI.Button))
        self.m_btnBuy2Introduce = self.transform:FindDeepChild("PurchaseBenefits2Btn"):GetComponent(typeof(UnityUI.Button))
        local skuInfo2 = self:getSkuInfo(AllBuyCFG[13].productId, 5000)
        local price = self.m_btnBuy2.transform:FindDeepChild("Text"):GetComponent(typeof(TextMeshProUGUI))
        price.text = "$"..skuInfo2.nDollar

        DelegateCache:addOnClickButton(self.m_btnBuy2)
        self.m_btnBuy2.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            WindowLoadingView:Show()

            EventHandler:AddListener("onPurchaseDoneNotifycation", self)
            EventHandler:AddListener("onPurchaseFailedNotifycation", self)
            UnityPurchasingHandler:purchase(skuInfo2)
        end)
        
        DelegateCache:addOnClickButton(self.m_btnBuy2Introduce)
        self.m_btnBuy2Introduce.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            ShowPurchaseBenifitPop:Show(skuInfo2)
        end)
    end

    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self.m_btnClose.interactable = true
    end)
    GlobalAudioHandler:PlaySound("popup")

end

function RoyalPassShopUI:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function RoyalPassShopUI:onPurchaseDoneNotifycation(skuInfo)
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    WindowLoadingView:Hide()
    self:Hide()

    PopStackViewHandler:Show(ShopEndPop, skuInfo)
    RoyalPassHandler:setPurchase()

    local bIsUpgrade, bHasPrize = false, false
    if skuInfo.nAddStar > 0 then
        bIsUpgrade, bHasPrize = RoyalPassHandler:addStars(skuInfo.nAddStar)
    end
    
    RoyalPassMainUI:updateUI()
    if bIsUpgrade then
        PopStackViewHandler:Show(RoyalPassLevelUpUI, bHasPrize)
    end
    
    PopStackViewHandler:Show(RoyalPassUnlockRoyalUI)
end

function RoyalPassShopUI:onPurchaseFailedNotifycation()
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    WindowLoadingView:Hide()
end

function RoyalPassShopUI:getSkuInfo(productId, nAddStar)
    local skuInfo = GameHelper:GetSimpleSkuInfoById( productId)
    skuInfo.nType = SkuInfoType.RoyalPassShop
    skuInfo.finalCoins = 0
    skuInfo.nAddStar = nAddStar
    skuInfo.vipPoint = FormulaHelper:GetAddVipPointBySpendDollar(skuInfo.nDollar)
    return skuInfo
end