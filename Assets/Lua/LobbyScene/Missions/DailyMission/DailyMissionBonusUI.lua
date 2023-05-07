DailyMissionBonusUI = {}

DailyMissionBonusUI.m_childNodes = {} -- 各个可能用到的节点缓存 
DailyMissionBonusUI.m_nTaskIndex = 1

function DailyMissionBonusUI:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end

    return true
end

function DailyMissionBonusUI:Init(parent)
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end
    
    local bundleName = "Lobby"
	local assetPath = "Assets/ResourceABs/Lobby/Missions/DailyTask/DailyMissionBonusUI.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local goPanel = Unity.Object.Instantiate(goPrefab)
    self.transform = goPanel.transform
    self.transform:SetParent(parent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
	self.transform.gameObject:SetActive(false)

    -- BlackBG
    self.m_trBlackBG = self.transform:FindDeepChild("BlackBG")

    self.m_childNodes.MissionPointBonusNode = self.transform:FindDeepChild("MissionPointBonusNode").gameObject
    self.m_childNodes.CoinBonusNode = self.transform:FindDeepChild("CoinBonusNode").gameObject
    -- 第三个任务的奖励里有个金锤子
    self.m_childNodes.GoldHammerNode = self.transform:FindDeepChild("GoldHammerNode").gameObject

    -- TextMissionPoint -- 90 MISSION POINTS
    -- TextCoins -- 23K COINS
    self.m_childNodes.TextMissionPoint = self.transform:FindDeepChild("TextMissionPoint"):GetComponent(typeof(UnityUI.Text))
    self.m_childNodes.TextCoins = self.transform:FindDeepChild("TextCoins"):GetComponent(typeof(UnityUI.Text))
   
    local btnCollect = self.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnCollect)
    btnCollect.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:OnCollect()
    end)

    self.m_btnCollect = btnCollect
    self.animator = self.transform:GetComponentInChildren(typeof(Unity.Animator))
end

function DailyMissionBonusUI:Show(parent, nTaskIndex)
    self:Init(parent)
    self.m_nTaskIndex = nTaskIndex
    self.m_btnCollect.interactable = true
    self.transform.gameObject:SetActive(true)
    GlobalAudioHandler:PlaySound("popup")

    self.m_childNodes.GoldHammerNode:SetActive(false)
    if nTaskIndex == 3 then
        self.m_childNodes.GoldHammerNode:SetActive(true)
    end

    self.transform.localScale = Unity.Vector3.one
    self.m_trBlackBG.localScale = Unity.Vector3.one
    self:initUI()
end

function DailyMissionBonusUI:initUI()
    local MissionValues = DailyMissionConfig.m_MissionsValue[DailyMissionHandler.data.m_curTaskIndex]
    self.m_nMissionStars = MissionValues.rewards.missionStars

    if MissionValues.rewards.CoinCoef then
        self.m_childNodes.CoinBonusNode:SetActive(true)
        local nCoins = MissionValues.rewards.CoinCoef * DailyMissionHandler.data.m_OneDollarCoins
        self.m_nBonusCoins = nCoins
        local strCoins = MoneyFormatHelper.coinCountOmit(nCoins)
        self.m_childNodes.TextCoins.text = strCoins .. " Coins."
    end

    if MissionValues.rewards.missionPoints then
        self.m_childNodes.MissionPointBonusNode:SetActive(true)
        local nMissionPoints = MissionValues.rewards.missionPoints

        if CommonDbHandler:orInMissionStarBoosterTime() then
            nMissionPoints = LuaHelper.GetInteger(nMissionPoints * 2.5)
        end

        self.m_nMissionPoints = nMissionPoints
        if DailyMissionHandler.bTest then
            self.m_nMissionPoints = 400
        end 

        self.m_childNodes.TextMissionPoint.text = tostring(nMissionPoints) .. " Mission points."
    end

end

function DailyMissionBonusUI:OnCollect()
    local data = DailyMissionHandler.data

    self.m_btnCollect.interactable = false
    local missionPlayerData = data.m_MissionPlayerData[DailyMissionHandler.data.m_curTaskIndex]
    missionPlayerData.isReward = true
    
    DailyMissionHandler:addMissionPoints(self.m_nMissionPoints)
    if data.m_nMissionPoint >= 500 then
        DailyMissionUI:initMissionPointBtnStatus()
    end

    if self.m_nTaskIndex == 3 then
        LuckyEggHandler:setGetGoldHammer()
        LeanTween.delayedCall(2.5, function()
            local nType = LuckyEggGetHammerPop.enumHammerType.enumGold
            PopStackViewHandler:Show(LuckyEggGetHammerPop, nType, true, 1)
        end)
    end

    LeanTween.delayedCall(1.8, function()
        self:Hide()
        
        local tasks = DailyMissionConfig:getDailyMissionIndexs(data.m_nCurDayIndex)
        local cnt = #tasks
        if self.m_nTaskIndex < cnt then
            GlobalAudioHandler:PlaySound("item_unlock")
        else
            GlobalAudioHandler:PlaySound("onday_completed")
        end
    end)

    PlayerHandler:AddCoin(self.m_nBonusCoins)
    local coinPos = self.m_childNodes.TextCoins.transform.position
    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 6, true)

    local bLevelUp, bHasPrize = RoyalPassHandler:addStars(self.m_nMissionStars)
    DailyMissionHandler:StartTodayNextTask()
    DailyMissionUI:UpdateUI()

    if bLevelUp then
        local ftime = 2.5
        if self.m_nTaskIndex == 3 then
            ftime = 3.5
        end

        LeanTween.delayedCall(ftime, function()
            PopStackViewHandler:Show(RoyalPassLevelUpUI, bHasPrize)
        end)
    end
    
    DailyMissionUI:initMissionPointBtnStatus()
end

function DailyMissionBonusUI:Hide()
    self.animator:Play("DailyTaskTanKuangtuichuAni", -1, 0)
    LeanTween.delayedCall(1.0, function()
        self.transform.gameObject:SetActive(false)
    end)
end