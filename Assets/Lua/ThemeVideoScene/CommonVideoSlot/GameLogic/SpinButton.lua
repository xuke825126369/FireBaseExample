local SpinButton = {}

SpinButton.m_rctTransformBtn = nil
SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_SpinEnable
SpinButton.m_fSpinToAutoTime = 0.0
SpinButton.m_bSelAutoSpinNumFlag = false
SpinButton.m_bHideSpinNumUIFlag = false
SpinButton.m_bEnableSpinFlag = true

------Button Image
---spin
SpinButton.m_imageSpinNormal = nil
SpinButton.m_imageSpinPress = nil
SpinButton.m_imageSpinGray = nil
---stop
SpinButton.m_imageStopNormal = nil
SpinButton.m_imageStopPress = nil
SpinButton.m_imageStopGray = nil
----auto
SpinButton.m_imageAutoSpinNormal = nil
SpinButton.m_imageAutoSpinPress = nil
SpinButton.m_imageAutoSpinGray = nil
----freespin
SpinButton.m_imageFreeSpinNormal = nil
SpinButton.m_imageFreeSpinPress = nil
SpinButton.m_imageFreeSpinGray = nil

SpinButton.m_imageBtnSpin = nil --按钮贴图 运行时常要用上面的那些图来替换这个

SpinButton.m_SpinButton = nil --Button

SpinButton.m_curButtonType = enumSpinBtnType.ButtonType_Spin

SpinButton.m_goSpinBtnEffect = nil --按钮上的休闲特效
SpinButton.m_fShowSpinBtnEffectTime = 0.0 --//用来统计多长时间播放一次按钮休闲特效

SpinButton.m_bUserStopSpin = false  --玩家点了stop -- 也用来控制是否显示ScatterEffect等。。

SpinButton.m_transform = nil --//绑定的界面对象

SpinButton.m_textAutoSpinNum = nil -- TextMeshProUGUI 之前SceneSlotGame里的

SpinButton.clickSpinZonebValid = false
SpinButton.clickSpinZoneDownPos = nil

function SpinButton:Init()
	self.m_transform = SceneSlotGame.m_transform:FindDeepChild("ButtonSpin")
	LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

	self:initParam()

	self.m_fSpinToAutoTime = 0
	self.m_bSelAutoSpinNumFlag = false
	self.m_bHideSpinNumUIFlag = false
	self.m_fShowSpinBtnEffectTime = 0
	
	self.m_curButtonType = enumSpinBtnType.ButtonType_NONE
	self.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_SpinEnable
	self:SetButtonSprite(enumSpinBtnType.ButtonType_Spin)
	self.m_textAutoSpinNum.gameObject:SetActive(false)
end

function SpinButton:initParam()
	self.m_rctTransformBtn = self.m_transform:GetComponent(typeof(Unity.RectTransform))
	self.m_SpinButton = self.m_transform:GetComponent(typeof(UnityUI.Button))
	self.m_SpinButton.interactable = true
	self.m_imageBtnSpin = self.m_SpinButton.image
	
	local tr = self.m_transform
	self.m_imageSpinNormal = tr:FindDeepChild("imageSpinNormal"):GetComponent(typeof(UnityUI.Image))
	self.m_imageSpinPress = tr:FindDeepChild("imageSpinPress"):GetComponent(typeof(UnityUI.Image))
	self.m_imageSpinGray = tr:FindDeepChild("imageSpinGray"):GetComponent(typeof(UnityUI.Image))

	self.m_imageStopNormal = tr:FindDeepChild("imageStopNormal"):GetComponent(typeof(UnityUI.Image))
	self.m_imageStopPress = tr:FindDeepChild("imageStopPress"):GetComponent(typeof(UnityUI.Image))
	self.m_imageStopGray = tr:FindDeepChild("imageStopGray"):GetComponent(typeof(UnityUI.Image))

	self.m_imageAutoSpinNormal = tr:FindDeepChild("imageAutoSpinNormal"):GetComponent(typeof(UnityUI.Image))
	self.m_imageAutoSpinPress = tr:FindDeepChild("imageAutoSpinPress"):GetComponent(typeof(UnityUI.Image))
	self.m_imageAutoSpinGray = tr:FindDeepChild("imageAutoSpinGray"):GetComponent(typeof(UnityUI.Image))

	self.m_imageFreeSpinNormal = tr:FindDeepChild("imageFreeSpinNormal"):GetComponent(typeof(UnityUI.Image))
	self.m_imageFreeSpinPress = tr:FindDeepChild("imageFreeSpinPress"):GetComponent(typeof(UnityUI.Image))
	self.m_imageFreeSpinGray = tr:FindDeepChild("imageFreeSpinGray"):GetComponent(typeof(UnityUI.Image))
	
	self.m_textAutoSpinNum = tr:FindDeepChild("ValueAutoSpinNum"):GetComponent(typeof(TextMeshProUGUI))

	self.m_goSpinBtnEffect = tr:FindDeepChild("SpinButtonAni").gameObject
end

function SpinButton:Update()
	local dt = Unity.Time.deltaTime
	self:CheckClickZoneValid(dt)
	self:UpdateSpinBtnEffect(dt)
	
	if not self:CheckAutoSpinOp(dt) then
		self:CheckSpinBtnClickOp(dt)
	end
end

-- 检查 是否是 点击动作
function SpinButton:CheckSpinBtnClickOp(dt)
	if not self.clickSpinZonebValid then
		return
	end

	if Unity.Input.GetMouseButtonUp(0) then
		if self.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_AutoSpin then
			SlotsGameLua.m_bAutoSpinFlag = false
			self:StopFunction()
		elseif self.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_SpinEnable then
			AudioHandler:playSpinBtnSound()
			self:SkipNormalSpinAnimationGoNext()
		elseif self.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_StopEnable then
			self:StopFunction()
			AudioHandler:playStopSpinBtnSound()
		elseif self.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_NFreeStop then
			self:StopFunction()
		elseif self.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_NFreeSpin then
			self:SkipAutoSpinAnimationGoNext()
		end
	end
end

-- 更新 SpinBtn 的特效
function SpinButton:UpdateSpinBtnEffect(dt)
	if self.m_SpinButton.interactable and self.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_SpinEnable then
		self.m_fShowSpinBtnEffectTime = self.m_fShowSpinBtnEffectTime + dt

		if self.m_fShowSpinBtnEffectTime > 8.0 then
			self.m_fShowSpinBtnEffectTime = 0.0
			if not self.m_goSpinBtnEffect.activeSelf then
				self.m_goSpinBtnEffect:SetActive(true)
			end
		end
	else
		self.m_fShowSpinBtnEffectTime = 0.0
		if self.m_goSpinBtnEffect.activeSelf then
			self.m_goSpinBtnEffect:SetActive(false)
		end
	end
end

-- 检测 点击 是否有效
function SpinButton:CheckClickZoneValid()
	if SceneSlotGame.m_bUIState then
		self.clickSpinZonebValid = false
		return
	end

	if not self.m_SpinButton.interactable then
		self.clickSpinZonebValid = false
		return
	end

	if Unity.Input.GetMouseButtonDown(0) or Unity.Input.GetMouseButton(0) or Unity.Input.GetMouseButtonUp(0)  then
		local mousePosition =  Unity.Vector2(Unity.Input.mousePosition.x, Unity.Input.mousePosition.y)
		local bMouseInSpinBtn = Unity.RectTransformUtility.RectangleContainsScreenPoint(self.m_rctTransformBtn, mousePosition, Unity.Camera.main)

		if Unity.Input.GetMouseButtonDown(0) then
			if bMouseInSpinBtn then
				self.clickSpinZonebValid = true
				self.clickSpinZoneDownPos = mousePosition
			end
		elseif Unity.Input.GetMouseButton(0) or Unity.Input.GetMouseButtonUp(0) then
			if not bMouseInSpinBtn then
				self.clickSpinZonebValid = false
			end

			if self.clickSpinZonebValid and Unity.Vector2.Distance(self.clickSpinZoneDownPos, mousePosition) > 80 then
				self.clickSpinZonebValid = false
			end
			
		end
	else
		self.clickSpinZonebValid = false
	end

end

-- 检查 是否 AutoSpin 操作
function SpinButton:CheckAutoSpinOp(dt)
	if Unity.Input.GetMouseButtonUp(0) then
		self.m_fSpinToAutoTime = 0.0
	end

	local bInAutoSpinOp = self.m_bSelAutoSpinNumFlag --正处于 AutoSpin 选择界面里
	if not self.m_bSelAutoSpinNumFlag then
		if Unity.Input.GetMouseButton(0) and self.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_SpinEnable and self.clickSpinZonebValid then
			self.m_fSpinToAutoTime = self.m_fSpinToAutoTime + dt
			if self.m_fSpinToAutoTime > 0.9 then
				self.m_fSpinToAutoTime = 0.0
				
				self.m_bSelAutoSpinNumFlag = true
				self.m_bHideSpinNumUIFlag = false

				if not Unity.Input.GetMouseButtonUp(0) then
					self.m_SpinButton.interactable = false
				end

				SceneSlotGame:SetAutoSpinBtn()
			end
		end

	else
		if self.m_bHideSpinNumUIFlag then
			if Unity.Input.GetMouseButtonUp(0) then
				self.m_bSelAutoSpinNumFlag = false
				self.m_bHideSpinNumUIFlag = false
			end
		else
			if Unity.Input.GetMouseButtonUp(0) then
				self.m_SpinButton.interactable = true
			end

			if Unity.Input.GetMouseButtonDown(0) then
				self.m_bHideSpinNumUIFlag = true
			end
		end
	end

	return bInAutoSpinOp or self.m_bSelAutoSpinNumFlag ----正处于 AutoSpin 选择界面里 或者，刚触发 AutoSpin 选择界面
end	

function SpinButton:SetButtonSprite(buttonType)
	if self.m_curButtonType == buttonType then
		return
	end
	self.m_curButtonType = buttonType
	
	local spriteState = self.m_SpinButton.spriteState

	if buttonType == enumSpinBtnType.ButtonType_Spin then
		self.m_imageBtnSpin.sprite = self.m_imageSpinNormal.sprite

		spriteState.highlightedSprite = self.m_imageSpinNormal.sprite
		spriteState.pressedSprite = self.m_imageSpinPress.sprite
		spriteState.disabledSprite = self.m_imageSpinGray.sprite

	elseif buttonType == enumSpinBtnType.ButtonType_Stop then
		self.m_imageBtnSpin.sprite = self.m_imageStopNormal.sprite

		spriteState.highlightedSprite = self.m_imageStopNormal.sprite
		spriteState.pressedSprite = self.m_imageStopPress.sprite
		spriteState.disabledSprite = self.m_imageStopGray.sprite

	elseif buttonType == enumSpinBtnType.ButtonType_Auto then
		self.m_imageBtnSpin.sprite = self.m_imageAutoSpinNormal.sprite

		spriteState.highlightedSprite = self.m_imageAutoSpinNormal.sprite
		spriteState.pressedSprite = self.m_imageAutoSpinPress.sprite
		spriteState.disabledSprite = self.m_imageAutoSpinGray.sprite

	elseif buttonType == enumSpinBtnType.ButtonType_FreeSpin then
		self.m_imageBtnSpin.sprite = self.m_imageFreeSpinNormal.sprite

		spriteState.highlightedSprite = self.m_imageFreeSpinNormal.sprite
		spriteState.pressedSprite = self.m_imageFreeSpinPress.sprite
		spriteState.disabledSprite = self.m_imageFreeSpinGray.sprite

	end
	self.m_SpinButton.spriteState = spriteState

end

function SpinButton:SkipNormalSpinAnimationGoNext()
	for i=0, SplashType.Max do
		SlotsGameLua.m_bSplashFlags[i] = false
	end
	
	SlotsGameLua.m_bInSplashShow = false
	SlotsGameLua.m_bInResult = false
	SlotsGameLua.m_bSplashEnd = true
	SlotsGameLua.m_nSplashActive = SplashType.None

	self:SpinFunction()
	SceneSlotGame.m_SlotsNumberWins:End(SlotsGameLua.m_GameResult.m_fGameWin)
end

function SpinButton:SkipAutoSpinAnimationGoNext()
	self.m_SpinButton.interactable = false
	if SlotsGameLua.m_nSplashActive == SplashType.Line and SlotsGameLua.m_bSplashFlags[SplashType.Line] then
		SceneSlotGame:OnSplashHide(SplashType.Line)
	end

	SceneSlotGame.m_SlotsNumberWins:End(SlotsGameLua.m_GameResult.m_fGameWin)
end

function SpinButton:SpinFunction()
	self.m_bUserStopSpin = false
	local bLastReSpin = SlotsGameLua.m_GameResult:InReSpin()
	local returnCode = SlotsGameLua:Spin()


	SceneSlotGame.m_bPlayReelStopAudio = true

	local strLevelName = ThemeLoader.themeKey
	if returnCode == SlotsReturnCode.Success then
		if not LevelCommonFunctions:isStopAllReel() then
			AudioHandler:handleSpinAudio()
		end

		LevelDataHandler:AddTotalSpinNum(SceneSlotGame.m_fTotalSpinNum)
		ReturnRateManager:JudgeReturnRatePerSpin()
		
		if SlotsGameLua.m_bAutoSpinFlag then
			SlotsGameLua.m_nAutoSpinNum = SlotsGameLua.m_nAutoSpinNum + 1
			self.m_textAutoSpinNum.text = "Auto"
		else
			SlotsGameLua.m_nAutoSpinNum = 0
		end	

		SceneSlotGame:ButtonEnable(false)
		SceneSlotGame:stopTotalWinEffect()
		
		if not SlotsGameLua.m_GameResult:InReSpin() then
			UITop:updateCoinCountInUi(0.5)
		end

		local bHasFreeSpinFlag = SlotsGameLua.m_GameResult:HasFreeSpin()
		local bHasReSpinFlag = SlotsGameLua.m_GameResult:HasReSpin()
		if bHasReSpinFlag then
			self:handleRespinCountInfo()
		elseif bHasFreeSpinFlag then
			self:handleFreespinCountInfo()
		else
			UITop:refreshUserLevel()
		end

		self:handleLevelUIParam() -- 更新jackpot参数等
	elseif returnCode == SlotsReturnCode.InSpin then
		self.m_SpinButton.interactable = false
	elseif returnCode == SlotsReturnCode.NoGold then
		if not BuyView:isActiveShow() then
			BuyView:Show()
		end

		SlotsGameLua.m_bAutoSpinFlag = false
		SceneSlotGame:OnSpinEndButtonChangeState()
		SceneSlotGame:ButtonEnable(true)
	else
		-- body
	end
	
end

function SpinButton:handleLevelUIParam()
	LevelCommonFunctions:addJackPotValue(false)
end

function SpinButton:handleRespinCountInfo()
	SlotsGameLua.m_GameResult.m_nReSpinCount = SlotsGameLua.m_GameResult.m_nReSpinCount + 1
	local nTotalCount = SlotsGameLua.m_GameResult.m_nReSpinTotalCount
	local nReSpinCount = SlotsGameLua.m_GameResult.m_nReSpinCount
	local nReSpinNum = nTotalCount - nReSpinCount
	LevelDataHandler:setReSpinCount(ThemeLoader.themeKey, nReSpinNum)
end

function SpinButton:handleFreespinCountInfo()
	local nFreeSpinCount = SlotsGameLua.m_GameResult.m_nFreeSpinCount
	nFreeSpinCount = nFreeSpinCount + 1
	SlotsGameLua.m_GameResult.m_nFreeSpinCount = nFreeSpinCount
	LevelDataHandler:addNewFreeSpinCount(ThemeLoader.themeKey, -1)
	
	local nFreeSpinRestNum = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount - nFreeSpinCount
	if nFreeSpinRestNum == 0 then
		self:SetButtonSprite(enumSpinBtnType.ButtonType_Stop)
	end

	local nTotalFreeSpinCount = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount
	local strFreeSpinNumInfo = nFreeSpinRestNum.. "/" .. nTotalFreeSpinCount
	SceneSlotGame.m_textFreeSpinNumInfo.text = strFreeSpinNumInfo
	SceneSlotGame:playFreeSpinNumChangeEffect()
end

function SpinButton:StopFunction()
	self.m_SpinButton.interactable = false
	self.m_bUserStopSpin = true

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FishFrenzy then
		FishFrenzyLevelUI:StopFunction()
		return
	end
	
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GiantTreasure then
		if GiantTreasureFunc.m_nGameType == 1 then
			GiantSpinsGame2_1:StopFunction()
			return
		end
		
		if GiantTreasureFunc.m_nGameType == 2 then
			GiantSpinsGame4_1:StopFunction()
			return
		end
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SantaMania then
		local bFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
		if bFreeSpinFlag then
			SantaFreeSpinGameMain:StopFunction()
			return
		end
	end
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SweetBlast then
		local bFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
		if bFreeSpinFlag then
			SweetBlastFreeSpinGameMain:StopFunction()
			return
		end
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CoinFrenzy then
		if SlotsGameLua.m_GameResult:InFreeSpin() then
			CoinFrenzyLevelUI.mDeckManager:StopFunction()
			return
		end
	end
	
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_DireWolf then
		DireWolfLevelUI.mDeckManager:StopFunction()
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GoldMine then
		if SlotsGameLua.m_GameResult:InFreeSpin() then
			GoldMineLevelUI.mDeckManager:StopFunction()
			return
		end
	end
	
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_PhoenixOfFire then
		PhoenixOfFireLevelUI.mDeckManager:StopFunction()
		return
	end

	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_KangarooRich then
		KangarooRichLevelUI.mDeckManager:StopFunction()
		return
	end
	
	local bAutoFlag = self.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_AutoSpin
	if SlotsGameLua.m_bInSpin then
		if not bAutoFlag then
			for i=0, SlotsGameLua.m_nReelCount-1 do
				SlotsGameLua.m_listReelLua[i]:Stop()
				SlotsGameLua.m_listReelLua[i].m_fRotateDistance = 0.0
				SlotsGameLua.m_listReelLua[i].m_fSpeed = SlotsGameLua.m_listReelLua[i].m_fSpeed * 1.6
				SlotsGameLua.m_listReelLua[i].m_fBoundSpeed = SlotsGameLua.m_listReelLua[i].m_fBoundSpeed * 1.5
			end
		end
	else
		-- 这个判断不加上，会导致 在AutoSpin 在启动后 亮起的第一帧，连续点击，会导致 按钮 灰掉，并且无法 转动的 严重 bug(重复多次，才会重现bug)
		local bInReSpin = SlotsGameLua.m_GameResult:InReSpin()
		if bAutoFlag and not bInReSpin then
			SceneSlotGame:OnSpinEndButtonChangeState()
			SceneSlotGame:ButtonEnable(true)
		end
	end
		
	if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_KingOfOcean then
		if not SlotsGameLua.m_bInSpin then
			if SlotsGameLua.m_bInResult and SlotsGameLua.m_nSplashActive == SplashType.Line then
				if SlotsGameLua.m_GameResult:InReSpin() and not SlotsGameLua.m_GameResult:HasReSpin() then
					SlotsGameLua.m_bAutoSpinFlag = false
					KingOfOceanFunc:StopFunction()
					SceneSlotGame:OnSpinEndButtonChangeState()
					SceneSlotGame.m_btnSpin.interactable = false
				end
			end
		end
	end

end

return SpinButton


