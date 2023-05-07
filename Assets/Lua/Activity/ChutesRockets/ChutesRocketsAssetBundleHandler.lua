local yield_return = (require 'cs_coroutine').yield_return
ChutesRocketsAssetBundleHandler = {}

ChutesRocketsAssetBundleHandler.m_bundleInfo = {}
ChutesRocketsAssetBundleHandler.m_mapPrefabs = {}

ChutesRocketsAssetBundleHandler.m_audioClips = {} -- key: 文件名 value: ..

ChutesRocketsAssetBundleHandler.m_bPrefabLoaded = false
ChutesRocketsAssetBundleHandler.m_bAudioLoaded = false
ChutesRocketsAssetBundleHandler.m_bAssetReady = false

function ChutesRocketsAssetBundleHandler:initBundleInfo()
    if not GameConfig.CHUTESROCKETS_FLAG then
        return
    end

    if not self:IsActiveTime() then
        return
    end
    
    self.m_bPrefabLoaded = false
    self.m_bAudioLoaded = false
    self.m_bAssetReady = false

    local data = GameConfigHandler.gameConfig.ChutesRocketsAssetBundle
    local bundleInfo = BundleInfo:new()
    bundleInfo.key = data.key
    bundleInfo.url = data.url == "" and "" or GameConfig.SERVER_ROOT..data.url
    bundleInfo.type = data.type
    bundleInfo.version = data.version
    bundleInfo.downloadStatus = self:isAssetBundleDownloaded(bundleInfo) and DownloadStatus.Downloaded or DownloadStatus.NotStart
    self.m_bundleInfo = bundleInfo
end

function ChutesRocketsAssetBundleHandler:isAssetBundleDownloaded(bundleInfo)
    if (GameConfig.PLATFORM_EDITOR or bundleInfo.url == "") then
        return true
    end
    return Unity.Caching.IsVersionCached(bundleInfo.url, bundleInfo.version)
end

function ChutesRocketsAssetBundleHandler:checkAndDownload()
    if GameConfig.PLATFORM_EDITOR then
        --如果是在编辑器模式下
        self:unzipChutesRocketsAssetBundle()
        self.m_bAssetReady = true
        return
    end

    local bundleInfo = self.m_bundleInfo
    if bundleInfo.downloadStatus == DownloadStatus.Downloading then
        -- 当状态为正在下载，不执行后面
        Debug.Log("ChutesRockets Downloading")
        return
    end

    -- 检测是否有该version缓存
    local bCacheFlag = Unity.Caching.IsVersionCached(bundleInfo.url, bundleInfo.version)
    if bCacheFlag then
        local url = bundleInfo.url
        local co = StartCoroutine(function()
            bundleInfo.downloadStatus = DownloadStatus.Downloading
            local www = Unity.WWW.LoadFromCacheOrDownload(url, bundleInfo.version)
            Debug.Log("ChutesRockets Downloading form Cache")
            yield_return(www)
            bundleInfo.assetBundle = www.assetBundle
            bundleInfo.downloadStatus = DownloadStatus.Downloaded

            self:unzipChutesRocketsAssetBundle()

            local waitTime = Unity.WaitForSeconds(0.5)
            Debug.Log("ChutesRockets Downloaded form Cache")
            while (not self.m_bAudioLoaded) or (not self.m_bPrefabLoaded) do
                yield_return(waitTime)
            end
            
            -- 到这资源才算是加载完可以使用了
            self.m_bAssetReady = true
            Debug.Log("ChutesRockets unzip form Cache")
        end)
    else
        self:downloadChutesRocketsAsset(bundleInfo)
    end
end

function ChutesRocketsAssetBundleHandler:downloadChutesRocketsAsset(bundleInfo)
    bundleInfo.downloadStatus = DownloadStatus.Downloading
    
    local co = StartCoroutine(function()
        local request = CS.UnityEngine.Networking.UnityWebRequestAssetBundle.GetAssetBundle(bundleInfo.url, bundleInfo.version, 0)
        request:SendWebRequest()
        local waitTime = Unity.WaitForSeconds(0.05)
        Debug.Log("ChutesRockets begin Download")
        while (not request.isDone) do
            yield_return(waitTime)
        end
        if request.isDone then
            bundleInfo.assetBundle = request.downloadHandler.assetBundle
            bundleInfo.downloadStatus = self:isAssetBundleDownloaded(bundleInfo) and DownloadStatus.Downloaded or DownloadStatus.NotStart
            
            self:unzipChutesRocketsAssetBundle()

            local waitTime = Unity.WaitForSeconds(0.5)
            Debug.Log("ChutesRockets Downloaded")
            while (not self.m_bAudioLoaded) or (not self.m_bPrefabLoaded) do
                yield_return(waitTime)
            end
            
            -- 到这资源才算是加载完可以使用了
            self.m_bAssetReady = true
            Debug.Log("ChutesRockets unziped")
        end
    end)
end

function ChutesRocketsAssetBundleHandler:unzipChutesRocketsAssetBundle()
    if not GameConfig.PLATFORM_EDITOR then
        self:loadAllPrefabs()
    else
        self.m_bPrefabLoaded = true
    end
    
    self:loadAudioClips()
end

function ChutesRocketsAssetBundleHandler:loadAllPrefabs()
    -- 不在编辑器模式下解压 加载Prefab
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

    local co = StartCoroutine(function()
        for k,v in pairs(prefabPathArray) do
            local assetPath = v
            local assetBundleRequest = self.m_bundleInfo.assetBundle:LoadAssetAsync(assetPath, typeof(Unity.GameObject))
            yield_return(assetBundleRequest)

            self.m_mapPrefabs[assetPath] = assetBundleRequest.asset
        end

        self.m_bPrefabLoaded = true
    end)
end

function ChutesRocketsAssetBundleHandler:loadAudioClips()
    local audioClips = {}
    if GameConfig.PLATFORM_EDITOR then
        local guids = CS.UnityEditor.AssetDatabase.FindAssets("", {"Assets/ActiveNeedLoad/ChutesRockets/Audio"})
        for i = 0, guids.Length-1 do
            local path = CS.UnityEditor.AssetDatabase.GUIDToAssetPath(guids[i])
            audioClips[i+1] = CS.UnityEditor.AssetDatabase.LoadAssetAtPath(path, typeof(Unity.AudioClip))
        end

        for i,v in ipairs(audioClips) do
            self.m_audioClips[v.name] = v
        end

        self.m_bAudioLoaded = true
        return
    end

    local co = StartCoroutine(function()
        local assetBundleRequest = self.m_bundleInfo.assetBundle:LoadAllAssetsAsync(typeof(Unity.AudioClip))
        Debug.Log("ChutesRockets audio begin unzip")
        yield_return(assetBundleRequest)

        local audioArray = assetBundleRequest.allAssets

        if audioArray.Length > 0 then
            for i = 0, audioArray.Length-1 do
                audioClips[i+1] = audioArray[i]
            end
        end

        for i,v in ipairs(audioClips) do
            self.m_audioClips[v.name] = v
        end

        self.m_bAudioLoaded = true
        Debug.Log("ChutesRockets audio unziped")
    end)

end

function GlobalAudioHandler:PlayChutesRocketsSound(key)
    local clip = ChutesRocketsAssetBundleHandler.m_audioClips[key]
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

function GlobalAudioHandler:StopChutesRocketsMusic()
    SlotsGameLua.m_bReelPauseFlag = false

    self.m_AudioSourceExtraMusic:Stop()
    
    if ThemeLoader.themeKey == nil then
        -- 在大厅的情况
        if not self.musicAudioSource.isPlaying then
            self.musicAudioSource:Play()
        end
    end
    
end

function GlobalAudioHandler:PlayChutesRocketsMusic(key)
	if self.musicAudioSource.isPlaying then
		self.musicAudioSource:Stop()
    end

    if ThemeLoader.themeKey ~= nil then
        self:StopAllInGameAudio()
    end
    
    local clip = ChutesRocketsAssetBundleHandler.m_audioClips[key]
    if clip == nil then
        Debug.Log("------clip == nil -- key: " .. key)
        return
    end

	self.m_AudioSourceExtraMusic.clip = clip
	self.m_AudioSourceExtraMusic.volume = 1.0
	self.m_AudioSourceExtraMusic.loop = true
	self.m_AudioSourceExtraMusic:Play ()
end

function Util.getChutesRocketsPrefab(fullPath)
    if GameConfig.PLATFORM_EDITOR then
        return CS.UnityEditor.AssetDatabase.LoadAssetAtPath(fullPath, typeof(Unity.GameObject))
    else
        return ChutesRocketsAssetBundleHandler.m_mapPrefabs[string.lower(fullPath)]
    end
end

function ChutesRocketsAssetBundleHandler:IsActiveTime()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    for i, v in ipairs(ChutesRocketsDataHandler.ACTIVETIME) do
        local fromStr = v.from
        local toStr = v.to
        local fromSecond = TimeHandler:GetTimeStampFromDateString(fromStr)
        local toSecond = TimeHandler:GetTimeStampFromDateString(toStr)
        if (nowSecond >= fromSecond) then
            if nowSecond < toSecond then
                -- 活动期间
                return true
            end
        end
    end

    return false
end