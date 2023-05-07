-- 各种值的计算公式类
FormulaHelper =  {}

-- 得到VIP等级的总Vip点数
function FormulaHelper:GetSumVipRankPoint(nVipLevel)
    if nVipLevel <= 1 then
        return 0
    else
        local nSumExp = 180 * CS.System.Math.Pow(6, nVipLevel - 1) * 10 // 10
        return nSumExp
    end
end

-- 得到当前等级升级后，可获取到的Vip点数
function FormulaHelper:GetAddVipPointByLevelUp()
    return PlayerHandler.nLevel // 10 * 1 + 1
end

-- 得到当前等级升级后，可获取到的金币数量
function FormulaHelper:GetAddMoneyCountByLevelUp()
    return PlayerHandler.nLevel * 30000
end

function FormulaHelper:GetTotalBetList(nLevel)
    if not nLevel then
        nLevel = PlayerHandler.nLevel
    end 
    
    local nAddCoef = 0
    if nLevel < 200 then
        nAddCoef = 1.5 + (nLevel // 20) * 0.2
    else
        nAddCoef = 1.5 + 200 // 20 * 0.2
    end 

    local listCurTotalBet = {}  
    local nMinTotalBet = (1.0 + nLevel // 2) * 10000
    if LoungeHandler:isLoungeMember() then
        nMinTotalBet = nMinTotalBet * 1.2
        nAddCoef = nAddCoef * 1.2
    end

    table.insert(listCurTotalBet, nMinTotalBet)
    local nPreTotalBet = nMinTotalBet
    for i = 1, 4 do
        local nValue = nPreTotalBet * nAddCoef // 1000 * 1000
        table.insert(listCurTotalBet, nValue)
        nPreTotalBet = nValue
    end

    return listCurTotalBet
end

-- 得到总经验值
function FormulaHelper:GetSumLevelExp(nLevel)
    return 200 + 100 * nLevel
end

-- 消耗下注数可获得的经验值
function FormulaHelper:GetAddLevelExp(nTotalBetIndex)
    Debug.Assert(nTotalBetIndex >= 1, nTotalBetIndex)
    local nAddExp = 10 * nTotalBetIndex
    if LoungeHandler:isLoungeMember() then
        local nAddCoef = 2
        nAddExp = LuaHelper.GetInteger(nAddExp * nAddCoef)
    end
    return nAddExp
end

-- 充值可得到的金币
function FormulaHelper:GetAddMoneyBySpendDollar(nDollar)
    local fCoef = 1.0 + math.sqrt(nDollar)
    local nCount = nDollar * fCoef * 3600000 * self:getVipAndLevelBonusMul() --基础金币
    nCount = nCount // 1000 * 1000
    nCount = LuaHelper.GetInteger(nCount)
    return nCount
end

-- 充值可得到的蓝宝石钻石
function FormulaHelper:GetAddSapphireBySpendDollar(nDollar)
    local nCount = nDollar * 30 * FormulaHelper:getVipAndLevelBonusMul()
    nCount = LuaHelper.GetInteger(nCount)
    return nCount
end

-- 充值可得到的Vip点数
function FormulaHelper:GetAddVipPointBySpendDollar(nDollar)
    local nCount = nDollar * 20 * 10 // 10
    nCount = LuaHelper.GetInteger(nCount)
    return nCount
end

-- 充值可得到的Vip点数
function FormulaHelper:GetAddLoungePointBySpendDollar(nDollar)
    local nCount = nDollar * 120 * 10 // 10
    nCount = LuaHelper.GetInteger(nCount)
    return nCount
end

function FormulaHelper:getLevelMultiplier()
    local userLevel = PlayerHandler.nLevel
    local levelMultiplier =  1 + userLevel // 20
    levelMultiplier = math.min(6, levelMultiplier)
    return levelMultiplier
end

function FormulaHelper:getVipAndLevelBonusMul()
    return self:getLevelMultiplier() * VipHandler:GetVipCoefInfo()
end


