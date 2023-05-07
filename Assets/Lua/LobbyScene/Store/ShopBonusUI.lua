ShopBonusUI = {}

function ShopBonusUI:Show(trStoreBonusUI)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        self.transform = trStoreBonusUI.transform
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

        local trBtn = self.transform:FindDeepChild("BtnStoreBonusLogo")
        local btnCollect = trBtn:GetComponent( typeof(UnityUI.Button) )
        btnCollect.onClick:RemoveAllListeners()
        DelegateCache:addOnClickButton(btnCollect)
        btnCollect.onClick:AddListener(function()
            self:onBtnCollectClick()
        end)
        self.m_btnCollectStoreBonus = btnCollect
        
        local tr = self.transform:FindDeepChild("TextBonusValue")
        self.m_textStoreBonusInfo = tr:GetComponent(typeof(TextMeshProUGUI))
        self.m_textLeftTime = self.transform:FindDeepChild("TimeLeftText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_goNoCollectContainer = self.transform:FindDeepChild("NoCollectContainer").gameObject
        self.m_goCollectContainer = self.transform:FindDeepChild("CollectContainer").gameObject

        self.mTimeOutGenerator = TimeOutGenerator:New()
    end

    self:InitShopBonus()
    local strCoins = MoneyFormatHelper.coinCountOmit(CommonDbHandler.data.storeBonusData.m_nShopBonus)
    self.m_textStoreBonusInfo.text = strCoins .. " COINS"
end

function ShopBonusUI:Update()
    if self.mTimeOutGenerator:orTimeOut() then
        self:RefreshCountDown()
    end
end

function ShopBonusUI:InitShopBonus(bSet)
    local m_nShopBonus = math.random(1, 20) * 30000 * FormulaHelper:getVipAndLevelBonusMul()
    
    if CommonDbHandler.data.storeBonusData.nNextCollectBonusTime == nil or CommonDbHandler.data.storeBonusData.nNextCollectBonusTime == 0 then
        CommonDbHandler.data.storeBonusData.nNextCollectBonusTime = TimeHandler:GetServerTimeStamp()
        CommonDbHandler.data.storeBonusData.m_nShopBonus = m_nShopBonus
        CommonDbHandler:SaveDb()
    elseif bSet then
        CommonDbHandler.data.storeBonusData.nNextCollectBonusTime = TimeHandler:GetServerTimeStamp() + 3600 * 24
        CommonDbHandler.data.storeBonusData.m_nShopBonus = m_nShopBonus
        CommonDbHandler:SaveDb()
    end

end

function ShopBonusUI:RefreshCountDown()
	local currentTime = TimeHandler:GetServerTimeStamp()
    local endTime = CommonDbHandler.data.storeBonusData.nNextCollectBonusTime
    local timediff = endTime - currentTime
    self.m_btnCollectStoreBonus.interactable = timediff <= 0

    if timediff > 0 then
        self.m_goNoCollectContainer:SetActive(true)
        self.m_goCollectContainer:SetActive(false)

        local time = endTime - currentTime
        local days = time // (3600*24)
        local hours = time // 3600 - 24 * days
        local minutes = time // 60 - 24 * days * 60 - 60 * hours
        local seconds = time % 60
        self.m_textLeftTime.text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    else
        self.m_goNoCollectContainer:SetActive(false)
        self.m_goCollectContainer:SetActive(true)
    end
end

function ShopBonusUI:onBtnCollectClick()
    self.m_btnCollectStoreBonus.interactable = false
    GlobalAudioHandler:PlayBtnSound()

    local nBonusMoneyCount = CommonDbHandler.data.storeBonusData.m_nShopBonus
    PlayerHandler:AddCoin(nBonusMoneyCount)

    local coinPos = self.m_btnCollectStoreBonus.transform.position
    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12)

    LuckyEggHandler:addSilverHammerCount(1)
    self:InitShopBonus(true)
    
    local nType = LuckyEggGetHammerPop.enumHammerType.enumSilver
    LuckyEggGetHammerPop:Show(nType, false, 1)
    EventHandler:Brocast("PlayStoreBonus")

end