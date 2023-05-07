GoPool = {}

function GoPool:New(goPrefab, ItemParent, nCount)
    local temp = {}
    self.__index = self
    setmetatable(temp, self)
    temp:Init(goPrefab, ItemParent, nCount)
    return temp
end

function GoPool:Init(goPrefab, ItemParent, nCount)
    self.goPrefab = goPrefab
    self.ItemParent = ItemParent
    self.tableItemPool = {}
    self.tableUsedItem = {}
    if nCount and nCount > 0 then
        for i = 1, nCount do
            local goItem = Unity.Object.Instantiate(self.goPrefab)
            goItem.transform:SetParent(self.ItemParent, false)
            goItem.transform.localScale = Unity.Vector3.one
            table.insert(self.tableItemPool, goItem)
            goItem:SetActive(false)
        end
    end
end

function GoPool:GetItem()
    local goItem = nil
    if #self.tableItemPool == 0 then
        local goItem = Unity.Object.Instantiate(self.goPrefab)
        goItem.transform:SetParent(self.ItemParent, false)
        goItem.transform.localScale = Unity.Vector3.one
        table.insert(self.tableItemPool, goItem)
        goItem:SetActive(false)
    end
        
    goItem = table.remove(self.tableItemPool)
    self.tableUsedItem[goItem] = true
    return goItem
end

function GoPool:RecycleAllItem()
    for k, v in pairs(self.tableUsedItem) do
        self:RecycleItem(k)
    end
end

function GoPool:RecycleItem(goItem)
    goItem:SetActive(false)
    self.tableUsedItem[goItem] = false
    table.insert(self.tableItemPool, goItem)
end
