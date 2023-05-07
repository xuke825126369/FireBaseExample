
FlashChallengeRewardScollView = {}

function FlashChallengeRewardScollView:Init(parent)
	self.scrollContent = parent:FindDeepChild("RewardContent")
	self.nCurrentJackPotReward = 0 --运行时数据

	self.scrollRect = parent:FindDeepChild("RewardScrollView"):GetComponent(typeof(Unity.RectTransform))
	DelegateCache:addOnClickButton(FlashChallengeUI.btnLeft)
	FlashChallengeUI.btnLeft.onClick:AddListener(function()
		GlobalAudioHandler:PlayBtnSound()
		self:onBtnToLeftLevelClicked()
	end)
	DelegateCache:addOnClickButton(FlashChallengeUI.btnRight)
	FlashChallengeUI.btnRight.onClick:AddListener(function()
		GlobalAudioHandler:PlayBtnSound()
		self:onBtnToRightLevelClicked()
	end)

	local scrollRect = self.scrollContent.parent:GetComponent(typeof(UnityUI.ScrollRect))
	DelegateCache:addOnValueChanged(scrollRect)
	scrollRect.onValueChanged:AddListener(function(value)
		-- FlashChallengeUI.btnLeft
		-- FlashChallengeUI.btnRight
		local nCurrentIndex = FlashChallengeRewardConfig:GetCurrentRewardIndex()
		if nCurrentIndex == 0 then
			nCurrentIndex = 1
		end
		if math.abs(self.scrollRect.position.x - self.mapRewardsInfos[nCurrentIndex].item.position.x) > self.scrollRect.sizeDelta.x/2 then
			if (self.scrollRect.position.x - self.mapRewardsInfos[nCurrentIndex].item.position.x) > 0 then
				-- Debug.Log("左边！！！！！！")
				if not FlashChallengeUI.btnLeft.gameObject.activeSelf then
					FlashChallengeUI.btnLeft.gameObject:SetActive(true)
				end
			else
				-- Debug.Log("右边！！！！！！")
				if FlashChallengeUI.btnLeft.gameObject.activeSelf then
					FlashChallengeUI.btnLeft.gameObject:SetActive(false)
				end
			end
		else
			if FlashChallengeUI.btnLeft.gameObject.activeSelf then
				FlashChallengeUI.btnLeft.gameObject:SetActive(false)
			end
		end
		if math.abs(self.scrollRect.position.x - self.leaderBoard.position.x) > self.scrollRect.sizeDelta.x/2 then
			if not FlashChallengeUI.btnRight.gameObject.activeSelf then
				FlashChallengeUI.btnRight.gameObject:SetActive(true)
			end
		else
			if FlashChallengeUI.btnRight.gameObject.activeSelf then
				FlashChallengeUI.btnRight.gameObject:SetActive(false)
			end
		end
	end)
	
	self:initItemContent()
	LuaAutoBindMonoBehaviour.Bind(self.scrollContent.gameObject, self)
	EventHandler:AddListener(self, "onNetTimeNotificationCallback")
end

function FlashChallengeRewardScollView:initItemContent()
	local rewardPrefab = AssetBundleHandler:LoadMissionAsset("Missions/FlashChallenge/RewardNode.prefab")
	local levelInfoItemPrefab = AssetBundleHandler:LoadMissionAsset("Missions/FlashChallenge/LevelInfoItem.prefab")
	self.mapRewardsInfos = {}

	local lastPosX = 0

	local nIndex = 1
	for i = 1, LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards) do
		local go = Unity.Object.Instantiate(levelInfoItemPrefab)
		local trItem = go:GetComponent(typeof(Unity.RectTransform))
		trItem:SetParent(self.scrollContent, false)
		local offset = i == 1 and 70 or 235
		trItem.anchoredPosition3D = Unity.Vector3(lastPosX + offset, 0, 0)
		lastPosX = trItem.anchoredPosition.x
		local levelText = self:FindSymbolElement(go, "TextLevel")
		levelText.text = i

        for j = 1, LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards[i]) do
            local go = Unity.Object.Instantiate(rewardPrefab)
			local trItem = go:GetComponent(typeof(Unity.RectTransform))
			trItem:SetParent(self.scrollContent, false)
			local width = j == 1 and 240 or 320
			trItem.anchoredPosition3D = Unity.Vector3(lastPosX + width, 0, 0)
			
			self:initRewardItem(nIndex, trItem)
			
			lastPosX = trItem.anchoredPosition.x
			
            nIndex = nIndex + 1
		end
	end

	local go = Unity.Object.Instantiate(levelInfoItemPrefab)
	local trItem = go:GetComponent(typeof(Unity.RectTransform))
	trItem:SetParent(self.scrollContent, false)
	local offset = 235
	trItem.anchoredPosition3D = Unity.Vector3(lastPosX + offset, 0, 0)
	lastPosX = trItem.anchoredPosition.x
	local levelText = self:FindSymbolElement(go, "TextLevel")
	levelText.text = 6

	--TODO 最后一个奖励
	local rewardPrefab = AssetBundleHandler:LoadMissionAsset("Missions/FlashChallenge/Leaderboards.prefab")
	self.leaderBoard = Unity.Object.Instantiate(rewardPrefab):GetComponent(typeof(Unity.RectTransform))
	self.leaderBoard:SetParent(self.scrollContent, false)
	self.leaderBoard.anchoredPosition3D = Unity.Vector3(lastPosX + 500, 0, 0)
	lastPosX = self.leaderBoard.anchoredPosition.x
	self.playBtn = self:FindSymbolElement(self.leaderBoard, "ButPlay")
	self.playBtn.onClick:RemoveAllListeners()
	DelegateCache:addOnClickButton(self.playBtn)
	self.playBtn.onClick:AddListener(function()
		self:onFlashChallengePlayClicked("FlashChallengeGame")
	end)

	self:updateLeaderBoardUI()
	self.scrollContent.sizeDelta = Unity.Vector2(lastPosX + 500, self.scrollContent.sizeDelta.y)
end

FlashChallengeRewardScollView.fLastUpdateTime = 0
function FlashChallengeRewardScollView:Update()
	if Unity.Time.time - self.fLastUpdateTime > 1.0 then
		self.fLastUpdateTime = Unity.Time.time
		if FlashChallengeRewardDataHandler.m_nLevel >= 6 then
			self.nCurrentJackPotReward = FlashChallengeRewardDataHandler:getCurrentJackpotReward()
			local jackpotText = self:FindSymbolElement(self.leaderBoard, "TextJinBi")

			if(self.coinNumTween and self.coinNumTween.isTweening) then
				NumberTween:cancel(self.coinNumTween)
				self.coinNumTween = nil
			end
			self.coinNumTween = NumberTween:value(self.nCurrentJackPotReward, FlashChallengeRewardDataHandler:getCurrentJackpotReward(), 1):setOnUpdate(function(value) 
				self.nCurrentJackPotReward = value
				jackpotText.text = MoneyFormatHelper.numWithCommas(self.nCurrentJackPotReward)
			end):setOnComplete(function()
				self.coinNumTween = nil
			end)

			local bFlag = FlashChallengeRewardDataHandler:checkCouldPlayJackpotGame()
			local playHuiGo = self:FindSymbolElement(self.leaderBoard, "PlayHui")
			if bFlag then
				-- 可以玩小游戏
				if not self.playBtn.gameObject.activeSelf then
					self.playBtn.gameObject:SetActive(true)
				end
				if playHuiGo.activeSelf then
					playHuiGo:SetActive(false)
				end
			else
				-- 倒计时
				if self.playBtn.gameObject.activeSelf then
					self.playBtn.gameObject:SetActive(false)
				end
				if not playHuiGo.activeSelf then
					playHuiGo:SetActive(true)
				end
				local leftTimeText = self:FindSymbolElement(self.leaderBoard, "TimeLeft")
	
				local playTime = FlashChallengeRewardDataHandler:getPlayJackpotTime()
				local currentTime = TimeHandler:GetServerTimeStamp()
	
				local timediff = playTime - currentTime
	
				local days = timediff // (3600*24)
				local hours = timediff // 3600 - 24 * days
				local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
				local seconds = timediff % 60
				
				local strTimeInfo = ""
				if days > 0 then
					strTimeInfo = string.format("%d DAYS!", days)
				else
					strTimeInfo = string.format("%02d:%02d:%02d", hours, minutes, seconds)
				end
	
				leftTimeText.text = "NEXT PLAY "..strTimeInfo
			end
		end
	end
end

function FlashChallengeRewardScollView:updateLeaderBoardUI()
	local jackpotText = self:FindSymbolElement(self.leaderBoard, "TextJinBi")
	local base = FlashChallengeRewardDataHandler:getBasePrize()
	self.nCurrentJackPotReward = base * FlashChallengeRewardConfig.N_MIN_RATIO
	jackpotText.text = MoneyFormatHelper.numWithCommas(self.nCurrentJackPotReward)
	local playHuiGo = self:FindSymbolElement(self.leaderBoard, "PlayHui")
	if FlashChallengeRewardDataHandler.m_nLevel >= 6 then
		local bFlag = FlashChallengeRewardDataHandler:checkCouldPlayJackpotGame()
		self.playBtn.gameObject:SetActive(bFlag)
		if self.playBtn.gameObject.activeSelf and bFlag then
			self.playBtn.interactable = false
		else
			self.playBtn.interactable = true
		end

		playHuiGo:SetActive(not bFlag)
		
		local nMultipiler, resultCount = FlashChallengeRewardDataHandler:getCurrentMultipiler()
		local progress = self:FindSymbolElement(self.leaderBoard, "ProgressImg")
		progress.fillAmount = resultCount / FlashChallengeRewardConfig:GetFlashChallengeMultiplierLevelNeedFireCount(nMultipiler)
		local text1 = self:FindSymbolElement(self.leaderBoard, "MultiplierText1")
		text1.text = "x"..nMultipiler
		local text2 = self:FindSymbolElement(self.leaderBoard, "MultiplierText2")
		text2.text = "x"..(nMultipiler + 1)
		local progressText = self:FindSymbolElement(self.leaderBoard, "TextShuZi")
		progressText.text = resultCount.."/"..FlashChallengeRewardConfig:GetFlashChallengeMultiplierLevelNeedFireCount(nMultipiler).." l"
	else
		self.playBtn.gameObject:SetActive(false)
		playHuiGo:SetActive(false)

		local progress = self:FindSymbolElement(self.leaderBoard, "ProgressImg")
		progress.fillAmount = 0
		local text1 = self:FindSymbolElement(self.leaderBoard, "MultiplierText1")
		text1.text = "x1"
		local text2 = self:FindSymbolElement(self.leaderBoard, "MultiplierText2")
		text2.text = "x2"
		local progressText = self:FindSymbolElement(self.leaderBoard, "TextShuZi")
		progressText.text = "0/"..FlashChallengeRewardConfig:GetFlashChallengeMultiplierLevelNeedFireCount(1).." l"
	end
end

function FlashChallengeRewardScollView:onFlashChallengePlayClicked(themeKey)
	MissionMainUIPop:showLoading()
	GlobalAudioHandler:PlayBtnSound()
	NetHandler:fetchNetTime( {forFlashChallengeGame = true, themeKey = themeKey})
end

function FlashChallengeRewardScollView:onNetTimeNotificationCallback(data)
    if not data.forFlashChallengeGame then
		return
	end
	
	MissionMainUIPop:hideLoading()
	if data.time == nil then
		-- 网络超时 或没有取到时间..
		Debug.Log("-----data.time == nil----")
		return
	end

	local netTime = LuaUtil.parseNetUtcDate(data.time)

	-- 加载FlashChallengeGame关卡
	local nLastTime = FlashChallengeRewardDataHandler:getLastNetPlayJackPotTime()
	if netTime - nLastTime >= FlashChallengeRewardConfig.N_NEXT_PLAY_TIME then
		FlashChallengeRewardDataHandler:setPlayJackpotTime(netTime)
		MissionMainUIPop:Hide()
		Scene:loadFlashChallengeGame(data.themeKey)
	end

end

function FlashChallengeRewardScollView:ShowToInitPos()
    self.scrollRect.gameObject:SetActive(true)
	local nCurrentIndex = FlashChallengeRewardConfig:GetCurrentRewardIndex()
	if nCurrentIndex == 0 then
		nCurrentIndex = 1
	end
	for i = 1, nCurrentIndex do
		local bGet = FlashChallengeRewardDataHandler:getRewardGet(i)
		if not bGet then
			self.moveId = LeanTween.moveLocalX(self.scrollContent.gameObject, -self.mapRewardsInfos[i].item.anchoredPosition.x - self.scrollRect.sizeDelta.x/3, 0.5).id
			break
		end
	end
end

function FlashChallengeRewardScollView:onBtnToRightLevelClicked()
	local nCurrentIndex = FlashChallengeRewardConfig:GetCurrentRewardIndex()
	if nCurrentIndex == 0 then
		nCurrentIndex = 1
	end
	if math.abs(self.scrollRect.position.x - self.mapRewardsInfos[nCurrentIndex].item.position.x) > self.scrollRect.sizeDelta.x/2 then
		if (self.scrollRect.position.x - self.mapRewardsInfos[nCurrentIndex].item.position.x) > 0 then
			if self.moveId ~= nil and LeanTween.isTweening(self.moveId) then
				LeanTween.cancel(self.moveId)
			end
			self.moveId = LeanTween.moveLocalX(self.scrollContent.gameObject, -self.leaderBoard.anchoredPosition.x - self.scrollRect.sizeDelta.x/3, 0.5).id
		else
			self.moveId = LeanTween.moveLocalX(self.scrollContent.gameObject, -self.mapRewardsInfos[nCurrentIndex].item.anchoredPosition.x - self.scrollRect.sizeDelta.x/3, 0.5).id
		end
	else
		if self.moveId ~= nil and LeanTween.isTweening(self.moveId) then
			LeanTween.cancel(self.moveId)
		end
		self.moveId = LeanTween.moveLocalX(self.scrollContent.gameObject, -self.leaderBoard.anchoredPosition.x - self.scrollRect.sizeDelta.x/3, 0.5).id
	end
end

function FlashChallengeRewardScollView:onBtnToLeftLevelClicked()
	local nCurrentIndex = FlashChallengeRewardConfig:GetCurrentRewardIndex()
	if nCurrentIndex == 0 then
		nCurrentIndex = 1
	end
	if self.moveId ~= nil and LeanTween.isTweening(self.moveId) then
		LeanTween.cancel(self.moveId)
	end
	self.moveId = LeanTween.moveLocalX(self.scrollContent.gameObject, -self.mapRewardsInfos[nCurrentIndex].item.anchoredPosition.x - self.scrollRect.sizeDelta.x/3, 0.5).id
end

function FlashChallengeRewardScollView:initRewardItem(nIndex, trItem)
	local lockContainer = trItem:FindDeepChild("Suo")
	local prizeTopContainer = trItem:FindDeepChild("PrizeTopContainer")
	local prizeBottomContainer = trItem:FindDeepChild("PrizeBottomContainer")
	local getContainer = trItem:FindDeepChild("DoneHei")
	local btnCollect = trItem:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
	local goNoCollect = trItem:FindDeepChild("CollectHui").gameObject
	local textFireCount = trItem:FindDeepChild("TextFireCount"):GetComponent(typeof(UnityUI.Text))

	local info = {}
	info.item = trItem
	info.lockContainer = lockContainer
	info.prizeTopContainer = prizeTopContainer
	info.prizeBottomContainer = prizeBottomContainer
	info.getContainer = getContainer
	info.textFireCount = textFireCount

	self.mapRewardsInfos[nIndex] = info
	DelegateCache:addOnClickButton(btnCollect)
	btnCollect.onClick:AddListener(function()
		self:onRewardCollectClicked(nIndex)
	end)
	info.btn = btnCollect
	info.goNoCollect = goNoCollect

	self:updateRewardCollectUI(nIndex)
end

function FlashChallengeRewardScollView:onRewardCollectClicked(nIndex)
	GlobalAudioHandler:PlayBtnSound()
	-- TODO 更新数据库， 以获取该奖励
	FlashChallengeRewardDataHandler:setRewardGet(nIndex)
	local item = self.mapRewardsInfos[nIndex].item
	
	self:updateRewardCollectUI(nIndex)

	local prize = FlashChallengeRewardConfig:GetRewardPrize(nIndex)
	if prize.nType == FlashChallengeRewardConfig.PrizeType.PickBonus then
		-- TODO 进入PickBonus
		PickBonusMainUIPop:Show()
	elseif prize.nType == FlashChallengeRewardConfig.PrizeType.Coins then
		CoinFly:fly(self.mapRewardsInfos[nIndex].btn.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 6, true)
	end
	FlashChallengeUI:UpdateRewardCount() --更新还有多少奖励没有领取的UI
	MissionMainUIPop:UpdateCountUI() --更新还有多少奖励没有领取的UI
end

function FlashChallengeRewardScollView:updateRewardCollectUI(nIndex)
	local info = self.mapRewardsInfos[nIndex]

	local lockContainer = info.lockContainer
	local prizeTopContainer = info.prizeTopContainer
	local prizeBottomContainer = info.prizeBottomContainer
	local getContainer = info.getContainer
	local btn = info.btn
	local textFireCount = info.textFireCount
	local goNoCollect = info.goNoCollect

	local prize = FlashChallengeRewardConfig:GetRewardPrize(nIndex)

	local bIsLock = nIndex > FlashChallengeRewardConfig:GetCurrentRewardIndex()
	lockContainer.gameObject:SetActive(bIsLock)
	prizeTopContainer.gameObject:SetActive(not bIsLock)

	if bIsLock then
		goNoCollect:SetActive(true)
		btn.interactable = false
		getContainer.gameObject:SetActive(false)
	else
		local bGet = FlashChallengeRewardDataHandler:getRewardGet(nIndex)
		getContainer.gameObject:SetActive(bGet)
		btn.interactable = not bGet
		goNoCollect:SetActive(bGet)
	end
	if prizeTopContainer.gameObject.activeSelf then
		local coins = self:FindSymbolElement(prizeTopContainer, "Coins")
		coins:SetActive(true)
	end

	local coins = self:FindSymbolElement(prizeBottomContainer, "Coins")
	coins:SetActive(prize.nType == FlashChallengeRewardConfig.PrizeType.Coins)

	local pickBonus = self:FindSymbolElement(prizeBottomContainer, "PickBonus")
	pickBonus:SetActive(prize.nType == FlashChallengeRewardConfig.PrizeType.PickBonus)

	if prize.nType == FlashChallengeRewardConfig.PrizeType.Coins then
		local coinsText = self:FindSymbolElement(coins, "TextCoins")
		coinsText.text = MoneyFormatHelper.coinCountOmit(prize.nMultiplier * FlashChallengeRewardDataHandler:getBasePrize())
	elseif prize.nType == FlashChallengeRewardConfig.PrizeType.PickBonus then
		local pickCountText = self:FindSymbolElement(pickBonus, "TextPickCount")
		pickCountText.text = prize.nPickCount
		local goSuperPickLogo = self:FindSymbolElement(pickBonus, "SuperPickLogo")
		local goPickLogo = self:FindSymbolElement(pickBonus, "PickLogo")
		goSuperPickLogo:SetActive(prize.nReduceCount > 0)
		goPickLogo:SetActive(prize.nReduceCount <= 0)
		
		local bFlag = false
		if btn.interactable and bFlag then
			btn.interactable = false
		else
			btn.interactable = true
		end
	end

	textFireCount.text = tostring(prize.nFireCount) .. "F"
end

function FlashChallengeRewardScollView:UpdateAllItem()
	local nIndex = 1
	for i = 1, LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards) do
        for j = 1, LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards[i]) do
			self:updateRewardCollectUI(nIndex)
            nIndex = nIndex + 1
		end
	end
	self:updateLeaderBoardUI()
end

function FlashChallengeRewardScollView:OnDestroy()
	self.goSymbolElementPool = nil
	self.leaderBoard = nil
	self.co = nil
end

function FlashChallengeRewardScollView:FindSymbolElement(goSymbol, strKey, bSelf)
    if not GameConfig.RELEASE_VERSION then
		local tablePoolKey = { "Coins", "TextCoins", "PickBonus", "TextPickCount", "TextLevel", "ButPlay", "TextJinBi", "TimeLeft", "PlayHui", "ProgressImg", "MultiplierText1", "MultiplierText2", "TextShuZi", "SuperPickLogo", "PickLogo" }
        Debug.Assert(LuaHelper.tableContainsElement(tablePoolKey, strKey))
    end

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

            if strKey == "TextCoins" or strKey == "TextPickCount" or strKey == "TextLevel" or strKey == "TextJinBi" or strKey == "MultiplierText1" or strKey == "MultiplierText2" or strKey == "TextShuZi" then
				self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(UnityUI.Text))
			elseif strKey == "TimeLeft" then
				self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(TextMeshProUGUI))
			elseif strKey == "ButPlay" then
				self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(UnityUI.Button))
			elseif strKey == "ProgressImg" then
				self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(UnityUI.Image))
            else
                self.goSymbolElementPool[goSymbol][strKey] = go
            end
        end

    end     
    
    return self.goSymbolElementPool[goSymbol][strKey]
end