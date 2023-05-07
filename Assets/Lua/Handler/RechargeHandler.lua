RechargeHandler = {}

function RechargeHandler:Init()
    self.data = PlayerHandler.data.mRechargeHandlerData
    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
end

function RechargeHandler:SaveDb()
    setmetatable(self.data.tableRechargeRecord, {__jsontype = "array"})
    PlayerHandler.data.mRechargeHandlerData = self.data
    PlayerHandler:SaveDb()
end

function RechargeHandler:GetDbInitData()
    local data = {}
    data.nLastRechargeTimeStamp = TimeHandler:GetServerTimeStamp()
    data.tableRechargeRecord = {}
    return data
end

function RechargeHandler:RecordLastRechargeTime(skuInfo)
    self.data.nLastRechargeTimeStamp = TimeHandler:GetServerTimeStamp()
        
    local rechargeInfo = {
        nTimeStamp = TimeHandler:GetServerUtcDateTimeNow():ToString(),
        nDollar = skuInfo.nDollar,
        productId = skuInfo.productId,
        nType = skuInfo.nType
    }
    table.insert(self.data.tableRechargeRecord, rechargeInfo)
    while #self.data.tableRechargeRecord > 10 do
        table.remove(self.data.tableRechargeRecord, 1)
    end
    self:SaveDb()
end

function RechargeHandler:orInRechargeRequestTime()
    if PlayerHandler.nLevel <= GameConst.nInitCashBackLevel then
        return false
    end
    
    local bRequest, fPercent = self:orInLevelLimitRechargeRequestTime()
    if bRequest == false then
    bRequest, fPercent = self:orInCoinsCountLimitRechargeRequestTime()
    end
    if bRequest == false then
    bRequest, fPercent = self:orInLgoinCountLimitRechargeRequestTime()
    end
    return bRequest, fPercent
end

-- 最大金币数量付费请求
function RechargeHandler:orInCoinsCountLimitRechargeRequestTime()
    local nRechargeCount = PlayerHandler.nRecharge + 1
    local nGoldCountLimit = FormulaHelper:GetAddMoneyBySpendDollar(nRechargeCount) * 50
    local bRequest = PlayerHandler.nGoldCount > nGoldCountLimit
    local fPercent = (PlayerHandler.nGoldCount - nGoldCountLimit) / nGoldCountLimit * math.random()
    return bRequest, fPercent
end

-- 登陆次数付费请求
function RechargeHandler:orInLgoinCountLimitRechargeRequestTime()
    local nPassDays = (TimeHandler:GetServerTimeStamp() - self.data.nLastRechargeTimeStamp) // (3600 * 24)
    local bRequest = nPassDays > 60
    local fPercent = (nPassDays - 60) / 10 * math.random()
    return bRequest, fPercent
end

-- 等级付费请求
function RechargeHandler:orInLevelLimitRechargeRequestTime()
    local nRechargeCount = PlayerHandler.nLevel
    nRechargeCount = math.max(1, nRechargeCount)
    local bRequest = nRechargeCount > PlayerHandler.nRecharge
    local fPercent = (nRechargeCount - PlayerHandler.nRecharge) / nRechargeCount * math.random()
    return bRequest, fPercent
end
