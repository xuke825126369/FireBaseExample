LuckyJumpGamePop = {} --包括两个界面，一个是转盘，一个是活动游戏界面
LuckyJumpGamePop.m_content = nil

LuckyJumpGamePop.m_textMoveCount = nil
LuckyJumpGamePop.m_textReward = nil

LuckyJumpGamePop.m_nCurWinCoins = 0



function LuckyJumpGamePop:Show()
    if self.asynLoadCo == nil then
        self.asynLoadCo = StartCoroutine(function()
            Scene.loadingAssetBundle:SetActive(true)
            LuckyJumpAssetBundleHandler:asynLoadLuckyJumpAssetBundle()
            while not LuckyJumpUnloadedUI.m_bAssetReady do
                yield_return(0)
            end
            Scene.loadingAssetBundle:SetActive(false)
            self:Show()
            self.asynLoadCo = nil
        end)
    end
end

function LuckyJumpGamePop:Show()
    --TODO 判断是否为竖屏
    self.m_bPortraitFlag = false
    if ThemeLoader.themeKey ~= nil then
        self.m_bPortraitFlag = GameLevelUtil:isPortraitLevel()
        SlotsGameLua.m_bReelPauseFlag = true
    end
    if self.m_bPortraitFlag then
        Debug.Log("切横屏")
        Scene:SwitchScreenOp(true) -- 变成横屏
    end
    if self.transform.gameObject == nil then
        local strPath = "Assets/LuckyJump/LuckyJumpGame.prefab"
        local prefabObj = Util.getLuckyJumpPrefab(strPath)
        self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
        self.transform = self.transform.gameObject.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.m_content = self.transform:FindDeepChild("Content")
        -- self.popController = PopController:new(self.transform.gameObject)
        if self.m_content and Unity.Screen.width > Unity.Screen.height then
            local screenRatio = Unity.Screen.width / Unity.Screen.height
            local scale = (2 - screenRatio) / 2 + 1
            if GameConfig.IS_GREATER_169 then
                scale = 1
            end
            self.m_content.localScale = Unity.Vector3(scale, scale, scale)
        end
        self.m_nCurWinCoins = 0
        self.textWinCoins = self.transform:FindDeepChild("TextJinBi"):GetComponent(typeof(TextMeshProUGUI))
        self.textFinalReward = self.transform:FindDeepChild("FinalReward"):GetComponent(typeof(UnityUI.Text))
        self.m_trArrow = self.transform:FindDeepChild("Arrow")
        self.m_btnMove = self.transform:FindDeepChild("MoveBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_btnMove.onClick:AddListener(function()
            self:onMoveBtnClicked()
        end)

        local btnClose = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
        btnClose.onClick:AddListener(function()
            self:hide()
        end)

        local btnPayTable = self.transform:FindDeepChild("BtnIntroduce"):GetComponent(typeof(UnityUI.Button))
        btnPayTable.onClick:AddListener(function()
            LuckyJumpPayTablePop:Show()
        end)
        self.m_textMoveCount = self.transform:FindDeepChild("MoveCount"):GetComponent(typeof(TextMeshProUGUI))
        self.m_goTextStop = self.transform:FindDeepChild("TextStop").gameObject
        self.m_goTextMove = self.transform:FindDeepChild("TextMove").gameObject
        self.m_textLevel = self.transform:FindDeepChild("TextDiTu"):GetComponent(typeof(TextMeshProUGUI))

        -- self.m_textReward = self.m_trWheelUI:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
    end
    self.transform:SetAsLastSibling()

    -- LuckyJumpManager:generateGameItem()
    LuckyJumpManager:initGameItem() --生成游戏界面

    self.transform.gameObject:SetActive(true)
    self:setBtnMoveInteractable(true)
    self:refreshText()
end

function LuckyJumpGamePop:refreshText()
    self.textFinalReward.text = MoneyFormatHelper.numWithCommas(LuckyJumpDataHandler.m_mapPrize["Level"..LuckyJumpDataHandler.data.nLevel])
    self.m_textMoveCount.text = LuckyJumpDataHandler.data.nMoveCount
    self.m_textLevel.text = LuckyJumpDataHandler.data.nLevel.."/"..#LuckyJumpConfig
    self.textWinCoins.text = MoneyFormatHelper.numWithCommas(LuckyJumpManager.m_nWinCoins)
end

function LuckyJumpGamePop:setBtnMoveInteractable(trueFlag)
    self.m_btnMove.interactable = trueFlag
    self.m_goTextStop:SetActive(not trueFlag)
    self.m_goTextMove:SetActive(trueFlag)
    self.m_textMoveCount.gameObject:SetActive(trueFlag)
end

function LuckyJumpGamePop:onMoveBtnClicked()
    if LuckyJumpManager:checkIsFirstIn() then
        return
    end
    self:setBtnMoveInteractable(false)
    if LuckyJumpDataHandler.data.nMoveCount <= 0 then
        self:setBtnMoveInteractable(true)
        LuckyJumpIntroducePop:Show()
        return
    end
    LuckyJumpDataHandler:addMoveCount(-1)
    LuckyJumpUnloadedUI:refreshMoveCount()
    self.m_textMoveCount.text = LuckyJumpDataHandler.data.nMoveCount

    local nWheelIndex = math.random( 1, 6 )
    local pos = LuckyJumpManager.m_curPlayerPos
    if nWheelIndex == 1 then --对应为向上
        pos = {pos[1]-1, pos[2]}
    elseif nWheelIndex == 2 then --对应为向右上
        if pos[2]%2 == 0 then
            pos = {pos[1], pos[2]+1}
        else
            pos = {pos[1]-1, pos[2]+1}
        end
    elseif nWheelIndex == 3 then --对应为向右下
        if pos[2]%2 == 0 then
            pos = {pos[1]+1, pos[2]+1}
        else
            pos = {pos[1], pos[2]+1}
        end
    elseif nWheelIndex == 4 then --对应为向下
        pos = {pos[1]+1, pos[2]}
    elseif nWheelIndex == 5 then --对应为向左下
        if pos[2]%2 == 0 then
            pos = {pos[1]+1, pos[2]-1}
        else
            pos = {pos[1], pos[2]-1}
        end
    elseif nWheelIndex == 6 then --对应为向左上
        if pos[2]%2 == 0 then
            pos = {pos[1], pos[2]-1}
        else
            pos = {pos[1]-1, pos[2]-1}
        end
    end
    --这里面检查了奖励
    LuckyJumpManager:setCurPlayerPos(pos)

    local toDegree = -360 * 5 - 360 / 6 * (nWheelIndex-1)
    LeanTween.value(0, toDegree, 2.0):setEase (LeanTweenType.easeOutQuad):setOnUpdate(function(value)
        if self.transform.gameObject == nil then
            return
        end
        local index = math.floor((math.floor(value) % 360 + 18 ) / 36) + 1
        self.m_trArrow.rotation = Unity.Quaternion.Euler(0, 0, value)
    end):setOnComplete(function()
        if self.transform.gameObject == nil then
            return
        end
        LuckyJumpManager:beginMoveTo()
        LeanTween.delayedCall(2,function()
            if self.transform.gameObject == nil then
                return
            end
            self:setBtnMoveInteractable(true)
        end)
    end)
end

function LuckyJumpGamePop:hide()
    if ThemeLoader.themeKey ~= nil then
        SlotsGameLua.m_bReelPauseFlag = false
    end
    if LuckyJumpManager.m_nWinCoins ~= 0 then
        LuckyJumpWinCollectPop:Show(function()
            self:hideDown()
        end)
    else
        self:hideDown()
    end
end

function LuckyJumpGamePop:hideDown()
    if self.m_bPortraitFlag then
        Debug.Log("切屏")
        Scene:SwitchScreenOp(false)
        self.m_bPortraitFlag = false
    end
    self.transform.gameObject:SetActive(false)
    Unity.Object.Destroy(self.transform.gameObject)
    LuckyJumpManager.m_mapItem = {}
    LuckyJumpManager.m_curPlayerPos = {0,0}
    LuckyJumpManager.m_player = nil
    LuckyJumpManager.levelTr = nil
    LuckyJumpManager.m_nWinCoins = 0
    if LuckyJumpPickATilePop.transform ~= nil then
        Unity.Object.Destroy(LuckyJumpPickATilePop.transform.gameObject)
        LuckyJumpPickATilePop.transform.gameObject = nil
        LuckyJumpPickATilePop.m_mapBeginPos = {}
        LuckyJumpPickATilePop.m_mapBeginBtn = {}
    end
    if LuckyJumpOutOfMovePop.transform ~= nil then
        Unity.Object.Destroy(LuckyJumpOutOfMovePop.transform.gameObject)
        LuckyJumpOutOfMovePop.transform.gameObject = nil
    end
    if LuckyJumpWinCollectPop.transform ~= nil then
        Unity.Object.Destroy(LuckyJumpWinCollectPop.transform.gameObject)
        LuckyJumpWinCollectPop.transform.gameObject = nil
    end
end

function LuckyJumpGamePop:coinFly(worldStart, count)
    local pos = self.textWinCoins.transform.position
	GlobalAudioHandler:playCoinBeginFly()
	local posStart = Unity.Vector3(worldStart.x, worldStart.y, worldStart.z)
	local posEnd = Unity.Vector3(pos.x, pos.y, pos.z)
	CS.CoinFly.instance:Fly(posStart, posEnd, count, function()
		GlobalAudioHandler:playCoinCollection(0.12 * count)
		self:updateCoinCountInUi(0.5)
	end)
end

function LuckyJumpGamePop:updateCoinCountInUi(time)
    if(self.coinNumTween and self.coinNumTween.isTweening) then
		NumberTween:cancel(self.coinNumTween)
	end
	self.coinNumTween = NumberTween:value(self.m_nCurWinCoins, LuckyJumpManager.m_nWinCoins, time):setOnUpdate(function(value) 
		self.m_nCurWinCoins = value
		self.textWinCoins.text = MoneyFormatHelper.numWithCommas(value)
	end)
end