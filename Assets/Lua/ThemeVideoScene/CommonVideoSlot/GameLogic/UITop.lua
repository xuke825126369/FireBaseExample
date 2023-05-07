local UITop = {}

function UITop:Init()
    self.m_transform = ThemeVideoScene.mTopBottomUIParent:FindDeepChild("UITop")
	LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

	self.goCollectMoneyEndPos = self.m_transform:FindDeepChild("GOLD/Image/goCollectMoneyEndPos").gameObject
	GlobalTempData.goUITopCollectMoneyEndPos = self.goCollectMoneyEndPos
	
    self.m_btnLobby = self.m_transform:FindDeepChild("LobbyButton"):GetComponent(typeof(UnityUI.Button))
	self.m_btnLobby.onClick:AddListener(function()
		AudioHandler:PlayBtnSound()
        ThemeLoader:ReturnToLobby()
	end)	

	self.m_BuyBtn = self.m_transform:FindDeepChild("BuyBtn"):GetComponent(typeof(UnityUI.Button))
	self.m_BuyBtn.onClick:AddListener(function()
		AudioHandler:PlayBtnSound()
        BuyView:Show()
	end)

	self.mclickBuyBtn = self.m_transform:FindDeepChild("GOLD/clickBtn"):GetComponent(typeof(UnityUI.Button))
	self.mclickBuyBtn.onClick:AddListener(function()
		AudioHandler:PlayBtnSound()
        BuyView:Show()
	end)

	self.mMenuBtn = self.m_transform:FindDeepChild("Menu"):GetComponent(typeof(UnityUI.Button))
	self.mMenuBtn.onClick:AddListener(function()
		AudioHandler:PlayBtnSound()
        ThemeMenuPopView:Show()
	end)
	
	self.goldText = self.m_transform:FindDeepChild("UITopCoinCountText"):GetComponent(typeof(TextMeshProUGUI))
	self.goldTextNumberAddAni = NumberAddLuaAni:New(self.goldText)

	self.textLevel = self.m_transform:FindDeepChild("nLevel"):GetComponent(typeof(TextMeshProUGUI))
	self.mLevelProgressbar = self.m_transform:FindDeepChild("LevelProgress"):GetComponent(typeof(UnityUI.Image))
	self.mLevelProgressbarText = self.m_transform:FindDeepChild("LevelProgressText"):GetComponent(typeof(TextMeshProUGUI))

	self.goStoreBonusGiftBox = self.m_transform:FindDeepChild("BuyBtn/GiftBox").gameObject
	self.goStoreBonusGiftBox:SetActive(false)
	self.mTimeOutGenerator = TimeOutGenerator:New()

	local levelUpPopTransform = self.m_transform:FindDeepChild("LevelUpPop")
	self.levelUpPopRectTransform = levelUpPopTransform:GetComponent(typeof(Unity.RectTransform))
	self.levelUpCoinImage = levelUpPopTransform:FindDeepChild("CoinImage"):GetComponent(typeof(UnityUI.Image))
	self.levelUpBonusText = levelUpPopTransform:FindDeepChild("LevelUpBonus"):GetComponent(typeof(TextMeshProUGUI))
	self.levelUpVipImage = levelUpPopTransform:FindDeepChild("LevelUpVipImage"):GetComponent(typeof(UnityUI.Image))
	self.levelUpVipPointText = levelUpPopTransform:FindDeepChild("LevelUpVipPoint"):GetComponent(typeof(TextMeshProUGUI))
	self.levelUpPopPoistion = self.levelUpPopRectTransform.anchoredPosition
	levelUpPopTransform.gameObject:SetActive(false)
	self.nCurrentLevel = PlayerHandler.nLevel

	self:InitTopUICoin()
	self:InitUserLevel()
			
	EventHandler:AddListener("UpdateMyInfo", self)
	MissionLevelEntry:Show()
	if LoungeHandler:isLoungeMember() then -- 包间状态开启
		BoosterEntry:Show()
	end
	LoungeBetSizeChangeBar:Init()
	ActiveThemeEntry:Show()
    LoungeSpecialLevelBoosterUI:Show()
	ThemeAdsEntry:Show()
end	

function UITop:OnDestroy()
	EventHandler:RemoveListener("UpdateMyInfo", self)
end

function UITop:Update()
	if self.mTimeOutGenerator:orTimeOut() then
		self:OnStoreBonusChanged()
	end
end

function UITop:OnStoreBonusChanged()
	self.goStoreBonusGiftBox:SetActive(CommonDbHandler:orCanGetStoreBonus())
end

function UITop:InitTopUICoin()
	self.goldTextNumberAddAni:End(PlayerHandler.nGoldCount)
end

function UITop:InitUserLevel()
	self.textLevel.text = "Lv."..PlayerHandler.nLevel
	
	local nSumExp = FormulaHelper:GetSumLevelExp(PlayerHandler.nLevel)
	local fPercent = PlayerHandler.nLevelExp / nSumExp
	fPercent = math.min(fPercent, 1)
	local fPercent1 = math.floor(fPercent * 100)
	fPercent1 = math.min(fPercent1, 100)
	self.mLevelProgressbarText.text = fPercent1.."%"

	local oriSize = self.mLevelProgressbar.rectTransform.sizeDelta
	local nTargetSizeX = 430 * fPercent
	self.mLevelProgressbar.rectTransform.sizeDelta = Unity.Vector2(nTargetSizeX, oriSize.y)

end

function UITop:updateCoinCountInUi(fTime)
	if fTime == nil then
		fTime = 2.0
	end

	self.goldTextNumberAddAni:ChangeTo(PlayerHandler.nGoldCount, fTime)
end

function UITop:UpdateMyInfo()
	self:updateCoinCountInUi()
	self:refreshUserLevel()
end

function UITop:refreshUserLevel()
	self.textLevel.text = "Lv."..PlayerHandler.nLevel

	local nSumExp = FormulaHelper:GetSumLevelExp(PlayerHandler.nLevel)
	local fPercent = PlayerHandler.nLevelExp / nSumExp
	fPercent = math.min(fPercent, 1)
	local fPercent1 = math.floor(fPercent * 100)
	fPercent1 = math.min(fPercent1, 100)
	self.mLevelProgressbarText.text = fPercent1.."%"

	local oriSize = self.mLevelProgressbar.rectTransform.sizeDelta
	local nTargetSizeX = 430 * fPercent	
	LeanTween.value(oriSize.x, nTargetSizeX, 0.6):setOnUpdate(function(value)
		local fSizeX = value
		self.mLevelProgressbar.rectTransform.sizeDelta = Unity.Vector2(fSizeX, oriSize.y)
	end)

	if self.nCurrentLevel ~= PlayerHandler.nLevel then
		self.nCurrentLevel = PlayerHandler.nLevel
		AppLocalEventHandler:OnLevelUp()
		self:PlayLevelUpAni()
	end

end

function UITop:PlayLevelUpAni()
	AudioHandler:playLevelUp()
	local levelUpBonus = FormulaHelper:GetAddMoneyCountByLevelUp()
	levelUpBonus = levelUpBonus * VipHandler:GetVipCoefInfo()
	local levelUpVipPoints = FormulaHelper:GetAddVipPointByLevelUp()
	PlayerHandler:AddCoin(levelUpBonus)
	PlayerHandler:AddVipPoint(levelUpVipPoints)

	self.levelUpVipPointText.text = string.format( "%d", levelUpVipPoints)
	self.levelUpBonusText.text = string.format( "$%s", MoneyFormatHelper.numWithCommas(levelUpBonus))
	VipHandler:SetVipImage(self.levelUpVipImage)
	
	self.levelUpPopRectTransform.gameObject:SetActive(true)
	local oriPosY = 170
	local targetPosY = -180
	local oriPos = self.levelUpPopRectTransform.localPosition
	self.levelUpPopRectTransform.localPosition = Unity.Vector3(oriPos.x, oriPosY, 0)
	LeanTween.moveLocalY(self.levelUpPopRectTransform.gameObject, targetPosY, 0.5):setEase(LeanTweenType.easeOutBack)
	LeanTween.delayedCall(2, function()
		CoinFly:fly(self.levelUpCoinImage.transform.position, self.goCollectMoneyEndPos.transform.position, 16)
	end)
	LeanTween.delayedCall(5, function()
		LeanTween.moveLocalY(self.levelUpPopRectTransform.gameObject, oriPosY, 0.5)
	end)	
	
	SceneSlotGame:CheckMaxBetBtnStatus()
end

return UITop