ThemeReturnRateDyncmaicConfig1Handler = {}
ThemeReturnRateDyncmaicConfig1Handler.bTest = false

function ThemeReturnRateDyncmaicConfig1Handler:Init()
    self.dbName = ThemeHelper:GetThemeBundleName(ThemeLoader.themeName)
    self.data = LocalDbHandler.data.mThemeReturnRateDyncmaicConfig1HandlerData[self.dbName]
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

function ThemeReturnRateDyncmaicConfig1Handler:SaveDb()
    setmetatable(self.data.tableFeatureSpinCount, {__jsontype = "array"})
    setmetatable(self.data.tableNeedSpinCount, {__jsontype = "array"})
    LocalDbHandler.data.mThemeReturnRateDyncmaicConfig1HandlerData[self.dbName] = self.data
    LocalDbHandler:SaveDb()
end

function ThemeReturnRateDyncmaicConfig1Handler:GetDbInitData()
    local data = {}
    data.tableFeatureSpinCount = {0, 0, 0}
    data.tableNeedSpinCount = {0, 0, 0}
    return data
end

--------------------------------------------------------
function ThemeReturnRateDyncmaicConfig1Handler:RandomFeature()
    local nSumSpinCount = math.random(1, 30) * 10
    local tableSpinCountRate = ThemeReturnRateHelper:AutoGetTableFeatureSpinCountRate()
    
    self.data.tableFeatureSpinCount = {}
    for i = 1, 3 do
        local fRate = LuaHelper.GetRate01ByRateTable(tableSpinCountRate, i)
        self.data.tableFeatureSpinCount[i] = LuaHelper.GetInteger(nSumSpinCount * fRate)
    end

    self.data.tableNeedSpinCount = {0, 0, 0}
    self:SaveDb()
end

function ThemeReturnRateDyncmaicConfig1Handler:orInFeature()
    return self:GetFeatureReturnType() >= 1
end

function ThemeReturnRateDyncmaicConfig1Handler:GetFeatureReturnType()
    local tempTable = LuaHelper.GetRandomTable({1, 2, 3})
    
    for i = 1, #tempTable do
        local nIndex = tempTable[i]
        if self.data.tableNeedSpinCount[nIndex] < self.data.tableFeatureSpinCount[nIndex] then
            return nIndex
        end
    end

    return -1
end

function ThemeReturnRateDyncmaicConfig1Handler:AddSpin()
    if not self:orInFeature() then
        return
    end

    if not ThemeReturnRateDyncmaicSwitch:orInReturnRateDyncmaicType(1) then
        return
    end

    local nIndex = ThemeReturnRateDyncmaicConfig1Handler:GetFeatureReturnType()
    self.data.tableNeedSpinCount[nIndex] = self.data.tableNeedSpinCount[nIndex] + 1
    self:SaveDb()

    if Debug.bOpen then
        Debug.Log("特殊返还率1: "..nIndex.." | "..self.data.tableNeedSpinCount[nIndex].." | "..self.data.tableFeatureSpinCount[nIndex])
    end
end
