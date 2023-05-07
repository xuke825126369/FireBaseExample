require("Lua.BuildGame.BuildGameAssetBundleHandler")
require("Lua.BuildGame.BuildGameMainUIPop")
require("Lua.BuildGame.BuildGameDataHandler")
require("Lua.BuildGame.BuildGameAllProbTable")
require("Lua.BuildGame.BuildGameManager")
require("Lua.BuildGame.BuildGameConfig")
require("Lua.BuildGame.BuildGameGetDepotsPop")
require("Lua.BuildGame.BuildGameShowAddProgressPop")

local yield_return = (require 'cs_coroutine').yield_return

BuildGameUnloadedUI = {}

BuildGameUnloadedUI.m_gameObject = nil
BuildGameUnloadedUI.m_transform = nil
BuildGameUnloadedUI.m_entryBtn = nil
BuildGameUnloadedUI.m_tipAni = nil
BuildGameUnloadedUI.m_bInitFlag = false
BuildGameUnloadedUI.loadingBg = nil

BuildGameUnloadedUI.m_imgDownloadProgress = nil

BuildGameUnloadedUI.m_coroutine = nil

BuildGameUnloadedUI.m_bAssetReady = false -- 每次登入游戏都检查一下..

function BuildGameUnloadedUI:Show()
    --检查是否处于活动时间
    if (not GameConfig.BUILDGAME_FLAG) or (not BuildGameDataHandler:checkIsActiveTime()) then
        if not self.m_bInitFlag then
            self.m_bInitFlag = true
            self.m_gameObject = LobbyView.transform:FindDeepChild("BottomBuildCity").gameObject
            self.m_transform = self.m_gameObject.transform
            local tr = self.m_transform:FindDeepChild("DownloadProgress")
            self.m_imgDownloadProgress = tr:GetComponent(typeof(UnityUI.Image))
            self.m_imgDownloadProgress.fillAmount = 1
            local goComingSoon = self.m_gameObject.transform:FindDeepChild("BuildCityComingSoonTip").gameObject
            goComingSoon:SetActive(true)
        end
        return
    end

    if not self.m_bInitFlag then
        self.m_bInitFlag = true

        self.m_gameObject = LobbyView.transform:FindDeepChild("BottomBuildCity").gameObject
        self.m_transform = self.m_gameObject.transform

        self.m_tipAni = self.m_transform:FindDeepChild("Tip"):GetComponent(typeof(Unity.Animator))
        local tipText = self.m_transform:FindDeepChild("TipText"):GetComponent(typeof(TextMeshProUGUI))
        tipText.text = "UNLOCK AT LEVEL "..BuildGameDataHandler.m_nUnlockLevel
        self.m_entryBtn = self.m_transform:FindDeepChild("EntryBtn")
        self.m_entryBtn.gameObject:SetActive(false)
        self.m_entryBtn:GetComponentInChildren(typeof(UnityUI.Button)).onClick:AddListener(function()
            self:loadingBtnOnClicked()
        end)

        self.m_goUnloaded = self.m_transform:FindDeepChild("BuildCityUnloaded").gameObject
        self.m_goUnloaded:SetActive(true)

        local tr = self.m_transform:FindDeepChild("DownloadProgress")
        self.m_imgDownloadProgress = tr:GetComponent(typeof(UnityUI.Image))
        self.m_imgDownloadProgress.fillAmount = 1

        self.m_bAssetReady = false
       LuaAutoBindMonoBehaviour.Bind(self.m_gameObject,self)
        BuildGameDataHandler:init()
        BuildGameManager:init()
    end
    
    self:checkAndDownLoadBuildGameAssetBundle() -- 检查资源是否有了。。没有就开下载并且初始化进度条信息..
end

function BuildGameUnloadedUI:loadingBtnOnClicked()
    AudioHandler:PlayBtnSound()
    local nLevel = PlayerHandler.nLevel
    if nLevel < BuildGameDataHandler.m_nUnlockLevel then
        if not self.m_tipAni.gameObject.activeSelf then
            self.m_tipAni.gameObject:SetActive(true)
            LeanTween.delayedCall(2.3, function()
                self.m_tipAni.gameObject:SetActive(false)
            end)
        end
        return
    end
    BuildGameMainUIPop:createAndShow()
end

function BuildGameUnloadedUI:hide()
    self.m_gameObject:SetActive(false)
end

function BuildGameUnloadedUI:Update(dt)
    if not GameConfig.BUILDGAME_FLAG then
        return
    end

    if self.m_bAssetReady then
        return
    end
    -- 资源没有下载完..
    local bundleInfo = BuildGameAssetBundleHandler.m_bundleInfo
    
    if not bundleInfo.isUIUpdated then
        local downloadProgress = bundleInfo.downloadingProgress
        if bundleInfo.downloadStatus == DownloadStatus.NotStart then
            downloadProgress = 0.0
            
        elseif bundleInfo.downloadStatus == DownloadStatus.Downloaded then
            downloadProgress = 1.0
            self:refreshButtonStatus()
        else
            -- 正在下...
        end

        self.m_imgDownloadProgress.fillAmount = 1 - downloadProgress
        bundleInfo.isUIUpdated = true
    end
end

function BuildGameUnloadedUI:checkAndDownLoadBuildGameAssetBundle()
    if not GameConfig.BUILDGAME_FLAG then
        return
    end

    local bundleInfo = BuildGameAssetBundleHandler.m_bundleInfo
    if bundleInfo.downloadStatus == DownloadStatus.Downloaded then
        self:refreshButtonStatus()
        return
    end
    BuildGameAssetBundleHandler:checkAndDownload()
end

function BuildGameUnloadedUI:refreshButtonStatus()
    -- 已经有资源了或者下载好了之后来到这里
    local bundleInfo = BuildGameAssetBundleHandler.m_bundleInfo
    if bundleInfo.downloadStatus ~= DownloadStatus.Downloaded then
        return
    end
    
    if self.m_coroutine == nil then
        self.m_coroutine = StartCoroutine(function()
            self.m_imgDownloadProgress.fillAmount = 0
            self.m_imgDownloadProgress.gameObject:SetActive(false)
            while bundleInfo.downloadStatus ~= DownloadStatus.Downloaded do
                yield_return(0)
            end
            Debug.Log("BuildGameAssets Download Sccuess!!!!!!!!")
            self.m_entryBtn.gameObject:SetActive(true)
            self.m_goUnloaded:SetActive(false)
        end)
    end
end