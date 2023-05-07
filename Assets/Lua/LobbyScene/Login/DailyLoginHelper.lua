DailyLoginHelper = {}

-- 出勤记录
function DailyLoginHelper:RecordChuQin()
    local todayLoginTimeStamp = TimeHandler:GetDayBeginTimeStamp()
    local nLastLoginDayBeginTimeStamp = TimeHandler:GetDayBeginTimeStamp(PlayerHandler.nLastLoginTimeStamp)
    if nLastLoginDayBeginTimeStamp ~= todayLoginTimeStamp then
        PlayerHandler:AddLoginDayCount()
        PlayerHandler:ResetTodayLoginCount()
    end
end
