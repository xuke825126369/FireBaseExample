LuckyJumpWinCollectPop = {} --包括两个界面，一个是转盘，一个是活动游戏界面

function LuckyJumpWinCollectPop:Show(downFun)
    if self.transform.gameObject == nil then
        local path = "Assets/LuckyJump/LuckyJumpWinCollectPop.prefab"
        local prefab = Util.getLuckyJumpPrefab(path)
        self.transform.gameObject = Unity.Object.Instantiate(prefab)
        self.transform = self.transform.gameObject.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.m_btnCollect = self.transform:FindDeepChild("CollectBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_txtCoinsWin = self.transform:FindDeepChild("WinCoins"):GetComponent(typeof(UnityUI.Text))
    end
    self.m_btnCollect.onClick:RemoveAllListeners()
    self.m_btnCollect.onClick:AddListener(function()
        self:onCollectBtnClicked(downFun)
    end)
    self.m_txtCoinsWin.text = MoneyFormatHelper.numWithCommas(LuckyJumpManager.m_nWinCoins)
    self.transform.gameObject:SetActive(true)
    self.transform:SetAsLastSibling()
end

function LuckyJumpWinCollectPop:onCollectBtnClicked(downFun)
    LuckyJumpManager.m_nWinCoins = 0
    LuckyJumpGamePop:refreshText()
    local coinPos = self.m_txtCoinsWin.transform.position
    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 6)

    LeanTween.delayedCall(0.5, function()
        self.transform.gameObject:SetActive(false)
        if downFun ~= nil then
            downFun()
        end
    end)
end
