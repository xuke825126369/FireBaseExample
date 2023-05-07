local StickySymbol = {}

StickySymbol.m_goSymbol = nil
StickySymbol.m_nSymbolId = 0
StickySymbol.m_nReelPos = -100 --// reel row indexPos

function StickySymbol:create(_goSymbol, _symbolID, _nReelPos)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.m_goSymbol = _goSymbol
    o.m_nSymbolId = _symbolID
    o.m_nReelPos = _nReelPos
    
    return o
end
return StickySymbol