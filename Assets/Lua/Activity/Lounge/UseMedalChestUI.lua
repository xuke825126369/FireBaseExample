UseMedalChestUI = {}
UseMedalChestUI.m_bInitFlag = false
UseMedalChestUI.m_listNeedSkipLeantweenID = {}
UseMedalChestUI.m_bSkipFlag = false -- 玩家点了skip的情况
UseMedalChestUI.m_fFullProgressTime = 7.0 -- 从头到尾走一次进度条的时间
UseMedalChestUI.m_coLevelUpAni = nil -- 使用chest过程的动画协程

function UseMedalChestUI:Show(nIndex)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local strPath = "UseMedalChestUI.prefab"
        local prefabObj = AssetBundleHandler:LoadGoldenLoungeAsset(strPath)
        local go = Unity.Object.Instantiate(prefabObj)
        self.transform = go.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)

        self.m_trContent = self.transform:FindDeepChild("Content")
        local btnSkip = self.transform:FindDeepChild("BtnSkip"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnSkip)
        btnSkip.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnBtnSkipClicked(btnSkip)
        end)
        self.btnSkip = btnSkip

        local tr = self.transform:FindDeepChild("LengendaryNode")
        self.goLengendaryNode = tr.gameObject
        self.goLengendaryNode:SetActive(false)
        self.imageLengendaryProgress = tr:FindDeepChild("imageLengendaryProgress"):GetComponent(typeof(UnityUI.Image))
        self.TextMeshProLengendaryProgress = tr:FindDeepChild("TextMeshProLengendaryProgress"):GetComponent(typeof(TextMeshProUGUI))
        self.goLevelUpMedalEffectNode = self.transform:FindDeepChild("LevelUpMedalEffectNode").gameObject

        self:initUI()
        self:initUIChestNodes()
        self:initUnlockHeroEffectNodes()
    end

    ViewAlphaAni:Show(self.transform.gameObject)
    for i = 1, 4 do
        self.m_listChestNodes[i]:SetActive(i == nIndex)
    end
    for i = 1, 8 do
        self.m_listMedalInfoNodes[i].goNode:SetActive(false)
    end

    self.m_bSkipFlag = false
    self.btnSkip.interactable = false
    self.goLengendaryNode:SetActive(false)
    self.m_listNeedSkipLeantweenID = {}
    self.goLevelUpMedalEffectNode:SetActive(false)
    LeanTween.delayedCall(2.5, function()
        self.goLevelUpMedalEffectNode:SetActive(true) 
        self:StartLevelUpCoroutine()
        self.btnSkip.interactable = true
    end)
    LoungeAudioHandler:PlaySound("openChest")

end

--
function UseMedalChestUI:StartLevelUpCoroutine()
    if self.m_coLevelUpAni ~= nil then
        return
    end

    self.m_coLevelUpAni = StartCoroutine(function()
        self:playLevelUpAni()
        self.m_coLevelUpAni = nil
    end)
end

function UseMedalChestUI:playLevelUpAni()
    local listMedalIndex = {} -- 需要展示的medal
    for i=1, 8 do
        local nPoints = MedalMasterMainUI.listDistributionLoungePoints[i]
        if nPoints > 0 then
            table.insert(listMedalIndex, i)
        end
    end

    local nIndex = 1
    local cnt = #listMedalIndex
    for i = 1, cnt do
        nIndex = listMedalIndex[i]

        local nStarPre, fProgressPre, nPlayerExpPre, nCurLevelExpPre = self:InitMedalLevelParam(nIndex)
        local nStar, fProgress, nPlayerExp, nCurLevelExp = LoungeConfig:getMedalLevelInfo(nIndex)
        local preParam = {nStarPre = nStarPre, fProgressPre = fProgressPre, nPlayerExpPre = nPlayerExpPre, nCurLevelExpPre = nCurLevelExpPre}
        local curParam = {nStar = nStar, fProgress = fProgress, nPlayerExp = nPlayerExp, nCurLevelExp = nCurLevelExp}

        if nStar == nStarPre then 
            if nStarPre == 5 then
                self:playLengendaryLevelUpAni(nIndex)
            else
                self:playMedalLevelUpAni0(preParam, curParam, nIndex)
            end
        elseif nStar == nStarPre +1 then
            self:playMedalLevelUpAni1(preParam, curParam, nIndex)
        elseif nStar == nStarPre +2 then
            self:playMedalLevelUpAni2(preParam, curParam, nIndex)
        elseif nStar == nStarPre +3 then
            self:playMedalLevelUpAni3(preParam, curParam, nIndex)
        elseif nStar == nStarPre +4 then
            self:playMedalLevelUpAni4(preParam, curParam, nIndex)
        elseif nStar == nStarPre +5 then
            self:playMedalLevelUpAni5(preParam, curParam, nIndex)
        end

        yield_return(Unity.WaitForSeconds(1.0))
    end

    self:LevelUpAniEnd(nIndex)
end
--

function UseMedalChestUI:LevelUpAniEnd(nIndex)
    if nIndex ~= nil then
        self.m_listMedalInfoNodes[nIndex].goNode:SetActive(false)
    else
        for i=1, 8 do
            self.m_listMedalInfoNodes[i].goNode:SetActive(false)
            self.m_listMedalInfoNodes[i].goLevelUpRewardNode:SetActive(false)
            local listGoStars = self.m_listMedalInfoNodes[i].listGoStars
            for j=1, 5 do
                listGoStars[j]:SetActive(false)
            end
        end
    end

    for i = 1, 5 do
        self.m_listUnlockHeroEffectNodes[i]:SetActive(false)
    end

    self:Hide()
    MedalMasterMainUI:RefreshUI()
    MedalMasterMainUI:CheckGrandPrizeClaim() -- 动画做完之后调用
    LevelUpResultUI:Show()
end

function UseMedalChestUI:playLengendaryLevelUpAni(nIndex)
    local data = LoungeHandler.data.activityData.listMedalMasterData
    local nPoints = MedalMasterMainUI.listDistributionLoungePoints[nIndex]
    local fExp = data.listMedalExp[nIndex]
    fExp = fExp - nPoints
    
    local bFullPre, fLengendaryProgressPre = LoungeConfig:getLengendaryProgressByExp(nIndex, fExp)
    local bFull, fLengendaryProgress = LoungeConfig:getLengendaryProgress(nIndex)

    local fFullTime = 5.0
    local fTime = (fLengendaryProgress - fLengendaryProgressPre) * fFullTime
    if fTime < 2.0 then
        fTime = 2.0
    end

    local id = LeanTween.value(fLengendaryProgressPre, fLengendaryProgress, fTime):setOnUpdate(function(value)
        self.imageLengendaryProgress.fillAmount = value
    end).id
    table.insert(self.m_listNeedSkipLeantweenID, id)

    local id = LeanTween.value(fLengendaryProgressPre, fLengendaryProgress, fTime):setOnUpdate(function(value)
        local strInfo = math.floor(value * 100) .. "%"
        self.TextMeshProLengendaryProgress.text = strInfo
    end).id
    table.insert(self.m_listNeedSkipLeantweenID, id)

    yield_return(Unity.WaitForSeconds(fTime))
end

function UseMedalChestUI:playMedalLevelUpAni0(preParam, curParam, nIndex)
    local nStarPre = preParam.nStarPre
    local fProgressPre = preParam.fProgressPre
    local nPlayerExpPre = preParam.nPlayerExpPre
    local nCurLevelExpPre = preParam.nCurLevelExpPre

    local nStar = curParam.nStar
    local fProgress = curParam.fProgress
    local nPlayerExp = curParam.nPlayerExp
    local nCurLevelExp = curParam.nCurLevelExp

    local fTime = (fProgress - fProgressPre) * self.m_fFullProgressTime
            
    if fTime < 2.0 then
        fTime = 2.0
    end

    local id = LeanTween.value(fProgressPre, fProgress, fTime):setOnUpdate(function(value)
        self.m_listMedalInfoNodes[nIndex].imageProgress.fillAmount = value
    end).id
    table.insert(self.m_listNeedSkipLeantweenID, id)

    local id = LeanTween.value(nPlayerExpPre, nPlayerExp, fTime):setOnUpdate(function(value)
        local str = math.floor(value) .. "/" .. nCurLevelExp
        self.m_listMedalInfoNodes[nIndex].TextMeshProCurChestPointProgress.text = str
    end).id
    table.insert(self.m_listNeedSkipLeantweenID, id)

    yield_return(Unity.WaitForSeconds(fTime))
end

function UseMedalChestUI:playMedalLevelUpAni1(preParam, curParam, nIndex)
    local nStarPre = preParam.nStarPre
    local fProgressPre = preParam.fProgressPre
    local nPlayerExpPre = preParam.nPlayerExpPre
    local nCurLevelExpPre = preParam.nCurLevelExpPre

    local nStar = curParam.nStar
    local fProgress = curParam.fProgress
    local nPlayerExp = curParam.nPlayerExp
    local nCurLevelExp = curParam.nCurLevelExp

    self:ShowMedalUpgradeHead(nIndex, preParam)
    
    self.m_listMedalInfoNodes[nIndex].listGoStars[nStar]:SetActive(true)
    self:ShowMedalUpgradeTail(nIndex, nStar, curParam)

    local listHeroStar = {nStar}
    self:UnlockHeros(nIndex, listHeroStar)

    self:ShowLevelUpRewardInfo(nIndex)
end

function UseMedalChestUI:playMedalLevelUpAni2(preParam, curParam, nIndex)
    local nStarPre = preParam.nStarPre
    local fProgressPre = preParam.fProgressPre
    local nPlayerExpPre = preParam.nPlayerExpPre
    local nCurLevelExpPre = preParam.nCurLevelExpPre

    local nStar = curParam.nStar
    local fProgress = curParam.fProgress
    local nPlayerExp = curParam.nPlayerExp
    local nCurLevelExp = curParam.nCurLevelExp

    self:ShowMedalUpgradeHead(nIndex, preParam)

    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 1]:SetActive(true)
    self:ShowMedalUpgradeFullLevel(nIndex, nStarPre + 2)

    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 2]:SetActive(true)
    self:ShowMedalUpgradeTail(nIndex, nStarPre + 2, curParam)

    local listHeroStar = {nStarPre + 1, nStarPre + 2}
    self:UnlockHeros(nIndex, listHeroStar)

    self:ShowLevelUpRewardInfo(nIndex)
end

function UseMedalChestUI:playMedalLevelUpAni3(preParam, curParam, nIndex)
    local nStarPre = preParam.nStarPre
    local fProgressPre = preParam.fProgressPre
    local nPlayerExpPre = preParam.nPlayerExpPre
    local nCurLevelExpPre = preParam.nCurLevelExpPre

    local nStar = curParam.nStar
    local fProgress = curParam.fProgress
    local nPlayerExp = curParam.nPlayerExp
    local nCurLevelExp = curParam.nCurLevelExp

    self:ShowMedalUpgradeHead(nIndex, preParam)

    -- 上面走完一颗星了 下面开始走第二颗
    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 1]:SetActive(true)
    self:ShowMedalUpgradeFullLevel(nIndex, nStarPre + 2)

    -- 走完第二颗星了 下面开始第三颗星。。
    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 2]:SetActive(true)
    self:ShowMedalUpgradeFullLevel(nIndex, nStarPre + 3)

    -- 走完第三颗星了 下面开始剩余部分。。
    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 3]:SetActive(true)
    self:ShowMedalUpgradeTail(nIndex, nStarPre + 3, curParam)

    -- 上面走完进度条了 开始激活新解锁的英雄
    local listHeroStar = {nStarPre + 1, nStarPre + 2, nStarPre + 3}
    self:UnlockHeros(nIndex, listHeroStar)

    -- 开始展示升级获得的金币 以及更新金币UI
    self:ShowLevelUpRewardInfo(nIndex)
    
end

-- nStar == nStarPre +4
function UseMedalChestUI:playMedalLevelUpAni4(preParam, curParam, nIndex)
    local nStarPre = preParam.nStarPre
    local fProgressPre = preParam.fProgressPre
    local nPlayerExpPre = preParam.nPlayerExpPre
    local nCurLevelExpPre = preParam.nCurLevelExpPre

    local nStar = curParam.nStar
    local fProgress = curParam.fProgress
    local nPlayerExp = curParam.nPlayerExp
    local nCurLevelExp = curParam.nCurLevelExp

    self:ShowMedalUpgradeHead(nIndex, preParam)

    -- 上面走完一颗星了 下面开始走第二颗
    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 1]:SetActive(true)
    self:ShowMedalUpgradeFullLevel(nIndex, nStarPre + 2)

    -- 走完第二颗星了 下面开始第三颗星。。
    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 2]:SetActive(true)
    self:ShowMedalUpgradeFullLevel(nIndex, nStarPre + 3)

    -- 走完第三颗星了 下面开始第四颗星。。
    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 3]:SetActive(true)
    self:ShowMedalUpgradeFullLevel(nIndex, nStarPre + 4)

    -- 走完第四颗星了 下面开始剩余部分。。
    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 4]:SetActive(true)
    self:ShowMedalUpgradeTail(nIndex, nStarPre + 4, curParam)

    -- 上面走完进度条了 开始激活新解锁的英雄
    local listHeroStar = {nStarPre + 1, nStarPre + 2, nStarPre + 3, nStarPre + 4}
    self:UnlockHeros(nIndex, listHeroStar)

    -- 开始展示升级获得的金币 以及更新金币UI
    self:ShowLevelUpRewardInfo(nIndex)
end

-- nStar == nStarPre +5
-- 这个方法里不会出现超过5级的部分 当做加点刚好到5级来展示
function UseMedalChestUI:playMedalLevelUpAni5(preParam, curParam, nIndex)
    local nStarPre = preParam.nStarPre
    local fProgressPre = preParam.fProgressPre
    local nPlayerExpPre = preParam.nPlayerExpPre
    local nCurLevelExpPre = preParam.nCurLevelExpPre

    local nStar = curParam.nStar
    local fProgress = curParam.fProgress
    local nPlayerExp = curParam.nPlayerExp
    local nCurLevelExp = curParam.nCurLevelExp

    -- 1. 先到第一个100%
    -- 2. 到第二个100% -- nStarPre+1 - 2 的过程
    -- 3. 到第三个100% -- 2 - 3的过程
    -- 4. 到第四个100% -- 3 - 4的过程
    -- 5. 到第五个100% -- 4 - 5的过程
    
    self:ShowMedalUpgradeHead(nIndex, preParam)

    -- 上面走完一颗星了 下面开始走第二颗
    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 1]:SetActive(true)
    self:ShowMedalUpgradeFullLevel(nIndex, nStarPre + 2)

    -- 走完第二颗星了 下面开始第三颗星。。
    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 2]:SetActive(true)
    self:ShowMedalUpgradeFullLevel(nIndex, nStarPre + 3)

    -- 走完第三颗星了 下面开始第四颗星。。
    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 3]:SetActive(true)
    self:ShowMedalUpgradeFullLevel(nIndex, nStarPre + 4)
    
    -- 走完第四颗星了 下面开始第五颗星。。
    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 4]:SetActive(true)
    self:ShowMedalUpgradeFullLevel(nIndex, nStarPre + 5)

    -- 走完第五颗星了 没有剩余部分。。
    self.m_listMedalInfoNodes[nIndex].listGoStars[nStarPre + 5]:SetActive(true)
    
    -- 上面走完进度条了 开始激活新解锁的英雄
    local listHeroStar = {nStarPre + 1, nStarPre + 2, nStarPre + 3, nStarPre + 4, nStarPre + 5}
    self:UnlockHeros(nIndex, listHeroStar)

    -- 开始展示升级获得的金币 以及更新金币UI
    self:ShowLevelUpRewardInfo(nIndex)
end

-- 从头到尾升一级的过程..
function UseMedalChestUI:ShowMedalUpgradeFullLevel(nIndex, nStarStage)
    -- nStarStage - 1 到 nStarStage 的升级过程展示
    local nExp1 = LoungeConfig:getMedalExpByLevel(nIndex, nStarStage)
    local fTime = self.m_fFullProgressTime
    local id = LeanTween.value(0.0, 1.0, fTime):setOnUpdate(function(value)
        self.m_listMedalInfoNodes[nIndex].imageProgress.fillAmount = value
    end).id
    table.insert(self.m_listNeedSkipLeantweenID, id)
    
    local id = LeanTween.value(0, nExp1, fTime):setOnUpdate(function(value)
        local str = math.floor(value) .. "/" .. nExp1
        self.m_listMedalInfoNodes[nIndex].TextMeshProCurChestPointProgress.text = str
    end).id
    table.insert(self.m_listNeedSkipLeantweenID, id)

    yield_return(Unity.WaitForSeconds(fTime))
end

-- nStarStage 多出来的一段进度条 但是又还没有到达下一级的这个过程
function UseMedalChestUI:ShowMedalUpgradeTail(nIndex, nStarStage, curParam)
    if nStarStage >= 5 then
        return
    end
    
    local nStar = curParam.nStar
    local fProgress = curParam.fProgress
    local nPlayerExp = curParam.nPlayerExp
    local nCurLevelExp = curParam.nCurLevelExp
    
    local fTime = fProgress * self.m_fFullProgressTime
        
    if fTime < 2.0 then
        fTime = 2.0
    end

    local id = LeanTween.value(0.0, fProgress, fTime):setOnUpdate(function(value)
        self.m_listMedalInfoNodes[nIndex].imageProgress.fillAmount = value
    end).id
    table.insert(self.m_listNeedSkipLeantweenID, id)
    
    local id = LeanTween.value(0, nPlayerExp, fTime):setOnUpdate(function(value)
        local str = math.floor(value) .. "/" .. nCurLevelExp
        self.m_listMedalInfoNodes[nIndex].TextMeshProCurChestPointProgress.text = str
    end).id
    table.insert(self.m_listNeedSkipLeantweenID, id)

    yield_return(Unity.WaitForSeconds(fTime))
    -- 走完剩余部分了
end

-- nStarPre 到 nStarPre +1 的过程
function UseMedalChestUI:ShowMedalUpgradeHead(nIndex, preParam)
    local nStarPre = preParam.nStarPre
    local fProgressPre = preParam.fProgressPre
    local nPlayerExpPre = preParam.nPlayerExpPre
    local nCurLevelExpPre = preParam.nCurLevelExpPre

    local fTime = (1.0 - fProgressPre) * self.m_fFullProgressTime
    
    if fTime < 2.0 then
        fTime = 2.0
    end

    local id = LeanTween.value(fProgressPre, 1.0, fTime):setOnUpdate(function(value)
        self.m_listMedalInfoNodes[nIndex].imageProgress.fillAmount = value
    end).id
    table.insert(self.m_listNeedSkipLeantweenID, id)
    
    local id = LeanTween.value(nPlayerExpPre, nCurLevelExpPre, fTime):setOnUpdate(function(value)
        local str = math.floor(value) .. "/" .. nCurLevelExpPre
        self.m_listMedalInfoNodes[nIndex].TextMeshProCurChestPointProgress.text = str
    end).id
    table.insert(self.m_listNeedSkipLeantweenID, id)
    
    yield_return(Unity.WaitForSeconds(fTime))
end

function UseMedalChestUI:UnlockHeros(nIndex, listHeroStar)
    local cnt = #listHeroStar
    local fTime = 2.5
    
    for i=1, cnt do
        local star = listHeroStar[i]
        
        self.m_listUnlockHeroEffectNodes[star]:SetActive(true)
        local id = LeanTween.delayedCall(2.5, function()
            self.m_listUnlockHeroEffectNodes[star]:SetActive(false)
        end).id
        table.insert(self.m_listNeedSkipLeantweenID, id)
        
        local id = LeanTween.delayedCall(1.2, function()
            LoungeAudioHandler:PlaySound("item_levelup")
            self.m_listMedalInfoNodes[nIndex].listGoMedalLogos[star]:SetActive(true)
        end).id
        table.insert(self.m_listNeedSkipLeantweenID, id)
        
        yield_return(Unity.WaitForSeconds(fTime))
    end
end

function UseMedalChestUI:ShowLevelUpRewardInfo(nIndex)
    local fTime = 5.0
    self.m_listMedalInfoNodes[nIndex].goLevelUpRewardNode:SetActive(true)

    local nPrize = MedalMasterMainUI.listLevelUpRewardCoins[nIndex]
    local strPrize = MoneyFormatHelper.numWithCommas(nPrize)
    self.m_listMedalInfoNodes[nIndex].TextLevelUpRewardCoins.text = strPrize

    -- 所有徽章的奖励都已经加给玩家了只是没有更新左上角 这里需要分段更新左上角的显示
    local nTargetCoin = 0
    local nTotalCoins = PlayerHandler.nGoldCount
    local nSumCoins = 0
    if nIndex < 8 then
        for i=nIndex+1, 8 do
            nSumCoins = nSumCoins + MedalMasterMainUI.listLevelUpRewardCoins[i]
        end
    end
    nTargetCoin = nTotalCoins - nSumCoins

    LobbyView:UpCoinsCanvasLayer()
    local posStart = self.m_listMedalInfoNodes[nIndex].TextLevelUpRewardCoins.transform.position
    CoinFly:fly(posStart, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12)
    yield_return(Unity.WaitForSeconds(fTime))
    LobbyView:DownCoinsCanvasLayer()
    -- 升级奖励金币值动画结束了
end

function UseMedalChestUI:initUIChestNodes()
    local listNames = {"CommonNode", "RareNode", "EpicNode", "LengendaryChestNode"}
    
    self.m_listChestNodes = {}
    for i=1, 4 do
        local strName = listNames[i]
        local goChestNode = self.transform:FindDeepChild(strName).gameObject
        goChestNode:SetActive(false)
        self.m_listChestNodes[i] = goChestNode
    end

end

function UseMedalChestUI:initUnlockHeroEffectNodes()
    local listNames = {"UnlockHeroEffect1", "UnlockHeroEffect2", "UnlockHeroEffect3",
                        "UnlockHeroEffect4", "UnlockHeroEffect5"}
    
    self.m_listUnlockHeroEffectNodes = {}
    for i=1, 5 do
        local strName = listNames[i]
        local goEffectNode = self.transform:FindDeepChild(strName).gameObject
        goEffectNode:SetActive(false)
        self.m_listUnlockHeroEffectNodes[i] = goEffectNode
    end

end

function UseMedalChestUI:OnBtnSkipClicked(btnSkip)
    self:Hide()

    btnSkip.interactable = false
    LeanTween.delayedCall(1.5, function()
        btnSkip.interactable = true
    end)
    
    EventHandler:Brocast("UpdateMyInfo")
	local count = #self.m_listNeedSkipLeantweenID
	for i = 1, count do
		local id = self.m_listNeedSkipLeantweenID[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
    self.m_listNeedSkipLeantweenID = {}

    self.m_bSkipFlag = true
	StopCoroutine(self.m_coLevelUpAni) -- 停掉动画协程
    self:LevelUpAniEnd()
    self.m_coLevelUpAni = nil

end

function UseMedalChestUI:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end

    return true
end

function UseMedalChestUI:initUI()
    local listNames = {"PlatinumUI1", "PlatinumUI2", "PlatinumUI3", "RoyalUI1", "RoyalUI2", "RoyalUI3", "MasterUI1", "MasterUI2"}

    self.m_listMedalInfoNodes = {}
    for i = 1, 8 do
        local tr = self.transform:FindDeepChild(listNames[i])
        local goNode = tr.gameObject
        goNode:SetActive(false)
        local imageProgress = tr:FindDeepChild("imageProgress"):GetComponent(typeof(UnityUI.Image))
        local TextMeshProName = tr:FindDeepChild("TextMeshProName"):GetComponent(typeof(TextMeshProUGUI))
        local TextMeshProCurChestPointProgress = tr:FindDeepChild("TextMeshProCurChestPointProgress"):GetComponent(typeof(TextMeshProUGUI))
    
        local listGoStars = {}
        for nStarIndex=1, 5 do
            local name = "StarNode" .. nStarIndex
            local trStarNode = tr:FindDeepChild(name)
            local goStar = trStarNode:FindDeepChild("imageStar").gameObject
            table.insert(listGoStars, goStar)
        end

        local listGoMedalLogos = {}
        for i=1, 5 do
            local name = "MedalStar" .. i
            local goMedalLogo = tr:FindDeepChild(name).gameObject
            table.insert(listGoMedalLogos, goMedalLogo)
        end

        local goProgressNode = tr:FindDeepChild("ProgressNode").gameObject
        local goMedalCompleted = tr:FindDeepChild("MedalCompleted").gameObject

        local goLevelUpRewardNode = tr:FindDeepChild("LevelUpRewardNode").gameObject
        local TextLevelUpRewardCoins = tr:FindDeepChild("TextLevelUpRewardCoins"):GetComponent(typeof(UnityUI.Text))
        
        local nodes = { goNode = goNode,
            imageProgress = imageProgress, TextMeshProName = TextMeshProName, 
            TextMeshProCurChestPointProgress = TextMeshProCurChestPointProgress,
            listGoStars = listGoStars, listGoMedalLogos = listGoMedalLogos,
            goProgressNode = goProgressNode, goMedalCompleted = goMedalCompleted,
            goLevelUpRewardNode = goLevelUpRewardNode, 
            TextLevelUpRewardCoins = TextLevelUpRewardCoins,
        }

        table.insert(self.m_listMedalInfoNodes, nodes)
    end

end

function UseMedalChestUI:initUIAllMedalLogos()
    self.m_listMedalLogos = {}
    for nLevel = 1, 8 do
        local nodes = {}
        for nStar = 1, 5 do
            local name = "Star" .. nStar .. "ElemLevel" .. nLevel
            local goLogo = self.transform:FindDeepChild(name).gameObject
            table.insert(nodes, goLogo)
            goLogo:SetActive(false)
        end
        table.insert(self.m_listMedalLogos, nodes)
    end
end

function UseMedalChestUI:InitMedalLevelParam(nIndex)
    for i = 1, 8 do
        self.m_listMedalInfoNodes[i].goNode:SetActive(false)
        self.m_listMedalInfoNodes[i].goLevelUpRewardNode:SetActive(false)
        local listGoStars = self.m_listMedalInfoNodes[i].listGoStars
        for j = 1, 5 do
            listGoStars[j]:SetActive(false)
        end
    end

    local data = LoungeHandler.data.activityData.listMedalMasterData
    local nPoints = MedalMasterMainUI.listDistributionLoungePoints[nIndex]
    local nPrize = MedalMasterMainUI.listLevelUpRewardCoins[nIndex]

    self.m_listMedalInfoNodes[nIndex].goNode:SetActive(true)
    self.m_listMedalInfoNodes[nIndex].TextMeshProName.text = LoungeConfig.listName[nIndex]

    local fExp = data.listMedalExp[nIndex]
    fExp = fExp - nPoints
    local nStar, fProgress, nPlayerExp, nCurLevelExp = LoungeConfig:getMedalLevelInfoByExp(nIndex, fExp)

    self.m_listMedalInfoNodes[nIndex].imageProgress.fillAmount = fProgress
    self.m_listMedalInfoNodes[nIndex].TextMeshProCurChestPointProgress.text = nPlayerExp .. "/" .. nCurLevelExp

    local bCompleteFlag = false
    if nStar == 5 then
        bCompleteFlag = true
    end

    self.m_listMedalInfoNodes[nIndex].goProgressNode:SetActive(not bCompleteFlag)
    self.m_listMedalInfoNodes[nIndex].goMedalCompleted:SetActive(bCompleteFlag)
    self.goLengendaryNode:SetActive(bCompleteFlag)
    if bCompleteFlag then
        local bFull, fLengendaryProgress = LoungeConfig:getLengendaryProgressByExp(nIndex, fExp)
        self.imageLengendaryProgress.fillAmount = fLengendaryProgress
        
        local strInfo = math.floor(fLengendaryProgress * 100) .. "%"
        self.TextMeshProLengendaryProgress.text = strInfo
    end

    for i = 1, 5 do
        self.m_listMedalInfoNodes[nIndex].listGoMedalLogos[i]:SetActive(i <= nStar)
        self.m_listMedalInfoNodes[nIndex].listGoStars[i]:SetActive(i <= nStar)
    end

    return nStar, fProgress, nPlayerExp, nCurLevelExp
end

function UseMedalChestUI:Hide()
    ViewAlphaAni:Hide(self.transform.gameObject)
end
