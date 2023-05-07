CashBackPurchaseUI = {}
CashBackPurchaseUI.coRefreshCountDown = nil
CashBackPurchaseUI.m_CONFIG = {{nDays = 1, productId = AllBuyCFG[10].productId}, 
                                {nDays = 3, productId = AllBuyCFG[11].productId}, 
                                {nDays = 7, productId = AllBuyCFG[14].productId}}

function CashBackPurchaseUI:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end

    return true
end

function CashBackPurchaseUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadGoldenLoungeAsset("LoungeUI/CashBackPurchaseUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(GlobalScene.popCanvasActivity, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        
        local btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnClose)
        btnClose.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:Hide(true)
        end)

        local trCashBackNode = self.transform:FindDeepChild("CashBackNode")
        self.goLockCashBack = trCashBackNode:FindDeepChild("LockNode").gameObject
        local tr = trCashBackNode:FindDeepChild("TextMeshProCountDown")
        self.TextMeshProCountDown = tr:GetComponent(typeof(TextMeshProUGUI))
        local tr = trCashBackNode:FindDeepChild("TextCoins")
        self.TextCoins = tr:GetComponent(typeof(UnityUI.Text))
        
        local listNames = {"purchaseNode1", "purchaseNode2", "purchaseNode3"}
        self.listPurchaseNodes = {} -- 三个子表
        for i=1, 3 do
            local tr = self.transform:FindDeepChild(listNames[i])
            local btnPurchaseBenefits = tr:FindDeepChild("BtnPurchaseBenefits"):GetComponent(typeof(UnityUI.Button))
            DelegateCache:addOnClickButton(btnPurchaseBenefits)
            btnPurchaseBenefits.onClick:AddListener(function()
                GlobalAudioHandler:PlayBtnSound()
                self:BtnPurchaseBenefitsClicked(i)
            end)
    
            local btnPurchase = tr:FindDeepChild("BtnPurchase"):GetComponent(typeof(UnityUI.Button))
            DelegateCache:addOnClickButton(btnPurchase)
            btnPurchase.onClick:AddListener(function()
                GlobalAudioHandler:PlayBtnSound()
                self:BtnPurchaseClicked(i)
            end)
        end
        self.mTimeOutGenerator = TimeOutGenerator:New()
    end

    ViewAlphaAni:Show(self.transform.gameObject)

    local nBonus = 0
    if CommonDbHandler.data.CashBackParam.nBonus ~= nil then
        nBonus = CommonDbHandler.data.CashBackParam.nBonus
    end
    self.TextCoins.text = MoneyFormatHelper.numWithCommas(nBonus)
    self.transform:SetAsLastSibling() -- SetAsFirstSibling -- SetSiblingIndex(0)
end

function CashBackPurchaseUI:Hide()
    LoungeAudioHandler:StopBackMusic()
    ViewAlphaAni:Hide(self.transform.gameObject)
end

function CashBackPurchaseUI:BtnPurchaseBenefitsClicked(index)
    GlobalAudioHandler:PlayBtnSound()
    local skuInfo = self:getSkuInfo(index)
    ShowPurchaseBenifitPop:Show(skuInfo)
end

function CashBackPurchaseUI:BtnPurchaseClicked(index)
    local skuInfo = self:getSkuInfo(index)
    WindowLoadingView:Show()
    EventHandler:AddListener("onPurchaseFailedNotifycation", self)
    EventHandler:AddListener("onPurchaseDoneNotifycation", self)
    UnityPurchasingHandler:purchase(skuInfo)
end

function CashBackPurchaseUI:getSkuInfo(index)
    local skuInfo = GameHelper:GetSimpleSkuInfoById(self.m_CONFIG[index].productId)
    skuInfo.finalCoins = 0
    skuInfo.nDays = self.m_CONFIG[index].nDays
    skuInfo.nType = SkuInfoType.LoungeCashBackPurchase
    return skuInfo
end

function CashBackPurchaseUI:onPurchaseFailedNotifycation(skuInfo)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    CommonDialogBox:ShowSureUI("Purchase Failed")
    WindowLoadingView:Hide()
end

function CashBackPurchaseUI:onPurchaseDoneNotifycation(skuInfo)
    EventHandler:RemoveListener("onPurchaseFailedNotifycation", self)
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    WindowLoadingView:Hide()
    if skuInfo.nType ~= SkuInfoType.LoungeCashBackPurchase then
        return
    end

    local nDays = skuInfo.nDays
    local nTime = nDays * LoungeConfig.m_nOneDaySecond
    local booster = {fCoef = 0.03, nBoosterTime = nTime}
    BoostHandler:setCashBackBoosterParam(booster)
end

function CashBackPurchaseUI:Update()
    if not self.mTimeOutGenerator:orTimeOut() then
        return
    end
    
    if BoostHandler.m_nCashBackRemainTime <= 0 then
        if not self.goLockCashBack.activeSelf then
            self.goLockCashBack:SetActive(true)
        end
        return
    end

    if self.goLockCashBack.activeSelf then
        self.goLockCashBack:SetActive(false)
    end

    BoostHandler.m_nCashBackRemainTime = BoostHandler.m_nCashBackRemainTime - 1
    local strInfo = BoostHandler:FormatTime(BoostHandler.m_nCashBackRemainTime)
    self.TextMeshProCountDown.text = strInfo
end
