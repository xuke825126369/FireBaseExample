require("Lua.Activity.Lounge.EarningPointsUI")
require("Lua.Activity.Lounge.LoungePayTable")
require("Lua.Activity.Lounge.CashBackPurchaseUI")

LoungeHallUI = {}
function LoungeHallUI:Show(func)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadGoldenLoungeAsset("LoungeUI/GoldenLoungeMainUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trContent = self.transform:FindDeepChild("Content")
        self.m_trPopNode = self.transform:FindDeepChild("PopParentNode") 
        -- 包间大厅里的弹窗父节点

        local btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnClose)
        btnClose.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:Hide()
        end)

        local btnTip = self.transform:FindDeepChild("BtnTip"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnTip)
        btnTip.onClick:AddListener(function()
            self:onBtnTipClicked(btnTip)
        end)

        self.TextMeshProSeason = self.transform:FindDeepChild("TextMeshProSeason"):GetComponent(typeof(TextMeshProUGUI))

        self:initUIMiddle()
        self:initUIBottom()

        self.mTimeOutGenerator = TimeOutGenerator:New()
    end

    ViewAlphaAni:Show(self.transform.gameObject, function()
        LoungeAudioHandler:PlayBackMusic("Loung_background")
    end)

    self:refreshUI() -- 界面参数展示
    if func ~= nil then
        func()
    end
end

function LoungeHallUI:initUIMiddle()
    local trMiddle = self.transform:FindDeepChild("UIMiddle")
    local trSpinRewards = trMiddle:FindDeepChild("SpinRewardsUI")
    local trLevelUpFaster = trMiddle:FindDeepChild("LevelUpFasterUI")
    local trGoldenBonus = trMiddle:FindDeepChild("GoldenSlotsBonusUI")
    local trCardPack = trMiddle:FindDeepChild("LuckCardsPackUI")
    local trHighRoller = trMiddle:FindDeepChild("HighRollerUI")
    local trMedalMaster = trMiddle:FindDeepChild("MedalMasterUI")
    local listTrs = {trSpinRewards, trLevelUpFaster, trGoldenBonus, trCardPack, 
                        trHighRoller, trMedalMaster}
    
    self.m_listMiddleNodes = {}
    for i=1, 6 do
        local tr = listTrs[i]
        local goTip = tr:FindDeepChild("TipNode").gameObject
        goTip:SetActive(false)

        local goLock = tr:FindDeepChild("LockNode").gameObject

        local btn = tr:GetComponentInChildren(typeof(UnityUI.Button)) 
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onBtnLoungeBonusNode(i, btn) -- 
        end)

        local nodes = {goTip = goTip, goLock = goLock, btn = btn}
        table.insert(self.m_listMiddleNodes, nodes)
    end
end

function LoungeHallUI:initUIBottom()
    local trBottom = self.transform:FindDeepChild("UIBottom")
    -- imageProgress
    local tr = trBottom:FindDeepChild("imageProgress")
    self.m_imageProgress = tr:GetComponent(typeof(UnityUI.Image))

    tr = trBottom:FindDeepChild("TextMeshProLoungePoint")
    self.TextMeshProLoungePoint = tr:GetComponent(typeof(TextMeshProUGUI))
    
    -- collect more lounge points for your second pass
    self.goTipLoungePointInfo = trBottom:FindDeepChild("TipLoungePointInfo").gameObject
    self.goTipLoungePointInfo:SetActive(false)

    local tr = trBottom:FindDeepChild("TextMeshProLoungePointTip")
    self.TextMeshProLoungePointTip = tr:GetComponent(typeof(TextMeshProUGUI))

    tr = trBottom:FindDeepChild("TextLoungePointToCoins")
    self.TextLoungePointToCoins = tr:GetComponent(typeof(UnityUI.Text))
    -- I00 = C00,000,000

    self.goMedalLogo1 = trBottom:FindDeepChild("MedalLogo1").gameObject
    self.goMedalLogo2 = trBottom:FindDeepChild("MedalLogo2").gameObject

    local tr = trBottom:FindDeepChild("CountDownNode")
    self.goCountDownNode = tr.gameObject
    self.TextMeshProMemberTime = tr:GetComponentInChildren(typeof(TextMeshProUGUI))
        
    -- 已经有两个皇冠的时候显示这个节点 展示当前的LoungePoint能兑换多少金币
    self.goLoungePointToCoinsNode = trBottom:FindDeepChild("LoungePointToCoinsNode").gameObject
    self.goLoungePointToCoinsNode:SetActive(false)
    
    tr = trBottom:FindDeepChild("BtnLoungePointInfo")
    local btnTip = tr:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnTip)
    btnTip.onClick:AddListener(function()
        self:OnLoungePointTipBtnClick(btnTip)
    end)

    tr = trBottom:FindDeepChild("BtnEarningPointsUI")
    local btnEarningPoints = tr:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnEarningPoints)
    btnEarningPoints.onClick:AddListener(function()
        self:OnEarningPointsBtnClick()
    end)
end

function LoungeHallUI:refreshUI()
    local nSeasonID = LoungeHandler.data.activityData.listMedalMasterData.nSeasonID
    self.TextMeshProSeason.text = "SEASON " .. nSeasonID

    local nLoungePoints = LoungeHandler:getLoungePoints()
    local nRoyalNum = LoungeHandler:getRoyalNum()

    if nRoyalNum == 0 then
        for i = 1, 6 do
            self.m_listMiddleNodes[i].goLock:SetActive(true)
        end
        self.goMedalLogo1:SetActive(false)
        self.goMedalLogo2:SetActive(false)
        self.goCountDownNode:SetActive(false)
    else
        for i = 1, 6 do
            self.m_listMiddleNodes[i].goLock:SetActive(false)
        end

        self.goCountDownNode:SetActive(true)
        local diffTime = LoungeHandler:getLoungeMemberTime()
        local strCountDown = LoungeConfig:formatDiffTime(diffTime)
        self.TextMeshProMemberTime.text = strCountDown
        
        if nRoyalNum == 1 then
            self.goMedalLogo1:SetActive(true)
            self.goMedalLogo2:SetActive(false)
        else
            self.goMedalLogo1:SetActive(true)
            self.goMedalLogo2:SetActive(true)
        end
    end

    if nRoyalNum < 2 then
        local strInfo = nLoungePoints .. "/"..LoungeConfig.N_MEMBER_NEED_POINTS
        self.TextMeshProLoungePoint.text = strInfo

        self.m_imageProgress.fillAmount = nLoungePoints / LoungeConfig.N_MEMBER_NEED_POINTS
        self.goLoungePointToCoinsNode:SetActive(false)

    else
        self.TextMeshProLoungePoint.text = nLoungePoints
        self.m_imageProgress.fillAmount = 1.0
        
        self.goLoungePointToCoinsNode:SetActive(true)
        local nCoinReward = LoungeConfig:getLoungePointToCoinValue(nLoungePoints)
        local strCoin = MoneyFormatHelper.numWithCommas(nCoinReward)
        local strInfo = "I" .. nLoungePoints .. " = " .. "C" .. strCoin
        self.TextLoungePointToCoins.text = strInfo
    end
end

-- 需要有转屏操作就传一个ture，不需要的话就别传了
function LoungeHallUI:Hide()
    LoungeAudioHandler:StopBackMusic()
    ViewAlphaAni:Hide(self.transform.gameObject)
end

function LoungeHallUI:OnLoungePointTipBtnClick(btnTip)
    GlobalAudioHandler:PlayBtnSound()
    
    btnTip.interactable = false
    self.goTipLoungePointInfo:SetActive(true)
    LeanTween.delayedCall(5.0, function()
        self.goTipLoungePointInfo:SetActive(false)
        btnTip.interactable = true
    end)

    local nRoyalNum = LoungeHandler:getRoyalNum()
    local str = ""
    if nRoyalNum == 0 then
        str = "10 DAYS WINNERS PASS REWARDS FOR EVERY 15,000 LOUNGE POINTS COLLECTED"
    elseif nRoyalNum == 1 then
        str = "great job!\n collect more lounge points for your second pass!"
    elseif nRoyalNum == 2 then
        str = "2 CROWNS COLLECTED!\n YOUR EXTRA LOUNGE POINTS EARNED WILL BE EXCHANGED INTO COINS NOW!"
    end

    self.TextMeshProLoungePointTip.text = str
end

function LoungeHallUI:OnEarningPointsBtnClick()
    GlobalAudioHandler:PlayBtnSound()
    EarningPointsUI:Show()
end

function LoungeHallUI:onBtnTipClicked(btnTip)
    btnTip.interactable = false
    LeanTween.delayedCall(1.0, function()
        btnTip.interactable = true
    end)

    GlobalAudioHandler:PlayBtnSound()
    LoungePayTable:Show()
end

function LoungeHallUI:onBtnLoungeBonusNode(index, btn)
    GlobalAudioHandler:PlayBtnSound()

    local nodes = self.m_listMiddleNodes[index]
    local goTip = nodes.goTip

    for i=1, 6 do
        if i ~= index then
            self.m_listMiddleNodes[i].goTip:SetActive(false)
            self.m_listMiddleNodes[i].btn.interactable = true
        end
    end

    if index == 2 or index == 3 or index == 4 or index == 5 then
        if not goTip.activeSelf then
            goTip:SetActive(true)
            self.m_listMiddleNodes[index].btn.interactable = false
            LeanTween.delayedCall(6.0, function()
                goTip:SetActive(false)
                self.m_listMiddleNodes[index].btn.interactable = true
            end)
        end
        
        return
    end

    -- 1 6
    local bMemberFlag = LoungeHandler:isLoungeMember()
    if not bMemberFlag then
        if not goTip.activeSelf then
            goTip:SetActive(true)
            self.m_listMiddleNodes[index].btn.interactable = false
            LeanTween.delayedCall(5.0, function()
                goTip:SetActive(false)
                self.m_listMiddleNodes[index].btn.interactable = true
            end)
        end
    else
        if index == 1 then
            CashBackPurchaseUI:Show()

        elseif index == 6 then
            self.m_listMiddleNodes[index].btn.interactable = false
            LeanTween.delayedCall(2.0, function()
                self.m_listMiddleNodes[index].btn.interactable = true
            end)
            MedalMasterMainUI:Show()
        else
            --
        end
    end

end

function LoungeHallUI:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        local timediff = LoungeHandler:getLoungeMemberTime()
        if timediff <= 0 then
            for i = 1, 6 do
                self.m_listMiddleNodes[i].goLock:SetActive(true)
            end

            self.goMedalLogo1:SetActive(false)
            self.goMedalLogo2:SetActive(false)
            self.goCountDownNode:SetActive(false)
        else
            for i = 1, 6 do
                self.m_listMiddleNodes[i].goLock:SetActive(false)
            end

            self.goCountDownNode:SetActive(true)

            if timediff < 24 * 3600 then
                local strCountDown = LoungeConfig:formatDiffTime(timediff)
                self.TextMeshProMemberTime.text = strCountDown
            end
        end

        if LoungeHandler:isLoungeMember() then
            self:handleOneMedalExpired()
        end
    end

end

-- 处理多余的
function LoungeHallUI:handleOneMedalExpired()
    if not LoungeHandler.data.activityData.bLoungeReward then
        return
    end
    
    LoungeHandler.data.activityData.bLoungeReward = false
    local nLongPoint = LoungeHandler:getLoungePoints()
    local nCoinReward = LoungeConfig:getLoungePointToCoinValue(nLongPoint)
    PlayerHandler:AddCoin(nCoinReward)
    LoungeHandler:addLoungePoints(-nLongPoint)
    OneMedalExpiredUI:Show(nCoinReward)
    self:refreshUI()
    EventHandler:Brocast("OnLoungeActivityStateChanged")

end
