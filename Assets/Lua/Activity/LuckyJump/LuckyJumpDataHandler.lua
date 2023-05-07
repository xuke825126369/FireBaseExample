LuckyJumpDataHandler = {}

LuckyJumpDataHandler.data = {}

LuckyJumpDataHandler.m_bInitData = false

LuckyJumpDataHandler.m_nEndTime = 0
LuckyJumpDataHandler.m_mapPrize = {}

LuckyJumpDataHandler.DATAPATH = Unity.Application.persistentDataPath .. "/LuckyJumpData.txt"

LuckyJumpDataHandler.m_nUnlockLevel = GameConfig.PLATFORM_EDITOR and 1 or 5

LuckyJumpDataHandler.ACTIVETIME = {
    {from = "2019-7-1T00:00:00+0000", to = "2020-1-15T00:00:00+0000"}
}

function LuckyJumpDataHandler:Init()
    if not GameConfig.LUCKYJUMP_FLAG then
        return
    end
    self:checkIsActiveTime()

    if self.m_bInitData then
        return
    end

    self.bIsShowHint = true
    self.m_bInitData = true
    self:readFile()
    if self.data.m_nEndTime ~= self.m_nEndTime then
        self:reset()
    end
    self:updateLevelPrize()
end

function LuckyJumpDataHandler:updateLevelPrize()
    local ratioArray = {1.1, 1.2, 1.3, 1.4, 1.5, 2} --1-5关，还有一个总奖励
    local index = 1
    for i=1,#LuckyJumpConfig do
        self.m_mapPrize["Level"..i] = self:getBasePrize()*50*ratioArray[i]
    end
    self.m_mapPrize["All"] = self:getBasePrize()*50*ratioArray[#LuckyJumpConfig+1]
end

function LuckyJumpDataHandler:writeFile()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function LuckyJumpDataHandler:readFile()
    if not CS.System.IO.File.Exists(self.DATAPATH) then
        self:reset()
        return
    end

    local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
    self.data = rapidjson.decode(strData)
end

function LuckyJumpDataHandler:reset()
    self.data = {}
    self.data.m_nVersion = 1
    self.data.bIsGetCompletedGift = false
    self.data.nMoveCount = 200
    self.data.fAddMoveCountProgress = 0 --收集进度
    self.data.nLevel = 1 -- 第几关
    self.data.m_nEndTime = self.m_nEndTime
    self.data.playerPos = {0,0} --默认初始位置为（1，1）
end

function LuckyJumpDataHandler:updatePlayerPosition(pos)
    self.data.playerPos = pos
    self:writeFile()
end

function LuckyJumpDataHandler:toNextLevel()
    if self.data.bIsGetCompletedGift then
        return
    end
    self.data.initPlayerPos = nil
    self.data.nLevel = self.data.nLevel + 1
    self.data.playerPos = {0,0}
    if self.data.nLevel > #LuckyJumpConfig then
        PlayerHandler:AddCoin(self.m_mapPrize["All"])
        self.data.bIsGetCompletedGift = true
    end
    self:writeFile()
end

function LuckyJumpDataHandler:addMoveCount(count)
    self.data.nMoveCount = self.data.nMoveCount + count
    self:writeFile()
end

function LuckyJumpDataHandler:checkIsActiveTime()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    for i, v in ipairs(self.ACTIVETIME) do
        local fromStr = v.from
        local toStr = v.to
        local fromSecond = TimeHandler:GetTimeStampFromDateString(fromStr)
        local toSecond = TimeHandler:GetTimeStampFromDateString(toStr)
        if (nowSecond >= fromSecond) then
            if nowSecond < toSecond then
                self.m_nEndTime = toSecond
                return true
            end
        end
    end
    return false
end

function LuckyJumpDataHandler:getEndTime()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    for i, v in ipairs(self.ACTIVETIME) do
        local fromStr = v.from
        local toStr = v.to
        local fromSecond = TimeHandler:GetTimeStampFromDateString(fromStr)
        local toSecond = TimeHandler:GetTimeStampFromDateString(toStr)
        if (nowSecond >= fromSecond) then
            if nowSecond < toSecond then
                return toSecond
            end
        end
    end
    return nil
end

--以1美金为奖励
function LuckyJumpDataHandler:getBasePrize()
    local nLevel = PlayerHandler.nLevel
    local nBaseLevel = 500
    if nLevel > 500 then
        nLevel = nLevel - 500
        nBaseLevel =  500 + 200 + math.floor( nLevel/200 ) * 200
    end

    local strSkuKey = AllBuyCFG[1].productId

    local levelMultiplier = 1 + math.floor(nBaseLevel / 100)

    local nBasePrize = 0
    for i, v in ipairs(DynamicConfig.coinSkuInfoArray) do
        if(strSkuKey == v.productId) then 
            nBasePrize = v.baseCoins * levelMultiplier
            break
        end
    end

    return nBasePrize
end

function LuckyJumpDataHandler:refreshAddSpinProgress(data)
    --根据押注大小增加进度
    local value = ActivityHelper:getAddSpinProgressValue(data, ActiveType.LuckyJump)
    
    self.data.fAddMoveCountProgress = self.data.fAddMoveCountProgress + value
    
    local isMax = self.data.fAddMoveCountProgress >= 1

    if isMax then
        while self.data.fAddMoveCountProgress >= 1 do
            self.data.fAddMoveCountProgress = self.data.fAddMoveCountProgress - 1
        end

        local nAddCount = ActivityHelper:getProgressFullAddCount(ActiveType.LuckyJump)
        
        self:addMoveCount(nAddCount)
    end
    self:writeFile()
    return isMax
end