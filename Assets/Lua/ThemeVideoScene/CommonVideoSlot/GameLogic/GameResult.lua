local GameResult = {}

function GameResult:create()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    
    o.m_bShowJackPot = false --显示 JackPot

    o.m_fGameWin = 0.0
    o.m_fSpinWin = 0.0
    o.m_fJackPotBonusWin = 0.0
    o.m_fNonLineBonusWin = 0.0

    o.m_listWins = {} ---从1开始数组
    o.m_listWinItemPayWays = {} --从1开始数组  List<WinItemPayWay>
    o.m_mapWinItemPayWays = {} --symbolID为key的map  Dictionary<int, WinItemPayWay>

    o.m_nNewFreeSpinCount = 0
    o.m_nFreeSpinCount = 0
    o.m_nFreeSpinTotalCount = 0
    o.m_fFreeSpinTotalWins = 0.0
    o.m_nFreeSpinAccumCount = 0
    o.m_fFreeSpinAccumWins = 0.0
    
    o.m_nReSpinCount = 0
    o.m_nReSpinTotalCount = 0
    o.m_fReSpinTotalWins = 0.0
    o.m_bRespinResetFlag = false
    o.m_bRespinCompletedFlag = false

    o.m_enumJackpotType = JackpotTYPE.enumJackpotType_NULL

    o.m_listTestWinSymbols = {} ----从1开始数组
    o.m_listTestWinLines = {} ----从1开始数组
    o.m_TestJackPotBonusItems = {}
    o.m_TestWin0Nums = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11} --//统计输出连续多少把不赢钱的情况，用于概率数值评价

    o.m_mapTestPayWayWinItems = {}
    o.m_TestNonLineWinItem = TestWinItem:create(-1)
    return o
end

function GameResult:ResetGame()
    self.m_listTestWinSymbols = {}
    self.m_listTestWinLines = {}
    self.m_TestJackPotBonusItems = {}
    self.m_TestWin0Nums = {0,0,0,0,0,0,0,0,0,0}
    self.m_mapTestPayWayWinItems = {}

    self.m_bBonusStartFlag = false
    self.m_bReSpinStartFlag = false

    self.m_fGameWin = 0.0 -- 用于棋盘下方显示的数、会在 SlotsGameLua:Spin() 里按一定条件每回合清零
    self:ResetSpin()
    self.m_nFreeSpinCount = 0
    self.m_nFreeSpinTotalCount = 0
    self.m_fFreeSpinTotalWins = 0.0
    self.m_nFreeSpinAccumCount = 0
    self.m_fFreeSpinAccumWins = 0.0

    self.m_enumJackpotType = JackpotTYPE.enumJackpotType_NULL
end

-- 每次中奖的结算的时候，都会先重置
function GameResult:ResetSpin()
    self.m_bShowJackPot = false --显示 JackPot

    self.m_fSpinWin = 0.0
    self.m_fJackPotBonusWin = 0.0
    self.m_fNonLineBonusWin = 0.0

    self.m_listWins = {} --nil
    self.m_mapWinItemPayWays = {} --nil
    self.m_listWinItemPayWays = {} --nil

    self.m_nNewFreeSpinCount = 0
    self.m_enumJackpotType = JackpotTYPE.enumJackpotType_NULL
end

-- 每次Spin 开始的时候，重置一些参数
function GameResult:Spin()
    if not self:HasReSpin() then
        self.m_nReSpinCount = 0
        self.m_nReSpinTotalCount = 0
        self.m_fReSpinTotalWins = 0
    end

    if not self:HasFreeSpin() and not self:HasReSpin() then
        self.m_nFreeSpinCount = 0
        self.m_nFreeSpinTotalCount = 0
        self.m_fFreeSpinTotalWins = 0.0

        return true
    end

    return false
end

function GameResult:InFreeSpin() --//最后一次freespin转动期间以及结算 都是这种情况：FreeSpinCount == FreeSpinTotalCount
    if self.m_nFreeSpinTotalCount ~= 0 and self.m_nFreeSpinCount <= self.m_nFreeSpinTotalCount then
        return true
    end
    return false
end

function GameResult:HasFreeSpin()
    if self.m_nFreeSpinTotalCount ~= 0 and self.m_nFreeSpinCount < self.m_nFreeSpinTotalCount then
        return true
    end

    return false
end

function GameResult:InReSpin() -- //最后一次respin转动期间以及结算 都是这种情况：ReSpinCount == ReSpinTotalCount
    if self.m_nReSpinTotalCount~=0 and self.m_nReSpinCount<=self.m_nReSpinTotalCount then
        return true
    end

    return false
end

function GameResult:HasReSpin()
    if self.m_nReSpinTotalCount ~= 0 and self.m_nReSpinCount < self.m_nReSpinTotalCount then
        return true
    end

    return false
end

return GameResult