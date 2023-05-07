GMGiftHandler = {}

function GMGiftHandler:Init()
    self.data = UserInfoHandler.data.mGMGiftHandlerData
    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
end

function GMGiftHandler:SaveDb()
	UserInfoHandler.data.mGMGiftHandlerData = self.data
    UserInfoHandler:SaveDb()
end

function GMGiftHandler:GetDbInitData()
    local data = {}
	data.nVersion = 0
    data.nCompensationCoins = 0
    return data
end

function GMGiftHandler:SyncNetData(netData)
	if netData and netData.nVersion > self.data.nVersion then
		self.data.nVersion = netData.nVersion
		self.data.nCompensationCoins = self.data.nCompensationCoins + netData.nCompensationCoins
	end
	self:SaveDb()
end

function GMGiftHandler:CollectGMGift(nCoins)
	self.data.nCompensationCoins = self.data.nCompensationCoins - nCoins
	PlayerHandler:AddCoin(nCoins)
	self:SaveDb()
end
