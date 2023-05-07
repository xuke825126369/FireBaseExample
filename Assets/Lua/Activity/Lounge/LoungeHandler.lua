require("Lua.Activity.Lounge.LoungeConfig")

LoungeHandler = {}
LoungeHandler.DATAPATH = Unity.Application.persistentDataPath .. "/LoungeHandler.txt"

--子表内容初始值如下:
local MEDALMASTERDATA = {
    nSeasonID = 1, -- 这个是由 ACTIVETIME 唯一决定的 --
    bStartOverUIShow = false, -- 换赛季的时候显示一次
    bGrandPrizeClaimed= false, -- 所有徽章都升级到5星之后领取一个大奖 GrandPrize
    listChestCount = {0, 0, 0, 0}, -- 依次是 nCommonChest nRareChest nEpicChest nLegendaryChest

    listMedalExp = {0, 0, 0, 0, 0, 0, 0, 0},
    -- 每个徽章当前获得的经验值 可以换算出等级以及进度百分比AddListener
    -- 加经验的时候判断修改
    listCompletedFlag = {false, false, false, false, false, false, false, false},

    -- 用的 TimeHandler:GetServerTimeStamp() 是网络时间
    -- 但是变量名这个赛季不能改了。。因为这写文件了。
    listFreeBonusLastLocalTime = {0, 0, 0, 0, 0, 0, 0, 0},
    nFreeChestLastLocalTime = 0,
}

function LoungeHandler:Init()
    EventHandler:AddListener("UseCoins", self)
    EventHandler:AddListener("onLevelUp", self)
    EventHandler:AddListener("PlayFreeBonusGoldenChest", self)
    EventHandler:AddListener("PlayFreeBonusSilverChest", self)
    EventHandler:AddListener("onPurchaseDoneNotifycation", self)
end

function LoungeHandler:SaveDb()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function LoungeHandler:GetDbInitData()
    local data = {}
    data.nActivityVersion = 0
    data.activityData = {}
    return data
end

function LoungeHandler:GetActivityDbInitData()
    local data = {}
    data.nSeasonID = LoungeManager.nSeasonID
    data.nLoungeMemberEndNetTime = 0
    data.nLoungeMemberEndLocalTime = 0
    data.nLoungePoint = 0 -- 15000 获得一个皇冠 加10天会员期
    data.bLoungeReward = false 
    data.nQualifiedSpins = 0
    data.listMedalMasterData = LuaHelper.DeepCloneTable(MEDALMASTERDATA)
    return data
end

function LoungeHandler:InitActivityData()
    self.data = self:GetDbInitData()
    if LoungeManager:orActivityOpen() then
        if CS.System.IO.File.Exists(self.DATAPATH) then
            local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
            local data = rapidjson.decode(strData)
            self.data = data
        end
        
        if self.data.nActivityVersion ~= LoungeManager.nSeasonID then
            self.data.nActivityVersion = LoungeManager.nSeasonID
            self.data.activityData = self:GetActivityDbInitData()
            self:SaveDb()
        end
        
        LoungeHandler:CheckTriggerLoungeMember()
        self:SaveDb()
    else
        self.data.activityData = {}
        self:SaveDb()
    end
end

function LoungeHandler:onActivityEnd()
    self.data.activityData = {}
    self:SaveDb()
end

-- count 为负数就是使用了 要减少
function LoungeHandler:addChest(enumChestType, count)
    Debug.Assert(self.data.activityData.listMedalMasterData.listChestCount[enumChestType], tostring(enumChestType))
    self.data.activityData.listMedalMasterData.listChestCount[enumChestType] = self.data.activityData.listMedalMasterData.listChestCount[enumChestType] + count
    self:SaveDb()

    MedalMasterMainUI:RefreshRightUI()
    local nChestNum = 0
    for i = 1, 4 do
        nChestNum = nChestNum + self.data.activityData.listMedalMasterData.listChestCount[i]
    end     

    EventHandler:Brocast("addLoungeChestNotification", nChestNum)
end

function LoungeHandler:addMedalExp(nIndex, nExp)
    local data = self.data.activityData.listMedalMasterData
    data.listMedalExp[nIndex] = data.listMedalExp[nIndex] + nExp

    local nLevel, fProgress = LoungeConfig:getMedalLevelInfo(nIndex)
    if nLevel == 5 then
        data.listCompletedFlag[nIndex] = true
    end

    self:SaveDb()
end

function LoungeHandler:setLoungeDayPass(nDayPass)
    if self:isLoungeMember() then
        return
    end 

    local nEndTime = TimeHandler:GetServerTimeStamp() + nDayPass * LoungeConfig.m_nOneDaySecond
    self.data.activityData.nLoungeMemberEndLocalTime = nEndTime
    
    self:SaveDb()
end

-- 有正有负 当皇冠数小于2 满15000了就兑换出1个皇冠
function LoungeHandler:addLoungePoints(nPoints)
    self.data.activityData.nLoungePoint = self.data.activityData.nLoungePoint + nPoints
    self:CheckTriggerLoungeMember()
    self:SaveDb()

    EventHandler:Brocast("OnLoungeActivityStateChanged")
end

function LoungeHandler:isLoungeMember()
    if not LoungeManager:orUnLock() then
        return false
    end

    if TimeHandler:GetServerTimeStamp() < self.data.activityData.nLoungeMemberEndLocalTime then
        return true
    else
        return false
    end
end

function LoungeHandler:getLoungeMemberTime()
    if not self:isLoungeMember() then
        return 0
    end

    local diffTime = self.data.activityData.nLoungeMemberEndLocalTime - TimeHandler:GetServerTimeStamp()
    return diffTime
end

-- 得到皇冠数量
function LoungeHandler:getRoyalNum()
    local diffTime = self:getLoungeMemberTime()
    if diffTime == 0 then
        return 0
    end

    if diffTime < LoungeConfig.N_MEMBER_DAY_COUNT * LoungeConfig.m_nOneDaySecond then
        return 1
    end

    return 2
end

function LoungeHandler:getLoungePoints()
    return self.data.activityData.nLoungePoint
end

-- 消息监听 完成任务
function LoungeHandler:onLevelUp()
    local nPoint = math.random(1, PlayerHandler.nLevel % 10 + 1)
    self:addLoungePoints(nPoint)
end

function LoungeHandler:UseCoins(data)
    local nTotalBet = data.nTotalBet
    self.data.activityData.nQualifiedSpins = self.data.activityData.nQualifiedSpins + 1
    if self.data.activityData.nQualifiedSpins >= 200 then
        self.data.activityData.nQualifiedSpins = 0
        local nPoint = math.random(1, 12)
        self:addLoungePoints(nPoint)
    end

    local bTrigger, enumChestType = LoungeConfig:isTriggerChest(nTotalBet)
    if bTrigger then
        self:addChest(enumChestType, 1)
        PopStackViewHandler:Show(MedalChestPopEffect, enumChestType, true, 1)
    end
    
    self:SaveDb()
end

function LoungeHandler:PlayFreeBonusGoldenChest()
    self:addLoungePoints(2)
end

function LoungeHandler:PlayFreeBonusSilverChest()
    self:addLoungePoints(1)
end

function LoungeHandler:onPurchaseDoneNotifycation(skuInfo)
    if not LoungeManager:orActivityOpen() then
        return
    end

    local nLoungePoint = 0
    local count = 0
    local enumType = LoungeConfig.enumCHESTTYPE.Common
    for i = 1, #LoungeConfig.m_lsitSkuChestInfo do
        if skuInfo.productId == LoungeConfig.m_lsitSkuChestInfo[i].productId then
            enumType = LoungeConfig.m_lsitSkuChestInfo[i].enumType
            count = LoungeConfig.m_lsitSkuChestInfo[i].nCount
            nLoungePoint = LoungeConfig.m_lsitSkuChestInfo[i].nLoungePoint
            break
        end
    end
    
    self:addChest(enumType, count)
    self:addLoungePoints(nLoungePoint)
    PopStackViewHandler:Show(MedalChestPopEffect, enumType, true, count)
end

function LoungeHandler:CheckTriggerLoungeMember()
    if not LoungeManager:orUnLock() then
        return
    end

    local bNowLoungeMember = self:isLoungeMember()
    if self.data.activityData.nLoungePoint >= LoungeConfig.N_MEMBER_NEED_POINTS then
        local nRoyalNum = self:getRoyalNum()
        if nRoyalNum <= 1 then
            -- 保证最长2个皇冠的会员时间
            self.data.activityData.nLoungePoint = self.data.activityData.nLoungePoint - LoungeConfig.N_MEMBER_NEED_POINTS
            self.data.activityData.nLoungeMemberEndLocalTime = TimeHandler:GetServerTimeStamp() + LoungeConfig.N_MEMBER_DAY_COUNT * LoungeConfig.m_nOneDaySecond
        end
        
        if self:getRoyalNum() == 2 then
            self.data.activityData.bLoungeReward = true
        end
    end

    if not bNowLoungeMember and self:isLoungeMember() then
        LoungeSpecialLevelBoosterUI:Show()
        LeanTween.delayedCall(2.0, function()
            PopStackViewHandler:Show(WelcomeToTheLoungeUI)
        end)
    end

    self:SaveDb()
end