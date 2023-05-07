PopStackViewBase = {}

function PopStackViewBase:New()
    local temp = {}
    self.__index = self
    setmetatable(temp, self)
    return temp
end

function PopStackViewBase:orExist()
    return LuaHelper.OrGameObjectExist(self.transform)
end

function PopStackViewBase:isActiveShow()
    return LuaHelper.OrGameObjectExist(self.transform) and self.transform.gameObject.activeSelf
end

--------------------------------------------------------
PopStackViewHandler = {}

function PopStackViewHandler:Init()
    if self.transform == nil then
        self.tableStack = {}
        local go = Unity.GameObject()
        go.name = "PopStackViewHandler"
        LuaAutoBindMonoBehaviour.Bind(go, self)
        self.transform = go.transform
    end
end

function PopStackViewHandler:Show(viewInstance, ...)  
    self:Init()
    if viewInstance == nil then
        return
    end
    
    table.insert(self.tableStack, {viewInstance, {...}})
    if #self.tableStack == 1 then
        self:Do()
    end
end

function PopStackViewHandler:NextShowMe(viewInstance, ...)
    self:Init()
    if viewInstance == nil then
        return
    end
    
    if #self.tableStack >= 1 then
        table.insert(self.tableStack, 2, {viewInstance, {...}})
    else
        self:Show(viewInstance, ...)
    end
end

function PopStackViewHandler:Update()
    self:CheckDoNext()
end

function PopStackViewHandler:CheckDoNext()
    if #self.tableStack > 0 then
        local viewInstance = self.tableStack[1][1]
        if not viewInstance:isActiveShow() then
            table.remove(self.tableStack, 1)
            self:Do()
        end
    end
end

function PopStackViewHandler:Do()
    if #self.tableStack > 0 then
        local viewInstance = self.tableStack[1][1]
        local args = self.tableStack[1][2]
        viewInstance:Show(table.unpack(args))
    end
end
