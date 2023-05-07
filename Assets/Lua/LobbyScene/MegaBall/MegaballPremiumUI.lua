require ("Lua/LobbyScene/MegaBall/MegaballPremiumBegin")
require ("Lua/LobbyScene/MegaBall/MegaballPremiumEnd")
require ("Lua/LobbyScene/MegaBall/MegaballPremiumPurchaseBegin")

MegaballPremiumUI = {}

MegaballPremiumUI.transform = nil
MegaballPremiumUI.m_aniBallRoll = nil -- 两个clip QiuyaojiangAni QiuyaojiangxunhuanAni
MegaballPremiumUI.m_aniBallFlyOut = nil
MegaballPremiumUI.m_listGoResultBall = {} --
MegaballPremiumUI.m_goBallFlyOut = nil -- 要出结果的时候显示...

MegaballPremiumUI.m_BonusData = {nBaseCoins = 100000, nMultiplyCoef = 2000}
MegaballPremiumUI.m_listMultiplyFree = {100, 200, 300, 400, 500}
MegaballPremiumUI.m_listMultiplyPurchase = {1000, 2000, 3000, 4000, 5000}
MegaballPremiumUI.m_bPurchaseFlag = false
MegaballPremiumUI.m_goBeginUI = nil

function MegaballPremiumUI:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local assetPath = "Assets/ResourceABs/Lobby/MegaBall/MegaballPremiumUI.prefab"
    if self.bPurchaseFlag then
        assetPath = "Assets/ResourceABs/Lobby/MegaBall/MegaballPremiumUIPurchase.prefab"
    end

    local bundleName = "Lobby"
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
    local goPanel = Unity.Object.Instantiate(goPrefab)
    self.transform = goPanel.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    local rectTr = self.transform:GetComponent(typeof(Unity.RectTransform))
    rectTr.anchoredPosition = Unity.Vector2.zero
    rectTr.sizeDelta = Unity.Vector2.zero

    local tr = self.transform:FindDeepChild("MegaballPremiumBegin")
    self.m_goBeginUI = tr.gameObject

    local trBallRollAni = self.transform:FindDeepChild("BallRollAni")
    self.m_aniBallRoll = trBallRollAni:GetComponent(typeof(Unity.Animator))

    local trBallFlyOutAni = self.transform:FindDeepChild("BallFlyOutAni")
    self.m_aniBallFlyOut = trBallFlyOutAni:GetComponent(typeof(Unity.Animator))

    local listStrBallNames = {"GreenBall", "BlueBall", "PurpleBall", "RedBall", "YellowBall"}
    for i = 1, 5 do
        local strName = listStrBallNames[i]
        local goNode = trBallFlyOutAni:FindDeepChild(strName).gameObject
        self.m_listGoResultBall[i] = goNode
        goNode:SetActive(false)
    end

    self.m_goBallFlyOut = self.transform:FindDeepChild("BallFlyOut").gameObject
end

function MegaballPremiumUI:Show(bPurchaseFlag)
    self.m_bPurchaseFlag = bPurchaseFlag
    self:Init()

    if bPurchaseFlag then
        MegaballPremiumPurchaseBegin:Init(self.m_goBeginUI)
        MegaballPremiumPurchaseBegin:Show()
    else
        MegaballPremiumBegin:Init(self.m_goBeginUI)
        MegaballPremiumBegin:Show()
    end
    
    self.transform.gameObject:SetActive(true)
    self.m_goBallFlyOut:SetActive(false)
    GlobalAudioHandler:PlayBackMusic("megaball_background")
end

function MegaballPremiumUI:playAni(bShowPurchaseWheel)
    AppLocalEventHandler:OnPlayLuckyMegaBallEvt()
    
    self.m_aniBallRoll:Play("QiuyaojiangAni", -1, 0)
    LeanTween.delayedCall(3.06, function()
        self.m_aniBallRoll:Play("QiuyaojiangxunhuanAni", -1, 0)
    end)

    LeanTween.delayedCall(9.0, function()
        self.m_goBallFlyOut:SetActive(true)
        local nMulti = self.m_BonusData.nMultiplyCoef

        local listMultiply = self.m_listMultiplyFree
        if self.m_bPurchaseFlag then
            listMultiply = self.m_listMultiplyPurchase
        end

        local index = LuaHelper.indexOfTable(listMultiply, nMulti)
        self.m_listGoResultBall[index]:SetActive(true)
        GlobalAudioHandler:PlaySound("megaball_celebration")
    end)

    LeanTween.delayedCall(12.0, function()
        local vipMultiply = VipHandler:GetVipCoefInfo()
        FreeBonusSettleMultiplierFrame:Show( self.m_BonusData.nBaseCoins, vipMultiply, self.m_BonusData.nMultiplyCoef, function()
            self:Hide()
            if bShowPurchaseWheel then
                self:Show(true)
            end
        end)
    end)

end

function MegaballPremiumUI:Hide()
    Unity.Object.Destroy(self.transform.gameObject)
    GlobalAudioHandler:PlayLobbyBackMusic() -- 这里停了活动背景音会把之前的恢复播放
end
