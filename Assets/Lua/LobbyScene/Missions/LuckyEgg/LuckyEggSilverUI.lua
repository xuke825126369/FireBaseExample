local LuckyEggSilverUI = {}

function LuckyEggSilverUI:create(parent)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "Lobby"
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/LuckyEgg/LuckyEggSilver.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(parent, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_btnSaveBonus = self.transform:FindDeepChild("BtnSaveBonus"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnSaveBonus)
        self.m_btnSaveBonus.onClick:AddListener(function()
            self:onSaveBonusBtnClicked()
        end)
        self.m_goSaveBonus = self.transform:FindDeepChild("TiShi").gameObject
        self.m_goSaveBonus.transform:FindDeepChild("TextOpen"):GetComponent(typeof(TextMeshProUGUI)).text = "OPEN IT WHILE YOU SMASHED THE SILVER EGG TREASURE"
        self.m_textSaveBonus = self.transform:FindDeepChild("TextCoins"):GetComponent(typeof(TextMeshProUGUI))

        self.m_textTimeLeft = self.transform:FindDeepChild("TextEndInfo"):GetComponent(typeof(TextMeshProUGUI))
        self.m_textSilverCount = self.transform:FindDeepChild("SilverCountText"):GetComponent(typeof(TextMeshProUGUI))

        self.m_btnBack = self.transform:FindDeepChild("BackBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnBack)
        self.m_btnBack.onClick:AddListener(function()
            self:onBackBtnClicked()
        end)

        self.m_mapBtn = {}
        for i = 1, 7 do
            local btn = self.transform:FindDeepChild("GoldEgg"..i):GetComponent(typeof(UnityUI.Button))
            DelegateCache:addOnClickButton(btn)
            self.m_mapBtn[i] = btn
            btn.onClick:AddListener(function()
                self:onSilverEggClicked(i)
            end)
        end
    end

    self.transform.gameObject:SetActive(false)

end

function LuckyEggSilverUI:Show()
    self.transform.gameObject:SetActive(true)
    self:updateUI()
end

function LuckyEggSilverUI:onSilverEggClicked(nIndex)
    if LuckyEggHandler:getSilverHammerCount() <= 0 then
        LuckyEggSilverShopPop:Show()
        return
    end

    local ani = self.m_mapBtn[nIndex].transform:GetComponent(typeof(Unity.Animator))
    ani:SetInteger("nPlayMode", 1)
    LeanTween.delayedCall(0.2, function()
        ani:SetInteger("nPlayMode", 2)
    end)
    for i=1,LuaHelper.tableSize(self.m_mapBtn) do
        self.m_mapBtn[i].interactable = false
    end

    LuckyEggHandler:addSilverHammerCount(-1)
    LuckyEggHandler:setSilverEggHammered(nIndex)
    local nTypeIndex, hammerRemainWin, nHammerRemainCount, bonusSavedWin, endWin, totalWin = LuckyEggHandler:RandomClickedSilverEgg()

    -- 根据nIndex来做动画
    if nTypeIndex == 1 then
        LeanTween.delayedCall(0.9, function()
            GlobalAudioHandler:PlaySound("break1")
        end)
        for i=1,LuaHelper.tableSize(self.m_mapBtn) do
            self.m_mapBtn[i].interactable = not LuckyEggHandler:getSilverEggHammered(i)
        end
    elseif nTypeIndex == 2 then
        Debug.Log("砸出一个收集金币！！！！！！！！！！！！！！！！")
        LeanTween.delayedCall(0.9, function()
            GlobalAudioHandler:PlaySound("break1")
        end)
        LeanTween.delayedCall(2, function()
            -- 显示收集金币页面
            LuckyEggMainUI.collectRewardUI:Show(hammerRemainWin, false)
            for i = 1, LuaHelper.tableSize(self.m_mapBtn) do
                self.m_mapBtn[i].interactable = not LuckyEggHandler:getSilverEggHammered(i)
            end
        end)
    elseif nTypeIndex == 3 then
        self.m_mapBtn[nIndex].transform:FindDeepChild("JinBi").gameObject:SetActive(true)
        LeanTween.delayedCall(0.9, function()
            GlobalAudioHandler:PlaySound("break3")
        end)
        LuckyEggHandler:setSilverEnd()
        local bIsUpgrade, bHasPrize = false, false
        local nUserLevel = PlayerHandler.nLevel
        if RoyalPassHandler:orUnLock() then
            bIsUpgrade, bHasPrize = RoyalPassHandler:addStars(LuckyEggMainUI.silverRoyalPassStar:getFinalRoyalStars())
        end
        local slotsParam = nil
        if nUserLevel >= SlotsCardsManager.m_nUnlockLevel then
            slotsParam = SlotsCardsGiftManager:getStampPackInActive(LuckyEggHandler.N_SILVER_END_SEND_SLOTSCARDS, 1)
        end
        LeanTween.delayedCall(2, function()
            self.transform.gameObject:SetActive(false)
            -- 显示GoldEnd页面
            LuckyEggMainUI.endUI:show(LuckyEggMainUI.m_eggType.Silver, hammerRemainWin,nHammerRemainCount, bonusSavedWin, endWin, totalWin, bIsUpgrade, bHasPrize, slotsParam)
        end)
    end
    self.m_textSilverCount.text = LuckyEggHandler.data.nSilverCount
    self.m_textSaveBonus.text = MoneyFormatHelper.numWithCommas(LuckyEggHandler.data.nSilverCollectMoney)
end

function LuckyEggSilverUI:updateUI()
    self.m_textSilverCount.text = LuckyEggHandler.data.nSilverCount
    for i=1,LuaHelper.tableSize(self.m_mapBtn) do
        local bFlag = LuckyEggHandler:getSilverEggHammered(i)
        self.m_mapBtn[i].interactable = not bFlag
        local ani = self.m_mapBtn[i].transform:GetComponent(typeof(Unity.Animator))
        ani:SetInteger("nPlayMode", bFlag and 2 or 0)
        local goCoins = self.m_mapBtn[i].transform:FindDeepChild("JinBi").gameObject
        if goCoins.activeSelf then
            goCoins:SetActive(false)
        end
    end
    self.m_textSaveBonus.text = MoneyFormatHelper.numWithCommas(LuckyEggHandler.data.nSilverCollectMoney)
end

function LuckyEggSilverUI:onSaveBonusBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    if self.m_goSaveBonus.activeSelf then
        self.m_goSaveBonus:SetActive(false)
    else
        self.m_goSaveBonus:SetActive(true)
    end
end

LuckyEggSilverUI.fLastUpdateTime = 0.0
function LuckyEggSilverUI:Update()
    if Unity.Time.time - self.fLastUpdateTime > 1.0 then
        self.fLastUpdateTime = Unity.Time.time

        local nowSecond = TimeHandler:GetServerTimeStamp()
        local timediff = LuckyEggHandler:GetSeasonEndTime() - nowSecond
        local days = timediff // (3600 * 24)
        local hours = timediff // 3600 - 24 * days
        local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
        local seconds = timediff % 60

        local strTimeInfo = ""
        if days > 0 then
            strTimeInfo = string.format("%d DAYS!", days)
        else
            strTimeInfo = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end 

        self.m_textTimeLeft.text = "end in "..strTimeInfo
        if timediff <= 0 then
            LuckyEggMainUI:Show()
        end
    end
end

function LuckyEggSilverUI:onBackBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    LuckyEggMainUI:Show()
end

return LuckyEggSilverUI