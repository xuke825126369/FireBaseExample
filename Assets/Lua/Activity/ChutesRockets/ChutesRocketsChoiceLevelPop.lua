

ChutesRocketsChoiceLevelPop = {} --包括两个界面，一个是转盘，一个是活动游戏界面
ChutesRocketsChoiceLevelPop.m_scrollView = nil

ChutesRocketsChoiceLevelPop.COMPLETEDALLCOINS = 36000000000

local yield_return = (require 'cs_coroutine').yield_return

function ChutesRocketsChoiceLevelPop:Show(parentTransform)
    if self.transform.gameObject == nil then
        local strPath = "Assets/ActiveNeedLoad/ChutesRockets/ChutesRocketsChoicePop.prefab"
        local prefabObj = Util.getChutesRocketsPrefab(strPath)
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
        --self:updateTime()
        self.leftTimeText = self.transform:FindDeepChild("LeftTime"):GetComponent(typeof(TextMeshProUGUI))
    end

    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    self.m_container.localScale = Unity.Vector3.one
    self.m_scrollView.horizontalNormalizedPosition = 0
    if ChutesRocketsDataHandler.data.nLevel == 1 then
        self.m_scrollView.horizontalNormalizedPosition = 0
    elseif ChutesRocketsDataHandler.data.nLevel == 7 then
        self.m_scrollView.horizontalNormalizedPosition = 0
    else
        self.m_scrollView.horizontalNormalizedPosition = ChutesRocketsDataHandler.data.nLevel/6
    end
    self:initContent()
    self.popController:show(function()
        -- if ChutesRocketsDataHandler.data.nLevel <= 3 then
        --     self.m_scrollView.horizontalNormalizedPosition = 0
        -- elseif ChutesRocketsDataHandler.data.nLevel > 3 then
        --     self.m_scrollView.horizontalNormalizedPosition = 1
        -- end
    end)
    self:checkIsAllWin()

    EventHandler:AddListener(self, "onActiveTimeChanged")
    self:onActiveTimeChanged(ActiveManager.remainingTime)
end

function ChutesRocketsChoiceLevelPop:checkIsAllWin()
    if ChutesRocketsDataHandler.data.nLevel > 6 then
        if not ChutesRocketsDataHandler.data.bIsGetCompletedGift then
            PlayerHandler:AddCoin(self.COMPLETEDALLCOINS)
            ChutesRocketsDataHandler.data.bIsGetCompletedGift = true
            ChutesRocketsDataHandler:writeFile()
            ChutesRocketsUnloadedUI:hide() --全部完成隐藏入口
            ChutesRocketsCompletedAllWinPop:Show()
        end
    end
end

function ChutesRocketsChoiceLevelPop:onCloseBtnClicked()
    GlobalAudioHandler:StopChutesRocketsMusic()
    --TODO 关闭音效
    self.popController:hide(true, function()
        NotificationHandler:removeObserver(self)
    end)
    self.m_bPortraitFlag = false
    if ThemeLoader.themeKey ~= nil then
        self.m_bPortraitFlag = GameLevelUtil:isPortraitLevel()
    end
    if self.m_bPortraitFlag then
        Debug.Log("切屏")
        Scene:SwitchScreenOp(false)
        SceneLoading:ShowBlackBgInThemesTransitionScreen(false)
    end
end

function ChutesRocketsChoiceLevelPop:onIntroduceBtnClicked()
    ChutesRocketsIntroducePop:Show()
end

function ChutesRocketsChoiceLevelPop:initContent()
    self.COMPLETEDALLCOINS = ChutesRocketsLevelManager:getLevelReward(7)

    local currentLevel = ChutesRocketsDataHandler.data.nLevel
    
    local rewardText = self.transform:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
    rewardText.text = MoneyFormatHelper.numWithCommas(self.COMPLETEDALLCOINS).." COINS +"

    for i=1, 6 do
        if i < currentLevel then
            self.transform:FindDeepChild("GameBoatd"..i.."/WanCheng").gameObject:SetActive(true)
            self.transform:FindDeepChild("GameBoatd"..i.."/KaiQi").gameObject:SetActive(false)
            self.transform:FindDeepChild("GameBoatd"..i.."/KaiQi1").gameObject:SetActive(false)
            self.transform:FindDeepChild("GameBoatd"..i.."/Hui").gameObject:SetActive(false)
        elseif i == currentLevel then
            self.transform:FindDeepChild("GameBoatd"..i.."/WanCheng").gameObject:SetActive(false)
            self.transform:FindDeepChild("GameBoatd"..i.."/KaiQi").gameObject:SetActive(false)
            self.transform:FindDeepChild("GameBoatd"..i.."/KaiQi1").gameObject:SetActive(true)
            
            local rewardText = self.transform:FindDeepChild("GameBoatd"..i.."/KaiQi1/JiangLiJinBi/Reward"):GetComponent(typeof(UnityUI.Text))
            local levelName = "ChutesRocketsLevel"..ChutesRocketsDataHandler.data.nLevel
            local levelInfo = ChutesRocketsLevelConfig[levelName]
            local nReward = ChutesRocketsLevelManager:getLevelReward()
            local strReward = MoneyFormatHelper.numWithCommas(nReward)
            rewardText.text = strReward.." COINS"
            local spinCount = self.transform:FindDeepChild("GameBoatd"..i.."/KaiQi1/SpinCiShu/SpinCount"):GetComponent(typeof(TextMeshProUGUI))
            spinCount.text = "SPIN LEFT:"..ChutesRocketsDataHandler.data.nAction
            local spinBtns = self.transform:FindDeepChild("GameBoatd"..i.."/KaiQi1/PlayBtn"):GetComponent(typeof(UnityUI.Button))
            spinBtns.onClick:AddListener(function()
                GlobalAudioHandler:PlayBtnSound()
                self:onPlayBtnClick()
            end)
            DelegateCache:addOnClickButton(closeBtn)
            self.transform:FindDeepChild("GameBoatd"..i.."/Hui").gameObject:SetActive(false)
        else
            self.transform:FindDeepChild("GameBoatd"..i.."/WanCheng").gameObject:SetActive(false)
            self.transform:FindDeepChild("GameBoatd"..i.."/KaiQi").gameObject:SetActive(false)
            self.transform:FindDeepChild("GameBoatd"..i.."/KaiQi1").gameObject:SetActive(true)

            local rewardText = self.transform:FindDeepChild("GameBoatd"..i.."/KaiQi1/JiangLiJinBi/Reward"):GetComponent(typeof(UnityUI.Text))
            local levelName = "ChutesRocketsLevel"..i
            local levelInfo = ChutesRocketsLevelConfig[levelName]
            local nReward = ChutesRocketsLevelManager:getLevelReward(i)
            local strReward = MoneyFormatHelper.numWithCommas(nReward)
            rewardText.text = strReward.." COINS"

            local spinCount = self.transform:FindDeepChild("GameBoatd"..i.."/KaiQi1/SpinCiShu/SpinCount"):GetComponent(typeof(TextMeshProUGUI))
            spinCount.text = ""
            self.transform:FindDeepChild("GameBoatd"..i.."/Hui").gameObject:SetActive(true)
        end
        
    end
end

function ChutesRocketsChoiceLevelPop:onPlayBtnClick()
    ChutesRocketsMainUIPop:Show()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function ChutesRocketsChoiceLevelPop:OnDestroy()
    Debug.Log("ChutesRocketsChoiceLevelPop Destroy")
end

function ChutesRocketsChoiceLevelPop:onActiveTimeChanged(time)
    self.leftTimeText.text = ActivityHelper:FormatTime(time)
end