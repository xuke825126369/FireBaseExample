LobbyView = {}

function LobbyView:Init()
	if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

	local bundleName = "Lobby"
	local assetPath = "Assets/ResourceABs/Lobby/View/LobbyPanel.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local goPanel = Unity.Object.Instantiate(goPrefab)

    local goParent = LobbyScene.transform
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
	self.transform.gameObject:SetActive(false)
	
	self.goldText = self.transform:FindDeepChild("UITopCoinCountText"):GetComponent(typeof(TextMeshProUGUI))
	self.goldTextNumberAddAni = NumberAddLuaAni:New(self.goldText)
	self.goCollectMoneyEndPos = self.transform:FindDeepChild("goCollectMoneyEndPos").gameObject

	self.mMenuBtn = self.transform:FindDeepChild("MenuBtn"):GetComponent(typeof(UnityUI.Button))
	self.mBuyBtn = self.transform:FindDeepChild("BuyBtn"):GetComponent(typeof(UnityUI.Button))
	self.mVipBtn = self.transform:FindDeepChild("VipBtn"):GetComponent(typeof(UnityUI.Button))
	self.mCoinsBtn = self.transform:FindDeepChild("GOLD/clickBtn"):GetComponent(typeof(UnityUI.Button))

	self.mInBoxBtn = self.transform:FindDeepChild("InboxBtn"):GetComponent(typeof(UnityUI.Button))	
	self.mFreeCoinsBtn = self.transform:FindDeepChild("FreeCoinsBtn"):GetComponent(typeof(UnityUI.Button))
	self.mSlotsCardsBtn = self.transform:FindDeepChild("BottomSlotsCards"):GetComponentInChildren(typeof(UnityUI.Button))

	self.goInBoxMessageTip = self.transform:FindDeepChild("InboxBtn/BottomInboxMessageCount").gameObject
	self.goInBoxMessageTip:SetActive(false)
	self.textInboxCountText = self.transform:FindDeepChild("InboxBtn/BottomInboxMessageCount/InboxCountText"):GetComponent(typeof(TextMeshProUGUI))

	self.goThemeScrollRect = self.transform:FindDeepChild("ThemeScrollRect").gameObject
	self.goThemeItemParent = self.transform:FindDeepChild("ThemeScrollRect/ScrollView/Viewport/Content")

	self.textLevel = self.transform:FindDeepChild("nLevel"):GetComponent(typeof(TextMeshProUGUI))
	self.mLevelProgressbar = self.transform:FindDeepChild("LevelProgress"):GetComponent(typeof(UnityUI.Image))
	self.mLevelProgressbarText = self.transform:FindDeepChild("LevelProgressText"):GetComponent(typeof(TextMeshProUGUI))
	self.mCoinsCanvas = self.transform:FindDeepChild("GOLD"):GetComponent(typeof(Unity.Canvas))

	self.goStoreBonusGiftBox = self.transform:FindDeepChild("BuyBtn/GiftBox").gameObject
	self.goStoreBonusGiftBox:SetActive(false)

	self.goThemeList = self.transform:FindDeepChild("ThemeList").gameObject
	self.goFalashSalesShopEntry = self.transform:FindDeepChild("FalashSalesShopEntry").gameObject
	self.mFlashSaleBtn = self.transform:FindDeepChild("FalashSalesShopEntry"):GetComponentInChildren(typeof(UnityUI.Button))

	self.mFlashSaleBtn.onClick:AddListener(function()
		GlobalAudioHandler:PlayBtnSound()
		FlashSaleHandler:Show()
	end)

	self.mVipBtn.onClick:AddListener(function()
		GlobalAudioHandler:PlayBtnSound()
		VipInfoPop:Show()
	end)

    self.mMenuBtn.onClick:AddListener(function()
		GlobalAudioHandler:PlayBtnSound()
		MenuPop:Show()
    end)

	self.mCoinsBtn.onClick:AddListener(function()
		GlobalAudioHandler:PlayBtnSound()
		BuyView:Show()
	end)

	self.mBuyBtn.onClick:AddListener(function()
		GlobalAudioHandler:PlayBtnSound()
		BuyView:Show()
	end)

	self.mInBoxBtn.onClick:AddListener(function()
		GlobalAudioHandler:PlayBtnSound()
        InboxPop:Show()
	end)

	self.mFreeCoinsBtn.onClick:AddListener(function()
		GlobalAudioHandler:PlayBtnSound()
        FreeBonusGamePopView:Show()
	end)
	
	self:InitThemeView()
	self.mTimeOutGenerator = TimeOutGenerator:New()
end

function LobbyView:SetCoinsFlyEndPos()
	GlobalTempData.goUITopCollectMoneyEndPos = self.goCollectMoneyEndPos
end

function LobbyView:Show()
	self:Init()
	EventHandler:AddListener("UpdateMyInfo", self)
	EventHandler:AddListener("onInboxMessageChangedNotifycation", self)
	
	self.transform.gameObject:SetActive(true)
	self:SetCoinsFlyEndPos()

	self.goldTextNumberAddAni:End(PlayerHandler.nGoldCount)
	self.textLevel.text = "Lv."..PlayerHandler.nLevel

	self:onInboxMessageChangedNotifycation()
	self:InitLevelProgressbar()
	self:RefreshThemeUnLockState()
	
	GlobalAudioHandler:PlayLobbyBackMusic()
	if not LuaHelper.IsNullOrWhiteSpace(ThemeLoader.themeName) then
		local bTanChuang = math.random() < 0.5
		if bTanChuang then
			FlashSaleHandler:Show()
		end
	end
end

function LobbyView:Hide()
	EventHandler:RemoveListener("UpdateMyInfo", self)
	EventHandler:RemoveListener("onInboxMessageChangedNotifycation", self)
	self.transform.gameObject:SetActive(false)
end

function LobbyView:Update()
	if self.mTimeOutGenerator:orTimeOut() then
		self:OnStoreBonusChanged()
		self:OnFlashSalesChanged()
	end
end

function LobbyView:onInboxMessageChangedNotifycation()
	local nAwardCount = InBoxHandler:GetSmallTipCount()
	if nAwardCount > 0 then
		self.goInBoxMessageTip:SetActive(true)
		self.textInboxCountText.text = nAwardCount
	else
		self.goInBoxMessageTip:SetActive(false)
	end
end

function LobbyView:UpdateMyInfo()
	self.goldTextNumberAddAni:ChangeTo(PlayerHandler.nGoldCount)
	self.textLevel.text = "Lv."..PlayerHandler.nLevel
	self:UpdateLevelProgressbar()
end

function LobbyView:InitLevelProgressbar()
	self.textLevel.text = "Lv."..PlayerHandler.nLevel

	local nSumExp = FormulaHelper:GetSumLevelExp(PlayerHandler.nLevel)
	local fPercent = PlayerHandler.nLevelExp / nSumExp
	fPercent = math.min(fPercent, 1)
	local fPercent1 = math.floor(fPercent * 100)

	self.mLevelProgressbarText.text = fPercent1.."%"

	local oriSize =self.mLevelProgressbar.rectTransform.sizeDelta
	local nTargetSizeX = 430 * fPercent
	if fPercent > 0 then
		if nTargetSizeX < 10 then
			nTargetSizeX = 0
		else
			nTargetSizeX = math.max(20, nTargetSizeX)
		end
	end	
	self.mLevelProgressbar.rectTransform.sizeDelta = Unity.Vector2(nTargetSizeX, oriSize.y)

end

function LobbyView:UpdateLevelProgressbar()
	self.textLevel.text = "Lv."..PlayerHandler.nLevel

	local nSumExp = FormulaHelper:GetSumLevelExp(PlayerHandler.nLevel)
	local fPercent = PlayerHandler.nLevelExp / nSumExp
	fPercent = math.min(fPercent, 1)
	local fPercent1 = math.floor(fPercent * 100)
	self.mLevelProgressbarText.text = fPercent1.."%"

	local oriSize = self.mLevelProgressbar.rectTransform.sizeDelta
	local nTargetSizeX = 430 * fPercent
	if fPercent > 0 then
		if nTargetSizeX < 10 then
			nTargetSizeX = 0
		else
			nTargetSizeX = math.max(20, nTargetSizeX)
		end
	end	
	LeanTween.value(self.transform.gameObject, oriSize.x, nTargetSizeX, 0.6):setOnUpdate(function(value)
		local fSizeX = value
		self.mLevelProgressbar.rectTransform.sizeDelta = Unity.Vector2(fSizeX, oriSize.y)
	end)
end

function LobbyView:UpCoinsCanvasLayer(order, pos)
	if order then
		self.mCoinsCanvas.sortingOrder = order
	else
		self.mCoinsCanvas.sortingOrder = 1010
	end
	
	if pos then
		self.mCoinsCanvas:GetComponent(typeof(Unity.RectTransform)).anchoredPosition = pos
	else
		self.mCoinsCanvas:GetComponent(typeof(Unity.RectTransform)).anchoredPosition = Unity.Vector2(-650, 0)
	end
end

function LobbyView:DownCoinsCanvasLayer()
	self.mCoinsCanvas.sortingOrder = 11
	self.mCoinsCanvas:GetComponent(typeof(Unity.RectTransform)).anchoredPosition = Unity.Vector2(-388, -15)
end

function LobbyView:InitThemeView()
	local VideoThemeRootEntryItemGenerator = require "Lua/LobbyScene/VideoThemeRootEntryItem"
	self.tableVideoThemeRootEntry = {}
	self.tableVideoThemeEntry = {}

	StartCoroutine(function()
		local fVideoItemWidth = 450
		local nSumWidth = fVideoItemWidth * #ThemeVideoConfig + 500
		self.goThemeItemParent:GetComponent(typeof(Unity.RectTransform)).sizeDelta = Unity.Vector2(nSumWidth, 0)
		local mScrollRectZoneHideHelper = self.goThemeItemParent:GetComponent(typeof(CS.ScrollRectZoneHideHelper))
		
		local nIndex = 0
		local nVideoIndex = 0
		local fItemPosX = 100
		while nVideoIndex < #ThemeVideoConfig do
			nIndex = nIndex + 1

			nVideoIndex = nVideoIndex + 1
			local configItem = ThemeVideoConfig[nVideoIndex]
			if configItem ~= nil and configItem.themeName ~= nil then
				local themeName = configItem.themeName
				local goEntry = Unity.GameObject()
				goEntry.name = "configItem_"..nIndex.."_"..themeName
				goEntry.transform:SetParent(self.goThemeList.transform, false)
				goEntry.transform.localPosition = Unity.Vector3(fItemPosX, 0, 0)
				goEntry:SetActive(true)
				VideoThemeRootEntryItemGenerator:New(goEntry, configItem)
				mScrollRectZoneHideHelper:AddItem(goEntry)
				fItemPosX = fItemPosX + fVideoItemWidth
			end

			if nIndex % 5 == 0 then
				yield_return(0)
			end
		end

		mScrollRectZoneHideHelper:Active()
	end)
	
	self:InitAutoUpdateThemeRootEntryOp()
	self:InitAutoUpdateThemeOp()
end

function LobbyView:InitAutoUpdateThemeRootEntryOp()
	StartCoroutine(function()
		local bContinueWhile = true
		while bContinueWhile do
			local bHaveDownload = false
			for i = 1, #ThemeVideoConfig do
				local themeName = ThemeVideoConfig[i].themeName
				if themeName ~= nil and themeName ~= "" then
					if self.tableVideoThemeRootEntry[themeName] == nil then
						bHaveDownload = true
						break
					end
					if self.tableVideoThemeRootEntry[themeName]:CheckOrDownloading() then
						bHaveDownload = true
						break
					end
				end
			end
			
			bContinueWhile = bHaveDownload
			yield_return(Unity.WaitForSeconds(1.0))
		end
	end)
end

function LobbyView:InitAutoUpdateThemeOp()
	StartCoroutine(function()
		local bContinueWhile = true
		while bContinueWhile do
			local bHaveDownload = false
			for i = 1, 2 do
				local themeName = ThemeVideoConfig[i].themeName
				if self.tableVideoThemeEntry[themeName] == nil then
					bHaveDownload = true
					break
				end

				if self.tableVideoThemeEntry[themeName]:CheckOrDownloading() then
					bHaveDownload = true
					break
				end
			end

			bContinueWhile = bHaveDownload
			yield_return(Unity.WaitForSeconds(1.0))
		end
	end)
end

function LobbyView:RefreshThemeUnLockState()
	for i = 1, #ThemeVideoConfig do
		local themeName = ThemeVideoConfig[i].themeName
		if self.tableVideoThemeEntry[themeName] then
			self.tableVideoThemeEntry[themeName]:SetUnLockStateWhenLevelUp()
		end
	end	
end

function LobbyView:OnStoreBonusChanged()
	self.goStoreBonusGiftBox:SetActive(CommonDbHandler:orCanGetStoreBonus())
end

function LobbyView:OnFlashSalesChanged()
	if FlashSaleHandler:orInFlashSale() or PlayerHandler.nRecharge == 0 then
		self.goFalashSalesShopEntry:SetActive(true)
		self.goThemeList.transform.anchoredPosition = Unity.Vector2(400, 0)
	else
		self.goFalashSalesShopEntry:SetActive(false)
		self.goThemeList.transform.anchoredPosition = Unity.Vector2.zero
	end
end














