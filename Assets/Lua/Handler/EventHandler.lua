EventHandler = {}

EventHandler.mEventDic = {}

function EventHandler:AddListener(funcName, tableInstance)
    if self.mEventDic[funcName] == nil then
        self.mEventDic[funcName] = {}
    end
    
    if not LuaHelper.tableContainsElement(self.mEventDic[funcName], tableInstance) then
        table.insert(self.mEventDic[funcName], tableInstance)
    end
end

function EventHandler:Brocast(funcName, ...)
    if self.mEventDic[funcName] then
        for k, v in pairs(self.mEventDic[funcName]) do
            v[funcName](v, ...)
        end
    end
end

function EventHandler:RemoveListener(funcName, tableInstance)
    if tableInstance == nil then
        self.mEventDic[funcName] = nil
    else
        if self.mEventDic[funcName] then
            local nRemoveIndex = -1
            for k, v in pairs(self.mEventDic[funcName]) do
                if v == tableInstance then
                    nRemoveIndex = k
                    break
                end
            end 

            if nRemoveIndex > 0 then
                table.remove(self.mEventDic[funcName], nRemoveIndex)
            end
        end
    end 
end