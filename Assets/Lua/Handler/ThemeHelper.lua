ThemeHelper = {}

function ThemeHelper:InitEnumThemeType(ThemeConfig)
    enumThemeType = {}
    enumThemeType.None = -1
    
    local nThemeId = 100
    for i = 1,  #ThemeConfig do
        local Key = "enumLevelType_"..ThemeConfig[i].themeName
        enumThemeType[Key] = nThemeId
        nThemeId = nThemeId + 1
    end
    
end

function ThemeHelper:isClassicLevel(themeName)
	if not themeName then
		themeName = ThemeLoader.themeName
	end

    for k, v in pairs(ThemeClassicConfig) do
        if v.themeName == themeName then
            return true
        end
    end 

    return false
end

function ThemeHelper:GetConfigItemByThemeName(themeKey)
    for k, v in pairs(ThemeVideoConfig) do
        if v.themeName == themeKey then
            return v
        end
    end 
    
    for k, v in pairs(ThemeClassicConfig) do
        if v.themeName == themeKey then
            return v
        end
    end

    Debug.Assert(false)
    return nil
end

function ThemeHelper:GetThemeBundleName(themeName)
    if ThemeHelper:isClassicLevel(themeName) then
        return "ThemeClassicSlot_"..themeName
    else
        return "ThemeVideoSlot_"..themeName
    end
end

function ThemeHelper:GetThemeEntryBundleName(configItem)
    if not configItem then
		configItem = ThemeLoader.configItem
	end
    
    local themeName = configItem.themeName
    if ThemeHelper:isClassicLevel(themeName) then
        return "ThemeClassicEntry_"..themeName
    else
        return "ThemeVideoEntry_"..themeName
    end
end

function ThemeHelper:GetThemeCommonBundleName(configItem)
    local themeName = configItem.themeName

    local bundleName = ""
    if self:isClassicLevel(themeName) then
        bundleName = "ThemeClassicCommon"
    else
        bundleName = "ThemeVideoCommon"
    end     

    return bundleName
end

function ThemeHelper:GetThemeDbName(configItem)
    local nThemeEntryType = configItem.nThemeEntryType
    local themeName = configItem.themeName
    return self:GetThemeBundleName(themeName).."_LocalDb"
end

function ThemeHelper:GetThemeIndex(tableTheme, configItem)
    for k, v in pairs(tableTheme) do
        if v.themeName == configItem.themeName then
            return k
        end
    end
    
    Debug.Assert(false)
    return 0
end

--有可能主题下注用的是平均下注，这样可以确保经验值可以累加
function ThemeHelper:GetTotalBetIndex(tableBetList, nTotalBet)
    local nIndex = LuaHelper.indexOfTable(tableBetList, nTotalBet)
    if nIndex <= 0 then
        for i = 1, #tableBetList do
            if nTotalBet <= tableBetList[i] then
                nIndex = i
                break
            end
        end
    end 

    if nIndex <= 0 then
        nIndex = #tableBetList
    end

    return nIndex
end

function ThemeHelper:GetInitTotalBet()
	local listTotalBet = FormulaHelper:GetTotalBetList(PlayerHandler.nLevel)

	local nTargetIndex = 0
    if PlayerHandler.nLevel >= GameConst.nInitCashBackLevel then
		for i = #listTotalBet, 1, -1 do
			if PlayerHandler.nGoldCount >= listTotalBet[i] then
				nTargetIndex = i
				break
			end
		end

        if nTargetIndex <= 0 then
			nTargetIndex = 1
		end
	else
		nTargetIndex = 1
	end	

    Debug.Assert(nTargetIndex >= 1 and nTargetIndex <= #listTotalBet)
    return listTotalBet[nTargetIndex]
end

function ThemeHelper:GetNowTotalBet()
    return SceneSlotGame.m_nTotalBet
end

function ThemeHelper:getReturnRateIndex()
    -- 1: 0.5    2:0.95    3:2.0
    local tableRate = {300, 200, 130}--返还率 0.9
    if GameConfig.PLATFORM_EDITOR then
        local m_enumReturnRateTYPE = GameConfig.Instance.m_enumReturnRateTYPE
        if m_enumReturnRateTYPE == CS.SlotsMania.enumReturnRateTYPE.enumReturnType_None then
            tableRate = {300, 200, 130}
        elseif m_enumReturnRateTYPE == CS.SlotsMania.enumReturnRateTYPE.enumReturnType_Rate50 then
            tableRate = {1, 0, 0}
        elseif m_enumReturnRateTYPE == CS.SlotsMania.enumReturnRateTYPE.enumReturnType_Rate95 then
            tableRate = {0, 1, 0}
        elseif m_enumReturnRateTYPE == CS.SlotsMania.enumReturnRateTYPE.enumReturnType_Rate200 then
            tableRate = {0, 0, 1}
        else
            Debug.Assert(false)
        end
    else
        return ThemeReturnRateDyncmaicSwitch:GetFeatureReturnType()
    end
    
    return LuaHelper.GetIndexByRate(tableRate)
end
