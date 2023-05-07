local TestWinItem = {}

function TestWinItem:create(_ID)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.ID = _ID
    o.Hit = 0
    o.Bet = 0.0
    o.WinGold = 0.0

    return o
end

return TestWinItem