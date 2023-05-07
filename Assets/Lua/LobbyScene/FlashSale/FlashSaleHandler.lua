FlashSaleHandler = {}

function FlashSaleHandler:Init()
    self.data = LocalDbHandler.data.mFlashSaleHandlerData
    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
end

function FlashSaleHandler:SaveDb()
    LocalDbHandler.data.mFlashSaleHandlerData = self.data
    LocalDbHandler:SaveDb()
end

function FlashSaleHandler:GetDbInitData()
    local data = {}
    data.nSaleBeginTimeStamp = 0
    data.nSaleEndTimeStamp = 0
    data.productId = ""
    data.nSaleMultuile = 0
    return data
end

function FlashSaleHandler:InitFlashSales()
    if self:orCanSetUpFlashSale() then
        self:SetThisFlashSaleInfo()
    end
end

function FlashSaleHandler:SetThisFlashSaleInfo()
    local nBuyIndex = math.random(1, #AllBuyCFG)
    local nSaleMultuile = math.random(2, 20)
    local nNextOffsetDays = math.random(3, 7)

    Debug.Assert(nSaleMultuile >= 2)
    self.data.nSaleMultuile = nSaleMultuile
    self.data.productId = AllBuyCFG[nBuyIndex].productId
    self.data.nSaleBeginTimeStamp = TimeHandler:GetServerTimeStamp() + 24 * 3600 * nNextOffsetDays
    self.data.nSaleEndTimeStamp = self.data.nSaleBeginTimeStamp + 24 * 3600 * math.random(1, 6)
    
    self:SaveDb()
end

function FlashSaleHandler:orCanSetUpFlashSale()
    return PlayerHandler.nRecharge > 0 and TimeHandler:GetServerTimeStamp() > self.data.nSaleEndTimeStamp
end

function FlashSaleHandler:orInFlashSale()
    if PlayerHandler.nRecharge == 0 then
        return false
    end
        
    local nNowTimeStamp = TimeHandler:GetServerTimeStamp()
    if nNowTimeStamp >= self.data.nSaleBeginTimeStamp and nNowTimeStamp < self.data.nSaleEndTimeStamp then
        return true
    end

    return false
end

function FlashSaleHandler:Show()
    if BuyHandler:orHaveRecharge() then
        if FlashSaleHandler:orInFlashSale() then
            PopStackViewHandler:Show(NoCoinsTimeLimitHugePackPop)
        else
            PopStackViewHandler:Show(NoCoinsDealPop)
        end
    else
        PopStackViewHandler:Show(FirstIAPTipPop)
    end
end

