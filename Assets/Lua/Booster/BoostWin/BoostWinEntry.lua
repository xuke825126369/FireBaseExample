BoostWinEntry = {}

BoostWinEntry.m_bHasBooster = false -- 是否有booster在
BoostWinEntry.m_btnLock = nil -- 未解锁状态按钮
BoostWinEntry.m_btnUnLock = nil -- 解锁状态按钮

BoostWinEntry.m_goLockNode = nil -- 未解锁状态的资源节点
BoostWinEntry.m_goUnLockNode = nil -- 已经激活状态的资源节点
BoostWinEntry.m_boosterParam = {nBonus = 0, nRewardTime = 0, nMaxCoins = 0, boosters = {}}
BoostWinEntry.m_fBoostWinCoef = 0

function BoostWinEntry:Init() -- 进关卡的时候调用
    self.m_boosterParam = CommonDbHandler.data.BoostWinParam
    local now = os.time()

    self.m_bHasBooster = false
    local boosters = self.m_boosterParam.boosters
    for i = 1, #boosters do
        if boosters[i].nEndTime > now then
            self.m_bHasBooster = true
            break
        end
    end 
    
    self:initBoosterUI()
end

function BoostWinEntry:initBoosterUI()
    if not GameHelper:orInTheme() then
        return
    end 

    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadAsset("lobby", "BoosterUI/BoostWin/BoostWinEntry.prefab")
        if goPrefab == nil then
            Debug.LogWithColor("BoostWinEntry.prefab 不存在")
            return
        end

        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform:GetComponent(typeof(Unity.RectTransform))
        self.transform:SetParent(BoosterEntry.transform, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        self.transform.anchoredPosition = Unity.Vector2(881, -220)
        self.transform.sizeDelta = Unity.Vector2.zero
        
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

        self.mTimeOutGenerator = TimeOutGenerator:New()
        EventHandler:AddListener("onBoostWinNotificationCallback", self)
        EventHandler:AddListener("WinCoins", self)
    end

    self.transform.gameObject:SetActive(false)
    self.m_goLockNode:SetActive(false)
    self.m_goUnLockNode:SetActive(false)
    self:refreshUI()
end

function BoostWinEntry:RefreshCountDown()
    if not self.mTimeOutGenerator:orTimeOut() then
        return
    end

    if not self.m_bHasBooster then
        return
    end

    local now = os.time()
    local boosters = self.m_boosterParam.boosters
    local nMaxRemainTime = 0
    local fMaxCoef = 0
    local fSumCoef = 0
    local listNeedRemoveBooster = {}

    for i = 1, #boosters do
        if boosters[i].nEndTime > now then
            if not self.m_bHasBooster then
                self.m_bHasBooster = true
                self:refreshUI()
            end

            local nRemainTime = boosters[i].nEndTime - now
            if nRemainTime > nMaxRemainTime then
                nMaxRemainTime = nRemainTime
            end
            if boosters[i].fCoef > fMaxCoef then
                fMaxCoef = boosters[i].fCoef
            end

            fSumCoef = fSumCoef + boosters[i].fCoef
        else
            table.insert(listNeedRemoveBooster, i)
        end
    end

    self.m_fBoostWinCoef = fSumCoef
    local nRemainTime = nMaxRemainTime
    local strRemainTime = BoostHandler:FormatTime(nRemainTime)
    self.m_textBoosterCountDownInfo.text = strRemainTime

    if nRemainTime == 0 then
        self:BoosterFinish()
    end
end

function BoostWinEntry:BoosterFinish()
    self.m_bHasBooster = false
    self:refreshUI()
end

function BoostWinEntry:Hide()
    self.transform.gameObject:SetActive(false)
end

function BoostWinEntry:refreshUI() -- 激活未激活的状态切换
    if self.m_bHasBooster then
        self.transform.gameObject:SetActive(true)
        self.m_goLockNode:SetActive(false)
        self.m_goUnLockNode:SetActive(true)
    else
        self.m_goUnLockNode:SetActive(false)
        local bFlag, toSecond = BoostHandler:checkIsBoostWinActive()
        if bFlag then
            self.transform.gameObject:SetActive(true)
            self.m_goLockNode:SetActive(true)
        else
            self.transform.gameObject:SetActive(false)
            self.m_goLockNode:SetActive(false)
        end
    end
end

function BoostWinEntry:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end

    return true
end

function BoostWinEntry:onBoostWinNotificationCallback(data)
    self.m_boosterParam = CommonDbHandler.data.BoostWinParam
    self:initBoosterUI()
end

function BoostWinEntry:WinCoins(data)
    local nTotalBet = data.nWinCoins
    if self.m_bHasBooster then
        if self.m_boosterParam.nBonus < self.m_boosterParam.nMaxCoins then
            local nBonus = nTotalBet * self.m_fBoostWinCoef
            self.m_boosterParam.nBonus = self.m_boosterParam.nBonus + nBonus
            CommonDbHandler:SaveDb()
        end
    end
end

function BoostWinEntry:onBtnLockClick()
    GlobalAudioHandler:PlayBtnSound()
    BoostWinLock:Show()
end

function BoostWinEntry:onBtnUnLockClick()
    GlobalAudioHandler:PlayBtnSound()
    BoostWinUnlock:Show()
end

function BoostWinEntry:Update()
    self:RefreshCountDown()
end

function BoostWinEntry:OnDestroy()
    EventHandler:RemoveListener("onBoostWinNotificationCallback", self)
    EventHandler:RemoveListener("WinCoins", self)
end
