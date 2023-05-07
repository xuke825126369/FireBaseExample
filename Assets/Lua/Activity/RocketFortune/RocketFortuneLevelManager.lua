RocketFortuneLevelManager = {}

RocketFortuneLevelManager.m_trPlayer = nil
RocketFortuneLevelManager.m_goPlayer = nil
RocketFortuneLevelManager.m_trAllItems = {} --格子Transform，m_trAllItems[1]..
RocketFortuneLevelManager.m_specialItems = {} --道具格子配置表
RocketFortuneLevelManager.m_trSpecialItems = {} --道具格子Transform，m_trSpecialItems[1]..
RocketFortuneLevelManager.m_levelInfo = {} --运行时数据，限时活动关卡配置表

RocketFortuneLevelManager.m_trLevel = nil

RocketFortuneLevelManager.nCurrentIndex = 1 --默认为1，运行时数据，不保存
RocketFortuneLevelManager.nCurrentTarget = 0 --默认为0，运行时数据，不保存
RocketFortuneLevelManager.nFlyTarget = 0 --默认为0，运行时数据，不保存
RocketFortuneLevelManager.nRewardCoins = 0 --默认为0，运行时数据，不保存

RocketFortuneLevelManager.strGift = nil --默认为空的字符串

RocketFortuneLevelManager.ITEM_WIDTH = 162
RocketFortuneLevelManager.ITEM_HEIGHT = 222

GiftType = {
    giftType_Add1000000Coins = 0,
    giftType_Add2000000Coins = 1,
    giftType_AddOneSpinCount = 2,
    giftType_AddRewardMultiple = 3,
    giftType_FlyToLastOne = 4
}

GiftConfig = {
    gift1 = { giftType = GiftType.giftType_Add1000000Coins, gift = 1000000}, --奖励加1000000金币
    gift2 = { giftType = GiftType.giftType_Add2000000Coins, gift = 2000000}, --奖励加2000000金币
    gift3 = { giftType = GiftType.giftType_AddOneSpinCount, gift = 1},       --奖励增加一次spin次数

    gift4 = { giftType = GiftType.giftType_AddRewardMultiple, gift = 0.15},
    --奖励完成关卡增加15%倍数 RocketFortuneDataHandler.data.fRewardMultiple+0.15

    gift5 = { giftType = GiftType.giftType_AddRewardMultiple, gift = 0.25},
    --奖励完成关卡增加25%倍数 RocketFortuneDataHandler.data.fRewardMultiple+0.25

    gift6 = { giftType = GiftType.giftType_FlyToLastOne}
    --奖励将Player飞向数字高的格子
}

function RocketFortuneLevelManager:generateActiveLevel(trParent)
    -- 更换关卡清空item
    if self.m_trAllItems ~= nil then
        for k,v in pairs(self.m_trAllItems) do
            Unity.GameObject.Destroy(v.gameObject)
        end
    end

    if self.m_trSpecialItems ~= nil then
        for k,v in pairs(self.m_trSpecialItems) do
            Unity.GameObject.Destroy(v.gameObject)
        end
    end

    if self.m_trLevel ~= nil then
        Unity.GameObject.Destroy(self.m_trLevel.gameObject)
    end
    
    self.m_trAllItems = nil
    self.m_trAllItems = {}

    self.m_specialItems = nil
    self.m_specialItems = {}

    self.m_trSpecialItems = nil
    self.m_trSpecialItems = {}

    -- 游戏界面的生成
    self:updateLevelInfo()

    -- 如果没有该关卡则不生成
    if self.m_levelInfo == nil then
        return false
    end

    self.nRewardCoins = self:getLevelReward()

    self:loadLevel(trParent, ActiveManager.dataHandler.data.nLevel)
    self:initPlayerLocation()
    self:initSpecialItems()
    return true
end

function RocketFortuneLevelManager:getLevelReward(levelID)
    local fRewardMultiple= RocketFortuneDataHandler.data.fRewardMultiple
    
    local strSKuKey = AllBuyCFG[1].productId
	local skuInfo = GameHelper:GetSimpleSkuInfoById(strSKuKey)
    local nCoins5 = skuInfo.baseCoins -- 不乘打折系数的。。

    -- 越往后的关卡奖励越丰厚
    local fLevelCoef = RocketFortuneDataHandler.data.nLevel * 0.2
    if levelID ~= nil then
        fLevelCoef = levelID * 0.2
        fRewardMultiple = 1
    end

    fLevelCoef = 1+ fLevelCoef

    if levelID == RocketFortuneConfig.N_MAX_LEVEL + 1 then
        -- 特殊 用于返回所有关卡都完成之后的总奖励
        fLevelCoef = 3 + fLevelCoef
    end
    
    local nRewardCoins = nCoins5 * fRewardMultiple * fLevelCoef
    nRewardCoins = MoneyFormatHelper.normalizeCoinCount(nRewardCoins, 3)
    return nRewardCoins
end

function RocketFortuneLevelManager:initSpecialItems()
    for k,v in pairs(self.m_levelInfo.TABLE_SPECIAL_GRID) do
        self.m_specialItems[v.nID] = v
    end

    local giftContainer = self.m_trLevel:FindDeepChild("GiftContainer")
    local rocketContainer = self.m_trLevel:FindDeepChild("RocketContainer")
    local sliderContainer = self.m_trLevel:FindDeepChild("SliderContainer")
    --local jewelryContainer = self.m_trLevel:FindDeepChild("JewelryContainer")

    local sliderIndex = 1
    for k,v in pairs(self.m_specialItems) do
        if v.enumType == RocketFortuneItemType.enumItem_Gift then
            local giftPrefab = AssetBundleHandler:LoadActivityAsset("LevelItem/Gift")
            local gift = Unity.Object.Instantiate(giftPrefab).transform
            gift:SetParent(giftContainer, false)
            gift.position = self.m_trAllItems[v.nID].position
        elseif v.enumType == RocketFortuneItemType.enumItem_Rocket then
            local rocketPrefab = AssetBundleHandler:LoadActivityAsset("LevelItem/Rocket")
            local rocket = Unity.Object.Instantiate(rocketPrefab).transform
            rocket:SetParent(rocketContainer, false)
            local posTarget = self.m_trAllItems[v.nTarget].position
            rocket.position = posTarget
            local posItem = self.m_trAllItems[v.nID].position
            
            -- 分母为0的情况怎么处理？ -- 是应该处理，但火箭和梯子的y不可能相同，如果相同道具没有意义（配置表可能写错）
            local value = (posTarget.x - posItem.x)/(posTarget.y - posItem.y)
            local rotate = math.deg(math.atan(value))

            rocket.rotation = Unity.Quaternion.Euler(0, 0, -rotate)
            if rotate > 0 then
                rocket.localScale = Unity.Vector3(-1, 1, 1)
            end
            local height = Unity.Vector3.Distance(posTarget, posItem)
            --rocket:FindDeepChild("Trailer").sizeDelta = Unity.Vector2(38, height)
            rocket:FindDeepChild("Trailer").localScale = Unity.Vector3(1, height / (316 * self.m_canvasContainer.localScale.x), 1) 
            self.m_trSpecialItems[v.nID] = rocket
            rocket:FindDeepChild("Cloud").position = posItem

        elseif v.enumType == RocketFortuneItemType.enumItem_Slide then
            local sliderPath = "LevelItem/Slider".. sliderIndex
            local sliderPrefab = AssetBundleHandler:LoadActivityAsset(sliderPath)
            local slider = Unity.Object.Instantiate(sliderPrefab).transform
            slider:SetParent(sliderContainer, false)
            
            local posItem = self.m_trAllItems[v.nID].position
            local posTarget = self.m_trAllItems[v.nTarget].position
            slider.position = (posItem + posTarget)/2

            local value = (posItem.x - posTarget.x)/(posItem.y - posTarget.y)
            local rotate = math.deg(math.atan(value))
            slider.rotation = Unity.Quaternion.Euler(0, 0, -rotate)
            local height = Unity.Vector3.Distance(posTarget,posItem)
            if rotate > 0 then
                slider.localScale = Unity.Vector3(-1, height / (404 * self.m_canvasContainer.localScale.x), 1) 
            else
                slider.localScale = Unity.Vector3(1, height / (404 * self.m_canvasContainer.localScale.x), 1) 
            end           
            self.m_trSpecialItems[v.nID] = slider
        end
        sliderIndex = sliderIndex + 1
        if sliderIndex > 5 then
            sliderIndex = 1
        end
    end

    -- local posX = -(self.ITEM_WIDTH*5)
    -- local posY = -self.m_canvasContainer.sizeDelta.y/2
    -- for i=1, ((self.m_levelInfo.N_MAX_GRID_COUNT/10)+1) do
    --     for i=1, 11 do
    --         local jewelryPath = "LevelItem/Jewelry"..RocketFortuneDataHandler.data.nLevel
    --         local jewelryPrefab = AssetBundleHandler:LoadActivityAsset(jewelryPath)
    --         local jewelry = Unity.Object.Instantiate(jewelryPrefab).transform
    --         jewelry:SetParent(jewelryContainer, false)
    --         jewelry.position = Unity.Vector2(posX, posY)
    --         posX = posX + self.ITEM_WIDTH
    --     end
    --     posX = -(self.ITEM_WIDTH*5)
    --     posY = posY + self.ITEM_HEIGHT
    -- end

    -- local bgFrame = self.m_trLevel:FindDeepChild("BgFrame")
    -- bgFrame.sizeDelta = Unity.Vector2(1640, self.ITEM_HEIGHT * self.m_levelInfo.N_MAX_GRID_COUNT/10 + 10)
    -- bgFrame.position = Unity.Vector2(0, bgFrame.sizeDelta.y/2 - self.m_canvasContainer.sizeDelta.y/2)
    -- -- if RocketFortuneDataHandler.data.nLevel == 6 then
    -- --     bgFrame.position = Unity.Vector2(0, 130 + RocketFortuneDataHandler.data.nLevel * self.ITEM_HEIGHT)
    -- -- end

    -- bgFrame:SetAsLastSibling()
    --jewelryContainer:SetAsLastSibling()
    giftContainer:SetAsLastSibling()
    sliderContainer:SetAsLastSibling()
    rocketContainer:SetAsLastSibling()

    self.m_trPlayer:SetAsLastSibling()
end

function RocketFortuneLevelManager:loadLevel(trParent, nLevel)
    local prefabObj = AssetBundleHandler:LoadActivityAsset("Levels/Level"..nLevel)

    self.m_trLevel = Unity.Object.Instantiate(prefabObj, trParent).transform
    self.m_trLevel:SetAsFirstSibling()
    self.m_goPlayer = RocketFortuneMainUIPop.goPlayer
    self.m_trPlayer = self.m_goPlayer.transform
    local trGrid = self.m_trLevel:FindDeepChild("Deck/Grid")
    self.m_trPlayer:SetParent(trGrid)
    self.m_canvasContainer = Unity.GameObject.Find("CanvasContainer").transform
    self.container = self.m_trLevel:FindDeepChild("Deck")
    self.m_trAllItems = LuaHelper.GetTableFindChild(self.m_trLevel, self.m_levelInfo.N_MAX_GRID_COUNT, nil, Unity.Transform)
    for i = 1, #self.m_trAllItems do
        self.m_trAllItems[i]:GetComponentInChildren(typeof(UnityUI.Text)).text = tostring(i)
    end
end

function RocketFortuneLevelManager:initPlayerLocation()
    local fbid = FBHandler:getFbId()
    local userAvatar = self.m_trPlayer:FindDeepChild("Ani/TouXiang")
    if fbid ~= nil then
        local userImg = FBHandler:getAvatar(fbid)
        if userImg ~= nil then
            userAvatar.gameObject:SetActive(true)
            userAvatar:GetComponent(typeof(UnityUI.Image)).texture = userImg
        else
            userAvatar.gameObject:SetActive(false)
        end
    else
        userAvatar.gameObject:SetActive(false)
    end
    
    self.nCurrentIndex = RocketFortuneDataHandler.data.nLevelProgress
    self.m_trPlayer.localPosition = self.m_trAllItems[self.nCurrentIndex].localPosition
    Debug.Log("RocketFortuneLevelManager:initPlayerLocation "..self.nCurrentIndex)
    self:setContainerPos()
end

function RocketFortuneLevelManager:beginPlayerToTarget()
    -- self.m_btnBackToChoicePop.interactable = false
    --点击spin后 player开始走路
    local isWin = self:checkIsWin()
    if isWin then
        return
    end

    if self.nCurrentIndex < self.nCurrentTarget then
        --走的过程中发现已是最后一步，弹出胜利窗口，记录为下一关并保存数据
        ActivityHelper:PlayAni(self.m_goPlayer, "Jump")
        ActivityAudioHandler:PlaySound("player_jump")
        self.nCurrentIndex = self.nCurrentIndex + 1
        LeanTween.moveLocal(self.m_goPlayer, self.m_trAllItems[self.nCurrentIndex].localPosition, 0.5):setEase(LeanTweenType.easeInOutSine):setOnComplete(function()
            self:beginPlayerToTarget()
        end):setOnUpdate(function()
            self:setContainerPos()
        end)
    else
        self:checkIsSpecialItem()
    end
end

function RocketFortuneLevelManager:checkIsWin()
    if self.nCurrentIndex == self.m_levelInfo.N_MAX_GRID_COUNT then
        ActivityAudioHandler:PlaySound("map_end")
        --TODO 显示胜利页面 print("限时关卡胜利页")，将m_bIsGenerateLevel设置为false，下次进入该模式重新生成游戏界面
        RocketFortuneMainUIPop.m_bIsGenerateLevel = false
        
        -- 重置奖励倍数
        RocketFortuneDataHandler.data.fRewardMultiple = 1
        RocketFortuneDataHandler:writeFile()

        RocketFortuneWinPop:Show()
        return true
    end
    return false
end

function RocketFortuneLevelManager:checkIsSpecialItem()
    -- player停止后检测是否为特殊格子
    for k,v in pairs(self.m_levelInfo.TABLE_SPECIAL_GRID) do
        if v.nID == self.nCurrentIndex then
            -- TODO 检测是否有消除梯子功能
            if not RocketFortuneDataHandler:checkInRemoveSliderTime() then
                -- 检测当前格子为特殊格子
                if v.enumType == RocketFortuneItemType.enumItem_Gift then
                    Debug.Log("当前格子为礼物格子")
                    ActivityAudioHandler:PlaySound("wheel_prize")
                    self:showGiftUI()
                elseif v.enumType == RocketFortuneItemType.enumItem_Rocket then
                    Debug.Log("当前格子为火箭格子")
                    ActivityAudioHandler:PlaySound("player_fly")
                    self:beginPlayerFlyToTarget()
                elseif v.enumType == RocketFortuneItemType.enumItem_Slide then
                    Debug.Log("当前格子为滑梯格子")
                    ActivityAudioHandler:PlaySound("map_bridge")
                    self:beginPlayerFlyToTarget()
                end
            end
            return
        end
    end
    -- self.m_btnBackToChoicePop.interactable = true
    RocketFortuneMainUIPop.Wheel:Show()
end

function RocketFortuneLevelManager:beginPlayerFlyToTarget()
    -- 当player走到特殊格子时，直接飞向目标
    self.nCurrentIndex = self.nFlyTarget
    LeanTween.moveLocal(self.m_trPlayer.gameObject,self.m_trAllItems[self.nCurrentIndex].localPosition,1):setOnComplete(function()
        self:checkIsSpecialItem()
    end):setOnUpdate(function()
        self:setContainerPos()
    end)
end

function RocketFortuneLevelManager:beginPlayerFlyToLastOne()
    ActivityAudioHandler:PlaySound("player_fly")
    self.nCurrentIndex = self.m_levelInfo.N_MAX_GRID_COUNT
    --TODO 添加一个延时，让火箭先升空，再移动，再掉下来
    LeanTween.delayedCall(4.2, function()
        LeanTween.moveLocal(self.m_trPlayer.gameObject,self.m_trAllItems[self.nCurrentIndex].localPosition,2.8):setEase(LeanTweenType.easeInOutExpo):setOnComplete(function()
            self:checkIsWin()
            --TODO player结束火箭动画
        end):setOnUpdate(function()
            self:setContainerPos()
        end)
    end)
end

function RocketFortuneLevelManager:setContainerPos()
    if (self.m_trPlayer.localPosition.y > 0) and (self.m_trPlayer.localPosition.y < self.m_trAllItems[self.m_levelInfo.N_MAX_GRID_COUNT - 10].localPosition.y) then
        self.container.localPosition = Unity.Vector3(0, -self.m_trPlayer.localPosition.y, 0)
    elseif self.m_trPlayer.localPosition.y >= self.m_trAllItems[self.m_levelInfo.N_MAX_GRID_COUNT - 10].localPosition.y then
        self.container.localPosition = Unity.Vector3(0, -self.m_trAllItems[self.m_levelInfo.N_MAX_GRID_COUNT].localPosition.y + self.m_canvasContainer.sizeDelta.y/2 - 300, 0)
    elseif self.m_trPlayer.localPosition.y == self.m_trAllItems[1].localPosition.y then
        self.container.localPosition = Unity.Vector3.zero
    end
end

function RocketFortuneLevelManager:onCloseBtnClicked()
    RocketFortuneMainUIPop.popController:hide(true)
end

function RocketFortuneLevelManager:showGiftUI()
    if GiftConfig[self.strGift].giftType == GiftType.giftType_Add1000000Coins then
        --TODO 显示获得1000000金币页面
        RocketFortuneGiftAddCoinsPop:Show()
    elseif GiftConfig[self.strGift].giftType == GiftType.giftType_Add2000000Coins then
        --TODO 显示获得2000000金币页面
        RocketFortuneGiftAddCoinsPop:Show()
    elseif GiftConfig[self.strGift].giftType == GiftType.giftType_AddOneSpinCount then
        --TODO 显示获得spin页面
        RocketFortuneGiftAddSpinPop:Show()
    elseif GiftConfig[self.strGift].giftType == GiftType.giftType_AddRewardMultiple then
        --TODO 显示获得倍数页面 ， 并刷新顶部奖励额度
        self.nRewardCoins = self:getLevelReward()
        RocketFortuneMainUIPop:refreshRewardContent()
        RocketFortuneGiftAddMultiplePop:Show()
    elseif GiftConfig[self.strGift].giftType == GiftType.giftType_FlyToLastOne then
        --TODO 显示获得火箭页面，页面中点击keepBtn后，飞向终点
        RocketFortuneGiftRocketsPop:Show()
    end
end

function RocketFortuneLevelManager:updateLevelInfo()
    local levelName = "RocketFortuneLevel"..RocketFortuneDataHandler.data.nLevel
    self.m_levelInfo = RocketFortuneLevelConfig[levelName]
end

-- 显示隐藏所有梯子
function RocketFortuneLevelManager:ShowOrHideAllSlider(bIsShow)
    for k,v in pairs(self.m_specialItems) do
        if v.enumType == RocketFortuneItemType.enumItem_Slide then
            self.m_trSpecialItems[v.nID].gameObject:SetActive(bIsShow)
        end
    end
end