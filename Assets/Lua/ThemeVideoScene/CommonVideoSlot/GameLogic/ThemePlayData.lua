local ThemePlayData = {}

function ThemePlayData:Init()
    local strCFGFileName = ThemeLoader.themeName.."CFG"
    local strRq = "Lua/ThemeVideoCFG/"..strCFGFileName
    self.mCFGData = require(strRq)
    Debug.Assert(self.mCFGData ~= nil, "self.mCFGData == nil")
    Debug.Log("加载Excel表： "..strCFGFileName)
end

function ThemePlayData:Release()

end

--=-------------------------- 实用方法------------------------------

function ThemePlayData:GetLineCount()
    local nRowCount = self.mCFGData.m_nRowCount
    local nReelCount = self.mCFGData.m_nReelCount
    
    local tablePayLines = self:GetMatchPayLineTable(nReelCount, nRowCount)
    return #tablePayLines
end

function ThemePlayData:GetMatchPayLineTable(nReelCount, nRowCount)
    local tablePayLines = nil
    local strMatch = nRowCount.."X"..nReelCount
    for k, v in pairs(PayLines) do
        if string.match(k, strMatch) then
            tablePayLines = v
            break
        end
    end
        
    return tablePayLines
end

--=---------------------------设置关卡信息------------------------------

-- 设置 列信息
function ThemePlayData:SetCFGReelInfo()
    SlotsGameLua.m_listReelLua = {}
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local reelLua = ReelLua:create(i, SlotsGameLua.m_nRowCount)
        SlotsGameLua.m_listReelLua[i] = reelLua
    end
end

-- 设置符号信息
function ThemePlayData:SetCFGSymbolsInfo(SymbolList)
    if not SymbolList then
        SymbolList = self.mCFGData.SymbolList
    end
    
    SlotsGameLua.m_listSymbolLua = {}
    for k, v in pairs(SymbolList) do
        Debug.Assert(k == v.nId)
        local nSymbolId = k
        SlotsGameLua.m_listSymbolLua[nSymbolId] = SymbolLua:create(nSymbolId, v)
        if v.m_nSymbolType == 0 then
            SlotsGameLua.m_listSymbolLua[nSymbolId].type = SymbolType.Normal
        elseif v.m_nSymbolType == 2 then
            SlotsGameLua.m_listSymbolLua[nSymbolId].type = SymbolType.NullSymbol
        else
            SlotsGameLua.m_listSymbolLua[nSymbolId].type = SymbolType.Special
        end
    end

end

-- 设置 中奖线信息
function ThemePlayData:SetCFGLineInfo(tablePayLines)
    local nRowCount = SlotsGameLua.m_nRowCount
    local nReelCount = SlotsGameLua.m_nReelCount
    if tablePayLines == nil then
        tablePayLines = self:GetMatchPayLineTable(nReelCount, nRowCount)
    end
    
    SlotsGameLua.m_listLineLua = {}
    for k, v in pairs(tablePayLines) do
        local color = Unity.Color.green
        local lineLua = LineLua:create(SlotsGameLua.m_nReelCount, color)
        for index = 0, SlotsGameLua.m_nReelCount - 1 do
            lineLua.Slots[index] = v.winLine[index + 1]
        end

        SlotsGameLua.m_listLineLua[k] = lineLua
    end

end

-- 设置 基本信息
function ThemePlayData:SetCFGBasicInfo()
    local m_nRowCount = self.mCFGData.BasicInfo.nRowCount
    local m_nReelCount = self.mCFGData.BasicInfo.nReelCount
    
    SlotsGameLua.m_enumLevelType = enumThemeType["enumLevelType_"..ThemeLoader.themeKey]
    SlotsGameLua.m_nRowCount = m_nRowCount
    SlotsGameLua.m_nReelCount = m_nReelCount
end

return ThemePlayData
