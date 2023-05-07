require("Lua/LobbyScene/Login/DailyLoginHelper")

local InitLoginLoadingView = {}

function InitLoginLoadingView:Init()
	if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

	local bundleName = "Lobby"
	local assetPath = "Assets/ResourceABs/Lobby/View/InitLoginLoadingView.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local goPanel = Unity.Object.Instantiate(goPrefab)
	
    local goParent = GlobalScene.popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
	self.transform.gameObject:SetActive(false)
end

function InitLoginLoadingView:Show()
	self:Init()
	self.transform.gameObject:SetActive(true)
	
	StartCoroutine(function()
		while not CS.FireBaseInit.Instance:orInitFinish() do
            yield_return(0)
        end

		self:RequestLogin()
	end)

end

function InitLoginLoadingView:Hide()
	Unity.Object.Destroy(self.transform.gameObject)
end

function InitLoginLoadingView:RequestLogin()
	if GameConfig.PLATFORM_EDITOR then
		FireBaseLoginHandler:LoginWithPCEditor(function()
			self:OnLoginFinishEvent()
		end)
	else
		FireBaseLoginHandler:LoginWithGoogle(function()
			self:OnLoginFinishEvent()
		end)
	end
end

function InitLoginLoadingView:OnLoginFinishEvent()
	CommonDbHandler:Init()
    DailyBonusDataHandler:Init()
    FreeBonusGameHandler:Init()
    LoungeHandler:Init()
	
    DailyMissionHandler:Init()
    FlashChallengeHandler:Init()
    LuckyEggHandler:Init()
    RoyalPassHandler:Init()
    BuyHandler:Init()
    RechargeHandler:Init()

    FlashSaleHandler:Init()
    BoostHandler:Init()
    Debug.LogWithColor("数据网络同步成功")

	UnityPurchasingHandler:Init()
    GoogleAdsHandler:Init()

	-----------------------------------------------------------------------------------------------------
	if TimeHandler:GetServerTimeStamp() - PlayerHandler.nLastLoginTimeStamp >= 30 * 24 * 60 * 60 then
		GlobalTempData.bShowWelcomeBonusView = true
	end
	PlayerHandler:SetLastLoginTime()

	DailyLoginHelper:RecordChuQin()
	PlayerHandler:SetFirstLoginTime()
	PlayerHandler:AddLoginCount()
	PlayerHandler:AddTodayLoginCount()
	FlashSaleHandler:InitFlashSales()

	EventHandler:Brocast("UpdateMyInfo")
	LobbyScene:SetInitLoginFinish()
end

return InitLoginLoadingView















