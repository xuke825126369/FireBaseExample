RepeatWinEntry = {}

RepeatWinEntry.m_bHasBooster = false -- 是否有booster在
RepeatWinEntry.m_btnLock = nil -- 未解锁状态按钮
RepeatWinEntry.m_btnUnLock = nil -- 解锁状态按钮
RepeatWinEntry.m_goLockNode = nil -- 未解锁状态的资源节点
RepeatWinEntry.m_goUnLockNode = nil -- 已经激活状态的资源节点
RepeatWinEntry.m_textBoosterCountDownInfo = nil -- 激活状态下的倒计时

function RepeatWinEntry:Init() -- 进关卡的时候调用
    self.m_boosterParam = CommonDbHandler.data.RepeatWinParam
    local now = os.time()
    self.m_bHasBooster = false
    if self.m_boosterParam.nEndTime > now then
        self.m_bHasBooster = true
    end
    
    self:initBoosterUI()
end

function RepeatWinEntry:initBoosterUI()
    if GameHelper:orInTheme() then
        return
    end

    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadAsset("lobby", "BoosterUI/RepeatWin/RepeatWinEntry.prefab")
        if prefabObj == nil then
            return
        end

        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform:GetComponent(typeof(Unity.RectTransform))
        self.transform:SetParent(BoosterEntry.transform, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        local trBtn = self.transform:FindDeepChild("BtnBoostLock")
        self.m_goLockNode = trBtn.gameObject
        local btnLock = trBtn:GetComponentInChildren( typeof(UnityUI.Button) )
        DelegateCache:addOnClickButton(btnLock)
        btnLock.onClick:AddListener(function()
            self:onBtnLockClick()
        end)
        self.m_btnLock = btnLock
        self.m_goLockNode:SetActive(false)

        local trBtn = self.transform:FindDeepChild("BtnBoostUnlock")
        self.m_goUnLockNode = trBtn.gameObject
        local btnUnLock = trBtn:GetComponent( typeof(UnityUI.Button) )
        DelegateCache:addOnClickButton(btnUnLock)
        btnUnLock.onClick:AddListener(function()
            self:onBtnUnLockClick()
        end)
        self.m_btnUnLock = btnUnLock
        self.m_goUnLockNode:SetActive(false)

        local tr = self.transform:FindDeepChild("Time")
        self.m_textBoosterCountDownInfo = tr:GetComponent(typeof(TextMeshProUGUI))

        EventHandler:AddListener(self, "onRepeatWinNotificationCallback")
        EventHandler:AddListener(self, "WinCoins")
    end

    self.transform.gameObject:SetActive(false)

    self.m_goLockNode:SetActive(false)
    self.m_goUnLockNode:SetActive(false)
    self:refreshUI()
end

function RepeatWinEntry:RefreshCountDown()
    if not self.m_bHasBooster then
        return
    end

    local now = os.time()
    if self.m_boosterParam.nEndTime < now then
        self:BoosterFinish()
    else
        if self.m_boosterParam.nEndTime > now then
            if not self.m_bHasBooster then
                self.m_bHasBooster = true
                self:refreshUI()
            end
        end
    end
        
    local nRemainTime = BoostHandler.m_nRepeatWinRemainTime
    local strRemainTime = BoostHandler:FormatTime(nRemainTime)
    self.m_textBoosterCountDownInfo.text = strRemainTime
end

function RepeatWinEntry:BoosterFinish()
    self.m_bHasBooster = false
    self:refreshUI()
end

function RepeatWinEntry:Hide()
    self.transform.gameObject:SetActive(false)
end

function RepeatWinEntry:refreshUI() -- 激活未激活的状态切换
    if self.m_bHasBooster then
        self.transform.gameObject:SetActive(true)
        self.m_goLockNode:SetActive(false)
        self.m_goUnLockNode:SetActive(true)
    else
        self.m_goUnLockNode:SetActive(false)

        local bFlag, toSecond = BoostHandler:checkIsRepeatWinActive()
        if bFlag then
            self.transform.gameObject:SetActive(true)
            self.m_goLockNode:SetActive(true)
        else -- 商店不提供了...
            self.transform.gameObject:SetActive(false)
            self.m_goLockNode:SetActive(false)
        end

    end
end

function RepeatWinEntry:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end

    return true
end

function RepeatWinEntry:onRepeatWinNotificationCallback(data)
    self.m_boosterParam = CommonDbHandler.data.RepeatWinParam
    self:initBoosterUI()
end

function RepeatWinEntry:WinCoins(data)
    if not self.m_bHasBooster then
        return
    end

    local nTotalBet = SceneSlotGame.m_nTotalBet
    local nCurWin = data.nWinCoins
    if nCurWin > 100 * nTotalBet then
        nCurWin = 100 * nTotalBet
    end

    if self.m_boosterParam.nBonus < nCurWin then
        self.m_boosterParam.nBonus = nCurWin
        CommonDbHandler:SaveDb()
    end
end 

function RepeatWinEntry:onBtnLockClick()
    GlobalAudioHandler:PlayBtnSound()
    RepeatWinLock:Show()
end

function RepeatWinEntry:onBtnUnLockClick()
    GlobalAudioHandler:PlayBtnSound()
    RepeatWinUnlock:Show()
end

function RepeatWinEntry:OnDestroy()
    EventHandler:RemoveListener("onRepeatWinNotificationCallback", self)
    EventHandler:RemoveListener("WinCoins", self)
end
