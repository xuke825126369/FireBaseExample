enumThemeType = {}
enumThemeType.None = -1

function enumThemeType:Init()
    local nThemeId = 100
    for i = 1, #ThemeVideoConfig do
        local Key = "enumLevelType_"..ThemeVideoConfig[i].themeName
        enumThemeType[Key] = nThemeId
        nThemeId = nThemeId + 1
    end
    
    for i = 1,  #ThemeClassicConfig do
        local Key = "enumLevelType_"..ThemeClassicConfig[i].themeName
        enumThemeType[Key] = nThemeId
        nThemeId = nThemeId + 1
    end

end
