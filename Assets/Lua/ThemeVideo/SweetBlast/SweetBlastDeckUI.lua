SweetBlastDeckUI = {}

SweetBlastDeckUI.m_nReelCount = 20
SweetBlastDeckUI.m_nRowCount = 1
SweetBlastDeckUI.m_nFakeReelCount = 5
SweetBlastDeckUI.m_nFakeRowCount = 4
SweetBlastDeckUI.m_goLevelData = nil

SweetBlastDeckUI.GameType = {BaseGameType = 1, ReSpinType = 2}

function SweetBlastDeckUI:init()
    local go = Unity.GameObject.Find("NewGameNode/LevelInfo")
    local trLevelData = go.transform:FindDeepChild("LevelData")
    self.m_goLevelData = trLevelData.gameObject
    self.m_goLevelData:SetActive(true)

    for i=0, 4 do
        local reel = SlotsGameLua.m_listReelLua[i]
        for k,v in pairs(reel.m_listGoSymbol) do
            SymbolObjectPool:Unspawn(v)
        end
    end

    local oldReels = {}
    for i = 0, self.m_goLevelData.transform.childCount - 1 do
        local go = self.m_goLevelData.transform:GetChild(i).gameObject
        if string.match(go.name, "Reel") then
            table.insert(oldReels, go)
        end
        -- Unity.Object.Destroy(go)
        -- Destroy 是异步执行的 到下面InitReelParam的时候这里的reel01234还没有删掉
        -- DestroyImmediate
    end
    for i=1, #oldReels do
        Unity.Object.DestroyImmediate(oldReels[i])
    end

    --
    SlotsGameLua.m_nRowCount = self.m_nRowCount -- 1
    SlotsGameLua.m_nReelCount = self.m_nReelCount -- 20

    self:initRectGroup()
    self:InitReelParam()
    local list = SymbolObjectPool.m_mapPooledObjects

    self:InitChoice()
    self:RepositionSymbols()
    SweetBlastFunc:CreateReelRandomSymbolList() -- 
    SlotsGameLua:SetRandomSymbolToReel()
end 

function SweetBlastDeckUI:RepositionSymbols()
    for i = 0, self.m_nReelCount - 1 do
        local reelLua = SlotsGameLua.m_listReelLua[i]
        local oriPos = reelLua.m_transform.localPosition
        reelLua.m_transform.localPosition = Unity.Vector3(oriPos.x, 0, 0)
        local nSymbolNum = 2
        for y = 0, nSymbolNum - 1 do
            local fPosY = y * self.m_fSymbolHeight
            reelLua.m_listSymbolPos[y] = Unity.Vector3(0, fPosY, 0)
        end
    end
end

-- 1 2 3 4 是从上往下的顺序...
-- 这里不包含freespin的哪些RectGroup
function SweetBlastDeckUI:initRectGroup()
    local trRectGroup = SweetBlastLevelUI.m_transform:FindDeepChild("RectGroup")
    SweetBlastFunc.m_ReSpinFixedGroup = trRectGroup:FindDeepChild("ReSpinFixedGroup"):GetComponent(typeof(CS.CustomerRectMaskGroup))
    SweetBlastFunc.m_NormalRectGroup1 = trRectGroup:FindDeepChild("NormalGroup1"):GetComponent(typeof(CS.CustomerRectMaskGroup))
    SweetBlastFunc.m_NormalRectGroup2 = trRectGroup:FindDeepChild("NormalGroup2"):GetComponent(typeof(CS.CustomerRectMaskGroup))
    SweetBlastFunc.m_NormalRectGroup3 = trRectGroup:FindDeepChild("NormalGroup3"):GetComponent(typeof(CS.CustomerRectMaskGroup))
    SweetBlastFunc.m_NormalRectGroup4 = trRectGroup:FindDeepChild("NormalGroup4"):GetComponent(typeof(CS.CustomerRectMaskGroup))

    -- 位置大小信息...
    self:InitBiaoChi() 

    local listGroup = {SweetBlastFunc.m_NormalRectGroup1, SweetBlastFunc.m_NormalRectGroup2,
                    SweetBlastFunc.m_NormalRectGroup3, SweetBlastFunc.m_NormalRectGroup4}
    for i=1, 4 do
        local group = listGroup[i]
        local posY = (2.5 - i) * self.m_fSymbolHeight + self.m_fCentBoardY
        group.m_SpriteMask.transform.position = Unity.Vector3(self.m_fCentBoardX, posY, 0)
        group.m_SpriteMask.size = Unity.Vector2(self.m_fWidth, self.m_fSymbolHeight)
        group.m_SpriteMask.gameObject:SetActive(true)
    end

end

function SweetBlastDeckUI:InitBiaoChi()
    -- local trBiaoChi = self.m_transform:FindDeepChild("BiaoChi")
    local nReelCount = 5
    local nRowCount = 4
    -- 
    self.m_fCentBoardX = SlotsGameLua.m_fCentBoardX
    self.m_fCentBoardY = SlotsGameLua.m_fCentBoardY -- 这个是根据标尺算出来的

    SlotsGameLua.m_fCentBoardY = 0.0 
    -- 这个是ReelLua里重置列位置需要的参数... 每次切换到不同的棋盘就要去修改一下这个值。

    self.m_fWidth = SlotsGameLua.m_fAllReelsWidth
    self.m_fHeight = SlotsGameLua.m_fReelHeight

    self.m_fSymbolHeight = self.m_fHeight / nRowCount
    self.m_fSymbolWidth = self.m_fWidth / nReelCount

end 

-- reel们的各种信息
function SweetBlastDeckUI:InitReelParam()
    local strNodeName = "reels"
    local newGo = Unity.GameObject()
    newGo.name = strNodeName
    newGo.transform:SetParent(self.m_goLevelData.transform, false)
    local tr = newGo.transform
    tr.position = Unity.Vector3(self.m_fCentBoardX, self.m_fCentBoardY, 0)
    
    for j = 0, self.m_nFakeRowCount - 1 do
        local rectGroupGo = Unity.GameObject()
        rectGroupGo.name = "RectGroup_Row_"..j
        rectGroupGo.transform:SetParent(tr, false)
        local fPosY = (j - 1.5) * self.m_fSymbolHeight
        rectGroupGo.transform.localPosition = Unity.Vector3(0, fPosY, 0)

        for i = 0, self.m_nFakeReelCount - 1 do
            local goReel = Unity.GameObject()
            local nReelId = i * self.m_nFakeRowCount + (self.m_nFakeRowCount - 1 - j)
            goReel.name = "Reel"..nReelId
            goReel.transform:SetParent(rectGroupGo.transform, false)

            local fCenterReelId = 2
            local fPosX = (i - fCenterReelId) * self.m_fSymbolWidth
            goReel.transform.localPosition = Unity.Vector3(fPosX, 0, 0)

            local reelLua = ReelLua:create(nReelId, self.m_nRowCount)
            SlotsGameLua.m_listReelLua[nReelId] = reelLua
        end
    end

end

function SweetBlastDeckUI:InitChoice()
    self:initSymbolsFrequency()
    ChoiceCommonFunc:InitChoice(SlotsGameLua)
end

function SweetBlastDeckUI:initSymbolsFrequency()
    for k, v in pairs(ThemePlayData.mCFGData.SymbolList) do
        Debug.Assert(k == v.nId)
        local nSymbolId = k
        local symbol = SlotsGameLua.m_listSymbolLua[nSymbolId]
        
        local frequency50 = v.m_frequency50
        local frequency95 = v.m_frequency95
        local frequency200 = v.m_frequency200
        for i = 1, self.m_nReelCount do
            local index = (i-1) % 4
            index = index + 1
            symbol.m_frequency50[i] = frequency50[index]
            symbol.m_frequency95[i] = frequency95[index]
            symbol.m_frequency200[i] = frequency200[index]
        end
    end

end
