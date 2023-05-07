

BluePop = {}

BluePop.gameObject = nil
BluePop.transform = nil
BluePop.fullLoadingGameObject = nil

local yield_return = (require 'cs_coroutine').yield_return

function BluePop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function BluePop:createAndShow(bIsInQueue)
    local endTime, ratio, strType = SaleAdHandler:checkNormalSalesType("BluePop")
    if strType == nil or strType ~= "BluePop" then
        return
    end
    if DBHandler:checkHasSpecialSaleList("BluePop") then
        return
    end
    if self.gameObject == nil then
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/RocketsSalesShop/BluePop.prefab"))
        self.transform = self.gameObject.transform
        self.trBG = self.transform:FindDeepChild("BG")
        LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
        
        self.popController = PopController:new(self.gameObject)
        local btn = self.transform:FindDeepChild("ButtonClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        self.btnInfo = self.transform:FindDeepChild("ButtonPurchaseBenefits"):GetComponent(typeof(UnityUI.Button))
        self.fullLoadingGameObject = self.transform:FindDeepChild("FullLoading").gameObject
        self:updateLeftTime(endTime)
        self:refreshContent(ratio)
    end

    if Boot.isInReview then
        self:refreshContent(ratio)
    end

    local bLandscape = (not GameLevelUtil:isPortraitLevel())
    if bLandscape ~= self.bLandscape then
        if bLandscape then
            self.trBG.localScale = Unity.Vector3(0.9, 0.9, 0.9)
        else
            self.trBG.localScale = Unity.Vector3(0.65, 0.65, 0.65)
        end
    end
    self.bLandscape = bLandscape

    self:hideLoading()
    self.button.interactable = true
    self.transform:SetParent(LobbyScene.popCanvas, false)
    bIsInQueue = bIsInQueue or false
    self.popController:show(nil, nil, bIsInQueue)
    
    if ThemeLoader.themeKey ~= nil then
        SlotsGameLua.m_bReelPauseFlag = true
    end
end

function BluePop:refreshContent(ratio)
    self.shopSkus = self:getShopSkus()
    self.button = self.transform:FindDeepChild ("ButtonCollect"):GetComponent(typeof(UnityUI.Button))
    -- local coinCountGo = item:FindDeepChild ("CoinCount").gameObject
    local ratioText = self.transform:FindDeepChild ("Ratio"):GetComponent(typeof(TextMeshProUGUI))
    local getCoinsText = self.transform:FindDeepChild ("GetCoins"):GetComponent(typeof(TextMeshProUGUI))
    local getOldCoinCountText = self.transform:FindDeepChild("OldCoins"):GetComponent(typeof(TextMeshProUGUI))
    local priceText = self.transform:FindDeepChild("Price"):GetComponent(typeof(TextMeshProUGUI))
    local productId = self.shopSkus
    local skuInfo = SaleAdHandler:getSalesSkuInfo(productId, ratio, "BluePop")
    getCoinsText.text = MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
    getOldCoinCountText.text = "WAS "..MoneyFormatHelper.numWithCommas(skuInfo.baseCoins).." COINS"
    local moreNum = math.ceil((ratio - 1)*100)
    ratioText.text = string.format("%d",moreNum).."%"
    priceText.text = "FOR $"..skuInfo.nDollar
    self.button.onClick:RemoveAllListeners()
    DelegateCache:addOnClickButton(self.button)
    self.button.onClick:AddListener(function()
        self.button.interactable = false
        IabHandler:purchase(skuInfo)
        self:showLoading()
    end)
    self.btnInfo.onClick:RemoveAllListeners()
    DelegateCache:addOnClickButton(self.btnInfo)
    self.btnInfo.onClick:AddListener(function()
        SendIntroducePop:createAndShow(skuInfo)
    end)
end

function BluePop:Start()
    NotificationHandler:addObserver(self, "onPurchaseDoneNotifycation")
    NotificationHandler:addObserver(self, "onPurchaseFailedNotifycation")
end

function BluePop:OnEnable()
    NotificationHandler:addObserver(self, "onPurchaseDoneNotifycation")
    NotificationHandler:addObserver(self, "onPurchaseFailedNotifycation")
end

function BluePop:OnDisable()
    NotificationHandler:removeObserver(self)
end

function BluePop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
    if ThemeLoader.themeKey ~= nil then
        SlotsGameLua.m_bReelPauseFlag = false
    end
end

--notification callback
function BluePop:onPurchaseDoneNotifycation()
    self:hideLoading()
    ViewScaleAni:Hide(self.transform.gameObject)
    if ThemeLoader.themeKey ~= nil then
        SlotsGameLua.m_bReelPauseFlag = false
    end
end

function BluePop:onPurchaseFailedNotifycation()
    self:hideLoading()
    self.button.interactable = true
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function BluePop:showLoading()
	self.fullLoadingGameObject:SetActive(true)
end

function BluePop:hideLoading()
	self.fullLoadingGameObject:SetActive(false)
end

function BluePop:getShopSkus()
    local productId = "com.slots.goldfever.coins001"
    local reviewList = {"com.slots.goldfever.coins003",
                        "com.slots.goldfever.coins006",
                        "com.slots.goldfever.coins009",
                        "com.slots.goldfever.coins015",
                        "com.slots.goldfever.coins025"}
    productId = reviewList[math.random(1, 5)]
    -- if Boot.isInReview then
    --     local reviewList = {"com.slots.goldfever.coins025",
    --                         "com.slots.goldfever.coins030",
    --                         "com.slots.goldfever.coins035",
    --                         "com.slots.goldfever.coins040",
    --                         "com.slots.goldfever.coins060",
    --                         "com.slots.goldfever.coins070",
    --                         "com.slots.goldfever.coins080",
    --                         "com.slots.goldfever.coins090"}
    --     productId = reviewList[math.random(1, 8)]
    -- end
    return productId
end

function BluePop:updateLeftTime(endTime)
    local co = StartCoroutine( function()
        local timeText = self.transform:FindDeepChild("TimeText"):GetComponent(typeof(TextMeshProUGUI))
        local waitForSecend = Unity.WaitForSeconds(1)
        while endTime ~= nil do
            local nowSecond = os.time()
            local timediff = endTime - nowSecond

            local days = timediff // (3600*24)
            local hours = timediff // 3600 - 24 * days
            local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
            local seconds = timediff % 60
            if days > 0 then
                timeText.text = string.format("Time Left %d days!",days)
            else
                timeText.text = string.format("%02d:%02d:%02d", hours, minutes, seconds) --os.date("%H:%M:%S", time)
            end
            yield_return(waitForSecend)
            if days == 0 and hours == 0 and minutes == 0 and seconds == 0 then
                endTime = nil
                if SaleAdEntry.m_gameObject ~= nil then
                    -- SaleAdEntry:onPurchaseDoneNotifycation()
                end
            end
        end
    end)
end

-- function BluePop:setCardsContainer(parent, skuInfo)
--     local cardText = parent:FindDeepChild("SlotsCardInfoText"):GetComponent(typeof(TextMeshProUGUI))
--     local stars = parent:FindDeepChild("Stars")
--     for i=1,#SlotsCardsGiftManager.m_skuToSlotsCardsPack do
--         if skuInfo.productId == SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].productId then
--             cardText.text = "Min " .. SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].minCardCount .. " of"
--             for j = 0, stars.childCount - 1 do
--                 if j < SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].starCount then
--                     stars:GetChild(j).gameObject:SetActive(true)
--                 else
--                     stars:GetChild(j).gameObject:SetActive(false)
--                 end
--             end
--             break
--         end
--     end
-- end