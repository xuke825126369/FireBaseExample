local LeveData_ReSpin = {}

function LeveData_ReSpin:InitVariable()
    self.m_goSlotsGame = nil
    self.m_LevelData = nil
    self.m_goStickySymbolsDir = nil

    self.m_listReelLua = {}
    self.m_fCentBoardY = 0.0

    self.tableCurveGroup = {}
end

function LeveData_ReSpin:Init()
    self:LoadLevelData()
    self:CacheCurveGroup()
    self:initLevelParam()
end

function LeveData_ReSpin:LoadLevelData()
    local assetPath = "LevelData_ReSpin.prefab"
    local obj = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    
    local leveldataParent = Unity.GameObject.Find("NewGameNode/LevelInfo/SlotsDataInfo").transform

    local go = Unity.Object.Instantiate(obj)
    go.transform:SetParent(leveldataParent, false)
    go.transform.localScale = Unity.Vector3.one
    go.transform.localPosition = SlotsGameLua.m_goSlotsGame.transform.localPosition
    go:SetActive(false)

    self.m_goSlotsGame = go
    self.m_goStickySymbolsDir = self.m_goSlotsGame.transform:FindDeepChild("StickySymbolsDir").gameObject

end

function LeveData_ReSpin:SetSymbolsFrequencyInfo()
    for i = 1, #SlotsGameLua.m_listSymbolLua do
        local symbolLua = SlotsGameLua:GetSymbol(i)
        symbolLua.m_frequency50 = self.tableSymbolRate[i].m_frequency50
        symbolLua.m_frequency95 = self.tableSymbolRate[i].m_frequency95
        symbolLua.m_frequency200 = self.tableSymbolRate[i].m_frequency200
    end
end

function LeveData_ReSpin:initSymbolsFrequencyInfo() --ReelIndex
    self.tableSymbolRate = {}
    for i = 1, #SlotsGameLua.m_listSymbolLua do
        if not self.tableSymbolRate[i] then
            self.tableSymbolRate[i] = {}
        end
        
        self.tableSymbolRate[i].m_frequency50 = {}
        self.tableSymbolRate[i].m_frequency95 = {}
        self.tableSymbolRate[i].m_frequency200 = {}

        for j = 1, WitchFunc.nReSpinCurrentRowCount * 5 do
            local nReelId = math.floor((j - 1) / WitchFunc.nReSpinCurrentRowCount) + 1
            self.tableSymbolRate[i].m_frequency50[j] = SlotsGameLua.m_listSymbolLua[i].m_frequency50[nReelId]
            self.tableSymbolRate[i].m_frequency95[j] = SlotsGameLua.m_listSymbolLua[i].m_frequency95[nReelId]
            self.tableSymbolRate[i].m_frequency200[j] = SlotsGameLua.m_listSymbolLua[i].m_frequency200[nReelId]
        end 
        
    end
end

function LeveData_ReSpin:initLevelParam()
    local Prem_goSlotsGame = SlotsGameLua.m_goSlotsGame
    local Prem_transform = SlotsGameLua.m_transform
    local Prem_goStickySymbolsDir = SlotsGameLua.m_goStickySymbolsDir

    SlotsGameLua.m_goSlotsGame = self.m_goSlotsGame
    SlotsGameLua.m_transform = self.m_goSlotsGame.transform
    SlotsGameLua.m_goStickySymbolsDir = self.m_goStickySymbolsDir

    self.m_nReelCount = WitchFunc.nReSpinCurrentRowCount * WitchFunc.nReSpinCurrentReelCount
    self.m_nRowCount = 1

    self:initSymbolsFrequencyInfo()

    self.m_listReelLua = {}
    for i = 0, self.m_nReelCount - 1 do
        local nReelRow = self.m_nRowCount
        local reelLua = ReelLua:create(i, nReelRow)
        self.m_listReelLua[i] = reelLua
        self.m_listReelLua[i].m_nAddSymbolNums = self.m_nRowCount
    end

    self.m_fCentBoardY = 0.0

    SlotsGameLua.m_goSlotsGame = Prem_goSlotsGame
    SlotsGameLua.m_transform = Prem_transform
    SlotsGameLua.m_goStickySymbolsDir = Prem_goStickySymbolsDir
end

function LeveData_ReSpin:InitChoice()
    
    self:SetSymbolsFrequencyInfo()

    ChoiceCommonFunc:CreateChoice()
end

function LeveData_ReSpin:SimuActive()
    self.m_nReelCount = WitchFunc.nReSpinCurrentRowCount * WitchFunc.nReSpinCurrentReelCount
    self.m_nRowCount = 1

    SlotsGameLua.m_nReelCount = self.m_nReelCount
    SlotsGameLua.m_nRowCount = self.m_nRowCount
    
    self:InitChoice()
end

function LeveData_ReSpin:Active()
    self:SetCurrentRowCurveGroup()
    self:initLevelParam()

    SlotsGameLua.m_goSlotsGame = self.m_goSlotsGame
    SlotsGameLua.m_transform = self.m_goSlotsGame.transform
    SlotsGameLua.m_goStickySymbolsDir = self.m_goStickySymbolsDir

    SlotsGameLua.m_nReelCount = self.m_nReelCount
    SlotsGameLua.m_nRowCount = self.m_nRowCount

    self:InitChoice()

    SlotsGameLua.m_listReelLua = self.m_listReelLua
    SlotsGameLua.m_fCentBoardY = self.m_fCentBoardY

    self.m_goSlotsGame:SetActive(true)
    self:RepositionSymbols()
    SlotsGameLua:CreateReelRandomSymbolList()
    SlotsGameLua:SetRandomSymbolToReel()
end

function LeveData_ReSpin:DeActive()
    SlotsGameLua:resetStickySymbols()
    self.m_goSlotsGame:SetActive(false)
end

function LeveData_ReSpin:RepositionSymbols()
    local nOutSideCount = 1
    local m_fSymbolHeight = SlotsGameLua.m_fSymbolHeight
    local nReelCount = SlotsGameLua.m_nReelCount

    local nRow0Y = 0.0

    for i = 0, nReelCount - 1 do
        local reelLua = SlotsGameLua.m_listReelLua[i]
        local nSymbolNum = reelLua.m_nReelRow + reelLua.m_nAddSymbolNums
        for y = 0, nSymbolNum - 1 do
            local fPosY = m_fSymbolHeight * y + nRow0Y
            reelLua.m_listSymbolPos[y] = Unity.Vector3(0.0, fPosY, 0.0)
        end

        reelLua.m_nOutSideCount = nOutSideCount
    end

end

-- 缓存所有的CurveGroup
function LeveData_ReSpin:CacheCurveGroup()
    local strPrePath = "NewGameNode/LevelInfo/LevelBG"
    local strBiaoChiDir = strPrePath .. "/BiaoChi"
    local TopObj = Unity.GameObject.Find(strBiaoChiDir .. "/TOP")
    local BottomObj = Unity.GameObject.Find(strBiaoChiDir .. "/BOTTOM")
    local RightObj = Unity.GameObject.Find(strBiaoChiDir .. "/RIGHT")
    local LeftObj = Unity.GameObject.Find(strBiaoChiDir .. "/LEFT")

    local posRight = RightObj.transform.position
    local posLeft = LeftObj.transform.position
    local posTop = TopObj.transform.position
    local posBottom = BottomObj.transform.position

    local m_fCentBoardX = (posRight.x + posLeft.x) / 2.0
    local m_fCentBoardY = (posTop.y + posBottom.y) / 2.0

    local rowPrefab = self.m_goSlotsGame.transform:FindDeepChild("CurveGroup_Row_1").gameObject
    rowPrefab.name = "TempPrefab"
    rowPrefab:SetActive(false)

    local fMiddleY = (WitchFunc.nReSpinCurrentRowCount - 1) / 2
    local fMinPosY = (0 - fMiddleY) * SlotsGameLua.m_fSymbolHeight + m_fCentBoardY

    self.tableCacheGroupByRow = {}
    self.tableCachePosByRow = {}
    self.tableGoReel = {}
    for r = WitchFunc.nReSpinCurrentRowCount, WitchFunc.nReSpinCurrentRowCount do
        local nCurrentMaxRowCount = r

        self.tableCacheGroupByRow[nCurrentMaxRowCount] = {}
        local tableCurveGroup = self.tableCacheGroupByRow[nCurrentMaxRowCount]

        self.tableCachePosByRow[nCurrentMaxRowCount] = {}
        local tableCachePos = self.tableCachePosByRow[nCurrentMaxRowCount]

        for i = 0, nCurrentMaxRowCount - 1 do
            local rowObj = Unity.Object.Instantiate(rowPrefab)
            rowObj.transform:SetParent(rowPrefab.transform.parent, false)
            rowObj.transform.localScale = Unity.Vector3.one
            rowObj.name = "CurveGroup_"..nCurrentMaxRowCount.."_Row_"..i

            rowObj:SetActive(true)

            tableCurveGroup[i] = rowObj:GetComponent(typeof(CS.CurveGroup))
            tableCurveGroup[i].m_areaSize = Unity.Vector2(1500, SlotsGameLua.m_fSymbolHeight)

            local fPosY = (nCurrentMaxRowCount - 1 - i) * SlotsGameLua.m_fSymbolHeight + fMinPosY
            tableCurveGroup[i].transform.position = Unity.Vector3(m_fCentBoardX, fPosY, 0)
            
        end 

        for nReelId = 0, WitchFunc.nReSpinCurrentReelCount - 1 do
            local fPosX = (nReelId - 2) * SlotsGameLua.m_fSymbolWidth + m_fCentBoardX
            for nRowIndex = 0, nCurrentMaxRowCount - 1 do
                local fPosY = (nCurrentMaxRowCount - 1 - nRowIndex) * SlotsGameLua.m_fSymbolHeight + fMinPosY

                local nKey = nReelId * nCurrentMaxRowCount + nRowIndex
                tableCachePos[nKey] = Unity.Vector3(fPosX, fPosY, 0)
            end
        end

    end

    for i = 0, WitchFunc.nReSpinCurrentRowCount - 1 do
        for j = 0, WitchFunc.nReSpinCurrentReelCount - 1 do
            local goReel = Unity.GameObject()
            goReel.transform:SetParent(self.m_goSlotsGame.transform, false)
            local nKey = j * WitchFunc.nReSpinCurrentRowCount + i
            goReel.name = "Reel"..nKey
            goReel:SetActive(true)

            self.tableGoReel[nKey] = goReel
        end
    end
    
end

function LeveData_ReSpin:SetCurrentRowCurveGroup()
    local nCurrentMaxRowCount = WitchFunc.nReSpinCurrentRowCount
    self.tableCachePos = self.tableCachePosByRow[nCurrentMaxRowCount]
    self.tableCurveGroup = self.tableCacheGroupByRow[nCurrentMaxRowCount]

    for i = 0, nCurrentMaxRowCount - 1 do
        local rowObj = self.tableCurveGroup[i]
        for j = 0, WitchFunc.nReSpinCurrentReelCount - 1 do
            local nKey = j * nCurrentMaxRowCount + i

            local goReel = self.tableGoReel[nKey]
            goReel.transform:SetParent(rowObj.transform, false)
            goReel.transform.localScale = Unity.Vector3.one
            
            goReel.transform.position = self.tableCachePos[nKey]
        end
    end

end

return LeveData_ReSpin