local VideoThemeEntryItem = {}

local E_DOWNLOAD_STATE = {
    NODOWNLOAD = 1,
    DOWNLOADING = 2,
    DOWNLOADED = 3,
}

function VideoThemeEntryItem:New(go, configItem)
    local temp = {}
    self.__index = self
    setmetatable(temp, self)

    temp:Init(go, configItem)
    return temp
end

function VideoThemeEntryItem:Init(go, configItem)
    self.transform = go.transform
    self.transform.localScale = Unity.Vector3.one * 1.35
    self.configItem = configItem
    
    self.goLock = self.transform:FindDeepChild("LockContainer").gameObject
    self.goDownload = self.transform:FindDeepChild("DownloadContainer").gameObject
    self.imageGrayBg = self.transform:FindDeepChild("DownloadGrayBG"):GetComponent(typeof(UnityUI.Image))
    self.goTapDownloadTip = self.transform:FindDeepChild("TapDownloadText").gameObject

    self.textTapDownloadTip = self.transform:FindDeepChild("TapDownloadText"):GetComponent(typeof(TextMeshProUGUI))
    self.textUnLockLevel = self.transform:FindDeepChild("levelUnlock"):GetComponent(typeof(TextMeshProUGUI))

    self.textTapDownloadTip.text = "Tap Download"

    self.bStartDownloading = false
    self.bUnLock = true
    self.nUnLockLevel = self:GetUnLockLevel()
    self.textUnLockLevel.text = self.nUnLockLevel
    self:SetUnLockStateWhenLevelUp()
    self:RefreshState()

    local clickBtn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    clickBtn.onClick:AddListener(function()
        self:OnClickBtn()
    end)

    LobbyView.tableVideoThemeEntry[self.configItem.themeName] = self
end

function VideoThemeEntryItem:GetUnLockLevel()
    local nUnLockLevel = 0
    return nUnLockLevel
end

function VideoThemeEntryItem:SetUnLockStateWhenLevelUp()
    self.bUnLock = PlayerHandler.nLevel >= self.nUnLockLevel
    if ThemeUnLockHandler:orUnLockAllTheme() then
        self.bUnLock = true
    end
    self:RefreshState()
end

function VideoThemeEntryItem:CheckOrDownloading()
    if self.nDownloadState == E_DOWNLOAD_STATE.DOWNLOADING then 
        return true
    end

    if self.nDownloadState == E_DOWNLOAD_STATE.NODOWNLOAD then         
        self.bStartDownloading = true
        self:RefreshState()
        self:RequestWebThemeBundle()
        return true
    end

    return false
end

function VideoThemeEntryItem:OnClickBtn()
    if not self.bUnLock then
        return
    end
    
    if self.nDownloadState == E_DOWNLOAD_STATE.NODOWNLOAD then
        GlobalAudioHandler:PlayBtnSound()
        self.bStartDownloading = true
        self:RefreshState()
        self:RequestWebThemeBundle()
    elseif self.nDownloadState == E_DOWNLOAD_STATE.DOWNLOADING then

    elseif self.nDownloadState == E_DOWNLOAD_STATE.DOWNLOADED then
        GlobalAudioHandler:PlayBtnSound()
        ThemeLoader:LoadGame(self.configItem)
    else
        Debug.Assert(false)
    end

end

function VideoThemeEntryItem:RefreshState()
    if GameConfig.Instance.orUseAssetBundle then
        if self.bUnLock then
            self.goLock:SetActive(false)
            self.nDownloadState = E_DOWNLOAD_STATE.NODOWNLOAD
            local bCache = false
            local bundleName = ThemeHelper:GetThemeBundleName(self.configItem.themeName)
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
                self.goDownload:SetActive(true)
                self.goTapDownloadTip:SetActive(true)
            elseif self.nDownloadState == E_DOWNLOAD_STATE.DOWNLOADING then
                self.goTapDownloadTip:SetActive(false)
                self.goDownload:SetActive(true)
            elseif self.nDownloadState == E_DOWNLOAD_STATE.DOWNLOADED then
                self.goDownload:SetActive(false)
            else
                Debug.Assert(false)
            end
        else
            self.goTapDownloadTip:SetActive(false)
            self.goDownload:SetActive(true)
            self.goLock:SetActive(true)
        end

    else
        if self.bUnLock then
            self.nDownloadState = E_DOWNLOAD_STATE.DOWNLOADED
            self.goDownload:SetActive(false)
            self.goLock:SetActive(false)
        else
            self.goTapDownloadTip:SetActive(false)
            self.goDownload:SetActive(true)
            self.goLock:SetActive(true)
        end
    end
    
end

function VideoThemeEntryItem:ShowDownloadProgress(fProgress)
    self.imageGrayBg.fillAmount = 1.0 - fProgress
end

function VideoThemeEntryItem:RequestWebThemeBundle()
    StartCoroutine(function()
        if GameConfig.Instance.orUseAssetBundle then
            local bundleName =  ThemeHelper:GetThemeBundleName(self.configItem.themeName)
            local mThemeWebItemDic = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig.mThemeWebItemDic
            local mItem = CS.AssetBundleConfig.Instance.mAssetBundleHotUpdateConfig:GetHotUpdateItem(mThemeWebItemDic, bundleName)
            local url = mItem:GetUrl()
            local bCache = mItem:IsVersionCached()
            local www = Unity.Networking.UnityWebRequestAssetBundle.GetAssetBundle(url, mItem:GetHash128())
            local mUnityWebRequestAsyncOperation = www:SendWebRequest()
            while not mUnityWebRequestAsyncOperation.isDone do
                self:ShowDownloadProgress(mUnityWebRequestAsyncOperation.progress)
                yield_return(0)
            end     

            if www.result == Unity.Networking.UnityWebRequest.Result.Success then
                self:ShowDownloadProgress(1.0)
                local bCache = mItem:IsVersionCached()
                Debug.Assert(bCache)
            else
                self:ShowDownloadProgress(0.0)
            end
            www:Dispose()
                
            self.bStartDownloading = false
            self:RefreshState()
        end
    end)
end

return VideoThemeEntryItem