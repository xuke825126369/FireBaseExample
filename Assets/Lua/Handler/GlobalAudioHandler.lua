GlobalAudioHandler = {}

function GlobalAudioHandler:Init()
	self.musicTweenObject = Unity.GameObject("GlobalAudioHandler")
 	self.musicAudioSource = self.musicTweenObject:AddComponent(typeof(Unity.AudioSource))
 	self.audioSourcePool = {}
 	for i = 1, 5 do
 		self.audioSourcePool[i] = self.musicTweenObject:AddComponent(typeof(Unity.AudioSource))
 	end	

	self.mapClipDict = {}
	
	EventHandler:AddListener("onSoundSettingChanged", self)
	self:onSoundSettingChanged()
end

function GlobalAudioHandler:LoadAllAudio(audioClips)
	self.mapClipDict = {}
	for i,v in ipairs(audioClips) do
		self.mapClipDict[v.name] = v
	end
end

function GlobalAudioHandler:RemoveAllAudioSourceClip()
	for i, audioSource in ipairs(self.audioSourcePool) do
		audioSource.clip = nil
	end
end

function GlobalAudioHandler:getSourceFromPool()
	for i, audioSource in ipairs(self.audioSourcePool) do
 		if(not audioSource.isPlaying) then
 			audioSource.pitch = 1.0
			audioSource.volume = 1.0
			audioSource.loop = false
			audioSource.clip = nil
 			return audioSource
 		end
 	end

	Debug.Log("Audio Source Pool passed limit")
	
	local newAudioSource = self.musicTweenObject:AddComponent(typeof(Unity.AudioSource))
	newAudioSource.pitch = 1.0
	newAudioSource.volume = 1.0
	newAudioSource.loop = false
	newAudioSource.mute = SettingHandler:isMute()

	table.insert(self.audioSourcePool, newAudioSource)
 	return newAudioSource
end

function GlobalAudioHandler:onSoundSettingChanged()
	local bMute = SettingHandler:isMute()
	self.musicAudioSource.mute = bMute
 	for i, v in ipairs(self.audioSourcePool) do
 		v.mute = bMute
 	end
end

function GlobalAudioHandler:PlayBtnSound()
	local audioSource = self:getSourceFromPool()
	audioSource.clip = self.mapClipDict["button"]
	audioSource:Play()
end

function GlobalAudioHandler:PlayBackMusic(key)
	local clip = self.mapClipDict[key]
	self.musicAudioSource.clip = clip
	self.musicAudioSource.loop = true
	self.musicAudioSource.volume = 1.0
	self.musicAudioSource:Play()
end

function GlobalAudioHandler:setBGMusicVolume(volume)
	self.musicAudioSource.volume = volume
end

function GlobalAudioHandler:PlaySound(key)
	if not self.mapClipDict[key] then
		Debug.Log("GlobalAudioHandler key is Null: "..key)
		return nil
	end

	local clip = self.mapClipDict[key]
	local audioSource = self:getSourceFromPool()
	audioSource.clip = clip
	audioSource.loop = false
	audioSource.volume = 1
	audioSource:Play()
	return audioSource
end

function GlobalAudioHandler:playCoinCollection(second)
	local audioSource = self:getSourceFromPool()
	audioSource.clip = self.commonClipDict["coinsCollection"]
	LeanTween.value (1, 0, 0.2):setDelay(second):setOnUpdate (function(value)
		audioSource.volume = value
	end)
	audioSource:Play()
end

function GlobalAudioHandler:PlayLobbyBackMusic()
	local clip = self.mapClipDict["music_lobby"]
	self.musicAudioSource.clip = clip
	self.musicAudioSource.loop = true
	self.musicAudioSource.volume = 1.0
	self.musicAudioSource:Play()
	self.musicAudioSource.mute = SettingHandler:isMute()
end
