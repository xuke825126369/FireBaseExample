local GameLevelUtil = {}

function GameLevelUtil:isPayWaysLevel() --纯lua关卡的  cshap关卡的不在这里判断
	local payWaysLevelNames = {
		"AfricaMania", "Animal",
		"SnowWhite", "CashRespins", "GoldenEgypt", "BuffaloGold", "ChiliLoco", "VesuvianForture", 
		"FuXing", "GoldMine", "AztecAdventure", "StoryOfMedusa", "TigerDragon",
	}	
			
	local strLevelName = ThemeLoader.themeKey
	return LuaHelper.tableContainsElement(payWaysLevelNames, strLevelName)
end

function GameLevelUtil:isClassicLevel() -- 用来区分两类 GameBottomUI ...
	return false
end

function GameLevelUtil:isPortraitLevel() -- 用来区分两类 GameBottomUI ...
	local strlevelNameList = {
		"RichOfVegas", "FuXing", "OceanRomance", "GreatZeus", "FireDragon", 
		"CloverAndBier", "Aladdin", "CharmWitch", "FortuneFish", "CoinFrenzy",
		"GrannyWolf", "DireWolf", "GoldenVegas", "ReelOfDragon", "PhoenixOfFire",
		"KangarooRich", "FuLink", "LegendOfCleopatra", "ScarabGem", "StoryOfMedusa",
		"FortuneFarm", "Lucky8Spins"
	}

	return LuaHelper.tableContainsElement(strlevelNameList, ThemeLoader.themeKey)
end

function GameLevelUtil:is3DLevel()
	local strlevelNameList = {"CharmWitch", "GoldenVegas"}
	return LuaHelper.tableContainsElement(strlevelNameList, ThemeLoader.themeKey)
end

function GameLevelUtil:is3DModelCurvedLevel()
	local strlevelNameList = {"CrazyDollar"}
	return LuaHelper.tableContainsElement(strlevelNameList, ThemeLoader.themeKey)
end

function GameLevelUtil:isUseSortingGroupLevel()
	local strlevelNameList = {
		"HappyChristmas", "DoggyAndDiamond", "CoinFrenzy", "MaYa", "CrazyDollar", 
		"GrannyWolf", "SafariKing", "GoldMine", "ReelFortunes", "ReelOfDragon", 
		"MagicLink", "KangarooRich", "AztecAdventure", "FuLink", "LegendOfCleopatra",
		"ScarabGem", "FortuneFarm", "Lucky8Spins"
	}
	return LuaHelper.tableContainsElement(strlevelNameList, ThemeLoader.themeKey)
end

function GameLevelUtil:hasLineParticleEffect()
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Shinydiamonds or
		SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ColossalDog or
		SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Irish or
		SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MardiGras or
		SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_HotPot
	then
		return false
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_BierMania then
		return not BierManiaFunc:orInMiniGame()
	end
	
	return true
end

function GameLevelUtil:isSixOfkind()
	local strLevelName = ThemeLoader.themeKey
	local SixOfkindLevel = {"WildBeast", "VesuvianForture"}
	local bres = LuaHelper.tableContainsElement(SixOfkindLevel, strLevelName)

	if bres then
		return true
	end
	return false
end

-- 显示线条的关卡
function GameLevelUtil:isNeedShowWinLine()
	local names = {"Shinydiamonds", "ColossalDog", "Irish", "MardiGras"}
	return LuaHelper.tableContainsElement(names, ThemeLoader.themeKey)
end

function GameLevelUtil:isCameraOrthographic()
	return not GameLevelUtil:isClassicLevel()
end

function GameLevelUtil:isMaxBet()
	local listTotalBet = self:getTotalBetList()
	local cnt = #listTotalBet
	local nMaxBet = listTotalBet[cnt]
	local nTotalBet = 0
	if self:isClassicLevel() then
		nTotalBet = ClassicSceneSlotGame.m_nTotalBet
	else
		nTotalBet = SceneSlotGame.m_nTotalBet
	end

	if nTotalBet < nMaxBet then
		return false
	else
		return true
	end
end

function GameLevelUtil:getTotalBetList()
	local listCurTotalBet1 = FormulaHelper:GetTotalBetList(PlayerHandler.nLevel)
	return listCurTotalBet1
end

function GameLevelUtil:easeInQuad(fStart, fEnd, val)
	if val > 1.0 then
		val = 1.0
	end
	
	local dis = fEnd - fStart
	return dis * val * val + fStart
end

function GameLevelUtil:easeOutQuad(fStart, fEnd, val)
	if val > 1.0 then
		val = 1.0
	end

	local dis = fEnd - fStart
	return -dis * val * (val - 2) + fStart
end

return GameLevelUtil