require("Lua.Activity.ChutesRockets.ChutesRocketsMainUIPop")
require("Lua.Activity.ChutesRockets.ChutesRocketsDataHandler")
require("Lua.Activity.ChutesRockets.ChutesRocketsAssetBundleHandler")
require("Lua.Activity.ChutesRockets.ChutesRocketsCompletedAllWinPop")
require("Lua.Activity.ChutesRockets.ChutesRocketsIntroducePop")
require("Lua.Activity.ChutesRockets.ChutesRocketsLevelManager")
require("Lua.Activity.ChutesRockets.ChutesRocketsLevelConfig")
require("Lua.Activity.ChutesRockets.ChutesRocketsWinPop")
require("Lua.Activity.ChutesRockets.ChutesRocketsMoreSpinPop")
require("Lua.Activity.ChutesRockets.ChutesRocketsGiftAddSpinPop")
require("Lua.Activity.ChutesRockets.ChutesRocketsGiftAddCoinsPop")
require("Lua.Activity.ChutesRockets.ChutesRocketsGiftAddMultiplePop")
require("Lua.Activity.ChutesRockets.ChutesRocketsGiftRocketsPop")
require("Lua.Activity.ChutesRockets.ChutesRocketsChoiceLevelPop")
require("Lua.Activity.ChutesRockets.ChutesRocketsSendSpinPop")
require("Lua.Activity.ChutesRockets.ChutesRocketsIAPConfig")

local yield_return = (require 'cs_coroutine').yield_return

ChutesRocketsUnloadedUI = {}
ChutesRocketsUnloadedUI.m_entryBtn = nil
ChutesRocketsUnloadedUI.m_logoBtn = nil 
ChutesRocketsUnloadedUI.m_tipAni = nil
ChutesRocketsUnloadedUI.m_bInitFlag = false

ChutesRocketsUnloadedUI.m_imgDownloadProgress = nil
ChutesRocketsUnloadedUI.m_rectTrProgress = nil
ChutesRocketsUnloadedUI.m_textProgress = nil
ChutesRocketsUnloadedUI.m_goMaxNumBg = nil
ChutesRocketsUnloadedUI.m_nLastProgress = 0
ChutesRocketsUnloadedUI.m_btnEntry = nil
ChutesRocketsUnloadedUI.m_bIsMaxSpinCount = false
ChutesRocketsUnloadedUI.m_bIsReadyToPlay = false --记录是否显示ReadyToPlay弹窗

ChutesRocketsUnloadedUI.m_coroutine = nil
ChutesRocketsUnloadedUI.m_bIsActiveTime = false -- 是否在活动时间内

local LEVEL_FULLPROGRESS_HEIGHT = 312
local GetAddProgressConfig = {
    steps = {0, 1}, --0代表没获取，1代表获取
    probs = {5, 1}
}

function ChutesRocketsUnloadedUI:Show(parent)
    --如果玩家已经全部玩完，隐藏入口
    if ChutesRocketsDataHandler.data.bIsGetCompletedGift then
        return
    end
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:init(parent)
    end
    self.m_nLastProgress = ChutesRocketsDataHandler.data.fAddSpinCountProgress
    self.transform.gameObject:SetActive(true)
    self:refreshUI(false)
    self:checkAndDownLoadAssetBundle()
end

function ChutesRocketsUnloadedUI:checkAndDownLoadAssetBundle()
    local bundleInfo = ActivityBundleHandler.m_bundleInfo
    if bundleInfo.downloadStatus == DownloadStatus.Downloaded then
        self.m_goLoaded:SetActive(true)
        self.m_goUnloaded:SetActive(false)
        return
    end
    ActivityBundleHandler:checkAndDownload()
end

function ChutesRocketsUnloadedUI:init(parent)
    local prefab = Util.getHotPrefab("Assets/BaseHotAdd/Active/ChutesRockets/ChutesRocketsUnloadedUI.prefab")
        self.transform.gameObject = Unity.Object.Instantiate(prefab)
        self.transform = self.transform.gameObject.transform
        self.transform:SetParent(parent)
        self.transform.localScale = Unity.Vector3.one
        self.transform.anchoredPosition3D = Unity.Vector3.zero
        
        self.m_unlockedTip = self.transform:FindDeepChild("Tip").gameObject
        self.m_tipAni = self.transform:FindDeepChild("TiShi"):GetComponent(typeof(Unity.Animator))
        local tipText = self.transform:FindDeepChild("TipText"):GetComponent(typeof(TextMeshProUGUI))
        tipText.text = "UNLOCK AT LEVEL "..ChutesRocketsDataHandler.m_nUnlockLevel
        
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
            self:onChutesRocketsClicked()
        end)
        DelegateCache:addOnClickButton(self.m_entryBtn)

        self.m_goLoaded = self.transform:FindDeepChild("LOGO").gameObject

        self.m_imgProgress = self.transform:FindDeepChild("Progress"):GetComponent(typeof(UnityUI.Image))
        self.m_littleTextProgress = self.transform:FindDeepChild("LittleProgressText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_goUnloaded = self.transform:FindDeepChild("ChutesRocketsUnloaded").gameObject
        self.m_goUnloaded:SetActive(true)

        self.m_imgDownloadProgress = self.m_goUnloaded:GetComponent(typeof(UnityUI.Image))
        self.m_imgDownloadProgress.fillAmount = 1
        self.m_aniEntryUI = self.transform:FindDeepChild("ShouJiUIAni"):GetComponent(typeof(Unity.Animator))

        self.m_textProgress = self.transform:FindDeepChild("BigProgressText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_rectTrProgress = self.transform:FindDeepChild("ProgressBar"):GetComponent(typeof(Unity.RectTransform))
        self.m_goMaxNumBg = self.transform:FindDeepChild("MaxinumSpinsReached").gameObject

        EventHandler:AddListener(self, "AddBaseSpin")
        EventHandler:AddListener(self, "BaseGameSpinEnd")
        EventHandler:AddListener(self, "onActiveAssetbundleDownloading")
        EventHandler:AddListener(self, "onActiveAssetbundleDownloaded")
        EventHandler:AddListener(self, "onActiveTimesUp")

        ActivityHelper:addDataObserver("nAction", self, 
        function(self, nAction)
            self.m_goMaxNumBg:SetActive(nAction >= ChutesRocketsDataHandler.m_nMaxSpinCount)
            if nAction >= ChutesRocketsDataHandler.m_nMaxSpinCount then
                self.m_bIsMaxSpinCount = true
            end

            self.m_spinCountText.text = nAction
            self.m_logoSpinCount.text = nAction               
            if nAction > 0 then
                self.m_spinCountText.text = nAction.." SPINS\nSAVED"
            else
                self.m_spinCountText.text = "FULL TO PLAY"
            end
        end)
end

function ChutesRocketsUnloadedUI:hide()
    if self.transform ~= nil then
        self.transform.gameObject:SetActive(false)
    end
end

function ChutesRocketsUnloadedUI:onLogoBtnClicked()
    GlobalAudioHandler:PlayChutesRocketsSound("click")
    local nLevel = PlayerHandler.nLevel
    if nLevel < ChutesRocketsDataHandler.m_nUnlockLevel then
        if not self.m_unlockedTip.gameObject.activeSelf then
            self.m_unlockedTip.gameObject:SetActive(true)
            LeanTween.delayedCall(2.3, function()
                self.m_unlockedTip.gameObject:SetActive(false)
            end)
        end
        return
    end
    local isActiveShow = ChutesRocketsDataHandler:checkIsActiveTime()
    if not isActiveShow then
        self.transform.gameObject:SetActive(false)
        return
    end

    ChutesRocketsMainUIPop:Show()
end

function ChutesRocketsUnloadedUI:onShowDetailAniClicked()
    -- local nLevel = PlayerHandler.nLevel
    -- if nLevel < ChutesRocketsDataHandler.m_nUnlockLevel then
    --     if not self.m_unlockedTip.gameObject.activeSelf then
    --         self.m_unlockedTip.gameObject:SetActive(true)
    --         LeanTween.delayedCall(2.3, function()
    --             self.m_unlockedTip.gameObject:SetActive(false)
    --         end)
    --     end
    --     return
    -- end
    if ThemeLoader.themeKey == nil then
        ChutesRocketsMainUIPop:Show()
        return
    end
    if self.m_aniEntryUI:GetInteger("nPlayMode") == 1 then
        ChutesRocketsMainUIPop:Show()
        return
    end
    self.m_aniEntryUI:SetInteger("nPlayMode", 1)
end

function ChutesRocketsUnloadedUI:onHideDetailAniClicked()
    self.m_aniEntryUI:SetInteger("nPlayMode", 2)
end

function ChutesRocketsUnloadedUI:onChutesRocketsClicked()
    if ActiveThemeEntry:orInMove() then
        return
    end
    local isActiveShow = ChutesRocketsDataHandler:checkIsActiveTime()
    if not isActiveShow then
        self.transform.gameObject:SetActive(false)
        return
    end

    local nLevel = PlayerHandler.nLevel
    if nLevel < ChutesRocketsDataHandler.m_nUnlockLevel then
        if not self.m_unlockedTip.gameObject.activeSelf then
            self.m_unlockedTip.gameObject:SetActive(true)
            LeanTween.delayedCall(2.3, function()
                self.m_unlockedTip.gameObject:SetActive(false)
            end)
        end
        return
    end

    -- local nAction = ChutesRocketsDataHandler.data.nAction
    -- if nAction <= 0 then
    --     if not self.m_tipAni.gameObject.activeSelf then
    --         self.m_tipAni.gameObject:SetActive(true)
    --         LeanTween.delayedCall(2.3, function()
    --             self.m_tipAni.gameObject:SetActive(false)
    --         end)
    --     end
    --     return
    -- end

    ChutesRocketsMainUIPop:Show()
end

function ChutesRocketsUnloadedUI:OnDestroy()
    NotificationHandler:removeObserver(self)
end

function ChutesRocketsUnloadedUI:AddBaseSpin(data)
    if not GameConfig.CHUTESROCKETS_FLAG then
        return
    end
    if not ChutesRocketsAssetBundleHandler.m_bAssetReady then
        return
    end
    local userLevel = PlayerHandler.nLevel
    if userLevel < ChutesRocketsDataHandler.m_nUnlockLevel then
        return
    end

    if not ChutesRocketsDataHandler:checkIsActiveTime() then
        return
    end

    if ChutesRocketsDataHandler.data.bIsGetCompletedGift then
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
        local bIsGetProgress = ActivityHelper:isTriggerProgress(ActiveType.ChutesRockets)
    
        if not bIsGetProgress then
            return
        end
        ChutesRocketsDataHandler:refreshAddSpinProgress(data)
    end
end

function ChutesRocketsUnloadedUI:BaseGameSpinEnd(data)
    if not GameConfig.CHUTESROCKETS_FLAG then
        return
    end
    if not ChutesRocketsAssetBundleHandler.m_bAssetReady then
        return
    end

    if not ChutesRocketsDataHandler:checkIsActiveTime() then
        return
    end

    local userLevel = PlayerHandler.nLevel
    if userLevel < ChutesRocketsDataHandler.m_nUnlockLevel then
        return
    end

    if ChutesRocketsDataHandler.data.bIsGetCompletedGift then
        return
    end
    
    --当玩家加载好了资源，但没有显示界面时，返回，数据不记录
    if not self.m_bInitFlag then
        return
    end

    local bRespinFlag = false
    local bFreeSpinFlag = false
    bRespinFlag = SlotsGameLua.m_GameResult:InReSpin()
    bFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()

    if bRespinFlag or bFreeSpinFlag then
        return
    end

    if not self.m_bIsReadyToPlay then
        return
    end

    self.m_bIsReadyToPlay = false
    SceneSlotGame.m_bUIState = true -- 不会开始下一次spin 不管是手动操作还是Auto下
    LeanTween.delayedCall(0.5, function()
        SceneSlotGame.m_bUIState = false
        if self.m_bIsMaxSpinCount then
            ChutesRocketsMaxSpinCountPop:Show()
        else
            ChutesRocketsReadyToPlayPop:Show()
        end
    end)
end

function ChutesRocketsUnloadedUI:refreshUI(isMax)
    if self.transform.gameObject == nil then
        return
    end

    -- local nAction = ChutesRocketsDataHandler.data.nAction
    -- self.m_spinCountText.text = nAction
    -- self.m_logoSpinCount.text = nAction
    -- if nAction < 1 then
    --     self.m_logoCountGo:SetActive(false)
    -- elseif not self.m_logoCountGo.activeInHierarchy then
    --     self.m_logoCountGo:SetActive(true)
    -- end

    local fAddSpinCountProgress = ChutesRocketsDataHandler.data.fAddSpinCountProgress

    self:beginProgressAnimation(fAddSpinCountProgress, isMax)

    -- if nAction > 0 then
    --     self.m_spinCountText.text = nAction.." SPINS\nSAVED"
    -- else
    --     self.m_spinCountText.text = "FULL TO PLAY"
    -- end
end

function ChutesRocketsUnloadedUI:beginProgressAnimation(progress, isMax)
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

                if ChutesRocketsDataHandler.data.nAction >= ChutesRocketsDataHandler.m_nMaxSpinCount then
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

function ChutesRocketsUnloadedUI:onActiveAssetbundleDownloading(downloadProgress)  
    self.m_imgDownloadProgress.fillAmount = 1 - downloadProgress
end

function ChutesRocketsUnloadedUI:onActiveAssetbundleDownloaded()  
    self.m_goLoaded:SetActive(true)
    self.m_goUnloaded:SetActive(false)
end

function ChutesRocketsUnloadedUI:onActiveTimesUp()
    self.m_bAssetReady = false
    if self.CollectSplashUI.transform.gameObject then
        self.CollectSplashUI.transform.gameObject:SetActive(false)
    end
    if self.MaxReachedSplashUI.transform.gameObject then
        self.MaxReachedSplashUI.transform.gameObject:SetActive(false)
    end
end