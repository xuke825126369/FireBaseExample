require("Lua.Activity.RainbowPick.RainbowPickConfig")
require("Lua.Activity.RainbowPick.RainbowPickIAPConfig")

RainbowPickUnloadedUI = {}
RainbowPickUnloadedUI.m_bInitFlag = false
RainbowPickUnloadedUI.m_imgDownloadProgress = nil
RainbowPickUnloadedUI.m_coroutine = nil
RainbowPickUnloadedUI.m_bAssetReady = false -- 每次登入游戏都检查一下..
RainbowPickUnloadedUI.bCollectNotify = true --进度条收集满时的弹窗是否弹出

function RainbowPickUnloadedUI:Show(parent)
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:init(parent)
    end
    local fFillAmount = RainbowPickDataHandler.data.fProgress
    if RainbowPickDataHandler.data.nAction >= RainbowPickConfig.N_MAX_ACTION then
        fFillAmount = 1
    end
    self.m_imgAddProgress.fillAmount = fFillAmount
    self:checkAndDownLoadAssetBundle() -- 检查资源是否有了。。没有就开下载并且初始化进度条信息..
end

function RainbowPickUnloadedUI:init(parent)
    local prefab = Util.getHotPrefab("Assets/BaseHotAdd/Active/RainbowPick/RainbowPickUnloadedUI.prefab")
    Debug.Assert(prefab)
    self.transform.gameObject = Unity.Object.Instantiate(prefab)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(parent)
    self.transform.localScale = Unity.Vector3.one * 0.6
    self.transform.anchoredPosition3D = Unity.Vector3.zero

    self.m_goLoaded = self.transform:FindDeepChild("Loaded").gameObject
    self.m_goUnloaded = self.transform:FindDeepChild("Unloaded").gameObject

    local playBtn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(playBtn)
    playBtn.onClick:AddListener(function()
        Debug.Log(tostring(ActiveThemeEntry:orInMove()))
        if ActiveThemeEntry:orInMove() then
            return
        end
        GlobalAudioHandler:PlayBtnSound()
        RainbowPickMainUIPop:Show()
    end)

    self.m_goLoaded:SetActive(false)
    self.m_goUnloaded:SetActive(true)

    local tr = self.transform:FindDeepChild("DownloadProgress")
    self.m_imgDownloadProgress = tr:GetComponent(typeof(UnityUI.Image))
    self.m_imgDownloadProgress.fillAmount = 1

    self.m_imgAddProgress = self.transform:FindDeepChild("imgAddProgress"):GetComponent(typeof(UnityUI.Image)) --添加MoveCount收集的进度
    self.m_goCountContainer = self.transform:FindDeepChild("CountBg").gameObject
    self.m_textCount = self.transform:FindDeepChild("textCount"):GetComponent(typeof(TextMeshProUGUI))

    self.m_goMaximum = self.transform:FindDeepChild("Maximum").gameObject
    self.m_goMaximum:SetActive(false)

    self.m_bAssetReady = false

    NotificationHandler:removeObserver(self)
    EventHandler:AddListener(self, "AddBaseSpin")
    EventHandler:AddListener(self, "onActiveAssetbundleDownloading")
    EventHandler:AddListener(self, "onActiveAssetbundleDownloaded")
    EventHandler:AddListener(self, "onActiveTimesUp")

    ActivityHelper:addDataObserver("nAction", self, 
    function(self, nAction)
        self.m_goCountContainer:SetActive(nAction > 0)
        self.m_textCount.text = tostring(nAction)
        if self.m_goMaximum.activeSelf and nAction < RainbowPickConfig.N_MAX_ACTION then
            self.m_imgAddProgress.fillAmount = 0
        end
        self.m_goMaximum:SetActive(nAction >= RainbowPickConfig.N_MAX_ACTION)
    end)

    self.CollectSplashUI = require("Lua.Activity.RainbowPick.CollectSplashUI")
    self.MaxReachedSplashUI = require("Lua.Activity.RainbowPick.MaxReachedSplashUI")
end

function RainbowPickUnloadedUI:hide()
    self.transform.gameObject:SetActive(false)
end

function RainbowPickUnloadedUI:checkAndDownLoadAssetBundle()
    local bundleInfo = ActivityBundleHandler.m_bundleInfo
    if bundleInfo.downloadStatus == DownloadStatus.Downloaded then
        self.m_goLoaded:SetActive(true)
        self.m_goUnloaded:SetActive(false)
        return
    end
    ActivityBundleHandler:checkAndDownload()
end

function RainbowPickUnloadedUI:onClicked()
    GlobalAudioHandler:PlayBtnSound()
end

function RainbowPickUnloadedUI:AddBaseSpin(data)
    if ActiveManager.activeType ~= ActiveType.RainbowPick then return end
    if PlayerHandler.nLevel < ActiveManager.nUnlockLevel then return end
    if ActivityBundleHandler.m_bundleInfo.downloadStatus ~= DownloadStatus.Downloaded then return end

    --当玩家加载好了资源，但没有显示界面时，返回，数据不记录
    if not self.m_bInitFlag then
        return
    end

    if not data.bFreeSpinFlag then
        local bIsGetProgress = ActivityHelper:isTriggerProgress(ActiveType.RainbowPick)
        if not bIsGetProgress then
            return
        end

        if RainbowPickDataHandler.data.nAction >= RainbowPickConfig.N_MAX_ACTION then
            LeanTween.delayedCall(0.4, function()
                if RainbowPickUnloadedUI.bCollectNotify then
                    self.MaxReachedSplashUI:Show()
                end
            end)
        else
            local isMax, isActionReachMax = RainbowPickDataHandler:refreshAddSpinProgress(data)
            self:CollectEffect()
            LeanTween.delayedCall(1.1, function()
                self:refreshUI(isMax, isActionReachMax)
            end)
        end
    end
end

function RainbowPickUnloadedUI:refreshUI(isMax, isActionReachMax)
    if self.transform.gameObject == nil then
        return
    end
    local fProgress = RainbowPickDataHandler.data.fProgress
    if isActionReachMax then
        isMax = false
        fProgress = 1
    end
    self:beginProgressAnimation(fProgress, isMax, isActionReachMax)
end

--进度条的动画
function RainbowPickUnloadedUI:beginProgressAnimation(progress, isMax, isActionReachMax)
    if isActionReachMax then
        LeanTween.value(self.m_imgAddProgress.fillAmount, progress, 0.6):setOnUpdate(function(value)
            if self.transform.gameObject == nil then
                return
            end
            self.m_imgAddProgress.fillAmount = value
        end):setOnComplete(function()
            ActivityHelper:AddMsgCountData("nAction", 0)
            self.MaxReachedSplashUI:Show(isActionReachMax)
        end)
    else
        if not isMax then
            -- highlight animation
            LeanTween.value(self.m_imgAddProgress.fillAmount, progress, 0.6):setOnUpdate(function(value)
                if self.transform.gameObject == nil then
                    return
                end
                self.m_imgAddProgress.fillAmount = value
            end)
        else
            local seq = LeanTween.sequence()
            seq:append(LeanTween.value(self.m_imgAddProgress.fillAmount, 1.0, 0.2):setOnUpdate(function(value)
                if self.transform.gameObject == nil then
                    return
                end
                self.m_imgAddProgress.fillAmount = value
            end):setOnComplete(function()
                ActivityHelper:AddMsgCountData("nAction", 0)
                self.CollectSplashUI:Show(isActionReachMax)
            end))
            seq:append(LeanTween.value(1.0, 0, 0.8):setOnUpdate(function(value)
                if self.transform.gameObject == nil then
                    return
                end
                self.m_imgAddProgress.fillAmount = value
            end))
            seq:append(LeanTween.value(0, progress, 0.2):setOnUpdate(function(value)
                if self.transform.gameObject == nil then
                    return
                end
                self.m_imgAddProgress.fillAmount = value
            end):setOnComplete(function()
                --TODO 将入口变为Play按钮
            end))
        end
    end
end

function RainbowPickUnloadedUI:CollectEffect()
    local pos = ActivityHelper:GetDeckCenter()
    local go = ActivityHelper:GetPrefabFromPool("Animation/collect.prefab")
    go:SetActive(false)
    go.transform.position = pos
    go:SetActive(true)
    for i = 1, 4 do
        local goCoin = ActivityHelper:FindDeepChild(go, "coin"..i)
        goCoin.transform.localScale = Unity.Vector3.one
        goCoin.transform.localPosition = Unity.Vector3.zero

        LeanTween.move(goCoin, self.transform.position, 0.65):setDelay(0.6 + i * 0.07):setEase(LeanTweenType.easeInQuad)
        LeanTween.scale(goCoin, Unity.Vector3.one * 0.4, 0.75):setDelay(0.6 + i * 0.07):setEase(LeanTweenType.easeInQuad)
    end
    
    -- LeanTween.delayedCall(1.4, function()
    --     self.m_aniHit = self.m_aniHit or self.transform:GetComponentInChildren(typeof(Unity.Animator))
    --     self.m_aniHit:Play("Hit", 0, 0)
    -- end)

    LeanTween.delayedCall(1.5, function()
        ActivityHelper:RecyclePrefabToPool(go)
    end)
end

function RainbowPickUnloadedUI:onActiveAssetbundleDownloading(downloadProgress)  
    self.m_imgDownloadProgress.fillAmount = 1 - downloadProgress
end

function RainbowPickUnloadedUI:onActiveAssetbundleDownloaded()  
    self.m_goLoaded:SetActive(true)
    self.m_goUnloaded:SetActive(false)
end

function RainbowPickUnloadedUI:onActiveTimesUp()
    self.m_bAssetReady = false
    if self.CollectSplashUI.transform.gameObject then
        self.CollectSplashUI.transform.gameObject:SetActive(false)
    end
    if self.MaxReachedSplashUI.transform.gameObject then
        self.MaxReachedSplashUI.transform.gameObject:SetActive(false)
    end
end