require("Lua.Activity.Lounge.LoungeHallUI")
require("Lua.Activity.Lounge.LoungeHandler")
require("Lua.Activity.Lounge.LoungeSpecialLevelBoosterUI")
require("Lua.Activity.Lounge.WelcomeToTheLoungeUI")
require("Lua.Activity.Lounge.PassCardToLoungeRewardUI")
require("Lua.Activity.Lounge.LoungeTimeEndUI")
require("Lua.Activity.Lounge.LoungePassCardUI")
require("Lua.Activity.Lounge.OneMedalExpiredUI")
require("Lua.Activity.Lounge.LoungeBetSizeChangeBar")

LoungeEntryUI = {}
function LoungeEntryUI:Init()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        self.transform = LobbyView.transform:FindDeepChild("BottomLoungeEntry")
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

        self.m_entryBtn = self.transform:FindDeepChild("EntryBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_entryBtn.gameObject:SetActive(false)
        DelegateCache:addOnClickButton(self.m_entryBtn)
        self.m_entryBtn.onClick:AddListener(function()
            self:onLoungeClicked()
        end)

        self.m_goUnloaded = self.transform:FindDeepChild("UnloadedNode").gameObject
        self.m_goUnloaded:SetActive(true)
        self.m_imgDownloadProgress = self.transform:FindDeepChild("DownloadProgress"):GetComponent(typeof(UnityUI.Image))
        self.m_imgDownloadProgress.fillAmount = 1

        self.m_goProgressNode = self.transform:FindDeepChild("ProgressNode").gameObject
        self.m_goProgressNode:SetActive(false)
        self.m_imageLoungeProgress = self.transform:FindDeepChild("imageLoungeProgress"):GetComponent(typeof(UnityUI.Image))
        self.TextMeshProLoungePoint = self.transform:FindDeepChild("TextMeshProLoungePoint"):GetComponent(typeof(TextMeshProUGUI))

        self.goLevelLockNode = self.transform:FindDeepChild("goLevelLockNode").gameObject
        self.goLevelSuo = self.transform:FindDeepChild("LockNode").gameObject

        EventHandler:AddListener("onLevelUp", self)
        EventHandler:AddListener("onNetTimeNotificationCallback", self)
        EventHandler:AddListener("OnLoungeActivityStateChanged", self)
        EventHandler:AddListener("onAssetbundleDownloading", self)
        EventHandler:AddListener("onAssetbundleDownloaded", self)
        EventHandler:AddListener("onAssetbundleDownloadError", self)
    end

    self:RefreshState()
end

function LoungeEntryUI:OnDestroy()
    EventHandler:RemoveListener("onLevelUp", self)
    EventHandler:RemoveListener("onNetTimeNotificationCallback", self)
    EventHandler:RemoveListener("OnLoungeActivityStateChanged", self)
    EventHandler:RemoveListener("onAssetbundleDownloading", self)
    EventHandler:RemoveListener("onAssetbundleDownloaded", self)
    EventHandler:RemoveListener("onAssetbundleDownloadError", self)
end

function LoungeEntryUI:RefreshState()
    if not LoungeManager:orActivityOpen() then
        self.transform.gameObject:SetActive(false)
        return
    end

    if LoungeHandler:isLoungeMember() then
        self.transform.gameObject:SetActive(false)
        return
    end

    self.m_entryBtn.gameObject:SetActive(false)
    self.m_goProgressNode:SetActive(false)
    self.m_goUnloaded:SetActive(false)
    self.goLevelSuo:SetActive(not LoungeManager:orLevelOk())
    
    self.transform.gameObject:SetActive(true)
    if GameConfig.Instance.orUseAssetBundle then
        if LoungeBundleHandler:orExistBundle() then
            self.m_goUnloaded:SetActive(false)
            self.m_entryBtn.gameObject:SetActive(true)
            self.m_goProgressNode:SetActive(true)
        else
            self.m_goUnloaded:SetActive(true)
            self.m_imgDownloadProgress.fillAmount = 1.0
            LoungeBundleHandler:StartDownloadAndLoadBundle()
        end
    else
        self.m_goUnloaded:SetActive(false)
        self.m_entryBtn.gameObject:SetActive(true)
        self.m_goProgressNode:SetActive(true)
    end    

    self:refreshUI()
end

function LoungeEntryUI:refreshUI()
    if not LoungeManager:orActivityOpen() then
        return
    end
    
    self.TextMeshProLoungePoint.text = LoungeHandler.data.activityData.nLoungePoint
    local nRoyalNum = LoungeHandler:getRoyalNum()
    if nRoyalNum == 2 then
        self.m_imageLoungeProgress.fillAmount = 1.0
    else
        local fcoef = LoungeHandler.data.activityData.nLoungePoint / LoungeConfig.N_MEMBER_NEED_POINTS
        self.m_imageLoungeProgress.fillAmount = fcoef
    end

end

function LoungeEntryUI:onLoungeClicked()
    GlobalAudioHandler:PlayBtnSound()

    if not LoungeManager:orLevelOk() then
        LockTip:ShowWithLevel(self.goLevelLockNode, LoungeManager.m_nUnlockLevel)
        return
    end 
        
    LoungeHallUI:Show()
end

function LoungeEntryUI:onLevelUp()
    self:RefreshState()
end

function LoungeEntryUI:OnLoungeActivityStateChanged()
    self:RefreshState()
end

function LoungeEntryUI:onNetTimeNotificationCallback()
    self:RefreshState()
end

function LoungeEntryUI:onAssetbundleDownloading(bundleName, fProgress)
    if bundleName ~= LoungeManager:GetBundleName() then
        return
    end
    
    self.m_imgDownloadProgress.fillAmount = 1.0 - fProgress
end

function LoungeEntryUI:onAssetbundleDownloaded(bundleName)
    if bundleName ~= LoungeManager:GetBundleName() then
        return
    end

    self:RefreshState()
end

function LoungeEntryUI:onAssetbundleDownloadError(bundleName)
    if bundleName ~= LoungeManager:GetBundleName() then
        return
    end

    self:RefreshState()
end
