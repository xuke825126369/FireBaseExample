RocketFortuneGiftAddCoinsPop = {}
RocketFortuneGiftAddCoinsPop.m_btnCollect = nil
RocketFortuneGiftAddCoinsPop.m_rewardText = nil

function RocketFortuneGiftAddCoinsPop:Show(parentTransform)
    if self.transform.gameObject == nil then
        local strPath = "GiftAddCoinsPop"
        local prefabObj = AssetBundleHandler:LoadActivityAsset(strPath)
        self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
        self.transform = self.transform.gameObject.transform
        local trCollect = self.transform:FindDeepChild("CollectBtn")
        local btnCollect = trCollect:GetComponent(typeof(UnityUI.Button))
        btnCollect.onClick:AddListener(function()
            self:onKeepBtnClick()
        end)
        DelegateCache:addOnClickButton(btnCollect)
        self.m_btnCollect = btnCollect
        self.popController = PopController:new(self.transform.gameObject)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    end

    self.m_btnCollect.interactable = true
    self.m_rewardText = self.transform:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
    if RocketFortuneLevelManager.strGift == "gift1" then
        self.m_rewardText.text = MoneyFormatHelper.numWithCommas(RocketFortuneDataHandler:getBaseTB())
    elseif RocketFortuneLevelManager.strGift == "gift2" then
        self.m_rewardText.text = MoneyFormatHelper.numWithCommas(RocketFortuneDataHandler:getBaseTB() * 2)
    end
    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function RocketFortuneGiftAddCoinsPop:onKeepBtnClick()
    self.m_btnCollect.interactable = false
    local ftime = 2.5
    local coinPos = self.m_rewardText.transform.position
    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12)
    LeanTween.delayedCall(ftime, function()
        self.popController:hide(false, function()
            RocketFortuneMainUIPop.Wheel:Show()
        end)
    end)
end

function RocketFortuneGiftAddCoinsPop:OnDestroy()
    
end