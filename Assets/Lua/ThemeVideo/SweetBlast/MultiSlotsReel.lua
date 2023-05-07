MultiSlotsReel = {}
MultiSlotsReel.name = ""
MultiSlotsReel.m_goGameObject = nil
MultiSlotsReel.m_transform = nil

MultiSlotsReel.m_SlotsGame = nil -- SweetBlastFreeSpinGameMain Extra1 等等类似..

MultiSlotsReel.m_nID = 0 --//从0开始初始化 和之前C#保持一致。。。
MultiSlotsReel.m_nReelRow = 3
MultiSlotsReel.m_nAddSymbolNums = 3  --这个值不事先编辑了，保持和slotsgame.rowcount一致
MultiSlotsReel.m_nStopOffset = -5 ---//要小于等于rowcount的相反数 控制什么时候开始展示deck的一个参数

---以下3个都是从0开始。。。元素索引从下往上012345.。。
MultiSlotsReel.m_listSymbolPos = {} --// Vector3[]  m_nReelRow+ m_nAddSymbolNums
MultiSlotsReel.m_listGoSymbol = {}  --// GameObject[] m_nReelRow+ m_nAddSymbolNums ---运行时参数
MultiSlotsReel.m_curSymbolIds = {} --比FinalValues记录的多 m_nReelRow+m_nAddSymbolNums
-- m_curSymbolIds 记录的都啥玩意啊 很不靠谱啊。。2018-8-28

--从1开始。。
MultiSlotsReel.m_listStickySymbol = {} --// List<StickySymbol>()

MultiSlotsReel.m_fRotateDistance = 0.0 --事先编辑好的滚动距离  ---等待scatter的情况直接这个值乘以1.6 不单独编辑了
MultiSlotsReel.m_fSpeed = 0.0  --滚动速度 运行时参数。。随时会变化修改的
MultiSlotsReel.m_fBoundSpeed = 0.0 --反弹速度系数..

MultiSlotsReel.m_fMoveDistance = 0.0

MultiSlotsReel.m_fBoundTargetPosy = 0.0

MultiSlotsReel.m_nOutSideSymbolID = 0 -- 屏幕外只缓存一个元素。。元素的ID
MultiSlotsReel.m_listOutSideSymbols = {} --List<GameObject>() --- 从1开始。。。
MultiSlotsReel.m_nOutSideCount = 1 

MultiSlotsReel.m_bInSpin = false
MultiSlotsReel.m_bInStop = false
MultiSlotsReel.m_bInDamping = false

-- 每次spin结束都随机出40(不同的关卡可能不一样)个随机SymbolID来 给滚动过程中使用 如果40个用了超过了就从头开始。。循环。。 这是从1开始的数组
MultiSlotsReel.m_listRandomSymbolID = {} -- 从1开始 用完循环 这个数组里的ID是经过检查符合掉落规律的

MultiSlotsReel.m_fAccFullTime = 2.0 -- 加速时间2秒
MultiSlotsReel.m_fAccAge = 0.0
MultiSlotsReel.m_fSpeedStart = 0.0 --- 通过start end 插值产生 m_fSpeed
MultiSlotsReel.m_fSpeedEnd = 0.0
MultiSlotsReel.m_fCoef = 0.6 -- 开始速度是最大速度的m_fCoef倍  开始减速的时候又是从当前速度V减到m_fCoef*V
MultiSlotsReel.m_bStartDecelerateFlag = false -- 第一次切换的时候置为true 修改 Start end等。。

function MultiSlotsReel:create(nID, nReelRow, slotsGame)
    local o = {}
	setmetatable(o, self)
	self.__index = self

    o.m_nID = nID
    o.m_nReelRow = nReelRow
    o.m_SlotsGame = slotsGame

    local strName = "ReelData" .. tostring(nID)
    local trReel = slotsGame.m_transform:FindDeepChild(strName)
    
    o.name = strName
    o.m_transform = trReel

    o.m_goGameObject = trReel.gameObject
    
    LuaAutoBindMonoBehaviour.Bind(o.m_goGameObject, o)
    LuaAutoBindMonoBehaviour.Bind(o.m_goGameObject, o)
    
    o.m_nAddSymbolNums = 1 -- slotsGame.m_nRowCount
    o.m_nStopOffset = -1.0 * o.m_nAddSymbolNums -- slotsGame.m_nRowCount

    o.m_listSymbolPos = {} -- 在 slotsGame:RepositionSymbols() 里初始化。。

    local childCount = trReel.childCount
    for i=0, childCount-1 do
        local childObj = trReel:GetChild(i).gameObject
        Unity.Object.Destroy(childObj)
    end

    o.m_listGoSymbol = {} --以前的编辑元素在上面都删掉了
    o.m_curSymbolIds = {}

    o.m_listOutSideSymbols = {}

    o.m_fSpeedStart = 0
    o.m_fSpeedEnd = 0
    o.m_fAccAge = 0.0
    o.m_bStartDecelerateFlag = false
    o.m_fSpeed = 0
    o.m_nCurRandomIDIndex = 1

    o:initReelParam()
    
    return o
end

function MultiSlotsReel:initReelParam()
    ---以下2个都是从0开始。。。元素索引从下往上012345.。。
    --o.m_listGoSymbol = {}  --// GameObject[] m_nReelRow+ m_nAddSymbolNums ---运行时参数
    --o.m_curSymbolIds = {} --比FinalValues记录的多 m_nReelRow+m_nAddSymbolNums

    self.m_listRandomSymbolID = {} -- 从1开始 用完循环 这个数组里的ID是经过检查符合掉落规律的
    
    --从1开始。。
    self.m_listStickySymbol = {} --// List<StickySymbol>()

    self.m_fRotateDistance = 0.0 --事先编辑好的滚动距离  ---等待scatter的情况直接这个值乘以1.6 不单独编辑了
    self.m_fSpeed = 0.0  --滚动速度 运行时参数。。随时会变化修改的
    self.m_fBoundSpeed = 0.0 --反弹速度系数..

    self.m_fMoveDistance = 0.0 ---//2017-8-14 -- 记录了用来判断是否有元素移除窗口了
    self.m_fBoundTargetPosy = 0.0

    --self.m_listOutSideSymbols = {} --List<GameObject>()
    self.m_nOutSideCount = 1 --移除棋盘外的还保留几个。。由大元素占几个格子来决定  编辑关卡时候事先编辑好

    self.m_bInSpin = false
    self.m_bInStop = false
    self.m_bInDamping = false

end

function MultiSlotsReel:reset()
    Unity.GameObject.Destroy(self.m_goGameObject)
    self.m_goGameObject = nil

    for k,v in pairs(self.m_listGoSymbol) do
        Unity.GameObject.Destroy(v)
    end
    self.m_listGoSymbol = {}

    self.m_listStickySymbol = {}
    self.m_listOutSideSymbols = {}
end

function MultiSlotsReel:Start()
end

function MultiSlotsReel:OnEnable()
end

function MultiSlotsReel:OnDisable()
    
end

function MultiSlotsReel:OnDestroy()
    self:reset()
end

function MultiSlotsReel:Update()
    if not self.m_bInSpin then
        return
    end

    local listWildReelIDs = SweetBlastFreeSpinCommon.m_listWildReelIDs
    local bres = LuaHelper.tableContainsElement(listWildReelIDs, self.m_nID)
    if bres then -- 固定列
        self.m_bInStop = false
        self.m_bInSpin = false
        self.m_fRotateDistance = 0.0
        return
    end

    if dt > 0.15 then
        dt = 0.15
    end
    self:updateReelSymbols(dt)
end

function MultiSlotsReel:updateReelSymbols(dt)
    local vPos = self.m_transform.localPosition
    
    local STEPTIME = 0.03 --0.03秒就可能会滚动了超过一个格子了
    while dt > STEPTIME do 
        dt = dt - STEPTIME

        vPos = self:stepReelSymbols(STEPTIME, vPos)
    end

    if dt > 0.0 then
        vPos = self:stepReelSymbols(dt, vPos)
    end

    self.m_transform.localPosition = vPos
end

function MultiSlotsReel:decelerate(dt)
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

function MultiSlotsReel:stepReelSymbols(fStepTime, vPos) -- 返回vPos
    if not self.m_bInStop and not self.m_bInSpin then
        return vPos
    end

    local dt = fStepTime
    if self.m_bInStop and self.m_fRotateDistance <= 0.0 then --//可以准备停止了。。
        --这个时候走减速过程。。 改了往后点。。
        --

        local fDelta = self.m_fSpeed * dt
        if self.m_nStopOffset < self.m_nReelRow then -- 填充Deck
            vPos.y = vPos.y - fDelta
            self.m_fMoveDistance = self.m_fMoveDistance - fDelta

            if self.m_fMoveDistance < - self.m_SlotsGame.m_fSymbolHeight then
                self.m_fMoveDistance = self.m_fMoveDistance + self.m_SlotsGame.m_fSymbolHeight
                
                if self.m_nStopOffset >= -self.m_nAddSymbolNums then
                    if self.m_nStopOffset < self.m_nReelRow - self.m_nAddSymbolNums then
                        
                        local nRowIndex = self.m_nStopOffset + self.m_nAddSymbolNums
                        local nDeckKey = self.m_SlotsGame.m_nRowCount * self.m_nID + nRowIndex

                        local nDeckSymbolID = self.m_SlotsGame.m_listDeck[nDeckKey]
                        self:SymbolShiftDown(nDeckSymbolID, true, nDeckKey)

                    else
                        --这个时候走减速过程。。
                        self:decelerate(dt)
                        self:SymbolShiftDown( self:GetDeckFinishRandom(false) ) -- deck已经填充结束
                    end
                else
                    self:SymbolShiftDown( self:GetRandom(false) ) --还未开始填充deck
                end
                
                self.m_nStopOffset = self.m_nStopOffset + 1
                self:CheckStopNextReel(self.m_nStopOffset)
            end
        else -- 上面已经填完deck 进入DampingHeight阶段。。 超过+反弹
            --这个时候继续走减速过程。。
            self:decelerate(dt)

            if not self.m_bInDamping then
                vPos = self:OverMoveStage(vPos, dt)
            else
                vPos = self:DampingBounceReel(vPos, dt)
            end
        end

    else -- 随机跑的阶段
        -- 这个过程中按一定曲线来调整滚动速度 --- 跑满事先编辑好的距离m_fRotateDistance
        -- 假如是stacked关卡 需要在这个过程中切换元素掉落种类
        vPos = self:ReelRamdomRunStage(vPos, dt)
    end

    return vPos
end

-- 这个过程中按一定曲线来调整滚动速度 --- 跑满事先编辑好的距离m_fRotateDistance
-- 假如是stacked关卡 需要在这个过程中切换元素掉落种类
function MultiSlotsReel:ReelRamdomRunStage(vPos, dt) -- return vPos
    self.m_fAccAge = self.m_fAccAge + dt
    local val = self.m_fAccAge / self.m_fAccFullTime
    self.m_fSpeed = GameLevelUtil:easeOutQuad(self.m_fSpeedStart, self.m_fSpeedEnd, val)

    local fDelta = self.m_fSpeed * dt
    vPos.y = vPos.y - fDelta
    self.m_fMoveDistance = self.m_fMoveDistance - fDelta

    if self.m_bInStop then
        self.m_fRotateDistance = self.m_fRotateDistance - fDelta
    end

    if self.m_fMoveDistance < -self.m_SlotsGame.m_fSymbolHeight then
        self.m_fMoveDistance = self.m_fMoveDistance + self.m_SlotsGame.m_fSymbolHeight
        self:SymbolShiftDown( self:GetRandom(false) )
    end

    return vPos
end

--继续掉落game.DampingHeight的距离。。
--这个过程中要播放reelstop的音效、要检查是否需要等待scatter出现等等。。。各种特效会在这个过程检查播放
function MultiSlotsReel:OverMoveStage(vPos, dt) -- return vPos
    local fDelta = self.m_fSpeed * dt
    vPos.y = vPos.y - fDelta
    self.m_fMoveDistance = self.m_fMoveDistance - fDelta
    if self.m_fMoveDistance < -self.m_SlotsGame.m_fDampingHeight then
        self.m_bInDamping = true

        self.m_fSpeed = 0.0 -- 后面不再需要用到了

        self.m_fBoundTargetPosy = vPos.y - self.m_fMoveDistance

        self.m_SlotsGame:OnPreReelStop(self.m_nID)
    end

    return vPos
end

 -- return vPos -- 其实不要返回值也行 vPos 是userdata类型 这个参数相当于传引用  是输入参数也是输出参数。。。
function MultiSlotsReel:DampingBounceReel(vPos, dt)
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

        vPos.y = 0.0 -- self.m_SlotsGame.m_fCentBoardY --0.0
        self.m_bInStop = false
        self.m_bInSpin = false
    end

    return vPos
end

function MultiSlotsReel:resetReelSymbolsPos()
    local nTotalNum = self.m_nReelRow + self.m_nAddSymbolNums
    for y=0, nTotalNum-1 do
        local posx = self.m_listSymbolPos[y].x
        local posy = self.m_listSymbolPos[y].y
        local posz = LevelCommonFunctions:getSymbolOrderZ(self.m_nID, y)

        local pos = Unity.Vector3(posx, posy, posz)
        local go = self.m_listGoSymbol[y]
        local tr = SymbolObjectPool.m_mapGOElemTransform[go]
        tr.localPosition = pos
    end
    
    -- 凡是从C#传过来的结构体变量 都是引用类型 比如下面的vector3  b = a, 对b做了修改，a的值也会被修改。。
    
    local cnt = #self.m_listOutSideSymbols
    for i=0, cnt-1 do
        local posx = self.m_listSymbolPos[0].x
        local posy = self.m_listSymbolPos[0].y
        local posz = self.m_listSymbolPos[0].z
        posy = posy - self.m_SlotsGame.m_fSymbolHeight * (cnt - i)

        local pos = Unity.Vector3(posx, posy, posz)
        local go = self.m_listOutSideSymbols[i+1]
        local tr = SymbolObjectPool.m_mapGOElemTransform[go]

        tr.localPosition = pos
    end
end

--//bResultDeck 为true的时候 nDeckKey 才有意义
function MultiSlotsReel:SymbolShiftDown(addedValue, bResultDeck, nDeckKey)
    if bResultDeck == nil then
        bResultDeck = false
    end
    if nDeckKey == nil then
        nDeckKey = -1
    end

    local nTotalNum = self.m_nReelRow + self.m_nAddSymbolNums
    for y=0, nTotalNum-1 do
        if y == 0 then --这个是移除了视口的元素。。根据关卡逻辑需要对这个元素做一些特殊处理 复位一些运行时参数等
            -- 关卡相关的一些个性化处理。。。
            local goSymbol0 = self.m_listGoSymbol[0] --GameObject
            local tr = SymbolObjectPool.m_mapGOElemTransform[goSymbol0]
            local pos = tr.localPosition
            tr.localPosition = Unity.Vector3(pos.x, pos.y, 0)

            self.m_nOutSideSymbolID = self.m_curSymbolIds[0]
            
            table.insert(self.m_listOutSideSymbols, goSymbol0)
            local cnt = #self.m_listOutSideSymbols
            if cnt == self.m_nOutSideCount+1 then
              --  SymbolObjectPool:Unspawn(self.m_listOutSideSymbols[1])
                
                self.m_SlotsGame:reuseSymbolObject(self.m_listOutSideSymbols[1])
                
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

        if y < nTotalNum-1 then -- ==nTotalNum-1的情况在SetSymbol的时候已经做了
            -- //同一列的元素 如果orderID相同 下边压上边
            local go = self.m_listGoSymbol[y]
            local tr = SymbolObjectPool.m_mapGOElemTransform[go]
            local pos = tr.localPosition
            local fOrderZ = LevelCommonFunctions:getSymbolOrderZ(self.m_nID, y)
            local newPos = Unity.Vector3(pos.x, pos.y, fOrderZ)
            tr.localPosition = newPos
        end

    end
end

function MultiSlotsReel:CheckStopNextReel(nStopOffset)
    local nNextReelID = self.m_nID + 1
    if nNextReelID > self.m_SlotsGame.m_nReelCount-1 then
        return
    end
    
    if self.m_SlotsGame.m_listReelLua[nNextReelID].m_bInStop then
        return
    end

    if nStopOffset == self.m_nReelRow then
        self.m_SlotsGame.m_listReelLua[nNextReelID]:Stop()
    end
end

function MultiSlotsReel:Stop()
    if not self.m_bInSpin then
        return
    end

    self.m_bInStop = true
end

function MultiSlotsReel:Completed()
    if not self.m_bInStop and not self.m_bInSpin then
        return true
    else
        return false
    end
end

function MultiSlotsReel:isStickyPos(nRowIndex)
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

function MultiSlotsReel:SetSymbolRandom()
    local nTotal = self.m_nReelRow + self.m_nAddSymbolNums

    for i=0, nTotal-1 do
        local nId = self:GetRandom(false)
        self:SetSymbol(i, nId)
    end
end

function MultiSlotsReel:GetDeckFinishRandom()
    local nSymbolID = 0

    nSymbolID = self:GetRandom(false)
    return nSymbolID
end

--//bStopFlag 就是玩家点了stop按钮 需要尽快允许进入展示Deck的流程
--比如3X3关卡里这个时候就只随机出空元素了！
function MultiSlotsReel:GetRandom(bStopFlag)
    if bStopFlag then
    end

    local cnt = #self.m_listRandomSymbolID

    if self.m_nCurRandomIDIndex > cnt then
        self.m_nCurRandomIDIndex = 1
    end
    local nSymbolID = self.m_listRandomSymbolID[self.m_nCurRandomIDIndex]
    self.m_nCurRandomIDIndex = self.m_nCurRandomIDIndex + 1
    
    return nSymbolID
end

function MultiSlotsReel:SetSymbol(y, nSymbolID, bResultDeck, nDeckKey)
    if bResultDeck == nil then
        bResultDeck = false
    end
    if nDeckKey == nil then
        nDeckKey = -1
    end

    -- 元素是不是符合掉落规则等 不在这里检查了 事先生成的随机数列表里去检查。

    if self.m_listGoSymbol[y] ~= nil then
      --  SymbolObjectPool:Unspawn(self.m_listGoSymbol[y])
        -- 这里是什么情况？？...

        self.m_SlotsGame:reuseSymbolObject( self.m_listGoSymbol[y] )
    end
    
    self.m_curSymbolIds[y] = nSymbolID

    -- local newSymbol = self.m_SlotsGame:GetSymbol(nSymbolID)
    -- local go = SymbolObjectPool:Spawn(newSymbol.prfab)

    local go = self.m_SlotsGame:getSymbolObject(nSymbolID) -- 2018-8-28

    local tr = SymbolObjectPool.m_mapGOElemTransform[go]
    tr:SetParent(self.m_transform)
    tr.localScale = Unity.Vector3.one

    local elemPos = self.m_listSymbolPos[y]
    if y >= 1 then
        local preGo = self.m_listGoSymbol[y-1]
        local preTr = SymbolObjectPool.m_mapGOElemTransform[preGo]
        local prePos = preTr.localPosition
        elemPos = prePos
        elemPos.y = elemPos.y + self.m_SlotsGame.m_fSymbolHeight
        --- 滚动过程中elemPos 与 self.m_listSymbolPos[y]是不同的。。。
    end
    tr.localPosition = elemPos

    --//同一列的元素 如果orderID相同 下边压上边 -- z小的压z大的
    local fOrderZ = LevelCommonFunctions:getSymbolOrderZ(self.m_nID, y)
    local newPos = Unity.Vector3(elemPos.x, elemPos.y, fOrderZ)
    tr.localPosition = newPos

    self.m_listGoSymbol[y] = go
    
    SweetBlastFreeSpinCommon:SetSymbolRectGroup(go, self.m_SlotsGame.m_nReelsType)
end

function MultiSlotsReel:getReelRotateDistance()
    local distance = 2200.0 --不用编辑的值了

    self.m_SlotsGame.m_fRotateDistance = distance

    if self.m_nID == 0 then
        return distance
    elseif self.m_nID == 1 then
        return distance/50.0
    elseif self.m_nID == 2 then
        return distance/50.0
    elseif self.m_nID == 3 then
        return distance/50.0
    elseif self.m_nID == 4 then
        return distance/50.0
    end

    return 0.0
end

function MultiSlotsReel:Spin() --- --转动距离 速度等都不用编辑的值了
    local fMaxSpeed = 3000.0 -- 3500

    local fmaxvalue = self.m_SlotsGame.m_fSymbolHeight/0.03
    if fMaxSpeed > fmaxvalue then
        fMaxSpeed = fmaxvalue
    end
    self.m_SlotsGame.m_fSpeedMax = fMaxSpeed

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

    self.m_nStopOffset = -self.m_nAddSymbolNums -- -self.m_SlotsGame.m_nRowCount
    self.m_bInSpin = true
    self.m_bInStop = false
    self.m_bInDamping =false
end
