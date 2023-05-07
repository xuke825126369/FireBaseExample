ChutesRocketsLevelManager = {}

ChutesRocketsLevelManager.m_trPlayer = nil
ChutesRocketsLevelManager.m_trPlayerAnimator = nil
ChutesRocketsLevelManager.m_trAllItems = {} --格子Transform，m_trAllItems[1]..
ChutesRocketsLevelManager.m_specialItems = {} --道具格子配置表
ChutesRocketsLevelManager.m_trSpecialItems = {} --道具格子Transform，m_trSpecialItems[1]..
ChutesRocketsLevelManager.m_levelInfo = {} --运行时数据，限时活动关卡配置表

ChutesRocketsLevelManager.m_trLevel = nil

ChutesRocketsLevelManager.nCurrentIndex = 1 --默认为1，运行时数据，不保存
ChutesRocketsLevelManager.nCurrentTarget = 0 --默认为0，运行时数据，不保存
ChutesRocketsLevelManager.nFlyTarget = 0 --默认为0，运行时数据，不保存
ChutesRocketsLevelManager.nRewardCoins = 0 --默认为0，运行时数据，不保存

ChutesRocketsLevelManager.strGift = nil --默认为空的字符串

ChutesRocketsLevelManager.ITEM_WIDTH = 162
ChutesRocketsLevelManager.ITEM_HEIGHT = 222

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
    --奖励完成关卡增加15%倍数 ChutesRocketsDataHandler.data.fRewardMultiple+0.15

    gift5 = { giftType = GiftType.giftType_AddRewardMultiple, gift = 0.25},
    --奖励完成关卡增加25%倍数 ChutesRocketsDataHandler.data.fRewardMultiple+0.25

    gift6 = { giftType = GiftType.giftType_FlyToLastOne}
    --奖励将Player飞向数字高的格子
}

function ChutesRocketsLevelManager:generateActiveLevel(trParent)
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

    self:loadLevel(trParent)
    self:initPlayerLocation()
    self:initSpecialItems()
    return true
end

function ChutesRocketsLevelManager:getLevelReward(levelID)
    local fRewardMultiple= ChutesRocketsDataHandler.data.fRewardMultiple
    
    local strSKuKey = AllBuyCFG[1].productId
	local skuInfo = GameHelper:GetSimpleSkuInfoById(strSKuKey)
    local nCoins5 = skuInfo.baseCoins -- 不乘打折系数的。。

    -- 越往后的关卡奖励越丰厚
    local fLevelCoef = ChutesRocketsDataHandler.data.nLevel * 0.2
    if levelID ~= nil then
        fLevelCoef = levelID * 0.2
        fRewardMultiple = 1
    end

    fLevelCoef = 1+ fLevelCoef

    if levelID == 7 then
        -- 特殊 用于返回所有关卡都完成之后的总奖励
        fLevelCoef = 3 + fLevelCoef
    end
    
    local nRewardCoins = nCoins5 * fRewardMultiple * fLevelCoef
    nRewardCoins = MoneyFormatHelper.normalizeCoinCount(nRewardCoins, 3)
    return nRewardCoins
end

function ChutesRocketsLevelManager:initSpecialItems()
    for k,v in pairs(self.m_levelInfo.TABLE_SPECIAL_GRID) do
        self.m_specialItems[v.nID] = v
    end

    local giftContainer = self.m_trLevel:FindDeepChild("GiftContainer")
    local rocketContainer = self.m_trLevel:FindDeepChild("RocketContainer")
    local sliderContainer = self.m_trLevel:FindDeepChild("SliderContainer")
    local jewelryContainer = self.m_trLevel:FindDeepChild("JewelryContainer")

    local sliderIndex = 1
    for k,v in pairs(self.m_specialItems) do
        if v.enumType == ChutesRocketsItemType.enumItem_Gift then
            local giftPrefab = Util.getChutesRocketsPrefab("Assets/ActiveNeedLoad/ChutesRockets/LevelItem/Gift.prefab")
            local gift = Unity.Object.Instantiate(giftPrefab).transform
            gift:SetParent(giftContainer, false)
            gift.anchoredPosition = self.m_trAllItems[v.nID].anchoredPosition

        elseif v.enumType == ChutesRocketsItemType.enumItem_Rocket then
            local rocketPrefab = Util.getChutesRocketsPrefab("Assets/ActiveNeedLoad/ChutesRockets/LevelItem/Rocket.prefab")
            local rocket = Unity.Object.Instantiate(rocketPrefab).transform
            rocket:SetParent(rocketContainer, false)
            local posTarget = self.m_trAllItems[v.nTarget].anchoredPosition
            rocket.anchoredPosition = posTarget
            local posItem = self.m_trAllItems[v.nID].anchoredPosition
            
            -- 分母为0的情况怎么处理？ -- 是应该处理，但火箭和梯子的y不可能相同，如果相同道具没有意义（配置表可能写错）
            local value = (posTarget.x - posItem.x)/(posTarget.y - posItem.y)
            local rotate = math.deg(math.atan(value))

            rocket.rotation = Unity.Quaternion.Euler(0, 0, -rotate)
            if rotate > 0 then
                rocket.localScale = Unity.Vector3(-1, 1, 1)
            end
            local height = Unity.Vector2.Distance(posTarget, posItem)
            rocket:FindDeepChild("Trailer").sizeDelta = Unity.Vector2(38, height)
            self.m_trSpecialItems[v.nID] = rocket
            rocket:FindDeepChild("Cloud").anchoredPosition = Unity.Vector2(0, -height)

        elseif v.enumType == ChutesRocketsItemType.enumItem_Slide then
            local sliderPath = "Assets/ActiveNeedLoad/ChutesRockets/LevelItem/Slider".. sliderIndex ..".prefab"
            local sliderPrefab = Util.getChutesRocketsPrefab(sliderPath)
            local slider = Unity.Object.Instantiate(sliderPrefab).transform
            slider:SetParent(sliderContainer, false)
            
            local posItem = self.m_trAllItems[v.nID].anchoredPosition
            slider.anchoredPosition = posItem
            local posTarget = self.m_trAllItems[v.nTarget].anchoredPosition

            local value = (posItem.x - posTarget.x)/(posItem.y - posTarget.y)
            local rotate = math.deg(math.atan(value))
            slider.rotation = Unity.Quaternion.Euler(0, 0, -rotate)
            if rotate > 0 then
                slider.localScale = Unity.Vector3(-1, 1, 1)
            end
            local height = Unity.Vector2.Distance(posTarget,posItem)
            slider.sizeDelta = Unity.Vector2(99, height)
            self.m_trSpecialItems[v.nID] = slider
        end
        sliderIndex = sliderIndex + 1
        if sliderIndex > 5 then
            sliderIndex = 1
        end
    end

    local posX = -(self.ITEM_WIDTH*5)
    local posY = -self.m_canvasContainer.sizeDelta.y/2
    for i=1, ((self.m_levelInfo.N_MAX_GRID_COUNT/10)+1) do
        for i=1, 11 do
            local jewelryPath = "Assets/ActiveNeedLoad/ChutesRockets/LevelItem/Jewelry"..ChutesRocketsDataHandler.data.nLevel..".prefab"
            local jewelryPrefab = Util.getChutesRocketsPrefab(jewelryPath)
            local jewelry = Unity.Object.Instantiate(jewelryPrefab).transform
            jewelry:SetParent(jewelryContainer, false)
            jewelry.anchoredPosition = Unity.Vector2(posX, posY)
            posX = posX + self.ITEM_WIDTH
        end
        posX = -(self.ITEM_WIDTH*5)
        posY = posY + self.ITEM_HEIGHT
    end

    local bgFrame = self.m_trLevel:FindDeepChild("BgFrame")
    bgFrame.sizeDelta = Unity.Vector2(1640, self.ITEM_HEIGHT * self.m_levelInfo.N_MAX_GRID_COUNT/10 + 10)
    bgFrame.anchoredPosition = Unity.Vector2(0, bgFrame.sizeDelta.y/2 - self.m_canvasContainer.sizeDelta.y/2)
    -- if ChutesRocketsDataHandler.data.nLevel == 6 then
    --     bgFrame.anchoredPosition = Unity.Vector2(0, 130 + ChutesRocketsDataHandler.data.nLevel * self.ITEM_HEIGHT)
    -- end

    bgFrame:SetAsLastSibling()
    jewelryContainer:SetAsLastSibling()
    giftContainer:SetAsLastSibling()
    sliderContainer:SetAsLastSibling()
    rocketContainer:SetAsLastSibling()
    self.m_trPlayer:SetAsLastSibling()
end

function ChutesRocketsLevelManager:addItem(nID,item)
    --添加格子到allItems内
    if not LuaHelper.tableContainsElement(self.m_trAllItems,item) then
        self.m_trAllItems[nID] = item
    end
end

function ChutesRocketsLevelManager:createItem(nID,trParent)
    local itemPath = "Assets/ActiveNeedLoad/ChutesRockets/LevelItem/Item"..ChutesRocketsDataHandler.data.nLevel..".prefab"
    local itemPrefab = Util.getChutesRocketsPrefab(itemPath)
    local transform = Unity.Object.Instantiate(itemPrefab).transform
    transform.gameObject.name = nID
    transform:FindDeepChild("Text"):GetComponent(typeof(UnityUI.Text)).text = nID
    transform:SetParent(trParent)
    if nID % 2 == 0 then
        transform:FindDeepChild("BG2").gameObject:SetActive(true)
        transform:FindDeepChild("BG1").gameObject:SetActive(false)
    end
    if nID == self.m_levelInfo.N_MAX_GRID_COUNT then
        transform:FindDeepChild("Chest").gameObject:SetActive(true)
    end
    return transform
end

function ChutesRocketsLevelManager:loadLevel(trParent)
    local strPath = "Assets/ActiveNeedLoad/ChutesRockets/ChutesRocketsLevel.prefab"
    local prefabObj = Util.getChutesRocketsPrefab(strPath)

    self.m_trLevel = Unity.Object.Instantiate(prefabObj).transform
    self.m_trPlayer = self.m_trLevel:FindDeepChild("Player")
    self.m_trPlayerAnimator = self.m_trPlayer:GetComponent(typeof(Unity.Animator))
    self.m_canvasContainer = Unity.GameObject.Find("CanvasContainer").transform

    --LuaAutoBindMonoBehaviour.Bind(self.m_trPlayer.gameObject,self)
    -- for i=1,self.m_levelInfo.N_MAX_GRID_COUNT do
    --     self:addItem(i,transform:FindDeepChild(i))
    -- end
    self.container = self.m_trLevel:FindDeepChild("Container")
    for i=1,self.m_levelInfo.N_MAX_GRID_COUNT do
        local item = self:createItem(i,self.container)
        self:addItem(i,item)
    end
    self:assignItemLocation()
    self.m_trLevel:SetParent(trParent,false)
end

function ChutesRocketsLevelManager:assignItemLocation()
    self.container.anchoredPosition = Unity.Vector2(0, 0)
    --定义格子位置
    local lastPos = Unity.Vector2.zero
    local posY = -self.m_canvasContainer.sizeDelta.y/2 + self.ITEM_HEIGHT/2
    local firstPos = Unity.Vector2(-(self.ITEM_WIDTH*4.5), posY)
    local isRight = true
    for k,v in pairs(self.m_trAllItems) do
        if k == 1 then
            v.anchoredPosition = firstPos
        elseif k % 10 == 1 then
            v.anchoredPosition = Unity.Vector2(lastPos.x, lastPos.y + self.ITEM_HEIGHT)
            isRight = not isRight
        else
            if isRight then
                v.anchoredPosition = Unity.Vector2(lastPos.x + self.ITEM_WIDTH, lastPos.y)
            else
                v.anchoredPosition = Unity.Vector2(lastPos.x - self.ITEM_WIDTH, lastPos.y)
            end
        end
        lastPos = v.anchoredPosition
    end
end

function ChutesRocketsLevelManager:initPlayerLocation()
    local fbid = FBHandler:getFbId()
    local userAvatar = self.m_trPlayer:FindDeepChild("touxiang/playerAvatar/Avatar")
    if fbid ~= nil then
        local userImg = FBHandler:getAvatar(fbid)
        if userImg ~= nil then
            userAvatar.gameObject:SetActive(true)
            userAvatar:GetComponent(typeof(UnityUI.RawImage)).texture = userImg
        else
            userAvatar.gameObject:SetActive(false)
        end
    else
        userAvatar.gameObject:SetActive(false)
    end
    
    self.nCurrentIndex = ChutesRocketsDataHandler.data.nLevelProgress
    self.m_trPlayer.anchoredPosition = self.m_trAllItems[self.nCurrentIndex].anchoredPosition
    if (self.m_trPlayer.anchoredPosition.y > 0) and (self.m_trPlayer.anchoredPosition.y < self.m_trAllItems[self.m_levelInfo.N_MAX_GRID_COUNT - 10].anchoredPosition.y) then
        self.container.anchoredPosition = Unity.Vector2(0, -self.m_trPlayer.anchoredPosition.y)
    elseif self.m_trPlayer.anchoredPosition.y >= self.m_trAllItems[self.m_levelInfo.N_MAX_GRID_COUNT - 10].anchoredPosition.y then
        self.container.anchoredPosition = Unity.Vector2(0, -self.m_trAllItems[self.m_levelInfo.N_MAX_GRID_COUNT].anchoredPosition.y + self.m_canvasContainer.sizeDelta.y/2 - 300)
    elseif self.m_trPlayer.anchoredPosition.y == self.m_trAllItems[1].anchoredPosition.y then
        self.container.anchoredPosition = Unity.Vector2(0, 0)
    end
end

function ChutesRocketsLevelManager:beginPlayerToTarget()
    -- self.m_btnBackToChoicePop.interactable = false
    --点击spin后 player开始走路
    local isWin = self:checkIsWin()
    if isWin then
        return
    end

    if self.nCurrentIndex < self.nCurrentTarget then
        --走的过程中发现已是最后一步，弹出胜利窗口，记录为下一关并保存数据
        LeanTween.delayedCall(0.3,function()
            self.m_trPlayerAnimator:SetInteger("nPlayMode", 1)
        end)
        GlobalAudioHandler:PlayChutesRocketsSound("player_jump")
        self.nCurrentIndex = self.nCurrentIndex + 1
        LeanTween.moveLocal(self.m_trPlayer.gameObject, self.m_trAllItems[self.nCurrentIndex].localPosition, 0.5):setDelay(0.3):setEase(LeanTweenType.easeInOutSine):setOnComplete(function()
            self.m_trPlayerAnimator:SetInteger("nPlayMode", 0)
            self:beginPlayerToTarget()
        end):setOnUpdate(function()
            self:setContainerPos()
        end)
    else
        self:checkIsSpecialItem()
    end
end

function ChutesRocketsLevelManager:checkIsWin()
    if self.nCurrentIndex == self.m_levelInfo.N_MAX_GRID_COUNT then
        GlobalAudioHandler:PlayChutesRocketsSound("map_end")
        --TODO 显示胜利页面 print("限时关卡胜利页")，将m_bIsGenerateLevel设置为false，下次进入该模式重新生成游戏界面
        ChutesRocketsMainUIPop.m_bIsGenerateLevel = false
        
        -- 重置奖励倍数
        ChutesRocketsDataHandler.data.fRewardMultiple = 1
        ChutesRocketsDataHandler:writeFile()

        ChutesRocketsWinPop:Show()
        return true
    end
    return false
end

function ChutesRocketsLevelManager:checkIsSpecialItem()
    -- player停止后检测是否为特殊格子
    for k,v in pairs(self.m_levelInfo.TABLE_SPECIAL_GRID) do
        if v.nID == self.nCurrentIndex then
            -- TODO 检测是否有消除梯子功能
            if not ChutesRocketsDataHandler:checkInRemoveSliderTime() then
                -- 检测当前格子为特殊格子
                if v.enumType == ChutesRocketsItemType.enumItem_Gift then
                    Debug.Log("当前格子为礼物格子")
                    GlobalAudioHandler:PlayChutesRocketsSound("wheel_prize")
                    self:showGiftUI()
                elseif v.enumType == ChutesRocketsItemType.enumItem_Rocket then
                    Debug.Log("当前格子为火箭格子")
                    GlobalAudioHandler:PlayChutesRocketsSound("player_fly")
                    self:beginPlayerFlyToTarget()
                elseif v.enumType == ChutesRocketsItemType.enumItem_Slide then
                    Debug.Log("当前格子为滑梯格子")
                    GlobalAudioHandler:PlayChutesRocketsSound("map_bridge")
                    self:beginPlayerFlyToTarget()
                end
            end
            return
        end
    end
    -- self.m_btnBackToChoicePop.interactable = true
    ChutesRocketsMainUIPop:showWheel()
end

function ChutesRocketsLevelManager:beginPlayerFlyToTarget()
    -- 当player走到特殊格子时，直接飞向目标
    self.nCurrentIndex = self.nFlyTarget
    LeanTween.moveLocal(self.m_trPlayer.gameObject,self.m_trAllItems[self.nCurrentIndex].localPosition,1):setOnComplete(function()
        self:checkIsSpecialItem()
    end):setOnUpdate(function()
        self:setContainerPos()
    end)
end

function ChutesRocketsLevelManager:beginPlayerFlyToLastOne()
    GlobalAudioHandler:PlayChutesRocketsSound("player_fly")
    self.m_trPlayerAnimator:SetInteger("nPlayMode", 2)
    self.nCurrentIndex = self.m_levelInfo.N_MAX_GRID_COUNT
    --TODO 添加一个延时，让火箭先升空，再移动，再掉下来
    LeanTween.delayedCall(4.2, function()
        LeanTween.moveLocal(self.m_trPlayer.gameObject,self.m_trAllItems[self.nCurrentIndex].localPosition,2.8):setEase(LeanTweenType.easeInOutExpo):setOnComplete(function()
            self:checkIsWin()
            --TODO player结束火箭动画
            self.m_trPlayerAnimator:SetInteger("nPlayMode", 0)
        end):setOnUpdate(function()
            self:setContainerPos()
        end)
    end)
end

function ChutesRocketsLevelManager:setContainerPos()
    if self.m_trAllItems == nil then
        return
    end
    local pos = -self.m_trAllItems[self.m_levelInfo.N_MAX_GRID_COUNT].anchoredPosition.y + self.m_canvasContainer.sizeDelta.y/2 - 300
    if (self.m_trPlayer.anchoredPosition.y > 0) and (self.m_trPlayer.anchoredPosition.y < self.m_trAllItems[self.m_levelInfo.N_MAX_GRID_COUNT - 10].anchoredPosition.y) then
        self.container.anchoredPosition = Unity.Vector2(0, -self.m_trPlayer.anchoredPosition.y)
        if self.container.anchoredPosition.y <= pos then
            self.container.anchoredPosition = Unity.Vector2(0, pos)
        end
    elseif self.m_trPlayer.anchoredPosition.y >= self.m_trAllItems[self.m_levelInfo.N_MAX_GRID_COUNT - 10].anchoredPosition.y then
        self.container.anchoredPosition = Unity.Vector2(0, pos)
    elseif self.m_trPlayer.anchoredPosition.y <= 0 then
        self.container.anchoredPosition = Unity.Vector2(0, 0)
    end
    -- if self.m_trPlayer.anchoredPosition.y > self.m_trAllItems[self.m_levelInfo.N_MAX_GRID_COUNT - 10].anchoredPosition.y then
    --     self.container.anchoredPosition = Unity.Vector2(0, -self.m_trAllItems[self.m_levelInfo.N_MAX_GRID_COUNT].anchoredPosition.y + self.m_canvasContainer.sizeDelta.y/2 - 300)
    -- elseif (self.m_trPlayer.anchoredPosition.y > 0) and (self.m_trPlayer.anchoredPosition.y <= self.m_trAllItems[self.m_levelInfo.N_MAX_GRID_COUNT - 10].anchoredPosition.y) then
    --     self.container.anchoredPosition = Unity.Vector2(0, -self.m_trPlayer.anchoredPosition.y)
    -- elseif self.m_trPlayer.anchoredPosition.y <= 0 then
    --     self.container.anchoredPosition = Unity.Vector2(0, 0)
    -- end
end

function ChutesRocketsLevelManager:onCloseBtnClicked()
    ChutesRocketsMainUIPop.popController:hide(true)
end

function ChutesRocketsLevelManager:showGiftUI()
    if GiftConfig[self.strGift].giftType == GiftType.giftType_Add1000000Coins then
        --TODO 显示获得1000000金币页面
        ChutesRocketsGiftAddCoinsPop:Show()
    elseif GiftConfig[self.strGift].giftType == GiftType.giftType_Add2000000Coins then
        --TODO 显示获得2000000金币页面
        ChutesRocketsGiftAddCoinsPop:Show()
    elseif GiftConfig[self.strGift].giftType == GiftType.giftType_AddOneSpinCount then
        --TODO 显示获得spin页面
        ChutesRocketsGiftAddSpinPop:Show()
    elseif GiftConfig[self.strGift].giftType == GiftType.giftType_AddRewardMultiple then
        --TODO 显示获得倍数页面 ， 并刷新顶部奖励额度
        self.nRewardCoins = self:getLevelReward()
        ChutesRocketsMainUIPop:refreshRewardContent()
        ChutesRocketsGiftAddMultiplePop:Show()
    elseif GiftConfig[self.strGift].giftType == GiftType.giftType_FlyToLastOne then
        --TODO 显示获得火箭页面，页面中点击keepBtn后，飞向终点
        ChutesRocketsGiftRocketsPop:Show()
    end
end

function ChutesRocketsLevelManager:updateLevelInfo()
    local levelName = "ChutesRocketsLevel"..ChutesRocketsDataHandler.data.nLevel
    self.m_levelInfo = ChutesRocketsLevelConfig[levelName]
end

-- 显示隐藏所有梯子
function ChutesRocketsLevelManager:ShowOrHideAllSlider(bIsShow)
    for k,v in pairs(self.m_specialItems) do
        if v.enumType == ChutesRocketsItemType.enumItem_Slide then
            self.m_trSpecialItems[v.nID].gameObject:SetActive(bIsShow)
        end
    end
end