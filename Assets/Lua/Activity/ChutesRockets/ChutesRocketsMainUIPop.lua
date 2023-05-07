

ChutesRocketsMainUIPop = {} --包括两个界面，一个是转盘，一个是活动游戏界面
ChutesRocketsMainUIPop.m_goContainer = nil
ChutesRocketsMainUIPop.m_trWheelUI = nil
ChutesRocketsMainUIPop.m_trWheel = nil
ChutesRocketsMainUIPop.m_textSpinCount = nil
ChutesRocketsMainUIPop.m_btnSpin = nil
ChutesRocketsMainUIPop.m_btnClose = nil
ChutesRocketsMainUIPop.m_goEndAnim = nil

ChutesRocketsMainUIPop.m_textReward = nil
ChutesRocketsMainUIPop.m_trMoreMultiple = nil
ChutesRocketsMainUIPop.m_btnBackToChoicePop = nil
ChutesRocketsMainUIPop.m_textMultiple = nil

ChutesRocketsMainUIPop.m_bIsGenerateLevel = false

local isSimulation = false



local WheelConfig = {
    steps = {1, 2, 3, 4, 5, 6}, -- 转轮格子(格子ID: 1 2 3 4 5 6)对应的移动步数 steps
    probs = {20, 30, 30, 20, 10, 10} -- 随机到每个格子的概率是不一样的
}

local GiftProb = {
    -- 1  2 加金币
    -- 3  giftType_AddOneSpinCount
    -- 4  5 giftType_AddRewardMultiple
    -- 6 对应的 GiftType.giftType_FlyToLastOne
    index = {1, 2, 3, 4, 5, 6}, -- 随机数 1对应的GiftConfig.gift1
    probs = {15, 20, 60, 15, 10, 5} -- 随机到每个礼物的概率是不同（待定）
}

function ChutesRocketsMainUIPop:Show(parentTransform)
    GlobalAudioHandler:PlayChutesRocketsMusic("map_music")
    --TODO 判断是否为竖屏
    self.m_bPortraitFlag = false
    if ThemeLoader.themeKey ~= nil then
        self.m_bPortraitFlag = GameLevelUtil:isPortraitLevel()
        SlotsGameLua.m_bReelPauseFlag = true
    end
    if self.m_bPortraitFlag then
        Debug.Log("切横屏")
        Scene:SwitchScreenOp(true) -- 变成横屏
        SceneLoading:ShowBlackBgInThemesTransitionScreen(true)
    end

    local co = StartCoroutine(function()
        while Unity.Screen.width <= Unity.Screen.height do
            yield_return(0)
        end
        self:Show(parentTransform)
    end)
end

function ChutesRocketsMainUIPop:Show(parentTransform)
    if self.transform.gameObject == nil then
        local strPath = "Assets/ActiveNeedLoad/ChutesRockets/ChutesRocketsMainUIPop.prefab"
        local prefabObj = Util.getChutesRocketsPrefab(strPath)
        self.transform.gameObject = Unity.Object.Instantiate(prefabObj)

        self.m_goContainer = self.transform.gameObject.transform:FindDeepChild("Container")
        self.transform = self.transform.gameObject.transform

        local strWheelPath = "Assets/ActiveNeedLoad/ChutesRockets/ChutesRocketsWheelUI.prefab"
        self.m_trWheelUI = Unity.Object.Instantiate(Util.getChutesRocketsPrefab(strWheelPath)).transform
        self.m_trWheelUI:SetParent(self.m_goContainer.transform)

        self.popController = PopController:new(self.transform.gameObject)

        -- self.m_goContainer = self.transform:FindDeepChild("Container")
        -- self.activeContainer = self.transform:FindDeepChild("ActiveBG")
        self.m_trWheel = self.m_trWheelUI:FindDeepChild("Wheel")
        self.m_textSpinCount = self.m_trWheelUI:FindDeepChild("SpinCount"):GetComponent(typeof(TextMeshProUGUI))

        self.m_trTopUI = self.transform:FindDeepChild("TopUI")
        self.m_textReward = self.transform:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
        self.m_trMoreMultiple = self.transform:FindDeepChild("More")
        self.m_btnBackToChoicePop = self.transform:FindDeepChild("BackToChoiceBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_textMultiple = self.m_trMoreMultiple:FindDeepChild("MultipleText"):GetComponent(typeof(TextMeshProUGUI))
        
        self.m_goEndAnim = self.transform:FindDeepChild("LunPan_LZ").gameObject

        self.m_btnSpin = self.m_trWheelUI:FindDeepChild("SpinBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_btnGetSpin = self.m_trWheelUI:FindDeepChild("GetSpinBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_btnClose = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))

        self.m_btnSpin.onClick:AddListener(function()
            self:onSpinBtnClicked()
        end)
        DelegateCache:addOnClickButton(self.m_btnSpin)
        self.m_btnGetSpin.onClick:AddListener(function()
            -- self:onCloseBtnClicked()
            GlobalAudioHandler:PlayBtnSound()
            BuyView:Show()
        end)
        self.m_btnClose.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        DelegateCache:addOnClickButton(self.m_btnClose)
        self.m_btnBackToChoicePop.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onBackToChoicePopBtnClick()
        end)
        DelegateCache:addOnClickButton(self.m_btnBackToChoicePop)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    end
    
    if not self.m_bIsGenerateLevel then
        local isGenerated = ChutesRocketsLevelManager:generateActiveLevel(self.m_goContainer.transform) --生成游戏界面
        self.m_trWheelUI:SetAsLastSibling()
        self.m_trTopUI:SetAsLastSibling()
        if not isGenerated then
            self.transform.gameObject:SetActive(false)
            SlotsGameLua.m_bReelPauseFlag = false
            if ChutesRocketsUnloadedUI.transform ~= nil then
                Unity.Object.Destroy(ChutesRocketsUnloadedUI.transform.gameObject)
            end
            --TODO 全部通关后，显示选择页面（该流程有待确定）
            ChutesRocketsChoiceLevelPop:Show()
            return
        else
            self.m_bIsGenerateLevel = true
        end
    else
        ChutesRocketsLevelManager:initPlayerLocation()
    end

    self.m_btnClose.gameObject:SetActive(true)

    self.m_goEndAnim:SetActive(false)
    self:showWheel(true)
    self:refreshRewardContent()

    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function ChutesRocketsMainUIPop:UpdateSpinCountUI()
    if ChutesRocketsDataHandler.data.nAction < 1 then
        self.m_btnSpin.interactable = false
        self.m_btnGetSpin.gameObject:SetActive(true)
    else
        self.m_btnSpin.interactable = true
        self.m_btnGetSpin.gameObject:SetActive(false)
    end
    self.m_textSpinCount.text = "SPINS LEFT: "..ChutesRocketsDataHandler.data.nAction
end

function ChutesRocketsMainUIPop:onSpinBtnClicked()
    -- print("点击之前"..ChutesRocketsDataHandler.data.nLevelProgress)

    --TODO 开启仿真,用一个开关控制
    if isSimulation then
        local param = {nSimCount = 10000, nLevelID = 3}
        self:simulationGame(param)
        return
    end
    
    if ChutesRocketsUnloadedUI.m_bIsMaxSpinCount then
        ChutesRocketsUnloadedUI.m_bIsMaxSpinCount = false
        ChutesRocketsDataHandler.data.fAddSpinCountProgress = 0
        ChutesRocketsDataHandler:writeFile()
    end
    GlobalAudioHandler:PlayChutesRocketsSound("click_spin")
    ChutesRocketsDataHandler:addSpinCount(-1)
    self.m_textSpinCount.text = "SPINS LEFT: " .. ChutesRocketsDataHandler.data.nAction
    ChutesRocketsUnloadedUI:refreshUI(false)

    self.m_btnClose.gameObject:SetActive(false)
    self.m_btnBackToChoicePop.interactable = false

    self.m_btnSpin.interactable = false
    local nWheelIndex = self:getWheelRandomIndex()
    
    -- 先更新数据
    local nStep = WheelConfig.steps[nWheelIndex]
    ChutesRocketsLevelManager.nCurrentTarget = ChutesRocketsDataHandler.data.nLevelProgress + nStep
    local isWin = self:checkIsWin(ChutesRocketsLevelManager.nCurrentTarget)
    if not isWin then
        self:checkIsSpecialItem(ChutesRocketsLevelManager.nCurrentTarget)
    end

    -- 再做动画
    local toDegree = -360 * 10 - 360 / 6 * (nWheelIndex-1)
    local lastDegree = 0
    LeanTween.value(0, toDegree, 2.0):setEase (LeanTweenType.easeInOutQuad):setOnUpdate(function(value)
        if self.transform.gameObject == nil then
            return
        end
        local index = math.floor((math.floor(value) % 360 + 18 ) / 36) + 1
        if(index ~= self.lastIndex) then
            self.lastIndex = index
            GlobalAudioHandler:PlayChutesRocketsSound("golden_wheel_tick")
        end
        local angularSpeed = math.abs(value - lastDegree) / Unity.Time.deltaTime
        local blurAlpha = angularSpeed >= 400 and 1 or angularSpeed / 400
        self.m_trWheel.rotation = Unity.Quaternion.Euler(0, 0, value)
        lastDegree = value
    end):setOnComplete(function()
        if self.transform.gameObject == nil then
            return
        end
        self.m_goEndAnim:SetActive(true)
        GlobalAudioHandler:PlayChutesRocketsSound("reel_stop")
        --，转盘旋转停止后隐藏转盘开始游戏跳动画面，游戏跳动结束
        LeanTween.delayedCall(self.transform.gameObject, 1.7, function()
            if self.transform.gameObject == nil then
                return
            end
            self.m_goEndAnim:SetActive(false)
            -- self.m_trWheelUI.gameObject:SetActive(false)
            local bg = self.m_trWheelUI:FindDeepChild("BG"):GetComponent(typeof(UnityUI.Image))
            LeanTween.alpha(bg.transform, 0, 0.5)
            local container = self.m_trWheelUI:FindDeepChild("Container"):GetComponent(typeof(Unity.CanvasGroup))
            LeanTween.value(1,0,0.5):setEase (LeanTweenType.easeInOutQuad):setOnUpdate(function(value)
                container.alpha = value
            end):setOnComplete(function()
                self.m_trWheelUI.gameObject:SetActive(false)
            end)
            ChutesRocketsLevelManager:beginPlayerToTarget()
        end)
        -- print("点击之后"..ChutesRocketsDataHandler.data.nLevelProgress)
    end)
end

function ChutesRocketsMainUIPop:checkIsWin(nID)
    if nID >= ChutesRocketsLevelManager.m_levelInfo.N_MAX_GRID_COUNT then
        ChutesRocketsDataHandler.data.nLevel = ChutesRocketsDataHandler.data.nLevel + 1
        ChutesRocketsDataHandler.data.nLevelProgress = 1
        ChutesRocketsDataHandler.data.nPlayerLevel = PlayerHandler.nLevel
        ChutesRocketsDataHandler:writeFile()

        --TODO 添加获胜奖励
        PlayerHandler:AddCoin(ChutesRocketsLevelManager.nRewardCoins)

        return true
    end
    ChutesRocketsDataHandler.data.nLevelProgress = nID
    ChutesRocketsDataHandler:writeFile()
    return false
end

function ChutesRocketsMainUIPop:checkIsSpecialItem(nID)
    for k,v in pairs(ChutesRocketsLevelManager.m_levelInfo.TABLE_SPECIAL_GRID) do
        if v.nID == nID then
            -- 检测当前格子为特殊格子
            if v.enumType == ChutesRocketsItemType.enumItem_Gift then
                -- 礼物数据的逻辑在这里写
                local random = self:getGiftRandomIndex()
                local strGift = "gift"..random
                ChutesRocketsLevelManager.strGift = strGift
                local giftInfo = GiftConfig[strGift]
                if giftInfo.giftType == GiftType.giftType_Add1000000Coins then

                    -- 添加1000000coins奖励
                    local reward = ChutesRocketsDataHandler:getBaseTB()
                    PlayerHandler:AddCoin(reward)

                elseif giftInfo.giftType == GiftType.giftType_Add2000000Coins then

                    -- 添加2000000coins奖励
                    local reward = ChutesRocketsDataHandler:getBaseTB() * 2
                    PlayerHandler:AddCoin(reward)

                elseif giftInfo.giftType == GiftType.giftType_AddOneSpinCount then

                    -- 添加1个spinCount奖励
                    ChutesRocketsDataHandler:addSpinCount(giftInfo.gift)

                elseif giftInfo.giftType == GiftType.giftType_AddRewardMultiple then

                    ChutesRocketsDataHandler:addMultiple(giftInfo.gift)

                elseif giftInfo.giftType == GiftType.giftType_FlyToLastOne then

                    ChutesRocketsDataHandler.data.nLevelProgress = ChutesRocketsLevelManager.m_levelInfo.N_MAX_GRID_COUNT
                    local isWin = self:checkIsWin(ChutesRocketsDataHandler.data.nLevelProgress)
                end
            elseif v.enumType == ChutesRocketsItemType.enumItem_Rocket then
                ChutesRocketsDataHandler.data.nLevelProgress = v.nTarget
                ChutesRocketsDataHandler:writeFile()
                ChutesRocketsLevelManager.nFlyTarget = v.nTarget
                self:checkIsSpecialItem(v.nTarget)

            elseif v.enumType == ChutesRocketsItemType.enumItem_Slide then
                -- TODO 检测是否有消除梯子功能
                if not ChutesRocketsDataHandler:checkInRemoveSliderTime() then
                    ChutesRocketsDataHandler.data.nLevelProgress = v.nTarget
                    ChutesRocketsDataHandler:writeFile()
                    ChutesRocketsLevelManager.nFlyTarget = v.nTarget
                    self:checkIsSpecialItem(v.nTarget)
                end
            end
            return
        end
    end
end

function ChutesRocketsMainUIPop:showWheel(bFlag)
    if not self.transform.gameObject then
        return
    end
    if ChutesRocketsDataHandler.data.nSuperSpinCount > 0 then
        -- TODO 
    end
    self.m_trWheelUI.gameObject:SetActive(true)
    local time = 0.5
    if bFlag then
        time = 0.01
    end
    -- player走完后，显示转盘继续
    self.m_btnClose.gameObject:SetActive(true)
    self.m_btnBackToChoicePop.interactable = true
    local bg = self.m_trWheelUI:FindDeepChild("BG"):GetComponent(typeof(UnityUI.Image))
    LeanTween.alpha(bg.transform, 0.8, time)
    local container = self.m_trWheelUI:FindDeepChild("Container"):GetComponent(typeof(Unity.CanvasGroup))
    LeanTween.value(0,1,time):setEase (LeanTweenType.easeInOutQuad):setOnUpdate(function(value)
        container.alpha = value
    end):setOnComplete(function()
        if ChutesRocketsDataHandler.data.nAction < 1 then
            self.m_btnSpin.interactable = false
            self.m_btnGetSpin.gameObject:SetActive(true)
        else
            self.m_btnSpin.interactable = true
            self.m_btnGetSpin.gameObject:SetActive(false)
        end
    end)
    self.m_textSpinCount.text = "SPINS LEFT: "..ChutesRocketsDataHandler.data.nAction
    self.m_trWheel.rotation = Unity.Quaternion.Euler(0, 0, 0)
end

function ChutesRocketsMainUIPop:onCloseBtnClicked()
    SlotsGameLua.m_bReelPauseFlag = false
    if not self.transform.gameObject then
        return
    end
    --TODO 关闭音效
    GlobalAudioHandler:StopChutesRocketsMusic()
    self.popController:hide(true)
    if self.m_bPortraitFlag then
        Debug.Log("切屏")
        Scene:SwitchScreenOp(false)
        self.m_bPortraitFlag = false
        SceneLoading:ShowBlackBgInThemesTransitionScreen(false)
    end
end

function ChutesRocketsMainUIPop:getWheelRandomIndex()
    -- 这里返回的是wheel格子ID 1 2 3 4 5 6
    
    -- 随到每个格子的概率 probs
    local nRandomIndex = LuaHelper.GetIndexByRate(WheelConfig.probs)

    local nStep = WheelConfig.steps[nRandomIndex]
    -- Debug.Log("---nRandomIndex: " .. nRandomIndex .. "  ---nStep: " .. nStep)

    return nRandomIndex
end

function ChutesRocketsMainUIPop:getGiftRandomIndex()
    local nRandomIndex = LuaHelper.GetIndexByRate(GiftProb.probs)
    local nStep = GiftProb.index[nRandomIndex]
    return nRandomIndex
end

function ChutesRocketsMainUIPop:refreshRewardContent()
    local multiple = ChutesRocketsDataHandler.data.fRewardMultiple
    self.m_textReward.text = MoneyFormatHelper.numWithCommas(ChutesRocketsLevelManager.nRewardCoins).." COINS"
    if multiple > 1 then
        self.m_trMoreMultiple.gameObject:SetActive(true)
        local mul = math.ceil((multiple - 1)*100)
        self.m_textMultiple.text = string.format("%d",mul).."%\n More"
    else
        self.m_trMoreMultiple.gameObject:SetActive(false)
    end
end

function ChutesRocketsMainUIPop:onBackToChoicePopBtnClick()
    ChutesRocketsChoiceLevelPop:Show()
    self.popController:hide(true)
end

function ChutesRocketsMainUIPop:OnDestroy()
    
end

local getCoinsCount = 0
local getSpinCount = 0
local getMultipleCount = 0
local flyToLastCount = 0
local rocketsCount = 0
local sliderCount = 0

-- 仿真函数
function ChutesRocketsMainUIPop:simulationGame(param)

    local totalSpinCount = 0

    getCoinsCount = 0
    getSpinCount = 0
    getMultipleCount = 0
    flyToLastCount = 0
    rocketsCount = 0
    sliderCount = 0
    
    -- 仿真结束之后要恢复的参数
    local nPreLevelID = ChutesRocketsDataHandler.data.nLevel
    local nPreLevelProgress = ChutesRocketsDataHandler.data.nLevelProgress 

    local count = param.nSimCount
    local nLevelID = param.nLevelID

    ChutesRocketsDataHandler.data.nLevel = nLevelID
    ChutesRocketsDataHandler.data.nLevelProgress = 1 
    ChutesRocketsLevelManager:updateLevelInfo()

    for i=1, count do
        local isWin = false
        local spin = 0  --spin次数记录

        while not isWin do
            spin = spin + 1

            local nWheelIndex = self:getWheelRandomIndex()
            local nStep = WheelConfig.steps[nWheelIndex]
            local progress = ChutesRocketsDataHandler.data.nLevelProgress
            progress = progress + nStep
            
            isWin = progress >= ChutesRocketsLevelManager.m_levelInfo.N_MAX_GRID_COUNT

            ChutesRocketsDataHandler.data.nLevelProgress = progress

            if isWin then
                break
            else
                isWin = self:simulationCheckIsSpecialItem(progress)
            end

            if isWin then
                break
            end

        end

        ChutesRocketsDataHandler.data.nLevel = nLevelID
        ChutesRocketsDataHandler.data.nLevelProgress = 1 

        totalSpinCount = totalSpinCount + spin
    end

    ChutesRocketsDataHandler.data.nLevel = nPreLevelID
    ChutesRocketsDataHandler.data.nLevelProgress = nPreLevelProgress
    ChutesRocketsLevelManager:updateLevelInfo() --回复数据

    Debug.Log("平均过关spin次数为："..totalSpinCount/count)
    Debug.Log("平均过关获得金币礼物次数为："..getCoinsCount/count)
    Debug.Log("平均过关获得spin个数为："..getSpinCount/count)
    Debug.Log("平均过关获得加倍礼物次数为："..getMultipleCount/count)
    Debug.Log("平均过关飞向终点次数为："..flyToLastCount/count)
    Debug.Log("平均过关火箭礼物次数为："..rocketsCount/count)
    Debug.Log("平均过关滑梯礼物次数为："..sliderCount/count)
end

function ChutesRocketsMainUIPop:simulationCheckIsSpecialItem(nID)
    for k,v in pairs(ChutesRocketsLevelManager.m_levelInfo.TABLE_SPECIAL_GRID) do
        if v.nID == nID then
            if v.enumType == ChutesRocketsItemType.enumItem_Gift then
                local random = self:getGiftRandomIndex()
                local strGift = "gift"..random
                ChutesRocketsLevelManager.strGift = strGift
                local giftInfo = GiftConfig[strGift]
                if giftInfo.giftType == GiftType.giftType_Add1000000Coins then

                    -- 记录给金币的次数
                    getCoinsCount = getCoinsCount + 1

                elseif giftInfo.giftType == GiftType.giftType_Add2000000Coins then

                    -- 记录给金币的次数
                    getCoinsCount = getCoinsCount + 1

                elseif giftInfo.giftType == GiftType.giftType_AddOneSpinCount then

                    -- 记录添加spin个数giftInfo.gift
                    getSpinCount = getSpinCount + 1

                elseif giftInfo.giftType == GiftType.giftType_AddRewardMultiple then

                    -- 记录翻倍次数
                    getMultipleCount = getMultipleCount + 1

                elseif giftInfo.giftType == GiftType.giftType_FlyToLastOne then

                    -- 记录火箭礼物个数
                    ChutesRocketsDataHandler.data.nLevelProgress = ChutesRocketsLevelManager.m_levelInfo.N_MAX_GRID_COUNT
                    flyToLastCount = flyToLastCount + 1
                    return true
                    -- local isWin = self:checkIsWin(ChutesRocketsDataHandler.data.nLevelProgress)
                end
            elseif v.enumType == ChutesRocketsItemType.enumItem_Rocket then
                ChutesRocketsDataHandler.data.nLevelProgress = v.nTarget
                rocketsCount = rocketsCount + 1
                self:simulationCheckIsSpecialItem(v.nTarget)

            elseif v.enumType == ChutesRocketsItemType.enumItem_Slide then
                ChutesRocketsDataHandler.data.nLevelProgress = v.nTarget
                sliderCount = sliderCount + 1
                self:simulationCheckIsSpecialItem(v.nTarget)
            end
            return false
        end
    end
end