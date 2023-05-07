require("Lua/Activity/SlotsCards2020/SlotsCardsBundleHandler")
require("Lua/Activity/SlotsCards2020/SlotsCardsHandler")
require("Lua.Activity.SlotsCards2020.SlotsCardsMainUIPop")
require("Lua.Activity.SlotsCards2020.SlotsCardsGiftManager")
require("Lua.Activity.SlotsCards2020.SlotsCardsThemeEndPop")
require("Lua.Activity.SlotsCards2020.SlotsCardsAllThemeEndPop")
require("Lua.Activity.SlotsCards2020.SlotsCardsGameEntry")
require("Lua.Activity.SlotsCards2020.SlotsCardsGetCardsPop")
require("Lua.Activity.SlotsCards2020.SlotsCardsGetCoinsPop")
require("Lua.Activity.SlotsCards2020.SlotsCardsGetPackPop")
require("Lua.Activity.SlotsCards2020.SlotsCardsPrizesPop")
require("Lua.Activity.SlotsCards2020.SlotsCardsSimulation")
require("Lua.Activity.SlotsCards2020.SlotsCardsUnloadedUI")
require("Lua.Activity.SlotsCards2020.SlotsCardThemeEntry")
require("Lua.Activity.SlotsCards2020.SlotsCardsStarShopPop")
require("Lua.Activity.SlotsCards2020.SlotsCardsThemeEndPop")
require("Lua.Activity.SlotsCards2020.ShowCard")
require("Lua.Activity.SlotsCards2020.SlotsCardsOpenPackPop")
require("Lua.Activity.SlotsCards2020.SlotsCardsBookPop")
require("Lua.Activity.SlotsCards2020.Card")
require("Lua.Activity.SlotsCards2020.IntroduceCardPop")
require("Lua.Activity.SlotsCards2020.FrenzySpinGamePop")

local SlotsCardsTime = {from = "2023/01/05 00:00:00", period = 90}

SlotsCardsManager = {}
SlotsCardsManager.m_nVersion = 0
SlotsCardsManager.bActivityOpen = false
SlotsCardsManager.nActivityBeginTime = 0
SlotsCardsManager.nActivityEndTime = 0
SlotsCardsManager.m_nUnlockLevel = 30
SlotsCardsManager.album = nil
SlotsCardsManager.path = ""

if GameConfig.PLATFORM_EDITOR then
    SlotsCardsManager.m_nUnlockLevel = 2
end

function SlotsCardsManager:Init()
    SlotsCardsGiftManager:Init()
    
    self:CheckActivityState()
    self.bActivityOpen = self:orActivityOpen()
    self.bLevelUnlock = self:orLevelOk()
    self.bActivityUnLock = self:orUnLock()
    SlotsCardsHandler:InitActivityData()
    TimeHandler:AddListener(self.UpdateTime, self)
end

function SlotsCardsManager:orActivityOpen()
    return self.bActivityOpen
end

function SlotsCardsManager:GetRemainTime()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    return self.nActivityEndTime - nowSecond
end

function SlotsCardsManager:orLevelOk()
    return PlayerHandler.nLevel >= self.m_nUnlockLevel
end

function SlotsCardsManager:orUnLock()
    return self:orActivityOpen() and self:orLevelOk()
end

function SlotsCardsManager:GetBundleName()
    return "Activity_"..self.path
end

function SlotsCardsManager:SetActivitySeasonBeginAndEndTime()
    local activityInfo = SlotsCardsTime
    local fromSecond = TimeHandler:GetTimeStampFromDateString(activityInfo.from)
    local period = activityInfo.period

    local nSeasonId = (TimeHandler:GetServerTimeStamp() - fromSecond) // (period * 3600 * 24)
    local nSeasonBeginTime = nSeasonId * period * 3600 * 24 + fromSecond
    local nSeasonEndTime = nSeasonBeginTime + (period - 1) * 3600 * 24

    local nowSecond = TimeHandler:GetServerTimeStamp()
    if nowSecond >= nSeasonBeginTime and nowSecond < nSeasonEndTime then
        self.nActivityBeginTime = nSeasonBeginTime
        self.nActivityEndTime = nSeasonEndTime
        self.bActivityOpen = true

        if nSeasonId % 2 == 1 then
            self.album = "Album1"
            self.path = "SlotsCards2020"
            self.m_nVersion = 1
        else
            self.album = "Album2"
            self.path = "SlotsCards2021"
            self.m_nVersion = 2
        end

        SlotsCardsBundleHandler:InitBundleInfo()
        return true
    end

    return false
end

function SlotsCardsManager:CheckActivityState()
    self.bActivityOpen = false
    self:SetActivitySeasonBeginAndEndTime()
end

function SlotsCardsManager:UpdateTime()
    self:CheckActivityState()
    if self:orActivityOpen() ~= self.bActivityOpen then
        self.bActivityOpen = self:orActivityOpen()
        if self.bActivityOpen then

        end 

        SlotsCardsHandler:InitActivityData()
        EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
    end

    if self:orLevelOk() ~= self.bLevelUnlock then
        self.bLevelUnlock = self:orLevelOk()
        EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
    end
    
    if self:orUnLock() ~= self.bActivityUnLock then
        self.bActivityUnLock = self:orUnLock()
        EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
    end
end


