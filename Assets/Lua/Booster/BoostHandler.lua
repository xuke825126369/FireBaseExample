require "Lua/Booster/BoostConfig"
require "Lua/Booster/BoosterEntry"

BoostHandler = {}
BoostHandler.OneDay = 24 * 60 * 60

BoostHandler.m_nCashBackRemainTime = 0
BoostHandler.m_nCashBackEndTime = 0

BoostHandler.BONUSTYPE = {enumCashBack = 1, enumBoostWin = 2, enumRepeatWin = 3, enumJackpotAgain = 4}
BoostHandler.m_bPreBoostWinFlag = false
BoostHandler.m_bPreRepeatWinFlag = false

function BoostHandler:Init()
    self:initCashBackTime()
    TimeHandler:AddListener(self.BoosterCountDown, self)
    EventHandler:AddListener("onPurchaseDoneGiveBoosterGift", self)
end

function BoostHandler:BoosterCountDown()
    local now = TimeHandler:GetServerTimeStamp()
    self.m_nCashBackRemainTime = self.m_nCashBackEndTime - now
    if self.m_nCashBackRemainTime < 0 then
        self.m_nCashBackRemainTime = 0
    end
end

function BoostHandler:initCashBackTime()
    local now = os.time()

    local nMaxRemainTime = 0 -- 找出最大剩余时间 显示界面用
    local cashBackBoosters = CommonDbHandler.data.CashBackParam
    if cashBackBoosters == nil then
        nMaxRemainTime = 0
    else
        local boosters = cashBackBoosters.boosters
        if boosters == nil or #boosters == 0 then
            nMaxRemainTime = 0
        else
            for i = 1, #boosters do
                if boosters[i].nEndTime > now then
                    local nRemainTime = boosters[i].nEndTime - now
                    if nRemainTime > nMaxRemainTime then
                        nMaxRemainTime = nRemainTime
                        self.m_nCashBackEndTime = boosters[i].nEndTime
                    end
                end
            end
        end
    end

    self.m_nCashBackRemainTime = nMaxRemainTime
end

function BoostHandler:FormatTime(nTime)
    -- 输入秒  输出hh:mm:ss (h可以大于24)
    local days = nTime // (3600*24)
    local hours = nTime // 3600 - 24 * days
    local minutes = nTime // 60 - 60 * hours
    local seconds = nTime % 60

    if days > 0 then
        local strTimeInfo = (days+1) .. " day"
        if days > 1 then
            strTimeInfo = strTimeInfo .. "s"
        end

        return strTimeInfo
    end

    local strTimeInfo = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    return strTimeInfo
end

function BoostHandler:CheckAwardPrize() -- 每次进大厅检查一次
    self:CheckCashBackBooster()
end

function BoostHandler:CheckCashBackBooster()
    local CashBackBoosterParam = CommonDbHandler.data.CashBackParam
    if CashBackBoosterParam == nil then
        return
    end

    local boosters = CashBackBoosterParam.boosters
    if boosters == nil then
        return
    end

    local now = os.time()
    
    local nMaxRemainTime = 0 -- 找出最大剩余时间 
    local listNeedRemoveBooster = {}
    for i=1, #boosters do
        if boosters[i].nEndTime > now then
            -- 还处于激活状态的
            
            local nRemainTime = boosters[i].nEndTime - now
            if nRemainTime > nMaxRemainTime then
                nMaxRemainTime = nRemainTime
            end
        else
            table.insert(listNeedRemoveBooster, i)
        end
    end

    local bHasBoosterExpired = false -- 有booster过期了 
    if #listNeedRemoveBooster > 0 then
        bHasBoosterExpired = true
        local aliveBoosters = {}
        for i=1, #boosters do
            local bFlag = LuaUtil.arrayContainsElement(listNeedRemoveBooster, i)
            if not bFlag then
                table.insert(aliveBoosters, boosters[i])
            end
        end
        boosters = aliveBoosters
    end

    local bReward = false
    if nMaxRemainTime == 0 then -- 活动结束
        if CashBackBoosterParam.nBonus > 0 then
            bReward = true
        end
    else
        if now - CashBackBoosterParam.nRewardTime > self.OneDay then
            if CashBackBoosterParam.nBonus > 0 then
                bReward = true
            end
        end
    end

    if bReward then
        local type = self.BONUSTYPE.enumCashBack
        local coins = CashBackBoosterParam.nBonus -- boosters
        local BonusParam = {nType = type, nCoins = coins}
        if CommonDbHandler.data.BonusParams == nil then
            CommonDbHandler.data.BonusParams = {}
        end
        table.insert(CommonDbHandler.data.BonusParams, BonusParam)
        setmetatable(CommonDbHandler.data.BonusParams, {__jsontype = "array"})

        CashBackBoosterParam.nBonus = 0
        CashBackBoosterParam.nRewardTime = now
        if nMaxRemainTime == 0 then
            CashBackBoosterParam.nRewardTime = -1 
        end

        EventHandler:Brocast("onInboxMessageChangedNotifycation")
    end

    if bHasBoosterExpired or bReward then -- 数据有修改 更新一下数据库
        setmetatable(CommonDbHandler.data.CashBackParam.boosters, {__jsontype = "array"})
        CommonDbHandler:SaveDb()
    end
        
end

function BoostHandler:setCashBackBoosterParam(newBooster)
    local CashBackBoosterParam = CommonDbHandler.data.CashBackParam
    if CashBackBoosterParam.nRewardTime == -1 then
        CashBackBoosterParam.nRewardTime = TimeHandler:GetServerTimeStamp()
    end

    local curBoosters = CashBackBoosterParam.boosters
    self:mergeCashBackBooster(newBooster, curBoosters)

    CommonDbHandler.data.CashBackParam = CashBackBoosterParam
	setmetatable(CommonDbHandler.data.CashBackParam.boosters, {__jsontype = "array"})
    CommonDbHandler:SaveDb()

    self:initCashBackTime()
    EventHandler:Brocast("onCashBackBoosterNotificationCallback")
end

function BoostHandler:mergeCashBackBooster(newBooster, curBoosters)
    local bFind = false
    local newCoef = newBooster.fCoef
    local nNewBoosterTime = newBooster.nBoosterTime
    local now = TimeHandler:GetServerTimeStamp()

    for i = 1, #curBoosters do
        local oldBooster = curBoosters[i]
        local oldCoef = oldBooster.fCoef
        if math.abs(newCoef-oldCoef) < 0.00001 then
            bFind = true

            if oldBooster.nEndTime < now then
                oldBooster = {fCoef = newCoef, nEndTime = now + nNewBoosterTime}
                curBoosters[i] = oldBooster
            else
                oldBooster.nEndTime = oldBooster.nEndTime + nNewBoosterTime
            end

            break
        end
    end

    if not bFind then
        local booster = {fCoef = newCoef, nEndTime = now + nNewBoosterTime}
        table.insert(curBoosters, booster)
    end
end

function BoostHandler:checkIsCashBackActive() -- 特指大于4%的附加项 。。
    local nowSecond = os.time()
    for i,v in ipairs(BoostConfig.boostMeCashBackActiveInfo) do
        local fromStr = v.from
        local toStr = v.to
        local fromSecond = TimeHandler:GetTimeStampFromDateString(fromStr)
        local toSecond = TimeHandler:GetTimeStampFromDateString(toStr)
        if(nowSecond >= fromSecond and nowSecond < toSecond) then
            return true, toSecond
        end
    end
    return false, 0
end