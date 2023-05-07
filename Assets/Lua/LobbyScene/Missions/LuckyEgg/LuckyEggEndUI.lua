local LuckyEggEndUI = {}

function LuckyEggEndUI:create(parent)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/LuckyEgg/LuckyEggGoldEnd.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(parent, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        
        self.m_textLuckyBonusSaved = self.transform:FindDeepChild("LuckyBonusSavedText"):GetComponent(typeof(UnityUI.Text))
        self.m_textTotalWin = self.transform:FindDeepChild("TotalWinText"):GetComponent(typeof(UnityUI.Text))

        self.m_goRemainHammerItem = self.transform:FindDeepChild("RemainHammerItem").gameObject
        self.m_textRemainHammerReward = self.transform:FindDeepChild("RemainHammerReward"):GetComponent(typeof(TextMeshProUGUI))
        self.m_textRemainHammerCount = self.transform:FindDeepChild("RemainHammerCount"):GetComponent(typeof(TextMeshProUGUI))

        self.m_textCoinsReward = self.transform:FindDeepChild("CoinsRewardText"):GetComponent(typeof(TextMeshProUGUI))

        self.m_btnBack = self.transform:FindDeepChild("BtnBack"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnBack)
        self.m_btnBack.onClick:AddListener(function()
            self:onBackBtnClicked()
        end)

        self.m_btnCollect = self.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCollect)
        self.m_btnCollect.onClick:AddListener(function()
            self:onBackBtnClicked()
        end)
        self.m_goGoldEggLogo = self.transform:FindDeepChild("GoldEggs").gameObject
        self.m_goGoldHammer = self.transform:FindDeepChild("GoldHammer").gameObject
        self.m_goSilverEggLogo = self.transform:FindDeepChild("SilverEggs").gameObject
        self.m_goSilverHammer = self.transform:FindDeepChild("SilverHammer").gameObject
    end
    self.transform.gameObject:SetActive(false)
end

function LuckyEggEndUI:show(eggType, hammerRemainWin, nHammerRemainCount, bonusSavedWin, endWin, totalWin, bIsUpgrade, bHasPrize, slotsParam)
    GlobalAudioHandler:PlaySound("wheel_cheer")
    self.slotsParam = slotsParam
    self.bIsUpgrade = bIsUpgrade
    self.bHasPrize = bHasPrize
    
    self.m_goGoldEggLogo:SetActive(eggType ~= LuckyEggMainUI.m_eggType.Silver)
    self.m_goGoldHammer:SetActive(eggType ~= LuckyEggMainUI.m_eggType.Silver)
    self.m_goSilverEggLogo:SetActive(eggType == LuckyEggMainUI.m_eggType.Silver)
    self.m_goSilverHammer:SetActive(eggType == LuckyEggMainUI.m_eggType.Silver)

    self.transform.gameObject:SetActive(true)
    self.m_goRemainHammerItem:SetActive(nHammerRemainCount ~= 0)
    if nHammerRemainCount ~= 0 then
        self.m_textRemainHammerReward.text = MoneyFormatHelper.coinCountOmit(hammerRemainWin)
        self.m_textRemainHammerCount.text = "Hammer <color=#ffee35>X"..nHammerRemainCount.." <color=#FFFFFFFF>Bonus"
    end
    self.m_textLuckyBonusSaved.text = MoneyFormatHelper.numWithCommas(bonusSavedWin)
    self.m_textCoinsReward.text = MoneyFormatHelper.coinCountOmit(endWin)
    self.m_textTotalWin.text = MoneyFormatHelper.numWithCommas(totalWin)
end

function LuckyEggEndUI:onBackBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    LuckyEggMainUI:Show()
    CoinFly:fly(self.m_btnCollect.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 6, true)
    if self.bIsUpgrade then
        PopStackViewHandler:Show(RoyalPassLevelUpUI, self.bHasPrize)
    end
    if self.slotsParam ~= nil then
        SlotsCardsGetPackPop:Show(self.slotsParam.packType, true, self.slotsParam.packCount)
    end
end

return LuckyEggEndUI