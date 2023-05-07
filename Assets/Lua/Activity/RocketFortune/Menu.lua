local Menu = {} --包括两个界面，一个是转盘，一个是活动游戏界面

Menu.transform.gameObject = nil
Menu.transform = nil
Menu.m_scrollView = nil

Menu.COMPLETEDALLCOINS = 36000000000

local yield_return = (require 'cs_coroutine').yield_return

function Menu:Show(parentTransform)
    if self.transform.gameObject == nil then
        local prefabObj = AssetBundleHandler:LoadActivityAsset("Menu")
        self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
        self.transform = self.transform.gameObject.transform
        self.m_container = self.transform:FindDeepChild("Container")
        self.popController = PopController:new(self.transform.gameObject)

        local closeBtn = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(closeBtn)
        closeBtn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        self.m_scrollView = self.transform:FindDeepChild("ChoiceContainer"):GetComponent(typeof(UnityUI.ScrollRect))
        local introduceBtn = self.transform:FindDeepChild("IntroduceBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(introduceBtn)
        introduceBtn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onIntroduceBtnClicked()
        end)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.leftTimeText = self.transform:FindDeepChild("LeftTime"):GetComponent(typeof(TextMeshProUGUI))

        local tableGoLevel = LuaHelper.GetTableFindChild(self.transform, RocketFortuneConfig.N_MAX_LEVEL, "Level")
        local generator = require("Lua.Activity.RocketFortune.Menu_LevelUI")
        self.tableLevelUI = {}
        for i = 1, RocketFortuneConfig.N_MAX_LEVEL do
            self.tableLevelUI[i] = generator:new(tableGoLevel[i], i, function()
                self:onPlayBtnClick()
            end)
        end
        self.textReward = self.transform:FindDeepChild("TopUI/JinBiKuang/Reward"):GetComponent(typeof(UnityUI.Text))
    end

    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    self.m_container.localScale = Unity.Vector3.one
    self.m_scrollView.horizontalNormalizedPosition = 0
    if RocketFortuneDataHandler.data.nLevel == 1 then
        self.m_scrollView.horizontalNormalizedPosition = 0
    elseif RocketFortuneDataHandler.data.nLevel == RocketFortuneConfig.N_MAX_LEVEL + 1 then
        self.m_scrollView.horizontalNormalizedPosition = 0
    else
        self.m_scrollView.horizontalNormalizedPosition = RocketFortuneDataHandler.data.nLevel / RocketFortuneConfig.N_MAX_LEVEL
    end
    self:initContent()
    ViewScaleAni:Show(self.transform.gameObject)
    self:checkIsAllWin()

    EventHandler:AddListener(self, "onActiveTimeChanged")
    self:onActiveTimeChanged(ActiveManager.remainingTime)
end

function Menu:checkIsAllWin()
    if RocketFortuneDataHandler.data.nLevel > RocketFortuneConfig.N_MAX_LEVEL then
        if not RocketFortuneDataHandler.data.bIsGetCompletedGift then
            PlayerHandler:AddCoin(self.COMPLETEDALLCOINS)
            RocketFortuneDataHandler.data.bIsGetCompletedGift = true
            RocketFortuneDataHandler:writeFile()
            RocketFortuneUnloadedUI:hide() --全部完成隐藏入口
            RocketFortuneCompletedAllWinPop:Show()
        end
    end
end

function Menu:onCloseBtnClicked()
    self:hide()
    RocketFortuneMainUIPop:hide()
end

function Menu:onIntroduceBtnClicked()
    RocketFortuneIntroducePop:Show()
end

function Menu:initContent()
    self.COMPLETEDALLCOINS = RocketFortuneLevelManager:getLevelReward(RocketFortuneConfig.N_MAX_LEVEL + 1)
    self.textReward.text = MoneyFormatHelper.numWithCommas(self.COMPLETEDALLCOINS)
    for i = 1, RocketFortuneConfig.N_MAX_LEVEL do
        local nCoin = RocketFortuneLevelManager:getLevelReward(i)
        local nCardPackType = RocketFortuneConfig.LevelRewardCardPack[i].nPackType
        local nCardPackCount = RocketFortuneConfig.LevelRewardCardPack[i].nCount
        self.tableLevelUI[i]:set(RocketFortuneDataHandler.data.nLevel, nCoin, nCardPackType, nCardPackCount, RocketFortuneDataHandler.data.nAction)
    end
end

function Menu:hide()
    -- if not self.bCanHide then return end
    -- self.bCanHide = false
    ViewScaleAni:Hide(self.transform.gameObject)
    --ActivityHelper:SetTrigger(self.transform.gameObject, "Hide")
    NotificationHandler:removeObserver(self)
end

function Menu:onPlayBtnClick()
    RocketFortuneMainUIPop:Show()
    self:hide()
end

function Menu:OnDestroy()
    
end

function Menu:onActiveTimeChanged(time)
    self.leftTimeText.text = ActivityHelper:FormatTime(time)
end

return Menu