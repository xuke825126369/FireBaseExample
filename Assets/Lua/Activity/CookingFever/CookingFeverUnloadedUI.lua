--关卡里的入口
require("Lua.Activity.CookingFever.CookingFeverConfig")

local yield_return = (require 'cs_coroutine').yield_return

CookingFeverUnloadedUI = {}
CookingFeverUnloadedUI.m_entryBtn = nil
CookingFeverUnloadedUI.m_tipAni = nil
CookingFeverUnloadedUI.m_bInitFlag = false
CookingFeverUnloadedUI.m_imgDownloadProgress = nil
CookingFeverUnloadedUI.m_coroutine = nil
CookingFeverUnloadedUI.m_bAssetReady = false -- 每次登入游戏都检查一下.
CookingFeverUnloadedUI.bCollectNotify = true --进度条收集满时的弹窗是否弹出

function CookingFeverUnloadedUI:Show(parent)
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:init(parent)
    end
    local fFillAmount = CookingFeverDataHandler.data.fProgress
    if CookingFeverDataHandler.data.nAction >= CookingFeverConfig.N_MAX_ACTION then
        fFillAmount = 1
    end
    self.m_imgAddProgress.fillAmount = fFillAmount

    self:checkAndDownLoadAssetBundle() -- 检查资源是否有了。。没有就开下载并且初始化进度条信息..
end

function CookingFeverUnloadedUI:checkAndDownLoadAssetBundle()
    local bundleInfo = ActivityBundleHandler.m_bundleInfo
    if bundleInfo.downloadStatus == DownloadStatus.Downloaded then
        self.m_goLoaded:SetActive(true)
        self.m_goUnloaded:SetActive(false)
        return
    end
    ActivityBundleHandler:checkAndDownload()
end

function CookingFeverUnloadedUI:init(parent)
    local prefab = Util.getHotPrefab("Assets/BaseHotAdd/Active/CookingFever/CookingFeverUnloadedUI.prefab")
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
        CookingFeverMainUIPop:Show()
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

    self.m_bAssetReady = false

    NotificationHandler:removeObserver(self)
    EventHandler:AddListener(self, "AddBaseSpin")
    EventHandler:AddListener(self, "onActiveAssetbundleDownloading")
    EventHandler:AddListener(self, "onActiveAssetbundleDownloaded")
    EventHandler:AddListener(self, "onActiveTimesUp")

    ActivityHelper:addDataObserver("nAction", self, 
    function(self, nAction)
        self.m_goCountContainer:SetActive(nAction > 0)
        self.m_textCount.text = nAction
        if self.m_goMaximum.activeSelf and nAction < CookingFeverConfig.N_MAX_ACTION then
            self.m_imgAddProgress.fillAmount = 0
        end
        self.m_goMaximum:SetActive(nAction >= CookingFeverConfig.N_MAX_ACTION)
    end)

    self.CollectSplashUI = require("Lua.Activity.CookingFever.CollectSplashUI")
    self.MaxReachedSplashUI = require("Lua.Activity.CookingFever.MaxReachedSplashUI")
end

function CookingFeverUnloadedUI:hide()
    self.transform.gameObject:SetActive(false)
end

function CookingFeverUnloadedUI:onClicked()
    GlobalAudioHandler:PlayBtnSound()
end

function CookingFeverUnloadedUI:AddBaseSpin(data)
    if ActiveManager.activeType ~= ActiveType.CookingFever then return end
    if PlayerHandler.nLevel < ActiveManager.nUnlockLevel then return end
    if ActivityBundleHandler.m_bundleInfo.downloadStatus ~= DownloadStatus.Downloaded then return end
    --当玩家加载好了资源，但没有显示界面时，返回，数据不记录
    if not self.m_bInitFlag then return end

    if not data.bFreeSpinFlag then
        local bIsGetProgress = ActivityHelper:isTriggerProgress(ActiveType.CookingFever)
        if not bIsGetProgress then
            return
        end
        if CookingFeverDataHandler.data.nAction >= CookingFeverConfig.N_MAX_ACTION then
            if CookingFeverUnloadedUI.bCollectNotify then
                LeanTween.delayedCall(0.4, function()
                    self.MaxReachedSplashUI:Show(true)
                end)
            end
        else
            local isMax, isCoinReachMax = CookingFeverDataHandler:refreshAddSpinProgress(data)
            self:CollectEffect()
            LeanTween.delayedCall(1.4, function()
                self:refreshUI(isMax, isCoinReachMax)
            end)
        end
    end
end

function CookingFeverUnloadedUI:refreshUI(isMax, isActionReachMax)
    if self.transform.gameObject == nil then
        return
    end
    local fProgress = CookingFeverDataHandler.data.fProgress
    if isActionReachMax then
        isMax = false
        fProgress = 1
    end
    self:beginProgressAnimation(fProgress, isMax, isActionReachMax)
end

--进度条的动画
function CookingFeverUnloadedUI:beginProgressAnimation(progress, isMax, isActionReachMax)
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
                
            end))
        end
    end
end

function CookingFeverUnloadedUI:CollectEffect()
    local pos = ActivityHelper:GetDeckCenter()
    local go = ActivityHelper:GetPrefabFromPool("Animation/collect.prefab")
    go:SetActive(false)
    go.transform.position = pos
    go:SetActive(true)
    for i = 1, 4 do
        local goCoin = ActivityHelper:FindDeepChild(go, "coin"..i)
        goCoin.transform.localScale = Unity.Vector3.one
        goCoin.transform.localPosition = Unity.Vector3.zero

        LeanTween.move(goCoin, self.transform.position, 0.5):setDelay(0.68 + i * 0.07):setEase(LeanTweenType.easeInQuad)
        LeanTween.scale(goCoin, Unity.Vector3.zero, 0.6):setDelay(0.68 + i * 0.07):setEase(LeanTweenType.easeInQuad)
    end

    LeanTween.delayedCall(1.4, function()
        self.m_aniHit = self.m_aniHit or self.transform:GetComponentInChildren(typeof(Unity.Animator))
        self.m_aniHit:Play("Hit", 0, 0)
    end)

    LeanTween.delayedCall(2.2, function()
        ActivityHelper:RecyclePrefabToPool(go)
    end)
end

function CookingFeverUnloadedUI:onActiveAssetbundleDownloading(downloadProgress)  
    self.m_imgDownloadProgress.fillAmount = 1 - downloadProgress
end

function CookingFeverUnloadedUI:onActiveAssetbundleDownloaded()  
    self.m_goLoaded:SetActive(true)
    self.m_goUnloaded:SetActive(false)
end

function CookingFeverUnloadedUI:onActiveTimesUp()
    self.m_bAssetReady = false
    if self.CollectSplashUI.transform.gameObject then
        self.CollectSplashUI.transform.gameObject:SetActive(false)
    end
    if self.MaxReachedSplashUI.transform.gameObject then
        self.MaxReachedSplashUI.transform.gameObject:SetActive(false)
    end
end