require("Lua.Activity.LuckyJump.LuckyJumpConfig")
require("Lua.Activity.LuckyJump.LuckyJumpAssetBundleHandler")
require("Lua.Activity.LuckyJump.LuckyJumpDataHandler")
require("Lua.Activity.LuckyJump.LuckyJumpManager")
require("Lua.Activity.LuckyJump.LuckyJumpItem")
require("Lua.Activity.LuckyJump.LuckyJumpPickATilePop")
require("Lua.Activity.LuckyJump.LuckyJumpGamePop")
require("Lua.Activity.LuckyJump.LuckyJumpWinCollectPop")
require("Lua.Activity.LuckyJump.LuckyJumpOutOfMovePop")
require("Lua.Activity.LuckyJump.LuckyJumpIntroducePop")
require("Lua.Activity.LuckyJump.LuckyJumpPayTablePop")
require("Lua.Activity.LuckyJump.LuckyJumpEndPop")

local yield_return = (require 'cs_coroutine').yield_return

LuckyJumpUnloadedUI = {}
LuckyJumpUnloadedUI.m_entryBtn = nil
LuckyJumpUnloadedUI.m_tipAni = nil
LuckyJumpUnloadedUI.m_bInitFlag = false
LuckyJumpUnloadedUI.m_nLastProgress = 0

LuckyJumpUnloadedUI.m_imgDownloadProgress = nil

LuckyJumpUnloadedUI.m_coroutine = nil

LuckyJumpUnloadedUI.m_bAssetReady = false -- 每次登入游戏都检查一下..
local GetAddProgressConfig = {
    steps = {1, 2}, --1代表没获取，2代表获取
    probs = {10, 1}
}

function LuckyJumpUnloadedUI:show(parent)
    local isActiveShow = LuckyJumpDataHandler:checkIsActiveTime()
    if not isActiveShow then
        return
    end
    if LuckyJumpDataHandler.data.bIsGetCompletedGift then
        if self.transform ~= nil then
            self.transform.gameObject:SetActive(false)
        end
        return
    end

    if not self.m_bInitFlag then
        self.m_bInitFlag = true

        local prefab = Util.getHotPrefab("Assets/Active/LuckyJump/LuckyJump.prefab")--BaseHotAdd/Active/LuckyJump/LuckyJump.prefab")
        self.transform.gameObject = Unity.Object.Instantiate(prefab)
        self.transform = self.transform.gameObject.transform
        self.transform:SetParent(parent)
        self.transform.localScale = Unity.Vector3.one
        self.transform.anchoredPosition3D = Unity.Vector3.zero

        -- self.m_tipAni = self.transform:FindDeepChild("Tip"):GetComponent(typeof(Unity.Animator))
        -- local tipText = self.transform:FindDeepChild("TipText"):GetComponent(typeof(TextMeshProUGUI))
        -- tipText.text = "UNLOCK AT LEVEL "..LuckyJumpDataHandler.m_nUnlockLevel
        self.m_progressValue = self.transform:FindDeepChild("ProgressValue"):GetComponent(typeof(UnityUI.Image))--根据押注大小改变收集进度
        self.m_imgAddProgress = self.transform:FindDeepChild("AddProgress") --添加MoveCount收集的进度

        self.m_entryBtn = self.transform:FindDeepChild("EntryBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_entryBtn.gameObject:SetActive(false)
        self.m_entryBtn.onClick:AddListener(function()
            self:onLuckyJumpClicked()
        end)

        self.m_playBtnContainer = self.transform:FindDeepChild("PlayContainer").gameObject
        local playBtn = self.transform:FindDeepChild("PlayBtn"):GetComponent(typeof(UnityUI.Button))
        playBtn.onClick:AddListener(function()
            if ActiveThemeEntry:orInMove() then
                return
            end
            LuckyJumpGamePop:Show()
        end)
        self.transform:FindDeepChild("JianTou5"):GetComponent(typeof(UnityUI.Button)).onClick:AddListener(function()
            BuyView:Show(nil, false)
        end)
        self.transform:FindDeepChild("BtnBack"):GetComponent(typeof(UnityUI.Button)).onClick:AddListener(function()
            if self.m_aniController:GetInteger("nPlayMode") ~= 0 then
                self.m_aniController:SetInteger("nPlayMode", 0)
            end
        end)
        self.m_aniController = self.transform:GetComponentInChildren(typeof(Unity.Animator))
        self.m_goCandyPower = self.transform:FindDeepChild("LuckyJumpCandyPower").gameObject
        self.m_goCandyPower:SetActive(false)
        self.m_textTime = self.transform:FindDeepChild("TimeLeft"):GetComponent(typeof(TextMeshProUGUI))

        self.m_goUnloaded = self.transform:FindDeepChild("LuckyJumpUnloaded").gameObject
        self.m_goUnloaded:SetActive(true)

        local tr = self.transform:FindDeepChild("DownloadProgress")
        self.m_imgDownloadProgress = tr:GetComponent(typeof(UnityUI.Image))
        self.m_imgDownloadProgress.fillAmount = 1

        -- self.m_imgProgress = self.transform:FindDeepChild("JinDuTiao"):GetComponent(typeof(UnityUI.Image))
        self.m_moveCountText = self.transform:FindDeepChild("MoveCount"):GetComponent(typeof(TextMeshProUGUI))
        self.m_hongMoveCountText = self.transform:FindDeepChild("HongMoveCount"):GetComponent(typeof(TextMeshProUGUI))

        self.m_bAssetReady = false
       LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject,self)
        self:updateTime()
        NotificationHandler:removeObserver(self)
        EventHandler:AddListener(self, "AddBaseSpin")
        EventHandler:AddListener(self, "BaseGameSpinEnd")
        EventHandler:AddListener(self, "OnTotalBetChange")
    end
    self.m_aniController:SetInteger("nPlayMode", 0)
    self.m_nLastProgress = LuckyJumpDataHandler.data.fAddMoveCountProgress
    self:refreshUI(false)
    self:checkAndDownLoadLuckyJumpAssetBundle() -- 检查资源是否有了。。没有就开下载并且初始化进度条信息..
end

function LuckyJumpUnloadedUI:updateTime()
    local endTime = LuckyJumpDataHandler:getEndTime()
    if endTime ~= nil then
        local co = StartCoroutine( function()
            local waitForSecend = Unity.WaitForSeconds(1)
            while endTime ~= nil do
                local nowSecond = TimeHandler:GetServerTimeStamp()
                
                local time = endTime - nowSecond
                local days = time // (3600*24)
                local hours = time // 3600 - 24 * days
                local minutes = time // 60 - 24 * days * 60 - 60 * hours
                local seconds = time % 60
                if days <= 1 then
                    self.m_textTime.text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                else
                    self.m_textTime.text = string.format("%d DAYS", days)
                end
                if time <= 0 then
                    endTime = nil
                    self.m_entryBtn.interactable = false
                    self.transform.gameObject:SetActive(false)
                end
                yield_return(waitForSecend)
            end
        end)
    end

end

function LuckyJumpUnloadedUI:hide()
    self.transform.gameObject:SetActive(false)
end

function LuckyJumpUnloadedUI:Update(dt)
    if LuckyJumpAssetBundleHandler.m_bundleInfo.downloadStatus == DownloadStatus.Downloaded then
        return
    end
    -- 资源没有下载完..
    local bundleInfo = LuckyJumpAssetBundleHandler.m_bundleInfo
    
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

function LuckyJumpUnloadedUI:checkAndDownLoadLuckyJumpAssetBundle()
    local bundleInfo = LuckyJumpAssetBundleHandler.m_bundleInfo
    if bundleInfo.downloadStatus == DownloadStatus.Downloaded then
        self:refreshButtonStatus()
        return
    end
    LuckyJumpAssetBundleHandler:checkAndDownload()
end

function LuckyJumpUnloadedUI:refreshButtonStatus()
    -- 已经有资源了或者下载好了之后来到这里
    
    local bundleInfo = LuckyJumpAssetBundleHandler.m_bundleInfo
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
            Debug.Log("LuckyJumpAssets Download Sccuess!!!!!!!!")
            self.m_entryBtn.gameObject:SetActive(true)
            self.m_goUnloaded:SetActive(false)
        end)
    end
end

function LuckyJumpUnloadedUI:onLuckyJumpClicked()
    GlobalAudioHandler:PlayBtnSound()
    Scene.loadingAssetBundle:SetActive(false)
    local nLevel = PlayerHandler.nLevel
    if nLevel < LuckyJumpDataHandler.m_nUnlockLevel then
        if not self.m_tipAni.gameObject.activeSelf then
            self.m_tipAni.gameObject:SetActive(true)
            LeanTween.delayedCall(2.3, function()
                self.m_tipAni.gameObject:SetActive(false)
            end)
        end
        return
    end
    --TODO show Ani
    if self.m_aniController:GetInteger("nPlayMode") == 1 then
        self.m_aniController:SetInteger("nPlayMode", 0)
    else
        self.m_aniController:SetInteger("nPlayMode", 1)
    end
end

function LuckyJumpUnloadedUI:beginProgressAnimation(progress, isMax)
    if not isMax then
        -- highlight animation
        LeanTween.value(self.m_nLastProgress, progress, 0.6):setOnUpdate(function(value)
            if self.transform.gameObject == nil then
                return
            end
            local heigh = (1-value)*(-136)
            self.m_imgAddProgress.anchoredPosition = Unity.Vector2(0,heigh)
        end)
    else
        local seq = LeanTween.sequence()
        seq:append(LeanTween.value(self.m_nLastProgress, 1.0, 0.2):setOnUpdate(function(value)
            if self.transform.gameObject == nil then
                return
            end
            local heigh = (1-value)*(-136)
            self.m_imgAddProgress.anchoredPosition = Unity.Vector2(0,heigh)
        end))
        seq:append(LeanTween.value(1.0, 0, 0.8):setOnUpdate(function(value)
            if self.transform.gameObject == nil then
                return
            end
            local heigh = (1-value)*(-136)
            self.m_imgAddProgress.anchoredPosition = Unity.Vector2(0,heigh)
        end))
        seq:append(LeanTween.value(0, progress, 0.2):setOnUpdate(function(value)
            if self.transform.gameObject == nil then
                return
            end
            local heigh = (1-value)*(-136)
            self.m_imgAddProgress.anchoredPosition = Unity.Vector2(0,heigh)
        end))
    end
    self.m_nLastProgress = progress
end

function LuckyJumpUnloadedUI:AddBaseSpin(data)
    if not GameConfig.LUCKYJUMP_FLAG then
        return
    end
    local userLevel = PlayerHandler.nLevel
    if userLevel < LuckyJumpDataHandler.m_nUnlockLevel then
        return
    end
    
    if LuckyJumpDataHandler.data.bIsGetCompletedGift then
        if self.transform ~= nil then
            self.transform.gameObject:SetActive(false)
        end
        return
    end

    if not LuckyJumpDataHandler:checkIsActiveTime() then
        return
    end

    --当玩家加载好了资源，但没有显示界面时，返回，数据不记录
    if not self.m_bInitFlag then
        return
    end

    if not data.bFreeSpinFlag then
        local bIsGetProgress = ActivityHelper:isTriggerProgress(ActiveType.LuckyJump)
    
        if not bIsGetProgress then
            return
        end
        local isMax = LuckyJumpDataHandler:refreshAddSpinProgress(data)
        self:refreshUI(isMax)
    end
end

function LuckyJumpUnloadedUI:BaseGameSpinEnd(data)
    if not GameConfig.LUCKYJUMP_FLAG then
        return
    end
    if not LuckyJumpDataHandler:checkIsActiveTime() then
        return
    end

    local userLevel = PlayerHandler.nLevel
    if userLevel < LuckyJumpDataHandler.m_nUnlockLevel then
        return
    end

    if LuckyJumpDataHandler.data.bIsGetCompletedGift then
        return
    end

    local bRespinFlag = false
    local bFreeSpinFlag = false
    bRespinFlag = SlotsGameLua.m_GameResult:InReSpin()
    bFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
    
    if bRespinFlag or bFreeSpinFlag then
        return
    end

    --TODO 显示可以开始玩活动
end

function LuckyJumpUnloadedUI:refreshUI(isMax)
    if self.transform.gameObject == nil then
        return
    end
    local fAddMoveCountProgress = LuckyJumpDataHandler.data.fAddMoveCountProgress
    self:beginProgressAnimation(fAddMoveCountProgress, isMax)
    self:refreshMoveCount()
end

function LuckyJumpUnloadedUI:refreshMoveCount()
    local nMoveCount = LuckyJumpDataHandler.data.nMoveCount
    if nMoveCount <= 0 then
        self.m_playBtnContainer:SetActive(false)
    else
        self.m_playBtnContainer:SetActive(true)
    end

    self.m_moveCountText.text = nMoveCount
    self.m_hongMoveCountText.text = nMoveCount
end

-- 这个是显示压注大小与收集进度关系的ui 后面给每一关都加上。。 todo
-- 2021-7-30
function LuckyJumpUnloadedUI:OnTotalBetChange()
    local nBaseTB = ActivityHelper:getBasePrize()
    local value = (SceneSlotGame.m_nTotalBet / nBaseTB) *0.02
    
    local fMax = 0.6
    if value > fMax then
        value = fMax
    end

    self.m_progressValue.fillAmount = value/fMax
    if not self.m_goCandyPower.activeSelf then
        self.m_goCandyPower:SetActive(true)
        LeanTween.delayedCall(2, function()
            self.m_goCandyPower:SetActive(false)
        end)
    end
end