local ChoiceCommonFunc = {}

function ChoiceCommonFunc:InitChoice() -- 进关卡的时候调用一次
    SlotsGameLua.m_randomChoices = VideoSlotSymbolRandomChoice:New()
    self:CreateChoice()
end

function ChoiceCommonFunc:CreateChoice()
    Debug.Assert(SlotsGameLua.m_randomChoices, "SlotsGameLua.m_randomChoices == null")
    SlotsGameLua.SymbolNameIdHashTable = {}
    
    local nReelCount = SlotsGameLua.m_nReelCount
    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FishFrenzy then
        nReelCount = 5
    end
    SlotsGameLua.m_randomChoices:Init(SlotsGameLua.m_listSymbolLua, nReelCount)
end

return ChoiceCommonFunc