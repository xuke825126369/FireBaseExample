local Store = {}

function Store:Init()
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

    self.tableSkuInfo = {}

    self.tableTextCoin = {} --购买给的金币
    self.tableTextPrice = {} --价格
    self.tableTextAction = {} --购买给的Action数量
    self.tableTextTime = {}

    for i = 1, 3 do
        local tr = self.transform:FindDeepChild(BoardQuestIAPConfig.TYPE_NAME[i])
        self.tableTextCoin[i] = tr:FindDeepChild("textCoin"):GetComponent(typeof(TextMeshProUGUI))
        self.tableTextPrice[i] = tr:FindDeepChild("textPrice"):GetComponent(typeof(TextMeshProUGUI))
        self.tableTextAction[i] = tr:FindDeepChild("textAction"):GetComponent(typeof(TextMeshProUGUI))
        self.tableTextTime[i] = tr:FindDeepChild("textTime"):GetComponent(typeof(TextMeshProUGUI))
        local btnPurchase = tr:FindDeepChild("btnPurchase"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnPurchase)
        btnPurchase.onClick:AddListener(function()
            ActivityAudioHandler:PlaySound("board_button")
            self.fullLoadingGameObject:SetActive(true)
            UnityPurchasingHandler:purchase(self.tableSkuInfo[i])
        end)
        local btnPurchaseBenefits = tr:FindDeepChild("btnPurchaseBenefits"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnPurchaseBenefits)
        btnPurchaseBenefits.onClick:AddListener(function()
            ActivityAudioHandler:PlaySound("board_button")
            ShowPurchaseBenifitPop:Show(self.tableSkuInfo[i])
        end)
    end

    self.fullLoadingGameObject = self.transform:FindDeepChild("FullLoading").gameObject
    self.fullLoadingGameObject:SetActive(false)
end

function Store:Show()
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
    self:refresh()
end

function Store:hide()
    ActivityAudioHandler:PlaySound("board_closeWindow")
    ViewScaleAni:Hide(self.transform.gameObject)
end

function Store:refresh()
    local productId = BoardQuestIAPConfig:getSku()
    for i = 1, 3 do
        local skuMap = BoardQuestIAPConfig.skuMap[i]
        local activeInfo = BoardQuestIAPConfig.skuMap[i][productId]
        local skuInfo = self:getSkuInfo(productId, i, activeInfo)
        self.tableSkuInfo[i] = skuInfo
        self.tableTextCoin[i].text = MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
        self.tableTextPrice[i].text = string.format("ONLY $%s", skuInfo.nDollar)
        self.tableTextAction[i].text = math.floor(activeInfo.nAction)
        self.tableTextTime[i].text = math.floor(activeInfo.nTime / 60)
    end
end

function Store:getSkuInfo(productId, nType, activeInfo)
    local skuInfo = GameHelper:GetSimpleSkuInfoById(productId)
    skuInfo.nType = SkuInfoType.BoardQuest
    skuInfo.nActiveIAPType = nType
    skuInfo.activeInfo = activeInfo
    skuInfo.finalCoins = skuInfo.finalCoins * BoardQuestIAPConfig.F_COIN_RATIO
    return skuInfo
end

function Store:onPurchaseFailedNotifycation()
    self.fullLoadingGameObject:SetActive(false)
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function Store:onPurchaseDoneNotifycation(data)
    Debug.Log("Store:onPurchaseDoneNotifycation")
    self.fullLoadingGameObject:SetActive(false)
    self:hide()
end

function Store:Start()
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    EventHandler:AddListener(self, "onPurchaseFailedNotifycation")
end

function Store:OnEnable()
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    EventHandler:AddListener(self, "onPurchaseFailedNotifycation")
end

function Store:OnDisable()
    NotificationHandler:removeObserver(self)
end

return Store