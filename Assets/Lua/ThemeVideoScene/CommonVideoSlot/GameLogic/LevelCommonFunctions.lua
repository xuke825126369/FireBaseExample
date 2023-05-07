local LevelCommonFunctions = {}

function LevelCommonFunctions:checkSymbolAdjacent(nReelID, nSymbolID, nPreSymbolID)
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Shinydiamonds then
		return ShinydiamondsSymbol:checkSymbolAdjacent(nReelID, nSymbolID, nPreSymbolID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Irish then
		return IrishSymbol:checkSymbolAdjacent(nReelID, nSymbolID, nPreSymbolID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MardiGras then
		return IrishSymbol:checkSymbolAdjacent(nReelID, nSymbolID, nPreSymbolID)
	end

	return nSymbolID
end

function LevelCommonFunctions:getSymbolOrderZ(nReelID, nRowIndex)
	local bClassicLevel = GameLevelUtil:isClassicLevel()
	if bClassicLevel then
		return 0
	end

	if GameLevelUtil:is3DLevel() then
		return 0
	end

	if GameLevelUtil:isUseSortingGroupLevel() then
		return 0
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_StoryOfMedusa then
		return StoryOfMedusaFunc:getSymbolOrderZ(nReelID, nRowIndex)
	end

	local nTotalRowCount = SlotsGameLua.m_nRowCount
	local nTotalReelCount = SlotsGameLua.m_nReelCount
	local count = nTotalRowCount * (nTotalReelCount - nReelID) + nRowIndex
	local fOrderZ = -1000 + 10 * count
	return fOrderZ
end

function LevelCommonFunctions:setOutSideSortingGroup(goSymbol, nReelID)
	if not GameLevelUtil:isUseSortingGroupLevel() then
		if not GameLevelUtil:is3DLevel() then
			return
		end	
	end
	
	local strKey = ThemeLoader.themeKey.."Func"
	if _G[strKey] and _G[strKey].setOutSideSortingGroup then
		_G[strKey]:setOutSideSortingGroup(goSymbol, nReelID)
		return
	end		

	local order = -99
	if SymbolObjectPool.m_mapSortingGroup[goSymbol] then
		SymbolObjectPool.m_mapSortingGroup[goSymbol].sortingOrder = order
	end
end	

function LevelCommonFunctions:SetSortingGroup(goSymbol, nSymbolId, nReelId, nRowIndex)
	if not GameLevelUtil:isUseSortingGroupLevel() then
		if not GameLevelUtil:is3DLevel() then
			return
		end	
	end

	local strKey = ThemeLoader.themeKey.."Func"
	if _G[strKey] and _G[strKey].SetSortingGroup then
		_G[strKey]:SetSortingGroup(goSymbol, nSymbolId, nReelId, nRowIndex)
		return
	end

	if nRowIndex > SlotsGameLua.m_nRowCount then
		nRowIndex = SlotsGameLua.m_nRowCount
	end

	local order = -90 + nReelId * SlotsGameLua.m_nRowCount + (SlotsGameLua.m_nRowCount - nRowIndex)
	if SymbolObjectPool.m_mapSortingGroup[goSymbol] then
		SymbolObjectPool.m_mapSortingGroup[goSymbol].sortingOrder = order
	end
end

function LevelCommonFunctions:isNeedPlayReelStopSound(nReelID)
	local bres = true

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CashRespins then
		return CashRespinsFunc:isNeedPlayReelStopSound(nReelID)
	end

	return bres
end

--该列 是否 不 旋转
function LevelCommonFunctions:isStopReel(nReelID)
	local bStopReelFlag = false

	local strKey = ThemeLoader.themeKey.."Func"
	if _G[strKey] and _G[strKey].isStopReel then
		return _G[strKey]:isStopReel(nReelID)
	end		

	return bStopReelFlag
end

function LevelCommonFunctions:isStopAllReel()
	local tableLevel = 
	{	
		enumThemeType.enumLevelType_FishFrenzy,
	}
	if LuaHelper.tableContainsElement(tableLevel, SlotsGameLua.m_enumLevelType) then
		return false
	end
	
	local bStopAllReelFlag = true

	for i = 0, SlotsGameLua.m_nReelCount -1 do
		local nReelID  = i
		
		if not LevelCommonFunctions:isStopReel(nReelID) then
			bStopAllReelFlag = false
		end
	end

	return bStopAllReelFlag
end

-- 2020-3-5 测试代码 实际不用
-- 测试..如果是玩家点了stop的情况，就直接把deck元素都填在棋盘上方
function LevelCommonFunctions:isQuicklyShowDeck()
    local rt = SlotsGameLua.m_GameResult
    local bFreeSpinFlag = rt:InFreeSpin()
    local bReSpinFlag = rt:InReSpin()
    if bFreeSpinFlag or bReSpinFlag then
        return false
	end
	
	if not SpinButton.m_bUserStopSpin then
		return false
	end

	local listLevelKey = {"MaYa"}

	local flag = LuaHelper.tableContainsElement(listLevelKey, ThemeLoader.themeKey)
	if not flag then
		return false
	end

    -- 必须要求 m_nAddSymbolNums 与 m_nReelRow相等才能这样处理
	-- 否则只能返回false了
	
	local bResult = true
	-- 各自关卡处理各自关卡的情况，如果有不能直接展示的就返回false然后会走默认流程
	-- 不过一般来说都应该允许返回true 不允许返回true的情况应该是spin按钮就不能亮起来
	if ThemeLoader.themeKey == "MaYa" then
		bResult = MaYaFunc:QuicklyShowDeck()
	end

	return bResult
end

function LevelCommonFunctions:isReelCanStartDeck(nReelID)
	-- 每关各自根据逻辑实现  todo
	local strKey = ThemeLoader.themeKey.."Func"
	if _G[strKey] and _G[strKey].isReelCanStartDeck then
		return _G[strKey]:isReelCanStartDeck(nReelID)
	end
	
	local levelType = SlotsGameLua.m_enumLevelType
	
	if levelType == enumThemeType.enumLevelType_CollectLucky or
		levelType == enumThemeType.enumLevelType_FireRewind or
		levelType == enumThemeType.enumLevelType_FireRewindTestVideo or
		levelType == enumThemeType.enumLevelType_Shinydiamonds or
		levelType == enumThemeType.enumLevelType_MardiGras or
		levelType == enumThemeType.enumLevelType_Irish
	then
		local nNullSymbolID = SlotsGameLua:GetSymbolIdxByType(SymbolType.NullSymbol)

		local reel = SlotsGameLua.m_listReelLua[nReelID]
		local nIndex = reel.m_nReelRow + reel.m_nAddSymbolNums -1
		local nPreID = reel.m_curSymbolIds[nIndex]

		local nDeckKey = SlotsGameLua.m_nRowCount * nReelID + 0
		local nDeck0 = SlotsGameLua.m_listDeck[nDeckKey]

		 -- 要求一个空 一个非空
		if nDeck0 == nNullSymbolID and nPreID ~= nNullSymbolID then
			return true
		end

		if nDeck0 ~= nNullSymbolID and nPreID == nNullSymbolID then
			return true
		end

		return false
	end

	return true
end

function LevelCommonFunctions:isNeedPlayScatterSound(nReelID)
	local bWitchFlag = SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Witch
	if bWitchFlag then
		if SlotsGameLua.m_GameResult:InReSpin() then
			return false
		end
	end
	
	local bres = self:isNeedPlayScatterSoundAndEffect(nReelID,false)
	return bres
end

function LevelCommonFunctions:isNeedPlayScatterSoundAndEffect(nReelIndex, bEffectFlag)
	local nReelCount = SlotsGameLua.m_nReelCount
	local RowCount = SlotsGameLua.m_nRowCount
	local bSoundEnable = false
	local nScatterNum = 0 -- 统计之前出了几个scatter了
	for x=0, nReelIndex-1 do
		local nRowCount = SlotsGameLua.m_listReelLua[x].m_nReelRow
		for y=0, nRowCount - 1 do
			local nSymbolID = SlotsGameLua.m_listReelLua[x].m_curSymbolIds[y]
			local eType = SlotsGameLua:GetSymbol(nSymbolID).type
			if eType == SymbolType.Scatter then
				local bStickyFlag, nStickyIndex = SlotsGameLua.m_listReelLua[x]:isStickyPos(y)
				if not bStickyFlag then
					nScatterNum = nScatterNum + 1
				end
			end
		end
	end
	
	local nRowCount = SlotsGameLua.m_listReelLua[nReelIndex].m_nReelRow
	for y=0, nRowCount - 1 do
		local nSymbolID = SlotsGameLua.m_listReelLua[nReelIndex].m_curSymbolIds[y]
		local eType = SlotsGameLua:GetSymbol(nSymbolID).type
		if eType == SymbolType.Scatter then
			local bStickyFlag, nStickyIndex = SlotsGameLua.m_listReelLua[nReelIndex]:isStickyPos(y)
			if not bStickyFlag then
				nScatterNum = nScatterNum + 1
			end
			local bres = self:isPossibleUseful(nScatterNum, nReelIndex)
			if bres then
				local goScatter = SlotsGameLua.m_listReelLua[nReelIndex].m_listGoSymbol[y]
				
				local id = LeanTween.scale(goScatter, Unity.Vector3(1.2,1.2,1.0),0.2):setLoopPingPong(1).id
				table.insert(SceneSlotGame.m_listLeanTweenIDs, id)

			end
			bSoundEnable = bres
			break
		end
	end

	if not bEffectFlag then
		return bSoundEnable
	else
		if nScatterNum == 0 then
			return false
		end
		local bres = self:isScatterUseful(nScatterNum, nReelIndex)
		return bres
	end

	return false
end

function LevelCommonFunctions:isScatterUseful(nSymbols, nReelIndex)
	local bAnimalLevelFlag = SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_LittleAnimals
	local bFortunesOfGoldFlag = SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold
	if bAnimalLevelFlag or bFortunesOfGoldFlag then
		return false
	end

	local bRes = false
	local nReelCount = SlotsGameLua.m_nReelCount
	local nRestReels = nReelCount - (nReelIndex + 1)
	local levelType = SlotsGameLua.m_enumLevelType

	return bRes
end

function LevelCommonFunctions:isPossibleUseful(nSymbols,nReelIndex)
	local bAnimalLevelFlag = SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_LittleAnimals
	local bFortunesOfGoldFlag = SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold
	if bAnimalLevelFlag or bFortunesOfGoldFlag then
		return false
	end

	local bRes = false
	local nReelCount = SlotsGameLua.m_nReelCount
	local nRestReels = nReelCount - (nReelIndex + 1)

	return bRes
end

function LevelCommonFunctions:isNeedPlayScatterEffectInReel(nReelID)
	if SpinButton.m_bUserStopSpin then
		return false
	end

	local enumLevelType = SlotsGameLua.m_enumLevelType
	local bWitchFlag = enumLevelType == enumThemeType.enumLevelType_Witch
	if bWitchFlag then
		if SlotsGameLua.m_GameResult:InReSpin() then
			return false
		end
	end

	local bres = self:isNeedPlayScatterSoundAndEffect(nReelID, true)	
	return bres
end

function LevelCommonFunctions:isSamekindSymbol(SymbolIdx, nResultId)
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ChiliLoco then
		return ChiliLocoFunc:isSamekindSymbol(SymbolIdx, nResultId)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_VesuvianForture then
		return VesuvianFortureFunc:isSamekindSymbol(SymbolIdx, nResultId)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GoldMine then
		return GoldMineFunc:isSamekindSymbol(SymbolIdx, nResultId)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_StoryOfMedusa then
		return StoryOfMedusaFunc:isSamekindSymbol(SymbolIdx, nResultId)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CashRespins then
		return CashRespinsFunc:isSamekindSymbol(SymbolIdx, nResultId)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GoldenEgypt then
		return GoldenEgyptFunc:IsSamekindOfSymbol(SymbolIdx, nResultId)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SnowWhite then
		return SnowWhiteFunc:isSamekindSymbol(SymbolIdx, nResultId)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FuXing then
		return FuXingFunc:isSamekindSymbol(SymbolIdx, nResultId)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_BuffaloGold then
		return BuffaloGoldFunc:isSamekindSymbol(SymbolIdx, nResultId)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_AfricaMania then
		return AfricaManiaFunc:isSamekindSymbol(SymbolIdx, nResultId)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_TigerDragon then
		return TigerDragonFunc:isSamekindSymbol(SymbolIdx, nResultId)
	end
	
    return false
end

-- 非stacked的情况
function LevelCommonFunctions:CheckDeckOneScatterInReel(deck)
	for x=0, SlotsGameLua.m_nReelCount - 1 do
        local bHasScatterFlag = false
        local nReelRow = SlotsGameLua.m_listReelLua[x].m_nReelRow
        for y=0, nReelRow - 1 do
            local RandomValue = -1
            local nkey = SlotsGameLua.m_nRowCount * x + y
            local nID = deck[nkey]
            local type = SlotsGameLua:GetSymbol(nID).type
            if type == SymbolType.Scatter then
                if bHasScatterFlag then
                    while type ~= SymbolType.Normal do
                        nID = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
                        type = SlotsGameLua:GetSymbol(nID).type
                    end

                    deck[nkey] = nID
                else
                    bHasScatterFlag = true
                end
            end
        end
    end
end

function LevelCommonFunctions:SpawnSymbol(nSymbolId, nReelId, nRowIndex)
	local strKey = ThemeLoader.themeKey.."Func"
	if _G[strKey] and _G[strKey].CheckSpawnSymbol then
		return _G[strKey]:CheckSpawnSymbol(nSymbolId, nReelId, nRowIndex)
	end
	return SymbolObjectPool:Spawn(SlotsGameLua:GetSymbol(nSymbolId).prfab)
end

--bResultDeck 为true的情况下 nDeckKey才有意义
function LevelCommonFunctions:SymbolCustomHandler(nReelID, nRowIndex, bResultDeck, nDeckKey)
	-- 带goLight节点的元素
	local reel = SlotsGameLua.m_listReelLua[nReelID]
	local go = reel.m_listGoSymbol[nRowIndex]
	local nSymbolID = reel.m_curSymbolIds[nRowIndex]

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold then
		if nReelID == 2 then
			FortunesOfGoldFunc:ModifyReel2ElemSize(go, nSymbolID)
		end
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MermaidMischief then
		MermaidMischiefFunc:SymbolCustomHandler(go, nSymbolID, bResultDeck, nDeckKey)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MonsterRiches then
		MonsterRichesFunc:SymbolCustomHandler(go, nSymbolID, bResultDeck, nDeckKey)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Smitten then
		SmittenFunc:SymbolCustomHandler(go, nSymbolID, bResultDeck, nDeckKey)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ChiliLoco then
		ChiliLocoFunc:SymbolCustomHandler(go, nSymbolID, bResultDeck, nDeckKey)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GiantTreasure then
		GiantTreasureFunc:SymbolCustomHandler(go)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_RichOfVegas then
		RichOfVegasFunc:SymbolCustomHandler(go, nSymbolID, bResultDeck, nDeckKey)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ColossalDog then
		ColossalDogFunc:SymbolCustomHandler(go, nSymbolID, bResultDeck, nDeckKey)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_DiaDeAmor then
		DiaDeAmorFunc:SymbolCustomHandler(go, nSymbolID, bResultDeck, nDeckKey)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_VesuvianForture then
		VesuvianFortureFunc:SymbolCustomHandler(go, nSymbolID, bResultDeck, nDeckKey)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Alice then
		AliceFunc:SymbolCustomHandler(go, nSymbolID, bResultDeck, nDeckKey)
	else
		local strKey = ThemeLoader.themeKey.."Func"
		if _G[strKey] and _G[strKey].SymbolCustomHandler then
			return _G[strKey]:SymbolCustomHandler(nReelID, nRowIndex, bResultDeck, nDeckKey)
		end
	end

end

function LevelCommonFunctions:TotalBetChange()
	EventHandler:Brocast("OnTotalBetChange")
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Zues then
		ZuesLevelUI.mThunderCircleGame:TotalBetChange()
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_BierMania then
		BierManiaLevelUI.mClassicStarJackPotUI:modifyJackpotValueByTotalBet()
		BierManiaLevelUI.mRapidFireJackPotUI:modifyJackpotValueByTotalBet()
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_OceanRomance then
		OceanRomanceLevelUI.mJackPotUI:modifyJackpotValueByTotalBet()
		OceanRomanceLevelUI:TotalBetChangeReSpinTriggerNeedCount()
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GreatZeus then
		GreatZeusLevelUI.mJackPotUI:modifyJackpotValueByTotalBet()
		GreatZeusLevelUI:TotalBetChangeReSpinTriggerNeedCount()
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_IrishTwo then
		IrishTwoLevelUI.mJackPotUI:modifyJackpotValueByTotalBet()
		IrishTwoLevelUI:OnTotalBetUnLockCollectBonusProgressBar()
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CloverAndBier then
		CloverAndBierLevelUI:OnTotalBetChangedTagBeer()
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MaYa then
		MaYaLevelUI.mJackPotUI:modifyJackpotValueByTotalBet()
		MaYaLevelUI:OnTotalBetUnLockCollectBonusProgressBar()
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_PhoenixOfFire then
		PhoenixOfFireLevelUI:OnTotalBetChanged()
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_LuckyClover then
		LuckyCloverLevelUI.mJackPotUI:modifyJackpotValueByTotalBet()
		LuckyCloverLevelUI:OnTotalBetChanged()
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_AztecAdventure then
		AztecAdventureLevelUI.mJackPotUI:modifyJackpotValueByTotalBet()
		AztecAdventureLevelUI:OnTotalBetChanged()
	else
		local strKey = ThemeLoader.themeKey.."LevelUI"
		if _G[strKey] and _G[strKey].TotalBetChange then
			return _G[strKey]:TotalBetChange()
		end
		
		if _G[strKey] and _G[strKey].mJackPotUI and _G[strKey].mJackPotUI.modifyJackpotValueByTotalBet then
			return _G[strKey].mJackPotUI:modifyJackpotValueByTotalBet()
		end

		if _G[strKey] and _G[strKey].modifyJackpotValueByTotalBet then
			return _G[strKey]:modifyJackpotValueByTotalBet()
		end
	end	

end

function LevelCommonFunctions:addJackPotValue(bSimulationFlag)
	local bFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
	local bReSpinFlag = SlotsGameLua.m_GameResult:InReSpin()

	if bFreeSpinFlag or bReSpinFlag then
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_BierMania then
		BierManiaLevelUI.mClassicStarJackPotUI:addJackPotValue()
		BierManiaLevelUI.mRapidFireJackPotUI:addJackPotValue()
	else
		local strKey = ThemeLoader.themeKey.."LevelUI"
		if _G[strKey] and _G[strKey].mJackPotUI and _G[strKey].mJackPotUI.addJackPotValue then
			return _G[strKey].mJackPotUI:addJackPotValue()
		end

		if _G[strKey] and _G[strKey].addJackPotValue then
			return _G[strKey]:addJackPotValue()
		end
	end
	
end

--改变 某一列的开火 的转动距离
function LevelCommonFunctions:ChangeFireReelRaotateMaxDistance(nWhichReel, fDisCoef)
	fDisCoef = fDisCoef or 2.5
    SlotsGameLua.m_listReelLua[nWhichReel].m_fRotateDistance = SlotsGameLua.m_fRotateDistance * fDisCoef
    -- if not SlotsGameLua.m_bPlayingSlotFireSound then
    --     SlotsGameLua.m_bPlayingSlotFireSound = true
	-- 	AudioHandler:PlaySlotsOnFire()
	-- end
	AudioHandler:PlaySlotsOnFire()
end

-- 某一列要开火了
function LevelCommonFunctions:PlayWait777Effect(nReelID)
    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CollectLucky then
		CollectLuckyLevelUI:PlayWait777Effect(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CollectLuckyTestVideo then
		CollectLuckyLevelUITestVideo:PlayWait777Effect(nReelID)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FireRewind then
		FireReWindLevelUI:PlayWait777Effect(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FireRewindTestVideo then
		FireReWindTestVideoLevelUI:PlayWait777Effect(nReelID)
	end
end

function LevelCommonFunctions:PlaySpecialWait777Effect(nReelID)
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_009_WildLockOneLine then
        --WildLockOneLineLevelUI:PlaySpecialWait777Effect(nReelID)
	end
end

function LevelCommonFunctions:CheckReelEffectStatus(nReelID)
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CollectLucky then
		CollectLuckyLevelUI:StopFireEffect(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CollectLuckyTestVideo then
		CollectLuckyLevelUITestVideo:StopFireEffect(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FireRewind then
		FireReWindLevelUI:StopFireEffect(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FireRewindTestVideo then
		FireReWindTestVideoLevelUI:StopFireEffect(nReelID)
	end
end

function LevelCommonFunctions:PlayWaitFireReelStopEffect(nReelID)
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CollectLucky then
		CollectLuckyLevelUI:PlayWaitFireReelStopEffect(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CollectLuckyTestVideo then
		CollectLuckyLevelUITestVideo:PlayWaitFireReelStopEffect(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FireRewind then
		FireReWindLevelUI:PlayWaitFireReelStopEffect(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FireRewindTestVideo then
		FireReWindTestVideoLevelUI:PlayWaitFireReelStopEffect(nReelID)
	end
end

function LevelCommonFunctions:orWinMoney()
	if SlotsGameLua.m_GameResult.m_fSpinWin > 0 or
		SlotsGameLua.m_GameResult.m_fJackPotBonusWin > 0 or
		SlotsGameLua.m_GameResult.m_fNonLineBonusWin > 0 then
		return true
	else
		return false
	end
end

function LevelCommonFunctions:PlayWinEffect()
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CollectLucky then
		CollectLuckyLevelUI:PlayWinEffect()
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CollectLuckyTestVideo then
		CollectLuckyLevelUITestVideo:PlayWinEffect()
	end
end

    --棋盘元素上的goLight特效
    -- 1. 没中奖就隐藏掉
    -- 2. 中奖了就间隔地显示 隐藏交替
	-- 还应该有个参数。。标记是哪条线。。todo.....
function LevelCommonFunctions:playGoLightEffect(bWinFlag)
    if not bWinFlag then
        for x=0, SlotsGameLua.m_nReelCount-1 do
            local reel = SlotsGameLua.m_listReelLua[x]
            local nTotalNum = reel.m_nReelRow + reel.m_nAddSymbolNums
            for y=0, nTotalNum-1 do
                local go = reel.m_listGoSymbol[y]
                local goLight = SymbolObjectPool.m_mapGoLight[go]
                if goLight ~= nil then
                    goLight:SetActive(false)
                end
            end
        end
    end

    if bWinFlag then
        for x=0, SlotsGameLua.m_nReelCount-1 do
            local reel = SlotsGameLua.m_listReelLua[x]
            local nTotalNum = reel.m_nReelRow + reel.m_nAddSymbolNums
            for y=0, nTotalNum-1 do
                local go = reel.m_listGoSymbol[y]
                local goLight = SymbolObjectPool.m_mapGoLight[go]
                if goLight ~= nil then
                    if y == 1 then
                        self:BlinkGoLightEffect(goLight)
                    else
                        goLight:SetActive(false)
                    end
                end
            end
        end
    end

    -- 移除屏幕外的
    for x=0, SlotsGameLua.m_nReelCount-1 do
        local reel = SlotsGameLua.m_listReelLua[x]
        local nTotalNum = reel.m_nOutSideCount
        for y=1, nTotalNum do
            local go = reel.m_listOutSideSymbols[y]
            local goLight = SymbolObjectPool.m_mapGoLight[go]
            if goLight ~= nil then
                goLight:SetActive(false)
            end
        end
    end

end

function LevelCommonFunctions:BlinkGoLightEffect(goLight)
    if goLight == nil then
        return
    end
    
    local curveItemLight = goLight.transform:GetComponent(typeof(CS.CurveItem))
    if curveItemLight == nil then
        return
    end

	local co = StartCoroutine(function()
        local fDelay = 0.25
		while not SlotsGameLua.m_bInSpin do
            
            local ltd1 = LeanTween.value(0.5, 0.0, fDelay):setOnUpdate(function(value)
                curveItemLight.alpha = value
                curveItemLight.alpha = value
			end)
			table.insert(SceneSlotGame.m_listLeanTweenIDs, ltd1.id)

			ltd1:setOnComplete(function()
				LuaHelper.removeElementFromArray(SceneSlotGame.m_listLeanTweenIDs, ltd1.id)
			end)

            --goLight:SetActive(false)
            yield_return(Unity.WaitForSeconds(fDelay))

            local ltd2 = LeanTween.value(0.0, 0.5, fDelay):setOnUpdate(function(value)
                curveItemLight.alpha = value
                curveItemLight.alpha = value
            end)
			table.insert(SceneSlotGame.m_listLeanTweenIDs, ltd2.id)
			
			ltd2:setOnComplete(function()
				LuaHelper.removeElementFromArray(SceneSlotGame.m_listLeanTweenIDs, ltd2.id)
			end)

            --goLight:SetActive(true)
            yield_return(Unity.WaitForSeconds(fDelay))
		end
	end)

end

function LevelCommonFunctions:HandleWaitEvent()
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Phoenix then
		PhoenixLevelUI:HandleWaitEvent() -- respin结束了 播放动画 结算等 过一会再允许开启下一次自动。。。
		return
	end
	
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MermaidMischief then
		MermaidMischiefLevelUI:HandleWaitEvent()
		return
	end
	
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GoldenEgypt then
		GoldenEgyptLevelUI:HandleWaitEvent()
		return
	end
	
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MonsterRiches then
		MonsterRichesLevelUI:HandleWaitEvent()
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_TarzanBingo then
		TarzanBingoLevelUI:HandlePickBonusGame()
		return
	end
	
	-- 每一关都去自己实现。。
	SceneSlotGame:OnSplashHide(SplashType.Wait)
end

function LevelCommonFunctions:InitCustomWindowInfo()
	-- 这个方法没有存在的必要吧？在自己关卡里什么时候条件满足就什么时候
	-- 把m_bSplashFlags[SplashType.CustomWindow] = true 不就可以了？
	-- todo 需要重构

end

function LevelCommonFunctions:ShowCustomWindow()
	local strKey = ThemeLoader.themeKey.."LevelUI"
	if _G[strKey] and _G[strKey].ShowCustomWindow then
		_G[strKey]:ShowCustomWindow()
		return
	end
end

function LevelCommonFunctions:ShowCustomBigMoneySplash()
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_BierMania then
		BierManiaLevelUI:ShowCustomBigMoneySplash()
		return
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_IrishTwo then
		IrishTwoLevelUI:ShowCustomBigMoneySplash()
		return
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_HappyChristmas then
		HappyChristmasLevelUI:ShowCustomBigMoneySplash()
		return
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CoinFrenzy then
		CoinFrenzyLevelUI:ShowCustomBigMoneySplash()
		return
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Irish then
		IrishLevelUI:ShowCustomBigMoneySplash()
		return
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_LuckyVegas then
		LuckyVegasLevelUI:ShowCustomBigMoneySplash()
		return
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ThreePigs then
		ThreePigsLevelUI:ShowCustomBigMoneySplash()
		return
	end		
end

-- 一些是FreeSpin的关卡，但不显示FreeSpin相关UI
function LevelCommonFunctions:isAllowShowFreeSpinUI()
	local bAllowShowFreeSpinSplashUI = true
    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_007_UntilFull then
		bAllowShowFreeSpinSplashUI = false
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_011_UntilFullWild then
		bAllowShowFreeSpinSplashUI = false
	end
	
	return bAllowShowFreeSpinSplashUI
end

function LevelCommonFunctions:isSymbolNeedShow(posSymbol)
	local bClassicLevel = GameLevelUtil:isClassicLevel()
	if bClassicLevel then
		return true
	end
	
	local posSymbolLeft = posSymbol.x - SlotsGameLua.m_fSymbolWidth/2.0
	local posSymbolRight = posSymbol.x + SlotsGameLua.m_fSymbolWidth/2.0
	local posSymbolTop = posSymbol.y + SlotsGameLua.m_fSymbolHeight/2.0
	local posSymbolBottom = posSymbol.y - SlotsGameLua.m_fSymbolHeight/2.0

    local posBoardLeft = SlotsGameLua.m_fBoardPosLeft
    local posBoardRight = SlotsGameLua.m_fBoardPosRight
    local posBoardTop = SlotsGameLua.m_fBoardPosTop
	local posBoardBottom = SlotsGameLua.m_fBoardPosBottom

	if posSymbolBottom < posBoardTop+580.0 and posSymbolTop > posBoardBottom-80.0 then
		return true
	end
	
	return false
end

-- 这里不仅设置了 中奖符号的 层级，也处理了 Spine 节点Frame0 是否显示
function LevelCommonFunctions:SetWinSymbolWhenShowAndHide(bShow)
	local strKey = ThemeLoader.themeKey.."LevelUI"
	if _G[strKey] and _G[strKey].SetWinSymbolWhenShowAndHide then
		_G[strKey]:SetWinSymbolWhenShowAndHide(bShow)
		return
	end
end

-- 设置 竖屏 自定义 CameraSize
function LevelCommonFunctions:SetPortraitScreenCustomCameraSize(ratio)
	if not GameLevelUtil:isPortraitLevel() then
		return
	end

	local nPortrait1x2CameraSize = Unity.Camera.main.orthographicSize
	local nPortrait3x4CameraSize = Unity.Camera.main.orthographicSize
	if ThemeLoader.themeKey == "FuXing" then
		nPortrait1x2CameraSize = 1170
		nPortrait3x4CameraSize = 1050
	elseif ThemeLoader.themeKey == "RichOfVegas" then
		nPortrait1x2CameraSize = 1170
		nPortrait3x4CameraSize = 860
	elseif ThemeLoader.themeKey == "OceanRomance" then
		nPortrait1x2CameraSize = 1170
		nPortrait3x4CameraSize = 1200
	elseif ThemeLoader.themeKey == "GreatZeus" then
		nPortrait1x2CameraSize = 1170
		nPortrait3x4CameraSize = 930
	elseif ThemeLoader.themeKey == "FireDragon" then
		nPortrait1x2CameraSize = 1170
		nPortrait3x4CameraSize = 1030
	elseif ThemeLoader.themeKey == "CloverAndBier" then
		nPortrait1x2CameraSize = 990
		nPortrait3x4CameraSize = 850
	elseif ThemeLoader.themeKey == "Aladdin" then
		nPortrait1x2CameraSize = 1170
		nPortrait3x4CameraSize = 1000
	elseif ThemeLoader.themeKey == "FortuneFish" then
		nPortrait1x2CameraSize = 1170
		nPortrait3x4CameraSize = 1000
	elseif ThemeLoader.themeKey == "CoinFrenzy" then
		nPortrait1x2CameraSize = 1170
		nPortrait3x4CameraSize = 1090
	elseif ThemeLoader.themeKey == "GrannyWolf" then
		nPortrait1x2CameraSize = 970
		nPortrait3x4CameraSize = 1090
	elseif ThemeLoader.themeKey == "DireWolf" then
		nPortrait1x2CameraSize = 970
		nPortrait3x4CameraSize = 1000
	elseif ThemeLoader.themeKey == "ReelOfDragon" then
		nPortrait1x2CameraSize = 970
		nPortrait3x4CameraSize = 1090
	elseif ThemeLoader.themeKey == "PhoenixOfFire" then
		nPortrait1x2CameraSize = 950
		nPortrait3x4CameraSize = 1150
	elseif ThemeLoader.themeKey == "KangarooRich" then
		nPortrait1x2CameraSize = 950
		nPortrait3x4CameraSize = 1050
	elseif ThemeLoader.themeKey == "FuLink" then
		nPortrait1x2CameraSize = 1170
		nPortrait3x4CameraSize = 1150
	elseif ThemeLoader.themeKey == "ScarabGem" then
		nPortrait1x2CameraSize = 950
		nPortrait3x4CameraSize = 1090
	elseif ThemeLoader.themeKey == "StoryOfMedusa" then
		nPortrait1x2CameraSize = 1170
		nPortrait3x4CameraSize = 1050
	elseif ThemeLoader.themeKey == "LegendOfCleopatra" then
		nPortrait1x2CameraSize = 1200
		nPortrait3x4CameraSize = 1070
	elseif ThemeLoader.themeKey == "FortuneFarm" then
		nPortrait1x2CameraSize = 1100
		nPortrait3x4CameraSize = 1050
	elseif ThemeLoader.themeKey == "Lucky8Spins" then
		nPortrait1x2CameraSize = 1100
		nPortrait3x4CameraSize = 1010
	else
		return
	end	
	
	if GameConst.SCALEPORTRAITLEVEL then
		nPortrait1x2CameraSize = nPortrait1x2CameraSize + 200
	end

	if Unity.Camera.main.rect ~= Unity.Rect(0, 0, 1 ,1) then
		local fCoef = Unity.Camera.main.rect.height
		nPortrait1x2CameraSize = nPortrait1x2CameraSize * fCoef
		nPortrait3x4CameraSize = nPortrait3x4CameraSize * fCoef
	else
		
	end

	local fMaxRatio = 3 / 4
	local fMinRatio = 1125 / 2436

	if ratio <= fMaxRatio and ratio >= fMinRatio then
		local fSize = nPortrait1x2CameraSize + (ratio - fMinRatio) / (fMaxRatio- fMinRatio) * (nPortrait3x4CameraSize - nPortrait1x2CameraSize)
		Unity.Camera.main.orthographicSize = fSize
	elseif ratio + 0.01 >= fMaxRatio then
		Unity.Camera.main.orthographicSize = nPortrait3x4CameraSize
	elseif ratio - 0.01 <= fMinRatio then
		Unity.Camera.main.orthographicSize = nPortrait1x2CameraSize
	end
end	

-- 设置 3D竖屏 自定义 CameraSize
function LevelCommonFunctions:Set3DPortraitScreenCustomCameraSize()
	if not GameLevelUtil:isPortraitLevel() then
		return
	end
	
	local ratio = ScreenHelper:GetScreenWidthHeightRatio(false)

	local nPortrait1x2CameraAngle = 60
	local nPortrait3x4CameraAngle = 60
	if ThemeLoader.themeKey == "CharmWitch" then
		nPortrait1x2CameraAngle = 60
		nPortrait3x4CameraAngle = 52
	elseif ThemeLoader.themeKey == "GoldenVegas" then
		nPortrait1x2CameraAngle = 51
		nPortrait3x4CameraAngle = 48
	else
		return
	end	
	
	if GameConst.SCALEPORTRAITLEVEL then
		nPortrait1x2CameraAngle = nPortrait1x2CameraAngle + 10
	end

	if Unity.Camera.main.rect ~= Unity.Rect(0, 0, 1 ,1) then
		local fCoef = Unity.Camera.main.rect.height
		nPortrait1x2CameraAngle = nPortrait1x2CameraAngle * fCoef
		nPortrait3x4CameraAngle = nPortrait3x4CameraAngle * fCoef
	else
		
    end
	
	local fMaxRatio = 3 / 4
	local fMinRatio = 1125 / 2436

	if ratio <= fMaxRatio and ratio >= fMinRatio then
		local fAngle = nPortrait1x2CameraAngle + (ratio - fMinRatio) / (fMaxRatio - fMinRatio) * (nPortrait3x4CameraAngle - nPortrait1x2CameraAngle)
		Unity.Camera.main.fieldOfView = fAngle
	elseif ratio + 0.01 >= fMaxRatio then
		Unity.Camera.main.fieldOfView = nPortrait3x4CameraAngle
	elseif ratio - 0.01 <= fMinRatio then
		Unity.Camera.main.fieldOfView = nPortrait1x2CameraAngle
	end	

end	

-- 设置 真3D 横屏 自定义 CameraSize
function LevelCommonFunctions:Set3DModelCurvedLevelLandScapeScreenCustomCameraSize()
	if GameLevelUtil:isPortraitLevel() then
		return
	end	
	
	if not GameLevelUtil:is3DModelCurvedLevel() then
		return
	end	

	local ratio = ScreenHelper:GetScreenWidthHeightRatio(true)

	local nPortrait2x1CameraAngle = 30
	local nPortrait4x3CameraAngle = 30
	if ThemeLoader.themeKey == "CrazyDollar" then
		nPortrait2x1CameraAngle = 30
		nPortrait4x3CameraAngle = 33
	else
		return
	end
	
	local f2x1Ratio = 2436 / 1125
	local f4x3Ratio = 4 / 3

	if ratio >= f4x3Ratio and ratio <= f2x1Ratio then
		local fAngle = nPortrait2x1CameraAngle + (ratio - f2x1Ratio) / (f4x3Ratio - f2x1Ratio) * (nPortrait4x3CameraAngle - nPortrait2x1CameraAngle)
		Unity.Camera.main.fieldOfView = fAngle
	elseif ratio <= f4x3Ratio then
		Unity.Camera.main.fieldOfView = nPortrait4x3CameraAngle
	elseif ratio >= f2x1Ratio then
		Unity.Camera.main.fieldOfView = nPortrait2x1CameraAngle
	end	

end

return LevelCommonFunctions
