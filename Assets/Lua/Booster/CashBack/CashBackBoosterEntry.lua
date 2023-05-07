CashBackBoosterEntry = {}

CashBackBoosterEntry.transform = nil
CashBackBoosterEntry.m_bPortraitFlag = false -- 是否竖屏
CashBackBoosterEntry.m_bHasBooster = false -- 是否有booster在
CashBackBoosterEntry.m_goBoosterLockTipUI = nil --BoosterLockTipUI 未解锁状态点击之后打开的...
CashBackBoosterEntry.m_btnBoosterMe = nil -- btn 点了就打开商店界面
CashBackBoosterEntry.m_aniLockTip = nil -- InLockAni OutLockAni

CashBackBoosterEntry.m_listNeedCancelLeantweenID = {}

CashBackBoosterEntry.m_aniUnLockTip = nil -- InUnLockAni OutUnLockAni
CashBackBoosterEntry.m_goBoosterUnLockTipUI = nil -- BoosterUnLockTipUI 解锁后点击打开的...
-- TextBonus -- TextPercentCoef
CashBackBoosterEntry.m_TextBonus = nil -- 当前获得了多少钱
CashBackBoosterEntry.m_TextPercentCoef = nil

CashBackBoosterEntry.m_btnLock = nil -- 未解锁状态按钮
CashBackBoosterEntry.m_btnUnLock = nil -- 解锁状态按钮

CashBackBoosterEntry.m_goLockNode = nil -- 未解锁状态的资源节点
CashBackBoosterEntry.m_goUnLockNode = nil -- 已经激活状态的资源节点

-- ani 还没有..
CashBackBoosterEntry.m_aniBoosterTip = nil -- 点击上面按钮之后打开的提示界面的出场动画..
CashBackBoosterEntry.m_aniBoosterDefault = nil -- 一直在uitop显示的标签上的循环动画...

CashBackBoosterEntry.m_textBoosterCountDownInfo = nil -- 激活状态下的倒计时
CashBackBoosterEntry.m_textBoosterTip = nil -- 5% ？ 3%？ 7%？等等...

CashBackBoosterEntry.m_strCurBoosterRemainTime = "" -- booster 倒计时..

CashBackBoosterEntry.m_boosterParam = { nBonus = 0, nRewardTime = 0, boosters = {} }

CashBackBoosterEntry.m_fCashBackCoef = 0 -- 当前的返现比率 -- 运行时数据 每秒更新

function CashBackBoosterEntry:Init() -- 进关卡的时候调用
    self:CheckHasBooster()
    self:initBoosterUI()
end

function CashBackBoosterEntry:CheckHasBooster()
    local now = TimeHandler:GetServerTimeStamp()
    self.m_boosterParam = CommonDbHandler.data.CashBackParam
    self.m_bHasBooster = false
    local boosters = self.m_boosterParam.boosters
    for i = 1, #boosters do
        if boosters[i].nEndTime > now then
            self.m_bHasBooster = true
            break
        end
    end
end

function CashBackBoosterEntry:initBoosterUI()
    if not GameHelper:orInTheme() then
        return
    end

    self.m_bPortraitFlag = not ScreenHelper:isLandScape()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadAsset("lobby", "BoosterUI/CashBack/CashBackEntry.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform:GetComponent(typeof(Unity.RectTransform))
        self.transform:SetParent(BoosterEntry.transform, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        self.transform.anchoredPosition = Unity.Vector2(881, -220)
        self.transform.sizeDelta = Unity.Vector2.zero

        if self.m_bPortraitFlag then 
            rectTr.anchoredPosition = Unity.Vector2(100, 100)
            rectTr.sizeDelta = Unity.Vector2.zero
            self.transform.localScale = Unity.Vector3.one
        end

        self.m_goLockNode = self.transform:FindDeepChild("BtnLockAni").gameObject
        local btnLock = self.transform:FindDeepChild("BtnLockAni"):GetComponentInChildren(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnLock)
        btnLock.onClick:AddListener(function()
            self:onBtnLockClick()
        end)
        self.m_btnLock = btnLock
        self.m_goLockNode:SetActive(false)

        local trBtn = self.transform:FindDeepChild("BtnUnLock")
        self.m_goUnLockNode = trBtn.gameObject
        local btnUnLock = trBtn:GetComponent( typeof(UnityUI.Button) )
        DelegateCache:addOnClickButton(btnUnLock)
        btnUnLock.onClick:AddListener(function()
            self:onBtnUnLockClick()
        end)
        self.m_btnUnLock = btnUnLock
        self.m_goUnLockNode:SetActive(false)

        local trTip = self.transform:FindDeepChild("BoosterLockTipUI")
        self.m_goBoosterLockTipUI = trTip.gameObject
        self.m_goBoosterLockTipUI:SetActive(false)
        self.m_aniLockTip = trTip:GetComponent(typeof(Unity.Animator))

        trTip = self.transform:FindDeepChild("BoosterUnLockTipUI")
        self.m_goBoosterUnLockTipUI = trTip.gameObject
        self.m_goBoosterUnLockTipUI:SetActive(false)
        self.m_aniUnLockTip = trTip:GetComponent(typeof(Unity.Animator))

        local tr = trTip:FindDeepChild("TextBonus")
        self.m_TextBonus = tr:GetComponent(typeof(UnityUI.Text)) -- 当前获得了多少钱

        tr = trTip:FindDeepChild("TextPercentCoef")
        self.m_TextPercentCoef = tr:GetComponent(typeof(UnityUI.Text)) -- 当前的返现率是多少..
        
        local btnBoosterMe = self.transform:FindDeepChild("BtnBoosterMe"):GetComponent( typeof(UnityUI.Button) )
        DelegateCache:addOnClickButton(btnBoosterMe)
        btnBoosterMe.onClick:AddListener(function()
            self:onBtnBoosterMeClick()
        end)
        self.m_btnBoosterMe = btnBoosterMe

        local tr = self.transform:FindDeepChild("TextBoosterCountDown")
        self.m_textBoosterCountDownInfo = tr:GetComponent(typeof(TextMeshProUGUI))

        self.mTimeOutGenerator = TimeOutGenerator:New()
        EventHandler:AddListener("onCashBackBoosterNotificationCallback", self)
        EventHandler:AddListener("BaseSpinWinCoins", self)
    end

    self.transform.gameObject:SetActive(false) -- 根节点默认隐藏的

    self.m_goLockNode:SetActive(false)
    self.m_goUnLockNode:SetActive(false)
    if self.m_bHasBooster then
        self.transform.gameObject:SetActive(true)
        self.m_goUnLockNode:SetActive(true)
        self.m_btnUnLock.interactable = true
    else
        self.transform.gameObject:SetActive(true)
        self.m_goLockNode:SetActive(true)
        self.m_btnLock.interactable = true
    end
end

function CashBackBoosterEntry:RefreshCountDown()
    if not self.m_bHasBooster then
        return
    end

    local now = os.time()
    local boosters = self.m_boosterParam.boosters
    local nMaxRemainTime = 0 -- 找出最大剩余时间 显示界面用
    local fMaxCoef = 0 -- 找出最大的 如果要换成使用最大的呢..
    local fSumCoef = 0 -- 各个 booster 的 fcoef 和
    local listNeedRemoveBooster = {}
    for i=1, #boosters do
        if boosters[i].nEndTime > now then
            -- 处于激活状态的
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
    
    self.m_fCashBackCoef = fSumCoef -- fMaxCoef 两种不同的处理方式...
    local nRemainTime = BoostHandler.m_nCashBackRemainTime --nMaxRemainTime
    local strRemainTime = BoostHandler:FormatTime(nRemainTime)
    self.m_strCurBoosterRemainTime = strRemainTime -- 按钮显示用
    self.m_textBoosterCountDownInfo.text = strRemainTime

    if nRemainTime == 0 then
        self:BoosterFinish()
    end

end

function CashBackBoosterEntry:BoosterFinish()
    self.m_bHasBooster = false
    self:refreshUI()
    Debug.Log("-------CashBackBoosterFinish--------")
end

function CashBackBoosterEntry:Hide()
    self.transform.gameObject:SetActive(false)
end

-- 不一定切换到未激活状态 可能直接隐藏了
function CashBackBoosterEntry:refreshUI() -- 激活未激活的状态切换
    if self.m_bHasBooster then
        self.m_goLockNode:SetActive(false)
        self.transform.gameObject:SetActive(true)
        self.m_goUnLockNode:SetActive(true)
        self.m_btnUnLock.interactable = true

        self.m_goBoosterLockTipUI:SetActive(false)
    else
        self.m_goUnLockNode:SetActive(false)
        self.m_goLockNode:SetActive(false)
        self.transform.gameObject:SetActive(false)

        if math.random() < 0.3 then
            self.transform.gameObject:SetActive(true)
            self.m_goLockNode:SetActive(true)
            self.m_btnLock.interactable = true
        end
    end
end

function CashBackBoosterEntry:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end

    return true
end

function CashBackBoosterEntry:onCashBackBoosterNotificationCallback()
    self:CheckHasBooster()
    self:initBoosterUI()
end

function CashBackBoosterEntry:BaseSpinWinCoins(data)
    local nTotalBet = data.nTotalBet
    local nWinCoins = data.nWinCoins
    if nWinCoins > 0 then
        return
    end
    
    if self.m_bHasBooster then
        local nBonus = nTotalBet * self.m_fCashBackCoef
        self.m_boosterParam.nBonus = self.m_boosterParam.nBonus + nBonus
        CommonDbHandler:SaveDb()
    else
        if math.random() < 0.0002 then
            if not self.m_goLockNode.activeSelf then
                self.transform.gameObject:SetActive(true)
                self.m_goLockNode:SetActive(true)
                self.m_btnLock.interactable = true

                self.m_goBoosterLockTipUI:SetActive(true)
                local nID1 = LeanTween.delayedCall(5, function()
                    self.m_aniLockTip:Play("OutLockAni", -1, 0)
                end).id
                table.insert(self.m_listNeedCancelLeantweenID, nID1)

                local nID2 = LeanTween.delayedCall(5.5, function()
                    self.m_goBoosterLockTipUI:SetActive(false)
                end).id
                table.insert(self.m_listNeedCancelLeantweenID, nID2)

            end
        end
    end
end

function CashBackBoosterEntry:hideLockTipUI()
    self:CancelPerSpinLeanTween()

    self.m_btnLock.interactable = false
    self.m_aniLockTip:Play("OutLockAni", -1 ,0)
    LeanTween.delayedCall(0.5, function()
        self.m_goBoosterLockTipUI:SetActive(false)
        self.m_btnLock.interactable = true
    end)
end

function CashBackBoosterEntry:onBtnLockClick()
    if self.m_goBoosterLockTipUI.activeSelf then
        self:hideLockTipUI()
        return
    end

    GlobalAudioHandler:PlayBtnSound()
    self.m_goBoosterLockTipUI:SetActive(true)
    local nID1 = LeanTween.delayedCall(5, function()
        self.m_aniLockTip:Play("OutLockAni", -1, 0)
    end).id
    table.insert(self.m_listNeedCancelLeantweenID, nID1)

    local nID2 = LeanTween.delayedCall(5.5, function()
        self.m_goBoosterLockTipUI:SetActive(false)
    end).id
    table.insert(self.m_listNeedCancelLeantweenID, nID2)

end

function CashBackBoosterEntry:CancelPerSpinLeanTween()
	local count = #self.m_listNeedCancelLeantweenID
	for i=1, count do
		local id = self.m_listNeedCancelLeantweenID[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
    self.m_listNeedCancelLeantweenID = {}
end


function CashBackBoosterEntry:hideUnLockTipUI()
    self:CancelPerSpinLeanTween()

    self.m_btnUnLock.interactable = false
    self.m_aniUnLockTip:Play("OutUnLockAni", -1 ,0)
    LeanTween.delayedCall(0.5, function()
        self.m_goBoosterUnLockTipUI:SetActive(false)
        self.m_btnUnLock.interactable = true
    end)
end

function CashBackBoosterEntry:onBtnUnLockClick()
    if self.m_goBoosterUnLockTipUI.activeSelf then
        self:hideUnLockTipUI()
        return
    end
        
    GlobalAudioHandler:PlayBtnSound()
    self.m_goBoosterUnLockTipUI:SetActive(true)

    self.m_TextPercentCoef.text = math.floor( self.m_fCashBackCoef * 100 ) .. "%"
    local nBonus = self.m_boosterParam.nBonus
    local strBonus = LuaUtil.numWithCommas(nBonus)
    self.m_TextBonus.text = strBonus

    local nID1 =  LeanTween.delayedCall(5, function()
        self.m_aniUnLockTip:Play("OutUnLockAni", -1 ,0)
    end).id
    table.insert(self.m_listNeedCancelLeantweenID, nID1)

    local nID2 = LeanTween.delayedCall(5.5, function()
        self.m_goBoosterUnLockTipUI:SetActive(false)
    end).id
    table.insert(self.m_listNeedCancelLeantweenID, nID2)
end

function CashBackBoosterEntry:onBtnBoosterMeClick()
    if CashBackPurchaseUI:isActiveShow() then
        return
    end

    CashBackPurchaseUI:Show()
end

function CashBackBoosterEntry:OnDestroy()
    EventHandler:RemoveListener("onCashBackBoosterNotificationCallback", self)
    EventHandler:RemoveListener("BaseSpinWinCoins", self)
end

function CashBackBoosterEntry:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self:RefreshCountDown()
    end

    local bFlag1 = self.m_goBoosterLockTipUI.activeSelf
    local bFlag2 = self.m_goBoosterUnLockTipUI.activeSelf
    if not bFlag1 and not bFlag2 then
        return
    end

    if not self.m_btnLock.interactable then
        return
    end
    if not self.m_btnUnLock.interactable then
        return
    end

    local trTipUI = nil
    if bFlag1 then
        trTipUI = self.m_goBoosterLockTipUI.transform
    elseif bFlag2 then
        trTipUI = self.m_goBoosterUnLockTipUI.transform
    end
    
    if Unity.Input.GetMouseButton(0) then
       local pointerPosition = Unity.Vector2(Unity.Input.mousePosition.x, Unity.Input.mousePosition.y)
       local camera = Unity.Camera.main
       local touchInsidePop = false
       for i = 0, trTipUI.childCount - 1 do
           local item = trTipUI:GetChild(i)
           if Unity.RectTransformUtility.RectangleContainsScreenPoint(item, pointerPosition, Unity.Camera.main) then
               touchInsidePop = true
               break
           end
       end

       if not touchInsidePop then
           if bFlag1 then
               self:hideLockTipUI()
           elseif bFlag2 then
               self:hideUnLockTipUI()
           end
       end
	end
    
end
