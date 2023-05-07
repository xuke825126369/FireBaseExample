require("Lua.LobbyScene.FreeBonusGame.FreeBonusRedOrBlueGame")
require("Lua.LobbyScene.FreeBonusGame.FreeBonusSettleFrame")
require("Lua.LobbyScene.FreeBonusGame.FreeBonusSettleMultiplierFrame")

require("Lua.LobbyScene.MegaBall.MegaballPremiumBegin")
require("Lua.LobbyScene.MegaBall.MegaballPremiumPurchaseBegin")
require("Lua.LobbyScene.MegaBall.MegaballPremiumUI")
require("Lua.LobbyScene.MegaBall.MegaballPremiumEnd")

FreeBonusGamePopView = {}
FreeBonusGamePopView.m_nInitRedWinCoinRatio = 2
FreeBonusGamePopView.m_nInitBlueWinCoinRatio = 1
FreeBonusGamePopView.m_nInitLuckyWheelWinCoinRatio = 1 -- wheelOfFun转盘上配置的数不会超过5美元

function FreeBonusGamePopView:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local bundleName = "Lobby"
    local assetPath = "Assets/ResourceABs/Lobby/FreeBonusGameUI/FreeBonusGamePop.prefab"
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
    local goPanel = Unity.Object.Instantiate(goPrefab)

    local goParent = LobbyScene.popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    local btn = self.transform:FindDeepChild("CloseButton"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btn)
    btn.onClick:AddListener(function()
        self:onCloseBtnClicked()
    end)

    self.redBtn = self.transform:FindDeepChild("RedBtn"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.redBtn)
    self.redBtn.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:forRedBonusGameFetchNetTimeCallback()
    end)
    self.redTime = self.transform:FindDeepChild("RedTime"):GetComponent(typeof(TextMeshProUGUI))

    self.blueBtn = self.transform:FindDeepChild("BlueBtn"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.blueBtn)
    self.blueBtn.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:forBlueBonusGameFetchNetTimeCallback()
    end)
    self.blueTime = self.transform:FindDeepChild("BlueTime"):GetComponent(typeof(TextMeshProUGUI))

    self.luckyWheelBtn = self.transform:FindDeepChild("LuckyWheelBtn"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.luckyWheelBtn)
    self.luckyWheelBtn.onClick:AddListener(function()
        self:onLuckyWheelGameBtnClick()
    end)
    self.luckyWheelProgress = self.transform:FindDeepChild("LuckyWheelProgress")
    self.goLuckyWheelNoCollectState = self.transform:FindDeepChild("LuckyWheelItem/Get").gameObject
    
    self.megaBallBtn = self.transform:FindDeepChild("MegaBallBtn"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.megaBallBtn)
    self.megaBallBtn.onClick:AddListener(function()
        self:onMegaBallGameBtnClick()
    end)
    self.megaBallProgress = self.transform:FindDeepChild("MegaBallProgress")
    self.goMegaBallNoCollectState = self.transform:FindDeepChild("MegaBallItem/Get").gameObject

    self.m_textRedWinCoin = self.transform:FindDeepChild("RedWinCoinText"):GetComponent(typeof(TextMeshProUGUI))
    self.m_textBlueWinCoin = self.transform:FindDeepChild("BlueWinCoinText"):GetComponent(typeof(TextMeshProUGUI))
    self.m_textLuckyWheelWinCoin = self.transform:FindDeepChild("LuckyWheelCoinText"):GetComponent(typeof(TextMeshProUGUI))
    
    self.m_aniMegaBall = self.transform:FindDeepChild("BallRollAni"):GetComponent(typeof(Unity.Animator))
    self.m_aniLuckyWheel = self.transform:FindDeepChild("LuckyWheelItem"):GetComponent(typeof(Unity.Animator))
    self.m_imgProgress = self.transform:FindDeepChild("jinDuTiao"):GetComponent(typeof(UnityUI.Image))

    self.mNumberAddAniRedWinCoin = NumberAddLuaAni:New(self.m_textRedWinCoin)
    self.mNumberAddAniBlueWinCoin = NumberAddLuaAni:New(self.m_textBlueWinCoin)
    self.mNumberAddAniLuckyWheelWinCoin = NumberAddLuaAni:New(self.m_textLuckyWheelWinCoin)

    self.mTimeOutGenerator = TimeOutGenerator:New()
end 

function FreeBonusGamePopView:Show()
    self:Init()
    self.transform:SetAsLastSibling()
    local nMul, fProgress, nIndex = FreeBonusMultiplier:getMultiplier()
    self.m_imgProgress.fillAmount = fProgress
        
    self:CheckBtnStatus()

    local listMultiplier = FreeBonusGameHandler.listMultiplier
    for i = 1, 6 do
        self.textMultuile = self.transform:FindDeepChild("MultiplierItem/TextMeshProx"..i):GetComponent(typeof(TextMeshProUGUI))
        self.textMultuile.text = "X"..listMultiplier[i]
    end

    ViewAlphaAni:Show(self.transform.gameObject, function()
        if self.bLuckyWheelFlag then
            self.m_aniLuckyWheel:SetInteger("nPlayMode", 1)
        else
            self.m_aniLuckyWheel:SetInteger("nPlayMode", 0)
        end
        if self.bMegaFlag then
            self.m_aniMegaBall:SetInteger("nPlayMode", 1)
        else
            self.m_aniMegaBall:SetInteger("nPlayMode", 0)
        end
    end)

    self:StartCoinsUp()
end

function FreeBonusGamePopView:CheckBtnStatus()
    self.bRedFlag = FreeBonusGameHandler:CheckCouldPlayRedBonus()
    self.redBtn.gameObject:SetActive(self.bRedFlag)
    self.redTime.gameObject:SetActive(not self.bRedFlag)

    self.bBlueFlag = FreeBonusGameHandler:CheckCouldPlayBlueBonus()
    self.blueBtn.gameObject:SetActive(self.bBlueFlag)
    self.blueTime.gameObject:SetActive(not self.bBlueFlag)

    self.bLuckyWheelFlag = FreeBonusGameHandler:CheckCouldPlayLuckyWheel()
    self.luckyWheelBtn.gameObject:SetActive(self.bLuckyWheelFlag)
    self.goLuckyWheelNoCollectState.gameObject:SetActive(not self.bLuckyWheelFlag)
    self:UpdateLuckyWheelProgressUI()
    
    self.bMegaFlag = FreeBonusGameHandler:CheckCouldPlayMegaballBonus()
    self.megaBallBtn.gameObject:SetActive(self.bMegaFlag)
    self.goMegaBallNoCollectState.gameObject:SetActive(not self.bMegaFlag)
    self:UpdateMegaballProgressUI()
end

function FreeBonusGamePopView:UpdateLuckyWheelProgressUI()
    local nCount = FreeBonusGameHandler:GetLuckyWheelCount()
    for i = 0, (self.luckyWheelProgress.childCount - 1) do
        self.luckyWheelProgress:GetChild(i):GetChild(0).gameObject:SetActive(i < nCount)
    end
end

function FreeBonusGamePopView:UpdateMegaballProgressUI()
    local nCount = FreeBonusGameHandler:GetMegaballBonusCount()
    for i = 0, (self.megaBallProgress.childCount - 1) do
        self.megaBallProgress:GetChild(i):GetChild(0).gameObject:SetActive(i < nCount)
    end
end

function FreeBonusGamePopView:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewAlphaAni:Hide(self.transform.gameObject)
end

function FreeBonusGamePopView:Update()
    if not self.mTimeOutGenerator:orTimeOut() then
        return
    end

    local lastRedFlag = self.bRedFlag
    local lastBlueFlag = self.bBlueFlag
    local lastLuckyWheelFlag = self.bLuckyWheelFlag
    local lastMegaFlag = self.bMegaFlag

    local nowSecond = TimeHandler:GetServerTimeStamp()
    self.bRedFlag = FreeBonusGameHandler:CheckCouldPlayRedBonus()
    if lastRedFlag ~= self.bRedFlag then
        lastRedFlag = self.bRedFlag
        self.redBtn.gameObject:SetActive(self.bRedFlag)
        self.redTime.gameObject:SetActive(not self.bRedFlag)
    end

    if not self.bRedFlag then
        local endTime = FreeBonusGameHandler.data.nRedBonusTime + FreeBonusGameHandler.fRedBonusDiffTime
        local timediff = endTime - nowSecond

        local days = timediff // (3600*24)
        local hours = timediff // 3600 - 24 * days
        local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
        local seconds = timediff % 60
        if days > 0 then
            self.redTime.text = string.format("%d days!",days)
        else
            self.redTime.text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end
    end

    self.bBlueFlag = FreeBonusGameHandler:CheckCouldPlayBlueBonus()
    if lastBlueFlag ~= self.bBlueFlag then
        lastBlueFlag = self.bBlueFlag
        self.blueBtn.gameObject:SetActive(self.bBlueFlag)
        self.blueTime.gameObject:SetActive(not self.bBlueFlag)
    end
    if not self.bBlueFlag then
        local endTime = FreeBonusGameHandler.data.nBlueBonusTime + FreeBonusGameHandler.fBlueBonusDiffTime
        local timediff = endTime - nowSecond

        local days = timediff // (3600*24)
        local hours = timediff // 3600 - 24 * days
        local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
        local seconds = timediff % 60
        if days > 0 then
            self.blueTime.text = string.format("%d days!",days)
        else
            self.blueTime.text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end
    end

    self.bLuckyWheelFlag = FreeBonusGameHandler:CheckCouldPlayLuckyWheel()
    if lastLuckyWheelFlag ~= self.bLuckyWheelFlag then
        lastLuckyWheelFlag = self.bLuckyWheelFlag
        self.luckyWheelBtn.gameObject:SetActive(self.bLuckyWheelFlag)
        self.goLuckyWheelNoCollectState.gameObject:SetActive(not self.bLuckyWheelFlag)
        if self.bLuckyWheelFlag then
            self.m_aniLuckyWheel:SetInteger("nPlayMode", 1)
        else
            self.m_aniLuckyWheel:SetInteger("nPlayMode", 0)
        end
    end

    self.bMegaFlag = FreeBonusGameHandler:CheckCouldPlayMegaballBonus()
    if lastMegaFlag ~= self.bMegaFlag then
        lastMegaFlag = self.bMegaFlag
        self.megaBallBtn.gameObject:SetActive(self.bMegaFlag)
        self.goMegaBallNoCollectState:SetActive(not self.bMegaFlag)
        if self.bMegaFlag then
            self.m_aniMegaBall:SetInteger("nPlayMode", 1)
        else
            self.m_aniMegaBall:SetInteger("nPlayMode", 0)
        end
    end

end

function FreeBonusGamePopView:StartCoinsUp()
    local basePrize = FreeBonusGameHandler:getBasePrize()
    self.m_nInitRedWinCoin = basePrize * self.m_nInitRedWinCoinRatio
    self.m_nInitBlueWinCoin = basePrize * self.m_nInitBlueWinCoinRatio
    basePrize = 1250000 * FormulaHelper:getVipAndLevelBonusMul()
    self.m_nInitLuckyWheelWinCoin = basePrize * self.m_nInitLuckyWheelWinCoinRatio
    
    self.mNumberAddAniRedWinCoin:End(self.m_nInitRedWinCoin)
    self.mNumberAddAniBlueWinCoin:End(self.m_nInitBlueWinCoin)
    self.mNumberAddAniLuckyWheelWinCoin:End(self.m_nInitLuckyWheelWinCoin)

    local redWinCoinUp = self.m_nInitRedWinCoin * 10
    local blueWinCoinUp = self.m_nInitBlueWinCoin * 10
    local luckyWheelWinCoinUp = self.m_nInitLuckyWheelWinCoin * 10

    self.mNumberAddAniRedWinCoin:ChangeTo(redWinCoinUp, 24 * 3600)
    self.mNumberAddAniBlueWinCoin:ChangeTo(blueWinCoinUp, 24 * 3600)
    self.mNumberAddAniLuckyWheelWinCoin:ChangeTo(luckyWheelWinCoinUp, 24 * 3600)
end

function FreeBonusGamePopView:onMegaBallGameBtnClick()
    GlobalAudioHandler:PlayBtnSound()
    self.megaBallBtn.gameObject:SetActive(false)
    self.m_aniMegaBall:SetInteger("nPlayMode", 0)
    
    local listMultiply = MegaballPremiumUI.m_listMultiplyFree
    local listProb = {390, 360, 350, 360, 310}
    local index = LuaHelper.GetIndexByRate(listProb)
    local nMultiplyCoef = listMultiply[index]
    local nBaseCoins = FreeBonusGameHandler:getMegaBallBaseBonus()
    local vipMultiply = VipHandler:GetVipCoefInfo()
    local nFinalBonus = nBaseCoins * nMultiplyCoef * vipMultiply
    PlayerHandler:AddCoin(nFinalBonus)
    FreeBonusGameHandler:ResetMegaballBonusCount()

    -- 界面展示
    local data = {nBaseCoins = nBaseCoins, nMultiplyCoef = nMultiplyCoef}
    MegaballPremiumUI.m_BonusData = data
    MegaballPremiumUI:Show(false)
    self:CheckBtnStatus()
end

function FreeBonusGamePopView:onLuckyWheelGameBtnClick() 
    GlobalAudioHandler:PlayBtnSound()
    self.luckyWheelBtn.gameObject:SetActive(false)
    FreeBonusGameHandler:ResetLuckyWheelCount()
    self.m_aniLuckyWheel:SetInteger("nPlayMode", 0)
    WheelOfFunPopView:Show({})

    self:CheckBtnStatus()
end

function FreeBonusGamePopView:forRedBonusGameFetchNetTimeCallback()
    local netTime = TimeHandler:GetServerTimeStamp()
    local lastTime = FreeBonusGameHandler.data.nRedBonusTime
    if(netTime - lastTime >= FreeBonusGameHandler.fRedBonusDiffTime) then
        FreeBonusRedOrBlueGame:Show(1)
        self:UpdateLuckyWheelProgressUI()
    end
end

function FreeBonusGamePopView:forBlueBonusGameFetchNetTimeCallback()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local lastHourBonusNetTime = FreeBonusGameHandler.data.nBlueBonusTime
    if nowSecond - lastHourBonusNetTime >= FreeBonusGameHandler.fBlueBonusDiffTime then
        FreeBonusRedOrBlueGame:Show(2)
    end
end
