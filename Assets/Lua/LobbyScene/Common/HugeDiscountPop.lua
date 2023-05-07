--很长一段时间没有充值了，就弹出这个


HugeDiscountPop = {}

HugeDiscountPop.gameObject = nil
HugeDiscountPop.transform = nil
HugeDiscountPop.fullLoadingGameObject = nil
HugeDiscountPop.bIsShow = nil
HugeDiscountPop.bLastShow = false
HugeDiscountPop.nLeftTime = GameConfig.IS_TESTER and 60 or 60*60*2
if GameConfig.PLATFORM_EDITOR and CS.BootBehaviour.instance.m_nActiveTestType == 100 then
    HugeDiscountPop.nLeftTime = 10
end

HugeDiscountPop.showHugeDisPopProb = {
    actions = {0, 1}, --0代表不显示，1代表显示
    probs = {1, 1}
}

HugeDiscountPop.ratioPro = {4, 4.5, 5, 5.5, 6}
HugeDiscountPop.tableSku = {
    "com.slots.goldfever.coins015",
    "com.slots.goldfever.coins020",
    "com.slots.goldfever.coins030",
    "com.slots.goldfever.coins050"
}

local yield_return = (require 'cs_coroutine').yield_return

function HugeDiscountPop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function HugeDiscountPop:createAndShow(bIsInQueue)
    if DBHandler.data.bHugeDiscountPop then
        self.bIsShow = true
        TimeLimitedSalePopManager:Start(self)
    else
        self:checkIsShowHugeDis()
    end
    if not self.bIsShow then
        return
    end
    self.index = 1
    if self.gameObject == nil then
        local nameList = {"HugeDiscountPop", "BluePop"}
        if DBHandler.data.HugeDiscountPopIndex == nil then
            DBHandler.data.HugeDiscountPopIndex = math.random(1,2)
            DBHandler:persistentData()
        end
        local strName = nameList[DBHandler.data.HugeDiscountPopIndex]
        local path = "Assets/BaseHotAdd/RocketsSalesShop/".. strName ..".prefab"
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab(path))
        self.tableName = "HugeDiscountPop"
        self.transform = self.gameObject.transform
        self.trBG = self.transform:FindDeepChild("BG")
        LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
        
        self.popController = PopController:new(self.gameObject)
        local btn = self.transform:FindDeepChild("ButtonClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        self.fullLoadingGameObject = self.transform:FindDeepChild("FullLoading").gameObject
        self.button = self.transform:FindDeepChild ("ButtonCollect"):GetComponent(typeof(UnityUI.Button))
        self.timeText = self.transform:FindDeepChild("TimeText"):GetComponent(typeof(TextMeshProUGUI))
        self:refreshContent()
    end
    local bLandscape = (not GameLevelUtil:isPortraitLevel())
    if bLandscape ~= self.bLandscape then
        if bLandscape then
            self.trBG.localScale = Unity.Vector3(0.95, 0.95, 0.95)
        else
            self.trBG.localScale = Unity.Vector3(0.65, 0.65, 0.65)
        end
    end
    self.bLandscape = bLandscape
    self:hideLoading()
    self.button.interactable = true
    self.transform:SetParent(LobbyScene.popCanvas, false)
    bIsInQueue = bIsInQueue or false
    self.popController:show(function()
        local localpos = self.getOldCoinCountText.textInfo.characterInfo[3].bottomRight
        local localpos1 = self.getOldCoinCountText.textInfo.characterInfo[self.getOldCoinCountText.textInfo.characterCount-6].bottomLeft
        local length = Unity.Vector2.Distance(Unity.Vector2(localpos.x,localpos.y), Unity.Vector2(localpos1.x,localpos1.y))
        local redLine = self.transform:FindDeepChild("Redline")
        redLine.sizeDelta = Unity.Vector2(length, 4)
        redLine.localRotation = Unity.Quaternion.Euler(0, 0, 0)
    end, nil, bIsInQueue)

    local timediff = DBHandler:getHugeDisEndTime() - os.time()
    self.timeText.text = LuaHelper.formatSecond(timediff)
end

function HugeDiscountPop:checkIsShowHugeDis()
    local hugeDiscountEndTime = DBHandler:getHugeDisEndTime()
    local now = os.time()
    if hugeDiscountEndTime ~= nil then
        if hugeDiscountEndTime <= now then
            if self.bLastShow then
                self.bIsShow = false
                return
            end
            local nRandomIndex = LuaHelper.GetIndexByRate(self.showHugeDisPopProb.probs)
            local index = self.showHugeDisPopProb.actions[nRandomIndex]
            if index == 0 then
                self.bIsShow = false
                return
            end
        end
    end
    local list = DBHandler:getHugeDisTime()
    local lastTime = 0
    if #list > 0 then
        lastTime = list[#list]
    end
    local timediff = now - lastTime

    local showHugeDiscountPopTime = 10 + (#list) * 5
    if DBHandler.data.bHugeDiscountPopTimesUpLastTime then
        showHugeDiscountPopTime = 1
    end
    local days = timediff // (3600*24)

    if GameConfig.PLATFORM_EDITOR and CS.BootBehaviour.instance.m_nActiveTestType == 100 then
        days = timediff
    end

    if days >= showHugeDiscountPopTime then
        if hugeDiscountEndTime == nil then
            hugeDiscountEndTime = now + self.nLeftTime
            DBHandler:setHugeDisEndTime(hugeDiscountEndTime)
            self.bIsShow = true
            self.bLastShow = true
            TimeLimitedSalePopManager:Start(self)
        else
            if hugeDiscountEndTime <= now then
                local nRandomIndex = LuaHelper.GetIndexByRate(self.showHugeDisPopProb.probs)
                local index = self.showHugeDisPopProb.actions[nRandomIndex]
                if index == 1 then
                    self.bIsShow = true
                    self.bLastShow = true
                    hugeDiscountEndTime = now + self.nLeftTime
                    DBHandler:setHugeDisEndTime(hugeDiscountEndTime)
                    TimeLimitedSalePopManager:Start(self)
                else
                    self.bIsShow = false
                end
            else
                self.bIsShow = true
                self.bLastShow = true
                TimeLimitedSalePopManager:Start(self)
            end
        end
    else
        self.bIsShow = false
    end
end

function HugeDiscountPop:refreshContent()
    local ratioText = self.transform:FindDeepChild ("Ratio"):GetComponent(typeof(TextMeshProUGUI))
    local getCoinsText = self.transform:FindDeepChild ("GetCoins"):GetComponent(typeof(TextMeshProUGUI))
    self.getOldCoinCountText = self.transform:FindDeepChild("OldCoins"):GetComponent(typeof(TextMeshProUGUI))
    local priceText = self.transform:FindDeepChild("Price"):GetComponent(typeof(TextMeshProUGUI))
    if DBHandler.data.HugeDiscountPopShopSku == nil then
        DBHandler.data.HugeDiscountPopShopSku = self:getShopSkus()
        DBHandler:persistentData()
    end
    if DBHandler.data.HugeDiscountPopRatio == nil then
        DBHandler.data.HugeDiscountPopRatio = self.ratioPro[math.random(1, #self.ratioPro)]
        DBHandler:persistentData()
    end
    local productId = DBHandler.data.HugeDiscountPopShopSku
    local ratio = DBHandler.data.HugeDiscountPopRatio
    local skuInfo = self:getSkuInfo(productId, ratio)
    getCoinsText.text = MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
    self.getOldCoinCountText.text = "WAS  "..MoneyFormatHelper.numWithCommas(skuInfo.baseCoins).."  COINS"
    local moreNum = math.ceil((ratio - 1)*100)
    ratioText.text = string.format("%d",moreNum).."%"
    priceText.text = "FOR $"..skuInfo.nDollar
    DelegateCache:addOnClickButton(self.button)
    self.button.onClick:AddListener(function()
        self.button.interactable = false
        IabHandler:purchase(skuInfo)
        self:showLoading()
    end)
    local str = tostring(math.floor(skuInfo.baseCoins))
    LeanTween.scale(self.button.gameObject, Unity.Vector3.one*0.9, 0.8):setEase(LeanTweenType.easeInQuad):setLoopPingPong(-1)
end

function HugeDiscountPop:Start()
    NotificationHandler:addObserver(self, "onPurchaseDoneNotifycation")
    NotificationHandler:addObserver(self, "onPurchaseFailedNotifycation")
end

function HugeDiscountPop:OnEnable()
    NotificationHandler:addObserver(self, "onPurchaseDoneNotifycation")
    NotificationHandler:addObserver(self, "onPurchaseFailedNotifycation")
end

function HugeDiscountPop:OnDisable()
    NotificationHandler:removeObserver(self)
end

function HugeDiscountPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
    if ThemeLoader.themeKey ~= nil then
        SlotsGameLua.m_bReelPauseFlag = false
    end
end

function HugeDiscountPop:showLoading()
	self.fullLoadingGameObject:SetActive(true)
end

function HugeDiscountPop:hideLoading()
	self.fullLoadingGameObject:SetActive(false)
end

function HugeDiscountPop:getShopSkus()
    return self.tableSku[math.random(1, #self.tableSku)]
end

function HugeDiscountPop:getSkuInfo(productId, ratio)
    for i, v in ipairs(DynamicConfig.coinSkuInfoArray) do
        if(productId == v.productId) then 
            local skuInfo = SkuInfo:New()
            skuInfo.productId = productId
            skuInfo.vipPoint = v.vipPoint
            skuInfo.nDollar = v.nDollar
            skuInfo.baseCoins = v.baseCoins
            skuInfo.baseCoins = MoneyFormatHelper.normalizeCoinCount(skuInfo.baseCoins * FormulaHelper:getVipAndLevelBonusMul())
            skuInfo.finalCoins = MoneyFormatHelper.normalizeCoinCount(skuInfo.baseCoins * ratio)
                
            skuInfo.nType = SkuInfoType.ShopCoins

            return skuInfo
        end
    end
    return nil
end

--notification callback
function HugeDiscountPop:onPurchaseDoneNotifycation()
    DBHandler.data.bHugeDiscountPopTimesUpLastTime = nil
    self:hideLoading()
    ViewScaleAni:Hide(self.transform.gameObject)
    if ThemeLoader.themeKey ~= nil then
        SlotsGameLua.m_bReelPauseFlag = false
    end
    TimeLimitedSalePopManager:End(self)
end

function HugeDiscountPop:onPurchaseFailedNotifycation()
    self:hideLoading()
    self.button.interactable = true
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function HugeDiscountPop:onSecond(nowSecond)
    local timediff = DBHandler:getHugeDisEndTime() - nowSecond
    if self:isActiveShow() then
        self.timeText.text = LuaHelper.formatSecond(timediff)
        if timediff <= 0 then
            ViewScaleAni:Hide(self.transform.gameObject)
        end
    end
    if timediff <= 0 then
        DBHandler.data.bHugeDiscountPopTimesUpLastTime = true
        TimeLimitedSalePopManager:End(self)
    end
    return timediff
end

function HugeDiscountPop:onEnd()
    DBHandler:setHugeDisTime()
    DBHandler.data.bHugeDiscountPop = nil
    DBHandler.data.HugeDiscountPopRatio = nil
    DBHandler.data.HugeDiscountPopShopSku = nil
    DBHandler.data.HugeDiscountPopShopIndex = nil
    DBHandler:persistentData()
end

