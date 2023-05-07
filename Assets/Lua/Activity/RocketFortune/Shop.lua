local Shop = {}

function Shop:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("Shop")
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

    self.tableSkuInfo = {}

    self.tableTextActionCount = {}

    self.tableTextCoin = {} --购买给的金币
    self.tableTextPrice = {} --价格
    self.tableTextActionCount = {} --购买给的Pick数量

    local tableName = {"WheelSpinsBooster", "SuperWheelSpins", "ChutesRemoved"}
    for i = 1, 3 do
        local tr = self.transform:FindDeepChild(tableName[i])
        self.tableTextCoin[i] = tr:FindDeepChild("textCoin"):GetComponent(typeof(UnityUI.Text))
        self.tableTextPrice[i] = tr:FindDeepChild("textPrice"):GetComponent(typeof(UnityUI.Text))
        self.tableTextActionCount[i] = tr:FindDeepChild("textAction"):GetComponent(typeof(TextMeshProUGUI))
        Debug.Assert(self.tableTextActionCount[i], "textAction "..i)
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

function Shop:Show()
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
    GlobalAudioHandler:PlayBtnSound()
    GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
end

function Shop:hide()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function Shop:refresh()
    local productId = RocketFortuneIAPConfig:getSku()
    for i = 1, 3 do
        local skuMap = RocketFortuneIAPConfig.skuMap[i]
        local activeInfo = RocketFortuneIAPConfig.skuMap[i][productId]
        local skuInfo = self:getSkuInfo(productId, i, activeInfo)
        self.tableSkuInfo[i] = skuInfo
        self.tableTextCoin[i].text = MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
        self.tableTextPrice[i].text = string.format("ONLY $%s", skuInfo.nDollar)
        self.tableTextActionCount[i].text = "+"..math.floor(activeInfo.nAction)
    end
end

function Shop:getSkuInfo(productId, nType, activeInfo)
    local skuInfo = GameHelper:GetSimpleSkuInfoById(productId)
    skuInfo.nType = SkuInfoType.RocketForune
    skuInfo.nActiveIAPType = nType
    skuInfo.activeInfo = activeInfo
    skuInfo.finalCoins = skuInfo.finalCoins * RocketFortuneIAPConfig.F_COIN_RATIO
    return skuInfo
end

function Shop:onPurchaseFailedNotifycation()
    self.fullLoadingGameObject:SetActive(false)
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function Shop:onPurchaseDoneNotifycation(data)
    Debug.Log("Shop:onPurchaseDoneNotifycation")
    self.fullLoadingGameObject:SetActive(false)
    self:hide()
end


function Shop:Start()
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    EventHandler:AddListener(self, "onPurchaseFailedNotifycation")
end

function Shop:OnEnable()
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    EventHandler:AddListener(self, "onPurchaseFailedNotifycation")
end

function Shop:OnDisable()
    NotificationHandler:removeObserver(self)
end

return Shop