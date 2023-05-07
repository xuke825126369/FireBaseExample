local yield_return = (require 'cs_coroutine').yield_return
LuckyJumpAssetBundleHandler = {}

LuckyJumpAssetBundleHandler.m_bundleInfo = {}
LuckyJumpAssetBundleHandler.m_mapPrefabs = {}

LuckyJumpAssetBundleHandler.m_audioClips = {} -- key: 文件名 value: ..

LuckyJumpAssetBundleHandler.m_bPrefabLoaded = false
LuckyJumpAssetBundleHandler.m_bAudioLoaded = false

function LuckyJumpAssetBundleHandler:loadAssetFromLoadedBundle(assetPath, strType)
    if GameConfig.PLATFORM_EDITOR_TEST then
        return CS.UnityEditor.AssetDatabase.LoadAssetAtPath(assetPath, strType)
    else
        if strType == typeof(Unity.GameObject) then
            assetPath = string.lower(assetPath)
            for k, v in pairs(self.m_mapPrefabs) do
                if string.match(assetPath, k) then
                    return v
                end
            end
        else
            return self.m_bundleInfo.assetBundle:LoadAsset(assetPath, strType)
        end
        
        return nil
    end

end

function LuckyJumpAssetBundleHandler:initBundleInfo()
    if not GameConfig.LUCKYJUMP_FLAG then
        return
    end
    self.m_bPrefabLoaded = false
    self.m_bAudioLoaded = false

    local data = GameConfigHandler.gameConfig.LuckyJumpAssetBundle
    local bundleInfo = BundleInfo:new()
    bundleInfo.key = data.key
    bundleInfo.url = data.url == "" and "" or GameConfig.SERVER_ROOT..data.url..string.lower(data.key)
    bundleInfo.type = data.type
    bundleInfo.version = data.version
    bundleInfo.downloadStatus = self:isAssetBundleDownloaded(bundleInfo) and DownloadStatus.Downloaded or DownloadStatus.NotStart
    self.m_bundleInfo = bundleInfo
end

function LuckyJumpAssetBundleHandler:isAssetBundleDownloaded(bundleInfo)
    if (GameConfig.PLATFORM_EDITOR or bundleInfo.url == "") then
        return true
    end
    return Unity.Caching.IsVersionCached(bundleInfo.url, bundleInfo.version)
end

function LuckyJumpAssetBundleHandler:checkAndDownload()
    if GameConfig.PLATFORM_EDITOR then
        return
    end

    local bundleInfo = self.m_bundleInfo
    if bundleInfo.downloadStatus == DownloadStatus.Downloading then
        return
    end

    local bCacheFlag = Unity.Caching.IsVersionCached(bundleInfo.url, bundleInfo.version)
    if not bCacheFlag then
        self:downloadLuckyJumpAsset(bundleInfo)
    end
end

function LuckyJumpAssetBundleHandler:downloadLuckyJumpAsset(bundleInfo)
    bundleInfo.downloadStatus = DownloadStatus.Downloading
    bundleInfo.isUIUpdated = false
    local co = StartCoroutine(function()
        local request = CS.UnityEngine.Networking.UnityWebRequest.GetAssetBundle(bundleInfo.url, bundleInfo.version, 0)
        request:Send()
        local waitTime = Unity.WaitForSeconds(0.05)
        while (not request.isDone) do
            if bundleInfo.downloadingProgress ~= request.downloadProgress then
                bundleInfo.downloadingProgress = request.downloadProgress <= 0 and 0 or request.downloadProgress
                bundleInfo.isUIUpdated = false
            end
            yield_return(waitTime)
        end
        if request.isDone then
            bundleInfo.isUIUpdated = false

            bundleInfo.assetBundle = request.downloadHandler.assetBundle
            bundleInfo.downloadStatus = self:isAssetBundleDownloaded(bundleInfo) and DownloadStatus.Downloaded or DownloadStatus.NotStart
            
        end
    end)
end

function LuckyJumpAssetBundleHandler:asynLoadLuckyJumpAssetBundle()
    if not GameConfig.PLATFORM_EDITOR then
        self:unzipLuckyJumpAssetBundle()
        local waitTime = Unity.WaitForSeconds(0.1)
        while (not self.m_bAudioLoaded) or (not self.m_bPrefabLoaded) do
            yield_return(waitTime)
        end
        LuckyJumpUnloadedUI.m_bAssetReady = true
    else
        self:unzipLuckyJumpAssetBundle()
        LuckyJumpUnloadedUI.m_bAssetReady = true
    end
end

function LuckyJumpAssetBundleHandler:unloadLuckyJumpAssetBundle()
    if GameConfig.PLATFORM_EDITOR then
        return
    end
    if(self.m_bundleInfo.assetBundle ~= nil) then
        self.m_bundleInfo.assetBundle:Unload(true)
        self.m_mapPrefabs = {}
        self.m_audioClips = {}
        self.m_bPrefabLoaded = false
        self.m_bAudioLoaded = false
        self.m_bundleInfo.assetBundle = nil
        if LuckyJumpMainUIPop.transform ~= nil then
            Unity.Object.Destroy(LuckyJumpMainUIPop.transform.gameObject)
        end
        LuckyJumpUnloadedUI.m_bAssetReady = false
        Debug.Log("---------LuckyJumpAssetBundle unload True------------")
    end
end

function LuckyJumpAssetBundleHandler:unzipLuckyJumpAssetBundle()
    if not GameConfig.PLATFORM_EDITOR then
        self:loadAllPrefabs()
    else
        self.m_bPrefabLoaded = true
        self:loadAudioClips()
    end
end

function LuckyJumpAssetBundleHandler:loadAllPrefabs()
    local co = StartCoroutine(function()
        if self.m_bundleInfo.assetBundle == nil then
            local www = Unity.WWW.LoadFromCacheOrDownload(self.m_bundleInfo.url, self.m_bundleInfo.version)
            yield_return(www)
            self.m_bundleInfo.assetBundle = www.assetBundle
        end
        local prefabPathArray = {}
        local nameArray = self.m_bundleInfo.assetBundle:GetAllAssetNames()
        for i=1, nameArray.Length-1 do
            local assetPath = nameArray[i]
            if string.match(assetPath, ".prefab") then
                table.insert(prefabPathArray, assetPath)
            end
        end

        local Length = #prefabPathArray
        assert(Length > 0)

        for k,v in pairs(prefabPathArray) do
            local assetPath = v
            local assetBundleRequest = self.m_bundleInfo.assetBundle:LoadAssetAsync(assetPath, typeof(Unity.GameObject))
            yield_return(assetBundleRequest)
            self.m_mapPrefabs[assetPath] = assetBundleRequest.asset
        end
        Debug.Log("LuckyJump Prefab Loaded")
        self.m_bPrefabLoaded = true
        self:loadAudioClips()
    end)
end

function LuckyJumpAssetBundleHandler:loadAudioClips()
    local audioClips = {}
    if GameConfig.PLATFORM_EDITOR_TEST then
        local guids = CS.UnityEditor.AssetDatabase.FindAssets("", {"Assets/LuckyJump/Audio"})
        for i = 0, guids.Length-1 do
            local path = CS.UnityEditor.AssetDatabase.GUIDToAssetPath(guids[i])
            audioClips[i+1] = CS.UnityEditor.AssetDatabase.LoadAssetAtPath(path, typeof(Unity.AudioClip))
        end
        for i,v in pairs(audioClips) do
            self.m_audioClips[v.name] = v
        end

        self.m_bAudioLoaded = true

    else
        local co = StartCoroutine(function()
            local assetBundleRequest = self.m_bundleInfo.assetBundle:LoadAllAssetsAsync(typeof(Unity.AudioClip))
            yield_return(assetBundleRequest)
            Debug.Log("LuckyJump Audio Loaded")
            local audioArray = assetBundleRequest.allAssets

            if audioArray.Length > 0 then
                for i = 0, audioArray.Length-1 do
                    audioClips[i+1] = audioArray[i]
                end
            end

            for i,v in pairs(audioClips) do
                self.m_audioClips[v.name] = v
            end

            self.m_bAudioLoaded = true
        end)
    end
end

function GlobalAudioHandler:PlayLuckyJumpSound(key)
    local clip = LuckyJumpAssetBundleHandler.m_audioClips[key]
    if clip == nil then
        return nil
    end

    local audioSource = self:getSourceFromPool()
    audioSource.clip = clip
    audioSource.loop = false
    audioSource.volume = 1
    audioSource:Play()
    return audioSource
end

function Util.getLuckyJumpPrefab(fullPath)
    if GameConfig.PLATFORM_EDITOR_TEST then
        return CS.UnityEditor.AssetDatabase.LoadAssetAtPath(fullPath, typeof(Unity.GameObject))
    else
        return LuckyJumpAssetBundleHandler.m_mapPrefabs[string.lower(fullPath)]
    end
end

function GlobalAudioHandler:StopLuckyJumpMusic()
    SlotsGameLua.m_bReelPauseFlag = false

    self.m_AudioSourceExtraMusic:Stop()
    
    if ThemeLoader.themeKey == nil then
        -- 在大厅的情况
        if not self.musicAudioSource.isPlaying then
            self.musicAudioSource:Play()
        end
    end
    
end

function GlobalAudioHandler:PlayLuckyJumpMusic(key)
	if self.musicAudioSource.isPlaying then
		self.musicAudioSource:Stop()
    end

    if ThemeLoader.themeKey ~= nil then
        self:StopAllInGameAudio()
    end
    
    local clip = LuckyJumpAssetBundleHandler.m_audioClips[key]
    if clip == nil then
        Debug.Log("------clip == nil -- key: " .. key)
        return
    end

	self.m_AudioSourceExtraMusic.clip = clip
	self.m_AudioSourceExtraMusic.volume = 1.0
	self.m_AudioSourceExtraMusic.loop = true
	self.m_AudioSourceExtraMusic:Play ()
end