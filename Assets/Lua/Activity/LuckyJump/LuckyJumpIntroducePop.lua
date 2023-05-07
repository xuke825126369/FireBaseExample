LuckyJumpIntroducePop = {} --包括两个界面，一个是转盘，一个是活动游戏界面

function LuckyJumpIntroducePop:Show()
    if self.transform.gameObject == nil then
        local path = "Assets/LuckyJump/LuckyJumpIntroducePop.prefab"
        local prefab = Util.getLuckyJumpPrefab(path)
        self.transform.gameObject = Unity.Object.Instantiate(prefab)
        self.transform = self.transform.gameObject.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        -- self.popController = PopController:new(self.transform.gameObject)
        local btnClose = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
        btnClose.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
    end
    -- ViewScaleAni:Show(self.transform.gameObject)
    self.transform.gameObject:SetActive(true)
    self.transform:SetAsLastSibling()
end

function LuckyJumpIntroducePop:onCloseBtnClicked()
    --TODO 显示退出动画

    LeanTween.delayedCall(0.5,function()
        self.transform.gameObject:SetActive(false)
    end)
end