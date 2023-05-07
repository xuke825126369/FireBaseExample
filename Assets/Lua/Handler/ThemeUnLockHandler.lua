ThemeUnLockHandler = {}
ThemeUnLockHandler.dbName = "ThemeUnLockHandler"

function ThemeUnLockHandler:Init()
    self.data = LocalDbHandler.data.mThemeUnLockHandlerData
    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb() 
end

function ThemeUnLockHandler:SaveDb()
    LocalDbHandler.data.mThemeUnLockHandlerData = self.data
    LocalDbHandler:SaveDb()
end

function ThemeUnLockHandler:GetDbInitData()
    local data = {}
    data.feature_unlockall_beginTime = 0
    data.feature_unlockall_endTime = 0
    return data
end

function ThemeUnLockHandler:SetAllThemeUnLock(beginTime, endTime)
    if self:orUnLockAllTheme() then
        if self.data.feature_unlockall_beginTime > beginTime then
            self.data.feature_unlockall_beginTime = beginTime
        end

        if self.data.feature_unlockall_endTime < endTime then
            self.data.feature_unlockall_endTime = endTime
        end
    else
        self.data.feature_unlockall_beginTime = beginTime
        self.data.feature_unlockall_endTime = endTime
    end

    self:SaveDb()
end

--------------------------------------------------------
function ThemeUnLockHandler:orUnLockAllTheme()
    local nTimeStamp = TimeHandler:GetServerTimeStamp()
    if nTimeStamp >= self.data.feature_unlockall_beginTime and nTimeStamp <= self.data.feature_unlockall_endTime then
        return true
    end
    return false
end
