local AudioHandler = {}

function AudioHandler:Init()
	local audioParent = ThemeVideoScene.transform
	self.musicTweenObject = Unity.GameObject("AudioHandler_Music")
	self.winSoundTweeObject = Unity.GameObject("AudioHandler_Sound")
	self.musicTweenObject.transform:SetParent(audioParent, false)
	self.winSoundTweeObject.transform:SetParent(audioParent, false)
	
	self.gameObject = audioParent.gameObject
	self.themeBackMusicAudioSource = self.gameObject:AddComponent(typeof(Unity.AudioSource))
 	self.musicAudioSource = self.gameObject:AddComponent(typeof(Unity.AudioSource))
 	self.winSoundAudioSource = self.gameObject:AddComponent(typeof(Unity.AudioSource))
 	self.slotFireAudioSource = nil
 	self.audioSourcePool = {}
 	for i = 1, 5 do
 		self.audioSourcePool[i] = self.gameObject:AddComponent(typeof(Unity.AudioSource))
 	end
	
	self.reelStopKeys = {}
	self.scatterStopKeys = {}
	self.bonusStopKeys = {}
	for i = 1, 10 do
		self.reelStopKeys[i] = "reelStop"..(i - 1)
		self.scatterStopKeys[i] = "scatterStop"..(i - 1)
		self.bonusStopKeys[i] = "bonusStop"..(i - 1)
	end

	EventHandler:AddListener("onSoundSettingChanged", self)
	self:onSoundSettingChanged()
end

function AudioHandler:LoadThemeCommonAudio(audioClips)
	for i, v in ipairs(audioClips) do
		self.themeClipDict[v.name] = v
	end
end

function AudioHandler:loadThemeAudio(audioClips)
	self.themeClipDict = {}
	self.spinAudioArray = {}
	self.spinAudioIndex = 1
	for i,v in ipairs(audioClips) do
		self.themeClipDict[v.name] = v
	end

	local i = 0
	while true do
		if(self.themeClipDict["spin"..i]) then
			self.spinAudioArray[i + 1] = self.themeClipDict["spin"..i]
			i = i + 1
		else
			break
		end
	end
end

function AudioHandler:getSourceFromPool()
	for i, audioSource in ipairs(self.audioSourcePool) do
 		if(not audioSource.isPlaying) then
 			audioSource.pitch = 1.0
			audioSource.volume = 1.0
			audioSource.loop = false
 			return audioSource
 		end
 	end
	Debug.Log("Audio Source Pool passed limit")
	local newAudioSource = self.gameObject:AddComponent(typeof(Unity.AudioSource))
	newAudioSource.pitch = 1.0
	newAudioSource.volume = 1.0
	self.audioSourcePool[#self.audioSourcePool+1] = newAudioSource
	 
	newAudioSource.mute = SettingHandler:isMute()
 	return newAudioSource
end

function AudioHandler:onSoundSettingChanged()
	if not LuaHelper.OrGameObjectExist(self.musicTweenObject) then
		EventHandler:RemoveListener("onSoundSettingChanged", self)
		return
	end
	
	local mute = SettingHandler:isMute()
	self.themeBackMusicAudioSource.mute = mute
	self.musicAudioSource.mute = mute
	self.winSoundAudioSource.mute = mute
	if self.slotFireAudioSource then
		self.slotFireAudioSource.mute = mute
	end
 	for i, v in ipairs(self.audioSourcePool) do
 		v.mute = mute
	end

end

function AudioHandler:playLevelUp()
	local audioSource = self:getSourceFromPool()
	audioSource.clip = self.themeClipDict["levelup"]
	audioSource:Play()
end

function AudioHandler:PlayAscBetSound(isMax)
	local audioSource = self:getSourceFromPool()
	audioSource.clip = isMax and self.themeClipDict["betAscendingMax"] or self.themeClipDict["betAscending"]
	audioSource:Play()
end

function AudioHandler:PlayDescBetSound(isMax)
	local audioSource = self:getSourceFromPool()
	if isMax then
		audioSource.clip = self.themeClipDict["betAscendingMax"]
	else
		audioSource.clip = self.themeClipDict["betDescending"]
	end
	
	audioSource:Play()
end

function AudioHandler:playSpinBtnSound()
	local audioSource = self:getSourceFromPool()
	audioSource.clip = self.themeClipDict["spinClick"]
	audioSource:Play()
end

function AudioHandler:playStopSpinBtnSound()
	local audioSource = self:getSourceFromPool()
	audioSource.clip = self.themeClipDict["stopSpinClick"]
	audioSource:Play()
end

function AudioHandler:PlayAutoSpinBtnSound()
	local audioSource = self:getSourceFromPool()
	audioSource.clip = self.themeClipDict["autoSpin"]
	audioSource:Play()
end

function AudioHandler:PlayBtnSound()
	local audioSource = self:getSourceFromPool()
	audioSource.clip = self.themeClipDict["button"]
	audioSource:Play()
end

function AudioHandler:Play5or6Kind()
	local audioSource = self:getSourceFromPool()
	audioSource.clip = self.themeClipDict["5ofKind"]
	audioSource:Play()
	self.musicAudioSource:Pause()
end

function AudioHandler:handleSpinAudio()
	LeanTween.cancel(self.musicTweenObject)
	LeanTween.cancel(self.winSoundTweeObject)
	local isLoopSpinMusic = #self.spinAudioArray == 0
	self.musicAudioSource.loop = isLoopSpinMusic
	if not isLoopSpinMusic then
		local index = (self.spinAudioIndex % (#self.spinAudioArray)) + 1
		self.musicAudioSource.clip = self.spinAudioArray[index]
		self.spinAudioIndex = self.spinAudioIndex + 1
	end
	if not self.musicAudioSource.isPlaying then
		self.musicAudioSource:Play()
	end
	LeanTween.value(self.musicTweenObject, self.musicAudioSource.volume, 1.0, 0.5):setOnUpdate (function(value)
		self.musicAudioSource.volume = value
	end)
	LeanTween.value(self.winSoundTweeObject, self.winSoundAudioSource.volume, 0, 0.5):setOnUpdate(function(value)
		self.winSoundAudioSource.volume = value
	end)
end

-- 列滚动停止就调用 这里只做一件事就是停止关卡背景音
function AudioHandler:StopMusic(ratio)
	local isLoopSpinMusic = #self.spinAudioArray == 0
	local winLength = 0
	if ratio <= 0 then
		if not isLoopSpinMusic then
			LeanTween.value(self.musicTweenObject, self.musicAudioSource.volume, 0, 0.5):setOnUpdate(function(value)
				self.musicAudioSource.volume = value 
			end)
		else
			LeanTween.value(self.musicTweenObject, self.musicAudioSource.volume, 0, 5):setOnUpdate(function(value)
				self.musicAudioSource.volume = value 
			end):setOnComplete(function()
				self.musicAudioSource:Pause()
			end)
		end
		self.winSoundAudioSource.volume = 0
	else
		if self.musicAudioSource.isPlaying then
			LeanTween.value(self.musicTweenObject, self.musicAudioSource.volume * 0.6, 0, 1):setOnUpdate(function(value)
				self.musicAudioSource.volume = value 
			end):setOnComplete(function()
				self.musicAudioSource:Pause()
			end)
		end
	end
	
end

-- 这个方法也只做一件事：就是播放中奖音
function AudioHandler:PlayWinSound(ratio, auto)
	local isLoopSpinMusic = #self.spinAudioArray == 0
	local winLength = 0
	if ratio <= 0 then
		self.winSoundAudioSource.volume = 0
	else
		local key = nil
		if auto then
			key = "auto_win"
		else
			if ratio > 10 then
				key = "win4"
			elseif ratio >= 5 then
				key = "win3"
			elseif ratio >= 2 then
				key = "win2"
			elseif ratio >= 1 then
				key = "win1"
			else
				key = "win0"
			end
		end

		if self.themeClipDict[key] then
			local clip = self.themeClipDict[key]

			if clip == nil then
				Debug.Log("--error!!---self.themeClipDict[key] == nil----------key: " .. key)
			end

			self.winSoundAudioSource.clip = clip
			self.winSoundAudioSource.time = 0.0
			self.winSoundAudioSource:Play()
			winLength = clip.length
			LeanTween.cancel(self.winSoundTweeObject)

			LeanTween.value(self.winSoundTweeObject, self.winSoundAudioSource.volume, 1.0, 0.1):setOnUpdate(function(value)
				self.winSoundAudioSource.volume = value
			end)

		end
	end
	return winLength
end

function AudioHandler:HandleAllReelStopAudioBaseGame(ratio, bAutoFlag)
	return self:HandleAllReelStopAudio(ratio, bAutoFlag)
end

function AudioHandler:HandleAllReelStopAudioFreeGame(ratio)
	return self:HandleAllReelStopAudio(ratio, false)
end

-- 不能删 以前的老关卡 C#关卡都用到了
function AudioHandler:HandleAllReelStopAudio(ratio, auto)
	local isLoopSpinMusic = #self.spinAudioArray == 0
	local winLength = 0
	if ratio <= 0 then
		if not isLoopSpinMusic then
			LeanTween.value(self.musicTweenObject, self.musicAudioSource.volume, 0, 0.5):setOnUpdate(function(value)
				self.musicAudioSource.volume = value 
			end)
		else
			LeanTween.value(self.musicTweenObject, self.musicAudioSource.volume, 0, 5):setOnUpdate(function(value)
				self.musicAudioSource.volume = value 
			end):setOnComplete(function()
				self.musicAudioSource:Pause()
			end)
		end
		self.winSoundAudioSource.volume = 0
	else
		local key = nil
		if auto then
			key = "auto_win"
		else
			if ratio > 10 then
				key = "win4"
			elseif ratio >= 5 then
				key = "win3"
			elseif ratio >= 2 then
				key = "win2"
			elseif ratio >= 1 then
				key = "win1"
			else
				key = "win0"
			end
		end

		if self.themeClipDict[key] then
			local clip = self.themeClipDict[key]

			if clip == nil then
				Debug.Log("--error!!---self.themeClipDict[key] == nil----------key: " .. key)
			end

			self.winSoundAudioSource.clip = clip
			self.winSoundAudioSource.time = 0.0
			self.winSoundAudioSource:Play()
			winLength = clip.length
			LeanTween.cancel(self.musicTweenObject)
			LeanTween.cancel(self.winSoundTweeObject)
			if self.musicAudioSource.isPlaying then
				LeanTween.value(self.musicTweenObject, self.musicAudioSource.volume * 0.6, 0, 4):setOnUpdate(function(value)
					self.musicAudioSource.volume = value 
				end):setOnComplete(function()
					self.musicAudioSource:Pause()
				end)
			end

			LeanTween.value(self.winSoundTweeObject, self.winSoundAudioSource.volume, 1.0, 0.1):setOnUpdate(function(value)
				self.winSoundAudioSource.volume = value
			end)

		end
	end
	return winLength
end

function AudioHandler:PlayBigWinMusic()
	self.winSoundAudioSource.volume = 1.0
	local audioClip = self.themeClipDict["music_bigWin"]
	self.winSoundAudioSource.clip = audioClip
	self.winSoundAudioSource.time = 0.0
	self.winSoundAudioSource:Play()
	self.musicAudioSource:Pause()
	return audioClip.length
end

function AudioHandler:PlayMegaWinMusic()
	self.winSoundAudioSource.volume = 1.0
	local audioClip = self.themeClipDict["music_megaWin"]
	self.winSoundAudioSource.clip = audioClip
	self.winSoundAudioSource.time = 0.0
	self.winSoundAudioSource:Play()
	self.musicAudioSource:Pause()
	return audioClip.length
end

function AudioHandler:HandleSkipBigMegaWin()
	if self.winSoundAudioSource.isPlaying then
		local clip = self.winSoundAudioSource.clip
		if self.winSoundAudioSource.time < clip.length - 1.0 then
			self.winSoundAudioSource.time = clip.length - 1.0
		end
	end
end

function AudioHandler:PlayReelStopSound(nReelID)
	if nReelID < #self.reelStopKeys then
		local key = self.reelStopKeys[nReelID + 1]
		key = self.themeClipDict[key] and key or self.reelStopKeys[1]
		self:PlayThemeSound(key)
	end
end

function AudioHandler:PlayScatterStopSound(nReelID)
	if nReelID < #self.scatterStopKeys then
		local key = self.scatterStopKeys[nReelID + 1]
		key = self.themeClipDict[key] and key or self.scatterStopKeys[1]

		self:PlayThemeSound(key)
	end
end

function AudioHandler:PlaySlotsOnFire()
	self.slotFireAudioSource = self:PlayThemeSound("slotfire")
end

function AudioHandler:StopSlotsOnFire()
	if self.slotFireAudioSource  then
		self.slotFireAudioSource:Stop()
		self.slotFireAudioSource = nil
	end
end

function AudioHandler:PlayThemeSound(key)
	if not self.themeClipDict[key] then
		return nil
	end
	local clip = self.themeClipDict[key]
	local audioSource = self:getSourceFromPool()
	audioSource.clip = clip
	audioSource.loop = false
	audioSource.volume = 1
	audioSource:Play()
	return audioSource
end

function AudioHandler:getThemeAudio(key)
	return self.themeClipDict[key]
end

function AudioHandler:PlayRevealWild()
	self:PlayThemeSound("revealWild")
end

function AudioHandler:PlayRevealSymbol()
	self:PlayThemeSound("revealSymbol")
end

function AudioHandler:PlayFreeGameTriggeredSound()
	self:PlayThemeSound("freeTrigger")
end

function AudioHandler:PlayRetriggerSound()
	local strName = "freeRetrigger"
	if ThemeLoader.themeKey == "TigerDragonTestVideo" or ThemeLoader.themeKey == "FireRewindTestVideo" then
		strName = "win0" -- 录视频时候用一下。。
	end

	self:PlayThemeSound(strName)
end

function AudioHandler:PlayRespinReset()
	self:PlayThemeSound("respin_reset")
end

function AudioHandler:PlayFreeGamePopupSound()
	self:PlayThemeSound("freePopupStart")
end

function AudioHandler:PlayFreeGamePopupPickSound()
	self:PlayThemeSound("freePopupPick")
end

function AudioHandler:PlayFreeGamePopupEndSound()
	self:PlayThemeSound("freePopupEnd")
end

function AudioHandler:PlayFreeGamePopupBtnSound()
	self:PlayThemeSound("popupBtnClicked")
end

function AudioHandler:PlayBonusLanded()
	self:PlayThemeSound("bonus_landed")
end

function AudioHandler:PlayBonusCollectionFly()
	self:PlayThemeSound("bonusCollectionFly")
end

function AudioHandler:PlayBonusCollected()
	self:PlayThemeSound("bonusCollected")
end

function AudioHandler:PlayBonusCollectionFilled()
	self:PlayThemeSound("bonusCollectionFilled")
end

function  AudioHandler:PlayBonusGameTriggered()
	self:PlayThemeSound("bonusTrigger")
end

function AudioHandler:PlayBonusGamePopupStart()
	self:PlayThemeSound("bonusPopStart")
end

function AudioHandler:PlayBonusGamePopupEnd()
	self:PlayThemeSound("bonusPopEnd")
end

function AudioHandler:PlayBonusGamePickItem()
	self:PlayThemeSound("bonusGame_pickItem")
end

function AudioHandler:PlayBonusGameEnd()
	self:PlayThemeSound("bonusGame_end")
end

function AudioHandler:PlayFeatureAppear()
	self:PlayThemeSound("featureAppear")
end


function AudioHandler:LoadFreeGameMusic()
	self.musicAudioSource.clip = self.themeClipDict["music_free"]
	self.musicAudioSource.loop = true
end

function AudioHandler:LoadBaseGameMusic()
	self.musicAudioSource.clip = self.themeClipDict["music_base"]
	self.musicAudioSource.loop = true
end

function AudioHandler:LoadAndPlayBonusGameMusic()  
	LeanTween.cancel (self.musicTweenObject)
	self.musicAudioSource.clip = self.themeClipDict["music_bonus"]
	self.musicAudioSource.volume = 1.0
	self.musicAudioSource.loop = true
	self.musicAudioSource:Play()                                   
end 

function AudioHandler:LoadAndPlayRespinGameMusic()
	LeanTween.cancel (self.musicTweenObject)
	self.musicAudioSource.clip = self.themeClipDict["music_respin"]
	self.musicAudioSource.volume = 1.0
	self.musicAudioSource.loop = true
	self.musicAudioSource:Play()
end

function AudioHandler:LoadAndPlayWheelMusic()
	LeanTween.cancel (self.musicTweenObject)
	self.musicAudioSource.clip = self.themeClipDict["music_wheel"]
	self.musicAudioSource.volume = 1.0
	self.musicAudioSource.loop = true
	self.musicAudioSource:Play()
end

function AudioHandler:LoadAndPlayThemeMusic(key)
	if self.themeClipDict[key] then
		LeanTween.cancel (self.musicTweenObject)
		self.musicAudioSource.clip = self.themeClipDict[key]
		self.musicAudioSource.volume = 1.0
		self.musicAudioSource.loop = true
		self.musicAudioSource:Play()
	end
end

function AudioHandler:PlayThemeBackMusic(clipName)
	local clip = AudioHandler:getThemeAudio(clipName)
	if clip then
		AudioHandler.themeBackMusicAudioSource.clip = clip
		AudioHandler.themeBackMusicAudioSource.loop = true
		AudioHandler.themeBackMusicAudioSource.volume = 1
		
		if not AudioHandler.themeBackMusicAudioSource.isPlaying then
			AudioHandler.themeBackMusicAudioSource:Play()
		end
	end
end

function AudioHandler:PlayJackpotHit()
	local audioSource = self:PlayThemeSound("jackpotHit")
	if audioSource  then
		return audioSource.clip.length
	end
	return 0
end


function AudioHandler:PlayJackpotPopup()
	self:PlayThemeSound("jackpotPopup")
end

function AudioHandler:PlayJackpotPopupBtn()
	self:PlayThemeSound("popupBtnClicked")
end

function AudioHandler:PlayGameWheelRotateSound()
	self:PlayThemeSound("wheel_rotate")
end

function AudioHandler:HandleGameWheelStop()
	self:PlayThemeSound("wheelResult")
	LeanTween.cancel(self.musicTweenObject)
	LeanTween.value(self.musicTweenObject, self.musicAudioSource.volume, 0, 0.5):setOnUpdate (function(value)
		self.musicAudioSource.volume = value
	end)
end

function AudioHandler:StopAllInGameAudio()
	LeanTween.cancel (self.musicTweenObject)
	LeanTween.cancel (self.winSoundTweeObject)
	self.winSoundAudioSource:Stop()
	self.musicAudioSource:Stop()
	self.themeBackMusicAudioSource:Stop()
end

function AudioHandler:StopWinSound()
	LeanTween.cancel(self.winSoundTweeObject)
	LeanTween.value(self.winSoundTweeObject, self.winSoundAudioSource.volume, 0, 0.5):setOnUpdate(function(value)
	self.winSoundAudioSource.volume = value
	end)

	-- LeanTween.delayedCall(0.5, function()
	-- 	self.winSoundAudioSource:Stop()
	-- end)
end

return AudioHandler
