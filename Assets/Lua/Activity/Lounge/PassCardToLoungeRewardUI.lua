PassCardToLoungeRewardUI = {}

function PassCardToLoungeRewardUI:Show(nDayPass, nPrizeCoin)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local prefabObj = AssetBundleHandler:LoadGoldenLoungeAsset("LoungeDayPassUI/PassCardToLoungeRewardUI.prefab")
        local go = Unity.Object.Instantiate(prefabObj)
        self.transform = go.transform

        local btnCollect = self.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnCollect)
        btnCollect.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnBtnCollectClicked(btnCollect)
        end)

        self.m_TextNumDayPass = self.transform:FindDeepChild("TextNumDayPass"):GetComponent(typeof(UnityUI.Text))
        self.m_TextLoungeRewardCoins = self.transform:FindDeepChild("TextLoungeRewardCoins"):GetComponent(typeof(UnityUI.Text))
        self.m_posRewardCoin = self.transform:FindDeepChild("BtnCollect").position

        self.m_trContent = self.transform:FindDeepChild("Content")
    end

    self.transform:SetParent(LobbyScene.popCanvas, false)
    ViewAlphaAni:Show(self.transform.gameObject)

    self.m_TextNumDayPass.text = tostring(nDayPass)

    -- 兑换的金币
    self.m_nRewardCoins = nPrizeCoin
    self.m_TextLoungeRewardCoins.text = MoneyFormatHelper.numWithCommas(nPrizeCoin)
    self.transform:SetAsLastSibling()
    
end

function PassCardToLoungeRewardUI:Hide()
    ViewAlphaAni:Hide(self.transform.gameObject)
end

function PassCardToLoungeRewardUI:OnBtnCollectClicked(btnCollect)
    btnCollect.interactable = false
    LeanTween.delayedCall(3.9, function()
        btnCollect.interactable = true
    end)
    
    CoinFly:fly(self.m_posRewardCoin, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12, true)
    LeanTween.delayedCall(3.0, function()
        self:Hide()
    end)

end