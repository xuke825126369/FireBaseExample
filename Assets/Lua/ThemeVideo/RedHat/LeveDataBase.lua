local LeveDataBase = {}

function LeveDataBase:InitVariable()
    
end

function LeveDataBase:New()
    local o = {}
	setmetatable(o, self)
	self.__index = self
    return o
end

function LeveDataBase:Init()
    self.m_nReelCount = 0
    self.m_nRowCount = 0
    self.strBiaoChiName = ""
    self.symbolListName = ""
    self.SymbolLuaGenerator = nil
    self.m_listReelLua = nil
    self.m_listSymbolLua = nil
end

function LeveDataBase:SimuActive()
    SlotsGameLua.m_nReelCount = self.m_nReelCount
    SlotsGameLua.m_nRowCount = self.m_nRowCount
    
    local mCFGData = require("Lua/ThemeVideoCFG/RedHatCFG")
    if not self.m_listSymbolLua then
        self.m_listSymbolLua = {}
        for k, v in pairs(mCFGData[self.symbolListName]) do
            Debug.Assert(k == v.nId)
            local nSymbolId = k
            self.m_listSymbolLua[nSymbolId] = self.SymbolLuaGenerator:create(nSymbolId, v)
            if v.m_nSymbolType == 0 then
                self.m_listSymbolLua[nSymbolId].type = SymbolType.Normal
            elseif v.m_nSymbolType == 2 then
                self.m_listSymbolLua[nSymbolId].type = SymbolType.NullSymbol
            else
                self.m_listSymbolLua[nSymbolId].type = SymbolType.Special
            end
        end
    end     

    SlotsGameLua.m_listSymbolLua = self.m_listSymbolLua
    ChoiceCommonFunc:InitChoice()
end

function LeveDataBase:Active()
    SlotsGameLua.m_nReelCount = self.m_nReelCount
    SlotsGameLua.m_nRowCount = self.m_nRowCount

    if not self.m_listReelLua then
        self.m_listReelLua = {}
        for i = 0, SlotsGameLua.m_nReelCount - 1 do
            local nReelId = i
            local nRowCount = SlotsGameLua.m_nRowCount
            local reelLua = ReelLua:create(nReelId, nRowCount)
            self.m_listReelLua[i] = reelLua
        end
    end
    
    local mCFGData = require("Lua/ThemeVideoCFG/RedHatCFG")
    if not self.m_listSymbolLua then
        self.m_listSymbolLua = {}
        for k, v in pairs(mCFGData[self.symbolListName]) do
            Debug.Assert(k == v.nId)
            local nSymbolId = k
            self.m_listSymbolLua[nSymbolId] = self.SymbolLuaGenerator:create(nSymbolId, v)
            if v.m_nSymbolType == 0 then
                self.m_listSymbolLua[nSymbolId].type = SymbolType.Normal
            elseif v.m_nSymbolType == 2 then
                self.m_listSymbolLua[nSymbolId].type = SymbolType.NullSymbol
            else
                self.m_listSymbolLua[nSymbolId].type = SymbolType.Special
            end
        end
        
        for i = 1, #self.m_listSymbolLua do
            SymbolObjectPool:AddPoolItem(self.m_listSymbolLua[i], 15)
        end
        SymbolObjectPool:CreateStartupPools()
    end     
    
    SlotsGameLua.m_listReelLua = self.m_listReelLua
    SlotsGameLua.m_listSymbolLua = self.m_listSymbolLua

    ChoiceCommonFunc:InitChoice()
    self:RepositionSymbols()
    SlotsGameLua:CreateReelRandomSymbolList()
    SlotsGameLua:SetRandomSymbolToReel()

end

function LeveDataBase:DeActive()
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount * 2 - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
            SymbolObjectPool:Unspawn(goSymbol)
            SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j] = nil
        end
    end
end

function LeveDataBase:RepositionSymbols()
    local strBiaoChiDir = "NewGameNode/LevelInfo/LevelBG/"..self.strBiaoChiName
    local TopObj = Unity.GameObject.Find(strBiaoChiDir .. "/TOP")
    local BottomObj = Unity.GameObject.Find(strBiaoChiDir .. "/BOTTOM")
    local RightObj = Unity.GameObject.Find(strBiaoChiDir .. "/RIGHT")
    local LeftObj = Unity.GameObject.Find(strBiaoChiDir .. "/LEFT")
    
    local posRight = RightObj.transform.position
    local posLeft = LeftObj.transform.position
    local posTop = TopObj.transform.position
    local posBottom = BottomObj.transform.position
    
    self.m_fCentBoardX = (posRight.x + posLeft.x) / 2.0
    self.m_fCentBoardY = (posTop.y + posBottom.y) / 2.0
    self.m_fCentBoardZ = (posTop.z + posBottom.z) / 2.0
    self.m_fSymbolWidth = (posRight.x - posLeft.x) / SlotsGameLua.m_nReelCount
    self.m_fSymbolHeight = (posTop.y - posBottom.y) / SlotsGameLua.m_nRowCount

    SlotsGameLua.m_fCentBoardX = self.m_fCentBoardX
    SlotsGameLua.m_fCentBoardY = self.m_fCentBoardY
    SlotsGameLua.m_fCentBoardZ = self.m_fCentBoardZ
    SlotsGameLua.m_fSymbolWidth = self.m_fSymbolWidth
    SlotsGameLua.m_fSymbolHeight = self.m_fSymbolHeight
    
    local fMiddleReel = (SlotsGameLua.m_nReelCount - 1) / 2
    local fMiddleRow = (SlotsGameLua.m_nRowCount - 1) / 2

    local nOutSideCount = 1
    SlotsGameLua.m_transform.position = Unity.Vector3(self.m_fCentBoardX, self.m_fCentBoardY, self.m_fCentBoardZ)
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local reelLua = SlotsGameLua.m_listReelLua[i]
        local fPosX = (i - fMiddleReel) * self.m_fSymbolWidth + self.m_fCentBoardX
        reelLua.m_transform.position = Unity.Vector3(fPosX, self.m_fCentBoardY, self.m_fCentBoardZ)

        local nSymbolNum = reelLua.m_nReelRow + reelLua.m_nAddSymbolNums
        for y = 0, nSymbolNum - 1 do
            local fPosY = (y - fMiddleRow) * self.m_fSymbolHeight
            reelLua.m_listSymbolPos[y] = Unity.Vector3(0, fPosY, 0)
        end
        reelLua.m_nOutSideCount = nOutSideCount
    end

    self.tableCachePos = {}
    for nReelId = 0, SlotsGameLua.m_nReelCount - 1 do
        local fPosX = (nReelId - fMiddleReel) * self.m_fSymbolWidth + self.m_fCentBoardX
        for nRowIndex = 0, SlotsGameLua.m_nRowCount - 1 do
            local fPosY = (nRowIndex - fMiddleRow) * self.m_fSymbolHeight + self.m_fCentBoardY
            local nKey = nReelId * SlotsGameLua.m_nRowCount + nRowIndex
            self.tableCachePos[nKey] = Unity.Vector3(fPosX, fPosY, 0)
        end
    end 

end

return LeveDataBase
