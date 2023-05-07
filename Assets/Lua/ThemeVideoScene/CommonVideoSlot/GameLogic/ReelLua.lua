local ReelLua = {}
ReelLua.m_goGameObject = nil
ReelLua.m_transform = nil

----ReelLua.m_SlotsGame = nil --SlotsGameLua

ReelLua.m_nID = 0 --//从0开始初始化 和之前C#保持一致。。。
ReelLua.m_nAddSymbolNums = 3  --这个值不事先编辑了，保持和slotsgame.rowcount一致
ReelLua.m_nStopOffset = -5 ---//要小于等于rowcount的相反数 控制什么时候开始展示deck的一个参数

---以下3个都是从0开始。。。元素索引从下往上012345.。。
ReelLua.m_listSymbolPos = {} --// Vector3[]  m_nReelRow+ m_nAddSymbolNums
ReelLua.m_listGoSymbol = {}  --// GameObject[] m_nReelRow+ m_nAddSymbolNums ---运行时参数
ReelLua.m_curSymbolIds = {} --比FinalValues记录的多 m_nReelRow+m_nAddSymbolNums

--从1开始。。
ReelLua.m_listStickySymbol = {} --// List<StickySymbol>()

ReelLua.m_bHasStartDeckFlag = false
---//5-11 1. zeus关为了防止滚动过程在停下来之前的随机大元素把预先生成的Deck替换掉的情况。。  2. Witch3X3完整停下来

ReelLua.m_fRotateDistance = 0.0 --事先编辑好的滚动距离  ---等待scatter的情况直接这个值乘以1.6 不单独编辑了
ReelLua.m_fSpeed = 0.0  --滚动速度 运行时参数。。随时会变化修改的
ReelLua.m_fBoundSpeed = 0.0 --反弹速度系数..

ReelLua.m_fMoveDistance = 0.0 ---//2017-8-14 -- 记录了用来判断是否有元素移除窗口了
ReelLua.m_fBoundTargetPosy = 0.0

ReelLua.m_nReelRow = 0 --不规则棋盘 每列不一样

ReelLua.m_listOutSideSymbols = {} --List<GameObject>() --- 从1开始。。。
ReelLua.m_nOutSideCount = 1 --移除棋盘外的还保留几个。。由大元素占几个格子来决定  编辑关卡时候事先编辑好
--SlotsGameLua:getLevelOutSideCount() -- 改为在这里设置了 不在编辑关卡的时候编辑了

ReelLua.m_ScatterEffectObj = nil --等待freespin中奖的特效
--ReelLua.m_bPlayingSlotFireSound = false -- 这个与哪一列无关，以前数属于reel的类的静态变量。。现在移到slotsGame去了

ReelLua.m_nStackedChoiceSeg = 0 --用来控制在滚动过程中多随机几次元素。。避免结果与滚动过程太像的情况。。redhat类似的成片掉落关卡用

ReelLua.m_bReelAniPlaying = false --//Troy Level Add.. 2017-8-3

ReelLua.m_bInSpin = false
ReelLua.m_bInStop = false
ReelLua.m_bInDamping = false

-- 每次spin结束都随机出40(不同的关卡可能不一样)个随机SymbolID来 给滚动过程中使用 如果40个用了超过了就从头开始。。循环。。 这是从1开始的数组
ReelLua.m_listRandomSymbolID = {} -- 从1开始 用完循环 这个数组里的ID是经过检查符合掉落规律的
ReelLua.m_nCurRandomIDIndex = 1

ReelLua.m_fSpeedEaseCoef = 0.0 -- 修改移动速度的一个参数 2017-9-10
ReelLua.m_fAccFullTime = 2.0 -- 加速时间2秒
ReelLua.m_fAccAge = 0.0
ReelLua.m_fSpeedStart = 0.0 --- 通过start end 插值产生 m_fSpeed
ReelLua.m_fSpeedEnd = 0.0
ReelLua.m_fCoef = 0.7 -- 开始速度是最大速度的m_fCoef倍  开始减速的时候又是从当前速度V减到m_fCoef*V
ReelLua.m_bStartDecelerateFlag = false -- 第一次切换的时候置为true 修改 Start end等。。

ReelLua.m_fCurveItemMaxSpeed = 0.0 -- 达到这个值就完全模糊。。。 小于这个值的0.7倍完全清晰

ReelLua.m_bCheckReelEffectFlag = false -- 在该列即将要停之前做检查 对特效进行一些处理。。 比如着火特效的淡出等。。
ReelLua.m_bShowSymbolLightEffect = false -- 针对带有goLight节点的元素。。

function ReelLua:create(nID, nReelRow)
    local o = {}
	setmetatable(o, self)
	self.__index = self
    o:Init(nID, nReelRow)
    return o
end

function ReelLua:Init(nID, nReelRow)
    self.m_nID = nID
    self.m_nReelRow = nReelRow

    local strName = "Reel" .. tostring(nID)
    local trReel = SlotsGameLua.m_transform:FindDeepChild(strName)

    self.name = strName
    self.m_transform = trReel
    
    self.m_goGameObject = trReel.gameObject
    LuaAutoBindMonoBehaviour.Bind(self.m_goGameObject, self)

    self.m_nAddSymbolNums = SlotsGameLua.m_nRowCount
    self.m_nStopOffset = -1.0 * SlotsGameLua.m_nRowCount

    self.m_listSymbolPos = {} -- 在SlotsGameLua:RepositionSymbols()里初始化。。

    local childCount = trReel.childCount
    for i = 0, childCount - 1 do
        local childObj = trReel:GetChild(i).gameObject
        Unity.Object.Destroy(childObj)
    end

    self.m_listGoSymbol = {} --以前的编辑元素在上面都删掉了
    self.m_curSymbolIds = {}

    self.m_listOutSideSymbols = {}

    self.m_fSpeedStart = 0
    self.m_fSpeedEnd = 0
    self.m_fAccAge = 0.0
    self.m_bStartDecelerateFlag = false
    self.m_fSpeed = 0
    
    self:initReelParam() --这个reel不需要有不同的初始化的值就不用写了，共用ReelLua表，如果是表成员，还是要写的。。类似m_listOutSideSymbols
end

function ReelLua:initReelParam()
    ---以下2个都是从0开始。。。元素索引从下往上012345.。。
    --o.m_listGoSymbol = {}  --// GameObject[] m_nReelRow+ m_nAddSymbolNums ---运行时参数
    --o.m_curSymbolIds = {} --比FinalValues记录的多 m_nReelRow+m_nAddSymbolNums

    self.m_listRandomSymbolID = {} -- 从1开始 用完循环 这个数组里的ID是经过检查符合掉落规律的
    self.m_nCurRandomIDIndex = 1

    self.m_bCheckReelEffectFlag = false
    self.m_bShowSymbolLightEffect = false

    --从1开始。。
    self.m_listStickySymbol = {} --// List<StickySymbol>()

    self.m_bHasStartDeckFlag = false
    ---//5-11 1. zeus关为了防止滚动过程在停下来之前的随机大元素把预先生成的Deck替换掉的情况。。  2. Witch3X3完整停下来

    self.m_fRotateDistance = 0.0 --事先编辑好的滚动距离  ---等待scatter的情况直接这个值乘以1.6 不单独编辑了
    self.m_fSpeed = 0.0  --滚动速度 运行时参数。。随时会变化修改的
    self.m_fBoundSpeed = 0.0 --反弹速度系数..

    self.m_fMoveDistance = 0.0 ---//2017-8-14 -- 记录了用来判断是否有元素移除窗口了
    self.m_fBoundTargetPosy = 0.0

    --self.m_listOutSideSymbols = {} --List<GameObject>()
    self.m_nOutSideCount = 1 --移除棋盘外的还保留几个。。由大元素占几个格子来决定  编辑关卡时候事先编辑好

    self.m_ScatterEffectObj = nil --等待freespin中奖的特效

    self.m_nStackedChoiceSeg = 0 --用来控制在滚动过程中多随机几次元素。。避免结果与滚动过程太像的情况。。redhat类似的成片掉落关卡用

    self.m_bReelAniPlaying = false --//Troy Level Add.. 2017-8-3

    self.m_bInSpin = false
    self.m_bInStop = false
    self.m_bInDamping = false
    self.bInDeck = false
    
end

function ReelLua:reset()
    Unity.GameObject.Destroy(self.m_goGameObject)
    self.m_goGameObject = nil

    for k,v in pairs(self.m_listGoSymbol) do
        Unity.GameObject.Destroy(v)
    end
    self.m_listGoSymbol = {}

    self.m_listStickySymbol = {}
    self.m_listOutSideSymbols = {}
end

function ReelLua:Start()
end

function ReelLua:OnEnable()
end

function ReelLua:OnDisable()
    
end

function ReelLua:OnDestroy()
    self:reset()
end

function ReelLua:setCurveItemBlendRatio(fBlurCoef)
    local fSpeedCoef = self.m_fSpeed / self.m_fCurveItemMaxSpeed
    local fAlpha = fSpeedCoef / 0.5
    if fAlpha > 1 then
        fAlpha = 1
    elseif fAlpha < 0 then
        fAlpha = 0
    end
    
    local cnt = self.m_nReelRow + self.m_nAddSymbolNums
    for i=0, cnt-1 do
        local go = self.m_listGoSymbol[i]

        local curItem = SymbolObjectPool.m_mapCurveItem[go]
        if curItem ~= nil then
            curItem.alpha = 1 - fAlpha
        end

        local curSpineItem = SymbolObjectPool.m_mapCurveSpineItem[go]
        if curSpineItem ~= nil then
            curSpineItem.alpha = 1 - fAlpha
        end

        local goblurCurItem = SymbolObjectPool.m_mapgoblurCurveItem[go]
        if goblurCurItem ~= nil then
            goblurCurItem.alpha = fAlpha
        end

        local curveItemLight = SymbolObjectPool.m_mapCurveItemGoLight[go]
        if curveItemLight ~= nil then
            if curveItemLight.gameObject.activeSelf then
                curveItemLight.gameObject:SetActive(false)
            end
        end

        local curveItemDark = SymbolObjectPool.m_mapCurveItemGoDark[go]
        if curveItemDark ~= nil then
            if curveItemDark.gameObject.activeSelf then
                curveItemDark.gameObject:SetActive(false)
            end
        end
    end
    --m_listOutSideSymbols
    local nOutSideSymbols = #self.m_listOutSideSymbols
    for i=1, nOutSideSymbols do
        local go = self.m_listOutSideSymbols[i]

        local curItem = SymbolObjectPool.m_mapCurveItem[go]
        if curItem ~= nil then
            curItem.alpha = 1 - fAlpha
        end

        local curSpineItem = SymbolObjectPool.m_mapCurveSpineItem[go]
        if curSpineItem ~= nil then
            curSpineItem.alpha = 1 - fAlpha
        end

        local goblurCurItem = SymbolObjectPool.m_mapgoblurCurveItem[go]
        if goblurCurItem ~= nil then
            goblurCurItem.alpha = fAlpha
        end

        local curveItemLight = SymbolObjectPool.m_mapCurveItemGoLight[go]
        if curveItemLight ~= nil then
            if curveItemLight.gameObject.activeSelf then
                curveItemLight.gameObject:SetActive(false)
            end
        end

        local curveItemDark = SymbolObjectPool.m_mapCurveItemGoDark[go]
        if curveItemDark ~= nil then
            if curveItemDark.gameObject.activeSelf then
                curveItemDark.gameObject:SetActive(false)
            end
        end
    end

end

function ReelLua:Update()
    local dt = Unity.Time.deltaTime
    if not self.m_bInSpin then
        return
    end

    if SlotsGameLua.m_bReelPauseFlag then
        return -- 2019-4-9
    end

    local bStopReelFlag = LevelCommonFunctions:isStopReel(self.m_nID)
    if bStopReelFlag then
        self.m_bInStop = false
        self.m_bInSpin = false
        self.m_fRotateDistance = 0.0
        return
    end

    if dt > 0.15 then
        dt = 0.15
    end
    self:updateReelSymbols(dt)

    -- CurveItem 元素的模糊
  --  self:setCurveItemBlendRatio() -- 2018-7-17 没有用到了

end

function ReelLua:updateReelSymbols(dt)
    local vPos = self.m_transform.localPosition
    
    local STEPTIME = 0.01 -- 控制别移动太多 导致每列反弹的距离差别很大
    while dt > STEPTIME do 
        dt = dt - STEPTIME

        vPos = self:stepReelSymbols(STEPTIME, vPos)
    end

    if dt > 0.0 then
        vPos = self:stepReelSymbols(dt, vPos)
    end

    self.m_transform.localPosition = vPos
end

function ReelLua:decelerate(dt)
    if not self.m_bStartDecelerateFlag then
        self.m_bStartDecelerateFlag = true
        self.m_fSpeedStart = self.m_fSpeed
        self.m_fSpeedEnd = self.m_fSpeed * 0.2 --self.m_fCoef
        self.m_fAccAge = 0.0
        self.m_fAccFullTime = 1.0
    end

    if self.m_bStartDecelerateFlag then
        self.m_fAccAge = self.m_fAccAge + dt
        local val = self.m_fAccAge / self.m_fAccFullTime
        self.m_fSpeed = GameLevelUtil:easeOutQuad(self.m_fSpeedStart, self.m_fSpeedEnd, val)
    end
end

function ReelLua:stepReelSymbols(fStepTime, vPos) -- 返回vPos
    if not self.m_bInSpin then
        return vPos
    end

    local dt = fStepTime
    if self.m_bInStop and self.m_fRotateDistance <= 0.0 then --//可以准备停止了。。
        self.m_bShowSymbolLightEffect = true

        local fDelta = self.m_fSpeed * dt
        if self.m_nStopOffset < self.m_nReelRow then -- 填充Deck
            vPos.y = vPos.y - fDelta
            self.m_fMoveDistance = self.m_fMoveDistance - fDelta

            if self.m_fMoveDistance < - SlotsGameLua.m_fSymbolHeight then
                self.m_fMoveDistance = self.m_fMoveDistance + SlotsGameLua.m_fSymbolHeight
                local bStartDeckFlag = true
                if self.m_nStopOffset >= -self.m_nAddSymbolNums then
                    if self.m_nStopOffset < self.m_nReelRow - self.m_nAddSymbolNums then
                        if not self.m_bHasStartDeckFlag then
                            bStartDeckFlag = LevelCommonFunctions:isReelCanStartDeck(self.m_nID)
                            self.m_bHasStartDeckFlag = bStartDeckFlag
                        end
                        if bStartDeckFlag then
                            self.bInDeck = true

                            local nRowIndex = self.m_nStopOffset + self.m_nAddSymbolNums
                            local nDeckKey = SlotsGameLua.m_nRowCount * self.m_nID + nRowIndex
                            if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_RichOfVegas then 
                                nDeckKey = SlotsGameLua:GetDeckKey(self.m_nID, nRowIndex)
                            end
                            
                            local nDeckSymbolID = SlotsGameLua.m_listDeck[nDeckKey]
                            self:SymbolShiftDown(nDeckSymbolID, true, nDeckKey)
                        else
                            self:SymbolShiftDown( self:GetRandom(true) )
                        end
                    else
                        if not self.m_bCheckReelEffectFlag then -- 比如准备在这个时候淡出着火特效了。。
                            self.m_bCheckReelEffectFlag = true
                        end

                        self:decelerate(dt)
                        self:SymbolShiftDown( self:GetDeckFinishRandom(false) )
                    end
                else
                    self:SymbolShiftDown( self:GetRandom(false) )
                end

                if bStartDeckFlag then
                    self.m_nStopOffset = self.m_nStopOffset + 1
                end

            end
        else
            self:decelerate(dt)

            if not self.m_bInDamping then
                vPos = self:OverMoveStage(vPos, dt)
            else
                vPos = self:DampingBounceReel(vPos, dt)
            end
        end

    else
        vPos = self:ReelRamdomRunStage(vPos, dt)
        if self.bInDeck then
            Debug.Log("--error!!!!------m_nStopOffset: " .. self.m_nStopOffset)
            Debug.Log("--error!!!!---reelID: " .. self.m_nID)
            Debug.Log("--error!!!!----self.m_fMoveDistance: " .. self.m_fMoveDistance)
        end
    end

    return vPos
end

function ReelLua:ReelRamdomRunStage(vPos, dt) -- return vPos
    self.m_fAccAge = self.m_fAccAge + dt
    local val = self.m_fAccAge / self.m_fAccFullTime
    self.m_fSpeed = GameLevelUtil:easeOutQuad(self.m_fSpeedStart, self.m_fSpeedEnd, val)

    local fDelta = self.m_fSpeed * dt
    vPos.y = vPos.y - fDelta
    self.m_fMoveDistance = self.m_fMoveDistance - fDelta

    if self.m_bInStop then
        self.m_fRotateDistance = self.m_fRotateDistance - fDelta
    end

    if self.m_fMoveDistance < -SlotsGameLua.m_fSymbolHeight then
        self.m_fMoveDistance = self.m_fMoveDistance + SlotsGameLua.m_fSymbolHeight
        self:SymbolShiftDown( self:GetRandom(false) )
    end 

    return vPos
end

function ReelLua:OverMoveStage(vPos, dt)
    if self.m_fMoveDistance < -30 then
        self.m_bInDamping = true
        self.m_fSpeed = 0.0

        self.m_fBoundTargetPosy = vPos.y - self.m_fMoveDistance

        SceneSlotGame:OnPreReelStop(self.m_nID)
        local listThemeKey = {"AztecAdventure", "GrannyWolf", "StoryOfMedusa"}
        local bres = LuaHelper.tableContainsElement(listThemeKey, ThemeLoader.themeKey)
        if not bres then
            self:CheckStopNextReel()
        end
        
    else
        local fDelta = self.m_fSpeed * dt
        vPos.y = vPos.y - fDelta
        self.m_fMoveDistance = self.m_fMoveDistance - fDelta
    end

    return vPos
end

function ReelLua:PlayEffectWaitingFreeSpin()
    if self.m_nID >= SlotsGameLua.m_nReelCount-1 then
        return 
    end

    local nNextReelID = self.m_nID + 1
    local effectPos = SlotsGameLua:getReelBGPosByReelID(nNextReelID)
    local effectType = enumEffectType.Effect_ScatterEffect
    SlotsGameLua.m_listReelLua[nNextReelID].m_ScatterEffectObj = EffectObj:Show(effectPos, effectType)
    
    local  fDisCoef = 3.9
    SlotsGameLua.m_listReelLua[nNextReelID].m_fRotateDistance = SlotsGameLua.m_fRotateDistance * fDisCoef
    if not SlotsGameLua.m_bPlayingSlotFireSound then
        SlotsGameLua.m_bPlayingSlotFireSound = true
        AudioHandler:PlaySlotsOnFire()
    end
end

function ReelLua:DampingBounceReel(vPos, dt)
    self.m_fSpeed = 0.0

    local fdis = vPos.y - self.m_fBoundTargetPosy
    if math.abs( fdis ) > 1.0 then
        local fCoef = self.m_fBoundSpeed * dt
        if fCoef > 1.0 then
            fCoef = 1.0
        end
        vPos.y = vPos.y * (1.0 - fCoef) + self.m_fBoundTargetPosy * fCoef -- 线性插值 逐渐逼近目标
    else
        self:resetReelSymbolsPos()

        vPos.y = 0--0.0

        self.m_bInStop = false
        self.m_bInSpin = false
    end

    return vPos
end

function ReelLua:resetReelSymbolsPos()
    local nTotalNum = self.m_nReelRow + self.m_nAddSymbolNums
    for y = 0, nTotalNum - 1 do
        local posx = self.m_listSymbolPos[y].x
        local posy = self.m_listSymbolPos[y].y
        local posz = LevelCommonFunctions:getSymbolOrderZ(self.m_nID, y)

        local pos = Unity.Vector3(posx, posy, posz)
        local go = self.m_listGoSymbol[y]
        local tr = SymbolObjectPool.m_mapGOElemTransform[go]
        tr.localPosition = pos
    end

    local cnt = #self.m_listOutSideSymbols
    for i = 0, cnt - 1 do
        local posx = self.m_listSymbolPos[0].x
        local posy = self.m_listSymbolPos[0].y
        local posz = self.m_listSymbolPos[0].z
        posy = posy - SlotsGameLua.m_fSymbolHeight * (cnt - i)

        local pos = Unity.Vector3(posx, posy, posz)
        local go = self.m_listOutSideSymbols[i+1]
        local tr = SymbolObjectPool.m_mapGOElemTransform[go]

        tr.localPosition = pos
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold then
        if self.m_nID == 2 then
            FortunesOfGoldFunc:resetReel2SymbolsPos()
        end
    end
end

function ReelLua:SymbolShiftDown(addedValue, bResultDeck, nDeckKey)
    if bResultDeck == nil then
        bResultDeck = false
    end
    if nDeckKey == nil then
        nDeckKey = -1
    end

    local nTotalNum = self.m_nReelRow + self.m_nAddSymbolNums
    for y = 0, nTotalNum - 1 do
        if y == 0 then --这个是移除了视口的元素。。根据关卡逻辑需要对这个元素做一些特殊处理 复位一些运行时参数等
            -- 关卡相关的一些个性化处理。。。
            local goSymbol0 = self.m_listGoSymbol[0] --GameObject
            local tr = SymbolObjectPool.m_mapGOElemTransform[goSymbol0]
            local pos = tr.localPosition
            tr.localPosition = Unity.Vector3(pos.x, pos.y, 0)

            LevelCommonFunctions:setOutSideSortingGroup(goSymbol0, self.m_nID)

            table.insert(self.m_listOutSideSymbols, goSymbol0)
            local cnt = #self.m_listOutSideSymbols
            if cnt == self.m_nOutSideCount+1 then
                SymbolObjectPool:Unspawn(self.m_listOutSideSymbols[1])
                
                table.remove( self.m_listOutSideSymbols, 1 ) -- 移出
            end

            self.m_curSymbolIds[0] = -1

        end

        if y == nTotalNum-1 then
            self.m_listGoSymbol[y] = nil
            self:SetSymbol(y, addedValue, bResultDeck, nDeckKey)
        else
            self.m_listGoSymbol[y] = self.m_listGoSymbol[y+1]
			self.m_curSymbolIds[y] = self.m_curSymbolIds[y+1]
        end

        if y < nTotalNum-1 then
            local go = self.m_listGoSymbol[y]
            local tr = SymbolObjectPool.m_mapGOElemTransform[go]
            local pos = tr.localPosition
            local fOrderZ = LevelCommonFunctions:getSymbolOrderZ(self.m_nID, y)
            local newPos = Unity.Vector3(pos.x, pos.y, fOrderZ)
            tr.localPosition = newPos

            local nSymbolId = self.m_curSymbolIds[y]    
            LevelCommonFunctions:SetSortingGroup(go, nSymbolId, self.m_nID, y)
        end

    end

    self:SymbolShiftDown2(bResultDeck, nDeckKey)
end

function ReelLua:SymbolShiftDown2(bResultDeck, nDeckKey)
    local bFortunesOfGoldLevel = SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold
    
    if bFortunesOfGoldLevel and self.m_nID==2 then
        FortunesOfGoldFunc:FortunesOfGoldSymbolShiftDown(bResultDeck, nDeckKey, self.m_nID)
        return
    end
end

function ReelLua:CheckStopNextReel()
    local nNextReelID = self.m_nID + 1
    if nNextReelID > SlotsGameLua.m_nReelCount-1 then
        return
    end

    if SlotsGameLua.m_listReelLua[nNextReelID].m_bInStop then
        return
    end

    SlotsGameLua.m_listReelLua[nNextReelID]:Stop()
end

function ReelLua:Stop()
    if not self.m_bInSpin then
        return
    end

    self.m_bInStop = true
end

function ReelLua:Completed()
    if not self.m_bInStop and not self.m_bInSpin then
        return true
    else
        return false
    end
end

function ReelLua:isStickyPos(nRowIndex)
    local bres = false
    local nStickyIndex = -1
    local cnt = #self.m_listStickySymbol
    if cnt == 0 then
        return bres, nStickyIndex
    end

    for i=1, cnt do
        if self.m_listStickySymbol[i].m_nReelPos == nRowIndex then
            nStickyIndex = i
            bres = true

            return bres, nStickyIndex
        end
    end

    return bres, nStickyIndex
end

function ReelLua:SetSymbolRandom()
    local nTotal = self.m_nReelRow + self.m_nAddSymbolNums

    for i=0, nTotal-1 do
        local nId = self:GetRandom(false)
        self:SetSymbol(i, nId)
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold then
        if self.m_nID == 2 then
            FortunesOfGoldFunc:SetSymbolRandomReel2() -- 只在初始化棋盘的时候用到一次
        end
    end
end

function ReelLua:GetDeckFinishRandom()
    local nSymbolID = 0
    local levelType = SlotsGameLua.m_enumLevelType
    
    if levelType == enumThemeType.enumLevelType_CashRespins then
        return CashRespinsFunc:GetDeckFinishRandom(self.m_nID)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MermaidMischief then
        return MermaidMischiefFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Shinydiamonds then
        return ShinydiamondsFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MonsterRiches then
        return MonsterRichesFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Smitten then
        return SmittenFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ChiliLoco then
        return ChiliLocoFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_RichOfVegas then
        return RichOfVegasFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ColossalDog then
        return ColossalDogFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_DiaDeAmor then
        return DiaDeAmorFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Wolf then
        return WolfFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GreatZeus then
        return GreatZeusFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CharmWitch then
        return CharmWitchFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MaYa then
        return MaYaFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ReelOfDragon then
        return ReelOfDragonFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_LuckyClover then
        return LuckyCloverFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FuLink then
        return FuLinkFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_AztecAdventure then
        return AztecAdventureFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Alice then
        return AliceFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MardiGras then
        return MardiGrasFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_RedHat then
        return RedHatFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Pixie then
        return PixieFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_TigerDragon then
        return TigerDragonFunc:GetDeckFinishRandom(self.m_nID, self.m_nStopOffset)
    end

    if levelType == enumThemeType.enumLevelType_CollectLucky or
        levelType == enumThemeType.enumLevelType_CollectLuckyTestVideo or
        levelType == enumThemeType.enumLevelType_FireRewind or
        levelType == enumThemeType.enumLevelType_FireRewindTestVideo or
        levelType == enumThemeType.enumLevelType_Shinydiamonds or
        levelType == enumThemeType.enumLevelType_Irish
    then
        local nNullSymbolID = SlotsGameLua:GetSymbolIdxByType(SymbolType.NullSymbol)
        
        local nIndex = self.m_nReelRow + self.m_nAddSymbolNums -1
        local nPreID = self.m_curSymbolIds[nIndex]
        if nPreID == nNullSymbolID then
            nSymbolID = self:GetRandom(false) --math.random(1, 6)
            while nSymbolID == nNullSymbolID do
                nSymbolID = self:GetRandom(false)
            end
            if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_LuckyStar and self.m_nID == 3
            then
                nSymbolID = math.random(10, 12) -- luckyStar x2 x5 x10等。。。todo 不同的关卡不同。。
            end
        else
            nSymbolID = nNullSymbolID --self:GetRandom(true)
        end

        return nSymbolID
    end

    nSymbolID = self:GetRandom(false)
    return nSymbolID
end

function ReelLua:GetRandom(bStopFlag)
    if bStopFlag then
        if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_WildSliding then
            return WildSlidingFunc:getRandomSymbolIdToStop(self.m_nID)
        elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_AztecAdventure then
            return AztecAdventureFunc:getRandomSymbolIdToStop(self.m_nID)
        end
    end
    
    local cnt = #self.m_listRandomSymbolID
    if self.m_nCurRandomIDIndex > cnt then
        self.m_nCurRandomIDIndex = 1
    end
    local nSymbolID = self.m_listRandomSymbolID[self.m_nCurRandomIDIndex]
    self.m_nCurRandomIDIndex = self.m_nCurRandomIDIndex + 1

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_WildBeast then
        nSymbolID = WildBeastFunc:CheckShiftDownSymbolRule(nSymbolID)
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Phoenix then
        nSymbolID = PhoenixFunc:CheckShiftDownSymbolRule(nSymbolID)
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GiantTreasure then
        nSymbolID = GiantTreasureFunc:CheckShiftDownSymbolRule(nSymbolID)
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SantaMania then
        nSymbolID = SantaManiaFunc:CheckShiftDownSymbolRule(nSymbolID)
    end

    return nSymbolID
end

function ReelLua:SetSymbol(y, nSymbolID, bResultDeck, nDeckKey)
    if bResultDeck == nil then
        bResultDeck = false
    end

    if nDeckKey == nil then
        nDeckKey = -1
    end

    self.m_curSymbolIds[y] = nSymbolID
    if self.m_listGoSymbol[y] ~= nil then
        SymbolObjectPool:Unspawn(self.m_listGoSymbol[y])
    end

    local go = LevelCommonFunctions:SpawnSymbol(nSymbolID, self.m_nID, y)
    local tr = SymbolObjectPool.m_mapGOElemTransform[go]
    tr:SetParent(self.m_transform)
    tr.localScale = Unity.Vector3.one

    local elemPos = self.m_listSymbolPos[y]
    if y >= 1 then
        local preGo = self.m_listGoSymbol[y-1]
        local preTr = SymbolObjectPool.m_mapGOElemTransform[preGo]
        local prePos = preTr.localPosition
        elemPos = prePos
        elemPos.y = elemPos.y + SlotsGameLua.m_fSymbolHeight
        --- 滚动过程中elemPos 与 self.m_listSymbolPos[y]是不同的。。。
    end
    tr.localPosition = elemPos

    local fOrderZ = LevelCommonFunctions:getSymbolOrderZ(self.m_nID, y)
    local newPos = Unity.Vector3(elemPos.x, elemPos.y, fOrderZ)
    tr.localPosition = newPos

    self.m_listGoSymbol[y] = go
    LevelCommonFunctions:SetSortingGroup(go, nSymbolID, self.m_nID, y)
    LevelCommonFunctions:SymbolCustomHandler(self.m_nID, y, bResultDeck, nDeckKey)

end

function ReelLua:SymbolScaleReset()
    local nTotalNum = self.m_nReelRow + self.m_nAddSymbolNums
    for i=0, nTotalNum-1 do
        local go = self.m_listGoSymbol[i]
        local tr = SymbolObjectPool.m_mapGOElemTransform[go]
        tr.localScale = Unity.Vector3.one
    end
end

function ReelLua:getReelRotateDistance()
    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_KingOfOcean then
        return KingOfOceanFunc:getReelRotateDistance(self.m_nID)
    end   

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SweetBlast then
        return SweetBlastFunc:getReelRotateDistance(self.m_nID)
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortuneFarm then
        return FortuneFarmFunc:getReelRotateDistance(self.m_nID)
    end
    
    local distance = 2200.0 --不用编辑的值了
    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GrannyWolf and SlotsGameLua.m_GameResult:InReSpin() then
        return GrannyWolfFunc:getReelRotateDistance(self.m_nID)
    end

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_StoryOfMedusa and SlotsGameLua.m_GameResult:InReSpin() then
        return StoryOfMedusaFunc:getReelRotateDistance(self.m_nID)
    end

    SlotsGameLua.m_fRotateDistance = distance
    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GreatZeus then   
        if SlotsGameLua.m_GameResult:InReSpin() then
            local nFakeReelId = math.floor(self.m_nID / GreatZeusFunc.nReSpinCurrentRowCount)
            if nFakeReelId == 0 then
                return distance
            elseif nFakeReelId == 1 then
                return distance / 5.0
            elseif nFakeReelId == 2 then
                return distance / 20.0
            elseif nFakeReelId == 3 then
                return distance / 30.0
            elseif nFakeReelId == 4 then
                return distance / 50.0
            end
        end
    end    

    if self.m_nID == 0 then
        return distance
    elseif self.m_nID == 1 then
        return distance/5.0
    elseif self.m_nID == 2 then
        return distance/20.0
    elseif self.m_nID == 3 then
        return distance/30.0
    elseif self.m_nID == 4 then
        return distance/50.0
    end

    return 0.0
end

function ReelLua:Spin() --- --转动距离 速度等都不用编辑的值了
    
    self.m_bCheckReelEffectFlag = false
    self.m_bShowSymbolLightEffect = false

    SlotsGameLua.m_fAcceleration = 800.0 -- 没用了
    local fMaxSpeed = 3000.0
    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SnowWhite then
        fMaxSpeed = 2900.0
    end

    if self.m_nReelRow == 1 then
        fMaxSpeed = 2000.0
    end
    
    local fmaxvalue = SlotsGameLua.m_fSymbolHeight/0.03
    if fMaxSpeed > fmaxvalue then
        fMaxSpeed = fmaxvalue
    end
    SlotsGameLua.m_fSpeedMax = fMaxSpeed

    self.m_fCurveItemMaxSpeed = fMaxSpeed

    local fcoef = self.m_fCoef
    self.m_fSpeedStart = fMaxSpeed * fcoef
    self.m_fSpeedEnd = fMaxSpeed
    self.m_fAccAge = 0.0
    self.m_bStartDecelerateFlag = false

    self.m_fSpeed = self.m_fSpeedStart
    self.m_fBoundSpeed = 10.0
    self.m_fMoveDistance = 0.0
    self.m_fRotateDistance = self:getReelRotateDistance()
    
    self.m_nStopOffset = -SlotsGameLua.m_nRowCount
    self.m_bInSpin = true
    self.m_bInStop = false
    self.m_bInDamping =false
    self.m_bHasStartDeckFlag =false

    -- Debug.Log("当前InStop旋转距离： "..self.m_nID.." | "..self.m_fRotateDistance)
    -- Debug.Log("当前最大速度： "..self.m_fSpeedEnd)
    -- -- Debug.Log("当前初始速度： "..self.m_fSpeedStart)
    -- Debug.Log("当前符号高度： "..SlotsGameLua.m_fSymbolHeight)
    
    self.bInDeck = false
end

return ReelLua
