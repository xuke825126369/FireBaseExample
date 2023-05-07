require "Lua/ThemeVideo2020/SweetBlast/MultiSlotsReel"

SweetBlastFreeSpinGameMain = {} -- 左上的棋盘 主棋盘...
SweetBlastFreeSpinGameMain.m_transform = nil -- "X4_1"

SweetBlastFreeSpinGameMain.m_listReelLua = {} -- 5个 MultiSlotsReel 0 1 2 3 4

SweetBlastFreeSpinGameMain.m_fSymbolHeight = 0
SweetBlastFreeSpinGameMain.m_fDampingHeight = 100
SweetBlastFreeSpinGameMain.m_nRowCount = 3 -- 运行时修改设置
SweetBlastFreeSpinGameMain.m_nReelCount = 5
SweetBlastFreeSpinGameMain.m_listDeck = {} -- 从 0 到 14 的 15 SymbolID
SweetBlastFreeSpinGameMain.m_fCentBoardY = 0

SweetBlastFreeSpinGameMain.m_fSpeedMax = 0
SweetBlastFreeSpinGameMain.m_fRotateDistance = 2000

SweetBlastFreeSpinGameMain.m_nReelsType = -1 -- SweetBlastReelsType.ReelsTypeNull -- 运行时修改设置

SweetBlastFreeSpinGameMain.m_nActiveReel = -1
SweetBlastFreeSpinGameMain.m_fSpinAge = 0

SweetBlastFreeSpinGameMain.m_GameResult = {} -- 记录中奖信息 展示线时候需要用到

SweetBlastFreeSpinGameMain.m_bInResult = false

SweetBlastFreeSpinGameMain.m_nSplashActive = 0 -- 应该用 SlotsGameLua.m_nSplashActive ..

SweetBlastFreeSpinGameMain.m_bAllReelStop = true

SweetBlastFreeSpinGameMain.m_listStickySymbol = {} -- 固定的元素
SweetBlastFreeSpinGameMain.m_trReels = {nil, nil, nil, nil, nil}

SweetBlastFreeSpinGameMain.m_bShowGameResultFlag = false -- 两个棋盘都结算好了开始展示结果时置为 true

SweetBlastFreeSpinGameMain.m_bShowLineFlag = false -- 是否允许展示线了。。

SweetBlastFreeSpinGameMain.m_listHitSymbols = {} -- 显示隐藏 spinenode 时候需要

SweetBlastFreeSpinGameMain.m_mapSymbolPool = {} -- 这个棋盘上要用的元素都来这里取 用完都放回这里
-- prfab : listGo
-- 放在这个节点下的元素就和棋盘上的元素是同一个group了 在加入棋盘的时候就不用build了
SweetBlastFreeSpinGameMain.m_trSymbolsPool = nil --SymbolsPool4X_1

SweetBlastFreeSpinGameMain.m_fCurTotalSpinWin = 0


function SweetBlastFreeSpinGameMain:Start()
end

function SweetBlastFreeSpinGameMain:OnDisable()
end

function SweetBlastFreeSpinGameMain:OnDestroy()
end

function SweetBlastFreeSpinGameMain:getSymbolObject(nSymbolID)
    local go = SweetBlastFreeSpinCommon:getSymbolObject(nSymbolID, SweetBlastFreeSpinGameMain)
    return go
end

function SweetBlastFreeSpinGameMain:reuseSymbolObject(go)
    SweetBlastFreeSpinCommon:reuseSymbolObject(go, SweetBlastFreeSpinGameMain)
end

function SweetBlastFreeSpinGameMain:init()
    local nFreeSpinType = SweetBlastFreeSpinCommon.m_nFreeSpinType
    local go = SweetBlastFreeSpinCommon.m_mapGoFreeSpinNode[nFreeSpinType]
    
    local tr = self:getReelsTransformAndTrPool(go.transform) -- 查找类似 "Group2_1" 节点
    self.m_transform = tr
    LuaAutoBindMonoBehaviour.Bind(tr.gameObject, self)
    LuaAutoBindMonoBehaviour.Bind(tr.gameObject, self)
    
    self:initReelsTransform() -- 

    self.m_fSymbolHeight = 190 -- 3行还是4行的元素高都是190
    self.m_fCentBoardY = 0
    
    self.m_nReelsType = self:getReelsType()

    SweetBlastFreeSpinCommon:initSymbolPool(SweetBlastFreeSpinGameMain)
    
    self:initLevelParam()
end

function SweetBlastFreeSpinGameMain:initReelsTransform()
    local trReelData = self.m_transform:FindDeepChild("ReelData")

    for i=1, 5 do
        local reelName = "reel" .. tostring(i-1) -- ReelData
        local tr = trReelData:FindDeepChild(reelName)
        self.m_trReels[i] = tr
    end
end

function SweetBlastFreeSpinGameMain:getReelsTransformAndTrPool(trFreeSpinNode)
    local nFreeSpinType = SweetBlastFreeSpinCommon.m_nFreeSpinType

    local strGroupName = ""
    local strPoolName = ""

    if nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_2 then
        strGroupName = "Group2_1"
        strPoolName = "SymbolsPool3X5_2_1"
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_3 then
        strGroupName = "Group3_1"
        strPoolName = "SymbolsPool3X5_3_1"
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_4 then
        strGroupName = "Group4_1"
        strPoolName = "SymbolsPool3X5_4_1"
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_2 then
        strGroupName = "Group2_1"
        strPoolName = "SymbolsPool4X5_2_1"
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_3 then
        strGroupName = "Group3_1"
        strPoolName = "SymbolsPool4X5_3_1"
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_4 then
        strGroupName = "Group4_1"
        strPoolName = "SymbolsPool4X5_4_1"
    end

    local tr = trFreeSpinNode:FindDeepChild(strGroupName)
    
    self.m_trSymbolsPool = tr:FindDeepChild(strPoolName)

    return tr
end

function SweetBlastFreeSpinGameMain:getReelsType() -- 第一个棋盘
    local nReelsType = 0

    local nFreeSpinType = SweetBlastFreeSpinCommon.m_nFreeSpinType
    if nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_2 then
        nReelsType = SweetBlastReelsType.ReelsType3X5_2_1
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_3 then
        nReelsType = SweetBlastReelsType.ReelsType3X5_3_1
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_4 then
        nReelsType = SweetBlastReelsType.ReelsType3X5_4_1
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_2 then
        nReelsType = SweetBlastReelsType.ReelsType4X5_2_1
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_3 then
        nReelsType = SweetBlastReelsType.ReelsType4X5_3_1
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin4X5_4 then
        nReelsType = SweetBlastReelsType.ReelsType4X5_4_1
    end
    
    return nReelsType
end

function SweetBlastFreeSpinGameMain:initLevelParam()
    self.m_GameResult = GameResult:create(SweetBlastFreeSpinGameMain)
    
    local reelCount = 5
    self.m_nReelCount = reelCount
    
    local nReelRow = self.m_nRowCount

    for i=0, reelCount-1 do
        local reelLua = MultiSlotsReel:create(i, nReelRow, SweetBlastFreeSpinGameMain)

        self.m_listReelLua[i] = reelLua
    end

    for k, v in pairs(SplashType) do
        SlotsGameLua.m_bSplashFlags[v] = false
    end

    self:RepositionSymbols()

    SweetBlastFreeSpinCommon:CreateReelRandomSymbolList(SweetBlastFreeSpinGameMain)

    self:SetRandomSymbolToReel()

    SlotsGameLua.m_bSplashEnd = true

end

function SweetBlastFreeSpinGameMain:SetRandomSymbolToReel()
    for i=0, self.m_nReelCount-1 do
        local nTotal = self.m_listReelLua[i].m_nReelRow + self.m_listReelLua[i].m_nAddSymbolNums
        for y=0, nTotal-1 do
            self.m_listReelLua[i].m_curSymbolIds[y] = 0
        end

        self.m_listReelLua[i]:SetSymbolRandom()
    end
end

function SweetBlastFreeSpinGameMain:RepositionSymbols()
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

function SweetBlastFreeSpinGameMain:OnPreReelStop(nReelID) -- 0 1 2 3 4
    local listWildReelIDs = SweetBlastFreeSpinCommon.m_listWildReelIDs
    local bres = LuaHelper.tableContainsElement(listWildReelIDs, nReelID)
    if bres then
        return
    end

	if not SpinButton.m_bUserStopSpin or nReelID == 4 then
        AudioHandler:PlayReelStopSound(nReelID) -- 列停止的音
    end
end


-- function SweetBlastFunc:isStopReel(nReelID) -- 还有固定了一个占多格的大元素的reel ...
--     local rt = SlotsGameLua.m_GameResult
--     if not rt:InReSpin() then
--         return false
--     end

--     local reel = SlotsGameLua.m_listReelLua[nReelID]
    
--     local bStickyFlag, nStickyIndex = reel:isStickyPos(0)
--     if bStickyFlag then
--         return true
--     end

--     return false
-- end

function SweetBlastFreeSpinGameMain:getDeck()
    local deck = SweetBlastFreeSpinCommon:getDeck()
    
    self:ModifyTestDeck(deck)

    self.m_listDeck = deck
    return deck
end

function SweetBlastFreeSpinGameMain:ModifyTestDeck(deck) -- 调试的时候自己修改数据用
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
        deck[0] = 8
        deck[3] = 8
        deck[6] = 8

        deck[1] = 7
        deck[2] = 7

        deck[4] = 6
        deck[5] = 6

        deck[7] = 9
        deck[8] = 9

        deck[9] = 5
        deck[10] = 5
        deck[11] = 5

        deck[12] = 5
        deck[13] = 5
        deck[14] = 5
    end
end

function SweetBlastFreeSpinGameMain:handleFreeSpinEnd()
     -- 是否n次都用完了
    
    local nTotalFreeSpin = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount
    if SlotsGameLua.m_GameResult.m_nFreeSpinCount < nTotalFreeSpin then
        return
    end
    
    ---
    
    PayLinePayWaysEffectHandler:MatchLineHide(true)

    local param = {}
    param.m_nFreeSpinType = 0 -- 0类型 无意义。。
    param.m_listWildReelID = {}
    param.m_fFreeSpinBet = 0
    SweetBlastLevelUI:setFreeSpinParam(param)
    
    SceneSlotGame:ButtonEnable(false)
    SceneSlotGame.m_bUIState = true -- 等下面的 HideFreeSpinUI 关闭了再置为false
    SceneSlotGame.m_btnSpin.interactable = false -- 还有亮起来的可能吗？？...

    LeanTween.delayedCall(0.1, function()
        local nTotalWin = SlotsGameLua.m_GameResult.m_fGameWin
        local nFreeSpinNum = SweetBlastFreeSpinCommon.m_nFreeSpinNum
        
        ---- 弹窗。。
        SweetBlastLevelUI:showFreeSpinEnd(nTotalWin)
        -- 给玩家加金币 
        SceneSlotGame:collectFreeSpinTotalWins(3.2)
        
        SceneSlotGame:setTotalWinTipInfo("WIN", true)

    end)
    
end

function SweetBlastFreeSpinGameMain:DisplaySplashInfo()
    if not self.m_bShowGameResultFlag then
        return false -- 还有棋盘没有停下来
    end

    if not self.m_bInResult or SlotsGameLua.m_bInSplashShow then -- 
        return false
    end

    if SlotsGameLua.m_nSplashActive == SplashType.None then
        return false
    end

    if SlotsGameLua.m_nSplashActive >= SplashType.Max then
        self.m_bInResult = false
        self.m_bShowGameResultFlag = false

        AudioHandler:StopMusic(1.0)
        SceneSlotGame:OnSplashEnd()

        -- 因为有一些个性化的处理 就不弹统一的 FreeSpinEnd 界面了。。
        self:handleFreeSpinEnd() -- 检查是否已经结束了。。该回到BaseGame状态

    else
        if SlotsGameLua.m_nSplashActive == SplashType.Line then
            -- self.m_fCoinTime 会在这里初始化个时间

            AudioHandler:StopMusic(1.0)
            SceneSlotGame:AllReelStopAudioHandle()

            -- 展示中奖线等信息放在这里。。。 2018-8-24
            
            self:playWinEffect()
        end

        -- 比如 preFreeSpin等。。
        if not SlotsGameLua.m_bSplashFlags[SlotsGameLua.m_nSplashActive] then
        --    Debug.Log("Splash 显示弹窗：  false ".. SlotsGameLua.m_nSplashActive)
            SlotsGameLua.m_nSplashActive = SlotsGameLua.m_nSplashActive + 1
        else
            SlotsGameLua.m_bInSplashShow = true
        --    Debug.Log("Splash 显示弹窗： true ".. SlotsGameLua.m_nSplashActive)

            SceneSlotGame:OnSplashShow(SlotsGameLua.m_nSplashActive)
            -- bigwin 和 line 
            -- line 的情况会在这里面OnSplashHide。。。使得流程继续往后走...
            
        end
        
        local bHasFreeSpinFlag = SlotsGameLua.m_GameResult:HasFreeSpin()
        if not bHasFreeSpinFlag then
            if SlotsGameLua.m_nSplashActive >= SplashType.Line then
                SceneSlotGame.m_btnSpin.interactable = false
            end
        end

    end

    return true
end

function SweetBlastFreeSpinGameMain:Update()
    local bFlag = self:DisplaySplashInfo()
    if bFlag then
        return
    end

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
            
            SceneSlotGame:OnSpinToStop() -- 显示stop状态 亮起按钮允许玩家点击

            self.m_fSpinAge = 0.0
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

function SweetBlastFreeSpinGameMain:PreCheckWin()
    self:CheckWinEnd()

end

function SweetBlastFreeSpinGameMain:CheckWinEnd()
    self.m_listHitSymbols = {}

    local nFreeSpinType = SweetBlastFreeSpinCommon.m_nFreeSpinType
    if nFreeSpinType <= 3 then
        FreeSpinData3X5:CheckSpinWinPayLines(self.m_listDeck, self.m_GameResult, self)
    else
        FreeSpinData4X5:CheckSpinWinPayLines(self.m_listDeck, self.m_GameResult, self)
    end
    
    local fGameMainWin = self.m_GameResult.m_fSpinWin
    local strTemp = MoneyFormatHelper.coinCountOmit(fGameMainWin)
    Debug.Log("----SweetBlastFreeSpinGameMain:CheckWinEnd()----fGameMainWin: " .. strTemp)

    self:CheckWinEndPost()
end

function SweetBlastFreeSpinGameMain:Spin() -- 点spin按钮时候会调用
    if SlotsGameLua.m_bInSpin then
        return SlotsReturnCode.InSpin
    end
    
    self.m_bShowGameResultFlag = false

    SweetBlastFreeSpinGameExtra1:Spin()

    if SweetBlastFreeSpinCommon.m_nUsedReelsNum > 2 then
        SweetBlastFreeSpinGameExtra2:Spin()
    end
    
    if SweetBlastFreeSpinCommon.m_nUsedReelsNum > 3 then
        SweetBlastFreeSpinGameExtra3:Spin()
    end

    self.m_bInResult = false

    for k, v in pairs(SplashType) do
        SlotsGameLua.m_bSplashFlags[v] = false
    end
    
    PayLinePayWaysEffectHandler:MatchLineHide(true)

    ---Start reels spin

    -- 4X1
    for i=0, self.m_nReelCount-1 do
        self.m_listReelLua[i]:Spin()
    end

    self.m_fSpinAge = 0.0
    self.m_nActiveReel = -1
    SlotsGameLua.m_bInSpin = true
    self.m_bAllReelStop = false
    SlotsGameLua.m_nSplashActive = -1
    
    local bInFreeSpinFlag = self.m_GameResult:InFreeSpin()

    self:OnStartSpin() -- 开始滚动了 比如要隐藏spine动画的。。。

    LeanTween.delayedCall(0.5, function()
        SceneSlotGame:setTotalWinTipInfo("WIN", true)
    end)

    return SlotsReturnCode.Success
end

function SweetBlastFreeSpinGameMain:OnStartSpin()
    -- 开始滚动了 比如要隐藏spine动画的。。。
    self:showSpineFrame0(true)

    SlotsGameLua.m_bSplashEnd = false -- 开始滚动置为false 结算结束并且展示结果结束 置为true

    self.m_bShowLineFlag = false
end

function SweetBlastFreeSpinGameMain:CheckWinEndPost()
    local fCurSpinWins = self.m_GameResult.m_fSpinWin
    
    self.m_nWinOffset = 1
    self.m_fWinShowAge = 0.0
    self.m_bInSplashShowAllWinLines = true
    
    self.m_bAllReelStop = true
    
    local bStopFlag = SweetBlastFreeSpinCommon:isAllReelsStop()
    
    if bStopFlag then
        SlotsGameLua.m_bInSpin = false

        self:ShowGameResult()
    end

    self:OnSpinEnd() -- 结算结束了 开始展示结果之前。。比如spine动画可能需要显示出来等

end



function SweetBlastFreeSpinGameMain:ShowSpinResult()

end

function SweetBlastFreeSpinGameMain:OnSpinEnd()
    -- 结算结束了 开始展示结果之前。。比如spine动画可能需要显示出来等
    self:showSpineFrame0(false)
    
end

function SweetBlastFreeSpinGameMain:getAllReelsTotalWin()
    local fWins = 0

    local listGames = {SweetBlastFreeSpinGameMain, SweetBlastFreeSpinGameExtra1,
                       SweetBlastFreeSpinGameExtra2, SweetBlastFreeSpinGameExtra3}

    for i=1, SweetBlastFreeSpinCommon.m_nUsedReelsNum do
        fWins = fWins + listGames[i].m_GameResult.m_fSpinWin
    end

    return fWins
end

 -- 两个棋盘都已经结算完了之后调用。。。
 -- 展示中奖线 播放元素特效 。。 弹 bigwin 窗口。。
 -- 玩家赚到的游戏币统计..
function SweetBlastFreeSpinGameMain:ShowGameResult()
    if self.m_bShowGameResultFlag then
        Debug.Log("-------------error!!-------------")
        return
    end

     -- 正常逻辑上只会进来一次
    self.m_bShowGameResultFlag = true
 --   Debug.Log("------SweetBlastFreeSpinGameMain:ShowGameResult()------")

    -- 允许展示线了
    self.m_bShowLineFlag = true

    local fTotalBets = SceneSlotGame.m_nTotalBet
    local fWins = self:getAllReelsTotalWin()
    self.m_fCurTotalSpinWin = fWins -- 展示bigwin megawin时候需要。。
    -- 多个棋盘一共赢得的
        
    --  
    if fWins > 0.0 then
        local strInfo = MoneyFormatHelper.numWithCommas(fWins) -- 只会是整数。。
        strInfo = "+" .. strInfo
        SceneSlotGame:setTotalWinTipInfo(strInfo, true)
    end
    --
    
    SlotsGameLua.m_GameResult.m_fSpinWin = fWins -- 播放音效的时候需要用到

    SlotsGameLua.m_GameResult.m_fGameWin = fWins + SlotsGameLua.m_GameResult.m_fGameWin

    -- 这属于freespin。。记在数据库了 等都结束了再结算给玩家
    -- 再配合其他参数来确定是3中freespin（basegame触发、2X、4X）中的哪一种。。2018-8-22  todo 
    LevelDataHandler:addFreeSpinTotalWin(ThemeLoader.themeKey, fWins)
    --
    
    SlotsGameLua.m_bSplashFlags[SplashType.Line] = true -- 

    local fWinCoef = fWins / fTotalBets
    
    local data = {forBigWin = true, forWinExtra = false, bFreeSpinFlag = true,
                    nTotalBet = fTotalBets, fBigWin = fWins, fExtraWin = fWins}
    SlotsGameLua:onFinalReport(data)

    if fWinCoef >= 100.0 then
        SlotsGameLua.m_bSplashFlags[SplashType.SensationalWin] = true
    elseif fWinCoef >= 50.0 then
        SlotsGameLua.m_bSplashFlags[SplashType.EpicWin] = true
    elseif fWinCoef >= 30.0 then
        SlotsGameLua.m_bSplashFlags[SplashType.MegaWin] = true
    elseif fWinCoef >= 20.0 then
        SlotsGameLua.m_bSplashFlags[SplashType.HugeWin] = true
    elseif fWinCoef >= 10.0 then
        SlotsGameLua.m_bSplashFlags[SplashType.BigWin] = true
	end

    local bres = SlotsGameLua.m_bSplashFlags[SplashType.BigWin] or 
                 SlotsGameLua.m_bSplashFlags[SplashType.HugeWin] or
                 SlotsGameLua.m_bSplashFlags[SplashType.MegaWin] or
                 SlotsGameLua.m_bSplashFlags[SplashType.EpicWin] or
                 SlotsGameLua.m_bSplashFlags[SplashType.SensationalWin]
                 
    SceneSlotGame.m_bPlayReelStopAudio = true

    -- if bres then -- 不需要。。2018-8-27
    --     -- 等 bigwin megawin epicwin 关闭之后再处理对应音效。。
    --     SceneSlotGame.m_bPlayReelStopAudio = false
    -- end
    
    local bHasFreeSpinFlag = SlotsGameLua.m_GameResult:HasFreeSpin()
    if bres or (not bHasFreeSpinFlag) then
        if SpinButton.m_SpinButton.interactable then
            SpinButton.m_SpinButton.interactable = false
        end
    end

    self.m_bInResult = true
    SlotsGameLua.m_nSplashActive = 1
end

function SweetBlastFreeSpinGameMain:playWinEffect() -- 中奖特效
    -- 棋盘1
    local nTotalWinLines = #self.m_GameResult.m_listWins -- 有多少根线中奖了

    for nWinIndex = 1, nTotalWinLines do
        local wi = self.m_GameResult.m_listWins[nWinIndex]
        
        -- 转圈的粒子特效、spine动画、unity动画或者放大缩小...
        self:ShowPayLineEffect(wi.m_nLineID, wi.m_nMaxMatchReelID)
    end





    -- 其他棋盘
    SweetBlastFreeSpinGameExtra1:playWinEffect()

    if SweetBlastFreeSpinCommon.m_nUsedReelsNum > 2 then
        SweetBlastFreeSpinGameExtra2:playWinEffect()
    end

    if SweetBlastFreeSpinCommon.m_nUsedReelsNum > 3 then
        SweetBlastFreeSpinGameExtra3:playWinEffect()
    end
    
end

function SweetBlastFreeSpinGameMain:ShowPayLineEffect(nLineID, nMaxMatchReelID)
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

function SweetBlastFreeSpinGameMain:PlayHitLineEffect(x, y)
    local trParent = self.m_listReelLua[x].m_listGoSymbol[y].transform
    
    local nEffectKey = self.m_nRowCount * x + y -- 棋盘2的就在此基础上加100
    
    -- local pos0 = self.m_listReelLua[x].m_listGoSymbol[y].transform.localPosition
    -- --trParent.localPosition -- Unity.Vector3.zero --
    -- local pos1 = self.m_trReels[x+1].localPosition
    -- local pos3 = trParent.localPosition
    local effectPos = Unity.Vector3.zero -- pos0 + pos1 -- + pos3
    
    local strEffectName = "lztukuai4X"
    local effectObj = PayLinePayWaysEffectHandler:PlayHitLineEffect3(effectPos, nEffectKey, strEffectName, trParent)
    
    if effectObj ~= nil then
        effectObj.m_effectGo.transform.localScale = Unity.Vector3.one
        effectObj.m_effectGo.transform.localPosition = effectPos --Unity.Vector3.zero
    end

end

-- 一列里只要检查0号位置是不是固定了一个占满整列的元素
function SweetBlastFreeSpinGameMain:PlaySpineEffect(x, y)
	local go = nil
    local nEffectKey = self.m_nRowCount * x + y
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

function SweetBlastFreeSpinGameMain:PlayMultiClipEffect(x, y)
	local go = nil
    local nEffectKey = self.m_nRowCount * x + y
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

function SweetBlastFreeSpinGameMain:LoopScaleSymbol(x, y)
	local nEffectKey = self.m_nRowCount * x + y -- 棋盘2 加 100
	
	local goSymbol = self.m_listReelLua[x].m_listGoSymbol[y]

	local reel = self.m_listReelLua[x]
	local bStickyFlag, nStickyIndex = reel:isStickyPos(0)
	if bStickyFlag then
		goSymbol = reel.m_listStickySymbol[nStickyIndex].m_goSymbol
	end

	PayLinePayWaysEffectHandler:LoopScaleSymbol2(goSymbol, nEffectKey)
end

----
--开始滚动的时候 显示静帧 隐藏spine节点
--准备结算的时候 显示静帧 显示spine节点
function SweetBlastFreeSpinGameMain:showSpineFrame0(bShowFrame0)
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

            -- SetSymbolRectGroup 只对可见节点有效 所以要放在SetActive之后再调用
            SweetBlastFreeSpinCommon:SetSymbolRectGroup(goSymbol, self.m_nReelsType)

        end

    end
end

function SweetBlastFreeSpinGameMain:showSpineNode() -- 滚动停止的时候调用
    local cnt = #self.m_listHitSymbols
    for i=1, cnt do
        local key = self.m_listHitSymbols[i]
        local x = math.floor( key/self.m_nRowCount )
        local y = key % self.m_nRowCount
        
        local reel = self.m_listReelLua[x]
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

function SweetBlastFreeSpinGameMain:StopFunction()
    local listGames = {SweetBlastFreeSpinGameMain, SweetBlastFreeSpinGameExtra1, 
                        SweetBlastFreeSpinGameExtra2, SweetBlastFreeSpinGameExtra3}

    local cnt = SweetBlastFreeSpinCommon.m_nUsedReelsNum
    for j=1, cnt do
        local game = listGames[j]
        for i=0, 4 do
            game.m_listReelLua[i]:Stop()
            game.m_listReelLua[i].m_fRotateDistance = 0.0
            game.m_listReelLua[i].m_fSpeed = game.m_listReelLua[i].m_fSpeed * 1.6
            game.m_listReelLua[i].m_fBoundSpeed = game.m_listReelLua[i].m_fBoundSpeed * 1.5
        end
    end
    
end