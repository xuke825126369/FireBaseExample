require("Lua.Activity.Bingo.BingoConfig")
require("Lua.Activity.Bingo.BingoIAPConfig")
require("Lua.Activity.Bingo.BingoSaleUIPop")
require("Lua.Activity.Bingo.BingoSendSpinPop")

BingoUnloadedUI = {}
BingoUnloadedUI.bCollectNotify = true
function BingoUnloadedUI:Init(parent)
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end 

    local goPrefab = AssetBundleHandler:LoadAsset("ActivityCommon", "Bingo/BingoThemeEntry.prefab")
    local go = Unity.Object.Instantiate(goPrefab)
    self.transform = go.transform
    self.transform:SetParent(parent)
    self.transform.localScale = Unity.Vector3.one * 0.7
    self.transform.anchoredPosition3D = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    
    self.m_aniHit = self.transform:GetComponentInChildren(typeof(Unity.Animator))
    self.m_imgAddProgress = self.transform:FindDeepChild("AddPickProgress"):GetComponent(typeof(UnityUI.Image)) --添加MoveCount收集的进度
    local playBtn = self.transform:FindDeepChild("BtnPlay"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(playBtn)
    playBtn.onClick:AddListener(function()
        self:OnClickBtn()
    end)  

    self.m_goUnloaded = self.transform:FindDeepChild("BingoUnloaded").gameObject
    self.m_goLoaded = playBtn.gameObject
    self.m_goLoaded:SetActive(true)
    self.m_goUnloaded:SetActive(true)

    self.m_imgDownloadProgress = self.m_goUnloaded.transform:FindDeepChild("DownloadProgress"):GetComponent(typeof(UnityUI.Image))

    self.m_goCountContainer = self.transform:FindDeepChild("CountBg").gameObject
    self.m_textCount = self.transform:FindDeepChild("PickCountText"):GetComponent(typeof(TextMeshProUGUI))
    self.m_goMaximum = self.transform:FindDeepChild("Maximum").gameObject
    self.CollectSplashUI = require("Lua.Activity.Bingo.CollectSplashUI")
    self.MaxReachedSplashUI = require("Lua.Activity.Bingo.MaxReachedSplashUI")

    self.goLevelSuo = self.transform:FindDeepChild("LockNode").gameObject

    EventHandler:AddListener("AddBaseSpin", self)
    EventHandler:AddListener("onLevelUp", self)
    EventHandler:AddListener("onActiveMsgCountChanged", self)
    EventHandler:AddListener("onActiveTimesUp", self)
    EventHandler:AddListener("onActiveSeasonStart", self)
    EventHandler:AddListener("onActiveSeasonEnd", self)

    EventHandler:AddListener("onAssetbundleDownloading", self)
    EventHandler:AddListener("onAssetbundleDownloaded", self)
    EventHandler:AddListener("onAssetbundleDownloadError", self)
end 

function BingoUnloadedUI:Show(parent)
    self:Init(parent)
    self.m_imgDownloadProgress.fillAmount = 1
    self:RefreshState()
end

function BingoUnloadedUI:OnDestroy()
    EventHandler:RemoveListener("AddBaseSpin", self)
    EventHandler:RemoveListener("onLevelUp", self)
    EventHandler:RemoveListener("onActiveMsgCountChanged", self)
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    EventHandler:RemoveListener("onActiveSeasonStart", self)
    EventHandler:RemoveListener("onActiveSeasonEnd", self)

    EventHandler:AddListener("onAssetbundleDownloading", self)
    EventHandler:AddListener("onAssetbundleDownloaded", self)
    EventHandler:AddListener("onAssetbundleDownloadError", self)
end

function BingoUnloadedUI:OnClickBtn()
    if ActiveThemeEntry:orInMove() then
        return
    end

    if not ActiveManager:orLevelOk() then
        local des = string.format("UnLock Level: <color=yellow>%d</color>",  ActiveManager.nUnlockLevel)
        TipPoolView:Show(des)
        return
    end

    GlobalAudioHandler:PlayBtnSound()
    ThemeLoader:ReturnToLobby()
    BingoMainUIPop:Show()
end

function BingoUnloadedUI:RefreshState()
    if ActiveManager.activeType ~= ActiveType.Bingo then
        self.transform.gameObject:SetActive(false)
        return
    end 

    self.goLevelSuo:SetActive(not ActiveManager:orLevelOk())

    self.transform.gameObject:SetActive(true)
    self:onActiveMsgCountChanged()
    if GameConfig.Instance.orUseAssetBundle then
        if ActivityBundleHandler:orExistBundle() then
            self.m_goLoaded:SetActive(true)
            self.m_goUnloaded:SetActive(false)
        else
            self.m_goLoaded:SetActive(false)
            self.m_goUnloaded:SetActive(true)
            self.m_imgDownloadProgress.fillAmount = 1.0
            ActivityBundleHandler:StartDownloadAndLoadBundle()
        end
    else
        self.m_goLoaded:SetActive(true)
        self.m_goUnloaded:SetActive(false)
    end

end

function BingoUnloadedUI:onActiveMsgCountChanged()
    local nAction = BingoHandler.data.nAction
    self.m_goCountContainer:SetActive(nAction > 0)
    self.m_textCount.text = nAction
    self.m_goMaximum:SetActive(nAction >= BingoHandler.N_MAX_ACTION)
    self.m_imgAddProgress.fillAmount = BingoHandler.data.fCollectProgress
end

function BingoUnloadedUI:AddBaseSpin(data)
    if not ActiveManager:orUnLock() then
        return
    end
    
    if not ActivityBundleHandler:orExistBundle() then
        return
    end 

    local bTrigger, isActionReachMax = BingoHandler:refreshAddSpinProgress(data)
    if bTrigger then
        self:CollectEffect()
        LeanTween.delayedCall(self.transform.gameObject, 1.1, function()
            self:refreshUI(bTrigger, isActionReachMax)
        end)
    else
        self:refreshUI(bTrigger, isActionReachMax)
    end
end

function BingoUnloadedUI:refreshUI(bTrigger, isActionReachMax)
    local progress = BingoHandler.data.fCollectProgress
    if isActionReachMax then
        BingoUnloadedUI.bCollectNotify = true
        LeanTween.value(self.transform.gameObject, self.m_imgAddProgress.fillAmount, progress, 0.6):setOnUpdate(function(value)
            self.m_imgAddProgress.fillAmount = value
        end):setOnComplete(function()
            EventHandler:Brocast("onActiveMsgCountChanged")
            self.MaxReachedSplashUI:Show(isActionReachMax)
        end)
    else
        if not bTrigger then
            LeanTween.value(self.transform.gameObject, self.m_imgAddProgress.fillAmount, progress, 0.6):setOnUpdate(function(value)
                self.m_imgAddProgress.fillAmount = value
            end)
        else
            local seq = LeanTween.sequence()
            seq:append(LeanTween.value(self.transform.gameObject, self.m_imgAddProgress.fillAmount, 1.0, 0.2):setOnUpdate(function(value)
                self.m_imgAddProgress.fillAmount = value
            end):setOnComplete(function()
                EventHandler:Brocast("onActiveMsgCountChanged")
                self.CollectSplashUI:Show(isActionReachMax)
            end))
            seq:append(LeanTween.value(self.transform.gameObject, 1.0, 0, 0.8):setOnUpdate(function(value)
                self.m_imgAddProgress.fillAmount = value
            end))
            seq:append(LeanTween.value(self.transform.gameObject, 0, progress, 0.2):setOnUpdate(function(value)
                self.m_imgAddProgress.fillAmount = value
            end):setOnComplete(function()
                --TODO 将入口变为Play按钮
            end))
        end
    end
end

function BingoUnloadedUI:CollectEffect()
    local pos = ActivityHelper:GetDeckCenter()
    local go = ActivityHelper:GetPrefabFromPool("Animation/qiu.prefab")
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

    LeanTween.move(goRed, self.transform.position, 0.5):setDelay(0.75):setEase(LeanTweenType.easeInQuad)
    LeanTween.move(goGreen, self.transform.position, 0.5):setDelay(0.82):setEase(LeanTweenType.easeInQuad)
    LeanTween.move(goBlue, self.transform.position, 0.5):setDelay(0.89):setEase(LeanTweenType.easeInQuad)
    LeanTween.move(goPurple, self.transform.position, 0.5):setDelay(0.96):setEase(LeanTweenType.easeInQuad)

    LeanTween.scale(goRed, Unity.Vector3.zero, 0.55):setDelay(0.75):setEase(LeanTweenType.easeInQuad)
    LeanTween.scale(goGreen, Unity.Vector3.zero, 0.55):setDelay(0.81):setEase(LeanTweenType.easeInQuad)
    LeanTween.scale(goBlue, Unity.Vector3.zero, 0.55):setDelay(0.87):setEase(LeanTweenType.easeInQuad)
    LeanTween.scale(goPurple, Unity.Vector3.zero, 0.55):setDelay(0.93):setEase(LeanTweenType.easeInQuad)

    LeanTween.delayedCall(self.transform.gameObject, 1.05, function()
        self.m_aniHit:Play("Hit", 0, 0)
    end)
    
    LeanTween.delayedCall(2, function()
        ActivityHelper:RecyclePrefabToPool(go)
    end)
end

function BingoUnloadedUI:onLevelUp()
    self:RefreshState()
end

function BingoUnloadedUI:onAssetbundleDownloading(bundleName, downloadProgress) 
    if ActiveManager:GetBundleName() ~= bundleName then
        return
    end

    self.m_imgDownloadProgress.fillAmount = 1 - downloadProgress
end

function BingoUnloadedUI:onAssetbundleDownloaded(bundleName)
    if ActiveManager:GetBundleName() ~= bundleName then
        return
    end

    self:RefreshState()
end

function BingoUnloadedUI:onAssetbundleDownloadError(bundleName)
    if ActiveManager:GetBundleName() ~= bundleName then
        return
    end

    self:RefreshState()
end

function BingoUnloadedUI:onActiveSeasonStart()
    self:RefreshState()
end

function BingoUnloadedUI:onActiveSeasonEnd()
    if self.CollectSplashUI.transform.gameObject then
        self.CollectSplashUI.transform.gameObject:SetActive(false)
    end

    if self.MaxReachedSplashUI.transform.gameObject then
        self.MaxReachedSplashUI.transform.gameObject:SetActive(false)
    end

    self:RefreshState()
end


