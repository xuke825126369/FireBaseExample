CommonAudioHandler = {}

CommonAudioHandler.LoadItemInfo = {
	bundleName = "",
	assetPathDir = "",
}

function CommonAudioHandler:New()
    local temp = {}
    self.__index = self
    setmetatable(temp, self)
    return temp
end

function CommonAudioHandler:Init(name, tableLoadInfo)
	self.tableLoadInfo = tableLoadInfo
	
	self.SoundTweeObject = Unity.GameObject.Find(name)
	if self.SoundTweeObject then
		Unity.Object.Destroy(self.SoundTweeObject)
	end

	self.SoundTweeObject = Unity.GameObject(name)
 	self.musicAudioSource = self.SoundTweeObject:AddComponent(typeof(Unity.AudioSource))
 	self.audioSourcePool = {}
 	for i = 1, 5 do
 		self.audioSourcePool[i] = self.SoundTweeObject:AddComponent(typeof(Unity.AudioSource))
 	end
		
	self.mapClipDict = {}

	EventHandler:AddListener("onSoundSettingChanged", self)
	self:onSoundSettingChanged()
end

function CommonAudioHandler:Release()
	EventHandler:RemoveListener("onSoundSettingChanged", self)
	Unity.Object.Destroy(self.SoundTweeObject)
end

function CommonAudioHandler:OnDestroy()
	self.mapClipDict = nil
	Unity.Resources.UnloadUnusedAssets()
end

function CommonAudioHandler:LoadAllAudio(audioClips)
	for i, v in pairs(audioClips) do
		self.mapClipDict[v.name] = v
	end
	self.m_bAudioLoaded = true
end

function CommonAudioHandler:AsyncLoadAllAudio()
	local m_AllAudioClips = {}
	for k, v in pairs(self.tableLoadInfo) do
		local assetPathDir = v.assetPathDir
		local bundleName = v.bundleName
		
		local audioClips = {}
        if not GameConfig.Instance.orUseAssetBundle then
			local guids = CS.UnityEditor.AssetDatabase.FindAssets("", {assetPathDir})
			for i = 0, guids.Length - 1 do
				local path = CS.UnityEditor.AssetDatabase.GUIDToAssetPath(guids[i])
				audioClips[i + 1] = CS.UnityEditor.AssetDatabase.LoadAssetAtPath(path, typeof(Unity.AudioClip))
			end
		else
			local bundle = AssetBundleHandler:GetBundle(bundleName)
			local assetBundleRequest = bundle:LoadAllAssetsAsync(typeof(Unity.AudioClip))
			yield_return(assetBundleRequest)
			local audioArray = assetBundleRequest.allAssets
			if audioArray.Length > 0 then
				for i = 0, audioArray.Length - 1 do
					audioClips[i + 1] = audioArray[i]
				end
			end
		end

		for i,v in pairs(audioClips) do
			m_AllAudioClips[v.name] = v
		end
	end

	self.mapClipDict = m_AllAudioClips
	self.m_bAudioLoaded = true
end

function CommonAudioHandler:orInitFinish()
	return self.m_bAudioLoaded
end

function CommonAudioHandler:RemoveAllAudioSourceClip()
	for i, audioSource in ipairs(self.audioSourcePool) do
		audioSource.clip = nil
	end
end

function CommonAudioHandler:getSourceFromPool()
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

	local newAudioSource = self.SoundTweeObject:AddComponent(typeof(Unity.AudioSource))
	newAudioSource.pitch = 1.0
	newAudioSource.volume = 1.0
	newAudioSource.loop = false
	newAudioSource.mute = SettingHandler:isMute()

	table.insert(self.audioSourcePool, newAudioSource)
 	return newAudioSource
end

function CommonAudioHandler:onSoundSettingChanged()
	local bMute = SettingHandler:isMute()
	self.musicAudioSource.mute = bMute
 	for i, v in ipairs(self.audioSourcePool) do
 		v.mute = bMute
 	end
end

function CommonAudioHandler:PlayBtnSound()
	local audioSource = self:getSourceFromPool()
	audioSource.clip = self.mapClipDict["button"]
	audioSource:Play()
end

function CommonAudioHandler:StopBackMusic()
	GlobalAudioHandler:setBGMusicVolume(1.0)
	if self.musicAudioSource then
		self.musicAudioSource:Stop()
	end
end

function CommonAudioHandler:PlayBackMusic(key)
	local clip = self.mapClipDict[key]
	self.musicAudioSource.clip = clip
	self.musicAudioSource.loop = true
	self.musicAudioSource.volume = 1.0
	self.musicAudioSource:Play()
	
	GlobalAudioHandler:setBGMusicVolume(0)
end

function CommonAudioHandler:setBGMusicVolume(volume)
	self.musicAudioSource.volume = volume
end

function CommonAudioHandler:PlaySound(key)
	if not self.mapClipDict[key] then
		Debug.Log("CommonAudioHandler key is Null: "..key)
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
