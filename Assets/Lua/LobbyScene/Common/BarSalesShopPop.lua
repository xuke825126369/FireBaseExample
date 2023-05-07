

BarSalesShopPop = {}

BarSalesShopPop.gameObject = nil
BarSalesShopPop.transform = nil
BarSalesShopPop.fullLoadingGameObject = nil

local yield_return = (require 'cs_coroutine').yield_return

local data = 0

function BarSalesShopPop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function BarSalesShopPop:createAndShow(bIsInQueue)
    --查看是否有促销活动
    local salesActiveRatioArray, endTime = BonusUtil.rocketsSalesShopRatio()
    
    --如果没有不显示
    if salesActiveRatioArray == nil then
        return
    end

    local endInfo = DBHandler:getRocketsSalesShopInfo()
    if endInfo.salesShopEndTime ~= endTime then
        data = 0
        DBHandler:resetSalesShopInfo() --活动时间不同，重置shopInfo
    else
        data = endInfo.salesInfo
    end

    if data >= 3 then
        return
    end
    local bLandscape = (not GameLevelUtil:isPortraitLevel())
    if(bLandscape ~= self.bLandscape) then
        if self.gameObject then
            Unity.GameObject.Destroy(self.gameObject)
        end
        if bLandscape then
            self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/RocketsSalesShop/BarSalesShopPop.prefab"))
        else
            self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/RocketsSalesShop/BarSalesShopPopPortrait.prefab"))
        end
        self.bLandscape = bLandscape
        self.transform = self.gameObject.transform

        LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
        
        self.popController = PopController:new(self.gameObject)
        local btn = self.transform:FindDeepChild("ButtonClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        self.fullLoadingGameObject = self.transform:FindDeepChild("FullLoading").gameObject
       
        self.itemsContainer = self.transform:FindDeepChild("ItemsContainer")
        self:updateLeftTime()
    end

    self:hideLoading()
    
    self.shopSkus = self:getShopSkus()
    
    self:refreshContent()

    self.transform:SetParent(LobbyScene.popCanvas, false)
    bIsInQueue = bIsInQueue or false
    self.popController:show(nil, nil, bIsInQueue)
    
    if ThemeLoader.themeKey ~= nil then
        SlotsGameLua.m_bReelPauseFlag = true
    end
end

function BarSalesShopPop:refreshContent()
    local itemCount = self.itemsContainer.childCount
    for i = 0, itemCount - 1 do
        local item = self.itemsContainer:GetChild(i)
        local button = item:FindDeepChild ("Button"):GetComponent(typeof(UnityUI.Button))
        -- local coinCountGo = item:FindDeepChild ("CoinCount").gameObject
        local getMoreCoins = item:FindDeepChild ("GetMoreCoins"):GetComponent(typeof(TextMeshProUGUI))
        local getCoinCountText = item:FindDeepChild("GetCoinCount"):GetComponent(typeof(TextMeshProUGUI))
        local priceText = item:FindDeepChild("BtnImg/Price"):GetComponent(typeof(TextMeshProUGUI))
        local goShadow = item:FindDeepChild("shadow").gameObject
        local unlock = item:FindDeepChild("Lock").gameObject
        local collect = item:FindDeepChild("Collect").gameObject
        unlock:SetActive(false)
        goShadow:SetActive(true)
        -- coinCountGo:SetActive(false)
        getMoreCoins.gameObject:SetActive(false)
        collect:SetActive(false)

        local productId = self.shopSkus[#self.shopSkus - i]
        local skuInfo = DBHandler:getSalesShopSkuInfo(BonusUtil.getRocketsSalesSkuInfo(productId,i+1),i+1)
        getCoinCountText.text = MoneyFormatHelper.numWithCommas(skuInfo.finalCoins)
        priceText.text = "$"..skuInfo.nDollar
        button.onClick:RemoveAllListeners()
        DelegateCache:addOnClickButton(button)
        button.onClick:AddListener(function()
            IabHandler:purchase(skuInfo)
            self:showLoading()
        end)
        
        if i < data then
            collect:SetActive(true)
        elseif i > data then
            unlock:SetActive(true)
            getMoreCoins.gameObject:SetActive(true)
            if i == 1 then
                getMoreCoins.text = "Let's Get Huge Offer"
            elseif i == 2 then
                getMoreCoins.text = "Let's Get Mega Offer"
            end
        else
            goShadow:SetActive(false)
            -- coinCountGo:SetActive(true)
        end
        local cardImage = item:FindDeepChild("CardsImage")
        local userLevel = PlayerHandler.nLevel
        local isActiveShow = false
        for i=1,#SlotsCardsHandler.m_albumTable do
            local status = SlotsCardsHandler:checkIsActiveTime(i)
            if not isActiveShow then
                isActiveShow = status
            end
        end
        if isActiveShow and (userLevel >= SlotsCardsManager.m_nUnlockLevel) then
            cardImage.gameObject:SetActive(true)
            self:setCardsContainer(item, skuInfo)
        else
            cardImage.gameObject:SetActive(false)
        end
    end
end

function BarSalesShopPop:Start()
    NotificationHandler:addObserver(self, "onPurchaseDoneNotifycation")
    NotificationHandler:addObserver(self, "onPurchaseFailedNotifycation")
end

function BarSalesShopPop:OnEnable()
    NotificationHandler:addObserver(self, "onPurchaseDoneNotifycation")
    NotificationHandler:addObserver(self, "onPurchaseFailedNotifycation")
end

function BarSalesShopPop:OnDisable()
    NotificationHandler:removeObserver(self)
end

function BarSalesShopPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)

    if ThemeLoader.themeKey ~= nil then
        SlotsGameLua.m_bReelPauseFlag = false
    end
end

--notification callback
function BarSalesShopPop:onPurchaseDoneNotifycation()
    self:hideLoading()
    --TODO 更新下一个button
    data = DBHandler.data.salesShop.salesInfo
    self:refreshContent()
    if data >= 3 then
        ViewScaleAni:Hide(self.transform.gameObject)
        if ThemeLoader.themeKey ~= nil then
            SlotsGameLua.m_bReelPauseFlag = false
        end
    end
end

function BarSalesShopPop:onPurchaseFailedNotifycation()
    self:hideLoading()
    CommonDialogBox:ShowSureUI("Purchase Failed")
end

function BarSalesShopPop:showLoading()
	self.fullLoadingGameObject:SetActive(true)
end

function BarSalesShopPop:hideLoading()
	self.fullLoadingGameObject:SetActive(false)
end

function BarSalesShopPop:getShopSkus()
    local nUserLevel = PlayerHandler.nLevel
    local fTotalPrice = DBHandler:getTotalIapPrice()

    local nType = 2

    if (nUserLevel < 100) and (fTotalPrice == 0) then
        nType = 1 -- 低等级并且没有购买过
    end

    if nUserLevel >= 100 then
        nType = 2
    end

    if nUserLevel >= 200 then
        nType = 3
    end
    
    if nUserLevel >= 300 then
        nType = 4
    end
    
    if nUserLevel >= 600 then
        nType = 5
    end

    if fTotalPrice > 5 then
        if nType < 2 then
            nType = 2
        end
    end

    if fTotalPrice > 20 then
        if nType < 3 then
            nType = 3
        end
    end

    if fTotalPrice > 50 then
        if nType < 4 then
            nType = 4
        end
    end

    if fTotalPrice > 100 then
        if nType < 5 then
            nType = 5
        end
    end

    local listShopSkus = {"com.slots.goldfever.coins002", "com.slots.goldfever.coins002",
                        "com.slots.goldfever.coins002"}

    if nType == 1 then
        listShopSkus = {"com.slots.goldfever.coins003", "com.slots.goldfever.coins003",
                        "com.slots.goldfever.coins003"}
    elseif nType == 2 then
        listShopSkus = {"com.slots.goldfever.coins006", "com.slots.goldfever.coins006",
                        "com.slots.goldfever.coins006"}
    elseif nType == 3 then
        listShopSkus = {"com.slots.goldfever.coins009", "com.slots.goldfever.coins009",
                        "com.slots.goldfever.coins009"}
    elseif nType == 4 then
        listShopSkus = {"com.slots.goldfever.coins020", "com.slots.goldfever.coins020",
                        "com.slots.goldfever.coins020"}
    elseif nType == 5 then
        listShopSkus = {"com.slots.goldfever.coins100", "com.slots.goldfever.coins100",
                        "com.slots.goldfever.coins100"}
    end

    return listShopSkus
end

function BarSalesShopPop:updateLeftTime()
    local co = StartCoroutine( function()
        local salesActiveRatioArray, endTime = BonusUtil.rocketsSalesShopRatio()

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
                    SaleAdEntry:onPurchaseDoneNotifycation()
                end
            end
        end
    end)
end

function BarSalesShopPop:setCardsContainer(parent, skuInfo)
    local cardText = parent:FindDeepChild("SlotsCardInfoText"):GetComponent(typeof(TextMeshProUGUI))
    local stars = parent:FindDeepChild("Stars")
    for i=1,#SlotsCardsGiftManager.m_skuToSlotsCardsPack do
        if skuInfo.productId == SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].productId then
            cardText.text = "Min " .. SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].minCardCount .. " of"
            for j = 0, stars.childCount - 1 do
                if j < SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].starCount then
                    stars:GetChild(j).gameObject:SetActive(true)
                else
                    stars:GetChild(j).gameObject:SetActive(false)
                end
            end
            break
        end
    end
end