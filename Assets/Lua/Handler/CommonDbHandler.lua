CommonDbHandler = {}

local CouponInfo = {nCouponTime = 0, fCouponRatio = 0.0}

function CommonDbHandler:Init()
    self.data = PlayerHandler.data.mCommonDbHandlerData
    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
	LuaHelper.FixSimpleDbError(self.data.storeBonusData, self:GetDbInitData().storeBonusData)
	LuaHelper.FixSimpleDbError(self.data.CashBackParam, self:GetDbInitData().CashBackParam)
    self:SaveDb()
end

function CommonDbHandler:SaveDb()
    PlayerHandler.data.mCommonDbHandlerData = self.data
    PlayerHandler:SaveDb()
end

function CommonDbHandler:GetDbInitData()
    local data = {}
	data.nInboxId = 0

	data.nLastLuckyPackNetDaySecond = 0
    data.LoungeLuckyPackParam = {} -- {netTimeSecond = netTimeSecond, nCount = 1}
    data.FlashBoosterEndTime = 0
    data.MissionStarBoosterEndTime = 0

    data.tableCoinCouponInfo = {} -- 商店打折
    data.tableDiamondCouponInfo = {}
    data.StoreCoinCouponInfo = {nCouponEndTime = 0, fCouponRatio = 0.0} -- 商店打折
    data.StoreDiamondCouponInfo = {nCouponEndTime = 0, fCouponRatio = 0.0}

	data.nLastSendFreeCoinsTimeStamp = 0
    data.tableCollectFreeCoinInfo = {}

    data.mapInboxTrophyRewardParams = {}
    data.mapInboxRoyalPassRewardParams = {}
    data.mapInboxFlashChallengeRewardParams = {}
	data.BonusParams = {}
	data.SpinMultiplierParam = {daySecond = 0, fExp = 0}

	data.CashBackParam = {nBonus = 0, nRewardTime = 0, boosters = {} }
    data.LevelBurstParam = {fCoef = 0, nEndTime = 0} --经验值加倍
	data.RepeatWinParam = {nType = 1, nBonus = 0, nRewardTime = 0, nEndTime = 0, nMaxCoins = 0}
	data.BoostWinParam = { nBonus = 0, nRewardTime = 0, nMaxCoins = 0, boosters = {} }

	data.storeBonusData = {nNextCollectBonusTime = 0, m_nShopBonus = 0}
    return data
end

-- 设置信箱金币打折信息
function CommonDbHandler:AddInboxCoinCouponInfo(nAddTime, fRatio)
	local CouponInfo = {}
	CouponInfo.nInboxId = InBoxHandler:GetInboxId()
	CouponInfo.nCouponTime = nAddTime
	CouponInfo.fCouponRatio = fRatio
	table.insert(self.data.tableCoinCouponInfo, CouponInfo)
	setmetatable(self.data.tableCoinCouponInfo, {__jsontype = "array"})
    self:SaveDb()
end

-- 设置信箱钻石打折信息
function CommonDbHandler:AddInboxDiamondCouponInfo(nAddTime, fRatio)
	local CouponInfo = {}
	CouponInfo.nInboxId = InBoxHandler:GetInboxId()
	CouponInfo.nCouponTime = nAddTime
	CouponInfo.fCouponRatio = fRatio
	table.insert(self.data.tableDiamondCouponInfo, CouponInfo)
	setmetatable(self.data.tableDiamondCouponInfo, {__jsontype = "array"})
    self:SaveDb()
end

-- 设置商店金币打折信息
function CommonDbHandler:SetStoreCoinCouponInfo(nAddTime, fRatio)
	if self:checkHasCoinCouponFormShop() and fRatio < self.data.StoreCoinCouponInfo.fCouponRatio then
		return
	end
	
	self.data.StoreCoinCouponInfo.fCouponRatio = fRatio
    self.data.StoreCoinCouponInfo.nCouponEndTime = TimeHandler:GetServerTimeStamp() + nAddTime
    self:SaveDb()
end

-- 设置商店ß钻石打折信息
function CommonDbHandler:SetStoreDiamondCouponInfo(nAddTime, fRatio)
	if self:checkHasDiamondCouponFormShop() and fRatio < self.data.StoreDiamondCouponInfo.fCouponRatio then
		return
	end
	
	self.data.StoreDiamondCouponInfo.fCouponRatio = fRatio
    self.data.StoreDiamondCouponInfo.nCouponEndTime = TimeHandler:GetServerTimeStamp() + nAddTime
    self:SaveDb()
end

-- 获取 Royal Pass Star 数量提升
function CommonDbHandler:setMissionStarBooster(nAddTime)
    self.data.MissionStarBoosterEndTime = TimeHandler:GetServerTimeStamp() + nAddTime
    self:SaveDb()
end

-- Flash Booster, double Flash points, 变量是时长
function CommonDbHandler:setFlashBooster(nAddTime)
    self.data.FlashBoosterEndTime = TimeHandler:GetServerTimeStamp() + nAddTime
    self:SaveDb()
end

function CommonDbHandler:AddCollectFreeCoins()
	self.data.nLastSendFreeCoinsTimeStamp = TimeHandler:GetServerTimeStamp()
    table.insert(self.data.tableCollectFreeCoinInfo, {nInboxId = InBoxHandler:GetInboxId()})
	setmetatable(self.data.tableCollectFreeCoinInfo, {__jsontype = "array"})
	self:SaveDb()
end

function CommonDbHandler:AddLoungeLuckyPack()
	local nDayBeginTime = TimeHandler:GetDayBeginTimeStamp()
	self.data.nLastLuckyPackNetDaySecond = nDayBeginTime
    table.insert(self.data.LoungeLuckyPackParam, {nInboxId = InBoxHandler:GetInboxId()})
	setmetatable(self.data.LoungeLuckyPackParam, {__jsontype = "array"})
	self:SaveDb()
end

--------------------------------------------------------------------------------
function CommonDbHandler:checkHasCoinCouponFormShop()
	local bHasCoinCoupon = os.time() < self.data.StoreCoinCouponInfo.nCouponEndTime
	return bHasCoinCoupon, self.data.StoreCoinCouponInfo.fCouponRatio
end

function CommonDbHandler:checkHasDiamondCouponFormShop()
	local bHasDiamondCoupon = os.time() < self.data.StoreDiamondCouponInfo.nCouponEndTime
	return bHasDiamondCoupon, self.data.StoreDiamondCouponInfo.fCouponRatio
end

function CommonDbHandler:AddRoyalTrophyRewardsToInbox(mapInboxPrizeParams)
	for i = 1, LuaHelper.tableSize(mapInboxPrizeParams) do
		table.insert(self.data.mapInboxTrophyRewardParams, mapInboxPrizeParams[i])
	end
	setmetatable(self.data.mapInboxTrophyRewardParams, {__jsontype = "array"})
	self:SaveDb()
end

function CommonDbHandler:AddRoyalPassRewardToInbox(mapInboxPrizeParams)
	for i = 1, LuaHelper.tableSize(mapInboxPrizeParams) do
		table.insert(self.data.mapInboxRoyalPassRewardParams, mapInboxPrizeParams[i])
	end

	setmetatable(self.data.mapInboxRoyalPassRewardParams, {__jsontype = "array"})
	self:SaveDb()
end

function CommonDbHandler:removeRoyalPassReward(nIndex)
	table.remove(self.data.mapInboxRoyalPassRewardParams, nIndex)
	self:SaveDb()
	EventHandler:Brocast("onInboxMessageChangedNotifycation")
end

function CommonDbHandler:orCanGetStoreBonus()
	local currentTime = TimeHandler:GetServerTimeStamp()
    local endTime = CommonDbHandler.data.storeBonusData.nNextCollectBonusTime
    local timediff = endTime - currentTime
    return timediff <= 0
end

function CommonDbHandler:orInMissionStarBoosterTime()
	return CommonDbHandler.data.MissionStarBoosterEndTime > TimeHandler:GetServerTimeStamp()
end
