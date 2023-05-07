require("Lua.Activity.RocketFortune.RocketFortuneConfig")
require("Lua.Activity.RocketFortune.RocketFortuneCompletedAllWinPop")
require("Lua.Activity.RocketFortune.RocketFortuneIntroducePop")
require("Lua.Activity.RocketFortune.RocketFortuneLevelManager")
require("Lua.Activity.RocketFortune.RocketFortuneLevelConfig")
require("Lua.Activity.RocketFortune.RocketFortuneWinPop")
require("Lua.Activity.RocketFortune.RocketFortuneMoreSpinPop")
require("Lua.Activity.RocketFortune.RocketFortuneGiftAddSpinPop")
require("Lua.Activity.RocketFortune.RocketFortuneGiftAddCoinsPop")
require("Lua.Activity.RocketFortune.RocketFortuneGiftAddMultiplePop")
require("Lua.Activity.RocketFortune.RocketFortuneGiftRocketsPop")
require("Lua.Activity.RocketFortune.RocketFortuneSendSpinPop")
require("Lua.Activity.RocketFortune.RocketFortuneIAPConfig")

local yield_return = (require 'cs_coroutine').yield_return

RocketFortuneUnloadedUI = {}
RocketFortuneUnloadedUI.m_entryBtn = nil
RocketFortuneUnloadedUI.m_logoBtn = nil 
RocketFortuneUnloadedUI.m_tipAni = nil
RocketFortuneUnloadedUI.m_bInitFlag = false

RocketFortuneUnloadedUI.m_imgDownloadProgress = nil
RocketFortuneUnloadedUI.m_rectTrProgress = nil
RocketFortuneUnloadedUI.m_textProgress = nil
RocketFortuneUnloadedUI.m_goMaxNumBg = nil
RocketFortuneUnloadedUI.m_nLastProgress = 0
RocketFortuneUnloadedUI.m_btnEntry = nil
RocketFortuneUnloadedUI.m_bIsReadyToPlay = false --记录是否显示ReadyToPlay弹窗

RocketFortuneUnloadedUI.m_coroutine = nil
RocketFortuneUnloadedUI.m_bIsActiveTime = false -- 是否在活动时间内

local LEVEL_FULLPROGRESS_HEIGHT = 312
local GetAddProgressConfig = {
    steps = {0, 1}, --0代表没获取，1代表获取
    probs = {5, 1}
}

function RocketFortuneUnloadedUI:Show(parent)
    --如果玩家已经全部玩完，隐藏入口
    if RocketFortuneDataHandler.data.bIsGetCompletedGift then
        return
    end
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:init(parent)
    end
    self.m_nLastProgress = RocketFortuneDataHandler.data.fAddSpinCountProgress
    self.transform.gameObject:SetActive(true)
    self:refreshUI(false)
    self:checkAndDownLoadAssetBundle()
end

function RocketFortuneUnloadedUI:checkAndDownLoadAssetBundle()
    local bundleInfo = ActivityBundleHandler.m_bundleInfo
    if bundleInfo.downloadStatus == DownloadStatus.Downloaded then
        self.m_goLoaded:SetActive(true)
        self.m_goUnloaded:SetActive(false)
        return
    end
    ActivityBundleHandler:checkAndDownload()
end

function RocketFortuneUnloadedUI:init(parent)
    local prefab = Util.getHotPrefab("Assets/BaseHotAdd/Active/RocketFortune/RocketFortuneUnloadedUI.prefab")
        self.transform.gameObject = Unity.Object.Instantiate(prefab)
        self.transform = self.transform.gameObject.transform
        self.transform:SetParent(parent)
        self.transform.localScale = Unity.Vector3.one
        self.transform.anchoredPosition3D = Unity.Vector3.zero
        
        self.m_unlockedTip = self.transform:FindDeepChild("Tip").gameObject
        self.m_tipAni = self.transform:FindDeepChild("TiShi"):GetComponent(typeof(Unity.Animator))
        local tipText = self.transform:FindDeepChild("TipText"):GetComponent(typeof(TextMeshProUGUI))
        tipText.text = "UNLOCK AT LEVEL "..RocketFortuneDataHandler.m_nUnlockLevel
        
        self.m_logoCountGo = self.transform:FindDeepChild("CountBg").gameObject
        self.m_logoSpinCount = self.transform:FindDeepChild("LogoSpinCount"):GetComponent(typeof(TextMeshProUGUI))
        self.m_spinCountText = self.transform:FindDeepChild("SpinCount"):GetComponent(typeof(TextMeshProUGUI))

        self.m_hideDetailBtn = self.transform:FindDeepChild("ButShou"):GetComponent(typeof(UnityUI.Button))
        self.m_hideDetailBtn.onClick:AddListener(function()
            self:onHideDetailAniClicked()
        end)
        DelegateCache:addOnClickButton(self.m_hideDetailBtn)
        self.m_logoBtn = self.transform:FindDeepChild("LOGO"):GetComponent(typeof(UnityUI.Button))
        --self.m_logoBtn.interactable = false
        self.m_logoBtn.onClick:AddListener(function()
            self:onShowDetailAniClicked()
            -- self:onLogoBtnClicked()
        end)
        DelegateCache:addOnClickButton(self.m_logoBtn)
        self.m_entryBtn = self.transform:FindDeepChild("EntryBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_entryBtn.interactable = false
        self.m_entryBtn.onClick:AddListener(function()
            self:onRocketFortuneClicked()
        end)
        DelegateCache:addOnClickButton(self.m_entryBtn)

        self.m_goLoaded = self.transform:FindDeepChild("LOGO").gameObject

        self.m_imgProgress = self.transform:FindDeepChild("Progress"):GetComponent(typeof(UnityUI.Image))
        self.m_littleTextProgress = self.transform:FindDeepChild("LittleProgressText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_goUnloaded = self.transform:FindDeepChild("RocketFortuneUnloaded").gameObject
        self.m_goUnloaded:SetActive(true)

        self.m_imgDownloadProgress = self.m_goUnloaded:GetComponent(typeof(UnityUI.Image))
        self.m_imgDownloadProgress.fillAmount = 1
        self.m_aniEntryUI = self.transform:FindDeepChild("ShouJiUIAni"):GetComponent(typeof(Unity.Animator))

        self.m_textProgress = self.transform:FindDeepChild("BigProgressText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_rectTrProgress = self.transform:FindDeepChild("ProgressBar"):GetComponent(typeof(Unity.RectTransform))
        self.m_goMaxNumBg = self.transform:FindDeepChild("MaxinumSpinsReached").gameObject

        EventHandler:AddListener(self, "AddBaseSpin")
        EventHandler:AddListener(self, "onActiveAssetbundleDownloading")
        EventHandler:AddListener(self, "onActiveAssetbundleDownloaded")
        EventHandler:AddListener(self, "onActiveTimesUp")

        ActivityHelper:addDataObserver("nAction", self, 
        function(self, nAction)
            self.m_goMaxNumBg:SetActive(nAction >= RocketFortuneDataHandler.m_nMaxSpinCount)
            self.m_spinCountText.text = nAction
            self.m_logoSpinCount.text = nAction               
            if nAction > 0 then
                self.m_spinCountText.text = nAction.." SPINS\nSAVED"
            else
                self.m_spinCountText.text = "FULL TO PLAY"
            end
        end)
end

function RocketFortuneUnloadedUI:hide()
    if self.transform ~= nil then
        self.transform.gameObject:SetActive(false)
    end
end

function RocketFortuneUnloadedUI:onLogoBtnClicked()
    GlobalAudioHandler:PlayRocketFortuneSound("click")
    local nLevel = PlayerHandler.nLevel
    if nLevel < RocketFortuneDataHandler.m_nUnlockLevel then
        if not self.m_unlockedTip.gameObject.activeSelf then
            self.m_unlockedTip.gameObject:SetActive(true)
            LeanTween.delayedCall(2.3, function()
                self.m_unlockedTip.gameObject:SetActive(false)
            end)
        end
        return
    end
    local isActiveShow = RocketFortuneDataHandler:checkIsActiveTime()
    if not isActiveShow then
        self.transform.gameObject:SetActive(false)
        return
    end

    RocketFortuneMainUIPop:Show()
end

function RocketFortuneUnloadedUI:onShowDetailAniClicked()
    -- local nLevel = PlayerHandler.nLevel
    -- if nLevel < RocketFortuneDataHandler.m_nUnlockLevel then
    --     if not self.m_unlockedTip.gameObject.activeSelf then
    --         self.m_unlockedTip.gameObject:SetActive(true)
    --         LeanTween.delayedCall(2.3, function()
    --             self.m_unlockedTip.gameObject:SetActive(false)
    --         end)
    --     end
    --     return
    -- end
    if ThemeLoader.themeKey == nil then
        RocketFortuneMainUIPop:Show()
        return
    end
    if self.m_aniEntryUI:GetInteger("nPlayMode") == 1 then
        RocketFortuneMainUIPop:Show()
        return
    end
    self.m_aniEntryUI:SetInteger("nPlayMode", 1)
end

function RocketFortuneUnloadedUI:onHideDetailAniClicked()
    self.m_aniEntryUI:SetInteger("nPlayMode", 2)
end

function RocketFortuneUnloadedUI:onRocketFortuneClicked()
    if ActiveThemeEntry:orInMove() then
        return
    end
    local isActiveShow = RocketFortuneDataHandler:checkIsActiveTime()
    if not isActiveShow then
        self.transform.gameObject:SetActive(false)
        return
    end

    local nLevel = PlayerHandler.nLevel
    if nLevel < RocketFortuneDataHandler.m_nUnlockLevel then
        if not self.m_unlockedTip.gameObject.activeSelf then
            self.m_unlockedTip.gameObject:SetActive(true)
            LeanTween.delayedCall(2.3, function()
                self.m_unlockedTip.gameObject:SetActive(false)
            end)
        end
        return
    end

    -- local nAction = RocketFortuneDataHandler.data.nAction
    -- if nAction <= 0 then
    --     if not self.m_tipAni.gameObject.activeSelf then
    --         self.m_tipAni.gameObject:SetActive(true)
    --         LeanTween.delayedCall(2.3, function()
    --             self.m_tipAni.gameObject:SetActive(false)
    --         end)
    --     end
    --     return
    -- end

    RocketFortuneMainUIPop:Show()
end

function RocketFortuneUnloadedUI:OnDestroy()
    NotificationHandler:removeObserver(self)
end

function RocketFortuneUnloadedUI:AddBaseSpin(data)
    if ActivityBundleHandler.m_bundleInfo.downloadStatus ~= DownloadStatus.Downloaded then return end
    if PlayerHandler.nLevel < ActiveManager.nUnlockLevel then return end

    if RocketFortuneDataHandler.data.bIsGetCompletedGift then
        if self.transform ~= nil then
            Unity.Object.Destroy(self.transform.gameObject)
        end
        return
    end

    --当玩家加载好了资源，但没有显示界面时，返回，数据不记录
    if not self.m_bInitFlag then
        return
    end
    if not data.bFreeSpinFlag then
        local bIsGetProgress = ActivityHelper:isTriggerProgress(ActiveManager.activeType)
        if not bIsGetProgress then
            return
        end
        RocketFortuneDataHandler:refreshAddSpinProgress(data)
    end
end


function RocketFortuneUnloadedUI:refreshUI(isMax)
    if self.transform.gameObject == nil then
        return
    end

    -- local nAction = RocketFortuneDataHandler.data.nAction
    -- self.m_spinCountText.text = nAction
    -- self.m_logoSpinCount.text = nAction
    -- if nAction < 1 then
    --     self.m_logoCountGo:SetActive(false)
    -- elseif not self.m_logoCountGo.activeInHierarchy then
    --     self.m_logoCountGo:SetActive(true)
    -- end

    local fAddSpinCountProgress = RocketFortuneDataHandler.data.fAddSpinCountProgress

    self:beginProgressAnimation(fAddSpinCountProgress, isMax)

    -- if nAction > 0 then
    --     self.m_spinCountText.text = nAction.." SPINS\nSAVED"
    -- else
    --     self.m_spinCountText.text = "FULL TO PLAY"
    -- end
end

function RocketFortuneUnloadedUI:beginProgressAnimation(progress, isMax)
    local width = self.m_rectTrProgress.sizeDelta.x
    if not isMax then
        -- highlight animation
        LeanTween.value(self.m_nLastProgress, progress, 0.6):setOnUpdate(
            function(value)
                if self.transform.gameObject == nil then
                    return
                end
                self.m_rectTrProgress.sizeDelta = Unity.Vector2(width, LEVEL_FULLPROGRESS_HEIGHT * value)
                self.m_imgProgress.fillAmount = value
                local nTemp = math.floor(value * 1000)
                local fPercent = nTemp / 10.0

                if RocketFortuneDataHandler.data.nAction >= RocketFortuneDataHandler.m_nMaxSpinCount then
                    if not self.m_goMaxNumBg.activeInHierarchy then
                        self.m_textProgress.gameObject:SetActive(false)
                        self.m_goMaxNumBg:SetActive(true)
                        self.m_rectTrProgress.sizeDelta = Unity.Vector2(width, LEVEL_FULLPROGRESS_HEIGHT)
                        self.m_imgProgress.fillAmount = 1
                        self.m_textProgress.text = string.format("%.1f%%", 100)
                        self.m_littleTextProgress.text = string.format("%.1f%%", 100)
                    end
                else
                    if not self.m_textProgress.gameObject.activeInHierarchy then
                        self.m_textProgress.gameObject:SetActive(true)
                        self.m_goMaxNumBg:SetActive(false)
                    end
                    self.m_textProgress.text = string.format("%.1f%%", fPercent)
                    self.m_littleTextProgress.text = string.format("%.1f%%", fPercent)
                end
            end
        )
    else
        local seq = LeanTween.sequence()
        seq:append(
            LeanTween.value(self.m_nLastProgress, 1.0, 0.2):setOnUpdate(
                function(value)
                    if self.transform.gameObject == nil then
                        return
                    end
                    self.m_rectTrProgress.sizeDelta = Unity.Vector2(width, LEVEL_FULLPROGRESS_HEIGHT * value)
                    self.m_imgProgress.fillAmount = value
                    local nTemp = math.floor(value * 1000)
                    local fPercent = nTemp / 10.0

                    self.m_textProgress.text = string.format("%.1f%%", fPercent)
                    self.m_littleTextProgress.text = string.format("%.1f%%", fPercent)
                end
            )
        )
        seq:append(
            LeanTween.value(1.0, 0, 0.8):setOnUpdate(
                function(value)
                    if self.transform.gameObject == nil then
                        return
                    end
                    self.m_rectTrProgress.sizeDelta = Unity.Vector2(width, LEVEL_FULLPROGRESS_HEIGHT * value)
                    self.m_imgProgress.fillAmount = value
                    local nTemp = math.floor(value * 1000)
                    local fPercent = nTemp / 10.0

                    self.m_textProgress.text = string.format("%.1f%%", fPercent)
                    self.m_littleTextProgress.text = string.format("%.1f%%", fPercent)
                end
            )
        )
        seq:append(
            LeanTween.value(0, progress, 0.2):setOnUpdate(
                function(value)
                    if self.transform.gameObject == nil then
                        return
                    end
                    self.m_rectTrProgress.sizeDelta = Unity.Vector2(width, LEVEL_FULLPROGRESS_HEIGHT * value)
                    self.m_imgProgress.fillAmount = value
                    local nTemp = math.floor(value * 1000)
                    local fPercent = nTemp / 10.0

                    self.m_textProgress.text = string.format("%.1f%%", fPercent)
                    self.m_littleTextProgress.text = string.format("%.1f%%", fPercent)
                end
            )
        )
    end
    self.m_nLastProgress = progress
end

function RocketFortuneUnloadedUI:onActiveAssetbundleDownloading(downloadProgress)  
    self.m_imgDownloadProgress.fillAmount = 1 - downloadProgress
end

function RocketFortuneUnloadedUI:onActiveAssetbundleDownloaded()  
    self.m_goLoaded:SetActive(true)
    self.m_goUnloaded:SetActive(false)
end

function RocketFortuneUnloadedUI:onActiveTimesUp()
    self.m_bAssetReady = false
    if self.CollectSplashUI.transform.gameObject then
        self.CollectSplashUI.transform.gameObject:SetActive(false)
    end
    if self.MaxReachedSplashUI.transform.gameObject then
        self.MaxReachedSplashUI.transform.gameObject:SetActive(false)
    end
end