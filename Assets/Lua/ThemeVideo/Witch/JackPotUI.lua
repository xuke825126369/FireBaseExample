local JackPotUI = {}

function JackPotUI:InitVariable()
	self.m_transform = nil
	self.tableJackPotText = {}
	self.tableJackPotSlotsNumber = {}
	self.tableJackPotAddSumMoneyCount = {0, 0, 0, 0} -- 累积的JackPot 增加值
end

function JackPotUI:ReleaseVariable()
	local tableNeedRemove = {}
    for k, v in pairs(self) do
        if type(v) ~= "function" then
            table.insert(tableNeedRemove, k)
        end
    end
	
    for k, v in pairs(tableNeedRemove) do
        self[v] = nil
    end

    for k, v in pairs(self) do
        if type(v) ~= "function" then
            Debug.Assert(false, "Not Full Clear variable")
        end
    end
end

function JackPotUI:Init()
	self:InitVariable()

	self.m_transform = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelBG")

	self.tableJackPotText = {}
	self.tableJackPotText[1] = self.m_transform:FindDeepChild("JACKPOT/Mini/MiniValue"):GetComponent(typeof(TextMeshPro))
	self.tableJackPotText[2] = self.m_transform:FindDeepChild("JACKPOT/Minor/MinorValue"):GetComponent(typeof(TextMeshPro))
	self.tableJackPotText[3] = self.m_transform:FindDeepChild("JACKPOT/Major/MajorValue"):GetComponent(typeof(TextMeshPro))
	self.tableJackPotText[4] = self.m_transform:FindDeepChild("JACKPOT/Grand/GrandValue"):GetComponent(typeof(TextMeshPro))

	self.goJackPotGrandLock = self.m_transform:FindDeepChild("JACKPOT/Grand/GrandMask").gameObject

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

function JackPotUI:orUnlockGrand()
	if WitchFunc.m_bSimulationFlag then
		return true
	end		
	
	local tableTotalBet = GameLevelUtil:getTotalBetList()
	return SceneSlotGame.m_nTotalBet >= tableTotalBet[#tableTotalBet]
end

function JackPotUI:TotalBetChangeUnLockUI()
	if self:orUnlockGrand() then
		self.goJackPotGrandLock:SetActive(false)
	else
		self.goJackPotGrandLock:SetActive(true)
	end

end

function JackPotUI:modifyJackpotValueByTotalBet()
	for i, v in pairs(self.tableJackPotAddSumMoneyCount) do
		local fValue = self:GetTotalJackPotValue(i)
		if self.tableJackPotSlotsNumber[i] then
			self.tableJackPotSlotsNumber[i]:End(fValue)
		end
	end

	self:TotalBetChangeUnLockUI()
end		

function JackPotUI:addJackPotValue()
	local rt = SlotsGameLua.m_GameResult
    if WitchFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bReSpinFlag = rt:InReSpin()
    local bFreeSpinFlag = rt:InFreeSpin()
	if bReSpinFlag or bFreeSpinFlag then
		return
	end
	
	local nTotalBet = SceneSlotGame.m_nTotalBet

	local nJackPotCount = #WitchConfig.TABLE_JACKPOT_ADDCOEF
	for i = 1, nJackPotCount do
		if i == 4 then
			if self:orUnlockGrand() then
				self.tableJackPotAddSumMoneyCount[i] = self.tableJackPotAddSumMoneyCount[i] + nTotalBet * WitchConfig.TABLE_JACKPOT_ADDCOEF[i]
			end
		else
			self.tableJackPotAddSumMoneyCount[i] = self.tableJackPotAddSumMoneyCount[i] + nTotalBet * WitchConfig.TABLE_JACKPOT_ADDCOEF[i]
		end
	end

	if not WitchFunc.m_bSimulationFlag then
		for i = 1, nJackPotCount do
			local fValue = self:GetTotalJackPotValue(i)
			self.tableJackPotSlotsNumber[i]:ChangeTo(fValue)
		end
		self:setDBJackPotValue(self.tableJackPotAddSumMoneyCount)
    end

end

function JackPotUI:GetTotalJackPotValue(i)
	return SceneSlotGame.m_nTotalBet * WitchConfig.TABLE_JACKPOT_MIN_MULTUILE[i] + self.tableJackPotAddSumMoneyCount[i]
end

function JackPotUI:ResetCurrentJackPot(nPos)
	self.tableJackPotAddSumMoneyCount[nPos] = 0
	if not WitchFunc.m_bSimulationFlag then
		self:setDBJackPotValue(self.tableJackPotAddSumMoneyCount)
	end

end

function JackPotUI:InitDataBaseValue()
	self.tableJackPotAddSumMoneyCount = self:getDBJackPotValue()
end

--==================================== 数据库 ======================================
function JackPotUI:setDBJackPotValue(value)
	LevelDataHandler.m_Data.mThemeData.tableJackPotAddSumMoneyCount = value
	LevelDataHandler:persistentData()
end 

function JackPotUI:getDBJackPotValue()
	if LevelDataHandler.m_Data.mThemeData.tableJackPotAddSumMoneyCount == nil then
		return {0, 0, 0, 0}
	end
	
	return LevelDataHandler.m_Data.mThemeData.tableJackPotAddSumMoneyCount
end


return JackPotUI