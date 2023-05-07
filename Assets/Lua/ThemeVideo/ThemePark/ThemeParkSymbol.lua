--[[
    author:coldflag
    time:2021-08-12 15:25:09
]]
ThemeParkSymbol = {}

ThemeParkSymbol.CharacterSelectUI = require "Lua/ThemeVideo2020/ThemePark/SplashUI/CharacterSelectUI"
--[[
    @desc: 是否是Wild符号
    author:coldflag
    time:2021-08-12 15:33:00
    --@nSymbolId: CFG文件中符号的ID
    @return: 是Wild为1， 不是为0
]]
function ThemeParkSymbol:IsWildSymbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Wild") == nSymbolId or SlotsGameLua:GetSymbolIdByObjName("Wildx2") == nSymbolId or SlotsGameLua:GetSymbolIdByObjName("Wildx3") == nSymbolId
end

function ThemeParkSymbol:IsWildx2Symbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Wildx2") == nSymbolId
end

function ThemeParkSymbol:IsWildx3Symbol(nSymbolId)
    return SlotsGameLua:GetSymbolIdByObjName("Wildx3") == nSymbolId
end

--[[
    @desc: 
    author:coldflag
    time:2021-08-16 14:00:07
    --@intSymbolId: CFG文件中符号的ID
    @return: 是Scatter为1， 不是为0
]]
function ThemeParkSymbol:IsScatterSymbol(nSymbolId)
    return self:GetScatterSymbolID() == nSymbolId
end

--[[
    @desc: 返回Symbol Type是否为1
    author:coldflag
    time:2021-08-16 14:07:36
    --@intSymbolID: 
    @return:
]]
function ThemeParkSymbol:IsNormalSymbol(nSymbolID)
    return SlotsGameLua:GetSymbol(nSymbolID).type == SymbolType.Normal
end


function ThemeParkSymbol:GetWildx1SymbolID()
    return SlotsGameLua:GetSymbolIdByObjName("Wild")
end

function ThemeParkSymbol:GetScatterSymbolID()
    return SlotsGameLua:GetSymbolIdByObjName("Scatter")
end


--[[
    @desc: 检查棋盘上出现的是否是被选中的角色
    author:coldflag
    time:2021-08-31 11:11:36
    --@nSymbolID: 
    @return:
]]
function ThemeParkSymbol:IsSelectedCharacter(nSymbolID)
    local bResult = nSymbolID == self.CharacterSelectUI:GetSelectedCharacterID()
    return bResult
end