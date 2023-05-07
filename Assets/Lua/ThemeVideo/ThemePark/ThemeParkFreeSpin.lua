--[[
    author:coldflag
    time:2021-08-24 16:13:03
]]
ThemeParkFreeSpin = {}

LevelUI = ThemeParkLevelUI

ThemeParkFreeSpin.mapCharacterData = {} -- 保存了四个角色信息，再中奖时候更新（FreeSpin结束，即次数为0的时候初始化参数）
ThemeParkFreeSpin.bHasInitedCharacterData = false -- 当FreeSpin次数为0的时候，是否已经更新过了角色数据
ThemeParkFreeSpin.nCharacterID = nil -- 4 Dad, 3 Mom, 2 girl, 1 boy
ThemeParkFreeSpin.nBounsType = 0 -- 1 普通， 2 Mega， 3 Super
ThemeParkFreeSpin.nCurPosID = 1 -- 记录小人走到哪儿了
ThemeParkFreeSpin.nCurModID = 1 -- 记录小人现在在哪条道上
ThemeParkFreeSpin.mapRewardMap = {}

ThemeParkFreeSpin.bHasDownMap = false -- 游乐园地图是否已经向下移动过了

--[[
    @desc: 进入FreeSpin时候调用，初始化相关参数
    author:coldflag
    time:2021-08-23 15:51:41
    @return: void
]]
function ThemeParkFreeSpin:InitFreeSpinParm()
    self:InitCharacterData() -- 只在FreeSpin次数为0的时候才会真正重置数据
    self:InitCharacterPosition()
    self:InitRewardMapList()
end

function ThemeParkFreeSpin:InitCharacterPosition()
    if SlotsGameLua.m_GameResult and SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount == 0 then
        self.nCurPosID = 1
        self.nCurModID = 1
    end
end

function ThemeParkFreeSpin:GetNowCharacterPosition()
    return self.nCurModID, self.nCurPosID
end

function ThemeParkFreeSpin:FlushCharacterPosition(pos1, pos2)
    local rv = false
    if pos1 ~= nil and pos2 ~= nil then
        self.nCurModID = pos1
        self.nCurPosID = pos2
        rv = true
    end

    return rv
end

function ThemeParkFreeSpin:ResetCharacterPosition()
    local rv = self:FlushCharacterPosition(1, 1)
    return rv
end

--[[
    @desc: 在FreeSpin次数为0，且没有重置过数据的情况下，对角色表数据进行初始化
    author:coldflag
    time:2021-08-23 18:37:33
    @return:
]]
function ThemeParkFreeSpin:InitCharacterData()
    local rv = false
    if self.mapCharacterData and not self.bHasInitedCharacterData then
        -- 先直接清空，然后再重新塞入数据
        self.mapCharacterData = {}
        local mapDad = {["name"] = "dad", ["prize"] = 40000.0, ["raise"] = 1000, ["multiplier"] = 1}
        local mapMom = {["name"] = "mom", ["prize"] = 30000.0, ["raise"] = 2000, ["multiplier"] = 1}
        local mapGirl = {["name"] = "girl", ["prize"] = 20000.0, ["raise"] = 3000, ["multiplier"] = 1}
        local mapBoy = {["name"] = "boy", ["prize"] = 10000.0, ["raise"] = 4000, ["multiplier"] = 1}

        self.mapCharacterData = {mapBoy, mapGirl, mapMom, mapDad}

        self.bHasInitedCharacterData = true
        rv = true
    end

    return rv
end


function ThemeParkFreeSpin:GetCharacterDataStruct()
    if self.mapCharacterData then
        return self.mapCharacterData
    end
end

function ThemeParkFreeSpin:SetCharacterData(nCharacterID, sType, Data)
    local rv = false
    local map1 = {1, 2, 3, 4}
    local map2 = {"prize", "multiplier"}
    if nCharacterID == nil or sType == nil or Data == nil then
        return rv
    end

    if Tool:IsElemInTable(nCharacterID, map1) and Tool:IsElemInTable(sType, map2) then
        self.mapCharacterData[nCharacterID][sType] = Data
        rv = true
    end

    return rv
end

--[[
    @desc: 此处是填写地图的奖励列表
    author:coldflag
    time:2021-08-24 15:18:01
    @return: 
]]
function ThemeParkFreeSpin:InitRewardMapList()
    
    self.mapRewardMap = ThemeParkConfig:SetFreeSpinMapReward()

end


--[[
    @desc: 根据人物的倍率和当前押注数，计算应该显示的人物的价格，用于在选择人物的时候显示
    author:coldflag
    time:2021-08-27 11:09:44
    @return: 整形数组-人物价格
]]
function ThemeParkFreeSpin:GetArrayOfCharacterPrize()
    local arrayCharacterPrize = ThemeParkConfig:GetCharactersStartPrize()

    for i = 1, #arrayCharacterPrize do 

        self.mapCharacterData[i].prize = arrayCharacterPrize[i] -- 顺便将卡牌上要显示的人物价格也更新一下，以float类型存储

        local sPrize = MoneyFormatHelper.coinCountOmit(arrayCharacterPrize[i], 0)
        arrayCharacterPrize[i] = sPrize
    end

    return arrayCharacterPrize
end



function ThemeParkFreeSpin:GetNowCharacterID()
    if self.nCharacterID then
        return self.nCharacterID
    end
end

-- 覆盖人物的倍乘系数为mMultiplier
function ThemeParkFreeSpin:FlushCharMultiplier(mMultiplier)
    local nCharacterID = LevelUI.CharacterSelectUI:GetSelectedCharacterID()
    local rv = false
    if self.mapCharacterData and #self.mapCharacterData == 4 then
        for k, v in pairs(self.mapCharacterData) do
            if k == nCharacterID then
                v.multiplier = mMultiplier
                self:setCharMultiplierToDB(v.multiplier)
                rv =true
                break
            end
        end
    end

    return rv
end

--[[
    @desc: 角色@strCharacter 的倍乘系数加一
    author:coldflag
    time:2021-08-23 18:41:02
    --@strCharacter: 角色名称
        dad, mom, girl, boy
    @return:
]]
function ThemeParkFreeSpin:IncreaseCharMultiplier(nCharID)
    local rv = false
    if self.mapCharacterData and #self.mapCharacterData == 4 then
        for k, v in pairs(self.mapCharacterData) do
            if k == nCharID then
                v.multiplier = v.multiplier + 1
                self:setCharMultiplierToDB(v.multiplier)
                rv = true
                break
            end
        end
    end

    return rv
end

function ThemeParkFreeSpin:ReturnCharMultiplier(nCharID)
    local nrv = -1
    
    if self.mapCharacterData and #self.mapCharacterData == 4 then
        for k, v in pairs(self.mapCharacterData) do
            if k == nCharID then
                nrv = v.multiplier
                break
            end
        end
    end

    return nrv
end

--[[
    @desc: 将人物的价格 覆盖 为fPrize，(此函数不更改画面显示)
    author:coldflag
    time:2021-09-07 18:29:10
    --@fPrize: 
    @return:
]]
function ThemeParkFreeSpin:FlushCharPrize(fPrize)
    local nCharacterID = LevelUI.CharacterSelectUI:GetSelectedCharacterID()
    local rv = false
    if self.mapCharacterData and #self.mapCharacterData == 4 then
        for k, v in pairs(self.mapCharacterData) do
            if k == nCharacterID then
                v.prize = fPrize
                rv = true
                break
            end
        end
    end

    return rv
end

--[[
    @desc: 角色 @strCharacter 的价格增加 @fPrize
    author:coldflag
    time:2021-08-23 18:50:17
    --@strCharacter: 角色名称
	--@fPrize: 要增加的价格
    @return:
]]
function ThemeParkFreeSpin:IncreaseCharPrize(nCharID, fPrize)
    local rv = false
    if self.mapCharacterData and #self.mapCharacterData == 4 then
        for k, v in pairs(self.mapCharacterData) do
            if k == nCharID then
                v.prize = v.prize + fPrize
                self:setCharPrizeToDB(v.prize)
                rv = true
                break
            end
        end
    end

    return rv
end

function ThemeParkFreeSpin:ReturnCharPrize(nCharID)
    local frv = -1.0
    
    if self.mapCharacterData and #self.mapCharacterData == 4 then
        for k, v in pairs(self.mapCharacterData) do
            if k == nCharID then
                frv = v.prize
                break
            end
        end
    end

    return frv
end

--[[
    @desc: v["multiplier"] 和 v["prize"]的乘积
    author:coldflag
    time:2021-08-24 10:38:47
    --@strCharacter: 
    @return: 角色的价格 X 角色的倍乘系数
]]
function ThemeParkFreeSpin:CharPrizeXMutiple(nCharID)
    if self.mapCharacterData and #self.mapCharacterData == 4 then
        for k, v in pairs(self.mapCharacterData) do
            if k == nCharID then
                return v.multiplier * v.prize
            end
        end
    end
end

--[[
    @desc: 增加FreeSpin的次数
    author:coldflag
    time:2021-08-23 17:57:36
    --@nFreeSpinTime: 要增加的FreeSpin的次数
    @return:
]]
function ThemeParkFreeSpin:IncreaseFreeSpinTimes(nFreeSpinTimes)
    local rv = false
    if nFreeSpinTimes and SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount then
        SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount + nFreeSpinTimes
        rv = true
    end

    return rv
end

--[[
    @desc: 减少一次FreeSpin的次数
    author:coldflag
    time:2021-08-23 17:54:49
    @return:
]]
function ThemeParkFreeSpin:declineOneFreeSpinsTime()
    local rv = false
    if SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount > 0 then
        SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount - 1
        rv = true
    end

    return rv
end


function ThemeParkFreeSpin:GetFreeSpinRemainderTimes()
    return SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount - SlotsGameLua.m_GameResult.m_nFreeSpinCount
end

--[[
    @desc: FreeSpin中，气球符号奖励一次抽奖机会
    author:coldflag
    time:2021-08-24 10:42:06
    @return: 1-6 Free Spins
]]
function ThemeParkFreeSpin:ExtraFreeSpinBalloon()
    local nResult = ThemeParkConfig:GetExtraFreeSpinTime_Balloon()

    return nResult
end

-- 判断是否是捷径的起点
function ThemeParkFreeSpin:IsBypassPos(nPosID)
    return nPosID == 10 or nPosID == 21 or nPosID == 31
end

--[[
    @desc: 普通连续状态下的移动，此模式下，ID是连续递增的
    author:coldflag
    time:2021-08-24 11:54:09
    --@nPosID: 坐标ID
	--@nDistance: 移动的距离
    @return: 经过位置的有序坐标集
]]
function ThemeParkFreeSpin:NormalMove(nPosID, nDistance)
    local mapPosV3 = {}

    for i = 1, nDistance do
        local posV3 = ThemeParkFreeSpinUI:GetPosV3byPosID(1, nPosID + i)
        table.insert(mapPosV3, posV3)
        self.nCurPosID = nPosID + i
        self.nCurModID = 1
    end

    return mapPosV3
end

function ThemeParkFreeSpin:MoveBypassA(nPosID, nDistance)
    local mapPosV3 = {}
    -- 如果在捷径1的入口，则修改位置ID
    if nPosID == 10 then
        nPosID = 0
    end
    -- 捷径剩余的路程小于要移动的路程，要跳格子了。。。。。
    if nDistance > #ThemeParkFreeSpinUI.mapFreeSpinMapPos[2] - nPosID then
        local nPassedDistance = 0
        -- 在捷径中能够移动的距离
        for i = 1, #ThemeParkFreeSpinUI.mapFreeSpinMapPos[2] - nPosID do
            local posV3 = ThemeParkFreeSpinUI:GetPosV3byPosID(2, nPosID + i)
            table.insert(mapPosV3, posV3)
            nPassedDistance = nPassedDistance + 1
            self.nCurModID = 2
            self.nCurPosID = nPosID + i
        end

        -- 在正常路程中完成剩下的路程
        for i = 0, nDistance - nPassedDistance - 1 do
            local posV3 = ThemeParkFreeSpinUI:GetPosV3byPosID(1, 26 + i) -- 捷径的出口编号为26
            table.insert(mapPosV3, posV3)
            self.nCurModID = 1
            self.nCurPosID = 26 + i
        end
    else
        for i = 1, nDistance do
            local posV3 = ThemeParkFreeSpinUI:GetPosV3byPosID(2, nPosID + i)
            table.insert(mapPosV3, posV3)
            self.nCurModID = 2
            self.nCurPosID = nPosID + i
        end
    end

    return mapPosV3
end

--[[
    @desc: 第二个捷径的走法
    author:coldflag
    time:2021-09-07 18:21:30
    --@nPosID: 位置的ID
	--@nDistance: 要走的距离
    @return: 经过的点的有序集
]]
function ThemeParkFreeSpin:MoveBypassB(nPosID, nDistance)
    local mapPosV3 = {}
    -- 如果在捷径2的入口，则修改位置ID
    if nPosID == 21 then
        nPosID = 0
    end
    -- 捷径剩余的路程小于要移动的路程，要跳格子了。。。。。
    if nDistance > #ThemeParkFreeSpinUI.mapFreeSpinMapPos[3] - nPosID then
        local nPassedDistance = 0
        -- 在捷径中能够移动的距离
        for i = 1, #ThemeParkFreeSpinUI.mapFreeSpinMapPos[3] - nPosID do
            local posV3 = ThemeParkFreeSpinUI:GetPosV3byPosID(3, nPosID + i)
            table.insert(mapPosV3, posV3)
            nPassedDistance = nPassedDistance + 1
            self.nCurModID = 3
            self.nCurPosID = nPosID + i
        end

        -- 在正常路程中完成剩下的路程
        for i = 0, nDistance - nPassedDistance - 1 do
            local posV3 = ThemeParkFreeSpinUI:GetPosV3byPosID(1, 33 + i) -- 捷径的出口编号为33
            table.insert(mapPosV3, posV3)
            self.nCurModID = 1
            self.nCurPosID = 33 + i
        end
    else
        for i = 1, nDistance do
            local posV3 = ThemeParkFreeSpinUI:GetPosV3byPosID(3, nPosID + i)
            table.insert(mapPosV3, posV3)
            self.nCurModID = 3
            self.nCurPosID = nPosID + i
        end
    end

    return mapPosV3
end

function ThemeParkFreeSpin:MoveBypassC(nPosID, nDistance)
    -- 直接进入小丑转盘游戏
    return
end

--[[
    @desc: 正常路径上最后5个格子，因为可能会循环到前面的29号格子，所以不能直接把格子的ID相加，而是需要单独处理
    author:coldflag
    time:2021-08-24 16:08:31
    --@nPosID:
	--@nDistance: 
    @return:
]]
function ThemeParkFreeSpin:MoveNormalLast5Elem(nPosID, nDistance)
    local mapPosV3 = {}
    if nDistance > #ThemeParkFreeSpinUI.mapFreeSpinMapPos[1] - nPosID then
        local nPassedDistance = 0
        -- 走完这一轮剩余的路程
        for i = 1, #ThemeParkFreeSpinUI.mapFreeSpinMapPos[1] - nPosID do
            local posV3 = ThemeParkFreeSpinUI:GetPosV3byPosID(1, nPosID + i)
            table.insert(mapPosV3, posV3)
            nPassedDistance = nPassedDistance + 1
            self.nCurModID = 1
            self.nCurPosID = nPosID + i
        end

        -- 下面就是继续套娃
        for i = 0, nDistance - nPassedDistance - 1 do
            local posV3 = ThemeParkFreeSpinUI:GetPosV3byPosID(1, 29 + i) -- 轮询的七点编号为29
            table.insert(mapPosV3, posV3)
            self.nCurModID = 1
            self.nCurPosID = 29 + i
        end
    else
        mapPosV3 = self:NormalMove(nPosID, nDistance)
    end

    return mapPosV3
end

--[[
    @desc: 
    author:coldflag
    time:2021-08-24 11:26:55
    --@nPosID: 坐标ID
	--@nDistance: 移动的距离
    @return: 移动需要经过的Vector3坐标集
]]
function ThemeParkFreeSpin:GetMovePath(nDistance)
    local mapPosV3 = {}
    
    if self.nCurModID == 1 and not self:IsBypassPos(self.nCurPosID) and self.nCurPosID <= 37 then -- 这个情况下一定是按照正常的顺序移动的
        mapPosV3 = self:NormalMove(self.nCurPosID, nDistance)
    elseif self.nCurPosID == 10 or self.nCurModID == 2 then
        mapPosV3 = self:MoveBypassA(self.nCurPosID, nDistance)
    elseif self.nCurPosID == 21 or self.nCurModID == 3 then
        mapPosV3 = self:MoveBypassB(self.nCurPosID, nDistance)
    elseif self.nCurPosID == 31 then
        mapPosV3 = self:MoveBypassC(self.nCurPosID, nDistance)
    elseif self.nCurPosID > 37 and self.nCurPosID <= 43 then
        mapPosV3 = self:MoveNormalLast5Elem(self.nCurPosID, nDistance)
    else
        -- break
    end

    return mapPosV3
end

--[[
    @desc: 是否需要将地图图片向下移动
    author:coldflag
    time:2021-09-07 18:17:34
    @return:
]]
function ThemeParkFreeSpin:IsNeedToDownMap()
    if self.nCurModID == 1 and self.nCurPosID > 21 then
        return true
    end

    return false
end

--[[
    @desc: 判断角色停下来的时候的奖励类型，并颁奖
    author:coldflag
    time:2021-08-24 15:12:46
    @return:
]]
function ThemeParkFreeSpin:JudgeReward()
    -- 先判断是否需要向下移动地图，如果需要，则移动，且下次不再移动
    if not self.bHasDownMap and self:IsNeedToDownMap() then
        ThemeParkFreeSpinUI:DownMap()
        self.bHasDownMap = true
    end
    
    local nRewardID = self.mapRewardMap[self.nCurModID][self.nCurPosID]
    if nRewardID == 0 then
        -- 无事发生
        ThemeParkFreeSpin.bMapRewardFinish = true
        Debug.Log("Start Point")
    elseif nRewardID == 1 then
        --金币
        local fCoinNum = ThemeParkConfig:GetGoldCoin_Coin()
        LevelUI.GoldCoinSplashUI:Show(nRewardID, fCoinNum)

        local addRewardCoinTime = ThemeParkConfig.FreeSpinAddRewardCoinTime
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins + fCoinNum
        SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins

        SceneSlotGame.m_SlotsNumberWins:ChangeTo(SlotsGameLua.m_GameResult.m_fGameWin, addRewardCoinTime) -- 底部显示的金钱数量增加

        local SplashTime = ThemeParkConfig.FreeSpinGameRewardSplashTime
        LeanTween.delayedCall(SplashTime, function()
            LevelUI.GoldCoinSplashUI:Hide()       --    - bMapRewardFinish -  GoldCoinSplashUI:Hide()中置为true
        end)

    elseif nRewardID == 2 then
        -- 气球狗
        local fCoinNum = ThemeParkConfig:GetGoldCoin_Dog()
        LevelUI.GoldCoinSplashUI:Show(nRewardID, fCoinNum)

        local addRewardCoinTime = ThemeParkConfig.FreeSpinAddRewardCoinTime
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins + fCoinNum
        SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins

        SceneSlotGame.m_SlotsNumberWins:ChangeTo(SlotsGameLua.m_GameResult.m_fGameWin, addRewardCoinTime) -- 底部显示的金钱数量增加

        local SplashTime = ThemeParkConfig.FreeSpinGameRewardSplashTime
        LeanTween.delayedCall(SplashTime, function()
            LevelUI.GoldCoinSplashUI:Hide()       --    - bMapRewardFinish -  GoldCoinSplashUI:Hide()中置为true
        end)
        
    elseif nRewardID == 3 then
        -- 额外一次骰子机会
        -- 此处应该播放   骰子UI
        ThemeParkFreeSpinUI:PlayCharMoveScene() -- 此处是再次调用骰子流程
    elseif nRewardID == 4 then
        -- 礼盒
        local fReward = ThemeParkConfig:GetGiftBoxPrize()
        LevelUI.GiftBoxSplashUI:Show(fReward)

        local addRewardCoinTime = ThemeParkConfig.FreeSpinAddRewardCoinTime
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins + fReward
        SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins

        SceneSlotGame.m_SlotsNumberWins:ChangeTo(SlotsGameLua.m_GameResult.m_fGameWin, addRewardCoinTime) -- 底部显示的金钱数量增加

        local SplashTime = ThemeParkConfig.FreeSpinGameRewardSplashTime
        LeanTween.delayedCall(SplashTime, function()
            LevelUI.GiftBoxSplashUI:Hide()       --    - bMapRewardFinish -  GiftBoxSplashUI:Hide()中置为true
        end)
    elseif nRewardID == 5 then
        -- 箭靶
        local fCoinNum = ThemeParkConfig:GetGoldCoin_Archery()
        LevelUI.GoldCoinSplashUI:Show(nRewardID, fCoinNum)

        local addRewardCoinTime = ThemeParkConfig.FreeSpinAddRewardCoinTime
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins + fCoinNum
        SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins

        SceneSlotGame.m_SlotsNumberWins:ChangeTo(SlotsGameLua.m_GameResult.m_fGameWin, addRewardCoinTime) -- 底部显示的金钱数量增加

        local SplashTime = ThemeParkConfig.FreeSpinGameRewardSplashTime
        LeanTween.delayedCall(SplashTime, function()
            LevelUI.GoldCoinSplashUI:Hide()       --    - bMapRewardFinish -  GoldCoinSplashUI:Hide()中置为true
        end)
    elseif nRewardID == 6 then
        -- 小票
        ThemeParkFreeSpin.bMapRewardFinish = true
        Debug.Log("Reward Card")
    elseif nRewardID == 7 then
        -- 宝箱
        local nCharacterID = LevelUI.CharacterSelectUI:GetSelectedCharacterID()
        local fPrize = self:ReturnCharPrize(nCharacterID)
        local nMulti = self:ReturnCharMultiplier(nCharacterID)
        LevelUI.ChestSplashUI:Show(fPrize, nMulti)

        local fTotalWin = self:CharPrizeXMutiple(nCharacterID)

        local addRewardCoinTime = ThemeParkConfig.FreeSpinAddRewardCoinTime
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins + fTotalWin
        SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins

        SceneSlotGame.m_SlotsNumberWins:ChangeTo(SlotsGameLua.m_GameResult.m_fGameWin, addRewardCoinTime) -- 底部显示的金钱数量增加

        local SplashTime = ThemeParkConfig.FreeSpinGameRewardSplashTime
        LeanTween.delayedCall(SplashTime, function()
            LevelUI.ChestSplashUI:Hide()       --    - bMapRewardFinish -  在ChestSplashUI:Hide()中置为true
        end)
    elseif nRewardID == 8 then
        -- 这是捷径，无事发生
        ThemeParkFreeSpin.bMapRewardFinish = true
        Debug.Log("落在捷径出发点了")
    else
        ThemeParkFreeSpin.bMapRewardFinish = true
        -- break
    end

    local structPosition = {self.nCurModID, self.nCurPosID}
    self:setCharPositionToDB(structPosition)
end

--[[
    @desc: 第三列都是Wild，持续三回合
    author:coldflag
    time:2021-08-23 19:07:59
    @return:
]]
function ThemeParkFreeSpin:SuperSlideLand()
    -- 暂不需要
end


function ThemeParkFreeSpin:GetDice1OrDice2()
    return 1
end

-------------------------------------------数据保存函数-------------------------------------------------

--[[
    @desc: 保存人物位置信息到数据库
    author:coldflag
    time:2021-09-02 15:21:04
    --@structPosition: 表示人物位置的结构体
    @return:
]]
function ThemeParkFreeSpin:setCharPositionToDB(structPosition)
    local sLevelName = ThemeLoader.themeKey
    if LevelDataHandler.m_Data.LevelParams[sLevelName] == nil then
        LevelDataHandler.m_Data.LevelParams[sLevelName] = {}
    end
    LevelDataHandler.m_Data.LevelParams[sLevelName].structPosition = structPosition
    LevelDataHandler:persistentData()
    Debug.Log("Save structPosition: " .. structPosition[1] .. "  " .. structPosition[2])
end

function ThemeParkFreeSpin:getCharPositionFromDB()
    local param = LevelDataHandler.m_Data
    if param == nil then
        return nil
    end

    if param.structPosition == nil then
        return nil
    end
    Debug.Log("Achieve structPosition: " .. param.structPosition[1] .. "  " .. param.structPosition[2])
    return param.structPosition
end


function ThemeParkFreeSpin:setCharPrizeToDB(fCharacterPrize)
    local sLevelName = ThemeLoader.themeKey
    if LevelDataHandler.m_Data.LevelParams[sLevelName] == nil then
        LevelDataHandler.m_Data.LevelParams[sLevelName] = {}
    end
    LevelDataHandler.m_Data.LevelParams[sLevelName].fCharacterPrize = fCharacterPrize
    LevelDataHandler:persistentData()
    Debug.Log("Save prize: " .. fCharacterPrize)
end


function ThemeParkFreeSpin:getCharPrizeFromDB()
    local param = LevelDataHandler.m_Data
    if param == nil then
        return nil
    end

    if param.fCharacterPrize == nil then
        return nil
    end
    Debug.Log("Achieve prize: " .. param.fCharacterPrize)
    return param.fCharacterPrize
end


function ThemeParkFreeSpin:setCharMultiplierToDB(nMultiplier)
    local sLevelName = ThemeLoader.themeKey
    if LevelDataHandler.m_Data.LevelParams[sLevelName] == nil then
        LevelDataHandler.m_Data.LevelParams[sLevelName] = {}
    end
    LevelDataHandler.m_Data.LevelParams[sLevelName].nMultiplier = nMultiplier
    LevelDataHandler:persistentData()
    Debug.Log("Save multiplier: " .. nMultiplier)
end

function ThemeParkFreeSpin:getCharMultiplierFromDB()
    local param = LevelDataHandler.m_Data
    if param == nil then
        return nil
    end

    if param.nMultiplier == nil then
        return nil
    end
    Debug.Log("Achieve multiplier: " .. param.nMultiplier)
    return param.nMultiplier
end

function ThemeParkFreeSpin:setDownMapFlagToDB()
    local sLevelName = ThemeLoader.themeKey
    if LevelDataHandler.m_Data.LevelParams[sLevelName] == nil then
        LevelDataHandler.m_Data.LevelParams[sLevelName] = {}
    end
    LevelDataHandler.m_Data.LevelParams[sLevelName].bHasDownMap = self.bHasDownMap
    LevelDataHandler:persistentData()
end

function ThemeParkFreeSpin:getDownMapFlagToDB()
    local param = LevelDataHandler.m_Data
    if param == nil then
        return nil
    end

    if param.bHasDownMap == nil then
        return nil
    end

    return param.bHasDownMap
end