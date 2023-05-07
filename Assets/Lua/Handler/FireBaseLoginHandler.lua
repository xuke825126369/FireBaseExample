FireBaseLoginHandler = {}

-- 初始化登录，尽可能让玩家进入游戏，无论是否联网
function FireBaseLoginHandler:Init()
	self.finishLoginEvent = nil
end

function FireBaseLoginHandler:CheckOrExistAccount()
	if not PlayerHandler:orExistAccount() then
		local customId = Unity.SystemInfo.deviceUniqueIdentifier
		PlayerHandler:SetAccountInfo(customId)
	end
end

-- 开发模式编辑器登录
function FireBaseLoginHandler:LoginWithPCEditor(func)
	self.finishLoginEvent = func
	self:CheckOrExistAccount()
	PlayerHandler:SetUserId(PlayerHandler.UniqueIdentifier)
	TimeHandler:SetServerTimeStamp(TimeHandler:GetTimeStamp())
	self:FinishLogin(func)
end

-- 游客登录
function FireBaseLoginHandler:LoginWithGuest(func)
	self.finishLoginEvent = func
	self:CheckOrExistAccount()
	
	CS.FireBaseLogin.Instance:LoginAccountWithAnonymously(function(FirebaseUser)
		if FirebaseUser ~= nil then
			local nUserId = FirebaseUser.UserId
			PlayerHandler:SetUserId(nUserId)
			self:RequestUserData()
		else
			self:ShowErrorTip(function()
				self:LoginWithGuest(func)
			end)
		end
	end)

end

-- Google登录
function FireBaseLoginHandler:LoginWithGoogle(func)
	self.finishLoginEvent = func
	self:CheckOrExistAccount()

	CS.FireBaseLogin.Instance:LoginAccountWithGoogle(function(FirebaseUser)
		if FirebaseUser ~= nil then
			local nUserId = FirebaseUser.UserId
			PlayerHandler:SetUserId(nUserId)
			self:RequestUserData()
		else
			self:ShowErrorTip(function()
				self:LoginWithGoogle(func)
			end)
		end
	end)

end

-- 拉取服务器的数据，与客户端数据对比
function FireBaseLoginHandler:RequestUserData()
	local bInRequest = true
	CS.FireBaseDb.Instance:GetUserData(PlayerHandler.nUserId, 
	function(result)
		if bInRequest then
			bInRequest = false

			local jsonNetData = result
			local netData = nil
			if jsonNetData then
				netData = rapidjson.decode(jsonNetData)
			end

			if netData ~= nil then
				PlayerHandler:SyncNetData(netData.mPlayerHandlerData)
				GMGiftHandler:SyncNetData(netData.mGMGiftHandlerData)
			end

			self:SendUserDataToServer()
			self:RequestServerTime()
		end
	end, 
	function(result)
		if bInRequest then
			bInRequest = false
			
			self:ShowErrorTip(function()
				self:RequestUserData()
			end)
		end
	end)

	LeanTween.delayedCall(6.0, function()
		if bInRequest then
			bInRequest = false

			self:ShowErrorTip(function()
				self:RequestUserData()
			end)
		end
	end)

end

function FireBaseLoginHandler:RequestServerTime()
	CS.FireBaseDb.Instance:getServerTime(function(nTimeStamp)
        TimeHandler:SetServerTimeStamp(nTimeStamp)
		self:FinishLogin()
    end,
    function()
		self:ShowErrorTip(function()
			self:RequestServerTime()
		end)
    end)
end

-- 向服务器发送最新数据
function FireBaseLoginHandler:SendUserDataToServer()
	local data = rapidjson.encode(UserInfoHandler.data)
	CS.FireBaseDb.Instance:UpdateUserData(PlayerHandler.nUserId, data)
end

function FireBaseLoginHandler:ShowErrorTip(tryFunc)
	CommonDialogBox:ShowSureUI("Connection failure!", nil, function()
		tryFunc()
	end)
end

function FireBaseLoginHandler:FinishLogin()
    if self.finishLoginEvent then
		self.finishLoginEvent()
	end	
	self.finishLoginEvent = nil
end

return FireBaseLoginHandler
