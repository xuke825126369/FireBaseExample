OneMedalExpiredUI = {}

function OneMedalExpiredUI:Show(nCoinReward)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local strPath = "LoungeUI/OneMedalExpiredUI.prefab"
        local prefabObj = AssetBundleHandler:LoadGoldenLoungeAsset(strPath)
        local go = Unity.Object.Instantiate(prefabObj)

        self.transform = go.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)

        self.btnAndGo = self.transform:FindDeepChild("BtnAndGo"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnAndGo)
        self.btnAndGo.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnBtnCheckGOClicked()
        end)

        local tr = self.transform:FindDeepChild("TextLoungeRewardCoins")
        self.m_TextLoungeRewardCoins = tr:GetComponent(typeof(UnityUI.Text))
    end

    ViewAlphaAni:Show(self.transform.gameObject)
    local strCoin = MoneyFormatHelper.numWithCommas(nCoinReward)
    self.m_TextLoungeRewardCoins.text = strCoin
    self.transform:SetAsLastSibling()

end

function OneMedalExpiredUI:Hide()
    ViewAlphaAni:Hide(self.transform.gameObject)
end

function OneMedalExpiredUI:OnBtnCheckGOClicked()
    LoungeHandler:SaveDb()
    local posStart = self.m_TextLoungeRewardCoins.transform.position
    CoinFly:fly(posStart, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12, true)
    LeanTween.delayedCall(2.0, function()
        self:Hide()
    end)
end
