local yield_return = (require 'cs_coroutine').yield_return

LuckyJumpManager = {}

LuckyJumpManager.m_mapItem = {} --存储所有Item
LuckyJumpManager.m_curPlayerPos = {0,0} --当前玩家的位置
LuckyJumpManager.m_player = nil
LuckyJumpManager.m_nWinCoins = 0
LuckyJumpManager.levelTr = nil

function LuckyJumpManager:initGameItem()
    if self.levelTr ~= nil then
        Unity.Object.Destroy(self.levelTr.gameObject)
    end
    LuckyJumpPickATilePop.m_mapBeginPos = {}
    self.m_player = nil
    self.m_nWinCoins = 0
    self.m_curPlayerPos = LuckyJumpDataHandler.data.playerPos == nil and {0,0} or LuckyJumpDataHandler.data.playerPos
    local levelName = "Level"..LuckyJumpDataHandler.data.nLevel
    local levelTable = LuckyJumpConfig[LuckyJumpDataHandler.data.nLevel]
    local path = "Assets/LuckyJump/"..levelName..".prefab"
    local prefab = Util.getLuckyJumpPrefab(path)
    self.levelTr = Unity.Object.Instantiate(prefab).transform
    self.levelTr:SetParent(LuckyJumpGamePop.m_content)
    self.levelTr.localScale = Unity.Vector3.one*0.7
    
    local endItem = nil
    local index = 0
    for i=1,#levelTable do
        for j=1,#levelTable[i] do
            local go = self.levelTr:GetChild(index).gameObject
            local item = LuckyJumpItem:new(go, i, j, levelTable[i][j])
            self.m_mapItem[i.."-"..j] = item
            index = index + 1
            if levelTable[i][j] == LuckyJumpType.End then
                endItem = item
            end
            item:showBegin()
        end
    end
    endItem.transform:SetAsLastSibling()
    if self.m_player == nil then
        self.m_player = Unity.Object.Instantiate(Util.getLuckyJumpPrefab("Assets/LuckyJump/Player.prefab")).transform
        self.m_playerAni = self.m_player:GetComponent(typeof(Unity.Animator))
        self.m_player:SetParent(self.levelTr)
        self.m_player.localScale = Unity.Vector3.one
    end
    self.m_player:SetAsLastSibling()
    self:setPlayerPos()
    self:checkIsFirstIn()
end

function LuckyJumpManager:setCurPlayerPos(pos)
    self.m_curPlayerPos = pos

    local key = self.m_curPlayerPos[1].."-"..self.m_curPlayerPos[2]
    local item = self.m_mapItem[key]
    if not (item.gameObject.activeSelf) then
        pos = LuckyJumpDataHandler.data.initPlayerPos
    end
    item:checkPrize()
    LuckyJumpDataHandler:updatePlayerPosition(pos)
end

function LuckyJumpManager:setPlayerPos()
    if self.m_curPlayerPos[1] == 0 or self.m_curPlayerPos[2] == 0 then
        self.m_player.gameObject:SetActive(false)
    else
        local key = self.m_curPlayerPos[1].."-"..self.m_curPlayerPos[2]
        local item = self.m_mapItem[key]
        if not (item.gameObject.activeSelf) then
            self.m_curPlayerPos = LuckyJumpDataHandler.data.initPlayerPos
            LuckyJumpDataHandler:updatePlayerPosition(self.m_curPlayerPos)
            self.m_player.gameObject:SetActive(false)
        else
            self.m_player.anchoredPosition = item.transform.anchoredPosition
            self.m_player.gameObject:SetActive(true)
        end
    end
end

function LuckyJumpManager:checkIsFirstIn()
    if LuckyJumpDataHandler.data.initPlayerPos == nil then
        --TODO 显示让玩家选择初始位置
        LuckyJumpPickATilePop:Show()
        return true
    end
    return false
end

function LuckyJumpManager:generateGameItem()
    local levelName = "Level3"--..LuckyJumpDataHandler.data.nLevel
    local levelTable = LuckyJumpConfig[LuckyJumpDataHandler.data.nLevel]
    local prefab = Util.getLuckyJumpPrefab("Assets/LuckyJump/Item.prefab")
    local initPos = Unity.Vector2.zero
    for i=1,#levelTable do
        for j=1,#levelTable[i] do
            local go = Unity.Object.Instantiate(prefab)
            local item = LuckyJumpItem:new(go, i, j, levelTable[i][j])
        end
    end
end

function LuckyJumpManager:beginMoveTo()
    local key = self.m_curPlayerPos[1].."-"..self.m_curPlayerPos[2]
    local item = self.m_mapItem[key]
    self.m_playerAni:SetTrigger(Unity.Animator.StringToHash("ShowEffect"))
    LeanTween.scale(item.gameObject, Unity.Vector3.one*0.9,0.2):setDelay(0.2):setOnComplete(function()
        LeanTween.scale(item.gameObject, Unity.Vector3.one,0.3)
    end)
    LeanTween.moveLocal(self.m_player.gameObject, item.transform.localPosition, 0.5):setEase(LeanTweenType.easeInOutSine):setOnComplete(function()
        self:moveEndCheck()
    end)
end

function LuckyJumpManager:moveEndCheck()
    if LuckyJumpGamePop.transform.gameObject == nil then
        return
    end
    local key = self.m_curPlayerPos[1].."-"..self.m_curPlayerPos[2]
    local item = self.m_mapItem[key]
    item:showAniEndMove()
    if not (item.gameObject.activeSelf) then
        self.m_curPlayerPos = LuckyJumpDataHandler.data.initPlayerPos
        --TODO player掉落动画，动画结束后显示player初始位置
        self:setPlayerPos()
        return
    end

    if item.bIsEnd then
        return
    end
    if LuckyJumpDataHandler.data.nMoveCount <= 0 then
        --TODO 显示Out of Moves页面
        LuckyJumpOutOfMovePop:Show()
    end
end