SystemAwardHandler = {}
SystemAwardHandler.dbName = "SystemAwardHandler"

function SystemAwardHandler:Init()
    SystemAwardHandler:SendFreeCoins()
    SystemAwardHandler:SendFreeLoungeLuckyPack()
end

function SystemAwardHandler:SendFreeLoungeLuckyPack()
    if not LoungeHandler:isLoungeMember() then
        return
    end

    local nDayBeginTime = TimeHandler:GetDayBeginTimeStamp()
    local nLastTime = CommonDbHandler.data.nLastLuckyPackNetDaySecond 
    if nDayBeginTime == nLastTime then
        return
    end

    CommonDbHandler:AddLoungeLuckyPack()
    EventHandler:Brocast("onInboxMessageChangedNotifycation")
end

function SystemAwardHandler:SendFreeCoins()
    local nPeriodDayCount = 3
    local nDayCount = (TimeHandler:GetServerTimeStamp() - CommonDbHandler.data.nLastSendFreeCoinsTimeStamp) // (3600 * 24)
    if nDayCount >= nPeriodDayCount then
        CommonDbHandler:AddCollectFreeCoins()
    end
    EventHandler:Brocast("onInboxMessageChangedNotifycation")
end

