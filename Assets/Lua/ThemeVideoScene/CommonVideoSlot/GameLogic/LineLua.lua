local LineLua = {}

function LineLua:create(nReelCount, color)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o:Init(nReelCount, color)
    return o
end

function LineLua:Init(nReelCount, color)
    self.Slots = {}
    for i = 0, nReelCount - 1 do
        self.Slots[i] = 0
    end
    self.color = color
end

return LineLua
