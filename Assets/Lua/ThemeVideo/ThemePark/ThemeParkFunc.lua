--[[
    author:coldflag
    time:2021-08-11 11:38:15
]]
require "Lua/ThemeVideo2020/ThemePark/Tool"
require "Lua/ThemeVideo2020/ThemePark/ThemeParkLevelUI"
require "Lua/ThemeVideo2020/ThemePark/ThemeParkSymbol"
require "Lua/ThemeVideo2020/ThemePark/ThemeParkConfig"
require "Lua/ThemeVideo2020/ThemePark/ThemeParkFreeSpin"
require "Lua/ThemeVideo2020/ThemePark/ThemeParkFreeSpinUI"


ThemeParkFunc = {}
ThemeParkFunc.mapSymbolRectMaskGroup = {} -- 符号的遮罩信息
ThemeParkFunc.arrayHitSymbol = {} -- 包含了所有中奖元素的位置






function ThemeParkFunc:init()
    self.transform = ThemeVideo2020Scene.mNewGameNodeParent.transform:FindDeepChild("LevelBG")
    self.goLuckSpin = self.transform:FindDeepChild("Luckyspin").gameObject
    self.goLuckSpin:SetActive(false)
end



--[[
    @desc: 
    author:coldflag
    time:2021-08-12 15:58:29
    --@nReelId: 暂时无用，留作扩展
    @return: Custom Rect Mask Group 
]]
function ThemeParkFunc:GetMaskGroup()
    local group = ThemeParkLevelUI.m_cpDefaultMaskGroup -- 从LevelUI中获取遮罩区域

    Debug.Assert(group)

    return group
end

--[[
    @desc: 给符号关联遮罩组件
    author:coldflag
    time:2021-08-12 15:42:33
    --@goSymbol: Symbol Game Object
	--@group: Custom Rect Mask Group 
    @return: void
]]
function ThemeParkFunc:SetSymbolRectGroup(goSymbol, group)
    if self.mapSymbolRectMaskGroup ~= nil and self.mapSymbolRectMaskGroup[goSymbol] == group then
        return
    end

    if (goSymbol == nil) then
        Debug.Log("goSymbol is NULL, print at 50 in ThemeParkFunc.lua")
    end

    self.mapSymbolRectMaskGroup[goSymbol] = group
    self.mapSymbolRectMaskGroupChildren = {}
    if not self.mapSymbolRectMaskGroupChildren[goSymbol] then
        -- 返回这个Symbol下所有的孩子节点的列表
        local rectMaskGroupChildren = LuaHelper.GetComponentsInChildren(goSymbol, typeof(CS.CustomerRectMaskGroupChildren))

        -- 将这个孩子列表存到mapSymbolRectMaskGroupChildren表中
        self.mapSymbolRectMaskGroupChildren[goSymbol] = rectMaskGroupChildren
    end

    -- 为这个节点对应的所有孩子节点都关联遮罩区域，并且不用alpha遮罩
    for k, v in pairs(self.mapSymbolRectMaskGroupChildren[goSymbol]) do
        v.ValidParentMaskGroup = false -- 不用alpha遮罩
        v:SetGroupMask(group) -- 关联遮罩区域
    end
end

--[[ ================貌似不需要，先保留=============
    @desc: 在播放了Scatter特效后，在下一次Spin之前，重新检查所有符号是否设置了遮罩
    author:coldflag
    time:2021-08-20 19:03:46
    @return:
]]
function ThemeParkFunc:ResetRectMaskGroupAfterScatterEffect()
    for key = 0, 14 do
        local nRowCount = SlotsGameLua.m_nRowCount
        local nReelID = math.floor(key / nRowCount)
        local nRowIndex = math.floor(key % nRowCount)

        local listGoSymbol = SlotsGameLua.m_listReelLua[nReelID].m_listGoSymbol
        local goSymbol = listGoSymbol[nRowIndex]

        self:SetSymbolRectGroup(goSymbol, self:GetMaskGroup())
    end
end

--[[
    @desc: 通过符号ID获得符号预制件，并从符号缓存池中取出，调用SetSymbolRectGroup(goSymbol, group)为每个符号关联遮罩组件
    author:coldflag
    time:2021-08-12 15:45:02
    --@nSymbolId: 符号ID
	--@group: Custom Rect Mask Group
    @return: 返回单个Symbol Game Object
]]
function ThemeParkFunc:SpawnSymbolByGroup(nSymbolId, group)
    local prefab = SlotsGameLua:GetSymbol(nSymbolId).prfab
    local goSymbol = SymbolObjectPool:Spawn(prefab)
    if (goSymbol == nil) then
        Debug.Log("goSymbol is NULL, print at 80 in ThemeParkFunc.lua")
    end
    self:SetSymbolRectGroup(goSymbol, group)

    return goSymbol
end

--[[
    @desc: 为符号设置order，使得下面的符号压住上面，右边的符号压住左边。
           特别的，wild和scatter符号压住其他符号。
    author:coldflag
    time:2021-08-12 15:29:38
    --@goSymbol: Symbol Game Object
	--@nSymbolId: Symbol ID in CFG File
	--@nReelId: Reel ID
	--@nRowIndex: Index of Row, similar with nReelId
    @return: 已经设置好遮罩的Symbol Game Object
]]
function ThemeParkFunc:SetSortingGroup(goSymbol, nSymbolId, nReelId, nRowIndex)
    local order = -100
    if nRowIndex < SlotsGameLua.m_nRowCount then
        order = -90 + nReelId * SlotsGameLua.m_nRowCount + (SlotsGameLua.m_nRowCount - nRowIndex)
        if ThemeParkSymbol.IsWildSymbol(nSymbolId) then
            order = order + SlotsGameLua.m_nRowCount * 2
        end
    end

    if SymbolObjectPool.m_mapSortingGroup[goSymbol] then
        SymbolObjectPool.m_mapSortingGroup[goSymbol].sortingOrder = order
    end
end

--[[
    @desc: 关卡加载之处，LevelCommonFunctions.lua在732行调用，为符号设置矩形遮罩
    author:coldflag
    time:2021-08-13 09:49:17
    --@nSymbolId: 符号ID
	--@nReelId: 列ID
	--@nRowIndex: 行ID
    @return: 添加了遮罩组件的预制件
]]
function ThemeParkFunc:CheckSpawnSymbol(nSymbolId, nReelId, nRowIndex)
    local group = self:GetMaskGroup()
    local goSymbol = self:SpawnSymbolByGroup(nSymbolId, group)

    -- 设置Sorting Group是为了防止因为个别符号和其它符号区域产生交集从而产生闪烁的情况
    self:SetSortingGroup(goSymbol, nSymbolId, nReelId, nRowIndex)

    return goSymbol
end

--[[
    @desc: 返回一个普通符号
    author:coldflag
    time:2021-08-18 19:32:10
    --@intReelID: 列的ID，从1开始
    @return:
]]
function ThemeParkFunc:GenerateNormalSymbol(nReelID)
    local nSymbolID = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelID)
    while (not ThemeParkSymbol:IsNormalSymbol(nSymbolID)) do
        nSymbolID = SlotsGameLua.m_randomChoices:ChoiceSymbolId(nReelID)
    end
    return nSymbolID
end

--[[
    @desc: 随机找1个位置生成Scatter
    author:coldflag
    time:2021-08-19 09:33:04
    @return: 横坐标， 纵坐标， 最左边为0，最下面为0
]]
function ThemeParkFunc:Generate1Scatter()
    local mapReelID = {0, 2, 4}
    local nReelIndex = mapReelID[math.random(3)]

    return nReelIndex
end

--[[
    @desc: 随机找2个位置生成Scatter
    author:coldflag
    time:2021-08-19 09:33:35
    @return:
]]
function ThemeParkFunc:Generate2Scatter()
    local mapReelID = {0, 2, 4}
    -- 第一次取值,移除被选中的元素，并返回该元素
    local nReelIndex1 = table.remove(mapReelID, math.random(3))
    -- 第二次取值
    local nReelIndex2 = table.remove(mapReelID, math.random(2))

    return nReelIndex1, nReelIndex2
end

--[[
    @desc: 
    author:coldflag
    time:2021-08-19 15:04:52
    --@num: 要生成的Scatter坐标的数量
    @return: 包含了生成的ReelID的数组
]]
function ThemeParkFunc:GenerateScatterReelPosition(num)
    local rv = {}
    if num == 1 then
        local nReelID = self:Generate1Scatter()
        table.insert(rv, nReelID)
    elseif num == 2 then
        local nReelID1, nReelID2 = self:Generate2Scatter()
        rv = {nReelID1, nReelID2}
    else
        rv = {0, 2, 4}
    end

    return rv
end

--[[
    @desc: GetDeck回调函数
    author:coldflag
    time:2021-08-17 17:20:12
    @return:
]]
function ThemeParkFunc:GetDeck()
    local deck = {}

    local nScatterID = ThemeParkSymbol:GetScatterSymbolID()
    -- 获得需要生成Scatter的列的ID，此处的ID是从0开始
    local mapScatterReelID = self:GenerateScatterReelPosition(ThemeParkConfig:GetScatterNums())

    -- 根据Scatter个数塞入Scatter
    -- 测试中，先关掉
    for i = 1, #mapScatterReelID do
        local nRowIndex = math.random(0, 2)
        deck[mapScatterReelID[i] * 3 + nRowIndex] = nScatterID
    end
    
    -- 此处是生成Wild符号
    if SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount == 0 then -- 不在FreeSpin中
        for x = 0, 4 do -- ReelID
            for y = 0, 2 do -- RowID
                if deck[3 * x + y] == nil then
                    local bWilD, WildID = ThemeParkConfig:GetWildKind()
                    if bWilD then
                        deck[3 * x + y] = ThemeParkSymbol:GetWildx1SymbolID()
                    else
                        local nNormalSymbolID = self:GenerateNormalSymbol(x)
                        deck[3 * x + y] = nNormalSymbolID
                    end
                end
            end
        end
    end

    if SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount > 0 then -- 此处是生成Wild符号
        for x = 0, 4 do -- ReelID
            for y = 0, 2 do -- RowID
                if deck[3 * x + y] == nil then
                    local bWilD, WildID = ThemeParkConfig:GetWildKind()
                    if bWilD then
                        deck[3 * x + y] = WildID -- 只有在FreeSpin中才会出现Wildx2, Wildx3
                    else
                        local nNormalSymbolID = self:GenerateNormalSymbol(x)
                        deck[3 * x + y] = nNormalSymbolID
                    end
                end
            end
        end
    end
    
    -- deck[1] = 4
    -- deck[4] = 4
    -- deck[7] = 4
    return deck
end


--[[
    @desc: 检查有多少根线是中奖的，且计算出中奖的金额是多少，并保存相关数据
    author:coldflag
    time:2021-08-16 14:18:58
    --@deck: 棋盘停下后的Symbol矩阵
	--@result: 
    @return: 存入数据的入参result，用于展示特效
]]
function ThemeParkFunc:CheckSpinWinPayLines(deck, result)
    result:ResetSpin()
    local fTotalWin = 0.0
    -- local boolFreeSpin = result:inFreeSpin()

    Debug.Assert(#SlotsGameLua.m_listLineLua)
    -- 遍历所有的50根可能的中奖线
    for i = 1, #SlotsGameLua.m_listLineLua do
        local iResult = {}
        local bFirstNormalSymbol = true
        local lineIndex = SlotsGameLua:GetLine(i)
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            iResult[x] = deck[3 * x + lineIndex.Slots[x]]
        end

        local nMaxMatchReelID = 0
        local nSymbolID = -1
        local nManifaction = 1 -- 在Wildx2，Wildx3下的结算倍率

        local bNeedToIncreasePrize = false
        local nCharacterSymbolNum = 0
        if SlotsGameLua.m_GameResult:InFreeSpin() and ThemeParkConfig:IsIn_NeedToIncreasePrize_Lines(i) then -- FreeSpin中，如果是第二条线，就要检查是否出现了被选中的角色，如果有，就需要增加角色Prize
            bNeedToIncreasePrize = true
        end

        -- 检查单条线是否中奖，如果nMaxMatchReelID >= 2，即最大匹配数大于3，则这条线是中奖的
        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            if bNeedToIncreasePrize and ThemeParkSymbol:IsSelectedCharacter(iResult[x]) then
                nCharacterSymbolNum = nCharacterSymbolNum + 1
            end
            if ThemeParkSymbol:IsScatterSymbol(iResult[x]) then -- Scatter
                -- nCurScatterNum = nCurScatterNum + 1
                break
            elseif ThemeParkSymbol:IsWildSymbol(iResult[x]) then -- Wild
                nMaxMatchReelID = nMaxMatchReelID + 1
                if SlotsGameLua.m_GameResult:InFreeSpin() then -- 只有在FreeSpin中才会出现Wildx2，Wildx3
                    if ThemeParkSymbol:IsWildx2Symbol(iResult[x]) then -- Wildx2，则倍率加2
                        nManifaction = nManifaction + 2
                    elseif ThemeParkSymbol:IsWildx3Symbol(iResult[x]) then -- Wildx3，则倍率加3
                        nManifaction = nManifaction + 3
                    end
                end
                
            elseif (iResult[x] < 9 and iResult[x] > 0 and bFirstNormalSymbol) or (nSymbolID == iResult[x] and not bFirstNormalSymbol) then
                -- (iResult[x] < 9 and iResult[x] > 0 and boolFirstNormalSymbol)此时是第一次遇到普通符号
                -- (intSymbolID == iResult[x] and not boolFirstNormalSymbol)代表此时的普通符号和这条线之前的符号相同
                bFirstNormalSymbol = false
                nSymbolID = iResult[x]
                nMaxMatchReelID = nMaxMatchReelID + 1
            else
                -- --此处判断并插入中奖元素位置
                -- for intX = 1, nMaxMatchReelID do
                --     table.insert(self.arrayHitSymbol,intX*10+lineIndex.Slots[intX-1])
                -- end
                break
            end
        end

        -- 开始统计赢了多少钱，以及要展示哪块棋盘，3个及以上的普通符号才会中奖
        if nSymbolID > -1 and nMaxMatchReelID >= 3 and SlotsGameLua:GetSymbol(nSymbolID).type == SymbolType.Normal then
            local fCombReward = 0.0
            local classSymbol = SlotsGameLua:GetSymbol(nSymbolID)
            fCombReward = classSymbol.m_fRewards[nMaxMatchReelID]

            if (fCombReward > 0.0) then
                Debug.Assert(#SlotsGameLua.m_listLineLua)
                -- 单条线压住金额
                local fSingalLineBet = SceneSlotGame.m_nTotalBet / #SlotsGameLua.m_listLineLua
                -- 单条线赢得金币
                local fSignalLineWin = fCombReward * fSingalLineBet * nManifaction
                Debug.Log("////////////////////////////////")
                Debug.Log("-------floatCombReward: " .. fCombReward .. " intManifaction " .. nManifaction .. "  floatSingalLineBet:  " .. fSingalLineBet)
                Debug.Log("-------intSymbolID: " .. nSymbolID .. "  MatchCount:  " .. nMaxMatchReelID)
                Debug.Log("////////////////////////////////")
                -- 将结果压入result.m_listWins表中
                table.insert(result.m_listWins, WinItem:create(i, nSymbolID, nMaxMatchReelID, fSignalLineWin, true, nMaxMatchReelID - 1))
                fTotalWin = fTotalWin + fSignalLineWin
                result.m_fSpinWin = result.m_fSpinWin + fSignalLineWin
            end
        end
    end
    -- 为了在界面底部显示数字增加的动画而必须赋值的参数
    if not SlotsGameLua.m_GameResult:InFreeSpin() then
        SlotsGameLua.m_GameResult.m_fGameWin = fTotalWin
        -- 还要加上Lucky Spin的盈利
    end

    if SlotsGameLua.m_GameResult:InFreeSpin() then -- 这块必须放在置Splash.FreeSpin 为 true 之前，因为此时还不算InFreeSpin()，而CustomWindow对应的函数会比FreeSpin对应的函数更先执行。而刚进入FreeSpin的时候，需要FreeSpin对应的函数先执行
        SlotsGameLua.m_bSplashFlags[SplashType.CustomWindow] = true -- 因为FreeSpin中，棋盘结算后，还需要处理其他事情才能进入下一次Spin，所以暂时阻塞公共流程，等完成处理再放行
        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + fTotalWin
        SlotsGameLua.m_GameResult.m_fGameWin = result.m_fFreeSpinTotalWins
    end

    -- 此处是FreeSpin处理流程
    if not SlotsGameLua.m_GameResult:InFreeSpin() and ThemeParkLevelUI.bTriggerScatterBonus == true then
        local newFreeSpinCount = ThemeParkConfig.NewFreeSpinTimesInScatterBonus
        SlotsGameLua.m_bSplashFlags[SplashType.FreeSpin] = true
        SlotsGameLua.m_GameResult.m_nNewFreeSpinCount = newFreeSpinCount
        SlotsGameLua.m_GameResult.m_nFreeSpinCount = 0
        SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount = newFreeSpinCount
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = 0
    end

    ThemeParkLevelUI.bTriggerScatterBonus = false
    ThemeParkLevelUI.nUsefulCharSymbolNum = 0
    
    return result
end



function ThemeParkFunc:IsInFreeSpin()
    local nReminderFreeSpinTimes = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount - SlotsGameLua.m_GameResult.m_nFreeSpinCount
    local rv = false
    if nReminderFreeSpinTimes > 0 then
        rv = true
    end

    return rv
end
--[[
    @desc: 供ShowSpine（）使用
    author:coldflag
    time:2021-08-18 11:15:51
    --@intIndex: 
    @return: Spine节点，Frame0节点，Spine特效动画
]]
function ThemeParkFunc:GetSpineNodeAndFrame0(nReel, nIndex)
    local goSymbol = nReel.m_listGoSymbol[nIndex]
    local goSpineNode = SymbolObjectPool.m_mapSpineNode[goSymbol]
    local goSpineEffect = SymbolObjectPool.m_mapSpinEffect[goSymbol]
    local goFrame0 = SymbolObjectPool.m_mapSpineElemFrame0[goSymbol]

    return goSpineNode, goFrame0, goSpineEffect
end

--[[
    @desc: 播放符号中奖时候的Spine动画，即将SpineNode激活，将Frame0隐藏
    author:coldflag
    time:2021-08-18 10:18:52
    --@boolShow: true为需要播放，false为不需要播放
    @return:
]]
function ThemeParkFunc:ShowFrame0(bShow)
    if not bShow then
        for k, v in pairs(SlotsGameLua.m_GameResult.m_listWins) do
            table.insert(self.arrayHitSymbol, v.m_nSymbolIdx)
        end

        -- Tool:IntIndexSimplification(self.arrayHitSymbol)

        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            local nReel = SlotsGameLua.m_listReelLua[x]
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nSymbolID = nReel.m_curSymbolIds[y]
                if LuaHelper.tableContainsElement(self.arrayHitSymbol, nSymbolID) then
                    local goSpineNode, goFrame0, goSpineEffect = self:GetSpineNodeAndFrame0(nReel, y)
                    if goSpineNode ~= nil and goFrame0 ~= nil then
                        goSpineNode:SetActive(true)
                       CoroutineHelper.waitForEndOfFrame(
                            function()
                                goFrame0:SetActive(false)
                            end
                        )
                    end
                end
            end
        end
    else
        for k, v in pairs(SlotsGameLua.m_GameResult.m_listWins) do
            table.insert(self.arrayHitSymbol, v.m_nSymbolIdx)
        end

        -- Tool:IntIndexSimplification(self.arrayHitSymbol)

        for x = 0, SlotsGameLua.m_nReelCount - 1 do
            local nReel = SlotsGameLua.m_listReelLua[x]
            for y = 0, SlotsGameLua.m_nRowCount - 1 do
                local nSymbolID = nReel.m_curSymbolIds[y]
                if LuaHelper.tableContainsElement(self.arrayHitSymbol, nSymbolID) then
                    local goSpineNode, goFrame0, goSpineEffect = self:GetSpineNodeAndFrame0(nReel, y)
                    if goSpineNode ~= nil and goFrame0 ~= nil then
                        goFrame0:SetActive(true)
                        if goSpineEffect ~= nil then
                            goSpineEffect:StopActiveAnimation()
                        end
                        goSpineNode:SetActive(false)
                    end
                end
            end
        end
    end
    self.arrayHitSymbol = {}
end




--[[
    @desc: 设置开始Spin时候的回调函数
    author:coldflag
    time:2021-08-17 19:05:08
    @return: void
]]
function ThemeParkFunc:OnStartSpin()
    self:ResetRectMaskGroupAfterScatterEffect()
    self:ShowFrame0(true)
end

--[[
    @desc: 设置结束Spin时候的回调函数
    author:coldflag
    time:2021-08-17 19:05:41
    @return: void
]]
function ThemeParkFunc:OnSpinEnd()
    self:ShowFrame0(false)
end

--[[
    @desc: 设置回调函数
    author:coldflag
    time:2021-08-13 09:33:09
    @return:
]]
function ThemeParkFunc:initSlotsGameParam()
    -- 先初始化关卡相关配置
    self:init()

    SlotsGameLua:setCheckSpinWinPayLinesFunc(self, self.CheckSpinWinPayLines)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)
    -- 将ThemeParkLevelUI加入公共代码的表中，使得公共代码可以调用ThemeParkLevelUI:initLevelUI()
    SceneSlotGame.m_LevelUiTableParam = ThemeParkLevelUI
end
