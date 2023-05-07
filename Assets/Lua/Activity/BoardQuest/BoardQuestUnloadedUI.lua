require("Lua.Activity.BoardQuest.BoardQuestConfig")
require("Lua.Activity.BoardQuest.BoardQuestIAPConfig")

BoardQuestUnloadedUI = {}
BoardQuestUnloadedUI.bCollectNotify = true --进度条收集满时的弹窗是否弹出
BoardQuestUnloadedUI.m_imgDownloadProgress = nil
BoardQuestUnloadedUI.m_coroutine = nil
BoardQuestUnloadedUI.m_bAssetReady = false -- 每次登入游戏都检查一下.

function BoardQuestUnloadedUI:Show(parent)
    self:init(parent)
    local fFillAmount = BoardQuestDataHandler.data.fProgress
    if BoardQuestDataHandler.data.nAction >= BoardQuestConfig.N_MAX_ACTION then
        fFillAmount = 1
    end
    self.m_imgAddProgress.fillAmount = fFillAmount
    self:checkAndDownLoadAssetBundle() -- 检查资源是否有了。。没有就开下载并且初始化进度条信息..
end

function BoardQuestUnloadedUI:checkAndDownLoadAssetBundle()
    local bundleInfo = ActivityBundleHandler.m_bundleInfo
    if bundleInfo.downloadStatus == DownloadStatus.Downloaded then
        self.m_goLoaded:SetActive(true)
        self.m_goUnloaded:SetActive(false)
        return
    end
    ActivityBundleHandler:checkAndDownload()
end

function BoardQuestUnloadedUI:init(parent)
    self.m_bAssetReady = false
    local prefab = Util.getHotPrefab("Assets/BaseHotAdd/Active/BoardQuest/BoardQuestUnloadedUI.prefab")
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
        if ActiveThemeEntry:orInMove() then
           return
        end
        GlobalAudioHandler:PlayBtnSound()
        BoardQuestMainUIPop:Show()
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

    NotificationHandler:removeObserver(self)
    EventHandler:AddListener(self, "AddBaseSpin")
    EventHandler:AddListener(self, "onActiveAssetbundleDownloading")
    EventHandler:AddListener(self, "onActiveAssetbundleDownloaded")
    EventHandler:AddListener(self, "onActiveTimesUp")

    self.CollectSplashUI = require("Lua.Activity.BoardQuest.CollectSplashUI")
    self.MaxReachedSplashUI = require("Lua.Activity.BoardQuest.MaxReachedSplashUI")

    ActivityHelper:addDataObserver("nAction", self, 
    function(self, nAction)
        self.m_goCountContainer:SetActive(nAction > 0)
        self.m_textCount.text = nAction
        if self.m_goMaximum.activeSelf and nAction < BoardQuestConfig.N_MAX_ACTION then
            self.m_imgAddProgress.fillAmount = 0
        end
        self.m_goMaximum:SetActive(nAction >= BoardQuestConfig.N_MAX_ACTION)
    end)
end

function BoardQuestUnloadedUI:hide()
    self.transform.gameObject:SetActive(false)
end

function BoardQuestUnloadedUI:onClicked()
    GlobalAudioHandler:PlayBtnSound()
end

function BoardQuestUnloadedUI:AddBaseSpin(data)
    if ActiveManager.activeType ~= ActiveType.BoardQuest then return end
    if PlayerHandler.nLevel < ActiveManager.nUnlockLevel then return end
    if ActivityBundleHandler.m_bundleInfo.downloadStatus ~= DownloadStatus.Downloaded then return end
    
    if not data.bFreeSpinFlag then
        local bIsGetProgress = ActivityHelper:isTriggerProgress(ActiveType.BoardQuest)
        if not bIsGetProgress then
            return
        end

        if BoardQuestDataHandler.data.nAction >= BoardQuestConfig.N_MAX_ACTION then
            if BoardQuestUnloadedUI.bCollectNotify then
                LeanTween.delayedCall(0.4, function()
                    self.MaxReachedSplashUI:Show()
                end)
            end
        else
            local isMax, isActionReachMax = BoardQuestDataHandler:refreshAddSpinProgress(data)
            self:CollectEffect()
            LeanTween.delayedCall(1.4, function()
                self:refreshUI(isMax, isActionReachMax)
            end)
        end
    end
end

function BoardQuestUnloadedUI:refreshUI(isMax, isActionReachMax)
    if self.transform.gameObject == nil then
        return
    end
    local fProgress = BoardQuestDataHandler.data.fProgress
    if isActionReachMax then
        isMax = false
        fProgress = 1
    end
    self:beginProgressAnimation(fProgress, isMax, isActionReachMax)
end

--进度条的动画
function BoardQuestUnloadedUI:beginProgressAnimation(progress, isMax, isActionReachMax)
    if isActionReachMax then
        local id = LeanTween.value(self.m_imgAddProgress.fillAmount, progress, 0.6):setOnUpdate(function(value)
            if self.transform.gameObject == nil then
                return
            end
            self.m_imgAddProgress.fillAmount = value
        end):setOnComplete(function()
            ActivityHelper:AddMsgCountData("nAction", 0)
            self.MaxReachedSplashUI:Show()
        end).id
        table.insert(ActivityHelper.m_LeanTweenIDs, id)
    else
        if not isMax then
            -- highlight animation
            local id = LeanTween.value(self.m_imgAddProgress.fillAmount, progress, 0.6):setOnUpdate(function(value)
                if self.transform.gameObject == nil then
                    return
                end
                self.m_imgAddProgress.fillAmount = value
            end).id
            table.insert(ActivityHelper.m_LeanTweenIDs, id)
        else
            local seq = LeanTween.sequence()
            seq:append(LeanTween.value(self.m_imgAddProgress.fillAmount, 1.0, 0.2):setOnUpdate(function(value)
                if self.transform.gameObject == nil then
                    return
                end
                self.m_imgAddProgress.fillAmount = value
            end):setOnComplete(function()
                ActivityHelper:AddMsgCountData("nAction", 0)
                self.CollectSplashUI:Show()
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
            local id = seq.id
            table.insert(ActivityHelper.m_LeanTweenIDs, id)
        end
    end
end

function BoardQuestUnloadedUI:CollectEffect()
    local pos = ActivityHelper:GetDeckCenter()
    local go = ActivityHelper:GetPrefabFromPool("Animation/collect.prefab")
    go:SetActive(false)
    go.transform.position = pos
    go:SetActive(true)
    ActivityHelper:GetComponentInChildren(go, Unity.Animator):Play("Show", 0, 0)
    
    local goRed = ActivityHelper:FindDeepChild(go, "hongse/ani")
    local goGreen = ActivityHelper:FindDeepChild(go, "lvse/ani")
    local goBlue = ActivityHelper:FindDeepChild(go, "lanse/ani")
    local goPurple = ActivityHelper:FindDeepChild(go, "zise/ani")

    goRed.transform.localPosition = Unity.Vector3.zero
    goGreen.transform.localPosition = Unity.Vector3.zero
    goBlue.transform.localPosition = Unity.Vector3.zero
    goPurple.transform.localPosition = Unity.Vector3.zero

    goRed.transform.localScale = Unity.Vector3.one
    goGreen.transform.localScale = Unity.Vector3.one
    goBlue.transform.localScale = Unity.Vector3.one
    goPurple.transform.localScale = Unity.Vector3.one

    local id = LeanTween.move(goRed, self.transform.position, 0.5):setDelay(0.75):setEase(LeanTweenType.easeInQuad).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)
    local id = LeanTween.move(goGreen, self.transform.position, 0.5):setDelay(0.82):setEase(LeanTweenType.easeInQuad).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)
    local id = LeanTween.move(goBlue, self.transform.position, 0.5):setDelay(0.89):setEase(LeanTweenType.easeInQuad).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)
    local id = LeanTween.move(goPurple, self.transform.position, 0.5):setDelay(0.96):setEase(LeanTweenType.easeInQuad).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)

    local id = LeanTween.scale(goRed, Unity.Vector3.zero, 0.55):setDelay(0.75):setEase(LeanTweenType.easeInQuad).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)
    local id = LeanTween.scale(goGreen, Unity.Vector3.zero, 0.55):setDelay(0.81):setEase(LeanTweenType.easeInQuad).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)
    local id = LeanTween.scale(goBlue, Unity.Vector3.zero, 0.55):setDelay(0.87):setEase(LeanTweenType.easeInQuad).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)
    local id = LeanTween.scale(goPurple, Unity.Vector3.zero, 0.55):setDelay(0.93):setEase(LeanTweenType.easeInQuad).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)

    local id = LeanTween.delayedCall(1.05, function()
        self.m_aniHit = self.m_aniHit or self.transform:GetComponentInChildren(typeof(Unity.Animator))
        if self.m_aniHit then self.m_aniHit:Play("Hit", 0, 0) end
    end).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)
    local id = LeanTween.delayedCall(2, function()
        ActivityHelper:RecyclePrefabToPool(go)
    end).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)
end

function BoardQuestUnloadedUI:onActiveAssetbundleDownloading(downloadProgress)  
    self.m_imgDownloadProgress.fillAmount = 1 - downloadProgress
end

function BoardQuestUnloadedUI:onActiveAssetbundleDownloaded()  
    self.m_goLoaded:SetActive(true)
    self.m_goUnloaded:SetActive(false)
end

function BoardQuestUnloadedUI:onActiveTimesUp()
    self.m_bAssetReady = false
    if self.CollectSplashUI.transform.gameObject then
        self.CollectSplashUI.transform.gameObject:SetActive(false)
    end
    if self.MaxReachedSplashUI.transform.gameObject then
        self.MaxReachedSplashUI.transform.gameObject:SetActive(false)
    end
end