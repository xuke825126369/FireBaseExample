require("Lua.LobbyScene.Missions.LuckyEgg.LuckyEggGetHammerPop")
require("Lua.LobbyScene.Missions.LuckyEgg.LuckyEggRoyalPassStar")
require("Lua.LobbyScene.Missions.LuckyEgg.LuckyEggSilverShopPop")
require("Lua.LobbyScene.Missions.LuckyEgg.LuckyEggGoldShopPop")

LuckyEggMainUI = {}
LuckyEggMainUI.m_eggType = {
    Silver = 1,
    Gold = 2
}

function LuckyEggMainUI:Show(parent)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local bundleName = "Lobby"
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/LuckyEgg/LuckyEgg.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(parent, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_goContent = self.transform:FindDeepChild("Content").gameObject
        self.m_goLockContent = self.transform:FindDeepChild("JieSuoNode").gameObject
        self.m_textLockContent = self.transform:FindDeepChild("LockLevelText"):GetComponent(typeof(UnityUI.Text))

        self.m_textSilverCount = self.transform:FindDeepChild("SilverCountText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_textGoldCount = self.transform:FindDeepChild("GoldCountText"):GetComponent(typeof(TextMeshProUGUI))

        self.m_textTimeLeft = self.transform:FindDeepChild("TextEndIn"):GetComponent(typeof(TextMeshProUGUI))
        self.m_goSilverDone = self.transform:FindDeepChild("Done1").gameObject
        self.m_btnSilverCheck = self.transform:FindDeepChild("CheckBtn1"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnSilverCheck)
        self.m_btnSilverCheck.onClick:AddListener(function()
            self:onSilverCheckBtnClicked()
        end)
        self.m_btnSilver = self.transform:FindDeepChild("LetPlayBtn1"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnSilver)
        self.m_btnSilver.onClick:AddListener(function()
            self:onSilverBtnClicked()
        end)
        
        self.m_goGoldDone = self.transform:FindDeepChild("Done2").gameObject
        self.m_btnGoldCheck = self.transform:FindDeepChild("CheckBtn2"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnGoldCheck)
        self.m_btnGoldCheck.onClick:AddListener(function()
            self:onGoldCheckBtnClicked()
        end)
        self.m_btnGold = self.transform:FindDeepChild("LetPlayBtn2"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnGold)
        self.m_btnGold.onClick:AddListener(function()
            self:onGoldBtnClicked()
        end)

        local introduceBtn = self.transform:FindDeepChild("IntroduceBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(introduceBtn)
        introduceBtn.onClick:AddListener(function()
            self:showIntroducePage()
        end)

        self.silverUI = require("Lua.LobbyScene.Missions.LuckyEgg.LuckyEggSilverUI")
        self.silverUI:create(parent)
        self.goldUI = require("Lua.LobbyScene.Missions.LuckyEgg.LuckyEggGoldUI")
        self.goldUI:create(parent)
        self.endUI = require("Lua.LobbyScene.Missions.LuckyEgg.LuckyEggEndUI")
        self.endUI:create(parent)
        self.collectRewardUI = require("Lua.LobbyScene.Missions.LuckyEgg.LuckyEggCollectReward")
        self.silverHammerUI = require("Lua.LobbyScene.Missions.LuckyEgg.LuckyEggSilverHammerUI")
        self.goldHammerUI = require("Lua.LobbyScene.Missions.LuckyEgg.LuckyEggGoldHammerUI")
        self.smashDayUI = require("Lua.LobbyScene.Missions.LuckyEgg.LuckyEggSmashDayUI")

        local royalStarsNode1 = self.transform:FindDeepChild("RoyalStarsNode1").gameObject
        self.silverRoyalPassStar = LuckyEggRoyalPassStar:new(royalStarsNode1, LuckyEggHandler.N_SILVER_END_SEND_ROYALPASS)
        local royalStarsNode2 = self.transform:FindDeepChild("RoyalStarsNode2").gameObject
        self.goldRoyalPassStar = LuckyEggRoyalPassStar:new(royalStarsNode2, LuckyEggHandler.N_GOLD_END_SEND_ROYALPASS)
        
        self.m_goIntroduceContent = self.transform:FindDeepChild("IntroduceContent").gameObject
        self.m_btnBack = self.m_goIntroduceContent.transform:FindDeepChild("BackBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnBack)
        self.m_btnBack.onClick:AddListener(function()
            self:onBackBtnClicked()
        end)
    end
    
    if LuckyEggHandler:orUnLock() then
        self.m_goContent:SetActive(true)
        self.m_goLockContent:SetActive(false)
        self.m_goIntroduceContent:SetActive(false)
        self:updateUI()
    else
        self.m_goContent:SetActive(false)
        self.m_goLockContent:SetActive(true)
        self.m_textLockContent.text = LuckyEggHandler.N_UNLOCK_LEVEL
    end

    self.transform.gameObject:SetActive(true)
    self.silverUI.transform.gameObject:SetActive(false)
    self.goldUI.transform.gameObject:SetActive(false)
    self.endUI.transform.gameObject:SetActive(false)
end

function LuckyEggMainUI:updateUI()
    self.silverRoyalPassStar:updateUI()
    self.goldRoyalPassStar:updateUI()
    local bSilverEnd = LuckyEggHandler:getSilverEnd()
    local bGoldEnd = LuckyEggHandler:getGoldEnd()
    
    local bPlayLuckyEgg = LuckyEggHandler:CheckCouldPlayLuckyEgg()
    self.bPlayLuckyEgg = bPlayLuckyEgg
    self.m_btnSilverCheck.gameObject:SetActive(not bPlayLuckyEgg)
    self.m_btnGoldCheck.gameObject:SetActive(not bPlayLuckyEgg)
    if bPlayLuckyEgg then
        self.m_goSilverDone:SetActive(bSilverEnd)
        self.m_goGoldDone:SetActive(bGoldEnd)
    else
        local bIsShowSmashDayPop = LuckyEggHandler:getShowSmashDayPop()
        if not bIsShowSmashDayPop then
            LuckyEggHandler:setShowSmashDayPop()
            self.smashDayUI:Show()
        end
        self.m_goSilverDone:SetActive(false)
        self.m_goGoldDone:SetActive(false)
    end
    
    if bSilverEnd then
        self.m_textSilverCount.text = "<color=#fff335>DONE<color=#53E8FAFF>"
    else
        self.m_textSilverCount.text = "<color=#fff335>".. LuckyEggHandler.data.nSilverCount.."<color=#53E8FAFF>/"..LuckyEggHandler.N_SILVER_COUNT
    end
    if bGoldEnd then
        self.m_textGoldCount.text = "<color=#fff335>DONE<color=#53E8FAFF>"
    else
        self.m_textGoldCount.text = "<color=#fff335>".. LuckyEggHandler:getGoldHammerCount().."<color=#53E8FAFF>/"..LuckyEggHandler.N_GOLD_COUNT
    end
    self.m_btnGold.interactable = not bGoldEnd
    self.m_btnSilver.interactable = not bSilverEnd
end

LuckyEggMainUI.fLastUpdateTime = 0.0
LuckyEggMainUI.bPlayLuckyEgg = false
function LuckyEggMainUI:Update()
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
            self.m_textTimeLeft.text = "in "..strTimeInfo
        else
            strTimeInfo = string.format("%02d:%02d:%02d", hours, minutes, seconds)
            self.m_textTimeLeft.text = "end in "..strTimeInfo
        end
        
        local bCurrentPlayLuckyEgg = LuckyEggHandler:CheckCouldPlayLuckyEgg()
        if self.bPlayLuckyEgg ~= bCurrentPlayLuckyEgg then
            self.bPlayLuckyEgg = bCurrentPlayLuckyEgg
            self:updateUI()
        end

        if timediff <= 0 then
            LuckyEggHandler:CheckSeasonEnd()
            self:updateUI()
        end
    end
end

function LuckyEggMainUI:onSilverBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    self.transform.gameObject:SetActive(false)
    self.silverUI:Show()
    self.goldUI.transform.gameObject:SetActive(false)
    self.endUI.transform.gameObject:SetActive(false)
end

function LuckyEggMainUI:onGoldBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    self.transform.gameObject:SetActive(false)
    self.goldUI:Show()
    self.silverUI.transform.gameObject:SetActive(false)
    self.endUI.transform.gameObject:SetActive(false)
end

function LuckyEggMainUI:showIntroducePage()
    GlobalAudioHandler:PlayBtnSound()
    self.m_goContent:SetActive(false)
    self.m_goIntroduceContent:SetActive(true)
end

function LuckyEggMainUI:Hide()
    self.transform.gameObject:SetActive(false)
    self.silverUI.transform.gameObject:SetActive(false)
    self.goldUI.transform.gameObject:SetActive(false)
    self.endUI.transform.gameObject:SetActive(false)
end

function LuckyEggMainUI:onBackBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    self.m_goContent:SetActive(true)
    self.m_goIntroduceContent:SetActive(false)
end

function LuckyEggMainUI:onSilverCheckBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    self.silverHammerUI:Show()
end

function LuckyEggMainUI:onGoldCheckBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    self.goldHammerUI:Show()
end

function LuckyEggMainUI:getLuckyEggSkuInfo(productId, nSilverCount, nGoldCount, wasPrice)
    local skuInfo = GameHelper:GetSimpleSkuInfoById( productId)
    skuInfo.finalCoins = 0
    skuInfo.wasPrice = wasPrice
    skuInfo.nSilverCount = nSilverCount
    skuInfo.nGoldCount = nGoldCount
    skuInfo.nType = SkuInfoType.LuckyEggSale
    return skuInfo
end