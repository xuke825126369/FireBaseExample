RocketFortuneMainUIPop = {} --包括两个界面，一个是转盘，一个是活动游戏界面
RocketFortuneMainUIPop.m_goContainer = nil
RocketFortuneMainUIPop.m_btnClose = nil
--RocketFortuneMainUIPop.m_goEndAnim = nil

RocketFortuneMainUIPop.m_textReward = nil
RocketFortuneMainUIPop.m_trMoreMultiple = nil
RocketFortuneMainUIPop.m_btnBackToChoicePop = nil
RocketFortuneMainUIPop.m_textMultiple = nil

RocketFortuneMainUIPop.m_bIsGenerateLevel = false

local isSimulation = false





local GiftProb = {
    -- 1  2 加金币
    -- 3  giftType_AddOneSpinCount
    -- 4  5 giftType_AddRewardMultiple
    -- 6 对应的 GiftType.giftType_FlyToLastOne
    index = {1, 2, 3, 4, 5, 6}, -- 随机数 1对应的GiftConfig.gift1
    probs = {15, 20, 60, 15, 10, 5} -- 随机到每个礼物的概率是不同（待定）
}

function RocketFortuneMainUIPop:Show()
    if ActivityBundleHandler.m_bundleInfo.downloadStatus ~= DownloadStatus.Downloaded then
        return
    end
    if GameConfig.PLATFORM_EDITOR then
        self:Show()
        return
    end
    if self.asynLoadCo == nil then
        self.asynLoadCo = StartCoroutine(function()
            Scene.loadingAssetBundle:SetActive(true)
            Debug.Log("-------"..ActiveManager.activeType.." begin Loaded---------")
            ActivityBundleHandler:asynLoadAssetBundle()
            local isReady = ActiveManager.unloadedUI.m_bAssetReady
            while (not isReady) do
                yield_return(0)
            end
            Scene.loadingAssetBundle:SetActive(false)
            self:Show()
            self.asynLoadCo = nil
        end)
    end
end

function RocketFortuneMainUIPop:Show()
    if self.transform.gameObject == nil then
        self.m_bInitFlag = false
    else
        if self.transform.gameObject:Equals(nil) then
            self.m_bInitFlag = false
        end
    end
    if not self.m_bInitFlag then
        self:Init()
    end
    
    if not self.m_bIsGenerateLevel then
        local isGenerated = RocketFortuneLevelManager:generateActiveLevel(self.m_goContainer.transform) --生成游戏界面
        self.m_trTopUI:SetAsLastSibling()
        if not isGenerated then
            self.transform.gameObject:SetActive(false)
            SlotsGameLua.m_bReelPauseFlag = false
            if RocketFortuneUnloadedUI.transform ~= nil then
                Unity.Object.Destroy(RocketFortuneUnloadedUI.transform.gameObject)
            end
            --TODO 全部通关后，显示选择页面（该流程有待确定）
            RocketFortuneMainUIPop.Menu:Show()
            return
        else
            self.m_bIsGenerateLevel = true
        end
    else
        RocketFortuneLevelManager:initPlayerLocation()
    end

    ActivityHelper:postUIEvent(self, true)

    --self.m_goEndAnim:SetActive(false)
    self.Wheel:Show()
    self:refreshRewardContent()

    self.transform:SetParent(LobbyScene.popCanvas, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function RocketFortuneMainUIPop:Init()
    self.Menu = require("Lua.Activity.RocketFortune.Menu")
    self.Wheel = require("Lua.Activity.RocketFortune.Wheel")
    self.Shop = require("Lua.Activity.RocketFortune.Shop")
    self.tableUI = {
        self.Menu,
        self.Wheel,
        self.Shop,
        self
    }

    self.m_bInitFlag = true
    local prefabObj = AssetBundleHandler:LoadActivityAsset("RocketFortuneMainUIPop")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.m_goContainer = self.transform.gameObject.transform:FindDeepChild("Container")

   LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject)

    self.m_trTopUI = self.transform:FindDeepChild("TopUI")
    if GameConfig.IS_GREATER_169 then
        self.m_trTopUI.localScale = Unity.Vector3.one * 0.9
    end
    self.m_textReward = self.transform:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
    self.m_trMoreMultiple = self.transform:FindDeepChild("More")
    self.m_btnBackToChoicePop = self.transform:FindDeepChild("BackToChoiceBtn"):GetComponent(typeof(UnityUI.Button))
    self.m_textMultiple = self.m_trMoreMultiple:FindDeepChild("MultipleText"):GetComponent(typeof(UnityUI.Text))
    
    --self.m_goEndAnim = self.transform:FindDeepChild("LunPan_LZ").gameObject

    self.m_btnClose = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
    self.m_btnClose.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:hide()
    end)
    DelegateCache:addOnClickButton(self.m_btnClose)
    ActivityHelper:addUIEventObserver(self, function(b)
        self.m_btnClose.interactable = b
    end)

    self.m_btnBackToChoicePop.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:onBackToChoicePopBtnClick()
    end)
    DelegateCache:addOnClickButton(self.m_btnBackToChoicePop)
    ActivityHelper:addUIEventObserver(self, function(b)
        self.m_btnBackToChoicePop.interactable = b
    end)

    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

    self.goPlayer = Unity.Object.Instantiate(AssetBundleHandler:LoadActivityAsset("Player"), self.transform)

    local btn = self.transform:FindDeepChild("Container/TopUI/btnShop"):GetComponent(typeof(UnityUI.Button))
    btn.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self.Shop:Show()
        Debug.Log("shopbtn")
    end)
    DelegateCache:addOnClickButton(btn)
    ActivityHelper:addUIEventObserver(self, function(b)
        btn.interactable = b
    end)
    self.btnShop = btn
end

function RocketFortuneMainUIPop:checkIsWin(nID)
    if nID >= RocketFortuneLevelManager.m_levelInfo.N_MAX_GRID_COUNT then
        RocketFortuneDataHandler.data.nLevel = RocketFortuneDataHandler.data.nLevel + 1
        RocketFortuneDataHandler.data.nLevelProgress = 1
        RocketFortuneDataHandler.data.nPlayerLevel = PlayerHandler.nLevel
        RocketFortuneDataHandler:writeFile()

        --TODO 添加获胜奖励
        PlayerHandler:AddCoin(RocketFortuneLevelManager.nRewardCoins)

        return true
    end
    RocketFortuneDataHandler.data.nLevelProgress = nID
    RocketFortuneDataHandler:writeFile()
    return false
end

function RocketFortuneMainUIPop:checkIsSpecialItem(nID)
    for k,v in pairs(RocketFortuneLevelManager.m_levelInfo.TABLE_SPECIAL_GRID) do
        if v.nID == nID then
            -- 检测当前格子为特殊格子
            if v.enumType == RocketFortuneItemType.enumItem_Gift then
                -- 礼物数据的逻辑在这里写
                local random = self:getGiftRandomIndex()
                local strGift = "gift"..random
                RocketFortuneLevelManager.strGift = strGift
                local giftInfo = GiftConfig[strGift]
                if giftInfo.giftType == GiftType.giftType_Add1000000Coins then

                    -- 添加1000000coins奖励
                    local reward = RocketFortuneDataHandler:getBaseTB()
                    PlayerHandler:AddCoin(reward)

                elseif giftInfo.giftType == GiftType.giftType_Add2000000Coins then

                    -- 添加2000000coins奖励
                    local reward = RocketFortuneDataHandler:getBaseTB() * 2
                    PlayerHandler:AddCoin(reward)

                elseif giftInfo.giftType == GiftType.giftType_AddOneSpinCount then

                    -- 添加1个spinCount奖励
                    --RocketFortuneDataHandler:addSpinCount(giftInfo.gift)
                    ActivityHelper:AddMsgCountData("nAction", giftInfo.gift)

                elseif giftInfo.giftType == GiftType.giftType_AddRewardMultiple then

                    RocketFortuneDataHandler:addMultiple(giftInfo.gift)

                elseif giftInfo.giftType == GiftType.giftType_FlyToLastOne then

                    RocketFortuneDataHandler.data.nLevelProgress = RocketFortuneLevelManager.m_levelInfo.N_MAX_GRID_COUNT
                    local isWin = self:checkIsWin(RocketFortuneDataHandler.data.nLevelProgress)
                end
            elseif v.enumType == RocketFortuneItemType.enumItem_Rocket then
                RocketFortuneDataHandler.data.nLevelProgress = v.nTarget
                RocketFortuneDataHandler:writeFile()
                RocketFortuneLevelManager.nFlyTarget = v.nTarget
                self:checkIsSpecialItem(v.nTarget)

            elseif v.enumType == RocketFortuneItemType.enumItem_Slide then
                -- TODO 检测是否有消除梯子功能
                if not RocketFortuneDataHandler:checkInRemoveSliderTime() then
                    RocketFortuneDataHandler.data.nLevelProgress = v.nTarget
                    RocketFortuneDataHandler:writeFile()
                    RocketFortuneLevelManager.nFlyTarget = v.nTarget
                    self:checkIsSpecialItem(v.nTarget)
                end
            end
            return
        end
    end
end

function RocketFortuneMainUIPop:getGiftRandomIndex()
    local nRandomIndex = LuaHelper.GetIndexByRate(GiftProb.probs)
    local nStep = GiftProb.index[nRandomIndex]
    return nRandomIndex
end

function RocketFortuneMainUIPop:refreshRewardContent()
    local multiple = RocketFortuneDataHandler.data.fRewardMultiple
    self.m_textReward.text = MoneyFormatHelper.numWithCommas(RocketFortuneLevelManager.nRewardCoins)
    if multiple > 1 then
        self.m_trMoreMultiple.gameObject:SetActive(true)
        local mul = math.ceil((multiple - 1)*100)
        self.m_textMultiple.text = string.format("%d",mul)
    else
        self.m_trMoreMultiple.gameObject:SetActive(false)
    end
end

function RocketFortuneMainUIPop:onBackToChoicePopBtnClick()
    RocketFortuneMainUIPop.Menu:Show()
    self.popController:hide(true)
end

function RocketFortuneMainUIPop:OnDestroy()
    
end

function RocketFortuneMainUIPop:hide()
    EventHandler:Brocast("onActiveHide")
    ViewScaleAni:Hide(self.transform.gameObject)
    self.Wheel:hide()
    NotificationHandler:removeObserver(self)
end

