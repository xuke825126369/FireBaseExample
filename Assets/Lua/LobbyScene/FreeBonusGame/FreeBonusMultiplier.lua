FreeBonusMultiplier = {}
FreeBonusMultiplier.listExpValue = {20, 200, 2000, 10000, 50000, 500000} -- 1 2 3 4 5 10 20
FreeBonusMultiplier.listMultiplier = {1, 2, 3, 4, 5, 10}

-- 首次进游戏大厅的时候调用
function FreeBonusMultiplier:Init()
    self:CheckFreeBonusTime()
    EventHandler:AddListener("UseCoins", self)
    TimeHandler:AddListener(self.CheckFreeBonusTime, self)
end

-- 每一分钟检查一下是否到另一天了
function FreeBonusMultiplier:CheckFreeBonusTime()
    local daySec = TimeHandler:GetDayBeginTimeStamp()
    if daySec ~= CommonDbHandler.data.SpinMultiplierParam.daySecond then
        CommonDbHandler.data.SpinMultiplierParam = {daySecond = daySec, fExp = 0}
        CommonDbHandler:SaveDb()
    end
end

function FreeBonusMultiplier:orDifferentDay()
    local recordDateTime = CS.TimeUtility.GetUTCTimeFromTimeStamp(self.data.nThisDay_TimeStamp)
    local nowDateTime = TimeHandler:GetServerUtcDateTimeNow()
    return nowDateTime.Day ~= recordDateTime.Day or nowDateTime.Month ~= recordDateTime.Month or nowDateTime.Year ~= recordDateTime.Year
end

function FreeBonusMultiplier:getMultiplier()
    local param = CommonDbHandler.data.SpinMultiplierParam
    local fExp = param.fExp
    local nMul = 10
    local fProgress = 1.0
    local cnt = #self.listExpValue
    local nIndex = 1
    if fExp <= self.listExpValue[cnt] then
        for i = 1, cnt do
            if fExp <= self.listExpValue[i] then
                nIndex = i
                nMul = self.listMultiplier[i]
                if i == 1 then
                    fProgress = fExp / self.listExpValue[i]
                else
                    fProgress = (fExp - self.listExpValue[i-1]) / self.listExpValue[i]
                end
                break
            end
        end
    else
        nIndex = 6
        nMul = self.listMultiplier[nIndex]
        fProgress = 1.0
    end
    
    local fSumProgress = (nIndex - 1 + fProgress) / 6
    return nMul, fSumProgress, nIndex
end

function FreeBonusMultiplier:UseCoins(data)
    local nTotalBet = data.nTotalBet
    local fAddExp = nTotalBet / self:getOneDollarCoins() * 10
    fAddExp = LuaHelper.Clamp(fAddExp, 1, 100)
    CommonDbHandler.data.SpinMultiplierParam.fExp = CommonDbHandler.data.SpinMultiplierParam.fExp + fAddExp
    CommonDbHandler:SaveDb()
end

function FreeBonusMultiplier:getOneDollarCoins()
    return FormulaHelper:GetAddMoneyBySpendDollar(1)
end
