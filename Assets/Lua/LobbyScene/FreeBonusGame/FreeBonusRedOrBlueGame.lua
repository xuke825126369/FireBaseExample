FreeBonusRedOrBlueGame = {}

local FreeBonusType = {
    red = 1,
    blue = 2
}

function FreeBonusRedOrBlueGame:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local bundleName = "Lobby"
    local assetPath = "Assets/ResourceABs/Lobby/FreeBonusGameUI/FreeBonusRedOrBlueGame.prefab"
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
    local goPanel = Unity.Object.Instantiate(goPrefab)
    
    local goParent = LobbyScene.popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.baseRewardText = self.transform:FindDeepChild("BaseBonusRewardText"):GetComponent(typeof(UnityUI.Text))
    self.aniMulItem = self.transform:FindDeepChild("MultiplierItem"):GetComponent(typeof(Unity.Animator))
    self.mulText = self.transform:FindDeepChild("MulText"):GetComponent(typeof(TextMeshProUGUI))
    self.goRedContainer = self.transform:FindDeepChild("RedContainer").gameObject
    self.goBlueContainer = self.transform:FindDeepChild("BlueContainer").gameObject
    self.goRewardContainer = self.transform:FindDeepChild("RewardContainer").gameObject
end

function FreeBonusRedOrBlueGame:Show(nType)
    self:Init()
    self.transform:SetAsLastSibling()
    self.goRewardContainer.transform.localScale = Unity.Vector3.zero
    local nMul, fProgress, nIndex = FreeBonusMultiplier:getMultiplier()
    self.mulText.text = "x"..nMul
    self.goRedContainer:SetActive(false)
    self.goBlueContainer:SetActive(false)
    self.aniMulItem.gameObject:SetActive(nMul ~= 1)
    self.baseRewardText.gameObject:SetActive(false)
    self.netTime = TimeHandler:GetServerTimeStamp()
    
    local coins = 0
    local go = nil
    if nType == FreeBonusType.red then
        coins = FreeBonusGameHandler:getRedBonusBaseBonus()
        FreeBonusGameHandler:SetRedBonusNetTime(self.netTime)
        go = self.goRedContainer
    else
        coins = FreeBonusGameHandler:getBlueBonusBaseBonus()
        FreeBonusGameHandler:SetBlueBonusNetTime(self.netTime)
        go = self.goBlueContainer
    end
    go:SetActive(true)

    local nMul, fProgress, nIndex = FreeBonusMultiplier:getMultiplier()
    local finalCoin = coins * nMul
    local currentVipMultiply = VipHandler:GetVipCoefInfo()
    local fLoungeCoef = 1.0
    if  LoungeHandler:isLoungeMember() then
        fLoungeCoef = 1.5
    end
    
    local nTotalBonus = (finalCoin * fLoungeCoef) * currentVipMultiply
    PlayerHandler:AddCoin(nTotalBonus)

    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self:GetRandomCoins(nType, go, coins, finalCoin)
    end)
    
end

function FreeBonusRedOrBlueGame:GetRandomCoins(bonusType, go, coins, finalCoin)
    local ani = go:GetComponent(typeof(Unity.Animator))
    ani:SetTrigger(Unity.Animator.StringToHash("ShowEffect"))
    
    self.baseRewardText.text = MoneyFormatHelper.numWithCommas(coins)
    self.baseRewardText.gameObject:SetActive(true)
    local currentVipMultiply = VipHandler:GetVipCoefInfo()

    LeanTween.scale(self.goRewardContainer, Unity.Vector3.one, 0.5):setDelay(1.2):setEase(LeanTweenType.easeOutBack)
    LeanTween.delayedCall(1.2, function()
        GlobalAudioHandler:PlaySound("chestOpen")
    end)

    if self.aniMulItem.gameObject.activeSelf then
        LeanTween.delayedCall(1.7, function()
            self.aniMulItem:Play("MultiplierItemHitAni")
        end)
    end

    LeanTween.delayedCall(2.5, function()
        LeanTween.value(coins, finalCoin, 0.5):setOnUpdate(function(value)
            self.baseRewardText.text = MoneyFormatHelper.numWithCommas(value)
        end)
    end)

    LeanTween.delayedCall(3, function()
        FreeBonusSettleFrame:Show(finalCoin, currentVipMultiply, function()
            ViewScaleAni:Hide(self.transform.gameObject)
        end)
    end)

end
