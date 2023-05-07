local LeveDataBase = require "Lua/ThemeVideo/RedHat/LeveDataBase"
local LeveData_3X5 = LeveDataBase:New()

function LeveData_3X5:Init()
    self.m_nReelCount = 5
    self.m_nRowCount = 3
    self.strBiaoChiName = "BiaoChi_3x5"
    self.symbolListName = "SymbolList"
    self.SymbolLuaGenerator = SymbolLua
    self.m_listReelLua = nil
    self.m_listSymbolLua = nil
end

return LeveData_3X5
