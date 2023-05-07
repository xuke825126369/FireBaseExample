--[[
    author:coldflag
    time:2021-08-17 16:49:53
]]

ThemeParkConfig = {}

-------------------------------------时间参数-------------------------------------
ThemeParkConfig.DelayPlayScatterBonus = 1.5 -- 普通模式下出现3个Scatter后，延迟播放Bonus动画的时间

ThemeParkConfig.FreeSpinUpMap = 0.3 -- Start后向上移动地图的时间
ThemeParkConfig.FreeSpinDowmMapContentTime = 0.6 -- 人物移动到中间的时候，需要将地图图画向下移动的时间
ThemeParkConfig.FreeSpinCharacterMoveTimePerStep = 1.16 -- 人物在地图上移动一格需要的时间
ThemeParkConfig.FreeSpinFollowParticleMoveTime = 0.6 -- 跟随粒子飞行时间
ThemeParkConfig.FreeSpinCardParticleShowTime = 0.3
ThemeParkConfig.FreeSpinSecendScatterDeleyTimeAfterComplete = 0.5 -- 第二个Scatter动作做完后，延迟放开yield的时间
ThemeParkConfig.FreeSpinDelayFinishTime = 0.7 -- Scatter和人物奖励特效做完后，延迟1秒结束当前回合
ThemeParkConfig.FreeSpinGameRewardSplashTime = 4 -- FreeSpin小游戏中获得奖励的弹窗时间
ThemeParkConfig.FreeSpinAddRewardCoinTime = 1 -- FreeSpin小游戏获得金币后加到底部的时间

ThemeParkConfig.FreeSpinSplashUILifeTime = 5 -- FreeSpin Begin、Finish、Again 的生命周期时间
ThemeParkConfig.FreeSpinSplashCanQuickHideTime = 1.5 --FreeSpin Begin、Finish、Again需要等待一段时间才可以点击关闭
ThemeParkConfig.FreeSpinExtraCloseDelaySpinAgain = 0.6 -- ExtraFreeSpin 弹窗结束后，过 1 秒后再开始下一个spin回合

ThemeParkConfig.FreeSpinDiceTime = 2


----------------------------------其他一些数值参数------------------------------
ThemeParkConfig.NewFreeSpinTimesInScatterBonus = 18 -- 普通场景下出现三个Scatter的时候，奖励的FreeSpin的数量
ThemeParkConfig.FreeSpinTimes_3rdScatter = 3 -- FreeSpin 中，第三个scatter奖励的FreeSpin次数
ThemeParkConfig.FreeSpin_HotAirBalloonTrip_FreeSpinNums = 3 -- Hot Air Balloon Trip 的初始FreeSpin次数







---------------------------------------概率控制------------------------------------
--[[
    @desc: 是否会掉落Wild，并从Wild,Wildx2,Wildx3中选择一个掉落
    author:coldflag
    time:2021-08-17 16:58:27
    @return: Wild,Wildx2,Wildx3其中一个
]]
function ThemeParkConfig:GetWildKind()
    local fTriggerRate = 0.2  
    local mapWildKindRate = {100, 10, 1} -- 此处索引从1开始 = =！，分别是Wild, Wildx2, Wildx3

    local bTrigger = math.random() < fTriggerRate
    local nIndex = LuaHelper.GetIndexByRate(mapWildKindRate)
    local nWildID = 0
    if nIndex == 1 then  -- Wild
        nWildID = 9
    elseif nIndex == 2 then -- Wildx2
        nWildID = 10
    elseif nIndex == 3 then -- Wildx3
        nWildID = 11
    else 
        Debug.Log("-------------Unknown WildID!!!------------")
    end
    return bTrigger, nWildID
end

--[[
    @desc: 返回这次Spin会出多少个Scatter
    author:coldflag
    time:2021-08-18 19:20:17
    @return: Scatter的数量
]]
function ThemeParkConfig:GetScatterNums()
    local mapScatterNumRate = {1, 1, 1} -- 分别是一个Scatter，两个Scatter， 三个Scatter
    local mapScatterNum = {1,2,3}
    local nIndex = LuaHelper.GetIndexByRate(mapScatterNumRate)
    local nScatterNum = mapScatterNum[nIndex]

    return nScatterNum
end

--[[
    @desc: 填入FreeSpin的地图奖励表
    起点：0 无事发生
    金币：1
    气球：2
    骰子：3
    礼盒：4
    箭靶：5
    小票：6
    宝箱：7
    捷径：8 无事发生
    author:coldflag
    time:2021-08-24 15:25:15
    @return:
]]
function ThemeParkConfig:SetFreeSpinMapReward()
    local mapNormalWayReward = {0,1,2,1,3,4,5,1,4,8,6,7,1,4,2,1,3,4,1,2,8,6,1,5,4,1,4,3,4,2,8,1,7,1,4,1,5,2,6,4,1,3,1} -- 第四个原本是1，3，4，被改为了7
    local mapBypassAReward = {3,1,7}
    local mapBypassBReward = {1,3}

    local mapReward = {mapNormalWayReward, mapBypassAReward, mapBypassBReward}

    return mapReward
end

--[[
    @desc: 根据角色的ID来选择投骰子的概率
    author:coldflag
    time:2021-08-25 15:21:48
    --@nCharacterID: 人物角色ID
    @return: 投骰子的结果
]]
function ThemeParkConfig:Dice(nCharacterID)
    local nResult = 0
    if nCharacterID == 1 then
        nResult = self:BoyDice()
    elseif nCharacterID == 2 then
        nResult = self:GirlDice()
    elseif nCharacterID == 3 then
        nResult = self:MomDice()
    elseif nCharacterID == 4 then
        nResult = self:DadDice()
    end

    return nResult
end

function ThemeParkConfig:DadDice()
    local mapDiceNum = {1,2,3,4,5,6}
    local mapDiceRate = {1,1,1,1,1,1}
    local nIndex = LuaHelper.GetIndexByRate(mapDiceRate)
    local nDiceNum = mapDiceNum[nIndex]

    return nDiceNum
end

function ThemeParkConfig:MomDice()
    local mapDiceNum = {1,2,3,4,5,6}
    local mapDiceRate = {1,1,1,1,1,1}
    local nIndex = LuaHelper.GetIndexByRate(mapDiceRate)
    local nDiceNum = mapDiceNum[nIndex]

    return nDiceNum
end

function ThemeParkConfig:GirlDice()
    local mapDiceNum = {1,2,3,4,5,6}
    local mapDiceRate = {1,1,1,1,1,1}
    local nIndex = LuaHelper.GetIndexByRate(mapDiceRate)
    local nDiceNum = mapDiceNum[nIndex]

    return nDiceNum
end

function ThemeParkConfig:BoyDice()
    local mapDiceNum = {1,2,3,4,5,6}
    local mapDiceRate = {1,1,1,1,1,1}
    local nIndex = LuaHelper.GetIndexByRate(mapDiceRate)
    local nDiceNum = mapDiceNum[nIndex]

    return nDiceNum
end

--[[
    @desc: 返回四个角色的初始价格表
    author:coldflag
    time:2021-08-31 11:45:02
    @return: 初始价格表，Float类型
]]
function ThemeParkConfig:GetCharactersStartPrize()
    local mapCoef = {1,2,3,4} -- 初始价格与总压住数的倍率，与人物ID对应
    local nTotalBet = SceneSlotGame.m_nTotalBet

    local arrayCharacterStartPrize = {}
    for k, v in pairs(mapCoef) do
        local fPrize = nTotalBet * v
        table.insert(arrayCharacterStartPrize, fPrize)
    end

    return arrayCharacterStartPrize
end

--[[
    @desc: 戳气球获得额外的FreeSpin的次数
    author:coldflag
    time:2021-08-25 15:53:48
    @return: 戳破气球后显示的FreeSpin次数
]]
function ThemeParkConfig:GetExtraFreeSpinTime_Balloon()
    local mapTimesRate = {1,1,1,1,1,1} -- 6种数值分别对应的概率
    local mapExtraTimes = {1,2,3,4,5,6}
    local nIndex = LuaHelper.GetIndexByRate(mapTimesRate)
    local nExtraTimes = mapExtraTimes[nIndex]

    return nExtraTimes
end

--[[
    @desc: 人物卡片在这些线上的话，就需要增加人物的prize了
    author:coldflag
    time:2021-08-25 15:30:27
    @return: 在 或者 不在
]]
function ThemeParkConfig:IsIn_NeedToIncreasePrize_Lines(nLineID)
    local mapLines = self:Return_NeedToIncreasePrize_Lines()
    
    local bResult = Tool:IsElemInTable(nLineID, mapLines)

    return bResult
end

function ThemeParkConfig:Return_NeedToIncreasePrize_Lines()
    local mapLines = {2}

    return mapLines
end

--[[
    @desc: 
    author:coldflag
    time:2021-08-31 11:46:53
    --@nCharacterID: 角色ID，应该个SymbolID相同
    @return: FreeSpin滚动中，IsIn_NeedToIncreasePrize_Lines(nLineID)结果中，每个Symbol@nCharacterID对应的价格
]]
function ThemeParkConfig:GetPrizePerSymbol(nCharacterID)
    local mapPrize = {}
    local fCeof = 0.1
    local mapStartPrize = self:GetCharactersStartPrize()
    local nTotalBet = SceneSlotGame.m_nTotalBet
    for i = 1, 4 do
        local fPrize = mapStartPrize[i] * fCeof
        table.insert(mapPrize, fPrize)
    end

    return mapPrize[nCharacterID]
end


function ThemeParkConfig:GetGiftBoxPrize()
    local mapRate = {1,1,1,1,1,1} -- 6种数值分别对应的概率
    local mapCoef = {1,2,3,4,5,6}
    local nIndex = LuaHelper.GetIndexByRate(mapRate)
    local nCoef = mapCoef[nIndex]

    local nTotalBet = SceneSlotGame.m_nTotalBet

    return nTotalBet * nCoef
end

--@desc: 小游戏中金币标志格子给的奖励数量
function ThemeParkConfig:GetGoldCoin_Coin()
    local mapRate = {1,1,1,1,1,1} -- 6种数值分别对应的概率
    local mapCoef = {1,2,3,4,5,6}
    local nIndex = LuaHelper.GetIndexByRate(mapRate)
    local nCoef = mapCoef[nIndex]

    local nTotalBet = SceneSlotGame.m_nTotalBet

    return nTotalBet * nCoef
end


function ThemeParkConfig:GetGoldCoin_Dog()
    local mapRate = {1,1,1,1,1,1} -- 6种数值分别对应的概率
    local mapCoef = {1,2,3,4,5,6}
    local nIndex = LuaHelper.GetIndexByRate(mapRate)
    local nCoef = mapCoef[nIndex]

    local nTotalBet = SceneSlotGame.m_nTotalBet

    return nTotalBet * nCoef
end


function ThemeParkConfig:GetGoldCoin_Archery()
    local mapRate = {1,1,1,1,1,1} -- 6种数值分别对应的概率
    local mapCoef = {1,2,3,4,5,6}
    local nIndex = LuaHelper.GetIndexByRate(mapRate)
    local nCoef = mapCoef[nIndex]

    local nTotalBet = SceneSlotGame.m_nTotalBet

    return nTotalBet * nCoef
end

--[[
    @desc: 判断刮卡出现的是哪个小游戏
    author:coldflag
    time:2021-09-09 11:39:59
    @return:
]]
function ThemeParkConfig:GetLotteryAwardType()
    local mapRate = {1,1,1,1,1} -- 5种游戏分别对应的概率
    -- 1 Super Slide Land, 2 Hot Air Balloon Trip,  3 Ferris Whieel Dream,  4 Music Fountain, 5 Lolly SHop
    local nIndex = LuaHelper.GetIndexByRate(mapRate)


    -----Debug-------
    nIndex = 2
    -----------------


    return nIndex
end