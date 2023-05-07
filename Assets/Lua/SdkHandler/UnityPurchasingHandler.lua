
UnityPurchasingHandler = {}
UnityPurchasingHandler.bInIniting = false

function UnityPurchasingHandler:Init()
    self.bInIniting = true
    local storeItemList = {}
    for i, v in ipairs(AllBuyCFG) do
        table.insert(storeItemList, CS.CustomStoreItem(v.productId, Unity.Purchasing.ProductType.Consumable))
    end 
     
    self.controller = nil
    CS.UnityPurchasingInterface.Instance:Init(storeItemList)   
end

function UnityPurchasingHandler:OnInitialized(controller, extensions)
    self.bInIniting = false
    Debug.Log("UnityIAP.Initialization 成功")
    self.controller = controller
    CS.AppPurchaseUnityValidation.Instance:InitializeValidator()
end

function UnityPurchasingHandler:OnInitializeFailed(mInitializationFailureReason)
    self.bInIniting = false
    Debug.Log("UnityIAP.Initialization失败: "..mInitializationFailureReason:ToString())
end

function UnityPurchasingHandler:OnPurchaseFailed(mProduct, mPurchaseFailureReason)
    GlobalTempData.bInBuySDK = false
    Debug.Log("OnPurchaseFailed失败: "..mProduct.definition.id..": "..mPurchaseFailureReason:ToString())
    EventHandler:Brocast("onPurchaseFailedNotifycation")
end

function UnityPurchasingHandler:ProcessPurchase(mPurchaseEventArgs)
    GlobalTempData.bInBuySDK = false
    local productId = mPurchaseEventArgs.purchasedProduct.definition.id
    if PlayerHandler.currentSkuInfo.productId == productId then
        local skuInfo = PlayerHandler.currentSkuInfo
        local nDollar = skuInfo.nDollar

        if CS.AppPurchaseUnityValidation.Instance:IsPurchaseValid(mPurchaseEventArgs.purchasedProduct) then
            EventHandler:Brocast("onPurchaseDoneNotifycation", skuInfo)
            AppAdsEventHandler:SendBuyEvent(productId)
            RechargeHandler:RecordLastRechargeTime(skuInfo)
        else
            EventHandler:Brocast("onPurchaseFailedNotifycation")
        end
    else
        Debug.Assert(false, productId.." | "..PlayerHandler.currentSkuInfo.productId)
    end
end

function UnityPurchasingHandler:purchase(skuInfo)
    GlobalTempData.bInBuySDK = true
    PlayerHandler.data.currentSkuInfo = skuInfo
    PlayerHandler:SaveDb()
    
    if self.controller then
        LeanTween.delayedCall(1.0, function()
            self.controller:InitiatePurchase(skuInfo.productId)
        end)
    else
        Debug.LogError("购买 出错")
        EventHandler:Brocast("onPurchaseFailedNotifycation")
        GlobalTempData.bInBuySDK = false
        if not self.bInIniting then
            self:Init()
        end
    end
end

return UnityPurchasingHandler

