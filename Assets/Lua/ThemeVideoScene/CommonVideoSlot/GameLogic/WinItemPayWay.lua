local WinItemPayWay = {}

function WinItemPayWay:create(_SymbolIdx, _Matches, _Ways, _WinGold)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.m_nSymbolIdx = _SymbolIdx
    o.m_nMatches = _Matches ---// match count //3 4 5等最长几个元素。。从reel0到reeln就是n+1连
    o.m_nWays = _Ways
    o.m_fWinGold = _WinGold ---// win reward nWays*MultiBet (symbolID & matches )

    return o
end

return WinItemPayWay