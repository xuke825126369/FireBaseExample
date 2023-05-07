--过了一关，给的奖励弹窗，只有金币
local LevelPrizeSplashUI = {}

function LevelPrizeSplashUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("LevelPrizeSplashUI")
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

    self.goRatio = self.transform:FindDeepChild("Ratio").gameObject
    self.textRatio = self.goRatio.transform:FindDeepChild("textRatio"):GetComponent(typeof(UnityUI.Text))
end

function LevelPrizeSplashUI:show(nLevelWinCoin, nPlayerCoin, nRatio)
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
    self.btn.interactable = true
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

    self.goRatio:SetActive(nRatio > 0)
    if nRatio > 0 then
        self.textRatio.text = nRatio.."%"
    end

    self.popController:show(nil , function()
        ActivityAudioHandler:PlaySound("rainbow_level_cheer")
        GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    end, true)
end

function LevelPrizeSplashUI:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    self.btn.interactable = false
    ActivityAudioHandler:PlaySound("rainbow_closeWindow")
    CoinFly:fly2(self.textWinCoin.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10, true, self.nPlayerCoin)
    local fDelayTime = 1.5 + 0.12 * 10
    LeanTween.delayedCall(fDelayTime, function()
        ViewScaleAni:Hide(self.transform.gameObject)
    end)
end

function LevelPrizeSplashUI:Update(dt)
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

function LevelPrizeSplashUI:skip()
    if not self.bCanSkipFlag then
        return
    end
    self.bCanSkipFlag = false
    self.bCanHideFlag = true
    self.goSkip:SetActive(false)
    self.goCollect:SetActive(true)
    self.slotsNumberWinCoins:End(self.fMoneyCount)
end

function LevelPrizeSplashUI:OnClick()
    if self.bCanSkipFlag then
        self:skip()
    elseif self.bCanHideFlag then
        self:hide()
    end
end

return LevelPrizeSplashUI
