local ReturnRateManager = {}

ReturnRateManager.m_enumReturnRateType = enumReturnRateTYPE.enumReturnType_Rate95

function ReturnRateManager:InitGameSetReturnRate()
    self.m_enumReturnRateType = enumReturnRateTYPE.enumReturnType_Rate95
end

function ReturnRateManager:JudgeReturnRatePerSpin()
    local returnType = ReturnRateManager:getReturnRateType()
    if self.m_enumReturnRateType ~= returnType then
        self.m_enumReturnRateType = returnType
        
        if Debug.bOpen then
            Debug.Log("当前返还率："..ReturnRateManager:GetReturnRateName(self.m_enumReturnRateType))
        end
    end 
end

function ReturnRateManager:getReturnRateType()
    local returnRateType = enumReturnRateTYPE.enumReturnType_None
    local nTypeIndex = ThemeHelper:getReturnRateIndex()
    if nTypeIndex == 1 then
        returnRateType = enumReturnRateTYPE.enumReturnType_Rate50
    elseif nTypeIndex == 2 then
        returnRateType = enumReturnRateTYPE.enumReturnType_Rate95
    elseif nTypeIndex == 3 then
        returnRateType = enumReturnRateTYPE.enumReturnType_Rate200
    else
        Debug.Assert(false)
    end
    
	return returnRateType
end

function ReturnRateManager:GetActualReturnRate()
    local fWinCoins = LevelDataHandler.m_Data.fLastMonthWinCoins
    local fUseCoins = LevelDataHandler.m_Data.fLastMonthUseCoins
    return fWinCoins / fUseCoins
end 

function ReturnRateManager:GetReturnRateName(m_enumSimRateType)
    for k, v in pairs(enumReturnRateTYPE) do
        if v == m_enumSimRateType then
            return k
        end
    end

    Debug.Assert(false, "返还率类型有无")
end

function ReturnRateManager:PrintActualReturnRate()
    if not Debug.bOpen then return end
    local nTotalSpinNum = LevelDataHandler.m_Data.nLastMonthSpinNum
    local fWinCoins = LevelDataHandler.m_Data.fLastMonthWinCoins
    local fUseCoins = LevelDataHandler.m_Data.fLastMonthUseCoins
    
    local fWinRate = math.floor(fWinCoins / fUseCoins * 100)
    Debug.Log("总共Spin: "..nTotalSpinNum.."次, 消耗金币数："..fUseCoins..", 赚的金币数："..fWinCoins..", 实际返还率："..fWinRate.."%")

    local fWinMoneyCount = PlayerHandler.nGoldCount - LevelDataHandler.nInitGoldMoneyCount
    local fWinRate = fWinMoneyCount / LevelDataHandler.nInitGoldMoneyCount + 1.0
    local fWinRate = math.floor(fWinRate * 100)
    Debug.Log(string.format("初始金币: %s, 本次进入关卡实际返还率: %s%%, 赢了多少钱: %s", LevelDataHandler.nInitGoldMoneyCount, fWinRate, MoneyFormatHelper.numWithCommas(fWinMoneyCount)))

end 

return ReturnRateManager