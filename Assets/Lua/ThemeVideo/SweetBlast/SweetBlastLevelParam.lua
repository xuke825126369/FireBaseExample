SweetBlastLevelParam = {}

SweetBlastLevelParam.m_listJackpotValue = {0, 0, 0, 0} -- 4个累加值

----- 收集信息 包括开箱子信息等。。
SweetBlastLevelParam.m_CollectInfo = {} -- gummyBoard 相关的信息 ：收集 奖励等。。
SweetBlastLevelParam.m_CollectInfo.m_nCollectNum = 0 -- 收集了多少个
SweetBlastLevelParam.m_CollectInfo.m_fAvgTotalBet = 0 -- 收集到的时候算一个平均值记录着(奖励参考值)

-- 每页翻一个。。记录是否翻过了
SweetBlastLevelParam.m_CollectInfo.m_listGummylandFlag = {false, false, false, false}
SweetBlastLevelParam.m_CollectInfo.m_listColossalFlag = {false, false, false, false}

SweetBlastLevelParam.m_CollectInfo.m_listOpenedBoxInfo = {} -- 打开的盒子信息
-- m_listOpenedBoxInfo 里是如下信息:
-- local OpenedBoxParam = {} -- key 对应的打开盒子都有哪些信息..
-- OpenedBoxParam.nType = 0 -- 1: 金币奖励 2: Gummyland 3: Colossal 4: freespin次数增加奖励? 还有别的什么？...
-- OpenedBoxParam.nCoins = 0 -- 金币奖励
-- OpenedBoxParam.m_nFreeSpinNum = 0 -- freespin 奖励
-- OpenedBoxParam.key = 0 -- 打开的第几个箱子 1 2 3 ... 36

-------

-- gingerman 走地图小游戏
SweetBlastLevelParam.m_BonusGameInfo = {} -- Bonus触发的小游戏相关信息。。

-- 以下都加到 m_BonusGameInfo 表里面
SweetBlastLevelParam.m_BonusGameInfo.m_nTotalBet = 0 -- 触发的时候初始化

-- 每次进游戏时初始化好 写数据库 杀进程再进时候恢复 不是credit的也要填上 当踩过之后就会变成credit了 
-- key: 1--28 value: 触发时候初始化的金币值...
SweetBlastLevelParam.m_BonusGameInfo.m_mapCreditItemValue = {}

-- 运行时会改变。。特殊节点会变成credit节点
SweetBlastLevelParam.m_BonusGameInfo.m_listMapItemType = {2, 1, 4, 1, 2, 1, 5, 6, 1, 3, 1, 6, 4, 1, 2,
                            1, 3, 1, 6, 3, 1, 3, 1, 3, 6, 5, 1, 7}

SweetBlastLevelParam.m_BonusGameInfo.m_listWheelSpinSequence = {} -- 对应下标1-8
SweetBlastLevelParam.m_BonusGameInfo.m_nCurGingermanKey = 0 -- 地图格子key 1-28 当前格子

-- 存着玩。。实际逻辑不用这个值了 2018-9-30
SweetBlastLevelParam.m_BonusGameInfo.m_nBonusGingermanNum = 0 -- 转轮转到了多少.. 存的江米人数量

SweetBlastLevelParam.m_BonusGameInfo.m_nBonusGameCoins = 0 -- 地图上收集到了多少..

SweetBlastLevelParam.m_BonusGameInfo.m_nFreeSpinNum = 0 -- 累计了多少次freespin了..
SweetBlastLevelParam.m_BonusGameInfo.m_nSlotsGameNum = 0 -- 累计了多少个棋盘了..
-- 棋盘从上往下 从左往右编号 1 2 3 4 。。

-- WildReelKey  从左往右连续计数。。 从1开始 所有棋盘的 wildreel 都是一样的
SweetBlastLevelParam.m_BonusGameInfo.m_listWildReelKey = {} -- 哪些列是wild.. 一共5列 0 1 2 3 4

SweetBlastLevelParam.m_BonusGameInfo.m_nMoveTimes = 0 -- 走 了多少次了。。
SweetBlastLevelParam.m_BonusGameInfo.m_nWheelSpinIndex = 0 -- Spin 了多少次了。。
SweetBlastLevelParam.m_BonusGameInfo.m_bAddRowFlag = false -- 是否踩到 AddRow
SweetBlastLevelParam.m_BonusGameInfo.m_listGingermanSequence = {}--走的所有步数
SweetBlastLevelParam.m_BonusGameInfo.m_WildReelRows = 3 -- 有几行.. 3 or 4

-- 一个测试方法
function SweetBlastLevelParam:testSweetBlastParam()
    if not GameConfig.PLATFORM_EDITOR then
        return
    end

    if SweetBlastFunc.m_bSimulationFlag then
        return
    end

    -- if self.m_CollectInfo.m_nCollectNum == nil then
    --     self.m_CollectInfo.m_nCollectNum = 80000
    -- end

    -- if self.m_CollectInfo.m_fAvgTotalBet == nil then
    --     self.m_CollectInfo.m_fAvgTotalBet = 1250
    -- end
end

function SweetBlastLevelParam:initSweetBlastParam()
    local strLevelName = ThemeLoader.themeKey
    local param = LevelDataHandler.m_Data
    if param == nil then
        -- 1.
        -- self.m_CollectInfo = {}
        -- self.m_CollectInfo.m_listGummylandFlag = {false, false, false, false}
        -- self.m_CollectInfo.m_listColossalFlag = {false, false, false, false}
        -- self.m_CollectInfo.m_listOpenedBoxInfo = {} -- 打开的盒子信息

        -- -- 2.
        -- self.m_BonusGameInfo = {}
        -- self.m_BonusGameInfo.m_bAddRowFlag = false
        -- self.m_BonusGameInfo.m_WildReelRows = 3
        -- self.m_BonusGameInfo.m_nSlotsGameNum = 1

        -- -- 3.
        -- self.m_listJackpotValue = {0, 0, 0, 0}
    end

    if param and param.m_CollectInfo ~= nil then
        self.m_CollectInfo = param.m_CollectInfo
    end

    if param and param.m_BonusGameInfo ~= nil then
        self.m_BonusGameInfo = param.m_BonusGameInfo
    else
        self.m_BonusGameInfo = {}

        self.m_BonusGameInfo.m_bAddRowFlag = false
        self.m_BonusGameInfo.m_WildReelRows = 3
        self.m_BonusGameInfo.m_nSlotsGameNum = 1
    end

    if param and param.m_listJackpotValue ~= nil then
        --self.m_listJackpotValue = {0, 0, 0, 0}
        self.m_listJackpotValue = param.m_listJackpotValue

    end 

    self:testSweetBlastParam()
end

function SweetBlastLevelParam:updateCollectAvgBet(nGummies)
    -- 更新平均下注值 开箱子发奖励时的参考
    local fBet = SceneSlotGame.m_nTotalBet
    local nCurCollectNum = self.m_CollectInfo.m_nCollectNum
    local nCurAvgBet = self.m_CollectInfo.m_fAvgTotalBet
    -- local fTotal = (fBet * nGummies + nCurCollectNum * nCurAvgBet)
    -- self.m_CollectInfo.m_fAvgTotalBet = fTotal / (nCurCollectNum + nGummies)
    --------

    local cnt = 0
    local nCurrentPage = 0
    local collectInfo = SweetBlastLevelParam.m_CollectInfo
    if collectInfo.m_listOpenedBoxInfo == nil then
        cnt = 0
        nCurrentPage = 1
    else
        cnt = #collectInfo.m_listOpenedBoxInfo
        nCurrentPage = math.modf(cnt / 9) + 1
    end

    local nCurPageOpened = cnt - 9*(nCurrentPage-1)
    if nCurPageOpened < 0 then
        nCurPageOpened = 0
        Debug.Assert(nCurPageOpened >= 0, "------error!!----")
    end

    local num = SweetBlastGummyBoardUI.m_listMissionGummies[nCurrentPage]

    local nPreCollected = nCurPageOpened * num + nCurCollectNum

    local fTotal = (fBet * nGummies + nPreCollected * nCurAvgBet)
    self.m_CollectInfo.m_fAvgTotalBet = fTotal / (nPreCollected + nGummies)

end

function SweetBlastLevelParam:setBonusGameBetByType(nType)
    -- 1. basegame 3个bonus牌触发的 就等于GameScene.totalbet
    -- 2. 姜饼人开箱子兑换的 就等于收集平均数。。self.m_CollectInfo.m_fAvgTotalBet

    local nTotalBet = 0
    if nType == 1 then
        self.m_BonusGameInfo.m_nTotalBet = SceneSlotGame.m_nTotalBet
    elseif nType == 2 then
        self.m_BonusGameInfo.m_nTotalBet = self.m_CollectInfo.m_fAvgTotalBet
    else
        Debug.Log("----------  error!!!!   -----------")
    end

    self:saveParam()
end

function SweetBlastLevelParam:saveParam()
    if SweetBlastFunc.m_bSimulationFlag then
        return
    end

    local strLevelName = ThemeLoader.themeKey
    local param = LevelDataHandler.m_Data
    if param == nil then
        param = {}
    end

    param.m_CollectInfo = self.m_CollectInfo
    setmetatable(param.m_CollectInfo.m_listOpenedBoxInfo, {__jsontype = "array"})
    setmetatable(param.m_CollectInfo.m_listGummylandFlag, {__jsontype = "array"})
    setmetatable(param.m_CollectInfo.m_listColossalFlag, {__jsontype = "array"})
    
    param.m_BonusGameInfo = self.m_BonusGameInfo
    param.m_listJackpotValue = self.m_listJackpotValue

    LevelDataHandler:persistentData()
end

function SweetBlastLevelParam:setBonusGameInfoEmpty()
    local strLevelName = ThemeLoader.themeKey
    self.m_BonusGameInfo = {}

    self.m_BonusGameInfo.m_bAddRowFlag = false
    self.m_BonusGameInfo.m_WildReelRows = 3
    self.m_BonusGameInfo.m_nSlotsGameNum = 1

    self:saveParam()
end