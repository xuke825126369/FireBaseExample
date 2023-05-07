local WinItem = {}

function WinItem:create(_LineID, _SymbolIdx, _Matches, _fWinGold, _bAny3CombFlag, _nMaxMatchReelID)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.m_nLineID = _LineID
    o.m_nSymbolIdx = _SymbolIdx
    o.m_nMatches = _Matches
    o.m_fWinGold = _fWinGold
    o.m_nMaxMatchReelID = _nMaxMatchReelID
    o.m_bAny3CombFlag = _bAny3CombFlag

    return o
end

return WinItem

