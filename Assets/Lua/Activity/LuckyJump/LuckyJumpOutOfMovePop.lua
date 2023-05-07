LuckyJumpOutOfMovePop = {} --包括两个界面，一个是转盘，一个是活动游戏界面

function LuckyJumpOutOfMovePop:Show()
    if self.transform.gameObject == nil then
        local path = "Assets/LuckyJump/LuckyJumpOutOfMovePop.prefab"
        local prefab = Util.getLuckyJumpPrefab(path)
        self.transform.gameObject = Unity.Object.Instantiate(prefab)
        self.transform = self.transform.gameObject.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        local btnClose = self.transform:FindDeepChild("OKBtn"):GetComponent(typeof(UnityUI.Button))
        btnClose.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        self.m_txtMoveCount = self.transform:FindDeepChild("MoveCount"):GetComponent(typeof(TextMeshProUGUI))
    end
    self.m_txtMoveCount.text = LuckyJumpDataHandler.data.nMoveCount
    self.transform.gameObject:SetActive(true)
    self.transform:SetAsLastSibling()
end

function LuckyJumpOutOfMovePop:onCloseBtnClicked()
    --TODO 显示退出动画

    LeanTween.delayedCall(0.5,function()
        self.transform.gameObject:SetActive(false)
        if LuckyJumpManager.m_nWinCoins > 0 then
            LuckyJumpWinCollectPop:Show()
        end
    end)
end