PlayerHandler = {}
function PlayerHandler:Init()
    self.data = UserInfoHandler.data.mPlayerHandlerData
    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())

    local mt = {    
        __index = function(table, key)
            local value = self.data[key]
            Debug.Assert(value ~= nil, "不存在的服务器数据字段: "..key)
            return value
        end
    }
    setmetatable(self, mt)
    self:SaveDb()
end

function PlayerHandler:SaveDb()
    UserInfoHandler.data.mPlayerHandlerData = self.data
	UserInfoHandler:SaveDb()
end

function PlayerHandler:GetDbInitData()
    local data = {}

    ----------------------------------- 基础数据 -------------------------------
    data.UniqueIdentifier = ""
    data.nUserId = ""
    data.nVersion = 1
    data.nGoldCount = GameConst.nInitGoldCount		--金币
    data.nSapphireCount = GameConst.nInitSapphireCount -- 蓝宝石数量
    data.nLevel = GameConst.nMinLevel			--玩家等级
    data.nLevelExp = 0	 -- 当前等级 经验值
    data.nRecharge = 0	-- 当前的充值金额
    data.nVipPoint = 0
    data.strAppVersion = "" --下载新版本奖励
    
    data.nLoginCount = 0 -- 第一次登录 同步玩家网络数据
    data.nLoginDayCount = 0 -- 登录的天数
    data.nTodayLoginCount = 0 --今天 登录的次数，新用户今天第一次登录送金币
    data.nFirstLoginTimeStamp = 0 --第一次登录的时间
    data.nLastLoginTimeStamp = 0 --上一次登录的时间
    
    data.currentSkuInfo = {}
    ----------------------------------- 活动相关数据 -------------------------------
    data.mCommonDbHandlerData = {}
    data.mRechargeHandlerData = {}
    return data
end

function PlayerHandler:SyncNetData(netData)
    if netData == nil then
        return
    end
    
    if netData.nVersion == nil then
        return
    end

    local bSyncData = false
    if self.nVersion < netData.nVersion then
        bSyncData = true
    end

    if self.UniqueIdentifier ~= netData.UniqueIdentifier then
        bSyncData = true
    end     

    if bSyncData then
        for k, v in pairs(netData) do
            self.data[k] = v
        end
        self:SaveDb()
    end

end

function PlayerHandler:orExistAccount()
    if self.data.UniqueIdentifier and self.data.UniqueIdentifier ~= "" then
        return true
    end

    return false
end

function PlayerHandler:AddDataVersion()
    self.data.nVersion = self.data.nVersion + 1
end

function PlayerHandler:SetAppVersion()
    self:AddDataVersion()
    self.data.strAppVersion = Unity.Application.version
    self:SaveDb()
end

function PlayerHandler:SetAccountInfo(uid)
    Debug.Assert(uid)
    self:AddDataVersion()
    self.data.UniqueIdentifier = uid
    self:SaveDb()
end

function PlayerHandler:SetUserId(nUserId)
    self:AddDataVersion()
    self.data.nUserId = nUserId
    self:SaveDb()
end

function PlayerHandler:SetLastLoginTime()
    self:AddDataVersion()
    self.data.nLastLoginTimeStamp = TimeHandler:GetServerTimeStamp()
    self:SaveDb()
end

function PlayerHandler:SetFirstLoginTime()
    self:AddDataVersion()
    if self.data.nFirstLoginTimeStamp == 0 then
        self.data.nFirstLoginTimeStamp = TimeHandler:GetServerTimeStamp()
    end
    self:SaveDb()
end

function PlayerHandler:ResetTodayLoginCount()
    self:AddDataVersion()
    self.data.nTodayLoginCount = 0
    self:SaveDb()
end

function PlayerHandler:AddTodayLoginCount()
    self:AddDataVersion()
    self.data.nTodayLoginCount = self.data.nTodayLoginCount + 1
    self:SaveDb()
end

function PlayerHandler:AddLoginDayCount()
    self:AddDataVersion()
    self.data.nLoginDayCount = self.data.nLoginDayCount + 1
    self:SaveDb()
end

function PlayerHandler:AddLoginCount()
    self:AddDataVersion()
    self.data.nLoginCount = self.data.nLoginCount + 1
    self:SaveDb()
end

function PlayerHandler:AddRecharge(nDollar)
    self:AddDataVersion()
    self.data.nRecharge = self.data.nRecharge + nDollar
    self:SaveDb()

    local nAddVipPoint = FormulaHelper:GetAddVipPointBySpendDollar(nDollar)
    self:AddVipPoint(nAddVipPoint)
end

function PlayerHandler:AddVipPoint(nVipPoint)
    self:AddDataVersion()
    self.data.nVipPoint = self.data.nVipPoint + nVipPoint
    self:SaveDb()
end

function PlayerHandler:AddCoin(nCount)
    self:AddDataVersion()
    self.data.nGoldCount = self.data.nGoldCount + nCount
    self.data.nGoldCount = self.data.nGoldCount * 10 // 10 --防止小数点
    self:SaveDb()
end

function PlayerHandler:AddSapphire(nCount)
    self:AddDataVersion()
    self.data.nSapphireCount = self.data.nSapphireCount + nCount
    self:SaveDb()
end

function PlayerHandler:AddLevelExp(nExp)
    self:AddDataVersion()

    self.data.nLevelExp = math.max(0, self.data.nLevelExp)
    nExp = math.max(0, nExp)

    self.data.nLevelExp = self.data.nLevelExp + nExp
    local nSumExp = FormulaHelper:GetSumLevelExp(self.data.nLevel)
    nSumExp = math.max(1, nSumExp)

    if self.data.nLevelExp >= nSumExp then
        self.data.nLevelExp = self.data.nLevelExp - nSumExp
        self.data.nLevel = self.data.nLevel + 1
        nSumExp = FormulaHelper:GetSumLevelExp(self.data.nLevel)
        nSumExp = math.max(1, nSumExp)
    end

    if self.data.nLevelExp >= nSumExp then
        self.data.nLevel = self.data.nLevel + 1
        self.data.nLevelExp = 0
    end     

    self:SaveDb()
end







