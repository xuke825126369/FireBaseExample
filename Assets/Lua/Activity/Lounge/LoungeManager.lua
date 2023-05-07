require("Lua.Activity.Lounge.LoungeHandler")
require("Lua.Activity.Lounge.LoungeConfig")
require("Lua.Activity.Lounge.LoungeBundleHandler")
require("Lua.Activity.Lounge.LoungeEntryUI")
require("Lua.Activity.Lounge.MedalMasterEntryUI")
require("Lua.Activity.Lounge.LoungeHallUI")
require("Lua.Activity.Lounge.MedalMasterMainUI")

LoungeManager = {}
LoungeManager.bActivityOpen = false
LoungeManager.nSeasonID = 0
LoungeManager.nActivityBeginTime = 0
LoungeManager.nActivityEndTime = 0
LoungeManager.m_nUnlockLevel = 5
LoungeManager.m_nVersion = 1
LoungeManager.m_nCurSeasonID = 1 -- 当前是第几赛季 发布资源的时候修改
LoungeManager.ACTIVETIME = {
    {from = "2022/12/10 00:00:00", to = "2023/12/20 00:00:00"},
}

if GameConfig.PLATFORM_EDITOR then
    LoungeManager.m_nUnlockLevel = 2
end

function LoungeManager:Init()
    LoungeBundleHandler:InitBundleInfo()
    self:UpdateTime()
end

function LoungeManager:GetBundleName()
    return "Activity_Lounge"
end

function LoungeManager:orActivityOpen()
    return self.bActivityOpen
end

function LoungeManager:orLevelOk()
    return PlayerHandler.nLevel >= self.m_nUnlockLevel
end

function LoungeManager:orUnLock()
    return self:orActivityOpen() and self:orLevelOk()
end

function LoungeManager:CheckActivityState()
    self.bActivityOpen = false
    local nowSecond = TimeHandler:GetServerTimeStamp()
    for i, v in ipairs(self.ACTIVETIME) do
        local fromSecond = TimeHandler:GetTimeStampFromDateString(v.from)
        local toSecond = TimeHandler:GetTimeStampFromDateString(v.to)
        if nowSecond >= fromSecond and nowSecond < toSecond then
            self.bActivityOpen = true
            self.nSeasonID = i
            self.nActivityBeginTime = fromSecond
            self.nActivityEndTime = toSecond
            break
        end
    end
    
end

function LoungeManager:UpdateTime()
    self:CheckActivityState()
    LoungeHandler:InitActivityData()
            
    local bActivityOpen = self:orActivityOpen()
    local bLevelUnlock = self:orLevelOk()
    StartCoroutine(function()
        local waitForSecend = Unity.WaitForSeconds(1)
        while true do
            yield_return(waitForSecend)
            self:CheckActivityState()

            if self:orActivityOpen() ~= bActivityOpen then
                bActivityOpen = self:orActivityOpen()
                if bActivityOpen == true then
                    LoungeHandler:InitActivityData()
                else
                    LoungeHandler:onActivityEnd()
                end
                EventHandler:Brocast("OnLoungeActivityStateChanged")
            end

            if self:orLevelOk() ~= bLevelUnlock then
                bLevelUnlock = self:orLevelOk()
                EventHandler:Brocast("OnLoungeActivityStateChanged")
            end
        end
    end)

end


