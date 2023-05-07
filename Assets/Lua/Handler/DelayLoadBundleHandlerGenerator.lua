DelayLoadBundleHandlerGenerator = {}
DelayLoadBundleHandlerGenerator.bundleName = nil

function DelayLoadBundleHandlerGenerator:New()
    local temp = {}
    self.__index = self
    setmetatable(temp, self)
    return temp
end

function DelayLoadBundleHandlerGenerator:Init(bundleName, mAudioHandler)
    if self.bundleName == bundleName then
        return
    end
    
    if self.bundleName ~= nil then
        self:UnBundle()
    end
    
    self.bundleName = bundleName
    self.mAudioHandler = mAudioHandler
    self.bDownLoading = false

    if not GameConfig.Instance.orUseAssetBundle then
        self.mAudioHandler:InitActivityAudio()
        self.mAudioHandler:AsyncLoadAllAudio()
    end

    self.bInit = true
end

function DelayLoadBundleHandlerGenerator:GetWebItem()
    if not GameConfig.Instance.orUseAssetBundle then
        return nil
    end

    local mThemeWebItemDic = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig.mActivityWebItemDic
    local mItem = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig:GetHotUpdateItem(mThemeWebItemDic, self.bundleName)
    return mItem
end

function DelayLoadBundleHandlerGenerator:orExistBundle()
    if not GameConfig.Instance.orUseAssetBundle then
        return true
    end

    return AssetBundleHandler:ContainsBundle(self.bundleName)
end

function DelayLoadBundleHandlerGenerator:orBundleCache()
    if not GameConfig.Instance.orUseAssetBundle then
        return true
    end

    local mItem = self:GetWebItem()
    Debug.Assert(mItem, self.bundleName)
    return mItem:IsVersionCached()
end

function DelayLoadBundleHandlerGenerator:StartDownloadAndLoadBundle()
    if not GameConfig.Instance.orUseAssetBundle then
        return
    end

    if self:orExistBundle() then
        return
    end

    if self.bDownLoading then
        return
    end 

    self.bDownLoading = true
    StartCoroutine(function()
        local mItem = self:GetWebItem()
        local url = mItem:GetUrl()
        local www = Unity.Networking.UnityWebRequestAssetBundle.GetAssetBundle(url, mItem:GetHash128())
        local mUnityWebRequestAsyncOperation = www:SendWebRequest()
        while not mUnityWebRequestAsyncOperation.isDone do
            local fProgress = mUnityWebRequestAsyncOperation.progress
            EventHandler:Brocast("onAssetbundleDownloading", self.bundleName, fProgress)
            yield_return(0)
        end 
        
        if www.result == Unity.Networking.UnityWebRequest.Result.Success then
            local bundle = Unity.Networking.DownloadHandlerAssetBundle.GetContent(www)
            AssetBundleManager.Instance:SaveBundleToDic(mItem.bundleName, bundle)
            local assetBundleRequest = bundle:LoadAllAssetsAsync(typeof(Unity.GameObject))
            yield_return(assetBundleRequest)
            self.mAudioHandler:InitActivityAudio()
            self.mAudioHandler:AsyncLoadAllAudio()
            EventHandler:Brocast("onAssetbundleDownloaded", self.bundleName)
        else
            EventHandler:Brocast("onAssetbundleDownloadError", self.bundleName)
        end

        www:Dispose()
        self.bDownLoading = false
    end)
end

function DelayLoadBundleHandlerGenerator:StartDownloadBundle()
    if not GameConfig.Instance.orUseAssetBundle then
        return
    end

    if self:orBundleCache() then
        return
    end
    
    if self.bDownLoading then
        return
    end 

    self.bDownLoading = true
    StartCoroutine(function()
        local mItem = self:GetWebItem()
        local url = mItem:GetUrl()
        local www = Unity.Networking.UnityWebRequestAssetBundle.GetAssetBundle(url, mItem:GetHash128())
        local mUnityWebRequestAsyncOperation = www:SendWebRequest()
        while not mUnityWebRequestAsyncOperation.isDone do
            local fProgress = mUnityWebRequestAsyncOperation.progress
            EventHandler:Brocast("onAssetbundleDownloading_"..self.bundleName, fProgress)
            yield_return(0)
        end

        if www.result == Unity.Networking.UnityWebRequest.Result.Success then
            EventHandler:Brocast("onAssetbundleDownloaded_"..self.bundleName)
        else
            EventHandler:Brocast("onAssetbundleDownloadError_"..self.bundleName)
        end

        www:Dispose()
        self.bDownLoading = false
    end)
end

function DelayLoadBundleHandlerGenerator:AsyncLoadBundle()
    if not GameConfig.Instance.orUseAssetBundle then
        return
    end

    if self:orExistBundle() then
        return
    end

    local mItem = self:GetWebItem()
    local url = mItem:GetUrl()
    local www = Unity.Networking.UnityWebRequestAssetBundle.GetAssetBundle(url, mItem:GetHash128())
    local mUnityWebRequestAsyncOperation = www:SendWebRequest()
    yield_return(mUnityWebRequestAsyncOperation)

    if www.result == Unity.Networking.UnityWebRequest.Result.Success then
        local bundle = Unity.Networking.DownloadHandlerAssetBundle.GetContent(www)
        AssetBundleManager.Instance:SaveBundleToDic(mItem.bundleName, bundle)
        local assetBundleRequest = bundle:LoadAllAssetsAsync(typeof(Unity.GameObject))
        yield_return(assetBundleRequest)
        self.mAudioHandler:InitActivityAudio()
        self.mAudioHandler:AsyncLoadAllAudio()
    end

    www:Dispose()
end

function DelayLoadBundleHandlerGenerator:UnBundle()
    if not GameConfig.Instance.orUseAssetBundle then
        return
    end

    if self.bundleName == nil then
        return
    end

    AssetBundleHandler:UnLoadBundle(self.bundleName, true)
    self.mAudioHandler:Release()
end
