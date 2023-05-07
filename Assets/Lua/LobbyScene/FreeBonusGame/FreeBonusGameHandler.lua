require("Lua/LobbyScene/FreeBonusGame/FreeBonusMultiplier")

FreeBonusGameHandler = {}
FreeBonusGameHandler.DATAPATH = Unity.Application.persistentDataPath .. "/FreeBonusGameHandler.txt"
FreeBonusGameHandler.fBlueBonusDiffTime = 15 * 60
FreeBonusGameHandler.fRedBonusDiffTime = 60 * 60 * 3
FreeBonusGameHandler.N_MEGABALL_MAX = 3
FreeBonusGameHandler.N_LUCKYWHEEL_MAX = 5
FreeBonusGameHandler.listExpValue = {20, 200, 2000, 10000, 50000, 500000} -- 1 2 3 4 5 10 20
FreeBonusGameHandler.listMultiplier = {1, 2, 3, 4, 5, 10}

if GameConfig.PLATFORM_EDITOR then
    FreeBonusGameHandler.fBlueBonusDiffTime = 60
    FreeBonusGameHandler.fRedBonusDiffTime = 60
end

function FreeBonusGameHandler:Init()
    FreeBonusMultiplier:Init()

    if CS.System.IO.File.Exists(self.DATAPATH) then
        local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
        local data = rapidjson.decode(strData)
        self.data = data
    else
        self.data = self:GetDbInitData()
    end
    
    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
end

function FreeBonusGameHandler:SaveDb()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function FreeBonusGameHandler:GetDbInitData()
    local data = {}
    data.nDayTimeStamp = 0
    data.nMegaballCount = 0
    data.nLuckyWheelCount = 0
    data.nRedBonusTime = 0
    data.nBlueBonusTime = 0
    return data
end

function FreeBonusGameHandler:ResetMegaballBonusCount()
    self.data.nMegaballCount = 0
    self:SaveDb()
end

function FreeBonusGameHandler:GetMegaballBonusCount()
    return self.data.nMegaballCount
end

function FreeBonusGameHandler:GetLuckyWheelCount()
    return self.data.nLuckyWheelCount
end

function FreeBonusGameHandler:ResetLuckyWheelCount()
    self.data.nLuckyWheelCount = 0
    if self.data.nMegaballCount < self.N_MEGABALL_MAX then
        self.data.nMegaballCount = self.data.nMegaballCount + 1
    end
    self:SaveDb()
end

function FreeBonusGameHandler:SetRedBonusNetTime(netTime)
    self.data.nRedBonusTime = netTime
    if self.data.nLuckyWheelCount < self.N_LUCKYWHEEL_MAX then
        self.data.nLuckyWheelCount = self.data.nLuckyWheelCount + 1
    end
    self:SaveDb()
    EventHandler:Brocast("PlayFreeBonusGoldenChest")
end

function FreeBonusGameHandler:SetBlueBonusNetTime(netTime)
    self.data.nBlueBonusTime = netTime
    self:SaveDb()
    EventHandler:Brocast("PlayFreeBonusSilverChest")
end

function FreeBonusGameHandler:CheckCouldPlayMegaballBonus()
    return self.data.nMegaballCount >= self.N_MEGABALL_MAX
end

function FreeBonusGameHandler:CheckCouldPlayLuckyWheel()
    return self.data.nLuckyWheelCount >= self.N_LUCKYWHEEL_MAX
end

function FreeBonusGameHandler:CheckCouldPlayRedBonus()
    return TimeHandler:GetServerTimeStamp() - self.data.nRedBonusTime >= self.fRedBonusDiffTime
end

function FreeBonusGameHandler:CheckCouldPlayBlueBonus()
    return TimeHandler:GetServerTimeStamp() - self.data.nBlueBonusTime >= self.fBlueBonusDiffTime
end

function FreeBonusGameHandler:getBasePrize()
    local nBaseCoin = FormulaHelper:GetAddMoneyBySpendDollar(1)
    return nBaseCoin
end

function FreeBonusGameHandler:getMegaBallBaseBonus()
    local nBaseCoin = self:getBasePrize()
    local listCoefs = {0.02, 0.025, 0.03, 0.035, 0.04, 0.05}
    local probs = {50, 60, 60, 50, 30, 20}
    local index = LuaHelper.GetIndexByRate(probs)
    local fcoef = listCoefs[index]
    nBaseCoin = nBaseCoin * fcoef -- 0.035
    return nBaseCoin
end

function FreeBonusGameHandler:getRedBonusBaseBonus()
    local nBaseCoin = self:getBasePrize()
    local listCoefs = {0.025, 0.03, 0.035, 0.04, 0.045, 0.05}
    local probs = {10, 80, 50, 30, 20, 10}
    local index = LuaHelper.GetIndexByRate(probs)
    local fcoef = listCoefs[index]
    nBaseCoin = nBaseCoin * fcoef -- 0.035
    return nBaseCoin
end

function FreeBonusGameHandler:getBlueBonusBaseBonus()
    local nBaseCoin = self:getBasePrize()
    local listCoefs = {0.008, 0.009, 0.01, 0.015, 0.02, 0.025}
    local probs = {60, 55, 50, 50, 30, 10}
    local index = LuaHelper.GetIndexByRate(probs)
    local fcoef = listCoefs[index]
    nBaseCoin = nBaseCoin * fcoef -- 0.015
    return nBaseCoin
end
