RoyalPassScollView = {}

function RoyalPassScollView:Init(parent)
	if self.bInit then
		return
	end

	self.co = StartCoroutine(function()
		WindowLoadingView:Show()
		while not self.bInit do
			yield_return(0)
		end
		WindowLoadingView:Hide()
		self.co = nil
	end)

	self.scrollContent = parent:FindDeepChild("FreePassContent")
	self.scrollContentRect = self.scrollContent:GetComponent(typeof(Unity.RectTransform))

	local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/RoyalPass/FreePassTip")
	self.goFreePassTipPool = GoPool:New(goPrefab, self.scrollContent, 5)

	local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/RoyalPass/RoyalPassTip")
	self.goRoyalPassTipPool = GoPool:New(goPrefab, self.scrollContent, 5)

	self.royal100Item = nil
	self.m_goLevelRoyal100TiShi = nil
	self.levelInfos = {}
	self.tablePrizeContent = {}

	self.scrollRect = parent:FindDeepChild("FreePassScrollView"):GetComponent(typeof(Unity.RectTransform))
	self.tipHideAnimationId = Unity.Animator.StringToHash("Hide")
	self.trLocks = self.scrollRect:FindDeepChild("FreePassContent/Locks")
	local scrollRect = self.scrollContent.parent:GetComponent(typeof(UnityUI.ScrollRect))
	DelegateCache:addOnValueChanged(scrollRect)
	scrollRect.onValueChanged:AddListener(function(value)
		self:hideAllTipGo()
		local rectX = self.scrollContentRect.anchoredPosition.x
		local minX = -100
		local maxX = 1300
		for i = 1, #self.levelInfos do
			local fOffset = self.levelInfos[i].anchoredPosition.x + rectX
			local bShow = fOffset > minX and fOffset < maxX
			self.levelInfos[i].gameObject:SetActive(bShow)
		end
		
		for i = 1, #self.freePassPrizeInfos do
			local item = self.freePassPrizeInfos[i][1]
			local fOffset = item.anchoredPositionX + rectX
			local bShow = fOffset > minX and fOffset < maxX
			if item.gameObject.activeSelf ~= bShow then
				item.gameObject:SetActive(bShow)
			end
		end

		for i = 1, #self.royalPassPrizeInfos do
			local item = self.royalPassPrizeInfos[i][1]
			local fOffset = item.anchoredPositionX + rectX
			local bShow = fOffset > minX and fOffset < maxX
			if item.gameObject.activeSelf ~= bShow then
				item.gameObject:SetActive(bShow)
			end
		end

		local nCurrentLevel = RoyalPassHandler.m_nLevel
		--移动到当前等级的图标上
		if self.levelInfos[nCurrentLevel] and math.abs(self.scrollRect.position.x - self.levelInfos[nCurrentLevel].position.x) > self.scrollRect.sizeDelta.x/2 then
			if (self.scrollRect.position.x - self.levelInfos[nCurrentLevel].position.x) > 0 then
				-- Debug.Log("左边！！！！！！")
				if not RoyalPassMainUI.m_btnToLeftLevel.gameObject.activeSelf then
					local textLevel = self:FindSymbolElement(RoyalPassMainUI.m_btnToLeftLevel, "TextLevel")
					textLevel.text = nCurrentLevel
					RoyalPassMainUI.m_btnToLeftLevel.gameObject:SetActive(true)
				end
				if RoyalPassMainUI.m_btnToRightLevel.gameObject.activeSelf then
					RoyalPassMainUI.m_btnToRightLevel.gameObject:SetActive(false)
				end
			else
				-- Debug.Log("右边！！！！！！")
				if RoyalPassMainUI.m_btnToLeftLevel.gameObject.activeSelf then
					RoyalPassMainUI.m_btnToLeftLevel.gameObject:SetActive(false)
				end
				if not RoyalPassMainUI.m_btnToRightLevel.gameObject.activeSelf then
					local textLevel = self:FindSymbolElement(RoyalPassMainUI.m_btnToRightLevel, "TextLevel")
					textLevel.text = nCurrentLevel
					RoyalPassMainUI.m_btnToRightLevel.gameObject:SetActive(true)
				end
			end
		else
			if RoyalPassMainUI.m_btnToLeftLevel.gameObject.activeSelf then
				RoyalPassMainUI.m_btnToLeftLevel.gameObject:SetActive(false)
			end
			if RoyalPassMainUI.m_btnToRightLevel.gameObject.activeSelf then
				RoyalPassMainUI.m_btnToRightLevel.gameObject:SetActive(false)
			end
		end
		if not RoyalPassMainUI.m_btnToRightLevel.gameObject.activeSelf and self.royal100Item then
			if (math.abs(self.scrollRect.position.x - self.royal100Item.position.x) > self.scrollRect.sizeDelta.x/2) then
				if not RoyalPassMainUI.m_btnToRoyalChest.gameObject.activeSelf then
					RoyalPassMainUI.m_btnToRoyalChest.gameObject:SetActive(true)
				end
			else
				if RoyalPassMainUI.m_btnToRoyalChest.gameObject.activeSelf then
					RoyalPassMainUI.m_btnToRoyalChest.gameObject:SetActive(false)
				end
			end
		else
			if RoyalPassMainUI.m_btnToRoyalChest.gameObject.activeSelf then
				RoyalPassMainUI.m_btnToRoyalChest.gameObject:SetActive(false)
			end
		end
		if self.m_goLevelRoyal100TiShi and self.m_goLevelRoyal100TiShi.activeSelf then
			if math.abs(self.scrollRect.position.x - self.royal100Item.position.x) > self.scrollRect.sizeDelta.x/2 then
				self.m_goLevelRoyal100TiShi:SetActive(false)
			end
		end
		local nLength1 = LuaHelper.tableSize(self.mapFreePasslevelTipGos)
		if nLength1 > 0 then
			for k,v in pairs(self.mapFreePasslevelTipGos) do
				for i,goTip in pairs(v) do
					if goTip.gameObject.activeSelf then
						if math.abs(self.scrollRect.position.x - goTip.transform.position.x) > self.scrollRect.sizeDelta.x/2 then
							goTip.gameObject:SetActive(false)
						else
							if i == 2 then
								goTip.transform.position = self.freePassLimitedInfos[k].passItem.position
							else
								goTip.transform.position = self.freePassPrizeInfos[k][i].item.position
							end
						end
					end
				end
			end
		end
		local nLength1 = LuaHelper.tableSize(self.mapRoyalPasslevelTipGos)
		if nLength1 > 0 then
			for k,v in pairs(self.mapRoyalPasslevelTipGos) do
				for i,goTip in pairs(v) do
					if goTip.gameObject.activeSelf then
						if math.abs(self.scrollRect.position.x - goTip.transform.position.x) > self.scrollRect.sizeDelta.x/2 then
							goTip.gameObject:SetActive(false)
						else
							if i == 2 then
								goTip.transform.position = self.royalPassLimitedInfos[k].passItem.position
							else
								goTip.transform.position = self.royalPassPrizeInfos[k][i].item.position
							end
						end
					end
				end
			end
		end
	end)
	self:initPassContent()
end

function RoyalPassScollView:Update()
	local dt = Unity.Time.deltaTime
    for k, v in pairs(self.freePassLimitedInfos) do
		local item = v.item
		local textInfo = self:FindSymbolElement(item, "TextInfo")
		local limitedInfo = RoyalPassHandler:getFreePassLimitedInfo(k+1)

		if limitedInfo.nLimitedEndTime ~= nil and textInfo.gameObject.activeSelf then
			if limitedInfo.bInLimitedEndFinish then
				textInfo.text = "DONE"
			else
				local nowSecond = TimeHandler:GetServerTimeStamp()
				if nowSecond < limitedInfo.nLimitedEndTime then
					local timediff = limitedInfo.nLimitedEndTime - nowSecond

					local hours = timediff // 3600
					local minutes = timediff // 60 - 60 * hours
					local seconds = timediff % 60

					textInfo.text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
					if timediff <= 0 then
						if limitedInfo.bInLimitedEndFinish then
							textInfo.text = "DONE"
						else
							textInfo.text = "TIME OVER"
						end
					end
					if limitedInfo.bInLimitedEndFinish then
						textInfo.text = "DONE"
					end
				else
					textInfo.text = "TIME OVER"
				end
			end
		end
	end

	for k,v in pairs(self.royalPassLimitedInfos) do
		local item = v.item
		local textInfo = self:FindSymbolElement(item, "TextInfo")
		local limitedInfo = RoyalPassHandler:getRoyalPassLimitedInfo(k+1)

		if limitedInfo.nLimitedEndTime ~= nil and textInfo.gameObject.activeSelf then
			if limitedInfo.bInLimitedEndFinish then
				textInfo.text = "DONE"
			else
				local nowSecond = TimeHandler:GetServerTimeStamp()
				if nowSecond < limitedInfo.nLimitedEndTime then
					local timediff = limitedInfo.nLimitedEndTime - nowSecond

					local hours = timediff // 3600
					local minutes = timediff // 60 - 60 * hours
					local seconds = timediff % 60

					textInfo.text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
					if timediff <= 0 then
						if limitedInfo.bInLimitedEndFinish then
							textInfo.text = "DONE"
						else
							textInfo.text = "TIME OVER"
						end
					end
					if limitedInfo.bInLimitedEndFinish then
						textInfo.text = "DONE"
					end
				else
					textInfo.text = "TIME OVER"
				end
			end
		end
	end
end

function RoyalPassScollView:initPassContent()
	local freePassPrefab = AssetBundleHandler:LoadAsset("Lobby", "Assets/ResourceABs/Lobby/Missions/RoyalPass/FreePassItem.prefab")
	local freePassLimitedPrefab = AssetBundleHandler:LoadAsset("Lobby", "Assets/ResourceABs/Lobby/Missions/RoyalPass/FreePassLimited.prefab")
	self.freePassPrizeInfos = {}
	self.freePassLimitedInfos = {}
	self.mapFreePasslevelTipGos = {} -- self.maplevelTipGos[0] = {[go, go]}

	local royalPassPrefab = AssetBundleHandler:LoadAsset("Lobby", "Assets/ResourceABs/Lobby/Missions/RoyalPass/RoyalPassItem.prefab")
	local royalPassLimitedPrefab = AssetBundleHandler:LoadAsset("Lobby", "Assets/ResourceABs/Lobby/Missions/RoyalPass/RoyalPassLimited.prefab")
	self.royalPassPrizeInfos = {}
	self.royalPassLimitedInfos = {}
	self.mapRoyalPasslevelTipGos = {} -- self.maplevelTipGos[0] = {[go, go]}

	local levelInfoPrefab = AssetBundleHandler:LoadAsset("Lobby", "Assets/ResourceABs/Lobby/Missions/RoyalPass/LevelInfoItem.prefab")
	self.levelInfos = {}

	self.m_trDiamondContainer = self.scrollContent:FindDeepChild("DiamondContainer")
	self.m_trDiamondContainer.gameObject:SetActive(false)
	local btn = self.m_trDiamondContainer:GetComponentInChildren(typeof(UnityUI.Button))
	DelegateCache:addOnClickButton(btn)
	btn.onClick:AddListener(function()
		self:onDiamondBtnClick()
	end)

	local entry_width = 200
	local big_width = 380
	local lastPosX = -80
	for i = 0, 100 do
		local prizeInfo = RoyalPassConfig:GetFreePassLevelPrize(i+1)
		local nLength = LuaHelper.tableSize(prizeInfo)
		local addwidth = nLength > 1 and big_width or entry_width
		lastPosX = lastPosX + addwidth
		lastPosX = nLength > 1 and (lastPosX + entry_width - 20) or lastPosX
	end
	local progressBarBg = self:FindSymbolElement(self.scrollContent, "LevelJinDuBG"):GetComponent(typeof(Unity.RectTransform))
	progressBarBg.sizeDelta = Unity.Vector2(lastPosX - 300, progressBarBg.sizeDelta.y)

	StartCoroutine(function()
		local entry_width = 200
		local big_width = 380
		local lastPosX = -80
		for i = 0, 100 do
			--FreePass
			local prizeInfo = RoyalPassConfig:GetFreePassLevelPrize(i+1)
			local nLength = LuaHelper.tableSize(prizeInfo)
			local passItemGameObject = nLength > 1 and Unity.Object.Instantiate(freePassLimitedPrefab) or Unity.Object.Instantiate(freePassPrefab)
			local passItem = passItemGameObject:GetComponent(typeof(Unity.RectTransform))
			passItem:SetParent(self.scrollContent, false)
			local addwidth = nLength > 1 and big_width or entry_width
			passItem.anchoredPosition3D = Unity.Vector3(lastPosX + addwidth, 148, 0)
			if nLength > 1 then
				local passItem1 = Unity.Object.Instantiate(freePassPrefab):GetComponent(typeof(Unity.RectTransform))
				passItem1:SetParent(passItem, false)
				passItem1.anchoredPosition3D = Unity.Vector3(-124, 0, 0)
				self:initFreePassItem(i, passItem1, passItem.anchoredPosition.x -124, 148)
				
				local passItem2 = Unity.Object.Instantiate(freePassPrefab):GetComponent(typeof(Unity.RectTransform))
				passItem2:SetParent(passItem, false)
				passItem2.anchoredPosition3D = Unity.Vector3(34, 0, 0)
				self:initFreePassLimitedItem(passItem, i, passItem2, passItem.anchoredPosition.x + 34, 148)
			else
				self:initFreePassItem(i, passItem, passItem.anchoredPosition.x, 148)
			end

			--RoyalPass
			local prizeInfo = RoyalPassConfig:GetRoyalPassLevelPrize(i+1)
			local nLength = LuaHelper.tableSize(prizeInfo)
			local passItemGameObject = nLength > 1 and Unity.Object.Instantiate(royalPassLimitedPrefab) or Unity.Object.Instantiate(royalPassPrefab)
			local passItem = passItemGameObject:GetComponent(typeof(Unity.RectTransform))
			passItem:SetParent(self.scrollContent, false)
			local addwidth = nLength > 1 and big_width or entry_width
			passItem.anchoredPosition3D = Unity.Vector3(lastPosX + addwidth, -142, 0)
			if nLength > 1 then
				local passItem1 = Unity.Object.Instantiate(royalPassPrefab):GetComponent(typeof(Unity.RectTransform))
				passItem1:SetParent(passItem, false)
				passItem1.anchoredPosition3D = Unity.Vector3(-124, 0, 0)
				self:initRoyalPassItem(i, passItem1, passItem.anchoredPosition.x - 124, -142)
				local passItem2 = Unity.Object.Instantiate(royalPassPrefab):GetComponent(typeof(Unity.RectTransform))
				passItem2:SetParent(passItem, false)
				passItem2.anchoredPosition3D = Unity.Vector3(34, 0, 0)
				self:initRoyalPassLimitedItem(passItem, i, passItem2, passItem.anchoredPosition.x + 34, -142)
			else
				self:initRoyalPassItem(i, passItem, passItem.anchoredPosition.x, -142)
			end

			local passItemGameObject = Unity.Object.Instantiate(levelInfoPrefab)
			local passItem = passItemGameObject:GetComponent(typeof(Unity.RectTransform))
			passItem:SetParent(self.scrollContent, false)
			local addwidth = nLength > 1 and big_width or entry_width
			passItem.anchoredPosition3D = Unity.Vector3(lastPosX + addwidth, 0, 0)
			self:initLevelInfoItem(i, passItem)

			lastPosX = nLength > 1 and (passItem.anchoredPosition.x + entry_width - 20) or passItem.anchoredPosition.x
			if i % 10 == 0 then
				yield_return(0)
			end
			self.scrollContent.sizeDelta = Unity.Vector2(lastPosX + 250, self.scrollContent.sizeDelta.y)
		end
		
		local levelRoyalPrefab = AssetBundleHandler:LoadAsset("Lobby", "Assets/ResourceABs/Lobby/Missions/RoyalPass/LevelRoyal100.prefab")
		local passItemGameObject = Unity.Object.Instantiate(levelRoyalPrefab)
		self.royal100Item = passItemGameObject:GetComponent(typeof(Unity.RectTransform))
		self.royal100Item:SetParent(self.scrollContent, false)
		self.royal100Item.anchoredPosition3D = Unity.Vector3(lastPosX + 450, 48, 0)
		lastPosX = self.royal100Item.anchoredPosition.x

		self.m_goLevelRoyal100TiShi = passItemGameObject.transform:FindDeepChild("LevelRoyal100TiShi").gameObject
		self.m_goLevelRoyal100TiShi:SetActive(false)
		self.m_btnRoyalLevel100 = passItemGameObject.transform:FindDeepChild("BtnRoyalLevel100"):GetComponent(typeof(UnityUI.Button))
		DelegateCache:addOnClickButton(self.m_btnRoyalLevel100)
		self.m_btnRoyalLevel100.onClick:AddListener(function()
			self:onRoyalLevel100TipBtnClicked()
		end)
		self.m_textMissionChestInfo = passItemGameObject.transform:FindDeepChild("MissionChestInfo"):GetComponent(typeof(TextMeshProUGUI))
		self.m_textMissionChestStarCount = passItemGameObject.transform:FindDeepChild("TextXing"):GetComponent(typeof(TextMeshProUGUI))
		self.m_goMissionChestStarsContainer = passItemGameObject.transform:FindDeepChild("RoyalStars").gameObject
		self.m_textMissionChestLevel = passItemGameObject.transform:FindDeepChild("TextLevel"):GetComponent(typeof(TextMeshProUGUI))
		self.m_textMissionChestReward = passItemGameObject.transform:FindDeepChild("MissionChestRewardText"):GetComponent(typeof(UnityUI.Text))
		self.m_textMissionChestInfo = passItemGameObject.transform:FindDeepChild("MissionChestInfo"):GetComponent(typeof(TextMeshProUGUI))
		local btnShowReward = passItemGameObject.transform:FindDeepChild("BtnShowReward"):GetComponent(typeof(UnityUI.Button))
		DelegateCache:addOnClickButton(btnShowReward)
		btnShowReward.onClick:AddListener(function()
			self:onMissionChestClicked()
		end)
		self.scrollContent.sizeDelta = Unity.Vector2(lastPosX + 250, self.scrollContent.sizeDelta.y)

		local progressBar = self:FindSymbolElement(self.scrollContent, "LevelProgress"):GetComponent(typeof(Unity.RectTransform))
		progressBar.sizeDelta = Unity.Vector2( self.levelInfos[RoyalPassHandler.m_nLevel].anchoredPosition.x - 100 , 28)

		self.bInit = true
		self:UpdateAllItem()
		self.trLocks:SetAsLastSibling()
	end)

end

function RoyalPassScollView:onBtnToRightLevelClicked()
	if self.moveId ~= nil and LeanTween.isTweening(self.moveId) then
		LeanTween.cancel(self.moveId)
	end
	local nCurrentLevel = RoyalPassHandler.m_nLevel
	local targetPos = -self.levelInfos[nCurrentLevel].anchoredPosition.x - self.scrollRect.sizeDelta.x/3
	self.moveId = LeanTween.moveLocalX(self.scrollContent.gameObject, targetPos, 0.5).id
end

function RoyalPassScollView:onBtnToLeftLevelClicked()
	if self.moveId ~= nil and LeanTween.isTweening(self.moveId) then
		LeanTween.cancel(self.moveId)
	end
	local nCurrentLevel = RoyalPassHandler.m_nLevel
	local targetPos = -self.levelInfos[nCurrentLevel].anchoredPosition.x - self.scrollRect.sizeDelta.x/3
	self.moveId = LeanTween.moveLocalX(self.scrollContent.gameObject, targetPos, 0.5).id
end

function RoyalPassScollView:onBtnToRoyalChestClicked()
	if self.moveId ~= nil and LeanTween.isTweening(self.moveId) then
		LeanTween.cancel(self.moveId)
	end
	local targetPos = -self.royal100Item.anchoredPosition.x - self.scrollRect.sizeDelta.x/3
	self.moveId = LeanTween.moveLocalX(self.scrollContent.gameObject, targetPos, 0.5).id
end

function RoyalPassScollView:onMissionChestClicked()
	GlobalAudioHandler:PlayBtnSound()
	RoyalPassMissionChestUI:Show()
end

function RoyalPassScollView:updateMissionChestUI()
	local bIsUnLock = RoyalPassHandler.m_nLevel >= 100 and RoyalPassDbHandler.data.m_bIsPurchase
	self.m_goMissionChestStarsContainer:SetActive(bIsUnLock)
	self.m_textMissionChestInfo.gameObject:SetActive(not bIsUnLock)
	if bIsUnLock then
		local nCurrentStar, nChestLevelUpgradeNeedStars = RoyalPassHandler:GetLastChestCurrentRemainStar()
		nCurrentStar = math.modf(nCurrentStar)
		self.m_textMissionChestStarCount.text = nCurrentStar.."/"..nChestLevelUpgradeNeedStars
		self.m_textMissionChestLevel.text = "ROYAL TROPHY LEVEL "..RoyalPassHandler.m_nLastChestLevel
		local nCoins = RoyalPassHandler:GetLastChestLevelRewards()
    	self.m_textMissionChestReward.text = MoneyFormatHelper.numWithCommas(nCoins).." COINS"
	else
		self.m_textMissionChestInfo.text = "UNLOCK ROYAL PASS &\nREACH LEVEL 100 TO UNLOCK!"
	end
end

function RoyalPassScollView:onRoyalLevel100TipBtnClicked()
	GlobalAudioHandler:PlayBtnSound()
	if self.m_goLevelRoyal100TiShi.activeSelf then
		self.m_goLevelRoyal100TiShi:SetActive(false)
	else
		self.m_goLevelRoyal100TiShi:SetActive(true)
	end
end

function RoyalPassScollView:updateFreePassLimitedUI(nIndex)
	local item = self.freePassLimitedInfos[nIndex].item
	local passItem = self.freePassLimitedInfos[nIndex].passItem
	local btn = self.freePassLimitedInfos[nIndex].btn

	local textInfo = self:FindSymbolElement(item, "TextInfo")
	local limitedInfo = RoyalPassHandler:getFreePassLimitedInfo(nIndex+1)

	local lockContainer = self.freePassLimitedInfos[nIndex].lockContainer
	local prizeContainer = self.freePassLimitedInfos[nIndex].prizeContainer
	local getContainer = self.freePassLimitedInfos[nIndex].getContainer
	local noPrizeContainer = self.freePassLimitedInfos[nIndex].noPrizeContainer
	
	local prizeInfo = RoyalPassConfig:GetFreePassLevelPrize(nIndex+1)
	local prize = prizeInfo[2]
	local bNoPrize = prize.nType == RoyalPassConfig.PrizeType.None
	noPrizeContainer.gameObject:SetActive(bNoPrize)
	prizeContainer.gameObject:SetActive(not bNoPrize)

	local bIsLock = nIndex > RoyalPassHandler.m_nLevel

	if limitedInfo.bInLimitedEndFinish == nil then
		lockContainer.gameObject:SetActive(true)
	else
		lockContainer.gameObject:SetActive(not limitedInfo.bInLimitedEndFinish)
	end

	if not bIsLock then
		local bGet = RoyalPassHandler:getFreePassGet(nIndex + 1, 2)
		getContainer.gameObject:SetActive(bGet)
		btn.interactable = not bGet
	else
		btn.interactable = not bIsLock
		getContainer.gameObject:SetActive(false)
	end

	local limiteImg = self:FindSymbolElement(item, "Limited")
	if limitedInfo.nLimitedEndTime == nil then
		textInfo.gameObject:SetActive(false)
		limiteImg.transform.anchoredPosition = Unity.Vector2(159.4, 0)
	else
		textInfo.gameObject:SetActive(true)
		limiteImg.transform.anchoredPosition = Unity.Vector2(159.4, -30)
	end
	self:updateSendPrizeUI(prizeContainer, prize, bNoPrize)

end

function RoyalPassScollView:updateSendPrizeUI(prizeContainer, prize, bNoPrize)
	local strName = ""
	if prize.nType == RoyalPassConfig.PrizeType.Activty then
		strName = ActiveManager.activeType
	else
		strName = RoyalPassConfig.PrizeName[prize.nType]
	end
	
	local go = self.tablePrizeContent[prizeContainer]
	if not go or go.name ~= strName then
		if go then
			Unity.Object.Destroy(go)
		end
		local prefabObj = AssetBundleHandler:LoadAsset("Lobby", "Assets/ResourceABs/Lobby/Missions/RoyalPass/Items/"..strName..".prefab")
		local go = Unity.Object.Instantiate(prefabObj, prizeContainer.transform)
		go.name = strName
		go.transform.localPosition = Unity.Vector3.zero
		go.transform.localScale = Unity.Vector3.one
		self.tablePrizeContent[prizeContainer] = go
	end
	go = self.tablePrizeContent[prizeContainer]
	
	if not bNoPrize and prize.nType == RoyalPassConfig.PrizeType.Activty then
		local spinText = self:FindSymbolElement(go, "CountText")
		spinText.text = "+".._G[ActiveManager.activeType.."IAPConfig"].skuMapOther[prize.productId]
	end

	if not bNoPrize then
		if prize.nType == RoyalPassConfig.PrizeType.Coins then
			local nDollar = RoyalPassHandler:getBasePrize(prize.productId).nDollar
			local coinsText = self:FindSymbolElement(go, "CountText")
			coinsText.text = "$"..nDollar
		elseif prize.nType == RoyalPassConfig.PrizeType.SlotsCards then
			local stars = self:FindSymbolElement(go, "Stars").transform
			local packCount = self:FindSymbolElement(go,"DoublePack")
			local packTypeContainer = self:FindSymbolElement(go,"KaPaiJieDian").transform
			packCount:GetComponentInChildren(typeof(TextMeshProUGUI)).text = prize.nCount.." PACKS"
			stars.sizeDelta = Unity.Vector2(20* (prize.nSlotsType + 1), 20)
			for j = 0, stars.childCount - 1 do
				if j < prize.nSlotsType then
					stars:GetChild(j).gameObject:SetActive(true)
				else
					stars:GetChild(j).gameObject:SetActive(false)
				end
				packTypeContainer:GetChild(j).gameObject:SetActive(j + 1 == prize.nSlotsType)
			end
		elseif prize.nType == RoyalPassConfig.PrizeType.LoungeChest then
			local trChest = self:FindSymbolElement(go, "ChestNodes").transform
			for i=0, trChest.childCount - 1 do
				trChest:GetChild(i).gameObject:SetActive(i+1==prize.nChestType)
			end
			local countText = self:FindSymbolElement(go, "CountText")
			countText.text = "+"..prize.nCount
		elseif prize.nType == RoyalPassConfig.PrizeType.VipPoint then
			local vipText = self:FindSymbolElement(go, "CountText")
			vipText.text = "+"..prize.nPointCount.." PTS."
		elseif prize.nType == RoyalPassConfig.PrizeType.Diamond then
			local countText = self:FindSymbolElement(go, "CountText")
			countText.text = "+"..prize.nCount
		elseif prize.nType == RoyalPassConfig.PrizeType.LoungePoint then
			local countText = self:FindSymbolElement(go, "CountText")
			countText.text = "+"..prize.nCount
		elseif prize.nType == RoyalPassConfig.PrizeType.LoungeDayPass then
			local countText = self:FindSymbolElement(go, "CountText")
			countText.text = prize.nCount
		elseif prize.nType == RoyalPassConfig.PrizeType.MissionStarBooster then
			local countText = self:FindSymbolElement(go, "CountText")
			countText.text = string.format("%d hr", math.modf(prize.nTime / 3600))
		elseif prize.nType == RoyalPassConfig.PrizeType.FlashBooster then
			local countText = self:FindSymbolElement(go, "CountText")
			countText.text = string.format("%d hr", math.modf(prize.nTime / 3600))
		elseif prize.nType == RoyalPassConfig.PrizeType.PigBank then
			local countText = self:FindSymbolElement(go, "CountText")
			local fRatio = math.modf(prize.fRatio*100)
			countText.text = "More "..fRatio.."%"
		elseif prize.nType == RoyalPassConfig.PrizeType.Coupon then
			local countText = self:FindSymbolElement(go, "CountText")
			countText.text = string.format("%d hr", math.modf(prize.nTime / 3600))
			local morePercent = self:FindSymbolElement(go, "MorePercent")
			local fRatio = math.modf((prize.fRatio - 1)*100)
			morePercent.text = fRatio.."%"
		elseif prize.nType == RoyalPassConfig.PrizeType.DiamondCoupon then
			local countText = self:FindSymbolElement(go, "CountText")
			countText.text = string.format("%d hr", math.modf(prize.nTime / 3600))
			local morePercent = self:FindSymbolElement(go, "MorePercent")
			local fRatio = math.modf((prize.fRatio - 1)*100)
			morePercent.text = fRatio.."%"
		elseif prize.nType == RoyalPassConfig.PrizeType.ShopStampCard then
			local countText = self:FindSymbolElement(go, "CountText")
			countText.text = prize.nCount
		elseif prize.nType == RoyalPassConfig.PrizeType.CoinsAndVip then
			local nDollar = RoyalPassHandler:getBasePrize(prize.productId).nDollar
			local coinsText = self:FindSymbolElement(go, "CoinsCount")
			coinsText.text = "$"..nDollar
			local vipText = self:FindSymbolElement(go, "VipCount")
			vipText.text = "+"..prize.nPointCount
		end
	end
end

function RoyalPassScollView:onFreePassClicked(nIndex, infoIndex)
	GlobalAudioHandler:PlayBtnSound()

	RoyalPassHandler:setFreePassGet(nIndex + 1, infoIndex)
	local item = nil
	if infoIndex == 2 then
		item = self.freePassLimitedInfos[nIndex].passItem
		self:updateFreePassLimitedUI(nIndex)
	else
		item = self.freePassPrizeInfos[nIndex][infoIndex].item
		self:updateFreePassUI(nIndex, infoIndex)
	end
	MissionMainUIPop:UpdateCountUI()

	local prizeInfo = RoyalPassConfig:GetFreePassLevelPrize(nIndex + 1)
	local prize = prizeInfo[infoIndex]
	local bHasCoins = prize.nType == RoyalPassConfig.PrizeType.Coins or prize.nType == RoyalPassConfig.PrizeType.CoinsAndVip
	
	local items = {}
	table.insert(items, item)
	RoyalPassFreeRewardsUI:Show(items, bHasCoins)
end

function RoyalPassScollView:getPrizeIntroduceStr(prize)
	local str = ""
	if prize.nType == RoyalPassConfig.PrizeType.Coins then
		local nDollar = RoyalPassHandler:getBasePrize(prize.productId).nDollar
		str = "Worth $"..nDollar.." of Coins"
    elseif prize.nType == RoyalPassConfig.PrizeType.SlotsCards then
		if prize.nSlotsType == SlotsCardsAllProbTable.PackType.One then
			str = "Card Pack +" .. prize.nCount
		elseif prize.nSlotsType == SlotsCardsAllProbTable.PackType.Two then
			str = "2 Stars Pack +" .. prize.nCount
		elseif prize.nSlotsType == SlotsCardsAllProbTable.PackType.Three then
			str = "3 Stars Pack +" .. prize.nCount
		elseif prize.nSlotsType == SlotsCardsAllProbTable.PackType.Four then
			str = "4 Stars Pack +" .. prize.nCount
		elseif prize.nSlotsType == SlotsCardsAllProbTable.PackType.Five then
			str = "5 Stars Pack +" .. prize.nCount
		end
    elseif prize.nType == RoyalPassConfig.PrizeType.ShopStampCard then
		str = prize.nCount.." Shop Stamp Card"
    elseif prize.nType == RoyalPassConfig.PrizeType.VipPoint then
		str = prize.nPointCount.." Vip Points" 
    elseif prize.nType == RoyalPassConfig.PrizeType.Activty then
		local active = ActiveManager.activeType
		if active then
			local productId = prize.productId
			local nAction = _G[active.."IAPConfig"].skuMapOther[productId]
			str = nAction.." Items for "..active
		end
    elseif prize.nType == RoyalPassConfig.PrizeType.Diamond then
		str = prize.nCount.." Diamonds"
    elseif prize.nType == RoyalPassConfig.PrizeType.Coupon then
		local fRatio = math.modf((prize.fRatio-1)*100)
		str = fRatio.."% Store Coins Coupon"
    elseif prize.nType == RoyalPassConfig.PrizeType.DiamondCoupon then
		local fRatio = math.modf((prize.fRatio-1)*100)
		str = fRatio.."% Store Diamond Coupon"
    elseif prize.nType == RoyalPassConfig.PrizeType.PigBank then
		local fRatio = math.modf(prize.fRatio*100)
		str = "Add "..fRatio.."% Piggy Bank"
	elseif prize.nType == RoyalPassConfig.PrizeType.MissionStarBooster then
		str = string.format("%d hr Royal Star Booster", math.modf(prize.nTime / 3600))
	elseif prize.nType == RoyalPassConfig.PrizeType.FlashBooster then
		str = string.format("%d hr Flash Challenge Booster", math.modf(prize.nTime / 3600))
	elseif prize.nType == RoyalPassConfig.PrizeType.CoinsAndVip then
		local nDollar = RoyalPassHandler:getBasePrize(prize.productId).nDollar
		str = "Worth $"..nDollar.." of Coins".."\n"..prize.nPointCount.." Vip Points"
	elseif prize.nType == RoyalPassConfig.PrizeType.LoungePoint then
		str = prize.nCount.." Lounge Points"
	elseif prize.nType == RoyalPassConfig.PrizeType.LoungeChest then
		local nChestType = prize.nChestType
		local listName = {"Common", "Rare", "Epic", "Legendary"}
		str = prize.nCount .. " " .. listName[nChestType] .. " Chests"
	elseif prize.nType == RoyalPassConfig.PrizeType.LoungeDayPass then
		str = prize.nCount.." Lounge Day Pass"
	end
	return str
end

function RoyalPassScollView:updateFreePassUI(nIndex, infoIndex)
	local info = self.freePassPrizeInfos[nIndex][infoIndex]

	local lockContainer = info.lockContainer
	local prizeContainer = info.prizeContainer
	local getContainer = info.getContainer
	local noPrizeContainer = info.noPrizeContainer
	local btn = info.btn

	local prizeInfo = RoyalPassConfig:GetFreePassLevelPrize(nIndex+1)
	local prize = prizeInfo[infoIndex] --暂时只取第一个奖励（有的level有两个奖励）{nType = RoyalPassConfig.PrizeType.Coins, nMultiplier = 30}

	local bNoPrize = prize.nType == RoyalPassConfig.PrizeType.None
	noPrizeContainer.gameObject:SetActive(bNoPrize)
	prizeContainer.gameObject:SetActive(not bNoPrize)

	local bIsLock = nIndex > RoyalPassHandler.m_nLevel
	
	if bNoPrize then
		lockContainer.gameObject:SetActive(false)
	else
		lockContainer.gameObject:SetActive(bIsLock)
	end

	if not bIsLock then
		local bGet = RoyalPassHandler:getFreePassGet(nIndex + 1, infoIndex)
		if bNoPrize then
			btn.interactable = false
			getContainer.gameObject:SetActive(false)
		else
			getContainer.gameObject:SetActive(bGet)
			btn.interactable = not bGet
		end
	else
		btn.interactable = not bIsLock
		getContainer.gameObject:SetActive(false)
	end

	self:updateSendPrizeUI(prizeContainer, prize, bNoPrize)
end

function RoyalPassScollView:updateRoyalPassLimitedUI(nIndex)
	local item = self.royalPassLimitedInfos[nIndex].item
	local passItem = self.royalPassLimitedInfos[nIndex].passItem
	local btn = self.royalPassLimitedInfos[nIndex].btn

	local textInfo = self:FindSymbolElement(item, "TextInfo")
	local limitedInfo = RoyalPassHandler:getRoyalPassLimitedInfo(nIndex+1)

	local lockContainer = self.royalPassLimitedInfos[nIndex].lockContainer
	local prizeContainer = self.royalPassLimitedInfos[nIndex].prizeContainer
	local getContainer = self.royalPassLimitedInfos[nIndex].getContainer
	local noPrizeContainer = self.royalPassLimitedInfos[nIndex].noPrizeContainer
	
	local prizeInfo = RoyalPassConfig:GetRoyalPassLevelPrize(nIndex+1)
	local prize = prizeInfo[2]
	local bNoPrize = prize.nType == RoyalPassConfig.PrizeType.None
	noPrizeContainer.gameObject:SetActive(bNoPrize)
	prizeContainer.gameObject:SetActive(not bNoPrize)

	local bIsLock = nIndex > RoyalPassHandler.m_nLevel
	if RoyalPassDbHandler.data.m_bIsPurchase then
		if limitedInfo.bInLimitedEndFinish == nil then
			lockContainer.gameObject:SetActive(true)
		else
			lockContainer.gameObject:SetActive(not limitedInfo.bInLimitedEndFinish)
		end
	else
		lockContainer.gameObject:SetActive(true)
	end
	local limiteImg = self:FindSymbolElement(item, "Limited")
	if limitedInfo.bInLimitedEndFinish == nil then
		textInfo.gameObject:SetActive(false)
		limiteImg.transform.anchoredPosition = Unity.Vector2(159.4, 0)
	else
		textInfo.gameObject:SetActive(true)
		limiteImg.transform.anchoredPosition = Unity.Vector2(159.4, -30)
	end
	if not bIsLock then
		local bGet = RoyalPassHandler:getRoyalPassGet(nIndex + 1, 2)
		getContainer.gameObject:SetActive(bGet)
		btn.interactable = not bGet
	else
		btn.interactable = not bIsLock
		getContainer.gameObject:SetActive(false)
	end
	self:updateSendPrizeUI(prizeContainer, prize, bNoPrize)
end

function RoyalPassScollView:onRoyalPassClicked(nIndex, infoIndex)
	GlobalAudioHandler:PlayBtnSound()
	-- TODO 更新数据库， 以获取该奖励
	RoyalPassHandler:setRoyalPassGet(nIndex + 1, infoIndex)

	local item = nil
	if infoIndex == 2 then
		item = self.royalPassLimitedInfos[nIndex].passItem
		self:updateRoyalPassLimitedUI(nIndex)
	else
		item = self.royalPassPrizeInfos[nIndex][infoIndex].item
		self:updateRoyalPassUI(nIndex, infoIndex)
	end
	MissionMainUIPop:UpdateCountUI()
	
	local prizeInfo = RoyalPassConfig:GetRoyalPassLevelPrize(nIndex + 1)
	local prize = prizeInfo[infoIndex]
	local bHasCoins = prize.nType == RoyalPassConfig.PrizeType.Coins

	local items = {}
	table.insert( items, item )
	RoyalPassRewardsUI:Show(items, bHasCoins)
end

function RoyalPassScollView:updateRoyalPassUI(nIndex, infoIndex)
	local info = self.royalPassPrizeInfos[nIndex][infoIndex]

	local lockContainer = info.lockContainer
	local prizeContainer = info.prizeContainer
	local getContainer = info.getContainer
	local noPrizeContainer = info.noPrizeContainer
	local btn = info.btn

	local prizeInfo = RoyalPassConfig:GetRoyalPassLevelPrize(nIndex+1)
	local prize = prizeInfo[infoIndex] --暂时只取第一个奖励（有的level有两个奖励）{nType = RoyalPassConfig.PrizeType.Coins, nMultiplier = 30}

	local bNoPrize = prize.nType == RoyalPassConfig.PrizeType.None
	noPrizeContainer.gameObject:SetActive(bNoPrize)
	prizeContainer.gameObject:SetActive(not bNoPrize)

	local bIsLock = nIndex > RoyalPassHandler.m_nLevel
	if not RoyalPassDbHandler.data.m_bIsPurchase then
		bIsLock = true
	end

	if bNoPrize then
		lockContainer.gameObject:SetActive(false)
	else
		lockContainer.gameObject:SetActive(bIsLock)
	end

	if not bIsLock then
		local bGet = RoyalPassHandler:getRoyalPassGet(nIndex + 1, infoIndex)
		if bNoPrize then
			btn.interactable = false
			getContainer.gameObject:SetActive(false)
		else
			getContainer.gameObject:SetActive(bGet)
			btn.interactable = not bGet
		end
	else
		btn.interactable = not bIsLock
		getContainer.gameObject:SetActive(false)
	end
	self:updateSendPrizeUI(prizeContainer, prize, bNoPrize)
end

function RoyalPassScollView:initLevelInfoItem(nIndex, item)
	local passLevelText = self:FindSymbolElement(item, "PassLevelText")
	passLevelText.text = nIndex
	self.levelInfos[nIndex] = item
	local goLv = self:FindSymbolElement(self.levelInfos[nIndex], "ImageLv")
	goLv:SetActive(nIndex <= RoyalPassHandler.m_nLevel)
	if nIndex == RoyalPassHandler.m_nLevel then
		local progressBar = self:FindSymbolElement(self.scrollContent, "LevelProgress"):GetComponent(typeof(Unity.RectTransform))
		progressBar.sizeDelta = Unity.Vector2( self.levelInfos[nIndex].anchoredPosition.x - 100 , 28)
	end
end

function RoyalPassScollView:UpdateAllItem()
	if not self.bInit then
		return
	end

	for i = 0, 100 do
		local prizeInfo = RoyalPassConfig:GetFreePassLevelPrize(i+1)
		local nLength = LuaHelper.tableSize(prizeInfo)
		if nLength > 1 then
			for j = 1, nLength do
				if j == 1 then
					self:updateFreePassUI(i, j)
					self:updateRoyalPassUI(i, j)
				else
					self:updateFreePassLimitedUI(i)
					self:updateRoyalPassLimitedUI(i)
				end
			end
		else
			self:updateFreePassUI(i, 1)
			self:updateRoyalPassUI(i, 1)
		end
		local goLv = self:FindSymbolElement(self.levelInfos[i], "ImageLv")
		goLv:SetActive(i <= RoyalPassHandler.m_nLevel)
	end
	local progressBar = self:FindSymbolElement(self.scrollContent, "LevelProgress"):GetComponent(typeof(Unity.RectTransform))
	progressBar.sizeDelta = Unity.Vector2( self.levelInfos[RoyalPassHandler.m_nLevel].anchoredPosition.x - 100 , 28)
	self:updateMissionChestUI()
	self:updateDiamondContainerUI()
	MissionMainUIPop:UpdateCountUI()
	self:hideAllTipGo()
	if self.m_goLevelRoyal100TiShi.activeSelf then
		self.m_goLevelRoyal100TiShi:SetActive(false)
	end
end

function RoyalPassScollView:updateDiamondContainerUI()
	if RoyalPassHandler.m_nLevel >= 100 then
		if self.m_trDiamondContainer.gameObject.activeSelf then
			self.m_trDiamondContainer.gameObject:SetActive(false)
		end
	else
		if not self.m_trDiamondContainer.gameObject.activeSelf then
			self.m_trDiamondContainer.gameObject:SetActive(true)
		end
		local count = RoyalPassConfig:GetCurrentUpgradeLevelNeedDiamond()
		self.m_trDiamondContainer.anchoredPosition = Unity.Vector2(self.levelInfos[RoyalPassHandler.m_nLevel + 1].anchoredPosition.x - 100, 0)
		local diamondCount = self:FindSymbolElement(self.m_trDiamondContainer, "DiamondCount")
		diamondCount.text = count
	end
end

function RoyalPassScollView:onDiamondBtnClick()
	GlobalAudioHandler:PlayBtnSound()
	local diamondCount = PlayerHandler.nSapphireCount
	local count = RoyalPassConfig:GetCurrentUpgradeLevelNeedDiamond()
	if diamondCount < count then
		BuyView:Show(BuyView.SHOP_VIEW_TYPE.GEMTYPE)
		return
	end

	UseGemCompleteNowUI:Show(count, function()
		PlayerHandler:AddSapphire(-count)
		local bIsUpgrade, bHasPrize = RoyalPassHandler:addStars(RoyalPassConfig:GetCurrentUpgradeLevelNeedStar())
		if bIsUpgrade then
            PopStackViewHandler:Show(RoyalPassLevelUpUI, bHasPrize)
			RoyalPassMainUI:updateUI()
		end
	end)
	
end

function RoyalPassScollView:OnDestroy()
    self.goSymbolElementPool = nil
	self.bInit = false
end

function RoyalPassScollView:FindSymbolElement(goSymbol, strKey, bSelf)
    if self.goSymbolElementPool == nil then
        self.goSymbolElementPool = {}
    end

    if self.goSymbolElementPool[goSymbol] == nil then
        self.goSymbolElementPool[goSymbol] = {}
    end     

    if self.goSymbolElementPool[goSymbol][strKey] == nil then
        local goTran = nil
        if bSelf then
            goTran = goSymbol.transform
        else
            goTran = goSymbol.transform:FindDeepChild(strKey)
        end

        if goTran then
            local go = goTran.gameObject

            if strKey == "CountText" or strKey == "PassLevelText" or strKey == "TextInfo" or strKey == "TextFreePass" or strKey == "TextRoyalPass" or strKey == "MorePercent" or strKey == "CoinsCount" or strKey == "VipCount" or strKey == "DiamondCount" then
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(TextMeshProUGUI))
            elseif strKey == "Text" or strKey == "TextLevel" then
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(UnityUI.Text))
            else
                self.goSymbolElementPool[goSymbol][strKey] = go
            end
        end

    end     
    
    return self.goSymbolElementPool[goSymbol][strKey]
end
--------------------Item相关--------------------
function RoyalPassScollView:initFreePassItem(nIndex, passItem, anchoredPositionX, anchoredPositionY)
	local lockContainer = passItem:FindDeepChild("Lock")
	local prizeContainer = passItem:FindDeepChild("Prize")
	local getContainer = passItem:FindDeepChild("DuiHao")
	local noPrizeContainer = passItem:FindDeepChild("NoPrize")

	local info = {}
	info.item = passItem
	info.lockContainer = lockContainer
	info.prizeContainer = prizeContainer
	info.getContainer = getContainer
	info.noPrizeContainer = noPrizeContainer
	info.visible = true

	info.anchoredPositionX = anchoredPositionX
	info.gameObject = passItem.gameObject
	
	if self.freePassPrizeInfos[nIndex] == nil then
		self.freePassPrizeInfos[nIndex] = {}
	end
	table.insert(self.freePassPrizeInfos[nIndex], info)
	
	local infoIndex = LuaHelper.indexOfTable(self.freePassPrizeInfos[nIndex], info)
	local btn = passItem:GetComponent(typeof(UnityUI.Button))
	DelegateCache:addOnClickButton(btn)
	btn.onClick:AddListener(function()
		self:onFreePassClicked(nIndex, infoIndex)
	end)
	info.btn = btn

	local lockbtn = lockContainer:GetComponent(typeof(UnityUI.Button))
	DelegateCache:addOnClickButton(lockbtn)
	local goLockContainer = lockContainer.gameObject
	lockbtn.onClick:AddListener(function()
		local animator = goLockContainer:GetComponentInChildren(typeof(Unity.Animator))
		animator:Play("Rotate", 0, 0)
		self:onFreePassLockClicked(nIndex, infoIndex)
	end)
	self:updateFreePassUI(nIndex, infoIndex)
end

function RoyalPassScollView:initFreePassLimitedItem(item, nIndex, passItem, anchoredPositionX, anchoredPositionY)
	local info = {}
	info.item = item
	info.passItem = passItem
	info.anchoredPositionX = anchoredPositionX
	info.gameObject = passItem.gameObject

	local lockContainer = passItem:FindDeepChild("Lock")
	local prizeContainer = passItem:FindDeepChild("Prize")
	local getContainer = passItem:FindDeepChild("DuiHao")
	local noPrizeContainer = passItem:FindDeepChild("NoPrize")

	info.lockContainer = lockContainer
	info.prizeContainer = prizeContainer
	info.getContainer = getContainer
	info.noPrizeContainer = noPrizeContainer

	local btn = passItem:GetComponent(typeof(UnityUI.Button))
	DelegateCache:addOnClickButton(btn)
	btn.onClick:AddListener(function()
		self:onFreePassClicked(nIndex, 2)
	end)
	info.btn = btn

	local lockbtn = lockContainer:GetComponent(typeof(UnityUI.Button))
	local goLockContainer = lockContainer.gameObject
	DelegateCache:addOnClickButton(lockbtn)
	lockbtn.onClick:AddListener(function()
		local animator = goLockContainer:GetComponentInChildren(typeof(Unity.Animator))
		animator:Play("Rotate", 0, 0)
		self:onFreePassLockClicked(nIndex, 2)
	end)
	self.freePassLimitedInfos[nIndex] = info
	self:updateFreePassLimitedUI(nIndex)

end

function RoyalPassScollView:initRoyalPassItem(nIndex, passItem, anchoredPositionX, anchoredPositionY)
	local lockContainer = passItem:FindDeepChild("Lock")
	local prizeContainer = passItem:FindDeepChild("Prize")
	local getContainer = passItem:FindDeepChild("DuiHao")
	local noPrizeContainer = passItem:FindDeepChild("NoPrize")
	
	local info = {}
	info.item = passItem
	info.lockContainer = lockContainer
	info.prizeContainer = prizeContainer
	info.getContainer = getContainer
	info.noPrizeContainer = noPrizeContainer
	info.anchoredPositionX = anchoredPositionX
	info.gameObject = passItem.gameObject

	if self.royalPassPrizeInfos[nIndex] == nil then
		self.royalPassPrizeInfos[nIndex] = {}
	end
	table.insert(self.royalPassPrizeInfos[nIndex], info)

	local infoIndex = LuaHelper.indexOfTable(self.royalPassPrizeInfos[nIndex], info)
	local btn = passItem:GetComponent(typeof(UnityUI.Button))
	DelegateCache:addOnClickButton(btn)
	btn.onClick:AddListener(function()
		self:onRoyalPassClicked(nIndex, infoIndex)
	end)
	info.btn = btn
	
	local lockbtn = lockContainer:GetComponent(typeof(UnityUI.Button))
	local goLockContainer = lockContainer.gameObject
	DelegateCache:addOnClickButton(lockbtn)
	lockbtn.onClick:AddListener(function()
		local animator = goLockContainer:GetComponentInChildren(typeof(Unity.Animator))
		animator:Play("Rotate", 0, 0)
		self:onRoyalPassLockClicked(nIndex, infoIndex)
	end)
	self:updateRoyalPassUI(nIndex, infoIndex)

end

function RoyalPassScollView:initRoyalPassLimitedItem(item, nIndex, passItem, anchoredPositionX, anchoredPositionY)
	local info = {}
	info.item = item
	info.passItem = passItem

	local lockContainer = passItem:FindDeepChild("Lock")
	local prizeContainer = passItem:FindDeepChild("Prize")
	local getContainer = passItem:FindDeepChild("DuiHao")
	local noPrizeContainer = passItem:FindDeepChild("NoPrize")

	info.lockContainer = lockContainer
	info.prizeContainer = prizeContainer
	info.getContainer = getContainer
	info.noPrizeContainer = noPrizeContainer

	local btn = passItem:GetComponent(typeof(UnityUI.Button))
	DelegateCache:addOnClickButton(btn)
	btn.onClick:AddListener(function()
		self:onRoyalPassClicked(nIndex, 2)
	end)
	info.btn = btn

	local lockbtn = lockContainer:GetComponent(typeof(UnityUI.Button))
	DelegateCache:addOnClickButton(lockbtn)
	local goLockContainer = lockContainer.gameObject
	lockbtn.onClick:AddListener(function()
		local animator = goLockContainer:GetComponentInChildren(typeof(Unity.Animator))
		animator:Play("Rotate", 0, 0)
		self:onRoyalPassLockClicked(nIndex, 2)
	end)

	self.royalPassLimitedInfos[nIndex] = info
	self:updateRoyalPassLimitedUI(nIndex)
end
--------------------Tip相关--------------------
function RoyalPassScollView:onFreePassLockClicked(nIndex, infoIndex)
	GlobalAudioHandler:PlayBtnSound()
	self:hideAllTipGo()
	self.goFreePassTip = self.goFreePassTipPool:GetItem()
	self.goFreePassTip:SetActive(true)
	local animator = self.goFreePassTip:GetComponentInChildren(typeof(Unity.Animator))
	animator:Play("Show", 0, 0)

	local prizeInfo = RoyalPassConfig:GetFreePassLevelPrize(nIndex + 1)
    local prize = prizeInfo[infoIndex]
	self.goFreePassTip:GetComponentInChildren(typeof(TextMeshProUGUI)).text = self:getPrizeIntroduceStr(prize)

	local item 
	if infoIndex == 2 then
		item = self.freePassLimitedInfos[nIndex].passItem
	else
		item = self.freePassPrizeInfos[nIndex][infoIndex].item
	end
	self.goFreePassTip.transform.position = item.transform.position
	self.goFreePassTip.transform:SetAsLastSibling()
end

function RoyalPassScollView:onRoyalPassLockClicked(nIndex, infoIndex)
	GlobalAudioHandler:PlayBtnSound()
	self:hideAllTipGo()
	self.goRoyalPassTip = self.goRoyalPassTipPool:GetItem()
	self.goRoyalPassTip:SetActive(true)
	local animator = self.goRoyalPassTip:GetComponentInChildren(typeof(Unity.Animator))
	animator:Play("Show", 0, 0)

	local prizeInfo = RoyalPassConfig:GetRoyalPassLevelPrize(nIndex + 1)
    local prize = prizeInfo[infoIndex]
	self.goRoyalPassTip:GetComponentInChildren(typeof(TextMeshProUGUI)).text = self:getPrizeIntroduceStr(prize)

	local item 
	if infoIndex == 2 then
		item = self.royalPassLimitedInfos[nIndex].passItem
	else
		item = self.royalPassPrizeInfos[nIndex][infoIndex].item
	end
	self.goRoyalPassTip.transform.position = item.transform.position
	self.goRoyalPassTip.transform:SetAsLastSibling()
end

function RoyalPassScollView:hideAllTipGo()
	if self.goFreePassTip then
		self.goFreePassTip:SetActive(false)
	end
	if self.goRoyalPassTip then
		self.goRoyalPassTip:SetActive(false)
	end
end