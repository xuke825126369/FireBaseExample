require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassScollView")
require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassFreeRewardsUI")
require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassRewardsUI")
require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassLevelUpUI")
require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassTopLevelUI")
require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassIntroduceUI")
require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassMissionChestUI")
require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassUnlockRoyalUI")
require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassBuyLevelUI")
require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassShopUI")
require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassSesonEndUI")
require("Lua.LobbyScene.Missions.RoyalPass.RoyalStarBoosterUI")
require("Lua.LobbyScene.Missions.UseGemCompleteNowUI")

RoyalPassMainUI = {}
function RoyalPassMainUI:Show(parent)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/RoyalPass/RoyalPass.prefab")
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

        self.m_textStarsCount = self.transform:FindDeepChild("StarsCountText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_textTimeLeft = self.transform:FindDeepChild("TimeLeftText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_textLevelUpgrade = self.transform:FindDeepChild("LevelUpgradeText"):GetComponent(typeof(TextMeshProUGUI))

        self.m_textLevel = self.transform:FindDeepChild("LevelText"):GetComponent(typeof(UnityUI.Text))
        self.m_imgProgress = self.transform:FindDeepChild("JinDuTiaoProgress"):GetComponent(typeof(UnityUI.Image))
        self.m_goNoPurchaseLockBg = self.transform:FindDeepChild("NoPurchaseLockBg").gameObject
        
        local btn = self.m_goNoPurchaseLockBg:AddComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            local animator = self.m_goNoPurchaseLockBg:GetComponentInChildren(typeof(Unity.Animator))
            animator:Play("Rotate", 0, 0)
        end)
        
        self.m_btnCollectAll = self.transform:FindDeepChild("BtnCollectAll"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCollectAll)
        self.m_btnCollectAll.onClick:AddListener(function()
            self:onCollectAllClicked()
        end)

        self.m_btnBuyLevels = self.transform:FindDeepChild("BtnBuyLevels"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnBuyLevels)
        self.m_btnBuyLevels.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            RoyalPassBuyLevelUI:Show()
        end)

        self.m_btnUnlockRoyalPass = self.transform:FindDeepChild("BtnUnlockRoyalPass"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnUnlockRoyalPass)
        self.m_btnUnlockRoyalPass.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            RoyalPassShopUI:Show()
        end)

        local btnIntroduce = self.transform:FindDeepChild("IntroduceBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnIntroduce)
        btnIntroduce.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onIntroduceBtnClicked()
        end)

        self.m_btnToLeftLevel = self.transform:FindDeepChild("BtnToLeftLevel"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnToLeftLevel)
        self.m_btnToLeftLevel.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            RoyalPassScollView:onBtnToLeftLevelClicked()
        end)
        self.m_btnToLeftLevel.gameObject:SetActive(false)
        self.m_btnToRightLevel = self.transform:FindDeepChild("BtnToRightLevel"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnToRightLevel)
        self.m_btnToRightLevel.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            RoyalPassScollView:onBtnToRightLevelClicked()
        end)
        self.m_btnToRoyalChest = self.transform:FindDeepChild("BtnToRoyalChest"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnToRoyalChest)
        self.m_btnToRoyalChest.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            RoyalPassScollView:onBtnToRoyalChestClicked()
        end)
        self.m_trTipContainer = self.transform:FindDeepChild("TipContainer")

        self.m_goMissionStarContainer = self.transform:FindDeepChild("MissionStarContainer").gameObject
        self.m_textRoyalStarTimeLeft = self.transform:FindDeepChild("RoyalStarTimeLeft"):GetComponent(typeof(TextMeshProUGUI))
        self.m_textMorePercent = self.transform:FindDeepChild("MorePercentText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_textMorePercent.text = "150%"

        local tr = self.transform:FindDeepChild("BtnMissionStarBoosterPurchase")
        self.btnMissionStarBoosterPurchase = tr:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnMissionStarBoosterPurchase)
        self.btnMissionStarBoosterPurchase.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onMissionStarBoosterPurchase()
        end)

        self.BoosterTimeCountDownNode = self.transform:FindDeepChild("BoosterTimeCountDownNode").gameObject
    end

    if RoyalPassHandler:orUnLock() then
        RoyalPassScollView:Init(self.transform)
        self.m_goContent:SetActive(true)
        self.m_goLockContent:SetActive(false)
        self:updateUI()
    else
        self.m_goContent:SetActive(false)
        self.m_goLockContent:SetActive(true)
        self.m_textLockContent.text = RoyalPassConfig.N_UNLOCK_LEVEL
    end
    
    self.transform.gameObject:SetActive(true)
    RoyalPassHandler.m_bClaimLoungeDayPassFlag = false
    RoyalPassHandler.m_LoungeDayPassParam = {nDayPass = 0, nPrizeCoin = 0}
end

function RoyalPassMainUI:updateBtnStatus()
    local nCount = RoyalPassHandler:getNumberOfRewardsNotReceived()
    self.m_btnCollectAll.gameObject:SetActive(nCount > 0)
    self.m_btnBuyLevels.gameObject:SetActive(RoyalPassHandler.m_nLevel <= 95)
    self.m_btnUnlockRoyalPass.gameObject:SetActive(not RoyalPassDbHandler.data.m_bIsPurchase)
end

function RoyalPassMainUI:updateUI()
    self:updateBtnStatus()
    self.m_textStarsCount.text = string.format("%d", RoyalPassDbHandler.data.nStars)
    self.m_textLevel.text = RoyalPassHandler.m_nLevel
    
    if RoyalPassHandler.m_nLevel >= 100 then
        self.m_imgProgress.fillAmount = 1
        if self.m_textLevelUpgrade.gameObject.activeSelf then
            self.m_textLevelUpgrade.gameObject:SetActive(false)
        end
    else
        local nCurrent = RoyalPassConfig:GetCurrentStar()
        local nCount = RoyalPassConfig:GetCurrentUpgradeLevelNeedStar()
        self.m_imgProgress.fillAmount = nCurrent / nCount
        self.m_textLevelUpgrade.text = string.format("%d / %d", nCurrent, nCount)
        if not self.m_textLevelUpgrade.gameObject.activeSelf then
            self.m_textLevelUpgrade.gameObject:SetActive(true)
        end
    end
    self.m_goNoPurchaseLockBg:SetActive(not RoyalPassDbHandler.data.m_bIsPurchase)
    RoyalPassScollView:UpdateAllItem()
end

RoyalPassMainUI.fLastUpdateTime = 0.0
function RoyalPassMainUI:Update()
    if Unity.Time.time - self.fLastUpdateTime > 1.0 then
        self.fLastUpdateTime = Unity.Time.time
        self:updateTimeLeft()
    end
end

function RoyalPassMainUI:updateTimeLeft()
    if CommonDbHandler:orInMissionStarBoosterTime() then
        if not self.BoosterTimeCountDownNode.activeSelf then
            self.BoosterTimeCountDownNode:SetActive(true)
        end

        local timediff = CommonDbHandler.data.MissionStarBoosterEndTime - TimeHandler:GetServerTimeStamp()
        local days = timediff // (3600 * 24)
        local hours = timediff // 3600 - 24 * days
        local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
        local seconds = timediff % 60
        self.m_textRoyalStarTimeLeft.text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    else
        if self.BoosterTimeCountDownNode.activeSelf then
            self.BoosterTimeCountDownNode:SetActive(false)
        end
    end
    
    local timediff = RoyalPassDbHandler.data.m_nEndTime - TimeHandler:GetServerTimeStamp()
    local days = timediff // (3600*24)
    local hours = timediff // 3600 - 24 * days
    local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
    local seconds = timediff % 60
    
    local strTimeInfo = ""
    if days > 0 then
        strTimeInfo = string.format("%d DAYS!", days)
    else
        strTimeInfo = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end

    local nSeason = math.modf(RoyalPassDbHandler.data.m_nSeason + 1)
    self.m_textTimeLeft.text = "SEASON "..nSeason.. " ENDS IN "..strTimeInfo

    if timediff <= 0 then
        RoyalPassHandler:setRoyalPassEndTime()
        RoyalPassHandler:CheckSeasonEnd()
        RoyalPassSesonEndUI:Show()
        self:updateUI()
    end

end

function RoyalPassMainUI:onCollectAllClicked()
    GlobalAudioHandler:PlayBtnSound()
    local bHasPurchase = RoyalPassDbHandler.data.m_bIsPurchase

    local items = {}
    local bHasCoins = false
    for i = 0, RoyalPassHandler.m_nLevel do
        local prizeInfo = RoyalPassConfig:GetFreePassLevelPrize(i + 1)
        for j = 1 , LuaHelper.tableSize(prizeInfo) do
            if (not RoyalPassDbHandler.data.m_mapFreePassGet[i + 1][j].bGet) and prizeInfo[j].nType ~= RoyalPassConfig.PrizeType.None then
                if prizeInfo[j].nType == RoyalPassConfig.PrizeType.Coins  or prizeInfo[j].nType == RoyalPassConfig.PrizeType.CoinsAndVip then
                    bHasCoins = true
                end
                if j == 1 then
                    local item = RoyalPassScollView.freePassPrizeInfos[i][j].item
                    table.insert( items, item )
                else
                    if RoyalPassDbHandler.data.m_mapFreePassGet[i+1][j].bInLimitedEndFinish then
                        local item = RoyalPassScollView.freePassLimitedInfos[i].passItem
                        table.insert( items, item )
                    end
                end
            end
        end
    end

    if bHasPurchase then
        for i = 0, RoyalPassHandler.m_nLevel do
            local prizeInfo = RoyalPassConfig:GetRoyalPassLevelPrize(i+1)
            for j = 1 , LuaHelper.tableSize(prizeInfo) do
                if (not RoyalPassDbHandler.data.m_mapRoyalPassGet[i+1][j].bGet) and prizeInfo[j].nType ~= RoyalPassConfig.PrizeType.None then
                    if prizeInfo[j].nType == RoyalPassConfig.PrizeType.Coins or prizeInfo[j].nType == RoyalPassConfig.PrizeType.CoinsAndVip then
                        bHasCoins = true
                    end
                    if j == 1 then
                        local item = RoyalPassScollView.royalPassPrizeInfos[i][j].item
                        table.insert( items, item )
                    else
                        if RoyalPassDbHandler.data.m_mapRoyalPassGet[i+1][j].bInLimitedEndFinish then
                            local item = RoyalPassScollView.royalPassLimitedInfos[i].passItem
                            table.insert( items, item )
                        end
                    end
                end
            end
        end
        RoyalPassRewardsUI:Show(items, bHasCoins)
        RoyalPassHandler:setFreePassAllGet()
        RoyalPassHandler:setRoyalPassAllGet()
    else
        
        RoyalPassFreeRewardsUI:Show(items, bHasCoins)
        RoyalPassHandler:setFreePassAllGet()
    end
    self:updateUI()
end

function RoyalPassMainUI:onIntroduceBtnClicked()
    RoyalPassIntroduceUI:Show()
end

function RoyalPassMainUI:onMissionStarBoosterPurchase()
    RoyalStarBoosterUI:Show(MissionMainUIPop.m_trPopNode)
end