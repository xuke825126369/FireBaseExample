require("Lua/CFG/ThemeVideoConfig")
require("Lua/CFG/ThemeClassicConfig")

ThemeConfigModifyHandler = {}
ThemeConfigModifyHandler.dbName = "ThemeConfigModifyHandler"
ThemeConfigModifyHandler.nUpdateTimeInternal = 30 * 24 * 60 * 60

function ThemeConfigModifyHandler:Init()
    if Unity.PlayerPrefs.HasKey(self.dbName) then
		local dbString = Unity.PlayerPrefs.GetString(self.dbName)
        self.data = rapidjson.decode(dbString)
    else
        self.data = self:GetDbInitData()
        self:SaveDb()
    end

    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()

    self:Random()
end

function ThemeConfigModifyHandler:SaveDb()
    setmetatable(self.data.ThemeVideoConfig, {__jsontype = "array"})
    local dbString = rapidjson.encode(self.data)
    Unity.PlayerPrefs.SetString(self.dbName, dbString)
	Unity.PlayerPrefs.Save()
end

function ThemeConfigModifyHandler:GetDbInitData()
    local data = {}
    data.nLastRandomTimeStamp = 0
    data.ThemeVideoConfig = {}
    return data
end

function ThemeConfigModifyHandler:Random()
    local bCanRandom = false
    local todayRandomTimeStamp = TimeHandler:GetTimeStamp()
    if self.data.nLastRandomTimeStamp + self.nUpdateTimeInternal <= todayRandomTimeStamp then
        bCanRandom = true
    end
    
    if (not self.data.ThemeVideoConfig) then
        bCanRandom = true
    end

    if bCanRandom then
        self.data.nLastRandomTimeStamp = todayRandomTimeStamp
        self.data.ThemeVideoConfig = self:RandomThemeConfig(ThemeVideoConfig)
        self:SaveDb()
    end 

    local bModify1, bModify2
    bModify1, self.data.ThemeVideoConfig = self:CheckNeedRemoveTheme(self.data.ThemeVideoConfig, ThemeVideoConfig)
    bModify2, self.data.ThemeVideoConfig = self:CheckNeedAddTheme(self.data.ThemeVideoConfig, ThemeVideoConfig)
    
    if bModify1 or bModify2 then
        self:SaveDb()
    end
    ThemeVideoConfig = self.data.ThemeVideoConfig
end

function ThemeConfigModifyHandler:RandomThemeConfig(oriThemeConfig)
    local ThemeAllConfig = {}
    for k, v in pairs(oriThemeConfig) do
        if k ~= 1 then
            table.insert(ThemeAllConfig, v)
        end
    end
    local newThemeConfig = LuaHelper.GetRandomTable(ThemeAllConfig)
    table.insert(newThemeConfig, 1, oriThemeConfig[1])
    return newThemeConfig
end

function ThemeConfigModifyHandler:CheckNeedRemoveTheme(config1, config2)
    local tableRemoveThemeName = {}
    local bModify = false
    for k, v in pairs(config1) do
        local bHave = false
        for k1, v1 in pairs(config2) do
            if v1.themeName == v.themeName then
                bHave = true
                break
            end
        end

        if not bHave then
            table.insert(tableRemoveThemeName, v.themeName)
            bModify = true
        end
    end
    
    if #tableRemoveThemeName > 0 then
        local newConfig1 = {}
        for i = 1, #config1 do
            if not LuaHelper.tableContainsElement(tableRemoveThemeName, config1[i].themeName) then
                table.insert(newConfig1, config1[i])
            end 
        end
        config1 = newConfig1
    end

    return bModify, config1
end

function ThemeConfigModifyHandler:CheckNeedAddTheme(config1, config2)
    local bModify = false
    for k, v in pairs(config2) do
        local bHave = false
        for k1, v1 in pairs(config1) do
            if v1.themeName == v.themeName then
                bHave = true
                break
            end
        end
            
        if not bHave then
            table.insert(config1, v)
            bModify = true
        end
    end

    return bModify, config1
end
