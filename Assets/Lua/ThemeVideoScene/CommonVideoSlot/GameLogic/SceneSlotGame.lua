local SceneSlotGame = {}

function SceneSlotGame:InitVariable()
	self.m_fCurSpinWinCoins = 0
	self.m_bUIState = false
	self.m_bFreeSpinRetrigger = false
	self.m_bFeatureEffectPlaying = false
	self.m_listLeanTweenIDs = {}
	self.m_LevelUiTableParam = {}
end

function SceneSlotGame:Init() -- 对GameUI的初始化
	self:InitVariable()

	self.m_transform = ThemeVideoScene.mTopBottomUIParent:FindDeepChild("UIBottom")
	LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

	self.m_btnAddBet = self.m_transform:FindDeepChild("ButtonBetAdd"):GetComponent(typeof(UnityUI.Button))
	self.m_btnAddBet.onClick:AddListener(function()
		self:OnButtonAddBet()
	end)

	self.m_btnSubBet = self.m_transform:FindDeepChild("ButtonBetSub"):GetComponent(typeof(UnityUI.Button))
	self.m_btnSubBet.onClick:AddListener(function()
		self:OnButtonSubBet()
	end)

	self.m_btnMaxBet = self.m_transform:FindDeepChild("ButtonMaxBET"):GetComponent(typeof(UnityUI.Button))
	self.m_btnMaxBet.onClick:AddListener(function()
		self:OnButtonMaxBet()
	end)

	self.m_btnSpin = self.m_transform:FindDeepChild("ButtonSpin"):GetComponent(typeof(UnityUI.Button))

	self.m_btnPayTable = self.m_transform:FindDeepChild("Buttonpaytable"):GetComponent(typeof(UnityUI.Button))
	if self.m_btnPayTable then
		self.m_btnPayTable.onClick:AddListener(function()
			self:OnButtonPayTable()
		end)
	end	

	self.m_btnLobby = UITop.m_btnLobby

	local trLamp0 = self.m_transform:FindDeepChild("Lamp0")
	local trLamp1 = self.m_transform:FindDeepChild("Lamp1")
	if trLamp0 ~= nil then
		self.m_imageBtnMaxBetLamp0 = trLamp0.gameObject:GetComponent(typeof(UnityUI.Image))
	end

	if trLamp1 ~= nil then
		self.m_imageBtnMaxBetLamp1 = trLamp1.gameObject:GetComponent(typeof(UnityUI.Image))
	end	

	local trMaxbetUpgrade = self.m_transform:FindDeepChild("MaxbetUpgrade") -- 押注等级提升了。。
	if trMaxbetUpgrade ~= nil then
		self.m_goMaxBetUpgradeTip = trMaxbetUpgrade.gameObject
		self.m_goMaxBetUpgradeTip:SetActive(false)
	end

	self.m_textTotalBet = self.m_transform:FindDeepChild("ValueTotalBet"):GetComponent(typeof(TextMeshProUGUI))
	self.m_textTotalWinValue = self.m_transform:FindDeepChild("ValueTotalWin"):GetComponent(typeof(TextMeshProUGUI))
	self.m_textTotalWinTip = self.m_transform:FindDeepChild("TextMeshProTotalWin"):GetComponent(typeof(TextMeshProUGUI))
	self.m_textAutoSpinNum = self.m_transform:FindDeepChild("ValueAutoSpinNum"):GetComponent(typeof(TextMeshProUGUI))

	local trRespinTip = self.m_transform:FindDeepChild("ReSpinTip")
	if trRespinTip ~= nil then
		self.m_textReSpinTip = trRespinTip:GetComponent(typeof(TextMeshProUGUI))
		self.m_textReSpinTip.text = ""
	end
	
	self.m_goFreeSpin = self.m_transform:FindDeepChild("LeftFreeSpin").gameObject -- 非respin状态下要隐藏的
	self.m_goFreeSpin:SetActive(false)

	self.m_textFreeSpinWinTipInfo = self.m_transform:FindDeepChild("TextMeshProFreeSpinWinTip"):GetComponent(typeof(TextMeshProUGUI))
	self.m_textFreeSpinNumInfo = self.m_transform:FindDeepChild("ValueFreeSpinNum"):GetComponent(typeof(TextMeshProUGUI))
	self.m_textFreeSpinTitleInfo = self.m_transform:FindDeepChild("ImageFreeSpinNum/Image (3)"):GetComponent(typeof(TextMeshProUGUI))
	self.m_textFreeSpinTotalBetInfo = self.m_transform:FindDeepChild("ValueTotalBetFreeSpin"):GetComponent(typeof(TextMeshProUGUI))

	self.m_goBottomUILeftNormal = self.m_transform:FindDeepChild("LeftNormal").gameObject
	self.m_goBottomUILeftFreeSpin = self.m_transform:FindDeepChild("LeftFreeSpin").gameObject
	self.m_goBottomUILeftNormal:SetActive(true)
	self.m_goBottomUILeftFreeSpin:SetActive(false)

	self.m_SlotsNumberWins = SlotsNumber:create("", 0, 100000000000, 0, 2)
	self.m_SlotsNumberWins:AddUIText(self.m_textTotalWinValue)
	self.m_SlotsNumberWins:SetTimeEndFlag(true)
	self.m_SlotsNumberWins:ChangeTo(0)

	self:InitTotalBet()
	self:initBtnStatus()
	self:InitCommonUI()
	self:RequireLevelLuaRes()

	self:initLevelUI() -- 先初始化UI
	SlotsGameLua:Init() -- 逻辑相关信息 比如可能需要直接开启freespin等。。就需要ui展示
	EffectCache:CreateEffectCache()
end

function SceneSlotGame:InitTotalBet()
	self.m_nTotalBet = ThemeHelper:GetInitTotalBet()
    self.m_textTotalBet.text = MoneyFormatHelper.numWithCommas(self.m_nTotalBet)
end

function SceneSlotGame:initBtnStatus()
	local nTotalBet = self.m_nTotalBet
    local bFlag = GameLevelUtil:isMaxBet(nTotalBet)
    if bFlag then
        if self.m_btnMaxBet.interactable then
            self.m_btnMaxBet.interactable = false
			if self.m_imageBtnMaxBetLamp0 ~= nil then
            	self.m_imageBtnMaxBetLamp0.overrideSprite = self.m_imageBtnMaxBetLamp1.sprite
			end
        end
    else
        if not self.m_btnMaxBet.interactable then
            self.m_btnMaxBet.interactable = true
			if self.m_imageBtnMaxBetLamp0 ~= nil then
            	self.m_imageBtnMaxBetLamp0.overrideSprite = nil
			end
        end
    end

	SpinButton:Init()
end

function SceneSlotGame:RequireLevelLuaRes()
	local strKey = ThemeLoader.themeKey.."Func"
	require("Lua/ThemeVideo/"..ThemeLoader.themeKey.."/"..strKey)
	_G[strKey]:initSlotsGameParam()
end	

function SceneSlotGame:InitCommonUI()
	self.m_goFreeSpinBackground = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("Freebg")
	if self.m_goFreeSpinBackground ~= nil then
		self.m_goFreeSpinBackground = self.m_goFreeSpinBackground.gameObject
		self.m_goFreeSpinBackground:SetActive(false)
	end

	self.m_goNormalReelBackground = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("Normalbg")
	if self.m_goNormalReelBackground ~= nil then
		self.m_goNormalReelBackground = self.m_goNormalReelBackground.gameObject
		self.m_goNormalReelBackground:SetActive(true)
	end

	self:loadPayTable()
	self:loadUISplash()
	self:hideAllPopPanelGameObj()
	math.randomseed(os.time())
end

function SceneSlotGame:initLevelUI()
	local strLevelName = ThemeLoader.themeKey

	if self.m_LevelUiTableParam ~= nil then
		self.m_LevelUiTableParam:initLevelUI()
		return
	end
end

function SceneSlotGame:loadPayTable()
	UIPayTable:Init()
end

function SceneSlotGame:loadUISplash()
	local strBigWinFullName = "Assets/ResourceABs/ThemeVideoCommon/InGame/BigWin.prefab"
	local strMegaWinFullName = "Assets/ResourceABs/ThemeVideoCommon/InGame/MegaWin.prefab"
	local strEpicWinFullName = "Assets/ResourceABs/ThemeVideoCommon/InGame/EpicWin.prefab"
	local str5ofKindFullName = "Assets/ResourceABs/ThemeVideoCommon/InGame/FiveOfKind.prefab"
	local str6ofKindFullName = "Assets/ResourceABs/ThemeVideoCommon/InGame/SixOfKind.prefab"

	local bundleName = "ThemeVideoCommon"

	local goPrfabBigWin = AssetBundleHandler:LoadAsset(bundleName, strBigWinFullName)
	local goBigWin = Unity.Object.Instantiate(goPrfabBigWin)
	goBigWin.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
	goBigWin.name = "BigWin"
	self.m_uiSplashBigWin = UISplash:create(goBigWin, SplashType.BigWin)
	goBigWin:SetActive(false)
		
	local goPrfabMegaWin = AssetBundleHandler:LoadAsset(bundleName, strMegaWinFullName)
	local goMegaWin = Unity.Object.Instantiate(goPrfabMegaWin)
	goMegaWin.transform:SetParent(ThemeVideoScene.mPopScreenCanvas,false)
	goMegaWin.name = "MegaWin"
	self.m_uiSplashMegaWin = UISplash:create(goMegaWin, SplashType.MegaWin)
	goMegaWin:SetActive(false)

	local goPrfabEpicWin = AssetBundleHandler:LoadAsset(bundleName, strEpicWinFullName)
	local goEpicWin = Unity.Object.Instantiate(goPrfabEpicWin)
	goEpicWin.transform:SetParent(ThemeVideoScene.mPopScreenCanvas,false)
	goEpicWin.name = "EpicWin"
	self.m_uiSplashEpicWin = UISplash:create(goEpicWin, SplashType.EpicWin)
	goEpicWin:SetActive(false)

	local strKindOfName = str5ofKindFullName
	local b6OfKindLevel = GameLevelUtil:isSixOfkind()
	if b6OfKindLevel then
		strKindOfName = str6ofKindFullName
	end

	local go5 = AssetBundleHandler:LoadAsset(bundleName, strKindOfName)
	local go5ofKind = Unity.Object.Instantiate(go5)
	go5ofKind.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
	go5ofKind.name = "FiveOfKind"
	self.m_uiSplash5ofKind = UISplash:create(go5ofKind, SplashType.FiveInRow)
	go5ofKind:SetActive(false)

	local strFreeSpinsBeginFullName = "FreeSpinsBegin.prefab"
	if AssetBundleHandler:ContainsThemeAsset(strFreeSpinsBeginFullName) then
		local freeSpinBeginObj = AssetBundleHandler:LoadThemeAsset(strFreeSpinsBeginFullName)
		if freeSpinBeginObj then
			local goFreeSpinBegin = Unity.Object.Instantiate(freeSpinBeginObj)
			goFreeSpinBegin.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
			goFreeSpinBegin.name = "FreeSpinBegin"
			self.m_uiSplashFreeSpinsBegin = UISplash:create(goFreeSpinBegin, SplashType.FreeSpin)
			goFreeSpinBegin:SetActive(false)
		end
	end

	local strFreeSpinsEndFullName = "FreeSpinsEnd.prefab"
	if AssetBundleHandler:ContainsThemeAsset(strFreeSpinsEndFullName) then
		local freeSpinEndObj = AssetBundleHandler:LoadThemeAsset(strFreeSpinsEndFullName)
		if freeSpinEndObj then
			local goFreeSpinEnd = Unity.Object.Instantiate(freeSpinEndObj)
			goFreeSpinEnd.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
			goFreeSpinEnd.name = "FreeSpinEnd"
			self.m_uiSplashFreeSpinsEnd= UISplash:create(goFreeSpinEnd, SplashType.FreeSpinEnd)
			goFreeSpinEnd:SetActive(false)
		end
	end
	
	local strFreeSpinAgainFullName = "FreeSpinsAgain.prefab"
	if AssetBundleHandler:ContainsThemeAsset(strFreeSpinAgainFullName) then
		local freeSpinAgainObj = AssetBundleHandler:LoadThemeAsset(strFreeSpinAgainFullName)
		if freeSpinAgainObj then
			local goFreeSpinAgain = Unity.Object.Instantiate(freeSpinAgainObj)
			goFreeSpinAgain.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
			goFreeSpinAgain.name = "FreeSpinAgain"
			self.m_uiSplashFreeSpinsAgain = UISplash:create(goFreeSpinAgain, SplashType.FreeSpin)
			goFreeSpinAgain:SetActive(false)
		end
	end

	local strBonusGameBeginFullName = "BonusGameBegin.prefab"
	if AssetBundleHandler:ContainsThemeAsset(strBonusGameBeginFullName) then
		local bonusGameBeginObj = AssetBundleHandler:LoadThemeAsset(strBonusGameBeginFullName)
		if bonusGameBeginObj then
			local goBonusGameBegin = Unity.Object.Instantiate(bonusGameBeginObj)
			goBonusGameBegin.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
			goBonusGameBegin.name = "BonusGameBegin"
			self.m_uiSplashBonusGameBegin = UISplash:create(goBonusGameBegin, SplashType.Bonus)
			goBonusGameBegin:SetActive(false)
		end
	end	
	
	local strBonusGameEndFullName = "BonusGameEnd.prefab"
	if AssetBundleHandler:ContainsThemeAsset(strBonusGameEndFullName) then
		local bonusGameEndObj = AssetBundleHandler:LoadThemeAsset(strBonusGameEndFullName)
		if bonusGameEndObj then
			local goBonusGameEnd = Unity.Object.Instantiate(bonusGameEndObj)
			goBonusGameEnd.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
			goBonusGameEnd.name = "BonusGameEnd"
			self.m_uiSplashBonusGameEnd = UISplash:create(goBonusGameEnd, SplashType.BonusGameEnd)
			goBonusGameEnd:SetActive(false)
		end
	end

	if GameLevelUtil:isPortraitLevel() then
		local tableGo = {self.m_uiSplashBigWin, self.m_uiSplashMegaWin, self.m_uiSplashEpicWin}
		for i, v in pairs(tableGo) do
			local targetTran = v.m_goUISplash.transform:FindDeepChild("animation/GameObject")
			local OriScale = targetTran.localScale
			targetTran.localScale = Unity.Vector3(OriScale.x * 0.8, OriScale.y * 0.8, OriScale.z)
		end
	end
	
end

function SceneSlotGame:hideAllPopPanelGameObj()
	if self.m_uiSplashBigWin ~= nil then
		self.m_uiSplashBigWin.m_goUISplash:SetActive(false)
	end
	if self.m_uiSplashMegaWin ~= nil then
		self.m_uiSplashMegaWin.m_goUISplash:SetActive(false)
	end
	if self.m_uiSplash5ofKind ~= nil then
		self.m_uiSplash5ofKind.m_goUISplash:SetActive(false)
	end
end

function SceneSlotGame:RemoveBtnListener()
	self.m_btnAddBet.onClick:RemoveAllListeners()
	self.m_btnSubBet.onClick:RemoveAllListeners()
	self.m_btnMaxBet.onClick:RemoveAllListeners()
	self.m_btnPayTable.onClick:RemoveAllListeners()
end

function SceneSlotGame:reset()
	local count = #self.m_listLeanTweenIDs
	for i = 1, count do
		local id = self.m_listLeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_listLeanTweenIDs = {}

	PayLinePayWaysEffectHandler:reset()
	self.m_bPlayReelStopAudio = true
	
	self.m_bFeatureEffectPlaying = false -- alice  snowWhite 触发了FeatureEffect
	self.m_bUIState = false
	self.m_bInitCommonGameUI = false
	self.m_goMaxBetUpgradeTip = nil
	self.m_LevelUiTableParam = nil

	self.m_uiSplashBigWin = nil
	self.m_uiSplashMegaWin = nil
	self.m_uiSplash5ofKind = nil	
	ThemePlayData:Release()
end

function SceneSlotGame:SetAutoSpinBtn()
	AudioHandler:PlayAutoSpinBtnSound()
	SlotsGameLua.m_bAutoSpinFlag = true

	SpinButton.m_bSelAutoSpinNumFlag = false
	SpinButton.m_bHideSpinNumUIFlag = false

	SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_AutoSpin
	SpinButton:SetButtonSprite(enumSpinBtnType.ButtonType_Auto)
	self.m_textAutoSpinNum.gameObject:SetActive(true)
	self.m_textAutoSpinNum.text = "Auto"
	
	SpinButton.m_bEnableSpinFlag = false
	self:ButtonEnable(false)
	SpinButton.m_SpinButton.interactable = false
	local id = LeanTween.delayedCall(1.5, function()
		SpinButton.m_bEnableSpinFlag = true
		SpinButton.m_SpinButton.interactable = true
	end).id
	table.insert(self.m_listLeanTweenIDs, id)

end

function SceneSlotGame:Update()
	self.m_SlotsNumberWins:Update()

	if not SpinButton.m_bEnableSpinFlag then
		return
	end

	local bFreeSpinFlag = SlotsGameLua.m_GameResult:HasFreeSpin()
	local bReSpinFlag = SlotsGameLua.m_GameResult:HasReSpin()

	local bAutoFlag = false
	if SlotsGameLua.m_bAutoSpinFlag and not bFreeSpinFlag and not bReSpinFlag then
		bAutoFlag = true
	end
	
	local bSpinable = SlotsGameLua:Spinable()
	if bAutoFlag or bFreeSpinFlag or bReSpinFlag then
		if bSpinable then
			SlotsGameLua.m_bInSplashShow = false
			SlotsGameLua.m_nSplashActive = SplashType.None

			SpinButton:SpinFunction()
		end
	end

	self:OnClickScreenToSpin()
end

function SceneSlotGame:OnDestroy()
	self:RemoveBtnListener()
	self:reset()
end

function SceneSlotGame:hasSplashUI()
    for i = 0, SplashType.Max - 1 do
        if SlotsGameLua.m_bSplashFlags[i] then
            return true, i
        end
    end
	
    return false
end

function SceneSlotGame:setTotalWinTipInfo(strInfo, bFreeSpinWinFlag)
	if bFreeSpinWinFlag == nil then
		bFreeSpinWinFlag = false
	end

    if bFreeSpinWinFlag then
		self.m_textTotalWinTip.gameObject:SetActive(false)
		self.m_textFreeSpinWinTipInfo.gameObject:SetActive(true)
		if self.m_textFreeSpinWinTipInfo.text ~= strInfo then
			self.m_textFreeSpinWinTipInfo.text = strInfo
		end
	else
		self.m_textTotalWinTip.gameObject:SetActive(true)
		self.m_textFreeSpinWinTipInfo.gameObject:SetActive(false)
		if self.m_textTotalWinTip.text ~= strInfo then
			self.m_textTotalWinTip.text = strInfo
		end
	end
end

function SceneSlotGame:ButtonEnable(bEnable)
	if SlotsGameLua.m_GameResult:HasReSpin() then
		self.m_btnLobby.interactable = false
		self.m_btnSpin.interactable = false
		self.m_btnAddBet.interactable = false
		self.m_btnSubBet.interactable = false
		self.m_btnMaxBet.interactable = false
		
	elseif SlotsGameLua.m_GameResult:HasFreeSpin() then
		
		self.m_btnSpin.interactable = false
		self.m_btnLobby.interactable = false
		self.m_btnAddBet.interactable = false
		self.m_btnSubBet.interactable = false
		self.m_btnMaxBet.interactable = false
		self.m_btnPayTable.interactable = false
	elseif SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_AutoSpin then
		self.m_btnSpin.interactable = true
		self.m_btnLobby.interactable = false
		
		self.m_btnAddBet.interactable = false
		self.m_btnSubBet.interactable = false
		self.m_btnMaxBet.interactable = false

		self.m_btnPayTable.interactable = false
	else
		self.m_btnSpin.interactable = bEnable
		self.m_btnLobby.interactable = bEnable

		self.m_btnAddBet.interactable = bEnable
		self.m_btnSubBet.interactable = bEnable

		self.m_btnPayTable.interactable = bEnable

		if GameLevelUtil:isMaxBet() then
			self.m_btnMaxBet.interactable = false
		else
			self.m_btnMaxBet.interactable = bEnable
		end
	end

	local bWildLockFlag = false
	if bWildLockFlag then
		self.m_btnAddBet.interactable = false
		self.m_btnSubBet.interactable = false
		self.m_btnMaxBet.interactable = false
		return
	end

end

function SceneSlotGame:CheckMaxBetBtnStatus()
	if GameLevelUtil:isMaxBet() then
		self.m_btnMaxBet.interactable = false
		if self.m_imageBtnMaxBetLamp0 ~= nil then
			self.m_imageBtnMaxBetLamp0.overrideSprite = self.m_imageBtnMaxBetLamp1.sprite
		end
	else
		self.m_btnMaxBet.interactable = true
		if self.m_imageBtnMaxBetLamp0 ~= nil then
			self.m_imageBtnMaxBetLamp0.overrideSprite = nil
		end
	end
	
end

--显示停止 按钮
function SceneSlotGame:OnSpinToStop()
	-- spin 0.5s 之后让按钮亮起来 允许玩家快速stop

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Phoenix then
		if PhoenixFunc.m_bTrigerRespinFlag then
			return -- PhoenixFunc:GetDeck()里刚设置了暗下去的 
		end
	end
	
	if SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_NFreeStop or
		SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_StopEnable
	then
        return
	end

	if SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_AutoSpin then

    elseif SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_NFreeSpin then
		SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_NFreeStop
		SpinButton:SetButtonSprite(enumSpinBtnType.ButtonType_Stop)
		SpinButton.m_SpinButton.interactable = true
	elseif SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_SpinEnable then
		SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_StopEnable
		SpinButton:SetButtonSprite(enumSpinBtnType.ButtonType_Stop)
		SpinButton.m_SpinButton.interactable = true
	end
end

--Spin 结束后，按钮状态改变的逻辑 统一 放在这里
function SceneSlotGame:OnSpinEndButtonChangeState()
	local oriSpinBtnStatus = SpinButton.m_enumSpinStatus
	--结算之后，有的按钮状态会改
	if SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_AutoSpin then
		if not SlotsGameLua.m_bAutoSpinFlag then
			SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_SpinEnable
		end

		if SlotsGameLua.m_GameResult:HasFreeSpin() then
			SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_NFreeSpin
		end

	elseif SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_NFreeStop or
			SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_NFreeSpin then
		if not SlotsGameLua.m_GameResult:HasFreeSpin() then
			if SlotsGameLua.m_bAutoSpinFlag then
				SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_AutoSpin
			else
				SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_SpinEnable
			end
		else
			SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_NFreeSpin
		end
	elseif SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_InStop or
		SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_StopEnable then

		if SlotsGameLua.m_GameResult:HasFreeSpin() then
			SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_NFreeSpin
		else
			SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_SpinEnable
		end
	end

	if oriSpinBtnStatus ~= SpinButton.m_enumSpinStatus then
		--根据按钮状态 设置图片
		self.m_textAutoSpinNum.gameObject:SetActive(false)
		if SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_SpinEnable then
			SpinButton:SetButtonSprite(enumSpinBtnType.ButtonType_Spin)
		elseif SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_NFreeSpin then
			SpinButton:SetButtonSprite(enumSpinBtnType.ButtonType_FreeSpin)
		elseif SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_AutoSpin then
			SpinButton:SetButtonSprite(enumSpinBtnType.ButtonType_Auto)
			self.m_textAutoSpinNum.gameObject:SetActive(true)
		end
	end

end

function SceneSlotGame:playFreeSpinNumChangeEffect()
	if self.m_imageFreeSpinBG == nil then
		return
	end
	if self.m_bPlayingFreeSpinNumChangeEffect then
		return
	end
	self.m_bPlayingFreeSpinNumChangeEffect = true

	-- 1.0 -- 0.1-- 1.0 
	local fPeriodTime = 0.3 -- 一个来回的时间
	local cnt = 1
	local id = LeanTween.value(1.0, 0.12, fPeriodTime):setLoopPingPong(cnt):setOnUpdate(function(value)
		local cr = self.m_imageFreeSpinBG.color
		self.m_imageFreeSpinBG.color = Unity.Color(cr.r, cr.g, cr.b, value)
	end).id
	table.insert(self.m_listLeanTweenIDs, id)

	local id = LeanTween.delayedCall(fPeriodTime, function()
		self.m_bPlayingFreeSpinNumChangeEffect = false
	end).id
	table.insert(self.m_listLeanTweenIDs, id)
end

function SceneSlotGame:UpdateTotalBetToUI(strDes)
	if strDes == nil then
		self.m_textTotalBet.text = MoneyFormatHelper.numWithCommas(self.m_nTotalBet)
		self.m_textFreeSpinTotalBetInfo.text = MoneyFormatHelper.numWithCommas(self.m_nTotalBet)
	else
		self.m_textTotalBet.text = strDes
		self.m_textFreeSpinTotalBetInfo.text = strDes
	end

	if self.m_imageTotalBetBG == nil then
		return
	end
	if self.m_bPlayingTotalBetEffect then
		return
	end
	self.m_bPlayingTotalBetEffect = true

	-- 0.1 -- 1.0 -- 0.1
	local fPeriodTime = 0.3 -- 一个来回的时间
	local cnt = 1
	local id = LeanTween.value(0.12, 1.0, fPeriodTime):setLoopPingPong(cnt):setOnUpdate(function(value)
		local cr = self.m_imageTotalBetBG.color
		self.m_imageTotalBetBG.color = Unity.Color(cr.r, cr.g, cr.b, value)
	end).id
	table.insert(self.m_listLeanTweenIDs, id)

	local id = LeanTween.delayedCall(fPeriodTime, function()
		self.m_bPlayingTotalBetEffect = false
	end).id
	table.insert(self.m_listLeanTweenIDs, id)
end

function SceneSlotGame:UpdateTotalWinToUI()
	if SlotsGameLua.m_GameResult.m_fGameWin >= 0.001 then
		self.m_SlotsNumberWins:ChangeTo(SlotsGameLua.m_GameResult.m_fGameWin, self.m_fCurWinCoinTime)
		self:playTotalWinEffect()
	else
		local fWinCoins = 0
		local strTemp = tostring(fWinCoins)
		self.m_textTotalWinValue.text = strTemp
		self.m_SlotsNumberWins:End(0)
	end
end

function SceneSlotGame:playTotalWinEffect()
	if self.m_imageBigWinBG == nil then
		return
	end

	if self.m_bPlayingTotalWinEffect then
		return
	end

	self.m_bPlayingTotalWinEffect = true

	--self.m_fCurWinCoinTime
	-- 0.1 -- 1.0 -- 0.1
	local fPeriodTime = 0.3 -- 一个来回的时间
	local cnt = math.floor( self.m_fCurWinCoinTime / fPeriodTime )
	cnt = math.floor ( cnt/2 )
	self.m_nTotalWinEffectID = LeanTween.value(0.12, 1.0, fPeriodTime):setLoopPingPong(cnt):setOnUpdate(function(value)
		local cr = self.m_imageBigWinBG.color
		self.m_imageBigWinBG.color = Unity.Color(cr.r, cr.g, cr.b, value)
	end).id
	table.insert(self.m_listLeanTweenIDs, self.m_nTotalWinEffectID)

	local id = LeanTween.delayedCall(self.m_fCurWinCoinTime, function()
		self.m_bPlayingTotalWinEffect = false
		--self:stopTotalWinEffect()
	end).id
	table.insert(self.m_listLeanTweenIDs, id)
end

function SceneSlotGame:stopTotalWinEffect()
	if self.m_imageBigWinBG == nil then
		return
	end

	local cr = self.m_imageBigWinBG.color
	self.m_imageBigWinBG.color = Unity.Color(cr.r, cr.g, cr.b, 0.12)

	self.m_bPlayingTotalWinEffect = false
	LeanTween.cancel(self.m_nTotalWinEffectID)
end

-- 列落到底又弹回来 真正停止的时候
function SceneSlotGame:OnReelStop(nReelID)
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GreatZeus then
		GreatZeusLevelUI:OnReelStop(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_KingOfOcean then
		KingOfOceanLevelUI:OnReelStop(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MaYa then
		MaYaLevelUI:OnReelStop(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GrannyWolf then
		GrannyWolfLevelUI:OnReelStop(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ReelFortunes then
		ReelFortunesLevelUI:OnReelStop(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ReelOfDragon then
		ReelOfDragonLevelUI:OnReelStop(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MagicLink then
		MagicLinkLevelUI:OnReelStop(nReelID)
	elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FuLink then
		FuLinkLevelUI:OnReelStop(nReelID)
	end
	
end

-- 列落到底的时候
function SceneSlotGame:OnPreReelStop(nReelID)
	--------- 每关写自己的 不要在这里面加逻辑代码了
	
	local strKey = ThemeLoader.themeKey.."LevelUI"
	if _G[strKey] and _G[strKey].OnPreReelStop then
		_G[strKey]:OnPreReelStop(nReelID)
		return
	end	

	-- 以下代码以及对应调用的 LevelCommonFunctions 方法都不要修改 不要添加新逻辑 留给老关卡。

	local reel = SlotsGameLua.m_listReelLua[nReelID]

	if not SpinButton.m_bUserStopSpin or nReelID == SlotsGameLua.m_nReelCount-1 then
		-- 如果这个reel所有的元素都是固定的了 就不要播放reelstop音了
		local bres = LevelCommonFunctions:isNeedPlayReelStopSound(nReelID)
		if bres then
			AudioHandler:PlayReelStopSound(nReelID)
		end
	end

	if reel.m_ScatterEffectObj ~= nil then
		reel.m_ScatterEffectObj:reuseCacheEffect()
		reel.m_ScatterEffectObj = nil
	end

	if LevelCommonFunctions:isNeedPlayScatterEffectInReel(nReelID) then
		AudioHandler:PlayScatterStopSound(nReelID)
		reel:PlayEffectWaitingFreeSpin()
	else
		if SlotsGameLua.m_bPlayingSlotFireSound then
			SlotsGameLua.m_bPlayingSlotFireSound = false
			AudioHandler:StopSlotsOnFire()
		end
	end

	if nReelID == SlotsGameLua.m_nReelCount-1 then
		if SlotsGameLua.m_bPlayingSlotFireSound then
			SlotsGameLua.m_bPlayingSlotFireSound = false
			AudioHandler:StopSlotsOnFire()
		end
	end

	local bClassicLevel = GameLevelUtil:isClassicLevel()
	if bClassicLevel then
		LevelCommonFunctions:PlayWait777Effect(nReelID)
		LevelCommonFunctions:PlayWaitFireReelStopEffect(nReelID)
	end
end

function SceneSlotGame:OnButtonSubBet()
	local listTotalBet = GameLevelUtil:getTotalBetList()
    local cnt = #listTotalBet

	local nPreTotalBet = self.m_nTotalBet
	local bFind = false
	for i=cnt,1,-1 do
		if(listTotalBet[i] < nPreTotalBet) then
			self.m_nTotalBet = listTotalBet[i]
			bFind = true
			break
		end
	end

	if not bFind then
		self.m_nTotalBet = listTotalBet[cnt]
		self.m_btnMaxBet.interactable = false
		if self.m_imageBtnMaxBetLamp0 ~= nil then
			self.m_imageBtnMaxBetLamp0.overrideSprite = self.m_imageBtnMaxBetLamp1.sprite
		end
	else
		if(not self.m_btnMaxBet.interactable) then
		    self.m_btnMaxBet.interactable = true
			if self.m_imageBtnMaxBetLamp0 ~= nil then
				self.m_imageBtnMaxBetLamp0.overrideSprite = nil
			end
		end
	end

	AudioHandler:PlayDescBetSound(not bFind)
	self:UpdateTotalBetToUI()
	LevelCommonFunctions:TotalBetChange()
end

function SceneSlotGame:OnButtonPayTable()
	AudioHandler:PlayBtnSound()
	UIPayTable:Show()
end

function SceneSlotGame:OnButtonAddBet()
	local listTotalBet = GameLevelUtil:getTotalBetList()
	local cnt = #listTotalBet
	local nPreTotalBet = self.m_nTotalBet
	local bFind = false

	local nBetIndex = 0
	local bIsMax = false
	for i=1, cnt do
		if(listTotalBet[i] > nPreTotalBet) then
			nBetIndex = i
			if(i == cnt) then
				bIsMax = true
			end	
			self.m_nTotalBet = listTotalBet[i]
			bFind = true
			break
		end
	end

	if(not bFind) then
		self.m_nTotalBet = listTotalBet[1]
		nBetIndex = 1
	end
	if(bIsMax or cnt==1) then
		self.m_btnMaxBet.interactable = false
		if self.m_imageBtnMaxBetLamp0 ~= nil then 
			self.m_imageBtnMaxBetLamp0.overrideSprite = self.m_imageBtnMaxBetLamp1.sprite
		end
	else
	    if not self.m_btnMaxBet.interactable then
			self.m_btnMaxBet.interactable = true
			if self.m_imageBtnMaxBetLamp0 ~= nil then
				self.m_imageBtnMaxBetLamp0.overrideSprite = nil
			end
		end
	end
    
    AudioHandler:PlayAscBetSound(bIsMax)
	self:UpdateTotalBetToUI()
	LevelCommonFunctions:TotalBetChange()
end

function SceneSlotGame:OnButtonMaxBet()
	local listTotalBet = GameLevelUtil:getTotalBetList()
	local cnt = #listTotalBet
	local nTotalBet = listTotalBet[cnt]
	self.m_nTotalBet = nTotalBet
	AudioHandler:PlayAscBetSound(true)

	self:UpdateTotalBetToUI()
    self.m_btnMaxBet.interactable = false
	if self.m_imageBtnMaxBetLamp0 ~= nil then
		self.m_imageBtnMaxBetLamp0.overrideSprite = self.m_imageBtnMaxBetLamp1.sprite
	end
	LevelCommonFunctions:TotalBetChange()
end

function SceneSlotGame:OnTotalBetChangeTo(nTotalBet)
	local listTotalBet = GameLevelUtil:getTotalBetList()
	local cnt = #listTotalBet
	local nPreTotalBet = self.m_nTotalBet
	local bFind = false

	local nBetIndex = 0
	local bIsMax = false
	for i = 1, cnt do
		if listTotalBet[i] == nTotalBet then
			bFind = true

			if i == cnt then
				bIsMax = true
			end	
			break
		end
	end

	if not bFind then
		self.m_nTotalBet = listTotalBet[1]
		nBetIndex = 1
	else
		self.m_nTotalBet = nTotalBet
	end

	if bIsMax or cnt == 1 then
		self.m_btnMaxBet.interactable = false
		if self.m_imageBtnMaxBetLamp0 ~= nil then 
			self.m_imageBtnMaxBetLamp0.overrideSprite = self.m_imageBtnMaxBetLamp1.sprite
		end
	else
	    if not self.m_btnMaxBet.interactable then
			self.m_btnMaxBet.interactable = true
			if self.m_imageBtnMaxBetLamp0 ~= nil then
				self.m_imageBtnMaxBetLamp0.overrideSprite = nil
			end
		end
	end
	
	self:UpdateTotalBetToUI()
	LevelCommonFunctions:TotalBetChange()
end

-- 这是结算结束 展示结果之前。。
function SceneSlotGame:OnSpinEnd()
	local bFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()

	if not bFreeSpinFlag then
		PlayerHandler:AddCoin(self.m_fCurSpinWinCoins)
		LevelDataHandler:AddPlayerWinCoins(self.m_fCurSpinWinCoins)
		LevelDataHandler:AddBaseSpinWinCoins(SceneSlotGame.m_nTotalBet, self.m_fCurSpinWinCoins)
	end
	
	self.m_fCurSpinWinCoins = 0.0
end

function SceneSlotGame:AllReelStopAudioHandle()
	if SlotsGameLua.m_FuncAllReelStopAudioHandle.func ~= nil then
        SlotsGameLua.m_FuncAllReelStopAudioHandle.func(SlotsGameLua.m_FuncAllReelStopAudioHandle.param)
        return
    end

	local fCoinTime = 0.0
	local fSpinWin = SlotsGameLua.m_GameResult.m_fSpinWin
	local bFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
	if bFreeSpinFlag then
		local ratio = fSpinWin/self.m_nTotalBet
		if not self.m_bPlayReelStopAudio then
			ratio = 0.0
		end
		fCoinTime = AudioHandler:HandleAllReelStopAudioFreeGame(ratio)
	else
		local ratio = fSpinWin/self.m_nTotalBet
		if not self.m_bPlayReelStopAudio then
			ratio = 0.0
		end
		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FireRewindTestVideo then
			ratio = 0
		end
		if SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_AutoSpin then
			fCoinTime = AudioHandler:HandleAllReelStopAudioBaseGame(ratio, true)
		else
			fCoinTime = AudioHandler:HandleAllReelStopAudioBaseGame(ratio, false)
		end
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FireRewindTestVideo then
		fCoinTime = 1
	end

	if fSpinWin > 0 and fCoinTime < 0.5 then -- 有后续弹窗的情况处理...
		fCoinTime = 0.7 -- 测试。。respin结束后的结算

		if SlotsGameLua.m_enumLevelType == enumEffectType.enumLevelType_FortunesOfGold then
			fCoinTime = 1.5
		end
	end

	if fSpinWin < 0.000001 and SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_AutoSpin then
		fCoinTime = 0.5 -- 自动状态下 没中奖 延迟一点点再自动开启下一次
	end

	if fSpinWin > 0.0 then
		self.m_fCurWinCoinTime = fCoinTime * 0.8
		self:UpdateTotalWinToUI()

		--更新TopUI 的Money
		if SlotsGameLua.m_GameResult:InReSpin() then
			if not SlotsGameLua.m_GameResult:HasReSpin() then
				UITop:updateCoinCountInUi(self.m_fCurWinCoinTime)
			end
		else
			local bFlag1 = SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SnowWhite
			if bFlag1 then
				bFlag1 = SnowWhiteFunc.m_bPlayMultiBonusAniFlag
			end
			--- m_bPlayMultiBonusAniFlag情况 等倍数乘完之后再更新到左上角去。。

			if not bFlag1 then
				UITop:updateCoinCountInUi(self.m_fCurWinCoinTime)
			end
		end

	end

	SlotsGameLua.m_fCoinTime = fCoinTime
	
end

function SceneSlotGame:OnSplashEnd()
	SlotsGameLua.m_bSplashEnd = true
	self:OnSpinEndButtonChangeState()
	self:ButtonEnable(true)

	Debug.Log("SlotsGameLua.m_bSplashEnd = true")
end

function SceneSlotGame:OnSplashShow(nSplashType)
	if nSplashType == SplashType.Line then
		local bAutoFlag = SlotsGameLua.m_bAutoSpinFlag
		local bFreeSpin = SlotsGameLua.m_GameResult:InFreeSpin()
		local bReSpin = SlotsGameLua.m_GameResult:InReSpin()

		if bAutoFlag or bFreeSpin or bReSpin then
			if SlotsGameLua.m_fCoinTime < 0.5 then
				SlotsGameLua.m_fCoinTime = 0.5
			end
		end

		if self.m_bPlayReelStopAudio and not bReSpin then
			if bFreeSpin then
				self.m_btnSpin.interactable = true
			else
				self:OnSpinEndButtonChangeState()
				self:ButtonEnable(true)
			end
			
			self:OnSpinEndButtonChangeState()
		end
		
		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FishFrenzy then
			if SlotsGameLua.m_GameResult:InFreeSpin() and not SlotsGameLua.m_GameResult:HasFreeSpin() then
				self:ButtonEnable(false)
				self.m_btnSpin.interactable = false
			end
		end

		local ltd = LeanTween.delayedCall(SlotsGameLua.m_fCoinTime, function()
			if SlotsGameLua.m_bSplashFlags[nSplashType] then
				self:OnSplashHide(nSplashType)
			end
		end)
		table.insert(SlotsGameLua.mPerSpinCancelLeanTweenIDs, ltd.id)
	elseif nSplashType == SplashType.FreeSpin then
		local strKey = ThemeLoader.themeKey.."LevelUI"
		if _G[strKey] and _G[strKey].handleFreeSpinBegin then
			_G[strKey]:handleFreeSpinBegin()
			return
		end

		if self.m_bFreeSpinRetrigger then
			AudioHandler:PlayRetriggerSound()
		--	self.m_bFreeSpinRetrigger = false -- 弹窗的时候还需要用到
		else
			AudioHandler:PlayFreeGameTriggeredSound()
		end

		local fTime = self:ShowScatterBonusEffect(nSplashType) -- 等fTime时间之后 停止动画 展示出界面

		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SnowWhite then
			fTime = 1.0
		end

		local bRetrigerFlag = self.m_bFreeSpinRetrigger
		local co = StartCoroutine(function()
			self:delayShowFreeSpinBegin(fTime, bRetrigerFlag)
    	end)
			
	elseif nSplashType == SplashType.FreeSpinEnd then
		-- 播中奖音的时候会亮起让玩家点了可以略过..
        if SpinButton.m_SpinButton.interactable then
            SpinButton.m_SpinButton.interactable = false
		end

		local strKey = ThemeLoader.themeKey.."LevelUI"
		if _G[strKey] and _G[strKey].handleFreeSpinEnd then
			_G[strKey]:handleFreeSpinEnd()
			return 
		end

		AudioHandler:PlayFreeGamePopupEndSound()
		self.m_uiSplashFreeSpinsEnd:Show(nSplashType)
	elseif nSplashType == SplashType.ReSpin then
		local strKey = ThemeLoader.themeKey.."LevelUI"
		if _G[strKey] and _G[strKey].handleReSpinBegin then
			_G[strKey]:handleReSpinBegin()
			return
		end

		local fTime = 3.0
		self:ShowRespinTrigerEffect()

		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CashRespins then
			--CashRespinsLevelUI:ShowRespinInfo(true)
			-- 提前了。。放在获得的时候就调用 而不是等到各种动画做完了才调用

			fTime = 1.0
		end

		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Phoenix then
			--PhoenixLevelUI:ShowRespinInfo(true) -- 提前了
			fTime = 0.5
		end

		local id = LeanTween.delayedCall(fTime, function()
			self:OnSplashHide(SplashType.ReSpin)
			SceneSlotGame.m_bUIState = false
			AudioHandler:LoadAndPlayRespinGameMusic()
			self:HideRespinTrigerEffect()
		end).id
		table.insert(self.m_listLeanTweenIDs, id)

	elseif nSplashType == SplashType.ReSpinEnd then
		local strKey = ThemeLoader.themeKey.."LevelUI"
		if _G[strKey] and _G[strKey].handleReSpinEnd then
			_G[strKey]:handleReSpinEnd()
			return
		end
		
		self:OnSplashHide(SplashType.ReSpinEnd)
		-- 这个放这里不一定合适。。应该每关去各自实现
		-- 不一定每关都是在这里直接关了

		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CashRespins then
			CashRespinsLevelUI:ShowRespinInfo(false)
		end

		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Phoenix then
			PhoenixLevelUI:ShowRespinInfo(false)
		end

		SlotsGameLua:resetStickySymbols()

		-- respin结束了在这里修改到数据库  获得respin的时候在各自的关卡里写数据库
		local nReSpinNum = 0
		SlotsGameLua.m_GameResult.m_nReSpinCount = 0
		SlotsGameLua.m_GameResult.m_nReSpinTotalCount = 0

		local bInFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
		if bInFreeSpinFlag then
			AudioHandler:LoadFreeGameMusic()
		else
			AudioHandler:LoadBaseGameMusic()
		end
		
	elseif nSplashType == SplashType.Bonus then
		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MonsterRiches then
			MonsterRichesLevelUI:handleCollectCandyGame()
			return
		end
		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SantaMania then
			SantaManiaLevelUI:handleBonusGameBegin()
			return
		end
		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SweetBlast then
			SweetBlastLevelUI:handleBonusGameBegin()
			return
		end

		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_DireWolf then
			DireWolfLevelUI:handleBonusGameBegin()
			return
		end

		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ReelFortunes then
			ReelFortunesLevelUI:handleWheelGameBegin()
			return
		end

		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_ReelOfDragon then
			ReelOfDragonLevelUI:handleWheelGameBegin()
			return
		end
		
		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_TarzanBingo then
			TarzanBingoLevelUI:handleBingoBegin()
			return
		end
		
		if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Arab then
			ArabLevelUI:handleBonusGameBegin()
			return
		end
		
		local ftime = 3.2
		if not SlotsGameLua.m_bResetGameBonusFlag then
			self:ShowScatterBonusEffect()
		else
			SlotsGameLua.m_bResetGameBonusFlag = false
			if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Ocean then
				ftime = 1.0
			end

		end
		local co = StartCoroutine(function()
			self:delayShowBonusGameBegin(ftime)
    	end)
	elseif nSplashType == SplashType.FiveInRow then
		AudioHandler:Play5or6Kind()
		local nReelNum = SlotsGameLua.m_nReelCount
		if nReelNum == 5 or nReelNum == 6 then
			self.m_uiSplash5ofKind:Show(nSplashType)
		else
			SceneSlotGame:OnSplashHide(SplashType.FiveInRow)
		end
	elseif nSplashType == SplashType.BigWin then
		self.m_uiSplashBigWin.m_fLife = AudioHandler:PlayBigWinMusic() + 2.0
		self.m_uiSplashBigWin:Show(nSplashType)

	elseif nSplashType == SplashType.MegaWin then
		self.m_uiSplashMegaWin.m_fLife = AudioHandler:PlayMegaWinMusic() + 2.0
		self.m_uiSplashMegaWin:Show(nSplashType)

	elseif nSplashType == SplashType.EpicWin then
		self.m_uiSplashEpicWin.m_fLife = AudioHandler:PlayMegaWinMusic() + 2.0
		self.m_uiSplashEpicWin:Show(nSplashType)

	elseif nSplashType == SplashType.Jackpot then
		LevelCommonFunctions:ShowCustomBigMoneySplash()
	elseif nSplashType == SplashType.CustomWindow then
		LevelCommonFunctions:ShowCustomWindow()
	elseif nSplashType == SplashType.Wait then
		LevelCommonFunctions:HandleWaitEvent()
	else
		Debug.Assert(false, nSplashType)
	end
	
end

function SceneSlotGame:delayShowFreeSpinBegin(fDelay, bRetrigerFlag)
	if fDelay > 0.01 then
		yield_return(Unity.WaitForSeconds(fDelay))
	end

	local value = SplashType.FreeSpin
	if bRetrigerFlag then
		if self.m_uiSplashFreeSpinsAgain ~= nil then
			self.m_uiSplashFreeSpinsAgain:Show(value)
		else
			self.m_uiSplashFreeSpinsBegin:Show(value)
		end
	else
		self.m_uiSplashFreeSpinsBegin:Show(value)
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold
		 and bRetrigerFlag then
			AudioHandler:PlayThemeSound("moreFreePopupStart")
	else
		AudioHandler:PlayFreeGamePopupSound()
	end

	self:HideScatterBonusEffect()
end

function SceneSlotGame:delayShowBonusGameBegin(fDelay)
	if fDelay > 0.01 then
		yield_return(Unity.WaitForSeconds(fDelay))
	end

	local value = SplashType.Bonus
	self.m_uiSplashBonusGameBegin:Show(value)

	AudioHandler:PlayBonusGamePopupStart()
	self:HideScatterBonusEffect()
end

function SceneSlotGame:ShowRespinTrigerEffect()
	-- for x=0, SlotsGameLua.m_nReelCount-1 do
	-- 	local nRowCount = SlotsGameLua.m_listReelLua[x].m_nReelRow 
	-- 	for y=0, nRowCount do
	-- 		local nStickyIndex = nil 
	-- 		local bres,nStickyIndex = SlotsGameLua.m_listReelLua[x]:isStickyPos(y,nStickyIndex)
	-- 		if bres then
	-- 			local go = SlotsGameLua.m_listReelLua[x].m_listStickySymbol[nStickyIndex].m_goSymbol 
	-- 			local nEffectKey = SlotsGameLua.m_nRowCount * x + y
	-- 			--local bHasHitEffectFlag = self.hit
	-- 		end
	-- 	end
	-- end
end

function SceneSlotGame:HideRespinTrigerEffect()
--	self:HideScatterBonusEffect() -- 没有用的吧...
end

function SceneSlotGame:ShowScatterBonusEffect(nSplashType)
	-- if nSplashType == SplashType.FreeSpin then
	-- end

	local fTime = 3.0
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_WildBeast then
		WildBeastLevelUI:ShowScatterBonusEffect()

		fTime = 3.5
		if SlotsGameLua.m_GameResult:InFreeSpin() then
			fTime = 7.5
		end
		return fTime
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CashRespins then
		-- 延迟一点是因为 ShowScatterLandedEffect 第三个元素有可能还没有播完
		LeanTween.delayedCall(0.5, function()
			CashRespinsLevelUI:ShowScatterBonusEffect()
		end)

		fTime = 6.0
		return fTime
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Phoenix then
		LeanTween.delayedCall(0.5, function()
			PhoenixLevelUI:ShowScatterBonusEffect()
		end)

		fTime = 3.0
		return fTime
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Shinydiamonds then
		LeanTween.delayedCall(0.5, function()
			ShinydiamondsLevelUI:ShowScatterBonusEffect()
		end)

		fTime = 2.5
		return fTime
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold then
		FortunesOfGoldLevelUI:ShowScatterBonusEffect()

		fTime = 5.0
		return fTime
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GiantTreasure then
		GiantTreasureLevelUI:ShowScatterBonusEffect()

		fTime = 5.0
		return fTime
	end

	return fTime
end

function SceneSlotGame:HideScatterBonusEffect()
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_WildBeast then
		WildBeastLevelUI:HideScatterBonusEffect()
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CashRespins then
		CashRespinsLevelUI:HideScatterBonusEffect()
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Phoenix then
		PhoenixLevelUI:HideScatterBonusEffect()
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Shinydiamonds then
		ShinydiamondsLevelUI:HideScatterBonusEffect()
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold then
		FortunesOfGoldLevelUI:HideScatterBonusEffect()
		return
	end
	
end

function SceneSlotGame:OnSplashHide(value)
	if value < 0 then
		SlotsGameLua.m_bInSplashShow = false
		return
	end

	Debug.Assert(value == SlotsGameLua.m_nSplashActive, SlotsGameLua.m_nSplashActive.." | "..value)
	
	SlotsGameLua.m_nSplashActive = SlotsGameLua.m_nSplashActive + 1
	SlotsGameLua.m_bSplashFlags[value] = false
	SlotsGameLua.m_bInSplashShow = false
end

function SceneSlotGame:ShowFreeSpinUI(bShowFlag)
	local bClassicLevel = GameLevelUtil:isClassicLevel()
	if bClassicLevel then
		self.m_goFreeSpin:SetActive(bShowFlag)
		if bShowFlag then
			self:playFreeSpinNumChangeEffect()
		end
	else
		self.m_goBottomUILeftNormal:SetActive(not bShowFlag)
		self.m_goBottomUILeftFreeSpin:SetActive(bShowFlag)
	end

	if self.m_goFreeSpinBackground ~= nil then
		self.m_goFreeSpinBackground:SetActive(bShowFlag)
	end
	if self.m_goNormalReelBackground ~= nil then
		self.m_goNormalReelBackground:SetActive(not bShowFlag)
	end

	if bShowFlag then
		SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_NFreeSpin
		SpinButton:SetButtonSprite(enumSpinBtnType.ButtonType_FreeSpin)
		self:ButtonEnable(false)
		
		if self.m_textAutoSpinNum.gameObject.activeSelf then
			self.m_textAutoSpinNum.gameObject:SetActive(false)
		end

		local nFreeSpinNum = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount - SlotsGameLua.m_GameResult.m_nFreeSpinCount
		local nTotalFreeSpinCount = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount
		local strFreeSpinNumInfo = nFreeSpinNum .."/"..nTotalFreeSpinCount
		self.m_textFreeSpinNumInfo.text = strFreeSpinNumInfo

		if self.m_textFreeSpinTitleInfo then
			self.m_textFreeSpinTitleInfo.text = "FREE SPINS"
		end
		
		self.m_textFreeSpinTotalBetInfo.text = MoneyFormatHelper.numWithCommas(self.m_nTotalBet)

		local fDelayTime = 1.2
		
		fDelayTime = self:HandlePreFreeSpinCustomFunc() -- 处理一些个性化的需求 比如美女野兽关的把金色scatter变成wild固定在盘面上等
		-- GiantTreasure关也是金色scatter要变成wild固定在盘面上。。

		self.m_btnSpin.interactable = false
		SpinButton.m_bEnableSpinFlag = false
		self:delaySetAutoSpinEnable(fDelayTime)
	else
		SlotsGameLua:resetStickySymbols()
	end

	self:HandleCustomShowFreeSpinUI(bShowFlag)
end 

function SceneSlotGame:HandlePreFreeSpinCustomFunc()
	local fDelayTime = 1.2
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_WildBeast then
		
		--窗口关闭。。延迟一秒再开始scatter变wild的动画特效
		LeanTween.delayedCall(0.3, function()
			local fTime = WildBeastLevelUI:StickyGoldScatterToWild()
		end)

		fDelayTime = 2.2

		return fDelayTime
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GiantTreasure then
		
		--窗口关闭。。延迟0.3再开始scatter变wild的动画特效
		LeanTween.delayedCall(0.3, function()
			local fTime = GiantTreasureLevelUI:StickyGoldScatterToWild()
		end)

		fDelayTime = 2.5

		return fDelayTime
	end

	return fDelayTime
end

function SceneSlotGame:HandleCustomShowFreeSpinUI(bShowFlag)
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_WildBeast then
		WildBeastLevelUI:ShowFreeSpinUI(bShowFlag)
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Phoenix then
		PhoenixLevelUI:ShowFreeSpinUI(bShowFlag)
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold then
		FortunesOfGoldLevelUI:ShowFreeSpinUI(bShowFlag)
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MermaidMischief then
		MermaidMischiefLevelUI:ShowFreeSpinUI(bShowFlag)
		return
	end
	
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MonsterRiches then
		MonsterRichesLevelUI:ShowFreeSpinUI(bShowFlag)
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GoldenEgypt then
		GoldenEgyptLevelUI:ShowFreeSpinUI(bShowFlag)
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_BuffaloGold then
		BuffaloGoldLevelUI:ShowFreeSpinUI(bShowFlag)
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GiantTreasure then
		GiantTreasureLevelUI:ShowFreeSpinUI(bShowFlag)
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Smitten then
		SmittenLevelUI:ShowFreeSpinUI(bShowFlag)
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_MagicBall then
		MagicBallLevelUI:ShowFreeSpinUI(bShowFlag)
		return
	end
	
end

function SceneSlotGame:delaySetAutoSpinEnable(ftime)
	local co = StartCoroutine(function()
		yield_return(Unity.WaitForSeconds(ftime))
		SpinButton.m_bEnableSpinFlag = true
		self.m_btnSpin.interactable = true
		self.m_btnSpin:Select()
    end)
end

function SceneSlotGame:resetResultData(bFlag)
    if bFlag then
		local strLevelName = ThemeLoader.themeKey
		local fFreeSpinTotalWin = LevelDataHandler:getFreeSpinTotalWin(ThemeLoader.themeKey)
		LevelDataHandler:setFreeSpinTotalWin(strLevelName, 0)
		PlayerHandler:AddCoin(fFreeSpinTotalWin)
		LevelDataHandler:AddPlayerWinCoins(fFreeSpinTotalWin)
		UITop:updateCoinCountInUi(2.0)
    end
	
	SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = 0
	SlotsGameLua.m_GameResult.m_fSpinWin = 0
	SlotsGameLua.m_GameResult.m_fJackPotBonusWin = 0
	SlotsGameLua.m_GameResult.m_fNonLineBonusWin = 0
	SlotsGameLua.m_GameResult.m_fGameWin = 0

	self:UpdateTotalWinToUI()
end

function SceneSlotGame:collectFreeSpinTotalWins(fTime)
	if fTime == nil then
		fTime = 2.0
	end 

	local strLevelName = ThemeLoader.themeKey
	local fFreeSpinTotalWin = LevelDataHandler:getFreeSpinTotalWin(ThemeLoader.themeKey)
	LevelDataHandler:setFreeSpinTotalWin(strLevelName, 0)
	LevelDataHandler:setFreeSpinCount(strLevelName, 0)
    LevelDataHandler:setTotalFreeSpinCount(strLevelName, 0)
	
	PlayerHandler:AddCoin(fFreeSpinTotalWin)
	LevelDataHandler:AddPlayerWinCoins(fFreeSpinTotalWin)
	UITop:updateCoinCountInUi(fTime)
end

function SceneSlotGame:orAutoHideSplashUI()
	if SlotsGameLua.m_bAutoSpinFlag then
		return true
	end

	if SlotsGameLua.m_GameResult:InFreeSpin() then
		return true
	end
	
	return false
end

function SceneSlotGame:SetScreenSpinZoneRect()
	local nMinRow = 0
	local nMaxRow = SlotsGameLua.m_nRowCount - 1
	local nMinReel = 0
	local nMaxReel = SlotsGameLua.m_nReelCount - 1

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_RichOfVegas then
		nMaxRow = 2
	end

	local goMinGrid = SlotsGameLua.m_listReelLua[nMinReel].m_listGoSymbol[nMinRow]
	local goMaxGrid = SlotsGameLua.m_listReelLua[nMaxReel].m_listGoSymbol[nMaxRow]

	local xMin = goMinGrid.transform.position.x
	local yMin = goMinGrid.transform.position.y
	local xMax = goMaxGrid.transform.position.x
	local yMax = goMaxGrid.transform.position.y

	if xMin > xMax then
		local temp = xMin
		xMin = xMax
		xMax = temp
	end

	if yMin > yMax then
		local temp = yMin
		yMin = yMax
		yMax = temp
	end

	local xMin = xMin - SlotsGameLua.m_fSymbolWidth / 2
	local yMin = yMin - SlotsGameLua.m_fSymbolHeight / 2
	local xMax = xMax + SlotsGameLua.m_fSymbolWidth / 2
	local yMax = yMax + SlotsGameLua.m_fSymbolHeight / 2

	local fWidth = math.abs(xMax - xMin)
	local fHeigth = math.abs(yMax - yMin)
	
	self.mDefaultScreenSpinZoneRect = Unity.Rect(xMin, yMin, fWidth, fHeigth)
end

function SceneSlotGame:OnClickScreenToSpin(zoneRect)
	if not GameLevelUtil:isPortraitLevel() then
		self.clickSpinZonebValid = false
		return
	end

	if not (Unity.Input.GetMouseButtonDown(0) or Unity.Input.GetMouseButton(0) or Unity.Input.GetMouseButtonUp(0)) then
		self.clickSpinZonebValid = false
		return
	end

	if SceneSlotGame.m_bUIState then
		self.clickSpinZonebValid = false
		return
	end

	if not SpinButton.m_bEnableSpinFlag then
		self.clickSpinZonebValid = false
		return
	end

	if not SpinButton.m_SpinButton.interactable then
		self.clickSpinZonebValid = false
		return
	end	

	local bFreeSpinFlag = SlotsGameLua.m_GameResult:HasFreeSpin()
	local bReSpinFlag = SlotsGameLua.m_GameResult:HasReSpin()

	if SlotsGameLua.m_bAutoSpinFlag and not bFreeSpinFlag and not bReSpinFlag then
		self.clickSpinZonebValid = false
		return
	end

	local fZ = SlotsGameLua.m_transform.position.z - Unity.Camera.main.transform.position.z
	
	local mousePosition = Unity.Vector3(Unity.Input.mousePosition.x, Unity.Input.mousePosition.y, fZ)
	if LuaHelper.orScreenPositionOutOfViewFrustumd(mousePosition) then
		self.clickSpinZonebValid = false
		return
	end

	local worldPos = Unity.Camera.main:ScreenToWorldPoint(mousePosition)

	--Debug.Log("Unity.Input.mousePosition.z: "..Unity.Input.mousePosition.z)
	--Debug.Log("worldPos: "..worldPos.x..", "..worldPos.y..", "..worldPos.z)

	if not zoneRect then
		zoneRect = self.mDefaultScreenSpinZoneRect
	end

	--Debug.Log("zoneRect: "..zoneRect.x..", "..zoneRect.y..", "..zoneRect.width..", "..zoneRect.height)
	
	if not (zoneRect and zoneRect:Contains(worldPos)) then
		self.clickSpinZonebValid = false
		return
	end

	if Unity.Input.GetMouseButtonDown(0) then
		self.clickSpinZonebValid = true
		self.clickSpinZoneDownPos = worldPos
	end
	
	if self.clickSpinZonebValid and Unity.Vector3.Distance(worldPos, self.clickSpinZoneDownPos) >= 80 then
		self.clickSpinZonebValid = false
		return
	end

	if self.clickSpinZonebValid and Unity.Input.GetMouseButtonUp(0) then
		self.clickSpinZonebValid = false

		if SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_AutoSpin then
			SlotsGameLua.m_bAutoSpinFlag = false
			SpinButton:StopFunction()
		elseif SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_SpinEnable then
			AudioHandler:playSpinBtnSound()
			SpinButton:SkipNormalSpinAnimationGoNext()
		elseif SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_StopEnable then
			SpinButton:StopFunction()
			AudioHandler:playStopSpinBtnSound()
		elseif SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_NFreeStop then
			SpinButton:StopFunction()
		elseif SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_NFreeSpin then
			SpinButton:SkipAutoSpinAnimationGoNext()
		end

	end

end

return SceneSlotGame

