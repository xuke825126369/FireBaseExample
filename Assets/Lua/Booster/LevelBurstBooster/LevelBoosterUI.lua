LevelBurstBoosterUI = {}

LevelBurstBoosterUI.m_bPortraitFlag = false -- 是否竖屏
LevelBurstBoosterUI.m_bHasLevelBooster = false -- 是否有booster在

LevelBurstBoosterUI.m_goBooterLogoUI = nil -- BooterLogoUI
LevelBurstBoosterUI.m_goBtnAD = nil -- BtnAD
LevelBurstBoosterUI.m_goLevelUpInfoUI = nil 
LevelBurstBoosterUI.m_goNowX30 = nil 
LevelBurstBoosterUI.m_goNowX2 = nil 

LevelBurstBoosterUI.m_goLevelUpTip = nil -- X2 X30的logo
LevelBurstBoosterUI.m_goBoostNowInfoUI = nil -- BoostNowInfoUI
LevelBurstBoosterUI.m_aniBoosterTip = nil -- 点击上面按钮之后打开的提示界面的出场动画..
LevelBurstBoosterUI.m_aniBoosterLogo = nil -- 一直在uitop显示的标签上的循环动画...
LevelBurstBoosterUI.m_btnBoosterAD = nil -- 未激活状态下的 BoostNow 按钮 点了就打开商店
LevelBurstBoosterUI.m_textBoosterCountDownInfo = nil -- 
LevelBurstBoosterUI.m_strCurBoosterRemainTime = "" -- booster 倒计时..

-- 广告页面提示信息
LevelBurstBoosterUI.m_textBoosterBonusCoins = nil -- TextBoosterCoins -- 8,700,000,000
LevelBurstBoosterUI.m_textPreLevelUpCoins = nil -- TextPreLevelUpCoins -- was (290,000,000) Coins

-- 10的整数倍升级提示信息
LevelBurstBoosterUI.m_textLevelNumber = nil -- TextLevelNumber -- LEVEL 900
LevelBurstBoosterUI.m_textRewardNmuber = nil -- TextRewardNmuber -- 12.5B
LevelBurstBoosterUI.m_textPointNumber = nil -- TextPointNumber -- 6

-- 显示过广告的等级.. 比如 9级显示过了 就记录下来
LevelBurstBoosterUI.m_listLevelBurstADs = {} 
LevelBurstBoosterUI.m_boosterParam = {fCoef = 1.0, nEndTime = 0}
LevelBurstBoosterUI.m_coroutineCountDown = nil -- 活动时间到了就挂起

function LevelBurstBoosterUI:Init()
    self.m_boosterParam = CommonDbHandler.data.LevelBurstParam
    local now = os.time()

    if self.m_boosterParam.nEndTime > now then
        self.m_bHasLevelBooster = true
    else
        self.m_bHasLevelBooster = false
    end 
    
    self:initBoosterUI()
end

function LevelBurstBoosterUI:initBoosterUI()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        self.bLandscape = ScreenHelper:isLandScape()
        self.transform = UITop.transform:FindDeepChild("LevelBoosterUI")

        self.m_goBtnAD = trBtn.gameObject

        local trBtn = self.transform:FindDeepChild("BtnAD")
        local btnBoosterAD = trBtn:GetComponent(typeof(UnityUI.Button))
        btnBoosterAD.onClick:RemoveAllListeners()
        DelegateCache:addOnClickButton(btnBoosterAD)
        btnBoosterAD.onClick:AddListener(function()
            self:onBtnBoosterADClick()
        end)
        self.m_btnBoosterAD = btnBoosterAD

        local tr = self.transform:FindDeepChild("TextBoosterCountDown")
        self.m_textBoosterCountDownInfo = tr:GetComponent(typeof(TextMeshProUGUI))

        tr = self.transform:FindDeepChild("BooterLogoUI")
        self.m_goBooterLogoUI = tr.gameObject
        self.m_aniBoosterLogo = tr:GetComponentInChildren(typeof(Unity.Animator))

        tr = self.transform:FindDeepChild("LevelUpTip")
        self.m_goLevelUpTip = tr.gameObject
        self.m_goNowX30 = tr:FindDeepChild("NowX30").gameObject
        self.m_goNowX2 = tr:FindDeepChild("NowX2").gameObject
        self.m_goLevelUpTip:SetActive(true)
        self.m_goNowX30:SetActive(false)
        self.m_goNowX2:SetActive(false)

        tr = self.transform:FindDeepChild("BoostNowInfoUI")
        self.m_goBoostNowInfoUI = tr.gameObject
        self.m_textBoosterBonusCoins = tr:FindDeepChild("TextBoosterCoins"):GetComponent(typeof(TextMeshProUGUI))
        self.m_textPreLevelUpCoins = tr:FindDeepChild("TextPreLevelUpCoins"):GetComponent(typeof(TextMeshProUGUI))

        EventHandler:AddListener(self, "onLevelBoosterNotificationCallback")
        EventHandler:AddListener(self, "onLevelUp")
        EventHandler:AddListener(self, "BaseSpinNonWin")
        self.mTimeOutGenerator = TimeOutGenerator:New()
    end
    
    self.m_goBtnAD:SetActive(false)
    self.m_goBoostNowInfoUI:SetActive(false)
    self.m_goBooterLogoUI:SetActive(false)
    self.transform.gameObject:SetActive(true)

    if self.m_bHasLevelBooster then
        self.m_goBooterLogoUI:SetActive(true)
    end
end

function LevelBurstBoosterUI:RefreshCountDown()
    if not self.m_bHasLevelBooster then
        self:LevelBoosterFinish()
        self:Hide()
        return
    end

    local now = os.time()
    if self.m_boosterParam.nEndTime < now then
        self:LevelBoosterFinish()
        self:Hide()
    else
        if self.m_boosterParam.nEndTime > now then
            if not self.m_bHasLevelBooster then
                self.m_bHasLevelBooster = true
                self:refreshUI()
            end
        end
    end

    local nRemainTime = BoostHandler.m_nLevelBurstRemainTime
    local strRemainTime = BoostHandler:FormatTime(nRemainTime)
    self.m_strCurBoosterRemainTime = strRemainTime -- 按钮显示用
    self.m_textBoosterCountDownInfo.text = strRemainTime

end

function LevelBurstBoosterUI:LevelBoosterFinish()
    self.m_bHasLevelBooster = false

    self.m_boosterParam = {fCoef = 1.0, nEndTime = 0}
    CommonDbHandler.data.LevelBurstParam = self.m_boosterParam
    CommonDbHandler:SaveDb()

    if LoungeSpecialLevelBoosterUI ~= nil then
        LoungeSpecialLevelBoosterUI:Show(self.bLandscape)
    end
end

function LevelBurstBoosterUI:Hide()
    self.transform.gameObject:SetActive(false) -- 这是根节点
end

function LevelBurstBoosterUI:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end

    return true
end

function LevelBurstBoosterUI:refreshUI() -- 激活未激活的状态切换
    if self.m_bHasLevelBooster then
        self.m_goBooterLogoUI:SetActive(true)
        self.m_goBtnAD:SetActive(false)
        self.m_goBoostNowInfoUI:SetActive(false)
    else
        self.m_goBooterLogoUI:SetActive(false)
    end
end

function LevelBurstBoosterUI:onLevelBoosterNotificationCallback(data)
    self.m_boosterParam = CommonDbHandler.data.LevelBurstParam  
    self:initBoosterUI() -- 这里唤醒协程就行，协程里会检查更新界面的
end

function LevelBurstBoosterUI:BaseSpinNonWin(data)
    if self.m_bHasLevelBooster then
        return
    end

    local levelInfo = CommonDbHandler:getUserLevelInfo()
    local level = levelInfo.level

    if (level + 1)%10 ~= 0 then
        return
    end

    if levelInfo.levelProgress < 0.5 then
        return
    end

    local flag = LuaUtil.arrayContainsElement(self.m_listLevelBurstADs, level)
    if flag then
        return -- 该等级已经弹过广告了
    end

    table.insert(self.m_listLevelBurstADs, level)
end

function LevelBurstBoosterUI:onLevelUp()
    local level = PlayerHandler.nLevel
    if true then
        return
    end

    if not self.m_bHasLevelBooster then
        if (level+1)%10 == 0 then
            -- 延迟几秒出来 等现有的levelUp界面关闭之后
            LeanTween.delayedCall(5, function()
                self.m_goBtnAD:SetActive(true)
                self.m_goBoostNowInfoUI:SetActive(true)
                LeanTween.delayedCall(9, function()
                    self.m_goBoostNowInfoUI:SetActive(false)
                end)

                -- 参数展示

                local nPreCoins = BonusUtil.getLevelUpBonus(level + 1)
                local strPre = "was (" .. LuaUtil.numWithCommas(nPreCoins) .. ") Coins"
                self.m_textPreLevelUpCoins.text = strPre

                local nBoosterCoins = nPreCoins * 30
                local strBoosterCoins = LuaUtil.numWithCommas(nBoosterCoins)
                self.m_textBoosterBonusCoins.text = strBoosterCoins
            end)
        end
        
        if level%10 == 0 then
            self.m_goBtnAD:SetActive(false)
            self.m_goBoostNowInfoUI:SetActive(false)
        end

        self.m_goNowX30:SetActive(false)
        self.m_goNowX2:SetActive(false)

        return
    end

    self.m_goLevelUpTip:SetActive(true)
    
    if level%10 == 0 then
        -- 升级到10的整数倍关
        self.m_goNowX30:SetActive(true)
        self.m_goNowX2:SetActive(false)
    else
        self.m_goNowX30:SetActive(false)
        self.m_goNowX2:SetActive(true)
    end
end

function LevelBurstBoosterUI:onBtnBoosterADClick()

end

function LevelBurstBoosterUI:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self:RefreshCountDown()
    end
end