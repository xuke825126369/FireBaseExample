LuckyJumpEndPop = {} --包括两个界面，一个是转盘，一个是活动游戏界面

function LuckyJumpEndPop:Show()
    if self.transform.gameObject == nil then
        local path = "Assets/LuckyJump/LuckyJumpEndPop.prefab"
        local prefab = Util.getLuckyJumpPrefab(path)
        self.transform.gameObject = Unity.Object.Instantiate(prefab)
        self.transform = self.transform.gameObject.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.m_btnCollect = self.transform:FindDeepChild("CollectBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_btnCollect.onClick:AddListener(function()
            self:onCollectBtnClicked()
        end)
        self.m_txtCoinsWin = self.transform:FindDeepChild("WinCoins"):GetComponent(typeof(UnityUI.Text))
    end
    local level = "Level"..(LuckyJumpDataHandler.data.nLevel-1)
    self.m_txtCoinsWin.text = MoneyFormatHelper.numWithCommas(LuckyJumpDataHandler.m_mapPrize[level])
    self.transform.gameObject:SetActive(true)
    self.transform:SetAsLastSibling()
end

function LuckyJumpEndPop:onCollectBtnClicked()
    local coinPos = self.m_txtCoinsWin.transform.position
    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 6)
    --TODO 显示退出动画

    LeanTween.delayedCall(0.5, function()
        self.transform.gameObject:SetActive(false)
        if LuckyJumpDataHandler.data.nLevel < #LuckyJumpConfig then
            LuckyJumpManager:initGameItem()
        end
    end)
end
