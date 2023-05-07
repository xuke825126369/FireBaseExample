BingoMainUIPop = {}

BingoMainUIPop.m_bIsAuto = false
BingoMainUIPop.m_bInSpin = false
BingoMainUIPop.m_bInStop = false
BingoMainUIPop.m_fSpinToAutoTime = 0
BingoMainUIPop.clickSpinZonebValid = false
BingoMainUIPop.m_bInSimulation = false

function BingoMainUIPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadActivityAsset("BingoMainUIPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        
        self.m_aniBall = self.transform:FindDeepChild("QiuContainer"):GetComponent(typeof(Unity.Animator))
        self.m_textPickCount = self.transform:FindDeepChild("PickCountText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_textFinalPrize = self.transform:FindDeepChild("CurrentLevelRewardText"):GetComponent(typeof(UnityUI.Text))

        self.m_btnStop = self.transform:FindDeepChild("BtnStop"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnStop)
        self.m_btnStop.onClick:AddListener(function()
            ActivityAudioHandler:PlayBtnSound()
            self:onStopBtnClick()
        end)

        self.m_btnPlay = self.transform:FindDeepChild("BtnPlay"):GetComponent(typeof(UnityUI.Button))
        self.m_rectTransformPlay = self.transform:FindDeepChild("BtnPlay"):GetComponent(typeof(Unity.RectTransform))

        self.m_trBingoBallMaskContainer = self.transform:FindDeepChild("BingoBallMaskContainer")
        self.m_mapBalls = {}
        local goHongseBall = self.m_trBingoBallMaskContainer:FindDeepChild("Hong")
        self.m_mapBalls[1] = goHongseBall
        local goHuangseBall = self.m_trBingoBallMaskContainer:FindDeepChild("Huang")
        self.m_mapBalls[2] = goHuangseBall
        local goLvseBall = self.m_trBingoBallMaskContainer:FindDeepChild("Lv")
        self.m_mapBalls[3] = goLvseBall
        local goLanseBall = self.m_trBingoBallMaskContainer:FindDeepChild("Lan")
        self.m_mapBalls[4] = goLanseBall
        local goZiseBall = self.m_trBingoBallMaskContainer:FindDeepChild("Zi")
        self.m_mapBalls[5] = goZiseBall

        self.m_mapBallsEffect = {}
        local goHongseEffect = self.transform:FindDeepChild("hongseEffect").gameObject
        self.m_mapBallsEffect[1] = goHongseEffect
        local goHuangseEffect = self.transform:FindDeepChild("huangseEffect").gameObject
        self.m_mapBallsEffect[2] = goHuangseEffect
        local goLvseEffect = self.transform:FindDeepChild("lvseEffect").gameObject
        self.m_mapBallsEffect[3] = goLvseEffect
        local goLanseEffect = self.transform:FindDeepChild("lanseEffect").gameObject
        self.m_mapBallsEffect[4] = goLanseEffect
        local goZiseEffect = self.transform:FindDeepChild("ziseEffect").gameObject
        self.m_mapBallsEffect[5] = goZiseEffect

        self.m_trBottomFrame = self.transform:FindDeepChild("Bottomkuang")
        self.m_ballOriginPos = Unity.Vector3(0, 200, 0)
        self.m_ballTargetPos = Unity.Vector3(0, -500, 0)

        self.m_btnGameIntroduce = self.transform:FindDeepChild("GameIntroduceBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnGameIntroduce)
        self.m_btnGameIntroduce.onClick:AddListener(function()
            self:onGameIntroduceBtnClick()
        end)

        self.m_btnRateTable = self.transform:FindDeepChild("RateTableUIBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnRateTable)
        self.m_btnRateTable.onClick:AddListener(function()
            self:onRateTableBtnClick()
        end)

        self.m_btnClose = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnClose)
        self.m_btnClose.onClick:AddListener(function()
            ActivityAudioHandler:PlayBtnSound()
            self:hide()
        end)

        -- Sale 相关
        self.btnIconBingo = self.transform:FindDeepChild("IconBingo"):GetComponent(typeof(UnityUI.Button))
        self.mBoosterTimeText = self.transform:FindDeepChild("BoosterTimeText"):GetComponent(typeof(TextMeshProUGUI))
        DelegateCache:addOnClickButton(self.btnIconBingo)
        self.btnIconBingo.onClick:AddListener(function()
            ActivityAudioHandler:PlaySound("bingo_generic_click")
            self:ShowSaleUI()
        end)

        self.goUseNowContainer = self.transform:FindDeepChild("UseNowContainer").gameObject
        self.btnUseNow = self.transform:FindDeepChild("BtnUseNow"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnUseNow)
        self.btnUseNow.onClick:AddListener(function()
            ActivityAudioHandler:PlaySound("bingo_generic_click")
            local nWildCount = BingoHandler.data.nWildCount
            if nWildCount > 0 then
                self:ShowSelectWildUI()
            else
                self:ShowSaleUI()
            end
        end)

        self.btnIconWild = self.transform:FindDeepChild("IconWild"):GetComponent(typeof(UnityUI.Button))
        self.mWildBallCountText = self.transform:FindDeepChild("WildBallCountText"):GetComponent(typeof(TextMeshProUGUI))
        DelegateCache:addOnClickButton(self.btnIconWild)
        self.btnIconWild.onClick:AddListener(function()
            ActivityAudioHandler:PlaySound("bingo_generic_click")
            self:ShowSaleUI()
        end)

        self.btnIconSuper = self.transform:FindDeepChild("IconSuper"):GetComponent(typeof(UnityUI.Button))
        self.mSuperBallCountText = self.transform:FindDeepChild("SuperBallCountText"):GetComponent(typeof(TextMeshProUGUI))
        DelegateCache:addOnClickButton(self.btnIconSuper)
        self.btnIconSuper.onClick:AddListener(function()
            ActivityAudioHandler:PlaySound("bingo_generic_click")
            self:ShowSaleUI()
        end)
        
        self.m_trBingoContainer = self.transform:FindDeepChild("BingoContainer")
        
        -- SelectBingoUI
        self.m_goSelectWildBingoUI = self.transform:FindDeepChild("SelectWildBingoUI").gameObject
        self.m_trSelectBingoContainer = self.transform:FindDeepChild("SelectBingoContainer")
        self.m_textRemainingWildCount = self.transform:FindDeepChild("RemaingWildCount"):GetComponent(typeof(TextMeshProUGUI))

        self.btnFill = self.transform:FindDeepChild("FillBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnFill)
        self.btnFill.onClick:AddListener(function()
            ActivityAudioHandler:PlaySound("bingo_generic_click")
            self:onFillClicked()
        end)
        local btnSelectWildClose = self.transform:FindDeepChild("SelectWildCloseBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnSelectWildClose)
        btnSelectWildClose.onClick:AddListener(function()
            ActivityAudioHandler:PlaySound("bingo_generic_click")
            self:onSelectWildCloseClicked()
        end)
        
        -- SelectWildWaitUI
        self.m_goSelectWildWaitUI = self.transform:FindDeepChild("SelectWildWaitUI").gameObject
        local btnLeave = self.transform:FindDeepChild("LeaveBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnLeave)
        btnLeave.onClick:AddListener(function()
            self:onLeaveClickded()
        end)
        local btnStay = self.transform:FindDeepChild("StayBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnStay)
        btnStay.onClick:AddListener(function()
            self:onStayClicked()
        end)

        -- SelectWildMakeSureUI
        self.m_goSelectWildMakeSureUI = self.transform:FindDeepChild("SelectWildMakeSureUI").gameObject
        local btnNo = self.transform:FindDeepChild("NoBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnNo)
        btnNo.onClick:AddListener(function()
            self:onNoClickded()
        end)
        local btnYes = self.transform:FindDeepChild("YesBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnYes)
        btnYes.onClick:AddListener(function()
            self:onYesClicked()
        end)

        --RateTableUI
        self.m_goRateTableUI = self.transform:FindDeepChild("RateTableUI").gameObject
        self.m_btnRateTableClose = self.m_goRateTableUI.transform:FindDeepChild("RateTableCloseBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnRateTableClose)
        self.m_btnRateTableClose.onClick:AddListener(function()
            self:onRateTableCloseBtnClick()
        end)

        --ShowBingoUI
        self.m_goShowBingoUI = self.transform:FindDeepChild("ShowBingoUI").gameObject
        self.m_bingoResultContainer = self.transform:FindDeepChild("BingoResultContainer")
        self.m_btnBingo = self.m_goShowBingoUI.transform:FindDeepChild("BtnBingo"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnBingo)
        self.m_btnBingo.onClick:AddListener(function()
            self:onBingoBtnClick()
        end)
        
        --LevelCompleteUI
        self.m_goLevelCompleteUI = self.transform:FindDeepChild("LevelCompleteUI").gameObject
        self.m_textLevelCompleteReward = self.m_goLevelCompleteUI.transform:FindDeepChild("LevelCompleteRewardText"):GetComponent(typeof(UnityUI.Text))
        self.m_btnCollect = self.m_goLevelCompleteUI.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCollect)
        self.m_btnCollect.onClick:AddListener(function()
            self:onCollectBtnClick()
        end)

        --FinalPrizeUI
        self.m_goFinalPrizeUI = self.transform:FindDeepChild("FinalPrizeUI").gameObject
        self.m_textFinalPrizeReward = self.m_goFinalPrizeUI.transform:FindDeepChild("textCoin"):GetComponent(typeof(UnityUI.Text))
        self.m_btnFinalPrizeCollect = self.m_goFinalPrizeUI.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnFinalPrizeCollect)
        self.m_btnFinalPrizeCollect.onClick:AddListener(function()
            self:onFinalPrizeBtnClick()
        end)
        
        --HowToPlayUI
        self.m_goHowToPlayUI = self.transform:FindDeepChild("HowToPlayUI").gameObject
        self.m_btnHowToPlayClose = self.m_goHowToPlayUI.transform:FindDeepChild("HowToPlayClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnHowToPlayClose)
        self.m_btnHowToPlayClose.onClick:AddListener(function()
            self:onHowToPlayCloseBtnClick()
        end)

        --PlayAgainUI
        self.m_goPlayAgainUI = self.transform:FindDeepChild("PlayAgainUI").gameObject
        self.m_btnStartAgain = self.transform:FindDeepChild("PlayAgainBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnStartAgain)
        self.m_btnStartAgain.onClick:AddListener(function()
            self:onStartAgainBtnClick()
        end)

        --GetCoins
        self.m_goGetCoins = self.transform:FindDeepChild("GetCoins").gameObject
        self.m_aniGetGetCoins = self.m_goGetCoins:GetComponent(typeof(Unity.Animator))
        self.m_trGetCoinsAni = self.transform:FindDeepChild("GetCoinsAniGo")
        self.m_textGetCoinsReward = self.transform:FindDeepChild("GetCoinsRewardText"):GetComponent(typeof(UnityUI.Text))

        --GetSlotsCards
        self.m_goGetSlotsCards = self.transform:FindDeepChild("GetSlotsCards").gameObject
        self.m_aniGetSlotsCards = self.m_goGetSlotsCards:GetComponent(typeof(Unity.Animator))
        self.m_trGetPackAni = self.transform:FindDeepChild("SlotsCardsAniGo")
        self.m_trSlotsCardsPackContainer = self.transform:FindDeepChild("SlotsCardsPackContainer")
        self.m_trSlotsCardsStarContainer = self.m_goGetSlotsCards.transform:FindDeepChild("Stars")

        self.m_trLevelReward = self.transform:FindDeepChild("LevelREWARDS")
        self.m_trLevelcontainer = self.transform:FindDeepChild("Levelcontainer")

        self.m_goBingoEffect = self.transform:FindDeepChild("BingoEffect").gameObject
        
        self:GenerateBingoItem()
        self.toBingoId = Unity.Animator.StringToHash("ToBingo")
        self.downId = Unity.Animator.StringToHash("Down")
        self.textDate = self.transform:FindDeepChild("textDate"):GetComponent(typeof(TextMeshProUGUI))
    end
    local bIsBingo = BingoHandler:CheckIsBingo()
    if bIsBingo then
        BingoHandler:toNextLevel()
    end
    self.m_bInSpin = false
    self.m_bIsAuto = false
    self.m_bInStop = false
    self.m_fSpinToAutoTime = 0
    self.clickSpinZonebValid = false
    self:UpdateBingoItem()
    ViewAlphaAni:Show(self.transform.gameObject, function()
        ActivityAudioHandler:PlayBackMusic("bingo_music_loop")
    end)
    self:UpdatePickCount()
    self:SetBtnStatus()
    self:UpdateFeatureTimeUI()

    EventHandler:AddListener("onActiveTimeChanged", self)
    EventHandler:AddListener("onPurchaseDoneNotifycation", self)
    EventHandler:AddListener("onActiveTimesUp", self)
end

function BingoMainUIPop:Simulation()
    self.m_bInSimulation = true
    local nCount = 0

    local mapDownLevelCount = {0, 0, 0, 0, 0}
    local mapGetPackCount = {0, 0, 0, 0, 0}
    local nTotalWin = 0

    local mapTotalSpinCount = {0, 0, 0, 0, 0}
    local nSpinCount = 0
    while nCount < 10 do
        local nAction = BingoHandler:GetRandomBingoDigit()
        local bInMap = LuaHelper.tableContainsElement(BingoHandler.data.m_bingoMap, nAction)
        local nIndex = LuaHelper.indexOfTable(BingoHandler.data.m_bingoMap, nAction)
        
        nSpinCount = nSpinCount + 1

        local bIsCoins = BingoHandler:CheckIsCoinsItem(nIndex)
        if bIsCoins then
            nTotalWin = nTotalWin + BingoHandler:RandomWinCoins()
        end
        local bIsSlotsCardsOpen = SlotsCardsManager:orActivityOpen()
        if bIsSlotsCardsOpen then
            local bIsOneSlotsCard = BingoHandler:CheckIsOneStarCardsItem(nIndex)
            if bIsOneSlotsCard then
                mapGetPackCount[1] = mapGetPackCount[1] + 1
            end
            local bIsTwoSlotsCard = BingoHandler:CheckIsTwoStarCardsItem(nIndex)
            if bIsTwoSlotsCard then
                mapGetPackCount[2] = mapGetPackCount[2] + 1
            end
            local bIsThreeSlotsCard = BingoHandler:CheckIsThreeStarCardsItem(nIndex)
            if bIsThreeSlotsCard then
                mapGetPackCount[3] = mapGetPackCount[3] + 1
            end
        end

        local bIsBingo = BingoHandler:CheckIsBingo()
        if bIsBingo then
            local winCoins = BingoHandler.m_mapPrize["Level"..BingoHandler.data.nLevel]
            nTotalWin = nTotalWin + winCoins
            mapDownLevelCount[BingoHandler.data.nLevel] = mapDownLevelCount[BingoHandler.data.nLevel] + 1
            mapTotalSpinCount[BingoHandler.data.nLevel] = mapTotalSpinCount[BingoHandler.data.nLevel] + nSpinCount
            BingoHandler:toNextLevel()
            nCount = nCount + 1
            nSpinCount = 0
        end
    end
    self.m_bInSimulation = false
    local strFile = ""
    for i = 1, 5 do
        strFile = strFile.."Bingo Level "..i.."完成了 "..mapDownLevelCount[i].."次"..", 总共spin:"..mapTotalSpinCount[i].."\n"
    end
    
    for i = 1, 5 do
        strFile = strFile.."获得"..i.."星卡包:"..mapGetPackCount[i].."个\n"
    end
    
    strFile = strFile.."共获得:"..nTotalWin.."金币"
    Debug.Log(strFile)
end

function BingoMainUIPop:onStopBtnClick()
    self.m_bIsAuto = false
    if not self.m_btnPlay.gameObject.activeSelf then
        self.m_btnPlay.gameObject:SetActive(true)
    end
    if self.m_bInStop and (self.m_aniBall:GetInteger("nPlayMode") ~= 0) then
        self.m_aniBall:SetInteger("nPlayMode", 0)
    end
end

function BingoMainUIPop:onPurchaseDoneNotifycation()
    Debug.Log("BingoMainUIPop:onPurchaseDoneNotifycation")
    self:UpdateFeatureTimeUI()
    self:UpdatePickCount()
    self:UpdatePrizeUI()
end

function BingoMainUIPop:Update()
    local dt = Unity.Time.deltaTime
    if Unity.Input.GetMouseButtonDown(0) or Unity.Input.GetMouseButton(0) or Unity.Input.GetMouseButtonUp(0) then
		local mousePosition =  Unity.Vector2(Unity.Input.mousePosition.x, Unity.Input.mousePosition.y)
        local bMouseInSpinBtn = Unity.RectTransformUtility.RectangleContainsScreenPoint(self.m_rectTransformPlay, mousePosition, Unity.Camera.main)
        if Unity.Input.GetMouseButtonDown(0) and (not self:CheckUIStates()) then
            self.clickSpinZonebValid = bMouseInSpinBtn
        end
    else
        self.clickSpinZonebValid = false
    end

    if not self:CheckAutoSpinOp(dt) then
		self:CheckSpinBtnClickOp(dt)
    end
    
    local bAutoFlag = false
    if self.m_bIsAuto and (not self.m_bInSpin) and (not self:CheckUIStates()) then
        if BingoHandler.data.nAction > 0 or BingoHandler.data.nSuperPickCount > 0 then
            bAutoFlag = true
        else
            if self.m_aniBall:GetInteger("nPlayMode") ~= 0 then
                self.m_aniBall:SetInteger("nPlayMode", 0)
            end
            self:onStopBtnClick()
        end
	end
	if bAutoFlag then
        self:onPlayBtnClicked()
    end
end

-- 检查 是否 AutoSpin 操作
function BingoMainUIPop:CheckAutoSpinOp(dt)
	if Unity.Input.GetMouseButtonUp(0) then
		self.m_fSpinToAutoTime = 0.0
	end

	local bInAutoSpinOp = self.m_bIsAuto --正处于 AutoSpin 选择界面里

	if not self.m_bIsAuto then
		if Unity.Input.GetMouseButton(0) and (not self.m_bInSpin) and self.clickSpinZonebValid then
			self.m_fSpinToAutoTime = self.m_fSpinToAutoTime + dt
			if self.m_fSpinToAutoTime > 0.9 then
                self.m_fSpinToAutoTime = 0.0
                Debug.Log("开始auto Spin")
                self.m_bIsAuto = true
                self.m_btnPlay.gameObject:SetActive(false)
                self.m_btnStop.gameObject:SetActive(true)
			end
		end
	end
	
	return bInAutoSpinOp or self.m_bIsAuto ----正处于 AutoSpin 选择界面里 或者，刚触发 AutoSpin 选择界面
end	

-- 检查 是否是 点击动作
function BingoMainUIPop:CheckSpinBtnClickOp(dt)
	if not self.clickSpinZonebValid then
		return
	end

    if Unity.Input.GetMouseButtonUp(0) and self.m_btnPlay.interactable and (not self:CheckUIStates()) then
        ActivityAudioHandler:PlaySound("bingo_generic_click")
        self:onPlayBtnClicked()
	end
end

function BingoMainUIPop:CheckUIStates()	
    return self.m_goGetSlotsCards.activeSelf or self.m_goGetCoins.activeSelf or self.m_goPlayAgainUI.activeSelf or self.m_goHowToPlayUI.activeSelf or
    self.m_goLevelCompleteUI.activeSelf or self.m_goFinalPrizeUI.activeSelf or self.m_goShowBingoUI.activeSelf or self.m_goRateTableUI.activeSelf
end

function BingoMainUIPop:SetBtnStatus()
    local bNext = BingoHandler.data.nAction > 0
    bNext = bNext or BingoHandler.data.nSuperPickCount > 0

    if self.m_bIsAuto then
        if bNext then
            self.m_btnStop.gameObject:SetActive(true)
            self.m_btnPlay.gameObject:SetActive(false)
        else
            self.m_btnStop.gameObject:SetActive(false)
            self.m_btnPlay.gameObject:SetActive(true)
        end
    else
        self.m_btnStop.gameObject:SetActive(false)
        self.m_btnPlay.gameObject:SetActive(true)
    end
end

function BingoMainUIPop:GenerateBingoItem()
    local goPrefab = AssetBundleHandler:LoadActivityAsset("BingoItem")
    local x = 62
    local y = -63.5
    for i = 1, 25 do
        local obj = Unity.Object.Instantiate(goPrefab)
        obj.transform:SetParent(self.m_trBingoContainer, false)
        obj.transform.localScale = Unity.Vector3.zero
        obj.transform.anchoredPosition3D = Unity.Vector3(x, y, 0)
        x = x + 128
        if i % 5 == 0 then
            y = y - 131
            x = 62
        end
    end
end

function BingoMainUIPop:UpdateBingoItem()
    self.m_goBingoEffect:SetActive(true)
    local id = LeanTween.delayedCall(1.5, function ()
        self.m_goBingoEffect:SetActive(false)
    end).id
    table.insert( ActivityHelper.m_LeanTweenIDs, id )

    local nIndex = 0
    local nRow = 1
 
    local mapFlagAudio = {}
    for i = 1, 9 do
        mapFlagAudio[i] = false
    end
    for i = 0, self.m_trBingoContainer.childCount - 1 do
        local item = self.m_trBingoContainer:GetChild(i)
        local nCount = BingoHandler.data.m_bingoMap[i+1]
        self:UpdateItemUI(item, i+1, nCount)
        local delayTime = 0.1 * nIndex
        nIndex = nIndex + 1
        if not mapFlagAudio[nIndex] then
            mapFlagAudio[nIndex] = true
            local id = LeanTween.delayedCall(delayTime+0.3, function()
                ActivityAudioHandler:PlaySound("grid_appear")
            end).id
            table.insert( ActivityHelper.m_LeanTweenIDs, id )
        end
        if i % 5 == 4 then
            nRow = nRow + 1
            nIndex = nRow
        end
        self:ShowScaleItemAni(item, delayTime)
    end
    mapFlagAudio = nil
    self:UpdatePrizeUI()
end

function BingoMainUIPop:ShowScaleItemAni(item, delayTime) -- bingo后元素的放大缩小
    item.localScale = Unity.Vector3.zero
    local id = LeanTween.scale(item.gameObject, Unity.Vector3.one * 1.3, 0.3):setDelay(delayTime):setOnComplete(function()
        local id1 = LeanTween.scale(item.gameObject, Unity.Vector3.one, 0.2).id
        table.insert( ActivityHelper.m_LeanTweenIDs, id1 )
    end).id
    table.insert( ActivityHelper.m_LeanTweenIDs, id )
end

function BingoMainUIPop:UpdateItemUI(item, nIndex, nCount)
    local goSlotsCards = self:FindSymbolElement(item, "SlotsCards")
    local goCoins = self:FindSymbolElement(item, "Coins")
    local goGet = self:FindSymbolElement(item, "Get")
    local goBingoGet = self:FindSymbolElement(item, "BingoGet")
    local goBingoNotGet = self:FindSymbolElement(item, "BingoNotGet")
    local textBingoCount = self:FindSymbolElement(item, "BingoCount")
    textBingoCount.text = nCount

    local bIsCoins = BingoHandler:CheckIsCoinsItem(nIndex)
    goCoins:SetActive(bIsCoins)

    local bIsBingo = BingoHandler:CheckIsBingoItem(nIndex)
    local bIsGet = BingoHandler:CheckHasItem(nCount)
    if bIsBingo then
        goGet:SetActive(false)
        goBingoGet:SetActive(bIsGet)
        goBingoNotGet:SetActive(not bIsGet)
    else
        goGet:SetActive(bIsGet)
        goBingoGet:SetActive(false)
        goBingoNotGet:SetActive(false)
    end

    -- TODO 检测卡牌是否开启
    local bIsSlotsCardsOpen = SlotsCardsManager:orActivityOpen()
    if bIsSlotsCardsOpen then
        local bIsOneCards = BingoHandler:CheckIsOneStarCardsItem(nIndex)
        local bIsTwoCards = BingoHandler:CheckIsTwoStarCardsItem(nIndex)
        local bIsThreeCards = BingoHandler:CheckIsThreeStarCardsItem(nIndex)
        if bIsOneCards or bIsTwoCards or bIsTwoCards then
            local nStarCount = 1
            if bIsOneCards then
                nStarCount = 1
            elseif bIsTwoCards then
                nStarCount = 2
            elseif bIsThreeCards then
                nStarCount = 3
            end
            local stars = self:FindSymbolElement(goSlotsCards, "Stars").transform
            local packTypeContainer = self:FindSymbolElement(goSlotsCards, "KaPaiJieDian").transform
            for j = 0, stars.childCount - 1 do
                if j <= (nStarCount-1) then
                    stars:GetChild(j).gameObject:SetActive(true)
                else
                    stars:GetChild(j).gameObject:SetActive(false)
                end
                packTypeContainer:GetChild(j).gameObject:SetActive(j==(nStarCount-1))
            end
            goSlotsCards:SetActive(true)
        else
            goSlotsCards:SetActive(false)
        end
    else
        goSlotsCards:SetActive(false)
    end
    
end

function BingoMainUIPop:UpdatePrizeUI()
    local nLevel = BingoHandler.data.nLevel
    for i = 1, LuaHelper.tableSize(BingoConfig.TableLevelConfig) do
        local coins = BingoHandler.m_mapPrize["Level"..i]
        local levelbg = self:FindSymbolElement(self.m_trLevelReward, "Level"..i.."bg")
        local blackbg = self:FindSymbolElement(levelbg, "Mask")
        blackbg:SetActive(i ~= nLevel)
        local getObj = self:FindSymbolElement(levelbg, "dui")
        getObj:SetActive(i < nLevel)

        local level = self.m_trLevelcontainer:GetChild(i - 1)
        level.gameObject:SetActive(nLevel == i)
        if nLevel == i then
            local rewardText1 = self:FindSymbolElement(levelbg, "Text")
            rewardText1.text = MoneyFormatHelper.coinCountOmit(coins)

            local rewardText2 = self:FindSymbolElement(level, "Text")
            rewardText2.text = MoneyFormatHelper.coinCountOmit(coins)
        else
            local rewardText1 = self:FindSymbolElement(levelbg, "Text")
            rewardText1.text = MoneyFormatHelper.coinCountOmit(coins)
            rewardText1.gameObject:SetActive(i > nLevel)
        end
    end
    self.m_textFinalPrize.text = "$  "..MoneyFormatHelper.numWithCommas(BingoHandler.fFinalPrize)
end

function BingoMainUIPop:FindSymbolElement(goSymbol, strKey, bSelf)
    if not GameConfig.RELEASE_VERSION then
        local tablePoolKey = {"SlotsCards", "Coins", "BingoNotGet", "Get", "BingoGet", "BingoCount", "WildGet", 
         "Level1bg", "Level2bg", "Level3bg", "Level4bg", "Level5bg", "Mask", "dui", "Text", "FollowEffect",
        "Stars", "KaPaiJieDian", "PickCountText", "RateTableContainer", "xuanzhong", "BingoCountText", "RateTableBG", "Content"}
        Debug.Assert(LuaHelper.tableContainsElement(tablePoolKey, strKey))
    end

    if self.goSymbolElementPool == nil then
        self.goSymbolElementPool = {}
    end

    if self.goSymbolElementPool[goSymbol] == nil then
        self.goSymbolElementPool[goSymbol] = {}
    end     

    if self.goSymbolElementPool[goSymbol][strKey] == nil then
        local goTran = nil
        if bSelf then
            goTran = goSymbol.transform
        else
            goTran = goSymbol.transform:FindDeepChild(strKey)
        end

        if goTran then
            local go = goTran.gameObject

            if strKey == "BingoCount" or strKey == "PickCountText" or strKey == "BingoCountText" then
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(TextMeshProUGUI))
            elseif strKey == "Text" then
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(UnityUI.Text))
            else
                self.goSymbolElementPool[goSymbol][strKey] = go
            end
        end

    end     
    
    return self.goSymbolElementPool[goSymbol][strKey]
end

function BingoMainUIPop:UpdatePickCount()
    local count = BingoHandler.data.nAction
    if count == nil then
        count = 0
    end
    self.m_textPickCount.text = count
    local nWildCount = BingoHandler.data.nWildCount
    self.goUseNowContainer:SetActive(nWildCount > 0)
end

function BingoMainUIPop:onPlayBtnClicked()
    if BingoHandler.data.nAction <= 0 and BingoHandler.data.nSuperPickCount <= 0 then
        self:ShowSaleUI()
        return
    end

    if self.m_bInSpin then
        return
    end

    Debug.Log("点击Spin")
    self.m_bInSpin = true
    self.m_bInStop = false
    if self.m_aniBall:GetInteger("nPlayMode") ~= 1 then
        self.m_aniBall:SetInteger("nPlayMode", 1)
    end
    self.audioSource = ActivityAudioHandler:PlaySound("bingo_balls_roll", true)

    local bNext = BingoHandler.data.nAction > 0
    bNext = bNext or BingoHandler.data.nSuperPickCount > 0
    if not bNext then
        Debug.Log("已经没有Bingo 数了，还可以点击，有问题！！！！！！！！")
        return
    end

    self.m_btnPlay.interactable = false
    self.m_btnClose.interactable = false

    self.m_btnGameIntroduce.interactable = false
    self.m_btnRateTable.interactable = false
    self.btnIconBingo.interactable = false
    self.btnIconWild.interactable = false
    self.btnUseNow.interactable = false
    self.btnIconSuper.interactable = false

    local bSuper = false
    if BingoHandler.data.nSuperPickCount > 0 then
        bSuper = true
        BingoHandler:addSuperPickCount(-1)
        self:UpdateFeatureTimeUI()
    end
    BingoHandler:addPickCount(-1)
    self:UpdatePickCount()

    local nCount = BingoHandler:GetRandomBingoDigit(bSuper)
    local bInMap = LuaHelper.tableContainsElement(BingoHandler.data.m_bingoMap, nCount)

    local nIndex = LuaHelper.indexOfTable(BingoHandler.data.m_bingoMap, nCount)
    
    local bIsBingo = BingoHandler:CheckIsBingo()
    if bIsBingo then
        local winCoins = BingoHandler.m_mapPrize["Level"..BingoHandler.data.nLevel]
        PlayerHandler:AddCoin(winCoins)
        self.nLevelPrizeWinCoin = winCoins
        self.nLevelPrizePlayerCoin = PlayerHandler.nGoldCount
        if BingoHandler.data.nLevel == 5 then
            local winCoins = BingoHandler.fFinalPrize
            PlayerHandler:AddCoin(winCoins)
            self.nFinalPrizeWinCoin = winCoins
            self.nFinalPrizePlayerCoin = PlayerHandler.nGoldCount
            BingoHandler.data.fFinalPrizeRatioMutiplier = BingoHandler.data.fFinalPrizeRatioMutiplier + 0.1
            BingoHandler:updateLevelPrize()
            BingoHandler:SaveDb()
        end
    end

    local nCurrentWinCoins = 0
    local ballIndex = math.random(1, 5)
    if bInMap then
        ballIndex = nIndex%5 == 0 and 5 or nIndex%5
        local bIsCoins = BingoHandler:CheckIsCoinsItem(nIndex)
        if bIsCoins then
            nCurrentWinCoins = BingoHandler:RandomWinCoins()
            PlayerHandler:AddCoin(nCurrentWinCoins)
        end
        local bIsSlotsCardsOpen = SlotsCardsManager:orActivityOpen()
        if bIsSlotsCardsOpen then
            local bIsOneSlotsCard = BingoHandler:CheckIsOneStarCardsItem(nIndex)
            if bIsOneSlotsCard then
                SlotsCardsGiftManager:getStampPackInActive(SlotsCardsAllProbTable.PackType.One, 1)
            end
            local bIsTwoSlotsCard = BingoHandler:CheckIsTwoStarCardsItem(nIndex)
            if bIsTwoSlotsCard then
                SlotsCardsGiftManager:getStampPackInActive(SlotsCardsAllProbTable.PackType.Two, 1)
            end
            local bIsThreeSlotsCard = BingoHandler:CheckIsThreeStarCardsItem(nIndex)
            if bIsThreeSlotsCard then
                SlotsCardsGiftManager:getStampPackInActive(SlotsCardsAllProbTable.PackType.Three, 1)
            end
        end
    end
    Debug.Log("随机出来一个："..nCount)
    
    local ball = self.m_mapBalls[ballIndex]
    ball.gameObject:SetActive(true)
    local textCount = self:FindSymbolElement(ball, "PickCountText")
    textCount.text = nCount
    
    ball.localPosition = self.m_ballOriginPos
    ball.localScale = Unity.Vector3.zero
    local id = LeanTween.scale(ball.gameObject, Unity.Vector3.one * 1.5, 0.5):setDelay(0.5):setOnStart(function()
        ActivityAudioHandler:PlaySound("bingo_ball_pop_up")
    end):setEase(LeanTweenType.easeInCirc).id
    table.insert( ActivityHelper.m_LeanTweenIDs, id )
    local id = LeanTween.moveLocal(ball.gameObject, Unity.Vector3.zero, 0.5):setDelay(0.5):setOnComplete(function()
        ball:SetParent(self.m_trBingoBallMaskContainer.parent, false)
        self.m_trBottomFrame:SetAsLastSibling()

        local effectId = bInMap and self.toBingoId or self.downId
        local ani = ball:GetComponent(typeof(Unity.Animator))

        if bInMap then
            local item = self.m_trBingoContainer:GetChild(nIndex - 1)
            local id = LeanTween.move(ball.gameObject, item.position, 0.5):setDelay(1):setOnStart(function()
                ball:SetAsLastSibling()
                ani:SetTrigger(effectId)
                ActivityAudioHandler:PlaySound("bingo_ball_flies_to_card")
                self.m_bInStop = true
                if not self.m_bIsAuto then
                    self.m_aniBall:SetInteger("nPlayMode", 0)
                end
            end):setOnComplete(function()
                if BingoHandler:CheckIsBingoItem(nIndex) then
                    ActivityAudioHandler:PlaySound("bingo_ball_lands_on_highlighted_number")       
                elseif BingoHandler:CheckIsEmpty(nIndex) then
                    ActivityAudioHandler:PlaySound("bingo_ball_lands_on_empty")            
                end

                self.m_mapBallsEffect[ballIndex].transform.position = item.position
                self.m_mapBallsEffect[ballIndex]:SetActive(true)
                self:ShowItemAni(item)
                self:UpdateItemUI(item, nIndex, nCount)
                ball.gameObject:SetActive(false)
                ball:SetParent(self.m_trBingoBallMaskContainer, false)
                ball.localPosition = self.m_ballOriginPos
                -- self:SetBtnStatus()
                
                if bIsBingo then
                    self:onStopBtnClick()
                end
                
                self.audioSource:Stop()
                self.m_mapBallsEffect[ballIndex]:SetActive(false)
                
                local bShowUI = false
                if nCurrentWinCoins > 0 then
                    bShowUI = true
                    self:ShowGetCoins(item.position, nCurrentWinCoins, bIsBingo)
                else
                    local bIsSlotsCardsOpen = SlotsCardsManager:orActivityOpen()
                    if bIsSlotsCardsOpen then
                        local bIsOneSlotsCard = BingoHandler:CheckIsOneStarCardsItem(nIndex)
                        local bIsTwoSlotsCard = BingoHandler:CheckIsTwoStarCardsItem(nIndex)
                        local bIsThreeSlotsCard = BingoHandler:CheckIsThreeStarCardsItem(nIndex)
                        local nSlotsCardType = nil
                        if bIsOneSlotsCard then
                            nSlotsCardType = 1
                        end
                        if bIsTwoSlotsCard then
                            nSlotsCardType = 2
                        end                        
                        if bIsThreeSlotsCard then
                            nSlotsCardType = 3
                        end
                        if nSlotsCardType then
                            bShowUI = true
                            self:ShowGetSlotsCards(item.position, nSlotsCardType, bIsBingo)
                        end
                    else
                    end
                end
                if not bShowUI and bIsBingo then
                    self:ShowBingoUI()
                end
                self.m_bInSpin = false
                self.m_btnPlay.interactable = true
                self.m_btnClose.interactable = true
                self.m_btnGameIntroduce.interactable = true
                self.m_btnRateTable.interactable = true
                self.btnIconBingo.interactable = true
                self.btnIconWild.interactable = true
                self.btnUseNow.interactable = true
                self.btnIconSuper.interactable = true

            end).id
            table.insert( ActivityHelper.m_LeanTweenIDs, id )
        else
            local id = LeanTween.moveLocal(ball.gameObject, self.m_ballTargetPos, 0.5):setDelay(1):setOnStart(function()
                ball:SetAsLastSibling()
                ani:SetTrigger(effectId)
                self.m_bInStop = true
                if not self.m_bIsAuto then
                    self.m_aniBall:SetInteger("nPlayMode", 0)
                end
            end):setOnComplete(function()
                ball.gameObject:SetActive(false)
                ball:SetParent(self.m_trBingoBallMaskContainer, false)
                ball.localPosition = self.m_ballOriginPos
                -- self:SetBtnStatus()
                if bIsBingo then
                    self:onStopBtnClick()
                end
                self.audioSource:Stop()
                self.m_bInSpin = false
                self.m_btnPlay.interactable = true
                self.m_btnClose.interactable = true
                self.m_btnGameIntroduce.interactable = true
                self.m_btnRateTable.interactable = true
                self.btnIconBingo.interactable = true
                self.btnIconWild.interactable = true
                self.btnUseNow.interactable = true
                self.btnIconSuper.interactable = true
            end).id
            table.insert( ActivityHelper.m_LeanTweenIDs, id )
        end
    end).id
    table.insert( ActivityHelper.m_LeanTweenIDs, id )
end

function BingoMainUIPop:ShowItemAni(item) -- bingo后元素的放大缩小
    local originIndex = item:GetSiblingIndex()
    item:SetAsLastSibling()
    local id = LeanTween.scale(item.gameObject, Unity.Vector3.one * 1.3, 0.3):setOnComplete(function()
        local id1 = LeanTween.scale(item.gameObject, Unity.Vector3.one, 0.2):setOnComplete(function()
            item:SetSiblingIndex(originIndex)
        end).id
        table.insert( ActivityHelper.m_LeanTweenIDs, id1 )
    end).id
    table.insert( ActivityHelper.m_LeanTweenIDs, id )
end

function BingoMainUIPop:hide()
    EventHandler:Brocast("onActiveHide")
    EventHandler:RemoveListener("onPurchaseDoneNotifycation", self)
    EventHandler:RemoveListener("onActiveTimesUp", self)
    EventHandler:RemoveListener("onActiveTimeChanged", self)
    ViewAlphaAni:Hide(self.transform.gameObject)
    ActivityAudioHandler:StopBackMusic()
end

function BingoMainUIPop:OnDestroy()
    self.goSymbolElementPool = nil
end

function BingoMainUIPop:ShowGetSlotsCards(pos, nSlotsCardsType, bIsBingo)
    for i = 0, self.m_trSlotsCardsPackContainer.childCount - 1 do
        self.m_trSlotsCardsPackContainer:GetChild(i).gameObject:SetActive(i == (nSlotsCardsType - 1))
    end
    for i = 0, self.m_trSlotsCardsStarContainer.childCount - 1 do
        self.m_trSlotsCardsStarContainer:GetChild(i).gameObject:SetActive(i <= (nSlotsCardsType - 1))
    end

    self.m_trGetPackAni.position = pos
    self.m_trGetPackAni.localScale = Unity.Vector3.zero

    local id2 = LeanTween.moveLocal(self.m_trGetPackAni.gameObject, Unity.Vector3.zero, 0.7).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id2)
    local id3 = LeanTween.scale(self.m_trGetPackAni.gameObject, Unity.Vector3.one * 2.1, 0.7):setOnComplete(function()
        ActivityAudioHandler:PlaySound("bingo_chest_pop_up")
        --local id4 = LeanTween.scale(self.m_trGetPackAni.gameObject, Unity.Vector3.one * 2, 0.5):setEase(LeanTweenType.easeInOutBack).id
        local id4 = LeanTween.scale(self.m_trGetPackAni.gameObject, Unity.Vector3.one * 2, 0.3):setEase(LeanTweenType.easeInOutQuad).id
        table.insert(ActivityHelper.m_LeanTweenIDs, id4)
    end).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id3)

    self.m_goGetSlotsCards:SetActive(true)
    LeanTween.delayedCall(2.5, function()
        ActivityHelper:CancelLeanTween()
        self.m_aniGetSlotsCards:Play("Hide", 0, 0)
        LeanTween.delayedCall(0.5, function()
            self.m_goGetSlotsCards:SetActive(false)
        end)
        if bIsBingo then
            self:ShowBingoUI()
        end
    end)
end

function BingoMainUIPop:ShowGetCoins(pos, nCurrentWinCoins, bIsBingo)
    self.m_trGetCoinsAni.position = pos
    self.m_trGetCoinsAni.localScale = Unity.Vector3.zero
    -- TODO 做动画
    local id1 = LeanTween.moveLocal(self.m_trGetCoinsAni.gameObject, Unity.Vector3.zero, 0.6).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id1)
    local id2 = LeanTween.scale(self.m_trGetCoinsAni, Unity.Vector3.one * 2.2, 0.45):setOnComplete(function()
        ActivityAudioHandler:PlaySound("bingo_gift_explodes")
        local id3 = LeanTween.scale(self.m_trGetCoinsAni, Unity.Vector3.one * 2, 0.2).id
        table.insert(ActivityHelper.m_LeanTweenIDs, id3)
    end).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id2)
    self.m_goGetCoins:SetActive(true)
    self.m_textGetCoinsReward.text = MoneyFormatHelper.numWithCommas(nCurrentWinCoins)
    LeanTween.delayedCall(2, function()
        LobbyView:UpCoinsCanvasLayer()
        CoinFly:fly(self.m_textGetCoinsReward.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 6, true)
    end)
    LeanTween.delayedCall(5.0, function()
        LobbyView:DownCoinsCanvasLayer()
        ActivityHelper:CancelLeanTween()
        self.m_aniGetGetCoins:Play("Hide", 0, 0)
        LeanTween.delayedCall(0.5, function()
            self.m_goGetCoins:SetActive(false)
        end)
        if bIsBingo then
            self:ShowBingoUI()
        end
    end)
end

function BingoMainUIPop:onCollectBtnClick()
    ActivityAudioHandler:setBGMusicVolume(1)
    ActivityAudioHandler:PlaySound("bingo_generic_click")
    LobbyView:UpCoinsCanvasLayer()
    CoinFly:fly(self.m_btnCollect.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 20)
    self.m_btnCollect.interactable = false
    LeanTween.delayedCall(2, function()
        self.m_goLevelCompleteUI:SetActive(false)
        LobbyView:DownCoinsCanvasLayer()
    end)

    local bIsBingo = BingoHandler:CheckIsBingo()
    if bIsBingo then
        local bIsAllEnd = BingoHandler:toNextLevel()
        if bIsAllEnd then
            self.m_textFinalPrizeReward.text = MoneyFormatHelper.numWithCommas(self.nFinalPrizeWinCoin)
            LeanTween.delayedCall(3, function()
                self.m_btnFinalPrizeCollect.interactable = true
                self.m_goFinalPrizeUI:SetActive(true)
                ActivityAudioHandler:PlaySound("bingo_final_cheer")
                ActivityAudioHandler:setBGMusicVolume(0.1)
            end)
        else
            for i = 1, LuaHelper.tableSize(BingoConfig.TableLevelConfig) do
                local level = self.m_trLevelcontainer:GetChild(i - 1)
                if level.gameObject.activeSelf then
                    local ani = level:GetComponent(typeof(Unity.Animator))
                    LeanTween.delayedCall(2, function()
                        ani:SetInteger("nPlayMode", 1)
                        ActivityAudioHandler:PlaySound("bingo_checksign")
                    end)
                end
            end

            local id = LeanTween.delayedCall(4, function()
                for i = 1, LuaHelper.tableSize(BingoConfig.TableLevelConfig) do
                    local level = self.m_trLevelcontainer:GetChild(i - 1)
                    if level.gameObject.activeSelf then
                        local ani = level:GetComponent(typeof(Unity.Animator))
                        ani:SetInteger("nPlayMode", 0)
                    end
                end
                self:UpdateBingoItem()
            end).id
            table.insert( ActivityHelper.m_LeanTweenIDs, id )
        end
    end
end

function BingoMainUIPop:onFinalPrizeBtnClick()
    ActivityAudioHandler:setBGMusicVolume(1)
    ActivityAudioHandler:PlaySound("bingo_generic_click")
    self.m_btnFinalPrizeCollect.interactable = false
    LobbyView:UpCoinsCanvasLayer()
    CoinFly:fly(self.m_btnCollect.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 60, true, self.nFinalPrizePlayerCoin)
    LeanTween.delayedCall(9, function()
        self.m_goFinalPrizeUI:SetActive(false)
        LobbyView:DownCoinsCanvasLayer()
    end)
    LeanTween.delayedCall(10, function()
        self:ShowPlayAgainUI()
    end)
end

function BingoMainUIPop:onBingoBtnClick()
    ActivityAudioHandler:PlaySound("bingo_generic_click")
    self.m_goShowBingoUI:SetActive(false)
    ActivityAudioHandler:setBGMusicVolume(0)
    self.m_textLevelCompleteReward.text = MoneyFormatHelper.numWithCommas(self.nLevelPrizeWinCoin)
    ActivityAudioHandler:PlaySound("bingo_music_end")
    self.m_goLevelCompleteUI:SetActive(true)
    self.m_btnCollect.interactable = true
end

function BingoMainUIPop:ShowBingoUI()
    self.m_aniBall:SetInteger("nPlayMode", 0)
    ActivityAudioHandler:PlaySound("bingo_in_game_bingo_award_pop_up")
    for i = 0, self.m_bingoResultContainer.childCount - 1 do
        self.m_bingoResultContainer:GetChild(i).gameObject:SetActive((BingoHandler.data.nLevel - 1) == i)
    end
    self.m_goShowBingoUI:SetActive(true)
end

function BingoMainUIPop:ShowPlayAgainUI()
    ActivityAudioHandler:PlaySound("bingo_generic_pop_up")
    self.m_goPlayAgainUI:SetActive(true)
end

function BingoMainUIPop:onStartAgainBtnClick()
    ActivityAudioHandler:PlaySound("bingo_generic_click")
    self.m_goPlayAgainUI:SetActive(false)
    self:UpdateBingoItem()
end

function BingoMainUIPop:onHowToPlayCloseBtnClick()
    ActivityAudioHandler:PlaySound("bingo_generic_click")
    self.m_goHowToPlayUI:SetActive(false)
end

function BingoMainUIPop:onGameIntroduceBtnClick()
    ActivityAudioHandler:PlaySound("bingo_generic_pop_up")
    self.m_goHowToPlayUI:SetActive(true)
end

function BingoMainUIPop:onRateTableBtnClick()
    ActivityAudioHandler:PlaySound("bingo_generic_click")
    local rateTableContainer = self:FindSymbolElement(self.m_goRateTableUI, "RateTableContainer").transform
    if rateTableContainer.childCount ~= BingoHandler.m_nBingoMaxCount then
        local needAddCount = BingoHandler.m_nBingoMaxCount - rateTableContainer.childCount
        local rateTableBG = self:FindSymbolElement(self.m_goRateTableUI, "RateTableBG").transform
        rateTableBG.sizeDelta = Unity.Vector2(1250, 6 + 84 * (BingoHandler.m_nBingoMaxCount / 15))
        if needAddCount > 0 then
            local prefab = AssetBundleHandler:LoadActivityAsset("RateItem")
            for i=1,needAddCount do
                local obj = Unity.Object.Instantiate(prefab)
                obj.transform:SetParent(rateTableContainer, false)
                obj.transform.localScale = Unity.Vector3.one
                obj.transform.localPosition = Unity.Vector3.zero
            end
        elseif needAddCount < 0 then
            for i = rateTableContainer.childCount - 1, BingoHandler.m_nBingoMaxCount - 1, -1 do
                local item = rateTableContainer:GetChild(i).gameObject
                if item.activeSelf then
                    item:SetActive(false)
                end
            end
        end
    end
    for i = 0, BingoHandler.m_nBingoMaxCount - 1 do
        local item = rateTableContainer:GetChild(i)
        if not item.gameObject.activeSelf then
            item.gameObject:SetActive(true)
        end
        local bg = self:FindSymbolElement(item, "xuanzhong")
        bg:SetActive(BingoHandler:CheckHasItem(i + 1))
        local bingoCountText = self:FindSymbolElement(item, "BingoCountText")
        bingoCountText.text = i + 1
    end
    self.m_goRateTableUI:SetActive(true)
end

function BingoMainUIPop:onRateTableCloseBtnClick()
    ActivityAudioHandler:PlaySound("bingo_generic_click")
    self.m_goRateTableUI:SetActive(false)
end

function BingoMainUIPop:ShowSaleUI()
    ActivityAudioHandler:PlaySound("bingo_generic_pop_up")
    BingoSaleUIPop:Show()
end

function BingoMainUIPop:UpdateFeatureTimeUI()
    self.mSuperBallCountText.text = BingoHandler.data.nSuperPickCount
    self.mWildBallCountText.text = BingoHandler.data.nWildCount
    
    if self.mBoosterTimeCo == nil and BingoHandler:checkInBoosterTime() then
        --local endTime = BingoHandler.data.m_nBingoBallBoosterEndTime
        self.mBoosterTimeCo = StartCoroutine( function()
            local waitForSecend = Unity.WaitForSeconds(1)
            while (BingoHandler.data.m_nBingoBallBoosterEndTime ~= nil) and (self.transform ~= nil) do
                local nowSecond = TimeHandler:GetServerTimeStamp()
                
                local time = BingoHandler.data.m_nBingoBallBoosterEndTime - nowSecond
                local days = time // (3600*24)
                local hours = time // 3600 - 24 * days
                local minutes = time // 60 - 24 * days * 60 - 60 * hours
                local seconds = time % 60
                self.mBoosterTimeText.text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                if time <= 0 then
                    BingoHandler.data.m_nBingoBallBoosterEndTime = nil
                end
                yield_return(waitForSecend)
            end
            self.mBoosterTimeCo = nil
        end)
    else
        self.mBoosterTimeText.text = string.format("%02d:%02d:%02d", 0, 0, 0)
    end
end

function BingoMainUIPop:ShowSelectWildUI()
    self.m_nWildCount = BingoHandler.data.nWildCount
    self.m_textRemainingWildCount.text = "YOU HAVE "..self.m_nWildCount
    for i = 0, self.m_trSelectBingoContainer.childCount - 1 do
        local item = self.m_trSelectBingoContainer:GetChild(i)
        local nCount = BingoHandler.data.m_bingoMap[i+1]
        local nIndex = i + 1

        local bIsGet = BingoHandler:CheckHasItem(nCount)
        local btn = item:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:RemoveAllListeners()
        btn.interactable = not bIsGet
        if not bIsGet then
            btn.onClick:AddListener(function()
                self:onSelectWildClicked(item)
            end)
        end
        self:UpdateSelectWildItemUI(item, nIndex, nCount, bIsGet, false)
    end
    
    self.m_goSelectWildBingoUI:SetActive(true)
    self.btnFill.interactable = false
end

function BingoMainUIPop:UpdateSelectWildItemUI(item, nIndex, nCount, bIsGet, bIsGetWild)
    local goWildGet = self:FindSymbolElement(item, "WildGet")
    goWildGet:SetActive(bIsGetWild)

    local goSlotsCards = self:FindSymbolElement(item, "SlotsCards")
    local goCoins = self:FindSymbolElement(item, "Coins")
    local goGet = self:FindSymbolElement(item, "Get")
    local goBingoGet = self:FindSymbolElement(item, "BingoGet")
    local goBingoNotGet = self:FindSymbolElement(item, "BingoNotGet")
    local textBingoCount = self:FindSymbolElement(item, "BingoCount")
    textBingoCount.text = nCount

    local bIsCoins = BingoHandler:CheckIsCoinsItem(nIndex)
    goCoins:SetActive(bIsCoins)

    local bIsBingo = BingoHandler:CheckIsBingoItem(nIndex)
    local bIsGet = BingoHandler:CheckHasItem(nCount)
    if bIsBingo then
        goGet:SetActive(false)
        goBingoGet:SetActive(bIsGet)
        goBingoNotGet:SetActive(not bIsGet)
    else
        goGet:SetActive(bIsGet)
        goBingoGet:SetActive(false)
        goBingoNotGet:SetActive(false)
    end

    -- TODO 检测卡牌是否开启
    local bIsSlotsCardsOpen = SlotsCardsManager:orActivityOpen()
    if bIsSlotsCardsOpen then
        local bIsOneCards = BingoHandler:CheckIsOneStarCardsItem(nIndex)
        local bIsTwoCards = BingoHandler:CheckIsTwoStarCardsItem(nIndex)
        local bIsThreeCards = BingoHandler:CheckIsThreeStarCardsItem(nIndex)
        if bIsOneCards or bIsTwoCards or bIsTwoCards then
            local nStarCount = 1
            if bIsOneCards then
                nStarCount = 1
            elseif bIsTwoCards then
                nStarCount = 2
            elseif bIsThreeCards then
                nStarCount = 3
            end
            local stars = self:FindSymbolElement(goSlotsCards, "Stars").transform
            local packTypeContainer = self:FindSymbolElement(goSlotsCards, "KaPaiJieDian").transform
            for j = 0, stars.childCount - 1 do
                if j <= (nStarCount-1) then
                    stars:GetChild(j).gameObject:SetActive(true)
                else
                    stars:GetChild(j).gameObject:SetActive(false)
                end
                packTypeContainer:GetChild(j).gameObject:SetActive(j==(nStarCount-1))
            end
            goSlotsCards:SetActive(true)
        else
            goSlotsCards:SetActive(false)
        end
    else
        goSlotsCards:SetActive(false)
    end
end

function BingoMainUIPop:onSelectWildClicked(item)
    local strSountName = "bingo_generic_click"
    local goWildGet = self:FindSymbolElement(item, "WildGet")
    if goWildGet.activeSelf then
        self.m_nWildCount = self.m_nWildCount + 1
        goWildGet:SetActive(false)
    else
        if self.m_nWildCount > 0 then
            self.m_nWildCount = self.m_nWildCount - 1
            goWildGet:SetActive(true)
        else
            strSountName = "bingo_out_of_balls_alert"
        end
    end
    if self.m_nWildCount ~= BingoHandler.data.nWildCount then
        self.btnFill.interactable = true
    else
        self.btnFill.interactable = false
    end
    self.m_textRemainingWildCount.text = "YOU HAVE "..self.m_nWildCount
    ActivityAudioHandler:PlaySound(strSountName)
end

function BingoMainUIPop:onSelectWildCloseClicked()
    ActivityAudioHandler:PlaySound("bingo_generic_pop_up")
    self.m_goSelectWildWaitUI:SetActive(true)
end

function BingoMainUIPop:onLeaveClickded()
    ActivityAudioHandler:PlaySound("bingo_generic_click")
    self.m_goSelectWildWaitUI:SetActive(false)
    self.m_goSelectWildBingoUI:SetActive(false)
end

function BingoMainUIPop:onStayClicked()
    ActivityAudioHandler:PlaySound("bingo_generic_click")
    self.m_goSelectWildWaitUI:SetActive(false)
end

function BingoMainUIPop:onFillClicked()
    ActivityAudioHandler:PlaySound("bingo_generic_pop_up")
    self.m_goSelectWildMakeSureUI:SetActive(true)
end

function BingoMainUIPop:onNoClickded()
    ActivityAudioHandler:PlaySound("bingo_generic_click")
    self.m_goSelectWildMakeSureUI:SetActive(false)
    self.m_goSelectWildBingoUI:SetActive(false)
end

function BingoMainUIPop:onYesClicked()
    ActivityAudioHandler:PlaySound("bingo_generic_click")
    self.m_goSelectWildMakeSureUI:SetActive(false)
    self.m_goSelectWildBingoUI:SetActive(false)
    local mapGet = {}
    for i = 0, self.m_trSelectBingoContainer.childCount - 1 do
        local item = self.m_trSelectBingoContainer:GetChild(i)
        local nCount = BingoHandler.data.m_bingoMap[i+1]
        local goWildGet = self:FindSymbolElement(item, "WildGet")
        if goWildGet.activeSelf then
            table.insert( mapGet, nCount )
        end
    end
    for k,v in pairs(mapGet) do
        BingoHandler:GetItem(v)
    end

    local reduce = BingoHandler.data.nWildCount - self.m_nWildCount
    BingoHandler:addWildCount(-reduce)
    self:UpdateFeatureTimeUI()

    local bIsBingo = BingoHandler:CheckIsBingo()
    if bIsBingo then
        local winCoins = BingoHandler.m_mapPrize["Level"..BingoHandler.data.nLevel]
        PlayerHandler:AddCoin(winCoins)
        self.nLevelPrizeWinCoin = winCoins
        self.nLevelPrizePlayerCoin = PlayerHandler.nGoldCount
        if BingoHandler.data.nLevel == 5 then
            local winCoins = BingoHandler.fFinalPrize
            PlayerHandler:AddCoin(winCoins)
            self.nFinalPrizeWinCoin = winCoins
            self.nFinalPrizePlayerCoin = PlayerHandler.nGoldCount
            BingoHandler.data.fFinalPrizeRatioMutiplier = BingoHandler.data.fFinalPrizeRatioMutiplier + 0.1
            BingoHandler:updateLevelPrize()
            BingoHandler:SaveDb()
        end
    end

    -- TODO 先加数据，再做动画
    self:ShowGetWildBingoItemAni(mapGet)
end

function BingoMainUIPop:ShowGetWildBingoItemAni(mapGet)
    self:UpdatePickCount()
    self.m_bInSpin = true
    self.m_btnPlay.interactable = false
    self.m_btnClose.interactable = false

    self.m_btnGameIntroduce.interactable = false
    self.m_btnRateTable.interactable = false

    self.btnIconBingo.interactable = false
    self.btnIconWild.interactable = false
    self.btnUseNow.interactable = false
    self.btnIconSuper.interactable = false

    local co = StartCoroutine(function()
        local delayTime = 0
        for k,v in pairs(mapGet) do
            local nCount = v
            local nIndex = LuaHelper.indexOfTable(BingoHandler.data.m_bingoMap, nCount)

            local nCurrentWinCoins = 0
            local bIsCoins = BingoHandler:CheckIsCoinsItem(nIndex)
            if bIsCoins then
                nCurrentWinCoins = BingoHandler:RandomWinCoins()
                PlayerHandler:AddCoin(nCurrentWinCoins)
            else
                local bIsSlotsCardsOpen = SlotsCardsManager:orActivityOpen()
                if bIsSlotsCardsOpen then
                    local bIsOneSlotsCard = BingoHandler:CheckIsOneStarCardsItem(nIndex)
                    if bIsOneSlotsCard then
                        SlotsCardsGiftManager:getStampPackInActive(SlotsCardsAllProbTable.PackType.One, 1)
                    end
                    local bIsTwoSlotsCard = BingoHandler:CheckIsTwoStarCardsItem(nIndex)
                    if bIsTwoSlotsCard then
                        SlotsCardsGiftManager:getStampPackInActive(SlotsCardsAllProbTable.PackType.Two, 1)
                    end
                    local bIsThreeSlotsCard = BingoHandler:CheckIsThreeStarCardsItem(nIndex)
                    if bIsThreeSlotsCard then
                        SlotsCardsGiftManager:getStampPackInActive(SlotsCardsAllProbTable.PackType.Three, 1)
                    end
                end
            end

            ActivityAudioHandler:PlaySound("bingo_generic_click")
            local item = self.m_trBingoContainer:GetChild(nIndex - 1)
            self:ShowItemAni(item)
            self:UpdateItemUI(item, nIndex, nCount)
           
            if nCurrentWinCoins > 0 then
                self:ShowGetCoins(item.position, nCurrentWinCoins)
            else
                local bIsSlotsCardsOpen = SlotsCardsManager:orActivityOpen()
                if bIsSlotsCardsOpen then
                    local bIsOneSlotsCard = BingoHandler:CheckIsOneStarCardsItem(nIndex)
                    local bIsTwoSlotsCard = BingoHandler:CheckIsTwoStarCardsItem(nIndex)
                    local bIsThreeSlotsCard = BingoHandler:CheckIsThreeStarCardsItem(nIndex)
                    local nSlotsCardType = nil
                    if bIsOneSlotsCard then
                        nSlotsCardType = 1
                    end
                    if bIsTwoSlotsCard then
                        nSlotsCardType = 2
                    end                        
                    if bIsThreeSlotsCard then
                        nSlotsCardType = 3
                    end
                    if nSlotsCardType then
                        self:ShowGetSlotsCards(item.position, nSlotsCardType)
                    end
                end
            end            
            
            delayTime = 0.6
            if nCurrentWinCoins > 0 then
                delayTime = delayTime + 6.0
            else
                local bIsSlotsCardsOpen = SlotsCardsManager:orActivityOpen()
                if bIsSlotsCardsOpen then
                    local bIsOneSlotsCard = BingoHandler:CheckIsOneStarCardsItem(nIndex)
                    local bIsTwoSlotsCard = BingoHandler:CheckIsTwoStarCardsItem(nIndex)
                    local bIsThreeSlotsCard = BingoHandler:CheckIsThreeStarCardsItem(nIndex)
                    if bIsOneSlotsCard or bIsTwoSlotsCard or bIsThreeSlotsCard then
                        delayTime = delayTime + 5.1
                    end
                end
            end
            yield_return(Unity.WaitForSeconds(delayTime))
        end
        local bIsBingo = BingoHandler:CheckIsBingo()
        if bIsBingo then
            self:ShowBingoUI()
        end

        self.m_bInSpin = false
        self.m_btnPlay.interactable = true
        self.m_btnClose.interactable = true
        self.m_btnGameIntroduce.interactable = true
        self.m_btnRateTable.interactable = true
        self.btnIconBingo.interactable = true
        self.btnIconWild.interactable = true
        self.btnUseNow.interactable = true
        self.btnIconSuper.interactable = true
	end)
end

function BingoMainUIPop:onActiveTimeChanged()
    local time = ActiveManager:GetRemainTime()
    self.textDate.text = ActivityHelper:FormatTime(time)
end

function BingoMainUIPop:onActiveTimesUp()
    if self.transform.gameObject then
        self.transform.gameObject:SetActive(false)
    end
    if BingoSaleUIPop.transform.gameObject then
        BingoSaleUIPop.transform.gameObject:SetActive(false)
    end
end
