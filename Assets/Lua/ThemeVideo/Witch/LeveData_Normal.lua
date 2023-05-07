local LeveData_Normal = {}

function LeveData_Normal:InitVariable()
    self.m_goSlotsGame = nil
    self.m_LevelData = nil
    self.m_goStickySymbolsDir = nil

    self.m_listReelLua = nil
    self.m_fCentBoardY = 0.0
end

function LeveData_Normal:Init()
    self.m_goSlotsGame = SlotsGameLua.m_goSlotsGame 
    self.m_goStickySymbolsDir = SlotsGameLua.m_goSlotsGame.transform:FindDeepChild("StickySymbolsDir").gameObject
    self.m_listReelLua = SlotsGameLua.m_listReelLua

    self.m_randomChoices = SlotsGameLua.m_randomChoices

    local goSlotsDataInfo = Unity.GameObject.Find("NewGameNode/LevelInfo/SlotsDataInfo")
    goSlotsDataInfo.transform.position = Unity.Vector3(0, SlotsGameLua.m_fCentBoardY, 0)
    
    SlotsGameLua.m_fCentBoardY = 0
    self.m_fCentBoardY = SlotsGameLua.m_fCentBoardY
    self:initSymbolsFrequencyInfo()
end

function LeveData_Normal:SetSymbolsFrequencyInfo()
    for i = 1, #SlotsGameLua.m_listSymbolLua do
        local symbolLua = SlotsGameLua:GetSymbol(i)

        symbolLua.m_frequency50 = self.tableSymbolRate[i].m_frequency50
        symbolLua.m_frequency95 = self.tableSymbolRate[i].m_frequency95
        symbolLua.m_frequency200 = self.tableSymbolRate[i].m_frequency200
    end

end

function LeveData_Normal:initSymbolsFrequencyInfo() --ReelIndex
    self.tableSymbolRate = {}

    for i = 1, #SlotsGameLua.m_listSymbolLua do
        if not self.tableSymbolRate[i] then
            self.tableSymbolRate[i] = {}
        end
        
        self.tableSymbolRate[i].m_frequency50 = {}
        self.tableSymbolRate[i].m_frequency95 = {}
        self.tableSymbolRate[i].m_frequency200 = {}

        for j = 1, 5 do
            self.tableSymbolRate[i].m_frequency50[j] = SlotsGameLua.m_listSymbolLua[i].m_frequency50[j]
            self.tableSymbolRate[i].m_frequency95[j] = SlotsGameLua.m_listSymbolLua[i].m_frequency95[j]
            self.tableSymbolRate[i].m_frequency200[j] = SlotsGameLua.m_listSymbolLua[i].m_frequency200[j]
        end
    end

end

function LeveData_Normal:InitChoice()
    self:SetSymbolsFrequencyInfo()
    ChoiceCommonFunc:CreateChoice()
end

function LeveData_Normal:SimuActive()
    SlotsGameLua.m_nReelCount = 5
    SlotsGameLua.m_nRowCount = 3
    self:InitChoice()
end

function LeveData_Normal:Active()
    SlotsGameLua.m_goSlotsGame = self.m_goSlotsGame
    SlotsGameLua.m_transform = self.m_goSlotsGame.transform
    SlotsGameLua.m_goStickySymbolsDir = self.m_goStickySymbolsDir

    SlotsGameLua.m_nReelCount = 5
    SlotsGameLua.m_nRowCount = 3

    self:InitChoice()
            
    if not self.m_listReelLua then
        self.m_listReelLua = {}
        for i = 0, 4 do
            local nReelId = i
            local nRowCount = 4
            local reelLua = ReelLua:create(nReelId, nRowCount)
            self.m_listReelLua[i] = reelLua

            Debug.Log("Reel: "..nReelId.." | "..nRowCount)
        end
    end

    SlotsGameLua.m_listReelLua = self.m_listReelLua
    SlotsGameLua.m_fCentBoardY = self.m_fCentBoardY

    self.m_goSlotsGame:SetActive(true)
    SlotsGameLua:RepositionSymbols()
    SlotsGameLua:CreateReelRandomSymbolList()
    SlotsGameLua:SetRandomSymbolToReel()

end 

function LeveData_Normal:DeActive()
    self.m_goSlotsGame:SetActive(false)
end

return LeveData_Normal
