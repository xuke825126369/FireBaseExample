DailyBonusDataHandler = {}
DailyBonusDataHandler.DATAPATH = Unity.Application.persistentDataPath .. "/DailyBonusDataHandler.txt"
DailyBonusDataHandler.data = {}
DailyBonusDataHandler.DAILY_BONUS_MAX = 30
DailyBonusDataHandler.tableBaoXiangRewardDaysIndex = {7, 15, 22, 30}

DailyBonusDataHandler.nRewardType = {
    Coins = 1,
    SlotsCards = 2,
    VipPoint = 3,
    Activty = 4,
    Diamond = 5,
    LoungePoints = 6
}

DailyBonusDataHandler.MAP_CHESTREWARD = { 
    { 
        { nType = DailyBonusDataHandler.nRewardType.Coins, fRatio = 8 },
    },
    { 
        { nType = DailyBonusDataHandler.nRewardType.Coins, fRatio = 10 },
    },
    { 
        { nType = DailyBonusDataHandler.nRewardType.Coins, fRatio = 12 },
    },
    { 
        { nType = DailyBonusDataHandler.nRewardType.Coins, fRatio = 20 },
    },
}

DailyBonusDataHandler.MAP_DAILYREWARD = {
    { { nType = DailyBonusDataHandler.nRewardType.Coins, fRatio = 1 } },
    { { nType = DailyBonusDataHandler.nRewardType.Coins, fRatio = 2 } },
    { { nType = DailyBonusDataHandler.nRewardType.Coins, fRatio = 3 } },
    { { nType = DailyBonusDataHandler.nRewardType.Coins, fRatio = 4 } },
    { { nType = DailyBonusDataHandler.nRewardType.Coins, fRatio = 5 } },
    { { nType = DailyBonusDataHandler.nRewardType.Coins, fRatio = 6 },},
    { { nType = DailyBonusDataHandler.nRewardType.Coins, fRatio = 7 },},
}

function DailyBonusDataHandler:Init()
    if CS.System.IO.File.Exists(self.DATAPATH) then
        local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
        local data = rapidjson.decode(strData)
        self.data = data
    else
        self.data = self:GetDbInitData()
    end
    
    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
    self:CheckSeasonEnd()
end

function DailyBonusDataHandler:SaveDb()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function DailyBonusDataHandler:GetDbInitData()
    local data = {}
    data.nLoginDaysCount = 0
    data.mapChestRewardFlag = {false, false, false, false}
    data.lastLoginTimeStamp = 0
    return data
end

function DailyBonusDataHandler:CheckSeasonEnd()
    if self.data.nLoginDaysCount >= self.DAILY_BONUS_MAX then
        self.data.nLoginDaysCount = 0
        self.data.mapChestRewardFlag = {false, false, false, false}
        self:SaveDb()
    end
end

function DailyBonusDataHandler:getChestRewardFlag(nIndex)
    return self.data.mapChestRewardFlag[nIndex]
end

function DailyBonusDataHandler:setDailyBonusReward()
    self.data.nLoginDaysCount = self.data.nLoginDaysCount + 1
    self.data.lastLoginTimeStamp = TimeHandler:GetDayBeginTimeStamp()

    local nCurrentDay = self:GetCurrentDayIndex()
    local mapType = self:getCurrentDayReward(nCurrentDay)
    local nLength = LuaHelper.tableSize(mapType)

    for j = 1, nLength do
        local nCoins = DailyBonusDataHandler:getBaseCoinsPrize() * mapType[j].fRatio
        PlayerHandler:AddCoin(nCoins)
    end

    self:SaveDb()
end

function DailyBonusDataHandler:getChestReward(nIndex)
    local mapType = self.MAP_CHESTREWARD[nIndex]
    local nLength = LuaHelper.tableSize(mapType)
    for j = 1, nLength do
        local nCoins = self:getBaseCoinsPrize() * mapType[j].fRatio
        PlayerHandler:AddCoin(nCoins)
    end

    self.data.mapChestRewardFlag[nIndex] = true
    self:SaveDb()
end

function DailyBonusDataHandler:getDailyBonusLoginDaysCount()
    return self.data.nLoginDaysCount
end

function DailyBonusDataHandler:GetCurrentDayIndex()
    return self.data.nLoginDaysCount % 7 + 1
end

-- 取商店1美元的十分之一 coins为参考依据
function DailyBonusDataHandler:getBaseCoinsPrize()
    local nCoins = 120000 * FormulaHelper:getVipAndLevelBonusMul()
    return nCoins
end

function DailyBonusDataHandler:getCurrentDayReward(nIndex)
    return self.MAP_DAILYREWARD[nIndex]
end

-- 出勤记录
function DailyBonusDataHandler:orDifferentDay()
    local nLastLoginDaysTimeStamp = self.data.lastLoginTimeStamp
    return nLastLoginDaysTimeStamp ~= TimeHandler:GetDayBeginTimeStamp()
end
