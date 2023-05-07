local VideoThemeRootEntryItem = {}

local E_DOWNLOAD_STATE = {
    NODOWNLOAD = 1,
    DOWNLOADING = 2,
    DOWNLOADED = 3,
}

function VideoThemeRootEntryItem:New(go, configItem)
    local temp = {}
    self.__index = self
    setmetatable(temp, self)
    temp:Init(go, configItem)
    return temp
end

function VideoThemeRootEntryItem:Init(go, configItem)
    self.transform = go.transform
    self.configItem = configItem
    self.themeKey = configItem.themeName

    self:ShowPrepareLoadingEntry()
    
    self.bStartDownloading = false
    self:RefreshState()
    LobbyView.tableVideoThemeRootEntry[self.configItem.themeName] = self
end

function VideoThemeRootEntryItem:CheckOrDownloading()
    if self.nDownloadState == E_DOWNLOAD_STATE.DOWNLOADING then 
        return true
    end

    if self.nDownloadState == E_DOWNLOAD_STATE.NODOWNLOAD then         
        self.bStartDownloading = true
        self:RefreshState()
        self:AsyncRequestLoadBundle()
        return true
    end 
    
    return false
end

function VideoThemeRootEntryItem:RefreshState()
    if GameConfig.Instance.orUseAssetBundle then
        self.nDownloadState = E_DOWNLOAD_STATE.NODOWNLOAD
        local bCache = false
        local bundleName = self:GetBundleName()
        local mThemeWebItemDic = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig.mThemeWebItemDic
        local mItem = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig:GetHotUpdateItem(mThemeWebItemDic, bundleName)
        if mItem then
            bCache = mItem:IsVersionCached()
        end

        if bCache then
            self.nDownloadState = E_DOWNLOAD_STATE.DOWNLOADED
        else
            if self.bStartDownloading then
                self.nDownloadState = E_DOWNLOAD_STATE.DOWNLOADING
            else
                self.nDownloadState = E_DOWNLOAD_STATE.NODOWNLOAD
            end
        end

        if self.nDownloadState == E_DOWNLOAD_STATE.NODOWNLOAD then
            
        elseif self.nDownloadState == E_DOWNLOAD_STATE.DOWNLOADING then

        elseif self.nDownloadState == E_DOWNLOAD_STATE.DOWNLOADED then
            self:ShowLoadedEntry()
        else
            Debug.Assert(false)
        end
    else
        self.nDownloadState = E_DOWNLOAD_STATE.DOWNLOADED
        self:ShowLoadedEntry()
    end
    
end

function VideoThemeRootEntryItem:ShowPrepareLoadingEntry()
    if not self.goPrepareLoadingEntry then
        local bundleName = ThemeHelper:GetThemeCommonBundleName(self.configItem)
        local assetPath = "Assets/ResourceABs/ThemeVideoCommon/Prefabs/VideoThemeEntryLoading.prefab"
        if ThemeHelper:isClassicLevel(self.configItem.themeName) then
            assetPath = "Assets/ResourceABs/ThemeClassicCommon/Prefabs/ClassicThemeEntryLoading.prefab"
        end

        AssetBundleHandler:LoadAsset(bundleName, assetPath)
        local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
        local goPrepareLoadingEntry = Unity.Object.Instantiate(goPrefab)
        goPrepareLoadingEntry.transform:SetParent(self.transform, false)
        goPrepareLoadingEntry.transform.localScale = Unity.Vector3.one
        goPrepareLoadingEntry.transform.localPosition = Unity.Vector3.zero
        goPrepareLoadingEntry:SetActive(true)
        self.goPrepareLoadingEntry = goPrepareLoadingEntry
    end

end

function VideoThemeRootEntryItem:ShowLoadedEntry()
    StartCoroutine(function()
        local bundleName = self:GetBundleName()
        if GameConfig.Instance.orUseAssetBundle then
            local mThemeWebItemDic = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig.mThemeWebItemDic
            local mItem = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig:GetHotUpdateItem(mThemeWebItemDic, bundleName)
            if mItem then
                local url = mItem:GetUrl()
                local www = Unity.Networking.UnityWebRequestAssetBundle.GetAssetBundle(url, mItem:GetHash128())
                yield_return(www:SendWebRequest())    
                if www.result == Unity.Networking.UnityWebRequest.Result.Success then
                    local bundle = Unity.Networking.DownloadHandlerAssetBundle.GetContent(www)
                    AssetBundleManager.Instance:SaveBundleToDic(mItem.bundleName, bundle)
                end
                www:Dispose()
            end
        end
        
        if self.goPrepareLoadingEntry ~= nil then
            Unity.Object.Destroy(self.goPrepareLoadingEntry)
            self.goPrepareLoadingEntry = nil
        end

        if not self.goThemeEntryItem then
            local bundleName = self:GetBundleName()
            local assetPath = "Assets/ResourceABs/ThemeVideoEntry/"..self.themeKey.."/smallEntry.prefab"
            if ThemeHelper:isClassicLevel(self.configItem.themeName) then
                assetPath = "Assets/ResourceABs/ThemeClassicEntry/"..self.themeKey.."/smallEntry.prefab"
            end
            
            local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
            local goPanel = Unity.Object.Instantiate(goPrefab)
            goPanel.transform:SetParent(self.transform, false)
            goPanel.transform.localScale = Unity.Vector3.one
            goPanel.transform.localPosition = Unity.Vector3.zero
            goPanel:SetActive(true)

            local VideoThemeEntryItemGenerator = require "Lua/LobbyScene/VideoThemeEntryItem"
            VideoThemeEntryItemGenerator:New(goPanel, self.configItem)
            self.goThemeEntryItem = goPanel
        end
    end)
    
end

function VideoThemeRootEntryItem:GetBundleName()
    return ThemeHelper:GetThemeEntryBundleName(self.configItem)
end

function VideoThemeRootEntryItem:AsyncRequestLoadBundle()
    StartCoroutine(function()
        if GameConfig.Instance.orUseAssetBundle then
            local bundleName = self:GetBundleName()
            local mThemeWebItemDic = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig.mThemeWebItemDic
            local mItem = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig:GetHotUpdateItem(mThemeWebItemDic, bundleName)
            if mItem then
                local url = mItem:GetUrl()
                local www = Unity.Networking.UnityWebRequestAssetBundle.GetAssetBundle(url, mItem:GetHash128())
                yield_return(www:SendWebRequest())    
                if www.result == Unity.Networking.UnityWebRequest.Result.Success then
                    local bCache = mItem:IsVersionCached()
                    Debug.Assert(bCache)
                end
                www:Dispose()
            end

            self.bStartDownloading = false
            self:RefreshState()
        end
    end)
end

return VideoThemeRootEntryItem