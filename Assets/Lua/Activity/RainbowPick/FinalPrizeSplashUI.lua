--过了一关，给的奖励的弹窗，奖励包含卡包等
local FinalPrizeSplashUI = {}

function FinalPrizeSplashUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("FinalPrizeSplashUI")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
   LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    self.textWinCoin  = self.transform:FindDeepChild("textWinCoin"):GetComponent(typeof(UnityUI.Text))
    self.slotsNumberWinCoins = SlotsNumber:create("", 0, 100000000000, 0, 2)
    self.slotsNumberWinCoins:AddUIText(self.textWinCoin)
    self.slotsNumberWinCoins:SetTimeEndFlag(true)
    self.slotsNumberWinCoins:End(0)

    self.btn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btn)
    self.btn.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:OnClick()
    end)
    self.goSkip = self.btn.transform:FindDeepChild("Skip").gameObject
    self.goCollect = self.btn.transform:FindDeepChild("Collect").gameObject

    self.fAddCoinTime = 2.0
    self.fLife = 6.0

    self.tableGoCardPack = LuaHelper.GetTableFindChild(self.transform, 5, "CardPack")
    self.tableGoStar = LuaHelper.GetTableFindChild(self.transform, 5, "Star")
    self.textCardPackCount = self.transform:FindDeepChild("textCardPackCount"):GetComponent(typeof(TextMeshProUGUI))

    local go = self.transform:FindDeepChild("Container/LevelPrizeHaveGiftSplashUI/AdapterContainer/Gift/SlotsCards").gameObject
    self.cardPackUI = CardPackUI:new(go)
end

function FinalPrizeSplashUI:show(nLevelWinCoin, nPlayerCoin, nCardPackType, nCardPackCount)
    if self.transform.gameObject == nil then
        self.m_bInitFlag = false
    else
        if self.transform.gameObject:Equals(nil) then
            self.m_bInitFlag = false
        end
    end
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:Init()
    end
    self.bCanHide = true
    self.fMoneyCount = nLevelWinCoin
    self.nPlayerCoin = nPlayerCoin
    self.fAge = 0.0   
    self.bCanSkipFlag = true
    self.bCanHideFlag = false
    self.transform.gameObject:SetActive(true) 
    self.goSkip:SetActive(true)
    self.goCollect:SetActive(false)
    self.slotsNumberWinCoins:End(0)
    self.slotsNumberWinCoins:ChangeTo(self.fMoneyCount , self.fAddCoinTime)
    self.btn.interactable = true
    self.cardPackUI:set(nCardPackType, nCardPackCount)
    
    self.popController:show(nil , function()
        ActivityAudioHandler:PlaySound("rainbow_final_pop")
        GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    end, true)

    StaticDataHandler:add(ActiveManager.activeType, "nFinalPrizeTime")
end

function FinalPrizeSplashUI:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    self.btn.interactable = false
    ActivityAudioHandler:PlaySound("rainbow_closeWindow")
    CoinFly:fly2(self.textWinCoin.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 50, true, self.nPlayerCoin)
    local fDelayTime = 1.5 + 0.12 * 50
    LeanTween.delayedCall(fDelayTime, function()
        ViewScaleAni:Hide(self.transform.gameObject)
    end)
end

function FinalPrizeSplashUI:Update(dt)
    if self.slotsNumberWinCoins ~= nil then
        self.slotsNumberWinCoins:Update()
    end
    self.fAge = self.fAge + dt
    if self.fAge > self.fAddCoinTime then
        self:skip()
    end
    if self.fAge > self.fLife then
        self:hide()
    end
end

function FinalPrizeSplashUI:skip()
    if not self.bCanSkipFlag then
        return
    end
    self.bCanSkipFlag = false
    self.bCanHideFlag = true
    self.goSkip:SetActive(false)
    self.goCollect:SetActive(true)
    self.slotsNumberWinCoins:End(self.fMoneyCount)
end

function FinalPrizeSplashUI:OnClick()
    if self.bCanSkipFlag then
        self:skip()
    elseif self.bCanHideFlag then
        self:hide()
    end
end

return FinalPrizeSplashUI
