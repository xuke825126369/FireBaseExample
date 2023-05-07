--点击菜，出现菜谱
CookingFeverIAPStoreUI = {}

function CookingFeverIAPStoreUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("IAPStore")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)
    
    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        if self.bCanHide then
            ActivityAudioHandler:PlaySound("cook_button")
            self:hide()
        end
    end)

    self.tableSkuInfo = {}

    self.tableTextCoin = {} --金币数量
    self.tableTextCookCoin = {}
    self.tableTextPrice = {} --价格

    local tableName = {"CoinBooster", "BasketBooster", "WildBasket"}
    for i = 1, 3 do
        local tr = self.transform:FindDeepChild(tableName[i])
        self.tableTextCoin[i] = tr:FindDeepChild("textCoin"):GetComponent(typeof(UnityUI.Text))
        self.tableTextCookCoin[i] = tr:FindDeepChild("textCookCoin"):GetComponent(typeof(TextMeshProUGUI))
        self.tableTextPrice[i] = tr:FindDeepChild("textPrice"):GetComponent(typeof(UnityUI.Text))
        local btnBuy = tr:FindDeepChild("btnBuy"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnBuy)
        btnBuy.onClick:AddListener(function()
            ActivityAudioHandler:PlaySound("cook_button")
            self.fullLoadingGameObject:SetActive(true)
            UnityPurchasingHandler:purchase(self.tableSkuInfo[i])
        end)
        local btnPurchaseBenefits = tr:FindDeepChild("btnPurchaseBenefits"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnPurchaseBenefits)
        btnPurchaseBenefits.onClick:AddListener(function()
            ActivityAudioHandler:PlaySound("cook_button")
            ShowPurchaseBenifitPop:Show(self.tableSkuInfo[i])
        end)

        if i == 1 then
            self.textCoinBoosterTime = tr:FindDeepChild("textTime"):GetComponent(typeof(UnityUI.Text))
        elseif i == 2 then
            self.textBasketBoosterTime = tr:FindDeepChild("textTime"):GetComponent(typeof(UnityUI.Text))
        elseif i == 3 then
            self.textWildBasketCount = tr:FindDeepChild("textCount"):GetComponent(typeof(UnityUI.Text))
        end
    end
    self:refresh()

    self.fullLoadingGameObject = self.transform:FindDeepChild("FullLoading").gameObject
    self.fullLoadingGameObject:SetActive(false)
end

function CookingFeverIAPStoreUI:Show()
    if self.transform.gameObject == nil then
        self.m_bInitFlag = false
    else
        if self.transform.gameObject:Equals(nil) then
            self.m_bInitFlag = false
        end
    end
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:Init()
    end
    self.bCanHide = true
    ActivityAudioHandler:PlaySound("cook_normal_pop_up")
    GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    self.transform:SetAsLastSibling()
    ViewScaleAni:Show(self.transform.gameObject)
end

function CookingFeverIAPStoreUI:hide()
    if not self.bCanHide then return end
    self.bCanHide = false
    ViewScaleAni:Hide(self.transform.gameObject)
end

function CookingFeverIAPStoreUI:refresh()
    local productId = CookingFeverIAPConfig:getSku()
    for i = 1, 3 do
        local skuMap = CookingFeverIAPConfig.skuMap[i]
        local info = skuMap[productId]
        local skuInfo = self:getSkuInfo(productId, i, info)
        self.tableSkuInfo[i] = skuInfo
        self.tableTextCoin[i].text = MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
        self.tableTextCookCoin[i].text = tostring(skuInfo.activeInfo.nAction)
        self.tableTextPrice[i].text = string.format("ONLY $%s", skuInfo.nDollar)
        if i == 1 then
            self.textCoinBoosterTime.text = math.floor(skuInfo.activeInfo.nTime // 60)
        elseif i == 2 then
            self.textBasketBoosterTime.text = math.floor(skuInfo.activeInfo.nTime // 60)
        elseif i == 3 then
            self.textWildBasketCount.text = skuInfo.activeInfo.nWildBasketCount
        end
    end
end

function CookingFeverIAPStoreUI:getSkuInfo(productId, nType, info)
    local skuInfo = GameHelper:GetSimpleSkuInfoById(productId)
    skuInfo.nType = SkuInfoType.CookingFever
    skuInfo.nActiveIAPType = nType
    skuInfo.activeInfo = info
    skuInfo.finalCoins = skuInfo.finalCoins * CookingFeverIAPConfig.F_COIN_RATIO
    return skuInfo
end

function CookingFeverIAPStoreUI:onPurchaseFailedNotifycation()
    self.fullLoadingGameObject:SetActive(false)
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function CookingFeverIAPStoreUI:onPurchaseDoneNotifycation(data)
    self.fullLoadingGameObject:SetActive(false)
    self:hide()
end

function CookingFeverIAPStoreUI:Start()
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    EventHandler:AddListener(self, "onPurchaseFailedNotifycation")
end

function CookingFeverIAPStoreUI:OnEnable()
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    EventHandler:AddListener(self, "onPurchaseFailedNotifycation")
end

function CookingFeverIAPStoreUI:OnDisable()
    NotificationHandler:removeObserver(self)
end

function CookingFeverIAPStoreUI:OnDestroy()
    NotificationHandler:removeObserver(self)
end