local JackPotUI = {}

function JackPotUI:InitVariable()
	self.m_transform = nil
	self.tableJackPotText = {}
	self.tableJackPotSlotsNumber = {}
	self.tableJackPotAddSumMoneyCount = {0, 0, 0} -- 累积的JackPot 增加值
end

function JackPotUI:Init()
	self:InitVariable()

	self.m_transform = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelBG")

	self.tableJackPotText = {}
	self.tableJackPotText[1] = self.m_transform:FindDeepChild("ArabBonusGameValue/MinorValue/TextValueMinor"):GetComponent(typeof(TextMeshPro))
	self.tableJackPotText[2] = self.m_transform:FindDeepChild("ArabBonusGameValue/MajorValue/TextValueMajor"):GetComponent(typeof(TextMeshPro))
	self.tableJackPotText[3] = self.m_transform:FindDeepChild("ArabBonusGameValue/GrandValue/TextValueGrand"):GetComponent(typeof(TextMeshPro))

	self:InitJackportParam()
end

function JackPotUI:Update()
	self:updateSlotsNumber()
end

function JackPotUI:updateSlotsNumber()
	for k,v in pairs(self.tableJackPotSlotsNumber) do
		v:Update()
	end
end

--Init jackport params
function JackPotUI:InitJackportParam()
    self:InitDataBaseValue()

	for k, v in pairs(self.tableJackPotText) do
		local m_SlotsNumber = SlotsNumber:create("", 0, 1000000000000000, 0, 0.01)
		m_SlotsNumber:AddUIText(v)
		self.tableJackPotSlotsNumber[k] = m_SlotsNumber
	end			

	self:modifyJackpotValueByTotalBet()
end

function JackPotUI:modifyJackpotValueByTotalBet()
	for i, v in pairs(self.tableJackPotAddSumMoneyCount) do
		local fValue = self:GetTotalJackPotValue(i)
		if self.tableJackPotSlotsNumber[i] then
			self.tableJackPotSlotsNumber[i]:End(fValue)
		end
	end
end		

function JackPotUI:addJackPotValue()
	local rt = SlotsGameLua.m_GameResult
    if ArabFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bReSpinFlag = rt:InReSpin()
    local bFreeSpinFlag = rt:InFreeSpin()
	if bReSpinFlag or bFreeSpinFlag then
		return
	end

	local nTotalBet = SceneSlotGame.m_nTotalBet
	local nJackPotCount = #ArabConfig.TABLE_JACKPOT_ADDCOEF
	for i = 1, nJackPotCount do
		self.tableJackPotAddSumMoneyCount[i] = self.tableJackPotAddSumMoneyCount[i] + nTotalBet * ArabConfig.TABLE_JACKPOT_ADDCOEF[i]
	end

	if not ArabFunc.m_bSimulationFlag then
		for i = 1, nJackPotCount do
			local fValue = self:GetTotalJackPotValue(i)
			self.tableJackPotSlotsNumber[i]:ChangeTo(fValue)
		end
		self:setDBJackPotValue(self.tableJackPotAddSumMoneyCount)
    end	

end

function JackPotUI:GetTotalJackPotValue(i)
	return SceneSlotGame.m_nTotalBet * ArabConfig.TABLE_JACKPOT_MIN_MULTUILE[i] + self.tableJackPotAddSumMoneyCount[i]
end

function JackPotUI:ResetCurrentJackPot(nPos)
	self.tableJackPotAddSumMoneyCount[nPos] = 0
	if not ArabFunc.m_bSimulationFlag then
		self:setDBJackPotValue(self.tableJackPotAddSumMoneyCount)
	end
end

function JackPotUI:InitDataBaseValue()
	self.tableJackPotAddSumMoneyCount = self:getDBJackPotValue()
end

--==================================== 数据库 ======================================
function JackPotUI:setDBJackPotValue(value)
    local strLevelName = ThemeLoader.themeKey
	LevelDataHandler.m_Data.mThemeData.tableJackPotAddSumMoneyCount = value
	LevelDataHandler:persistentData()
end 

function JackPotUI:getDBJackPotValue()
	if LevelDataHandler.m_Data.mThemeData.tableJackPotAddSumMoneyCount == nil then
		return {0, 0, 0}
	end
	
	return LevelDataHandler.m_Data.mThemeData.tableJackPotAddSumMoneyCount
end


return JackPotUI