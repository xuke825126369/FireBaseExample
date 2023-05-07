local StoreUI = {}

function StoreUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("Store")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)
    
    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        self:hide()
    end)

    local btnKeepPlaying = self.transform:FindDeepChild("btnKeepPlaying"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnKeepPlaying)
    btnKeepPlaying.onClick:AddListener(function()
        self:hide()
        RainbowPickMainUIPop:hide()
    end)

    self.tableSkuInfo = {}

    self.tableTextPickCount = {}

    self.tableTextCoin = {} --购买给的金币
    self.tableTextPrice = {} --价格
    self.tableTextPickCount = {} --购买给的Pick数量

    local tableName = {"PickBooster", "CoinBooster", "SuperPick"}
    for i = 1, 3 do
        local tr = self.transform:FindDeepChild(tableName[i])
        self.tableTextCoin[i] = tr:FindDeepChild("textCoin"):GetComponent(typeof(UnityUI.Text))
        self.tableTextPrice[i] = tr:FindDeepChild("textPrice"):GetComponent(typeof(UnityUI.Text))
        self.tableTextPickCount[i] = tr:FindDeepChild("textPickCount"):GetComponent(typeof(UnityUI.Text))
        local btnPurchase = tr:FindDeepChild("btnPurchase"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnPurchase)
        btnPurchase.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self.fullLoadingGameObject:SetActive(true)
            UnityPurchasingHandler:purchase(self.tableSkuInfo[i])
        end)
        local btnPurchaseBenefits = tr:FindDeepChild("btnPurchaseBenefits"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnPurchaseBenefits)
        btnPurchaseBenefits.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            ShowPurchaseBenifitPop:Show(self.tableSkuInfo[i])
        end)
    end
    self:refresh()

    self.fullLoadingGameObject = self.transform:FindDeepChild("FullLoading").gameObject
    self.fullLoadingGameObject:SetActive(false)
end

function StoreUI:Show()
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
    
    self.transform:SetAsLastSibling()
    ViewScaleAni:Show(self.transform.gameObject)
    ActivityAudioHandler:PlaySound("rainbow_normal_pop")
    GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
end

function StoreUI:hide()
    ActivityAudioHandler:PlaySound("rainbow_closeWindow")
    ViewScaleAni:Hide(self.transform.gameObject)
end

function StoreUI:refresh()
    local productId = RainbowPickIAPConfig:getSku()
    for i = 1, 3 do
        local skuMap = RainbowPickIAPConfig.skuMap[i]
        local activeInfo = RainbowPickIAPConfig.skuMap[i][productId]
        local skuInfo = self:getSkuInfo(productId, i, activeInfo)
        self.tableSkuInfo[i] = skuInfo
        self.tableTextCoin[i].text = MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
        self.tableTextPrice[i].text = string.format("ONLY $%s", skuInfo.nDollar)
        self.tableTextPickCount[i].text = "+"..math.floor(activeInfo.nAction)
    end
end

function StoreUI:getSkuInfo(productId, nType, activeInfo)
    local skuInfo = GameHelper:GetSimpleSkuInfoById(productId)
    skuInfo.nType = SkuInfoType.RainbowPick
    skuInfo.nActiveIAPType = nType
    skuInfo.activeInfo = activeInfo
    skuInfo.finalCoins = skuInfo.finalCoins * RainbowPickIAPConfig.F_COIN_RATIO
    return skuInfo
end

function StoreUI:onPurchaseFailedNotifycation()
    self.fullLoadingGameObject:SetActive(false)
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function StoreUI:onPurchaseDoneNotifycation(data)
    Debug.Log("StoreUI:onPurchaseDoneNotifycation")
    self.fullLoadingGameObject:SetActive(false)
    self:hide()
end


function StoreUI:Start()
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    EventHandler:AddListener(self, "onPurchaseFailedNotifycation")
end

function StoreUI:OnEnable()
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    EventHandler:AddListener(self, "onPurchaseFailedNotifycation")
end

function StoreUI:OnDisable()
    NotificationHandler:removeObserver(self)
end

return StoreUI