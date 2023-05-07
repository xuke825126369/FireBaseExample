ThemeReturnRateDyncmaicConfig2Handler = {}
ThemeReturnRateDyncmaicConfig2Handler.bTest = false

function ThemeReturnRateDyncmaicConfig2Handler:Init()
    self.dbName = ThemeHelper:GetThemeBundleName(ThemeLoader.themeName)
    self.data = LocalDbHandler.data.mThemeReturnRateDyncmaicConfig2HandlerData[self.dbName]
    if self.data == nil then
        self.data = self:GetDbInitData()
    end 

    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
    if not self:orInFeature() then
        self:RandomFeature()
    end
    EventHandler:AddListener("AddSpin", self)
end 

function ThemeReturnRateDyncmaicConfig2Handler:SaveDb()
    setmetatable(self.data.tableFeatureSpinCount, {__jsontype = "array"})
    setmetatable(self.data.tableNeedSpinCount, {__jsontype = "array"})
    setmetatable(self.data.tableFeatureSortType, {__jsontype = "array"})
    LocalDbHandler.data.mThemeReturnRateDyncmaicConfig2HandlerData[self.dbName] = self.data
    LocalDbHandler:SaveDb()
end

function ThemeReturnRateDyncmaicConfig2Handler:GetDbInitData()
    local data = {}
    data.tableFeatureSortType = {1, 2, 3}
    data.tableFeatureSpinCount = {0, 0, 0}
    data.tableNeedSpinCount = {0, 0, 0}
    return data
end

--------------------------------------------------------
function ThemeReturnRateDyncmaicConfig2Handler:RandomFeature()
    local nSumSpinCount = math.random(1, 15) * 10
    local tableSpinCountRate = ThemeReturnRateHelper:AutoGetTableFeatureSpinCountRate()
    
    self.data.tableFeatureSpinCount = {}
    for i = 1, 3 do
        local fRate = LuaHelper.GetRate01ByRateTable(tableSpinCountRate, i)
        self.data.tableFeatureSpinCount[i] = LuaHelper.GetInteger(nSumSpinCount * fRate)
    end
    
    self.data.tableFeatureSortType = LuaHelper.GetRandomTable({1, 2, 3})
    self.data.tableNeedSpinCount = {0, 0, 0}
    self:SaveDb()
end

function ThemeReturnRateDyncmaicConfig2Handler:orInFeature()
    return self:GetFeatureReturnType() >= 1
end

function ThemeReturnRateDyncmaicConfig2Handler:GetFeatureReturnType()
    for i = 1, 3 do
        local nIndex = self.data.tableFeatureSortType[i]
        if self.data.tableNeedSpinCount[nIndex] < self.data.tableFeatureSpinCount[nIndex] then
            return nIndex
        end
    end
    return -1
end

function ThemeReturnRateDyncmaicConfig2Handler:AddSpin()
    if not self:orInFeature() then
        return
    end
        
    if not ThemeReturnRateDyncmaicSwitch:orInReturnRateDyncmaicType(2) then
        return
    end

    local nIndex = ThemeReturnRateDyncmaicConfig2Handler:GetFeatureReturnType()
    self.data.tableNeedSpinCount[nIndex] = self.data.tableNeedSpinCount[nIndex] + 1
    self:SaveDb()

    if Debug.bOpen then
        Debug.Log("特殊返还率2: "..nIndex.." | "..self.data.tableNeedSpinCount[nIndex].." | "..self.data.tableFeatureSpinCount[nIndex])
    end
end
