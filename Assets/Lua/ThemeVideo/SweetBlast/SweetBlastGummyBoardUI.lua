SweetBlastGummyBoardUI = {}
--领小熊奖励UI

SweetBlastGummyBoardUI.m_transform = nil -- GummyBoardUI
SweetBlastGummyBoardUI.m_LeanTweenIDs = {} -- 退出关卡时候要取消的leantween动画

-- 4个任务 每个任务里9个礼盒 兑换每个礼盒所需要的Gummy数
SweetBlastGummyBoardUI.m_listMissionGummies = {3500, 5000, 7000, 15000} -- 开礼盒需要的数量
SweetBlastGummyBoardUI.m_listSuperFreeSpins = {15, 15, 15, 8} -- 每个任务奖励的freespin数

SweetBlastGummyBoardUI.m_listgoTextGummies = {}

SweetBlastGummyBoardUI.m_listBonusAni = {} -- 按钮上的动画们
-- 解锁态 未解锁态 打开后的状态等等 对应不同的clip。。。

-- BtnGummyLandInfo 对应信息展示5秒后自动关闭
--TextMeshProCollectNum
-- TextMeshProFreeSpinNum
-- BtnLeftPage    BtnRightPage
SweetBlastGummyBoardUI.m_goBtnLeftPage = nil
SweetBlastGummyBoardUI.m_goBtnRightPage = nil
--SweetBlastGummyBoardUI.m_listBonusInfos = {}
SweetBlastGummyBoardUI.m_nCurrentIndex = 1 -- 1 2 3 4
--小红按钮
SweetBlastGummyBoardUI.m_listGoPageTips = {}
SweetBlastGummyBoardUI.m_listAniPageTips = {}


--active
SweetBlastGummyBoardUI.m_listBtnBox = {} -- btn
--kong
SweetBlastGummyBoardUI.m_listgoBoxBG = {} -- 钱不够兑换的情况下显示
--bg

SweetBlastGummyBoardUI.m_listGoNotEnoughGummiesTipAni = {}
SweetBlastGummyBoardUI.m_listAniNotEnoughGummiesTip = {}
-- NotEnoughGummiesTipAni 是节点m_listgoBoxBG的子节点。。只有钱不够兑换的情况下才可能需要显示。。

SweetBlastGummyBoardUI.nTotalMissions = 4
SweetBlastGummyBoardUI.textMeshProCollectNum = nil
SweetBlastGummyBoardUI.m_listgoBoxLock = {}
SweetBlastGummyBoardUI.m_listTextMeshProCoins = {}

SweetBlastGummyBoardUI.m_listgoRequireBear = {}
SweetBlastGummyBoardUI.m_boxSprite = nil
SweetBlastGummyBoardUI.m_boxEmptySprite = nil
SweetBlastGummyBoardUI.m_textMeshProFreeSpin = nil
SweetBlastGummyBoardUI.m_listgGummyland = {}
SweetBlastGummyBoardUI.m_listgColossal = {}
SweetBlastGummyBoardUI.m_btnClose = nil
SweetBlastGummyBoardUI.m_btnGummyLandInfo = nil

SweetBlastGummyBoardUI.m_goGummyCollectTipAni = nil -- 兑换数量不够的按钮点击之后的展示信息。。
SweetBlastGummyBoardUI.m_aniGummyCollectTip = nil -- 动画控制器。。 默认动画是出场动画，有个分支是退场动画

SweetBlastGummyBoardUI.m_nPopInfoLeanTweenID = 0 -- popInfo...



function SweetBlastGummyBoardUI:initUI()
    local assetPath = "GummyBoardUI.prefab"
    local uiPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    if uiPrefab == nil then
        Debug.Log("------error!!------")
    end
    
    local go = Unity.Object.Instantiate(uiPrefab)
    go.transform:SetParent(SceneSlotGame.m_trPayTableCanvas, false)
    go.transform.localScale = Unity.Vector3.one
    go:SetActive(false)
    self.m_transform = go.transform
    LuaAutoBindMonoBehaviour.Bind(go, self)
    local trClose = self.m_transform:FindDeepChild("BtnGummyLandClose")
    self.m_btnClose = trClose:GetComponent(typeof(UnityUI.Button))

    DelegateCache:addOnClickButton(self.m_btnClose)
    self.m_btnClose.onClick:AddListener(
        function()
            self:onClose()
        end
    )

    local trBoxStatusImagePools = self.m_transform:FindDeepChild("BoxStatusImagePools")
    local trEmptyBox = trBoxStatusImagePools:FindDeepChild("EmptyBox")
    local trNormalBox = trBoxStatusImagePools:FindDeepChild("NormalBox")
    self.m_boxEmptySprite = trEmptyBox:GetComponent(typeof(UnityUI.Image)).sprite
    self.m_boxSprite = trNormalBox:GetComponent(typeof(UnityUI.Image)).sprite
    
    self.m_btnGummyLandInfo = self.m_transform:FindDeepChild("BtnGummyLandInfo"):GetComponent(typeof(UnityUI.Button))
    
    DelegateCache:addOnClickButton(self.m_btnGummyLandInfo)
    self.m_btnGummyLandInfo.onClick:AddListener(
        function()
            self:popinfo()
        end
    )

    self.m_goGummyCollectTipAni = self.m_transform:FindDeepChild("GummyCollectTipAni").gameObject
    self.m_aniGummyCollectTip = self.m_goGummyCollectTipAni:GetComponent( typeof(Unity.Animator) )
    self.m_goGummyCollectTipAni:SetActive(false)

    local trCollectNum = self.m_transform:FindDeepChild("TextMeshProCollectNum")
    self.textMeshProCollectNum = trCollectNum:GetComponent(typeof(UnityUI.Text))
    
    local trFreeSpin = self.m_transform:FindDeepChild("TextMeshProFreeSpin")
    self.m_textMeshProFreeSpin = trFreeSpin:GetComponent(typeof(UnityUI.Text))

    for i = 1, self.nTotalMissions do
        local tr = self.m_transform:FindDeepChild("pageTip" .. i)
        local goPage = tr.gameObject
        self.m_listGoPageTips[i] = goPage

        local aniTip = tr:GetComponentInChildren( typeof(Unity.Animator) )
        self.m_listAniPageTips[i] = aniTip
    end

    self.m_goBtnLeftPage = self.m_transform:FindDeepChild("BtnLeftPage").gameObject

    local btn = self.m_goBtnLeftPage:GetComponent(typeof(UnityUI.Button))
    
    DelegateCache:addOnClickButton(btn)
    btn.onClick:AddListener(
        function()
            self:onClickBtnLeftPage()
        end
    )

    self.m_goBtnRightPage = self.m_transform:FindDeepChild("BtnRightPage").gameObject
    local btn = self.m_goBtnRightPage:GetComponent(typeof(UnityUI.Button))
    
    DelegateCache:addOnClickButton(btn)
    btn.onClick:AddListener(
        function()
            self:onClickBtnRightPage()
        end
    )

    for i=1, 9 do
        local trinfo = self.m_transform:FindDeepChild("BonusInfo" .. i)
        local gomeshtext = trinfo:FindDeepChild("TextGummyNum").gameObject
        local btnBox = trinfo:FindDeepChild("HeZi1").gameObject:GetComponent(typeof(UnityUI.Button))
        local goRequirBear = trinfo:FindDeepChild("ShouJi").gameObject
        local goBG = trinfo:FindDeepChild("HeZi3").gameObject
        local golock = trinfo:FindDeepChild("Lock").gameObject
        local trJiangLi = trinfo:FindDeepChild("JiangLi")
        local textProcoins = trJiangLi:FindDeepChild("TextMeshProCoins"):GetComponent(typeof(UnityUI.Text))
        local goGummyland = trJiangLi:FindDeepChild("Gummyland").gameObject
        local goColossal = trJiangLi:FindDeepChild("Colossal").gameObject

        --NotEnoughGummiesTipAni -- 2018-9-21
        local trNotEnoughTip = trinfo:FindDeepChild("NotEnoughGummiesTipAni")
        if trNotEnoughTip ~= nil then
            local goNotEnoughTip = trNotEnoughTip.gameObject
            local aniNotEnoughTip = goNotEnoughTip:GetComponent( typeof(Unity.Animator) )
            goNotEnoughTip:SetActive(false)
            self.m_listGoNotEnoughGummiesTipAni[i] = goNotEnoughTip
            self.m_listAniNotEnoughGummiesTip[i] = aniNotEnoughTip
        end

        self.m_listBtnBox[i] = btnBox

        DelegateCache:addOnClickButton(btnBox)
        btnBox.onClick:AddListener(function()
            self:onClickBtnBonus(i)
        end)

        self.m_listgoBoxBG[i] = goBG
        self.m_listgoRequireBear[i] = goRequirBear
        self.m_listgoBoxLock[i] = golock
        self.m_listgoTextGummies[i] = gomeshtext
        self.m_listTextMeshProCoins[i] = textProcoins
        self.m_listgGummyland[i] = goGummyland
        self.m_listgColossal[i] = goColossal
    end

end

function SweetBlastGummyBoardUI:initParam()
    --确定 当前页数
    local cnt = self:getOpenedBoxCount()

    self.m_nCurrentIndex = math.modf(cnt / 9) + 1
    if self.m_nCurrentIndex > self.nTotalMissions then
        self.m_nCurrentIndex = self.nTotalMissions
    end

    for i=1, 4 do
        self.m_listGoPageTips[i]:SetActive(false)
    end
    self.m_goBtnLeftPage:SetActive(true)
    self.m_goBtnRightPage:SetActive(true)

    self:setRedPoint(0)
    self:refresh()
    if self.m_nCurrentIndex == 1 then
        self.m_goBtnLeftPage:SetActive(false)
    elseif self.m_nCurrentIndex == self.nTotalMissions then
        self.m_goBtnRightPage:SetActive(false)
    end

    self:refreshTextMeshProCollectNum()

    self.m_textMeshProFreeSpin.text = self.m_listSuperFreeSpins[self.m_nCurrentIndex]
end

function SweetBlastGummyBoardUI:getOpenedBoxCount()
    local cnt = 0
    local collectInfo = SweetBlastLevelParam.m_CollectInfo
    if collectInfo.m_listOpenedBoxInfo == nil then
        cnt = 0
    else
        cnt = #collectInfo.m_listOpenedBoxInfo

        -- 检查数据。。。
        local nCurrentPage = math.modf(cnt / 9) + 1
        if nCurrentPage > 1 then
            for nIndexPage=1, nCurrentPage-1 do
                local listPageBoxKey = {}
                for indexBox=1, 9 do
                    --local key = (nIndexPage-1) * 9 + indexBox
                    listPageBoxKey[indexBox] = false --key
                end

                cnt = #collectInfo.m_listOpenedBoxInfo
                for i=1, cnt do
                    local openedBox = collectInfo.m_listOpenedBoxInfo[i]
                    local key = openedBox.key

                    local page = math.floor( (key-1)/9 ) + 1
                    local indexBox = (key-1) % 9 + 1

                    if page == nIndexPage then
                        listPageBoxKey[indexBox] = true
                    end
                end

                for i=1, 9 do
                    if not listPageBoxKey[i] then
                        Debug.Log("------!!! error!!! error!!! error!!!------")

                        local fCoinValue = collectInfo.m_fAvgTotalBet
                        fCoinValue = MoneyFormatHelper.normalizeCoinCount(fCoinValue, 3) -- 从高到低保留3位非零数字
            
                        local param = {}
                        param.nType = 1
                        param.nCoins = fCoinValue
                        param.m_nFreeSpinNum = 0
                        local key = (nIndexPage-1) * 9 + i
                        param.key = key
            
                        table.insert(collectInfo.m_listOpenedBoxInfo, param)
            
                        SweetBlastLevelParam:saveParam()
                    end
                end
            end
        end
        
        cnt = #collectInfo.m_listOpenedBoxInfo
    end

    return cnt
end

--刷新格子
function SweetBlastGummyBoardUI:refresh()
    for i = 1, 9 do
        self.m_listgoTextGummies[i]:GetComponent(typeof(UnityUI.Text)).text =
            self.m_listMissionGummies[self.m_nCurrentIndex]
    end

    local cnt = self:getOpenedBoxCount()
    local nCurrentPage = math.modf(cnt / 9) + 1

    if SweetBlastLevelParam.m_CollectInfo.m_nCollectNum == nil then
        SweetBlastLevelParam.m_CollectInfo.m_nCollectNum = 0
    end
    if SweetBlastLevelParam.m_CollectInfo.m_nCollectNum < self.m_listMissionGummies[self.m_nCurrentIndex] then
        for i=1, 9 do
            -- 买不起
            self.m_listBtnBox[i].gameObject:SetActive(true)
            self.m_listBtnBox[i].image.sprite = self.m_boxSprite
            self.m_listgoBoxBG[i]:SetActive(true)
            self.m_listgoBoxLock[i]:SetActive(false)
            self.m_listTextMeshProCoins[i].gameObject:SetActive(false)
            self.m_listgoRequireBear[i]:SetActive(true)
            self.m_listgGummyland[i]:SetActive(false)
            self.m_listgColossal[i]:SetActive(false)
            --    self.m_listgoTextGummies[i]:SetActive(true)
        end
    else
        for i=1, 9 do
            -- 买的起
            self.m_listBtnBox[i].gameObject:SetActive(true)
            self.m_listBtnBox[i].image.sprite = self.m_boxSprite
            self.m_listgoBoxBG[i]:SetActive(false)
            self.m_listgoBoxLock[i]:SetActive(false)
            self.m_listTextMeshProCoins[i].gameObject:SetActive(false)
            self.m_listgoRequireBear[i]:SetActive(true)
            self.m_listgGummyland[i]:SetActive(false)
            self.m_listgColossal[i]:SetActive(false)
            --  self.m_listgoTextGummies[i]:SetActive(true)
        end
    end

    --取过的
    for i=1, cnt do
        local OpenedBox = SweetBlastLevelParam.m_CollectInfo.m_listOpenedBoxInfo[i]

        --先判断是不是当前页
        if OpenedBox.key > (self.m_nCurrentIndex - 1) * 9 and OpenedBox.key <= self.m_nCurrentIndex * 9 then
            local nindex = OpenedBox.key - (self.m_nCurrentIndex - 1) * 9
            self.m_listBtnBox[nindex].gameObject:SetActive(true)
            self.m_listBtnBox[nindex].image.sprite = self.m_boxEmptySprite
            self.m_listgoBoxBG[nindex]:SetActive(false)
            self.m_listgoBoxLock[nindex]:SetActive(false)
            self.m_listgoRequireBear[nindex]:SetActive(false)
            if OpenedBox.nType == 1 then
                self.m_listTextMeshProCoins[nindex].text = MoneyFormatHelper.coinCountOmit( OpenedBox.nCoins )
                self.m_listTextMeshProCoins[nindex].gameObject:SetActive(true)
                elseif OpenedBox.nType == 2 then
                    self.m_listgGummyland[nindex]:SetActive(true)
                elseif OpenedBox.nType == 3 then
                    self.m_listgColossal[nindex]:SetActive(true)
            end
        -- self.m_listgoTextGummies[nindex]:SetActive(false)
        end
    end

    --下一页的
    if self.m_nCurrentIndex > nCurrentPage then
        for i = 1, 9 do
            self.m_listBtnBox[i].gameObject:SetActive(false)
            self.m_listgoBoxBG[i]:SetActive(false)
            self.m_listgoBoxLock[i]:SetActive(true)
            self.m_listTextMeshProCoins[i].gameObject:SetActive(false)
            self.m_listgGummyland[i]:SetActive(false)
            self.m_listgColossal[i]:SetActive(false)
            --   self.m_listgoTextGummies[i]:SetActive(true)
        end
    end
end

function SweetBlastGummyBoardUI:onClickBtnBonus(i)
    local requireAmount = SweetBlastGummyBoardUI.m_listMissionGummies[self.m_nCurrentIndex]
    local index = i + (self.m_nCurrentIndex - 1) * 9

    if requireAmount > SweetBlastLevelParam.m_CollectInfo.m_nCollectNum then
        -- pop 买不起
        local bPopTipEnable = true
        for i=1, 9 do
            if self.m_listGoNotEnoughGummiesTipAni[i].activeSelf then
                bPopTipEnable = false
                break
            end
        end
        
        if bPopTipEnable then
            self.m_listGoNotEnoughGummiesTipAni[i]:SetActive(true)
            --self.m_listAniNotEnoughGummiesTip -- 播放某个clip
    
            LeanTween.delayedCall(2.5, function()
                self.m_listAniNotEnoughGummiesTip[i]:SetInteger("nPlayMode", 1) -- 退场动画

                LeanTween.delayedCall(0.65, function()
                    self.m_listGoNotEnoughGummiesTipAni[i]:SetActive(false)
                end)

            end)
        end

        return
    end

    local cnt = self:getOpenedBoxCount()
    for i=1, cnt do
        local OpenedBox = SweetBlastLevelParam.m_CollectInfo.m_listOpenedBoxInfo[i]
        if OpenedBox.key == index then
            -- todo pop 买过了
            return
        end
    end

    AudioHandler:PlayThemeSound("collection_select_item")

    if SlotsGameLua.m_GameResult.m_fGameWin > 0 then
        -- 2018-12-12  Freespin结束就去开礼盒包 直接开出了respin。。这种情况respin里会弹bigwin的bug修改
        
        SlotsGameLua.m_GameResult.m_fGameWin = 0.0
        SceneSlotGame.m_SlotsNumberWins:End(0.0)
        SceneSlotGame:setTotalWinTipInfo("WIN", false)
    end

    --领取奖励
    --param.nType = 0 -- 1: 金币奖励 2: Gummyland 3: Colossal
    local param = self:GetReward(requireAmount, index)
    if param.nType == 1 then
        self:collectCoins(param.nCoins)
    
    elseif param.nType == 2 then
        Debug.Log("-----bonusgame-----")
        -- 让其它按钮不可点击？ 等等

        self:collectBonusGame()

    elseif param.nType == 3 then
        Debug.Log("-----respin-----")

        -- 让其它按钮不可点击？

        self:collectRespin()
    end

    self:refreshTextMeshProCollectNum()

    self:refresh() -- 买了一个之后可能会导致其它的不能购买了 所以盒子的状态都得检查刷新


    local cnt = self:getOpenedBoxCount()
    if cnt == 36 then -- 4页都已经全部打开了。。需要重置..
        SweetBlastLevelParam.m_CollectInfo.m_listOpenedBoxInfo = {}
        SweetBlastLevelParam.m_CollectInfo.m_listGummylandFlag = {false, false, false, false}
        SweetBlastLevelParam.m_CollectInfo.m_listColossalFlag = {false, false, false, false}
    end

    SweetBlastLevelParam:saveParam()

end

function SweetBlastGummyBoardUI:refreshTextMeshProCollectNum()
    --   if SweetBlastLevelParam.m_CollectInfo.m_nCollectNum == nil then
    --       SweetBlastLevelParam.m_CollectInfo.m_nCollectNum = 0
    --   end
    self.textMeshProCollectNum.text = SweetBlastLevelParam.m_CollectInfo.m_nCollectNum

end

function SweetBlastGummyBoardUI:popinfo()
    GlobalAudioHandler:PlayBtnSound()
    
    self.m_btnGummyLandInfo.interactable = false
    LeanTween.delayedCall(1.0, function()
        self.m_btnGummyLandInfo.interactable = true
    end)

    if self.m_goGummyCollectTipAni.activeSelf then
        LeanTween.cancel(self.m_nPopInfoLeanTweenID)
        self.m_aniGummyCollectTip:SetInteger("nPlayMode", 1) -- 退场动画
        LeanTween.delayedCall(1.0, function()
            self.m_goGummyCollectTipAni:SetActive(false)
        end)
    else
        self.m_goGummyCollectTipAni:SetActive(true) -- 会播放默认的出场动画。。
        self.m_nPopInfoLeanTweenID = LeanTween.delayedCall(5.0, function()
            
            self.m_aniGummyCollectTip:SetInteger("nPlayMode", 1) -- 退场动画
            self.m_btnGummyLandInfo.interactable = false
            LeanTween.delayedCall(1.0, function()
                self.m_goGummyCollectTipAni:SetActive(false)
                self.m_btnGummyLandInfo.interactable = true
            end)

        end).id
    end
end

function SweetBlastGummyBoardUI:onClickBtnRightPage()
    AudioHandler:PlayThemeSound("collection_click_button")

    self:setRedPoint(1)
    if self.m_nCurrentIndex == 1 then
        self.m_goBtnLeftPage:SetActive(true)
    end
    self.m_nCurrentIndex = self.m_nCurrentIndex + 1

    if self.m_nCurrentIndex == self.nTotalMissions then
        self.m_goBtnRightPage:SetActive(false)
    end
    self:refresh()

    self.m_textMeshProFreeSpin.text = self.m_listSuperFreeSpins[self.m_nCurrentIndex]
end

function SweetBlastGummyBoardUI:onClickBtnLeftPage()
    AudioHandler:PlayThemeSound("collection_click_button")

    self:setRedPoint(-1)
    if self.m_nCurrentIndex == self.nTotalMissions then
        self.m_goBtnRightPage:SetActive(true)
    end
    self.m_nCurrentIndex = self.m_nCurrentIndex - 1

    if self.m_nCurrentIndex == 1 then
        self.m_goBtnLeftPage:SetActive(false)
    end
    self:refresh()

    self.m_textMeshProFreeSpin.text = self.m_listSuperFreeSpins[self.m_nCurrentIndex]
end

function SweetBlastGummyBoardUI:setRedPoint(movePage)
    self.m_listGoPageTips[self.m_nCurrentIndex]:SetActive(false)
    
    self.m_listGoPageTips[self.m_nCurrentIndex + movePage]:SetActive(true)
end

function SweetBlastGummyBoardUI:OnEnable()
end

function SweetBlastGummyBoardUI:OnEnable()
end

function SweetBlastGummyBoardUI:Start()
end

-- function SweetBlastGummyBoardUI:Update()
-- end

function SweetBlastGummyBoardUI:OnDisable()
end

function SweetBlastGummyBoardUI:OnDestroy()
    local count = #self.m_LeanTweenIDs
    for i = 1, count do
        local id = self.m_LeanTweenIDs[i]
        if LeanTween.isTweening(id) then
            LeanTween.cancel(id)
        end
    end
    self.m_LeanTweenIDs = {}

    self.m_listBtnBox = {}
    self.m_listgoBoxBG = {}
    self.m_listgoRequireBear = {}
    self.m_listgoBoxLock = {}
    self.m_listgoTextGummies = {}
    self.m_listTextMeshProCoins = {}
    self.m_listGoPageTips = {}
    self.m_listBonusAni = {}
    
    self.m_listGoNotEnoughGummiesTipAni = {}
    self.m_listAniNotEnoughGummiesTip = {}

    self.m_listgGummyland = {}
    self.m_listgColossal = {}
    
end

function SweetBlastGummyBoardUI:Show()
    self.m_transform.gameObject:SetActive(true)

    -- 4页全部打开的情况 在领奖的时候重置了。。
    local cnt = self:getOpenedBoxCount()
    if cnt == 36 then -- 4页全部打开..
        Debug.Log("---------error!------------")
        SweetBlastLevelParam.m_CollectInfo.m_listGummylandFlag = {false, false, false, false}
        SweetBlastLevelParam.m_CollectInfo.m_listColossalFlag = {false, false, false, false}
        SweetBlastLevelParam.m_CollectInfo.m_listOpenedBoxInfo = {} -- 打开的盒子信息  
        SweetBlastLevelParam:saveParam()  
    end

    self:initParam()
    
    self:blockButtons(true)

    SceneSlotGame:ButtonEnable(false)
    SceneSlotGame.m_btnSpin.interactable = false
    SceneSlotGame.m_bUIState = true -- 让棋盘别自动滚动 比如auto下 freespin下等。。
end

function SweetBlastGummyBoardUI:hide()
    if not self.m_transform.gameObject.activeSelf then
        return
    end

    self.m_transform.gameObject:SetActive(false)

    local num = SweetBlastLevelParam.m_CollectInfo.m_nCollectNum
    SweetBlastLevelUI.m_TextMeshProCollectNum.text = tostring(num)
    SceneSlotGame.m_bUIState = false
    SceneSlotGame:ButtonEnable(true)
end

function SweetBlastGummyBoardUI:onClose()
    GlobalAudioHandler:PlayBtnSound()
    self:hide()
end

function SweetBlastGummyBoardUI:collectCoins(nCoins)
    PlayerHandler:AddCoin(nCoins)
    LevelDataHandler:AddPlayerWinCoins(nCoins)
    UITop:updateCoinCountInUi(5.0)
end

function SweetBlastGummyBoardUI:collectBonusGame()
    SceneSlotGame:ButtonEnable(false)
    SceneSlotGame.m_btnSpin.interactable = false
    self:blockButtons(false)
    
    SweetBlastLevelUI.m_btnGummyBoard.interactable = false

    -- 标记着已经触发了bonusgame 等bonus结束了再设为false 断线重连需要...
    LevelDataHandler:setBonusGameFlag(ThemeLoader.themeKey, true)

    -- nType 1: 3个bonus牌触发的   2: 姜饼人开箱子兑换到的。。。
    SweetBlastLevelParam:setBonusGameBetByType(2)
    SweetBlastLevelUI.m_bThreeBonusElemTriggerFlag = false

    local id1 = LeanTween.delayedCall(3.5, function()
        self:hide()
        AudioHandler:PlayThemeSound("freePopupStart")

        SweetBlastLevelUI.m_goBonusGameBeginUI:SetActive(true)
        SceneSlotGame.m_btnSpin.interactable = false
    end).id
    table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id1)

    local id2 = LeanTween.delayedCall(6.7, function()
        SweetBlastLevelUI.m_goBonusGameBeginUI:SetActive(false)
        SweetBlastBonusGameUI:Show()
      --  self:blockButtons(true)
    end).id
    table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id2)
    
end

function SweetBlastGummyBoardUI:collectRespin()
    SceneSlotGame:ButtonEnable(false)
    SceneSlotGame.m_btnSpin.interactable = false
    self:blockButtons(false)
    
    SweetBlastLevelUI.m_btnGummyBoard.interactable = false
    
    SlotsGameLua.m_GameResult.m_nReSpinCount = 0
    SlotsGameLua.m_GameResult.m_nReSpinTotalCount = 3

    LevelDataHandler:setReSpinCount(ThemeLoader.themeKey, 3)
    SweetBlastLevelUI:updateRespinCountInfo(3, false) -- 还剩下几次
    
    SweetBlastLevelUI:initGingermanStoreRespinInfo()
    

    local id = LeanTween.delayedCall(2.5, function()
        self:hide()

        SweetBlastLevelUI.m_bRespinFromGummyStore = true
        -- 重新来一遍消息循环检查..
        AudioHandler:PlayThemeSound("respin_triggered")
        SlotsGameLua.m_bSplashFlags[SplashType.ReSpin] = true
        SlotsGameLua.m_bInResult = true
        SlotsGameLua.m_nSplashActive = 1
        SceneSlotGame.m_SlotsNumberWins:End(0)
     --   self:blockButtons(true)
    end).id

    table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id)

end

function SweetBlastGummyBoardUI:blockButtons(isblockbtn)
    self.m_goBtnLeftPage:GetComponent(typeof(UnityUI.Button)).interactable = isblockbtn
    self.m_goBtnRightPage:GetComponent(typeof(UnityUI.Button)).interactable = isblockbtn

    for i=1, 9 do
        local btn = self.m_listBtnBox[i]
        btn.interactable = isblockbtn
    end

    self.m_btnGummyLandInfo.interactable = isblockbtn
    self.m_btnClose.interactable = isblockbtn
end

-- 要求每页9个里面有一个类型2 一个类型3 七个类型1 todo
function SweetBlastGummyBoardUI:GetReward(requireAmount, index)
    local collectInfo = SweetBlastLevelParam.m_CollectInfo
    collectInfo.m_nCollectNum = collectInfo.m_nCollectNum - requireAmount

    local listCoinCoef = {0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0}
    local nCoinIndex = math.random(1, #listCoinCoef)
    local fCoinCoef = listCoinCoef[nCoinIndex]
    local fCoinValue = fCoinCoef * collectInfo.m_fAvgTotalBet
    
    fCoinValue = MoneyFormatHelper.normalizeCoinCount(fCoinValue, 3) -- 从高到低保留3位非零数字
    
    if collectInfo.m_listGummylandFlag == nil then
        collectInfo.m_listGummylandFlag = {false, false, false, false}
    end
    if collectInfo.m_listColossalFlag == nil then
        collectInfo.m_listColossalFlag = {false, false, false, false}
    end

    local bGummylandFlag = collectInfo.m_listGummylandFlag[self.m_nCurrentIndex]
    local bColossalFlag = collectInfo.m_listColossalFlag[self.m_nCurrentIndex]

    local bSpecialFlag = false

    local param = {}
    param.nType = 1
    param.nCoins = 0
    param.m_nFreeSpinNum = 0
    param.key = index
    local fProb = math.random()
    if fProb < 0.75 then
        param.nType = 1
        param.nCoins = fCoinValue
    elseif fProb < 0.875 then
        if bGummylandFlag then
            param.nType = 1
            param.nCoins = fCoinValue
        else
            param.nType = 2 -- Gummyland
            collectInfo.m_listGummylandFlag[self.m_nCurrentIndex] = true
            bGummylandFlag = true

            bSpecialFlag = true
        end
    else
        if bColossalFlag then
            param.nType = 1
            param.nCoins = fCoinValue
        else
            param.nType = 3 -- Colossal
            collectInfo.m_listColossalFlag[self.m_nCurrentIndex] = true
            bColossalFlag = true

            bSpecialFlag = true
        end

    end

    if collectInfo.m_listOpenedBoxInfo == nil then
        collectInfo.m_listOpenedBoxInfo = {}
    end

    -- 这页一共打开的箱子数量
    local nTotal = #collectInfo.m_listOpenedBoxInfo
    local nCurPageOpenedNum = nTotal - (self.m_nCurrentIndex-1) * 9
    if not bSpecialFlag then
        if nCurPageOpenedNum > 4 and not bGummylandFlag then
            param.nType = 2 -- Gummyland
            param.nCoins = 0
            collectInfo.m_listGummylandFlag[self.m_nCurrentIndex] = true
        end
    
        if nCurPageOpenedNum > 6 and not bColossalFlag then
            param.nType = 3 -- Colossal
            param.nCoins = 0
            collectInfo.m_listColossalFlag[self.m_nCurrentIndex] = true
        end
    end

    table.insert(SweetBlastLevelParam.m_CollectInfo.m_listOpenedBoxInfo, param)
    
    -- 所有箱子是否全部打开了，全部打开了领取freespin奖励.. 
    -- 最后一次开箱子只能是金币，不要是 bonusgame 和 respin -- 这点上面的逻辑保证了
    local nTotal = #collectInfo.m_listOpenedBoxInfo
    local nCurPageOpenedNum = nTotal - (self.m_nCurrentIndex-1) * 9
    
    if nCurPageOpenedNum == 9 then

        self:blockButtons(false)
        self:RewardFullBonus()

    end
    
    SweetBlastLevelParam:saveParam()

    return param
end

function SweetBlastGummyBoardUI:RewardFullBonus()
    Debug.Log("-------SweetBlastGummyBoardUI:RewardFullBonus()--------")

    local nCurFullPage = self.m_nCurrentIndex

    self.m_listAniPageTips[nCurFullPage]:SetInteger("nPlayMode", 1)
    local id1 = LeanTween.delayedCall(3.5, function()
        self.m_listAniPageTips[nCurFullPage]:SetInteger("nPlayMode", 0)
    end).id

    table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id1)
    
    local id2 = LeanTween.delayedCall(1.5, function() -- 页收集满的音效
        AudioHandler:PlayThemeSound("collection_page_unlocked")
    end).id

    table.insert(SweetBlastLevelUI.m_LeanTweenIDs, id2)
    

    SceneSlotGame:ButtonEnable(false)
    SceneSlotGame.m_btnSpin.interactable = false
    
    -- self:blockButtons(false) -- 
    
    -- 15  15  15  8
    local nFreeSpinNum = self.m_listSuperFreeSpins[self.m_nCurrentIndex]
    local listWildReelID = {}
    local nFreeSpinType = 0

    local param = SweetBlastLevelParam.m_CollectInfo
    local fFreeSpinBet = param.m_fAvgTotalBet

    if self.m_nCurrentIndex == 1 then
        nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin4X5_2
        listWildReelID = {1, 3}

    elseif self.m_nCurrentIndex == 2 then
        nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin4X5_3
        listWildReelID = {1, 3}

    elseif self.m_nCurrentIndex == 3 then
        nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin4X5_3
        listWildReelID = {2, 3, 4}

    elseif self.m_nCurrentIndex == 4 then
        nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin4X5_4
        listWildReelID = {1, 2, 3, 4}

    else

    end
    
    -- 这里会奖励写数据库 并且打开freespinBegin界面
    SweetBlastLevelUI.m_bThreeBonusElemTriggerFlag = false
    SweetBlastLevelUI:TriggerSweetBlastFreeSpin(nFreeSpinType, nFreeSpinNum, listWildReelID, fFreeSpinBet)

end