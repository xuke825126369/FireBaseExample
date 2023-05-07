TimeOutGenerator = {}
function TimeOutGenerator:New(fInternalTime)
    local temp = {}
    self.__index = self
    setmetatable(temp, self)
    temp:Init(fInternalTime)
    return temp
end

function TimeOutGenerator:Init(fInternalTime)
    self.fLastUpdateTime = 0
    self.fInternalTime = fInternalTime
    if not self.fInternalTime then
        self.fInternalTime = 1.0
    end
end 

function TimeOutGenerator:orTimeOut()
    if Unity.Time.time - self.fLastUpdateTime > self.fInternalTime then
        self.fLastUpdateTime = Unity.Time.time
        return true
    end

    return false
end

-------------------------------------------------------------------------------------
TimeHandler = {}
TimeHandler.nServerTimeStamp = 0
TimeHandler.mapUpdateFunc = {}

function TimeHandler:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end
    
    local go = Unity.GameObject()
    go.name = "TimeHandler"
    LuaAutoBindMonoBehaviour.Bind(go, self)
    self.transform = go.transform
    
    self.nServerTimeStamp = 0
    self.mTimeOutGenerator = TimeOutGenerator:New()
    self:PrintTime()
end

function TimeHandler:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self.nServerTimeStamp = self.nServerTimeStamp + 1
        for k, v in pairs(self.mapUpdateFunc) do
            k(v)
        end
    end
end

function TimeHandler:GetTimeStamp()
    return CS.TimeUtility.GetTimeStampFromLocalTime(CS.System.DateTime.Now)
end

function TimeHandler:SetServerTimeStamp(nServerTimeStamp)
    self.nServerTimeStamp = nServerTimeStamp
    self:PrintTime()
end

function TimeHandler:GetServerTimeStamp()
    return self.nServerTimeStamp
end

function TimeHandler:PrintTime()
    Debug.LogWithColor("当前服务器时间:"..TimeHandler:GetServerLocalDateTimeNow():ToString())
    Debug.LogWithColor("当前本地时间:"..CS.System.DateTime.Now:ToString())
end

function TimeHandler:AddListener(func, instance)
    func(instance)
    self.mapUpdateFunc[func] = instance
end

function TimeHandler:RemoveListener(func, instance)
    self.mapUpdateFunc[func] = nil
end

----------------------------------------------------------------------------
function TimeHandler:GetServerLocalDateTimeNow()
    return CS.TimeUtility.GetLocalTimeFromTimeStamp(self.nServerTimeStamp)
end

function TimeHandler:GetServerUtcDateTimeNow()
    return CS.TimeUtility.GetUTCTimeFromTimeStamp(self.nServerTimeStamp)
end

function TimeHandler:orDifferentDay(fLastDayTimeStamp)
    local recordDateTime = CS.TimeUtility.GetLocalTimeFromTimeStamp(fLastDayTimeStamp)
    local nowDateTime = TimeHandler:GetServerLocalDateTimeNow()
    if nowDateTime.Day ~= recordDateTime.Day or nowDateTime.Month ~= recordDateTime.Month or nowDateTime.Year ~= recordDateTime.Year then
        return true
    end
    return false
end

function TimeHandler:GetDayBeginTimeStamp(nTimeStamp)
    if not nTimeStamp then
        nTimeStamp = self:GetTimeStamp()
    end

    local nowDate = CS.TimeUtility.GetLocalTimeFromTimeStamp(nTimeStamp) 
    local nDay = nowDate.Day
    local nMonth = nowDate.Month
    local nYear = nowDate.Year
    
    local todayLoginDate = CS.System.DateTime(nYear, nMonth, nDay, 0, 0, 0)
    local todayLoginTimeStamp = CS.TimeUtility.GetTimeStampFromLocalTime(todayLoginDate)
    return todayLoginTimeStamp
end

function TimeHandler:GetTimeStampFromDateString(timeStr)
    return CS.TimeUtility.GetTimeStampFromDateString(timeStr) 
end
