require("Lua.Activity.ActivityBundleHandler")
require("Lua.Activity.ActiveLobbyEntry")
require("Lua.Activity.ActiveThemeEntry")
require("Lua.Activity.ActivityHelper")

ActiveManager = {}
ActiveManager.mainUIPop = nil
ActiveManager.dataHandler = nil
ActiveManager.unloadedUI = nil
ActiveManager.nActivityBeginTime = 0
ActiveManager.nActivityEndTime = 0
ActiveManager.activeType = nil
ActiveManager.nUnlockLevel = 0

ActiveType = {
    Bingo = "Bingo",
    ChutesRockets = "ChutesRockets",
    FindRichie = "FindRichie",
    LuckyJump = "LuckyJump",
    CookingFever = "CookingFever",
    RainbowPick = "RainbowPick",
    BoardQuest = "BoardQuest",
    RocketFortune = "RocketFortune",
}

ActiveManager.ActiveTime = {
    {from = "2023/01/05 00:00:00",      period = 20,         activeType = "Bingo",           nUnlockLevel = 10},
    {from = "2030/08/09 00:00:00",      period = 20,         activeType = "ChutesRockets",   nUnlockLevel = 10},
    {from = "2030/08/09 00:00:00",      period = 20,         activeType = "FindRichie",      nUnlockLevel = 10},
    {from = "2030/08/09 00:00:00",      period = 20,         activeType = "LuckyJump",       nUnlockLevel = 10},
    {from = "2030/08/09 00:00:00",      period = 20,         activeType = "CookingFever",    nUnlockLevel = 10},
    {from = "2030/08/09 00:00:00",      period = 20,         activeType = "RainbowPick",     nUnlockLevel = 10},
    {from = "2030/08/09 00:00:00",      period = 20,         activeType = "BoardQuest",      nUnlockLevel = 10},
    {from = "2030/08/09 00:00:00",      period = 20,         activeType = "RocketFortune",   nUnlockLevel = 10},
}

function ActiveManager:Init()
    TimeHandler:AddListener(self.UpdateTime, self)
end 

function ActiveManager:orActivityOpen()
    return self.activeType ~= nil
end

function ActiveManager:GetRemainTime()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    return self.nActivityEndTime - nowSecond
end

function ActiveManager:orLevelOk()
    return PlayerHandler.nLevel >= self.nUnlockLevel
end

function ActiveManager:orUnLock()
    return self:orActivityOpen() and self:orLevelOk()
end

function ActiveManager:GetBundleName()
    return "Activity_"..self.activeType
end

function ActiveManager:SetActivitySeasonBeginAndEndTime(activityInfo)
    local fromSecond = TimeHandler:GetTimeStampFromDateString(activityInfo.from)
    if TimeHandler:GetServerTimeStamp() < fromSecond then
        return false
    end 

    local period = activityInfo.period
    local nSeasonId = (TimeHandler:GetServerTimeStamp() - fromSecond) // (period * 3600 * 24)
    local nSeasonBeginTime = nSeasonId * period * 3600 * 24 + fromSecond
    local nSeasonEndTime = nSeasonBeginTime + (period - 1) * 3600 * 24
    
    local nowSecond = TimeHandler:GetServerTimeStamp()
    if nowSecond >= nSeasonBeginTime and nowSecond < nSeasonEndTime then
        self.nActivityBeginTime = nSeasonBeginTime
        self.nActivityEndTime = nSeasonEndTime
        self.activeType = activityInfo.activeType
        if GameConfig.PLATFORM_EDITOR then
            self.nUnlockLevel = 2
        else
            self.nUnlockLevel = activityInfo.nUnlockLevel
        end 

        ActivityBundleHandler:InitBundleInfo()
        return true
    end

    return false
end 

function ActiveManager:CheckActivityState()
    self.activeType = nil
    for i, v in ipairs(self.ActiveTime) do
        if self:SetActivitySeasonBeginAndEndTime(v) then
            break
        end
    end
end

function ActiveManager:UpdateTime()
    local nLastActivityType = self.activeType
    self:CheckActivityState()
    if nLastActivityType ~= self.activeType then
        nLastActivityType = self.activeType
        EventHandler:Brocast("onActiveSeasonEnd")
        if self:orActivityOpen() then
            ActiveManager:InitActivityInfo()
        end
    end
    
    if self:orActivityOpen() then
        EventHandler:Brocast("onActiveTimeChanged")
    end
end

function ActiveManager:InitActivityInfo()
    Debug.LogWithColor("ActiveManager:set "..self.activeType) 
    local str = string.format("Lua.Activity.%s.%sUnloadedUI", self.activeType, self.activeType)
    require(str)
    local str = string.format("Lua.Activity.%s.%sMainUIPop", self.activeType, self.activeType)
    require(str)
    local str = string.format("Lua.Activity.%s.%sHandler", self.activeType, self.activeType)
    require(str)
    self.mainUIPop = _G[self.activeType.."MainUIPop"]
    self.dataHandler = _G[self.activeType.."Handler"]
    self.unloadedUI = _G[self.activeType.."UnloadedUI"]
    self.dataHandler:Init()
    EventHandler:Brocast("onActiveSeasonStart")

end

