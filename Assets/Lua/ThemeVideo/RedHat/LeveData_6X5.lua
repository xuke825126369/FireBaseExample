local LeveDataBase = require "Lua/ThemeVideo/RedHat/LeveDataBase"
local LeveData_6X5 = LeveDataBase:New()

function LeveData_6X5:Init()
    self.m_nReelCount = 5
    self.m_nRowCount = 6
    self.strBiaoChiName = "BiaoChi_6x5"
    self.symbolListName = "SymbolList2"
    self.SymbolLuaGenerator = require "Lua/ThemeVideo/RedHat/CustomSymbolLua"
    self.m_listReelLua = nil
    self.m_listSymbolLua = nil
end

return LeveData_6X5
