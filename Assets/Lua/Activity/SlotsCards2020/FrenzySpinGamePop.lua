FrenzySpinGamePop = {}

FrenzySpinGamePop.WheelItemPool = {}
FrenzySpinGamePop.WheelItemPoolParent = nil
FrenzySpinGamePop.mRotateRootTran = nil
FrenzySpinGamePop.m_trCardsContainer = nil
FrenzySpinGamePop.m_GlowEffectAni = nil
FrenzySpinGamePop.mListWheelItemPos = {}
FrenzySpinGamePop.mListGoWheelItem = {}
FrenzySpinGamePop.mListJackPotIds = {}
FrenzySpinGamePop.fWheelItemHight = 153
-- 1: Coins, 2: CoinRespin, 3:StampPack, 4:WildCard
FrenzySpinGamePop.targetJackPotIndexList = {1,2,3,4}
FrenzySpinGamePop.nTargetJackPotIndex = 0
FrenzySpinGamePop.N_ROW_COUNT = 4
FrenzySpinGamePop.m_cardData = {}
FrenzySpinGamePop.m_nCoinPrize = 0 -- 金卡spin获得的金币奖励值

function FrenzySpinGamePop:Show(albumKey, themeKey, cardKey)
    if IntroduceCardPop.transform ~= nil then
        IntroduceCardPop:Hide()
    end

    self.themeKey = themeKey
    self.cardKey = cardKey
    self.albumKey = albumKey
    SlotsCardsAudioHandler:PlaySound("golden_pop_up")

    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadSlotsCardsAsset("FrenzySpinGame/FrenzySpinGamePop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trCardsContainer = self.transform:FindDeepChild("CardContainer")
        self:LoadWheelItemPool()
        
        self.mRotateRootTran = self.transform:FindDeepChild("JackPotReel")
        self.mRotateRootTran.localPosition = Unity.Vector3.zero
        local nCenterIdnex = self.N_ROW_COUNT / 2
        for i = 1, self.N_ROW_COUNT * 2 do
            self.mListWheelItemPos[i] = Unity.Vector3(0, (i - nCenterIdnex) * self.fWheelItemHight, 0)
        end

        self.mSpinBtn = self.transform:FindDeepChild("SpinBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.mSpinBtn)
        self.mSpinBtn.onClick:AddListener(function()
            SlotsCardsAudioHandler:PlaySound("golden_spin_button")
            self.mSpinBtn.interactable = false
            LeanTween.delayedCall(0.4,function()
                self:PlayRotateAni()
            end)
        end)

        self.m_spinEffectGo = self.transform:FindDeepChild("lizigensui").gameObject
        self.m_finalEffectGo = self.transform:FindDeepChild("FinalEffect").gameObject
        self.m_getCoinsRewardGo = self.transform:FindDeepChild("GetCoinsRewardAni").gameObject
        self.m_textCoinsReward = self.m_getCoinsRewardGo.transform:FindDeepChild("CoinsRewardText"):GetComponent(typeof(TextMeshProUGUI))
        if self.m_textCoinsReward == nil then
            self.m_textCoinsReward = self.m_getCoinsRewardGo.transform:FindDeepChild("CoinsRewardText"):GetComponent(typeof(UnityUI.Text))
        end
        self.m_textCardName = self.transform:FindDeepChild("CardName"):GetComponent(typeof(TextMeshProUGUI))
        self.m_starContainer = self.transform:FindDeepChild("Star")
    end

    self.m_getCoinsRewardGo:SetActive(false)
    self.m_finalEffectGo:SetActive(false)
    self.mSpinBtn.interactable = true
    self:RefreshInitView()
    local name = SlotsCardsHandler:getCardName(albumKey, cardKey)
    self.m_textCardName.text = name
    local starCount = SlotsCardsHandler:getCardStarCount(albumKey, cardKey)
    for i = 0, 4 do
        self.m_starContainer:GetChild(i).gameObject:SetActive(i<=(starCount-1))
    end
    self.mSpinBtn.gameObject:SetActive(true)
    ViewScaleAni:Show(self.transform.gameObject)
end

function FrenzySpinGamePop:GetJackPotRandomIndex()
    return LuaHelper.GetIndexByRate(SlotsCardsAllProbTable.frenzySpinGameProb)
end

function FrenzySpinGamePop:initFrenzySpinCoinValue()
    local probs = {180, 160, 150, 120, 50, 20}
    local Coefs = {0.25, 0.5, 0.75, 1.0, 1.25, 1.5}
    local index = LuaHelper.GetIndexByRate(probs)
    local fcoef = Coefs[index]
    local nBasePrize = SlotsCardsHandler:getBaseTB()
    local nPrize = nBasePrize * fcoef
    
    -- self.albumKey, self.themeKey, self.cardKey
    local albumParam = SlotsCardsHandler.data.activityData[self.albumKey]
    local cardParam = albumParam.m_mapCardsInfo[self.cardKey]
    local nStar = cardParam.starCount
    local fMulti = 1.0
    if nStar <= 2 then
        fMulti = nStar *1.5
    else
        fMulti = nStar *2.0
    end
    
    nPrize = nPrize * fMulti
    nPrize = math.floor( nPrize )
    nPrize = MoneyFormatHelper.normalizeCoinCount(nPrize, 3)
    
    return nPrize
end

function FrenzySpinGamePop:updateTargetGift()
    local target = self.nTargetJackPotIndex
    
    --特殊处理，如果获得万能卡，万能卡已经有一张且没有消耗，则不给他万能卡
    if target == 4 then
        if SlotsCardsHandler.data.activityData.m_nStampBonusCount < 1 and not SlotsCardsHandler.data.activityData[SlotsCardsManager.album].bIsGetCompletedGift then
            SlotsCardsHandler:addStampBonus(1)
        else
            self.nTargetJackPotIndex = math.random( 1, 3 )
            target = self.nTargetJackPotIndex
        end 
    end
    self.m_nCoinPrize = self:initFrenzySpinCoinValue()
    
    --1: Coins, 2: CoinRespin, 3:StampPack, 4:WildCard
    if target == 1 then
        PlayerHandler:AddCoin(self.m_nCoinPrize)--根据当前玩家等级获取相应金币
    elseif target == 2 then
        PlayerHandler:AddCoin(self.m_nCoinPrize)
        --在获取一次respin机会
        SlotsCardsHandler:addFrenzyGame(self.albumKey, self.themeKey)
    elseif target == 3 then
        --Pack 礼包
        self.m_packInfo = SlotsCardsGiftManager:getPackInFrenzySpinGame()
    end
end

function FrenzySpinGamePop:Hide()
    for i = 1, self.N_ROW_COUNT * 2 do
        self:RecycleWheelItem(self.mListGoWheelItem[i])
    end

    self.mListGoWheelItem = {}
    self.mListJackPotIds = {}
    ViewScaleAni:Hide(self.transform.gameObject, function()
        Unity.Object.Destroy(self.transform.gameObject)
    end)
end

function FrenzySpinGamePop:OnDestroy()
    self.WheelItemPool = {}
    self.WheelItemPoolParent = nil
    self.mRotateRootTran = nil
    
    self.mListWheelItemPos = {}
    if SlotsCardsMainUIPop.transform.gameObject.activeInHierarchy then
        SlotsCardsAudioHandler:PlayBackMusic("stamp_music")
    end

end

function FrenzySpinGamePop:GetWheelItem(nTargetJackPotIndex)
    local goItem = nil
    if nTargetJackPotIndex == 1 then
        goItem = table.remove(self.WheelItemPool["Coins"])
    elseif nTargetJackPotIndex == 2 then
        goItem = table.remove(self.WheelItemPool["CoinRespin"])
    elseif nTargetJackPotIndex == 3 then
        goItem = table.remove(self.WheelItemPool["StampPack"])
    elseif nTargetJackPotIndex == 4 then
        goItem = table.remove(self.WheelItemPool["WildCard"])
    end

    -- assert(goItem, "nTargetJackPotIndex: "..nTargetJackPotIndex)
    goItem.gameObject:SetActive(true)
    return goItem
end

function FrenzySpinGamePop:RecycleWheelItem(goItem)
    goItem.gameObject:SetActive(false)
    if string.match(goItem.name, "Coins") then
        table.insert(self.WheelItemPool["Coins"], goItem)
    elseif string.match(goItem.name, "CoinRespin") then
        table.insert(self.WheelItemPool["CoinRespin"], goItem)
    elseif string.match(goItem.name, "StampPack") then
        table.insert(self.WheelItemPool["StampPack"], goItem)
    elseif string.match(goItem.name, "WildCard") then
        table.insert(self.WheelItemPool["WildCard"], goItem)
    else
        assert(false)
    end

    goItem.transform:SetParent(self.WheelItemPoolParent, false)
    goItem.transform.localPosition = Unity.Vector3.zero

end

function FrenzySpinGamePop:LoadWheelItemPool()
    self.WheelItemPool = {}
    self.WheelItemPoolParent = self.transform:FindDeepChild("WheelItemPoolParent")

    local LoadAssetNameList = {"Coins", "CoinRespin", "StampPack", "WildCard"} 
    for k, v in pairs(LoadAssetNameList) do
        local assetName = v
        local assetPath = "FrenzySpinGame/"..assetName..".prefab"

        local goPrefab = AssetBundleHandler:LoadSlotsCardsAsset(assetPath)

        local tempTable = {}
        for i = 1, 10 do
            local obj = Unity.Object.Instantiate(goPrefab)
            obj.transform:SetParent(self.WheelItemPoolParent, false)
            obj.transform.localPosition = Unity.Vector3.zero
            local reward = obj.transform:FindDeepChild("Reward")
            if reward ~= nil then
                local rewardText = reward:GetComponent(typeof(TextMeshProUGUI))
                rewardText.text = MoneyFormatHelper.numWithCommas(self:initFrenzySpinCoinValue())
            end
            obj:SetActive(false)
            
            table.insert(tempTable, obj)
        end

        self.WheelItemPool[assetName] = tempTable
    end

end

function FrenzySpinGamePop:RefreshInitView()
    for i = 1, self.N_ROW_COUNT * 2 do
        local nTargetJackPotIndex = LuaHelper.GetIndexByRate(SlotsCardsAllProbTable.frenzySpinGameProb)
        local goItem = self:GetWheelItem(nTargetJackPotIndex)
        goItem.transform:SetParent(self.mRotateRootTran, false)
        goItem.transform.localPosition = self.mListWheelItemPos[i]
        goItem.transform.localScale = Unity.Vector3.one
        self.mListJackPotIds[i] = nTargetJackPotIndex
        self.mListGoWheelItem[i] = goItem
    end

end

function FrenzySpinGamePop:PlayRotateAni(fTargetRotateDistanceY, bAni, tweenType, fTime)
    self.m_finalEffectGo:SetActive(false)
    --消耗一次玩的机会
    local count = SlotsCardsHandler.data.activityData[self.themeKey].nGoldSpinGameCount
    SlotsCardsHandler.data.activityData[self.themeKey].nGoldSpinGameCount = count - 1
    SlotsCardsHandler:SaveDb()

    self.m_getCoinsRewardGo:SetActive(false)
    self.nTargetJackPotIndex = self:GetJackPotRandomIndex()
    self.m_spinEffectGo:SetActive(true)
    --更新数据
    self:updateTargetGift()

    --刷新button按钮事件
    SlotsCardsMainUIPop:refresh()
    SlotsCardsBookPop:refreshThemeUI(self.themeKey)

    local fMoveDistance = 0.0
    local fFrameDistance = 0.0
    
    local fTime = fTime or 7.8
    local tweenType = tweenType or LeanTweenType.easeInOutQuad
    local bAni = bAni or false
    local fTargetRotateDistanceY = fTargetRotateDistanceY or -self.fWheelItemHight * 40
    local fStartPosY = self.mRotateRootTran.localPosition.y

    local nStartDeckOffset = 0

    LeanTween.moveLocalY(self.mRotateRootTran.gameObject, fTargetRotateDistanceY, fTime):setEase(tweenType):setOnUpdate(function()
        fFrameDistance =  math.abs(self.mRotateRootTran.localPosition.y - fStartPosY)
        fStartPosY = self.mRotateRootTran.localPosition.y
        fMoveDistance = fMoveDistance + fFrameDistance --移动距离
        
        while fMoveDistance >= self.fWheelItemHight do
            fMoveDistance = fMoveDistance - self.fWheelItemHight
            SlotsCardsAudioHandler:PlaySound("golden_wheel_tick")

            local fDis = math.abs(self.mRotateRootTran.localPosition.y - fTargetRotateDistanceY)
            if fDis <= self.fWheelItemHight * 6 then
                if nStartDeckOffset == 0 then
                    local nTargetJackPotIndex = self.nTargetJackPotIndex
                    self:SymbolShiftDown(nTargetJackPotIndex, nStartDeckOffset)
                    nStartDeckOffset  = nStartDeckOffset + 1
                else
                    self:SymbolShiftDown(self:GetRandom())
                end
            else
                self:SymbolShiftDown(self:GetRandom())
            end
        end
    end):setOnComplete(function()
        self:resetReelSymbolsPos()
        self.mRotateRootTran.localPosition = Unity.Vector3.zero
        SlotsCardsAudioHandler:PlaySound("golden_wheel_stop")

        -- self.mSpinBtn.interactable = true
        -- Debug.Log(self.nTargetJackPotIndex)

        --数据已更新，这里只是做相应的UI操作
        local target = self.nTargetJackPotIndex
        --TODO 显示获得粒子特效
        self.m_spinEffectGo:SetActive(false)
        -- self.m_GlowEffectAni:SetInteger("nPlayMode", 1)
        if target == 1 or target == 2 then
            self.m_finalEffectGo:SetActive(true)
        end
        LeanTween.delayedCall(2, function()
            --1: Coins, 2: CoinRespin, 3:StampPack, 4:WildCard
            if target == 1 then
                SlotsCardsAudioHandler:PlaySound("golden_win_pop_up")
                self.m_textCoinsReward.text = MoneyFormatHelper.numWithCommas(self.m_nCoinPrize)
                self.m_getCoinsRewardGo:SetActive(true)
                LeanTween.delayedCall(2, function()
                    CoinFly:fly(self.m_textCoinsReward.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 6, true)
                end)
                LeanTween.delayedCall(3, function()
                    self:Hide()
                end)
            elseif target == 2 then
                SlotsCardsAudioHandler:PlaySound("golden_win_pop_up")
                local ftime = 4
                self.m_textCoinsReward.text = MoneyFormatHelper.numWithCommas(self.m_nCoinPrize)
                self.m_getCoinsRewardGo:SetActive(true)
                -- self.m_GlowEffectAni:SetInteger("nPlayMode", 0)
                LeanTween.delayedCall(3, function()
                    CoinFly:fly(self.m_textCoinsReward.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 6, true)
                end)
                LeanTween.delayedCall(ftime, function()
                    self.mSpinBtn.interactable = true
                    self.m_getCoinsRewardGo:SetActive(false)
                end)
            elseif target == 3 then
                self:Hide()
                -- 显示获取礼包盒弹窗
                SlotsCardsGetPackPop:Show(self.m_packInfo.packType, true, self.m_packInfo.packCount)
            elseif target == 4 then
                self:Hide()
                -- 显示获得卡牌动画
                EventHandler:Brocast("ShowBonusStampPop")
            end
        end)
    end)
end

function FrenzySpinGamePop:resetReelSymbolsPos()
    local nTotalNum = self.N_ROW_COUNT * 2
    for y = 1, nTotalNum do
        local go = self.mListGoWheelItem[y]
        go.transform.localPosition = self.mListWheelItemPos[y]
    end
end

function FrenzySpinGamePop:GetRandom()
    return  LuaHelper.GetIndexByRate(SlotsCardsAllProbTable.frenzySpinGameRandomProb)
end

function FrenzySpinGamePop:SymbolShiftDown(newJackPotIndex, nStartDeckOffset)
    local nTotalNum = self.N_ROW_COUNT * 2
    for y = 1, nTotalNum do
        if y == 1 then
            self:RecycleWheelItem(self.mListGoWheelItem[1])
        end

        if y == nTotalNum then
            self:SetSymbol(y, newJackPotIndex, nStartDeckOffset)
        else
            self.mListGoWheelItem[y] = self.mListGoWheelItem[y + 1]
			self.mListJackPotIds[y] = self.mListJackPotIds[y + 1]
        end
    end
    
end

function FrenzySpinGamePop:SetSymbol(y, nTargetJackPotIndex, nStartDeckOffset)
    local newGoItem = self:GetWheelItem(nTargetJackPotIndex)
    newGoItem.transform:SetParent(self.mRotateRootTran, false)
    newGoItem.transform.localScale = Unity.Vector3.one
    local reward = newGoItem.transform:FindDeepChild("Reward")
    if reward ~= nil and nStartDeckOffset ~= nil then
        local rewardText = reward:GetComponent(typeof(TextMeshProUGUI))
        rewardText.text = MoneyFormatHelper.numWithCommas(self.m_nCoinPrize)
    end
    local prePos = self.mListGoWheelItem[y - 1].transform.localPosition
    local targetYPos = prePos.y + self.fWheelItemHight
    newGoItem.transform.localPosition = Unity.Vector3(0, targetYPos, 0)

    self.mListGoWheelItem[y] = newGoItem
    self.mListJackPotIds[y] = nTargetJackPotIndex
end