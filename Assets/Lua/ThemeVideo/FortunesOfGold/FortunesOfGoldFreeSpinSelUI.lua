FortunesOfGoldFreeSpinSelUI = {}
FortunesOfGoldFreeSpinSelUI.m_transform = nil -- trFreeSpinSelUI
FortunesOfGoldFreeSpinSelUI.m_goFreeSpinSelUI = nil
FortunesOfGoldFreeSpinSelUI.m_btnCoinPrize = nil -- 左按钮
FortunesOfGoldFreeSpinSelUI.m_btnFreeSpin = nil -- 右按钮

FortunesOfGoldFreeSpinSelUI.m_TextMeshProTotalFreeSpins = nil -- 要用于兑换的freespin总次数
FortunesOfGoldFreeSpinSelUI.m_TextMeshProCoinPrizeMax = nil -- 可能兑换到的最大值
FortunesOfGoldFreeSpinSelUI.m_TextMeshProCoinPrizeMin = nil -- 可能兑换到的最小值

FortunesOfGoldFreeSpinSelUI.m_fCoinPrizeMin = 0
FortunesOfGoldFreeSpinSelUI.m_fCoinPrizeMax = 0
FortunesOfGoldFreeSpinSelUI.m_fCoinPrize = 0 -- 实际兑换到了多少
FortunesOfGoldFreeSpinSelUI.m_fTotalWin = 0 -- freespin已经赢得的加上兑换到的

-- 兑换结果展示
FortunesOfGoldFreeSpinSelUI.m_goCoinPrizeEnd = nil
FortunesOfGoldFreeSpinSelUI.m_TextMeshProCoinPrizeValue = nil

function FortunesOfGoldFreeSpinSelUI:initFreeSpinSelUI()
	local strFullName = "FreeSpinsSelect.prefab"
	local SelObj = AssetBundleHandler:LoadThemeAsset(strFullName, typeof(Unity.GameObject))
	if SelObj ~= nil then
		local goFreeSpinSel = Unity.Object.Instantiate(SelObj)
        goFreeSpinSel.transform:SetParent(ThemeVideoScene.mPopWorldCanvas, false)
		goFreeSpinSel.name = "FreeSpinSel"
        goFreeSpinSel:SetActive(false)
        self.m_goFreeSpinSelUI = goFreeSpinSel
        self.m_transform = goFreeSpinSel.transform

        LuaAutoBindMonoBehaviour.Bind(goFreeSpinSel, self)

        local trFreeSpinNum = goFreeSpinSel.transform:FindDeepChild("TextMeshProFreeSpinNum")
        self.m_TextMeshProTotalFreeSpins = trFreeSpinNum:GetComponent(typeof(TextMeshProUGUI))
        self.m_TextMeshProTotalFreeSpins.text = "0"

        local trCoinPrizeMax = goFreeSpinSel.transform:FindDeepChild("TextMeshProCoinPrizeMax")
        self.m_TextMeshProCoinPrizeMax = trCoinPrizeMax:GetComponent(typeof(TextMeshProUGUI))
        self.m_TextMeshProCoinPrizeMax.text = "0"

        local trCoinPrizeMin = goFreeSpinSel.transform:FindDeepChild("TextMeshProCoinPrizeMin")
        self.m_TextMeshProCoinPrizeMin = trCoinPrizeMin:GetComponent(typeof(TextMeshProUGUI))
        self.m_TextMeshProCoinPrizeMin.text = "0"

        local trBtnCoinPrize = goFreeSpinSel.transform:FindDeepChild("BtnCoinPrize")
        self.m_btnCoinPrize = trBtnCoinPrize:GetComponent(typeof(UnityUI.Button))
        self.m_btnCoinPrize.onClick:AddListener(function()
            self:onCoinPrizeBtnClick()
        end)

        local trBtnFreeSpin = goFreeSpinSel.transform:FindDeepChild("BtnFreeSpin")
        self.m_btnFreeSpin = trBtnFreeSpin:GetComponent(typeof(UnityUI.Button))
        self.m_btnFreeSpin.onClick:AddListener(function()
            self:onFreeSpinBtnClick()
        end)

    end
    
    --m_goCoinPrizeEnd
	local strFullName = "CoinPrizeEnd.prefab"
	local CoinPrizeEndObj = AssetBundleHandler:LoadThemeAsset(strFullName, typeof(Unity.GameObject))
	if CoinPrizeEndObj ~= nil then
		local goCoinPrizeEnd = Unity.Object.Instantiate(CoinPrizeEndObj)
        goCoinPrizeEnd.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
		goCoinPrizeEnd.name = "CoinPrizeEnd"
        goCoinPrizeEnd:SetActive(false)
        self.m_goCoinPrizeEnd = goCoinPrizeEnd
        
        local trBtnCollect = goCoinPrizeEnd.transform:FindDeepChild("ButtonCollect")
        local btnCollect = trBtnCollect:GetComponent(typeof(UnityUI.Button))
        btnCollect.onClick:AddListener(function()
            self:onCoinPrizeCollectBtnClick()
        end)

        local trCoinPrizeValue = goCoinPrizeEnd.transform:FindDeepChild("TextMeshProCoinPrizeValue")
        self.m_TextMeshProCoinPrizeValue = trCoinPrizeValue:GetComponent(typeof(TextMeshProUGUI))
        self.m_TextMeshProCoinPrizeValue.text = "0"

    end

end

function FortunesOfGoldFreeSpinSelUI:Start()

end

function FortunesOfGoldFreeSpinSelUI:Update()
end

function FortunesOfGoldFreeSpinSelUI:OnDisable()
    
end

function FortunesOfGoldFreeSpinSelUI:OnDestroy()
end

function FortunesOfGoldFreeSpinSelUI:showFreeSpinSelUI(bShow)
    if bShow then
        SceneSlotGame.m_bUIState = true -- 让棋盘不要滚动。。。
        self.m_fCoinPrize = 0
        self.m_fTotalWin = 0

        self:initSelUIParam()
        self.m_goFreeSpinSelUI:SetActive(true)

        -- 所有列停止的时候调用 HandleAllReelStopAudio 会把背景音停掉
        -- 最好的做法是等列停止了 如果这个界面还开着再播对应背景音 todo
        LeanTween.delayedCall(1.5, function()
            AudioHandler:LoadAndPlayThemeMusic("music_selection")
        end)

    else
        SceneSlotGame.m_bUIState = false -- 窗口关闭了之后让棋盘允许滚动。。。
        self.m_goFreeSpinSelUI:SetActive(false)

        if SlotsGameLua.m_GameResult:InFreeSpin() then
            AudioHandler:LoadFreeGameMusic()
        else
            AudioHandler:LoadBaseGameMusic()
        end
    end
end

function FortunesOfGoldFreeSpinSelUI:initSelUIParam()
    -- m_TextMeshProTotalFreeSpins = nil -- 要用于兑换的freespin总次数
    -- m_TextMeshProCoinPrizeMax = nil -- 可能兑换到的最大值
    -- m_TextMeshProCoinPrizeMin = nil -- 可能兑换到的最小值

    local nRestFreeSpin = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount
    nRestFreeSpin = nRestFreeSpin - SlotsGameLua.m_GameResult.m_nFreeSpinCount
    self.m_TextMeshProTotalFreeSpins.text = tostring(nRestFreeSpin)

    if self.m_nRestFreeSpin ~= nRestFreeSpin then
        self.m_nRestFreeSpin = nRestFreeSpin
        
        local fRandomMax = math.random(50, 100)
        fRandomMax = fRandomMax / 10
        local fRandomMin = math.random(3, 5)
        fRandomMin = fRandomMin / 10

        local nTotalBet = SceneSlotGame.m_nTotalBet
    
        self.m_fCoinPrizeMin = math.floor( fRandomMin * nTotalBet * nRestFreeSpin)
        self.m_fCoinPrizeMax = math.floor( fRandomMax * nTotalBet * nRestFreeSpin)
    end
    
    local strMin = MoneyFormatHelper.numWithCommas( math.floor(self.m_fCoinPrizeMin) )
    self.m_TextMeshProCoinPrizeMin.text = strMin
    local strMax = MoneyFormatHelper.numWithCommas( math.floor(self.m_fCoinPrizeMax) )
    self.m_TextMeshProCoinPrizeMax.text = strMax

end

function FortunesOfGoldFreeSpinSelUI:onCoinPrizeBtnClick()
	AudioHandler:PlayBtnSound()
    Debug.Log("--------onCoinPrizeBtnClick----------")

    if SlotsGameLua.m_bInSpin then
        return
    end

    self:showFreeSpinSelUI(false)

    FortunesOfGoldLevelUI.m_goFreeSpinUI:SetActive(false)

    self:showCoinPrizeEndUI(true)

end

function FortunesOfGoldFreeSpinSelUI:onFreeSpinBtnClick()
	AudioHandler:PlayBtnSound()
    Debug.Log("--------onFreeSpinBtnClick----------")
    self:showFreeSpinSelUI(false)
end

function FortunesOfGoldFreeSpinSelUI:onCoinPrizeCollectBtnClick()
	AudioHandler:PlayBtnSound()
    Debug.Log("--------onCoinPrizeCollectBtnClick----------")

    self:showCoinPrizeEndUI(false)

end

function FortunesOfGoldFreeSpinSelUI:showCoinPrizeEndUI(bShow)
    if bShow then
        SceneSlotGame.m_bUIState = true -- 让棋盘不要滚动。。。
        self.m_fCoinPrize = self:getCoinPrizeParam()
        self.m_fTotalWin = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins + self.m_fCoinPrize

        SlotsGameLua.m_GameResult.m_fGameWin = self.m_fTotalWin

        local strInfo = MoneyFormatHelper.numWithCommas( math.floor( self.m_fCoinPrize ) )
        self.m_TextMeshProCoinPrizeValue.text = strInfo

        -- 写数据库等
        self:refreshUserData()
        
        self.m_goCoinPrizeEnd:SetActive(true)
    else -- 点了收集按钮
        SceneSlotGame.m_bUIState = false -- 窗口关闭了之后让棋盘允许滚动。。。
        
        -- 界面参数展示
        local ftime = 3.6
        UITop:updateCoinCountInUi(ftime)
		SceneSlotGame.m_SlotsNumberWins:ChangeTo(self.m_fTotalWin, ftime)
        
        SlotsGameLua.m_GameResult.m_nFreeSpinCount = 0
        SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount = 0
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = 0
        SlotsGameLua.m_GameResult.m_nNewFreeSpinCount = 0

        -- 还原界面
        SceneSlotGame:ShowFreeSpinUI(false)
        self.m_goCoinPrizeEnd:SetActive(false)
        
        -- 2018--6--24
        if SlotsGameLua.m_bAutoSpinFlag then
            SlotsGameLua.m_bAutoSpinFlag = false
        end

        SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_SpinEnable
        SpinButton:SetButtonSprite(enumButtonType.ButtonType_Spin)
        SceneSlotGame:ButtonEnable(true) -- CoinPrizeEndUI 不是在标准消息循环里弹出的窗口 所以必须手动控制
    end
end

function FortunesOfGoldFreeSpinSelUI:getCoinPrizeParam()
    -- 1. 模拟运行结果 一次结算掉。。
    local nTotalBet = SceneSlotGame.m_nTotalBet
    local fRandomCoef = math.random(80, 220)
    -- freespin 里中奖乘2 所以比basegame下是要高些
    fRandomCoef = fRandomCoef / 100.0
    local fCoinPrize = self.m_nRestFreeSpin * fRandomCoef * nTotalBet

    return fCoinPrize
end

function FortunesOfGoldFreeSpinSelUI:getCoinPrizeParam_Simulation(nFreeSpinNum)
    -- 1. 模拟运行结果 一次结算掉。。
    local nTotalBet = SceneSlotGame.m_nTotalBet
    local fRandomCoef = math.random(80, 220)
    -- freespin 里中奖乘2 所以比basegame下是要高些
    fRandomCoef = fRandomCoef / 100.0
    local fCoinPrize = nFreeSpinNum * fRandomCoef * nTotalBet
    return fCoinPrize
end

function FortunesOfGoldFreeSpinSelUI:refreshUserData()
    local strLevelName = ThemeLoader.themeKey
    LevelDataHandler:setFreeSpinCount(strLevelName, 0)
    LevelDataHandler:setTotalFreeSpinCount(strLevelName, 0)
    LevelDataHandler:setFreeSpinTotalWin(strLevelName, 0)

    PlayerHandler:AddCoin(self.m_fTotalWin)
    LevelDataHandler:AddPlayerWinCoins(self.m_fTotalWin)
end
