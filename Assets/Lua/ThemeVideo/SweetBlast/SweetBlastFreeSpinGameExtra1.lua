SweetBlastFreeSpinGameExtra1 = {} -- 左下的棋盘
SweetBlastFreeSpinGameExtra1.m_transform = nil -- "X4_2"

SweetBlastFreeSpinGameExtra1.m_listReelLua = {} -- 5个 MultiSlotsReel 

SweetBlastFreeSpinGameExtra1.m_fSymbolHeight = 0
SweetBlastFreeSpinGameExtra1.m_fDampingHeight = 100
SweetBlastFreeSpinGameExtra1.m_nRowCount = 3
SweetBlastFreeSpinGameExtra1.m_nReelCount = 5
SweetBlastFreeSpinGameExtra1.m_listDeck = {} -- 从 0 到 14 的 15 SymbolID
SweetBlastFreeSpinGameExtra1.m_fCentBoardY = 0

SweetBlastFreeSpinGameExtra1.m_fSpeedMax = 0
SweetBlastFreeSpinGameExtra1.m_fRotateDistance = 2000

SweetBlastFreeSpinGameExtra1.m_nReelsType = -1 -- SweetBlastReelsType.ReelsTypeNull -- 运行时修改设置

SweetBlastFreeSpinGameExtra1.m_nActiveReel = -1
SweetBlastFreeSpinGameExtra1.m_fSpinAge = 0

SweetBlastFreeSpinGameExtra1.m_GameResult = {} -- 记录中奖信息 展示线时候需要用到

SweetBlastFreeSpinGameExtra1.m_bAllReelStop = true

SweetBlastFreeSpinGameExtra1.m_listStickySymbol = {} -- 固定的元素。。
SweetBlastFreeSpinGameExtra1.m_trReels = {nil, nil, nil, nil, nil}

SweetBlastFreeSpinGameExtra1.m_listHitSymbols = {}

SweetBlastFreeSpinGameExtra1.m_mapSymbolPool = {} -- 这个棋盘上要用的元素都来这里取 用完都放回这里
-- prfab : listGo
-- 放在这个节点下的元素就和棋盘上的元素是同一个group了 在加入棋盘的时候就不用build了
SweetBlastFreeSpinGameExtra1.m_trSymbolsPool = nil -- SymbolsPool3X5_2_2

function SweetBlastFreeSpinGameExtra1:Start()
end

function SweetBlastFreeSpinGameExtra1:OnDisable()
end

function SweetBlastFreeSpinGameExtra1:OnDestroy()
end

function SweetBlastFreeSpinGameExtra1:getSymbolObject(nSymbolID)
    local go = SweetBlastFreeSpinCommon:getSymbolObject(nSymbolID, SweetBlastFreeSpinGameExtra1)
    return go
end

function SweetBlastFreeSpinGameExtra1:reuseSymbolObject(go)
    SweetBlastFreeSpinCommon:reuseSymbolObject(go, SweetBlastFreeSpinGameExtra1)
end

function SweetBlastFreeSpinGameExtra1:init()
    local nFreeSpinType = SweetBlastFreeSpinCommon.m_nFreeSpinType
    local go = SweetBlastFreeSpinCommon.m_mapGoFreeSpinNode[nFreeSpinType]
    
    local tr = self:getReelsTransformAndTrPool(go.transform)
    self.m_transform = tr
    LuaAutoBindMonoBehaviour.Bind(tr.gameObject, self)
    LuaAutoBindMonoBehaviour.Bind(tr.gameObject, self)
    
    self:initReelsTransform()

    self.m_fSymbolHeight = 200
    self.m_fCentBoardY = 0
    
    self.m_nReelsType = self:getReelsType()

    SweetBlastFreeSpinCommon:initSymbolPool(SweetBlastFreeSpinGameExtra1)

    self:initLevelParam()
end

function SweetBlastFreeSpinGameExtra1:initReelsTransform()
    local trReelData = self.m_transform:FindDeepChild("ReelData")

    for i=1, 5 do
        local reelName = "reel" .. tostring(i-1) -- ReelData
        local tr = trReelData:FindDeepChild(reelName)
        self.m_trReels[i] = tr
    end
end

function SweetBlastFreeSpinGameExtra1:getReelsTransformAndTrPool(trFreeSpinNode)
    local nFreeSpinType = SweetBlastFreeSpinCommon.m_nFreeSpinType

    local strGroupName = ""
    local strPoolName = ""

    if nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_2 then
        strGroupName = "Group2_2"
        strPoolName = "SymbolsPool3X5_2_2"
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_3 then
        strGroupName = "Group3_2"
        strPoolName = "SymbolsPool3X5_3_2"
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_4 then
        strGroupName = "Group4_2"
        strPoolName = "SymbolsPool3X5_4_2"
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_2 then
        strGroupName = "Group2_2"
        strPoolName = "SymbolsPool4X5_2_2"
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_3 then
        strGroupName = "Group3_2"
        strPoolName = "SymbolsPool4X5_3_2"
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_4 then
        strGroupName = "Group4_2"
        strPoolName = "SymbolsPool4X5_4_2"
    end

    local tr = trFreeSpinNode:FindDeepChild(strGroupName)

    self.m_trSymbolsPool = tr:FindDeepChild(strPoolName)

    return tr
end

function SweetBlastFreeSpinGameExtra1:getReelsType() -- 第二个棋盘
    local nReelsType = 0

    local nFreeSpinType = SweetBlastFreeSpinCommon.m_nFreeSpinType
    if nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_2 then
        nReelsType = SweetBlastReelsType.ReelsType3X5_2_2
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_3 then
        nReelsType = SweetBlastReelsType.ReelsType3X5_3_2
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_4 then
        nReelsType = SweetBlastReelsType.ReelsType3X5_4_2
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_2 then
        nReelsType = SweetBlastReelsType.ReelsType4X5_2_2
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_3 then
        nReelsType = SweetBlastReelsType.ReelsType4X5_3_2
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_4 then
        nReelsType = SweetBlastReelsType.ReelsType4X5_4_2
    end
    
    return nReelsType
end

function SweetBlastFreeSpinGameExtra1:initLevelParam()
    self.m_GameResult = GameResult:create(SweetBlastFreeSpinGameExtra1)
    
    local reelCount = 5
    self.m_nReelCount = reelCount
    
    local nReelRow = self.m_nRowCount
    for i=0, reelCount-1 do
        local reelLua = MultiSlotsReel:create(i, nReelRow, SweetBlastFreeSpinGameExtra1)

        self.m_listReelLua[i] = reelLua
    end

    self:RepositionSymbols()

    SweetBlastFreeSpinCommon:CreateReelRandomSymbolList(SweetBlastFreeSpinGameExtra1)

    self:SetRandomSymbolToReel()

    SlotsGameLua.m_bSplashEnd = true

end

function SweetBlastFreeSpinGameExtra1:SetRandomSymbolToReel()
    for i=0, self.m_nReelCount-1 do
        local nTotal = self.m_listReelLua[i].m_nReelRow + self.m_listReelLua[i].m_nAddSymbolNums
        for y=0, nTotal-1 do
            self.m_listReelLua[i].m_curSymbolIds[y] = 0
        end

        self.m_listReelLua[i]:SetSymbolRandom()
    end
end

function SweetBlastFreeSpinGameExtra1:RepositionSymbols()
    local nOutSideCount = 1
    local nReelCount = self.m_nReelCount

    local fMidIndex = (nReelCount - 1) / 2.0
    for i=0, nReelCount-1 do
        local reelLua = self.m_listReelLua[i]
        local fMidRow = (reelLua.m_nReelRow-1) / 2.0
        local nSymbolNum = reelLua.m_nReelRow + reelLua.m_nAddSymbolNums
        for y=1, nSymbolNum do
            local fPosY = (y-1 -fMidRow) * self.m_fSymbolHeight
            reelLua.m_listSymbolPos[y-1] = Unity.Vector3(0.0, fPosY, 0.0)
        end

        reelLua.m_nOutSideCount = nOutSideCount

    end
end

function SweetBlastFreeSpinGameExtra1:OnPreReelStop(nReelID) -- 0 1 2 3 4
    local listWildReelIDs = SweetBlastFreeSpinCommon.m_listWildReelIDs
    local bres = LuaHelper.tableContainsElement(listWildReelIDs, nReelID)
    if bres then
        return
    end

	if not SpinButton.m_bUserStopSpin or nReelID == 4 then
        AudioHandler:PlayReelStopSound(nReelID) -- 列停止的音
    end
end

function SweetBlastFreeSpinGameExtra1:getDeck()
    local deck = SweetBlastFreeSpinCommon:getDeck()
    
    self:ModifyTestDeck(deck)

    self.m_listDeck = deck
    return deck
end

function SweetBlastFreeSpinGameExtra1:ModifyTestDeck(deck) -- 调试的时候自己修改数据用
    if not GameConfig.PLATFORM_EDITOR then
        return
    end

    if SweetBlastFunc.m_bSimulationFlag then
        return
    end

    local nTestType = -1
    if nTestType < 0 then
        return
    end
    
    if nTestType == 1 and math.random() < 10.2 then
        deck[0] = 7
        deck[3] = 6
        deck[6] = 9

        deck[1] = 7
        deck[2] = 7

        deck[4] = 6
        deck[5] = 6

        deck[7] = 9
        deck[8] = 9

        deck[9] = 5
        deck[10] = 5
        deck[11] = 5
    end

end

function SweetBlastFreeSpinGameExtra1:Update()
    if not SlotsGameLua.m_bInSpin then
        return
    end

    if self.m_bAllReelStop then
        return
    end

    if self.m_nActiveReel == -1 then
        self.m_fSpinAge = self.m_fSpinAge + dt
        if self.m_fSpinAge > 0.5 then -- spin开始后0.5s可以允许停
            self.m_nActiveReel = 0
            self:getDeck()
            self.m_listReelLua[self.m_nActiveReel]:Stop()
            
            self.m_fSpinAge = 0.0

         --   Debug.Log("----- SweetBlastFreeSpinGameExtra1:Update() ----- getDeck -----")
        end
    else
        local nMaxReelID = self.m_nReelCount-1
        if self.m_nActiveReel <= nMaxReelID and self.m_listReelLua[self.m_nActiveReel]:Completed() then
            --check next reel
            self.m_nActiveReel = self.m_nActiveReel + 1
            --if all Reels stopped.
            if self.m_nActiveReel > nMaxReelID then

            else
                self.m_listReelLua[self.m_nActiveReel]:Stop()
            end
        end

        if self.m_nActiveReel > nMaxReelID then
            self:PreCheckWin()
        end

    end
end

function SweetBlastFreeSpinGameExtra1:PreCheckWin()
    self:CheckWinEnd()
end

function SweetBlastFreeSpinGameExtra1:CheckWinEnd()
    self.m_listHitSymbols = {}

    local nFreeSpinType = SweetBlastFreeSpinCommon.m_nFreeSpinType
    if nFreeSpinType <= 3 then
        FreeSpinData3X5:CheckSpinWinPayLines(self.m_listDeck, self.m_GameResult, self)
    else
        FreeSpinData4X5:CheckSpinWinPayLines(self.m_listDeck, self.m_GameResult, self)
    end
    
    local fGameExtra1Win = self.m_GameResult.m_fSpinWin
    local strTemp = MoneyFormatHelper.coinCountOmit(fGameExtra1Win)
    Debug.Log("----SweetBlastFreeSpinGameExtra1:CheckWinEnd()----fGameExtra1Win: " .. strTemp)

    self:CheckWinEndPost()
end

function SweetBlastFreeSpinGameExtra1:Spin() -- 点spin按钮时候会调用
    
    ---Start reels spin

    -- 4X2
    for i=0, self.m_nReelCount-1 do
        self.m_listReelLua[i]:Spin()
    end

    self.m_fSpinAge = 0.0
    self.m_nActiveReel = -1
    
    self.m_bAllReelStop = false

    self:OnStartSpin() -- 开始滚动了 比如要隐藏spine动画的。。。

end

function SweetBlastFreeSpinGameExtra1:OnStartSpin()
    -- 开始滚动了 比如要隐藏spine动画的。。。
    self:showSpineFrame0(true)

    --self.m_bShowLineFlag = false
    
end

function SweetBlastFreeSpinGameExtra1:OnSpinEnd()
    self:showSpineFrame0(false)
end

function SweetBlastFreeSpinGameExtra1:CheckWinEndPost()
    local fCurSpinWins = self.m_GameResult.m_fSpinWin
    
    self.m_nWinOffset = 1
    self.m_fWinShowAge = 0.0
    self.m_bInSplashShowAllWinLines = true
    
    self.m_bAllReelStop = true
    
    local bStopFlag = SweetBlastFreeSpinCommon:isAllReelsStop()

    if bStopFlag then
        SlotsGameLua.m_bInSpin = false

        SweetBlastFreeSpinGameMain:ShowGameResult() -- 展示线 特效等...
    end

    self:OnSpinEnd() -- 结算结束了 开始展示结果之前。。比如spine动画可能需要显示出来等

end

function SweetBlastFreeSpinGameExtra1:ShowSpinResult()
end

function SweetBlastFreeSpinGameExtra1:playWinEffect()
    local nTotalWinLines = #self.m_GameResult.m_listWins -- 有多少根线中奖了

    for nWinIndex = 1, nTotalWinLines do
        local wi = self.m_GameResult.m_listWins[nWinIndex]
        
        -- 转圈的粒子特效、spine动画、unity动画或者放大缩小...
        self:ShowPayLineEffect(wi.m_nLineID, wi.m_nMaxMatchReelID)
    end
end

function SweetBlastFreeSpinGameExtra1:ShowPayLineEffect(nLineID, nMaxMatchReelID)
    local ld = SweetBlastFreeSpinCommon:GetLine(nLineID)
    
	for x=0, nMaxMatchReelID do
		local y = ld.Slots[x]

		local nResultKey = self.m_nRowCount * x + ld.Slots[x]
		local nEffectKey = nResultKey
		-- 1. 转圈粒子特效... 其他的就依次检查，有一种播放就break
		self:PlayHitLineEffect(x, y)

		-- 2. spine特效
		self:PlaySpineEffect(x, y)

		-- -- 3. unity动画
		self:PlayMultiClipEffect(x, y)

		-- 4. 缩放
		self:LoopScaleSymbol(x, y)
	end
end

function SweetBlastFreeSpinGameExtra1:PlayHitLineEffect(x, y)
    local trParent = self.m_listReelLua[x].m_listGoSymbol[y].transform
    
    local nEffectKey = self.m_nRowCount * x + y + 100 -- 棋盘2的就在此基础上加100
    
    local effectPos = Unity.Vector3.zero
    
    local strEffectName = "lztukuai4X"
    local effectObj = PayLinePayWaysEffectHandler:PlayHitLineEffect3(effectPos, nEffectKey, strEffectName, trParent)
    
    if effectObj ~= nil then
        effectObj.m_effectGo.transform.localScale = Unity.Vector3.one
        effectObj.m_effectGo.transform.localPosition = effectPos --Unity.Vector3.zero
    end

end

function SweetBlastFreeSpinGameExtra1:PlaySpineEffect(x, y)
	local go = nil
    local nEffectKey = self.m_nRowCount * x + y + 100
    if PayLinePayWaysEffectHandler.m_mapSpineEffects[nEffectKey] ~= nil then
        return -- 已经在播放了
    end
    
    local bStickyFlag, nStickyIndex = self.m_listReelLua[x]:isStickyPos(0)
    if bStickyFlag then
        go = self.m_listReelLua[x].m_listStickySymbol[nStickyIndex].m_goSymbol
    else
        local listGo = self.m_listReelLua[x].m_listGoSymbol
        go = listGo[y]
    end
    
	PayLinePayWaysEffectHandler:PlaySpineEffect2(go, nEffectKey)
end

function SweetBlastFreeSpinGameExtra1:PlayMultiClipEffect(x, y)
	local go = nil
    local nEffectKey = self.m_nRowCount * x + y + 100
    if PayLinePayWaysEffectHandler.m_mapSpineEffects[nEffectKey] ~= nil then
        return -- 已经在播放了
    end
    
    local bStickyFlag, nStickyIndex = self.m_listReelLua[x]:isStickyPos(0)
    if bStickyFlag then
        go = self.m_listReelLua[x].m_listStickySymbol[nStickyIndex].m_goSymbol
    else
        local listGo = self.m_listReelLua[x].m_listGoSymbol
        go = listGo[y]
    end
    
    PayLinePayWaysEffectHandler:PlayMultiClipEffect2(go, nEffectKey)
end

function SweetBlastFreeSpinGameExtra1:LoopScaleSymbol(x, y)
	local nEffectKey = self.m_nRowCount * x + y + 100 -- 棋盘2 加 100
	
	local goSymbol = self.m_listReelLua[x].m_listGoSymbol[y]

	local reel = self.m_listReelLua[x]
	local bStickyFlag, nStickyIndex = reel:isStickyPos(0)
	if bStickyFlag then
		goSymbol = reel.m_listStickySymbol[nStickyIndex].m_goSymbol
	end

	PayLinePayWaysEffectHandler:LoopScaleSymbol2(goSymbol, nEffectKey)
end

------
----
--开始滚动的时候 显示静帧 隐藏spine节点
--准备结算的时候 显示静帧 显示spine节点
function SweetBlastFreeSpinGameExtra1:showSpineFrame0(bShowFrame0)
    -- 2018-8-22 显示spine节点只显示需要播放中奖特效的
    if not bShowFrame0 then
        self:showSpineNode()
        return
    end

    for x=0, self.m_nReelCount-1 do
        local reel = self.m_listReelLua[x]
        local nRowCount = reel.m_nReelRow
		for y=0, nRowCount-1 do
        --    local nkey = SlotsGameLua.m_nRowCount * x + y

            local goSymbol = nil
            local bStickyFlag, nStickyIndex = reel:isStickyPos(0)
            if bStickyFlag then
                goSymbol = reel.m_listStickySymbol[nStickyIndex].m_goSymbol
            else
                goSymbol = reel.m_listGoSymbol[y]
            end
            
            local goFrame0 = SymbolObjectPool.m_mapSpineElemFrame0[goSymbol]
            if goFrame0 ~= nil then
                local goSpineNode = SymbolObjectPool.m_mapSpineNode[goSymbol]
                local spineEffect = SymbolObjectPool.m_mapSpinEffect[goSymbol]

                if bShowFrame0 then
                    goFrame0:SetActive(true)

                    -- 要隐藏spineNode的时候 检查是否在播放 如果在播放 需要先停止播放
                    if spineEffect ~= nil then
                        spineEffect:StopActiveAnimation()
                    end
                    goSpineNode:SetActive(false)
                else
                    --显示spine节点 隐藏静帧
                    goSpineNode:SetActive(true)
                    spineEffect:Reset()
                    goFrame0:SetActive(false)
                end

            end

            SweetBlastFreeSpinCommon:SetSymbolRectGroup(goSymbol, self.m_nReelsType)

        end

    end
end

function SweetBlastFreeSpinGameExtra1:showSpineNode() -- 滚动停止的时候调用
    local cnt = #self.m_listHitSymbols
    for i=1, cnt do
        local key = self.m_listHitSymbols[i]
        local x = math.floor( key/self.m_nRowCount )
        local y = key % self.m_nRowCount
        
        local reel = self.m_listReelLua[x]
        if reel == nil then
            Debug.Log("--------error!!---------")
            break
        end

        local goSymbol = nil
        local bStickyFlag, nStickyIndex = reel:isStickyPos(0)
        if bStickyFlag then
            goSymbol = reel.m_listStickySymbol[nStickyIndex].m_goSymbol
        else
            goSymbol = reel.m_listGoSymbol[y]
        end

        local goSpineNode = SymbolObjectPool.m_mapSpineNode[goSymbol]
        local spineEffect = SymbolObjectPool.m_mapSpinEffect[goSymbol]
        local goFrame0 = SymbolObjectPool.m_mapSpineElemFrame0[goSymbol]
        if goSpineNode ~= nil then
            --显示spine节点 隐藏静帧
            goSpineNode:SetActive(true)

            spineEffect:Reset()
            goFrame0:SetActive(false) -- 静帧
            
            SweetBlastFreeSpinCommon:SetSymbolRectGroup(goSymbol, nil)
        end
    end 
    
    self.m_listHitSymbols = {}

end