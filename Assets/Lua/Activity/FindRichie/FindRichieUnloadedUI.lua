require("Lua.Activity.FindRichie.FindRichieAssetBundleHandler")
require("Lua.Activity.FindRichie.FindRichieDataHandler")
require("Lua.Activity.FindRichie.FruitItem")
require("Lua.Activity.FindRichie.FindRichieMainUIPop")

local yield_return = (require 'cs_coroutine').yield_return

FindRichieUnloadedUI = {}
FindRichieUnloadedUI.m_entryBtn = nil
FindRichieUnloadedUI.m_tipAni = nil
FindRichieUnloadedUI.m_bInitFlag = false
FindRichieUnloadedUI.m_nLastProgress = 0

FindRichieUnloadedUI.m_imgDownloadProgress = nil

FindRichieUnloadedUI.m_coroutine = nil

FindRichieUnloadedUI.m_bAssetReady = false -- 每次登入游戏都检查一下..
local GetAddProgressConfig = {
    steps = {1, 2}, --1代表没获取，2代表获取
    probs = {10, 1}
}

function FindRichieUnloadedUI:Show(parent)
    local isActiveShow = FindRichieDataHandler:checkIsActiveTime()
    if not isActiveShow then
        return
    end

    if not self.m_bInitFlag then
        self.m_bInitFlag = true

        local prefab = Util.getHotPrefab("Assets/Active/FindRichie/FindRichie.prefab")
        self.transform.gameObject = Unity.Object.Instantiate(prefab)
        self.transform = self.transform.gameObject.transform
        self.transform:SetParent(parent)
        self.transform.localScale = Unity.Vector3.one*0.7
        self.transform.anchoredPosition3D = Unity.Vector3.zero

        -- self.m_tipAni = self.transform:FindDeepChild("Tip"):GetComponent(typeof(Unity.Animator))
        -- local tipText = self.transform:FindDeepChild("TipText"):GetComponent(typeof(TextMeshProUGUI))
        -- tipText.text = "UNLOCK AT LEVEL "..FindRichieDataHandler.m_nUnlockLevel

        self.m_imgAddProgress = self.transform:FindDeepChild("AddPickProgress"):GetComponent(typeof(UnityUI.Image)) --添加MoveCount收集的进度

        self.m_entryBtn = self.transform:FindDeepChild("EntryBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_entryBtn.onClick:AddListener(function()
            self:onFindRichieClicked()
        end)

        self.m_goFindRichieEntryContianer = self.transform:FindDeepChild("FindRichieEntryContianer").gameObject
        local playBtn = self.transform:FindDeepChild("BtnPlay"):GetComponent(typeof(UnityUI.Button))
        self.m_playBtnContainer = playBtn.gameObject
        playBtn.onClick:AddListener(function()
            FindRichieMainUIPop:Show()
        end)
        self.transform:FindDeepChild("ShopBtn"):GetComponent(typeof(UnityUI.Button)).onClick:AddListener(function()
            BuyView:Show(nil, false)
        end)
        self.transform:FindDeepChild("BtnBack"):GetComponent(typeof(UnityUI.Button)).onClick:AddListener(function()
            -- if self.m_aniController:GetInteger("nPlayMode") ~= 0 then
            --     self.m_aniController:SetInteger("nPlayMode", 0)
            -- end
        end)
        -- self.m_aniController = self.transform:GetComponentInChildren(typeof(Unity.Animator))
        self.m_textTime = self.transform:FindDeepChild("TimeLeft"):GetComponent(typeof(TextMeshProUGUI))

        self.m_goUnloaded = self.transform:FindDeepChild("FindRichieUnloaded").gameObject
        self.m_goUnloaded:SetActive(true)

        local tr = self.m_goUnloaded.transform:FindDeepChild("DownloadProgress")
        self.m_imgDownloadProgress = tr:GetComponent(typeof(UnityUI.Image))
        self.m_imgDownloadProgress.fillAmount = 1

        self.m_textPickCount = self.transform:FindDeepChild("PickCountText"):GetComponent(typeof(TextMeshProUGUI))
        -- self.m_hongPickCountText = self.transform:FindDeepChild("HongPickCountText"):GetComponent(typeof(TextMeshProUGUI))

        self.m_bAssetReady = false
       LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject,self)
        self:updateTime()
        NotificationHandler:removeObserver(self)
        EventHandler:AddListener(self, "AddBaseSpin")
        EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    end
    self.m_textPickCount.text = "PICKS:"..FindRichieDataHandler.data.nPickCount
    -- self.m_aniController:SetInteger("nPlayMode", 0)
    self.m_nLastProgress = FindRichieDataHandler.data.fAddPickCountProgress
    self:refreshUI(false)
    self:checkAndDownLoadFindRichieAssetBundle() -- 检查资源是否有了。。没有就开下载并且初始化进度条信息..
end

function FindRichieUnloadedUI:updateTime()
    local endTime = FindRichieDataHandler:getEndTime()
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

function FindRichieUnloadedUI:hide()
    self.transform.gameObject:SetActive(false)
end

function FindRichieUnloadedUI:Update(dt)
    if FindRichieAssetBundleHandler.m_bundleInfo.downloadStatus == DownloadStatus.Downloaded then
        return
    end
    -- 资源没有下载完..
    local bundleInfo = FindRichieAssetBundleHandler.m_bundleInfo
    
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

function FindRichieUnloadedUI:checkAndDownLoadFindRichieAssetBundle()
    local bundleInfo = FindRichieAssetBundleHandler.m_bundleInfo
    if bundleInfo.downloadStatus == DownloadStatus.Downloaded then
        self:refreshButtonStatus()
        return
    end
    FindRichieAssetBundleHandler:checkAndDownload()
end

function FindRichieUnloadedUI:refreshButtonStatus()
    -- 已经有资源了或者下载好了之后来到这里
    
    local bundleInfo = FindRichieAssetBundleHandler.m_bundleInfo
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
            Debug.Log("FindRichieAssets Download Sccuess!!!!!!!!")
            self.m_goUnloaded:SetActive(false)
        end)
    end
end

function FindRichieUnloadedUI:onFindRichieClicked()
    if ActiveThemeEntry:orInMove() then
        return
    end
    GlobalAudioHandler:PlayBtnSound()
    local nLevel = PlayerHandler.nLevel
    if nLevel < FindRichieDataHandler.m_nUnlockLevel then
        if not self.m_tipAni.gameObject.activeSelf then
            self.m_tipAni.gameObject:SetActive(true)
            LeanTween.delayedCall(2.3, function()
                self.m_tipAni.gameObject:SetActive(false)
            end)
        end
        return
    end
    --TODO show Ani
    -- if self.m_aniController:GetInteger("nPlayMode") == 1 then
    --     self.m_aniController:SetInteger("nPlayMode", 0)
    -- else
    --     self.m_aniController:SetInteger("nPlayMode", 1)
    -- end
end

function FindRichieUnloadedUI:beginProgressAnimation(progress, isMax)
    if not isMax then
        -- highlight animation
        LeanTween.value(self.m_nLastProgress, progress, 0.6):setOnUpdate(function(value)
            if self.transform.gameObject == nil then
                return
            end
            self.m_imgAddProgress.fillAmount = value
        end)
    else
        local seq = LeanTween.sequence()
        seq:append(LeanTween.value(self.m_nLastProgress, 1.0, 0.2):setOnUpdate(function(value)
            if self.transform.gameObject == nil then
                return
            end
            self.m_imgAddProgress.fillAmount = value
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
    self.m_nLastProgress = progress
end

function FindRichieUnloadedUI:AddBaseSpin(data)
    if not GameConfig.FINDRICHIE_FLAG then
        return
    end
    if not self.m_bAssetReady then
        return
    end
    local userLevel = PlayerHandler.nLevel
    if userLevel < FindRichieDataHandler.m_nUnlockLevel then
        return
    end

    if not FindRichieDataHandler:checkIsActiveTime() then
        return
    end

    --当玩家加载好了资源，但没有显示界面时，返回，数据不记录
    if not self.m_bInitFlag then
        return
    end

    if not data.bFreeSpinFlag then
        local bIsGetProgress = ActivityHelper:isTriggerProgress(ActiveType.FindRichie)
    
        if not bIsGetProgress then
            return
        end
        local isMax = FindRichieDataHandler:refreshAddSpinProgress(data)
        self:refreshUI(isMax)
    end
end

function FindRichieUnloadedUI:refreshUI(isMax)
    if self.transform.gameObject == nil then
        return
    end
    local fAddPickCountProgress = FindRichieDataHandler.data.fAddPickCountProgress
    self:beginProgressAnimation(fAddPickCountProgress, isMax)
    self:refreshMoveCount()
end

function FindRichieUnloadedUI:refreshMoveCount()
    local nPickCount = FindRichieDataHandler.data.nPickCount
    if nPickCount <= 0 then
        self.m_playBtnContainer:SetActive(false)
        self.m_goFindRichieEntryContianer:SetActive(true)
    else
        self.m_playBtnContainer:SetActive(true)
        self.m_goFindRichieEntryContianer:SetActive(false)
    end

    self.m_textPickCount.text = "PICKS:"..nPickCount
    -- self.m_hongPickCountText.text = nPickCount
end

function FindRichieUnloadedUI:onPurchaseDoneNotifycation(data)
    if not GameConfig.FINDRICHIE_FLAG then
        return
    end
    if not self.m_bAssetReady then
        return
    end

    if not FindRichieDataHandler:checkIsActiveTime() then
        return
    end

    local userLevel = PlayerHandler.nLevel
    if userLevel < FindRichieDataHandler.m_nUnlockLevel then
        return
    end

    self:refreshUI(FindRichieDataHandler.data.fAddPickCountProgress >= 1)
    -- local pickCount = FindRichieDataHandler:getFindRichiePickCount(data.productId)
    -- FindRichieSendSpinPop:Show(pickCount)
end