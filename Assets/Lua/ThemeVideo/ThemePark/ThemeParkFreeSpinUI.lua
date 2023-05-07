--[[
    author:coldflag
    time:2021-08-24 16:18:03
]]
ThemeParkFreeSpinUI = {}

LevelUI = ThemeParkLevelUI

ThemeParkFreeSpinUI.mapFreeSpinMapPos = {} -- FreeSpin时候的地图需要保存的元素位置
ThemeParkFreeSpinUI.goCharacter = nil -- FreeSpin中移动人物头像的游戏对象
ThemeParkFreeSpinUI.trLittleGameMap = nil -- 游乐场小游戏地图
ThemeParkFreeSpinUI.trCharacterCard = nil -- 显示人物信息的卡牌（prize， 倍乘系数等信息）
ThemeParkFreeSpinUI.trFreeSpinScene = nil -- 整个FreeSpin场景

ThemeParkFreeSpinUI.mapGoScatter = {} -- 保存了在FreeSpin期间出现的Scatter对象
ThemeParkFreeSpinUI.mapGoCharRewardEffect = {} -- 保存了在FreeSpin期间在相应线上出现和选择的角色相同的符号时候播放的环绕粒子特效对象
ThemeParkFreeSpinUI.mapPosVec3 = {} -- 保存了人物移动期间经过的坐标
ThemeParkFreeSpinUI.bIsCharactrerMoveFinished = true






function ThemeParkFreeSpinUI:Init()

    self.transform = ThemeVideo2020Scene.mNewGameNodeParent.transform:FindDeepChild("LevelBG")
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)


    -- self.goCharacter = self.transform:FindDeepChild("MapBroB").gameObject -- 投骰子的时候移动的人物头像

    self.trLittleGameMap = self.transform:FindDeepChild("Map")
    self:SetMapStartBtnListener()

    local trDice1 = self.transform:FindDeepChild("Shaizi")
    local trDice2 = self.transform:FindDeepChild("shaizix2")
    self.trDice = {trDice1, trDice2}

    -- 投骰子的时候移动的人物头像
    local goMapBroB = self.transform:FindDeepChild("MapBroB").gameObject
    local goMapBroG = self.transform:FindDeepChild("MapBroG").gameObject
    local goMapBroM = self.transform:FindDeepChild("MapBroM").gameObject
    local goMapBroD = self.transform:FindDeepChild("MapBroD").gameObject
    self.mapGoCharacter = {goMapBroB, goMapBroG, goMapBroM, goMapBroD} 

    -- 地图右下方的人物卡片
    local trKapai = self.transform:FindDeepChild("Kapai")
    local goKapaiBoy = trKapai.transform:FindDeepChild("KapaiBoy").gameObject
    local goKapaiGirl = trKapai.transform:FindDeepChild("KapaiGirl").gameObject
    local goKapaiMom = trKapai.transform:FindDeepChild("KapaiMom").gameObject
    local goKapaiDad = trKapai.transform:FindDeepChild("KapaiDad").gameObject
    self.mapGoCard = {goKapaiBoy, goKapaiGirl, goKapaiMom, goKapaiDad}

    -- 获取FreeSpin的地图上所需要的位置坐标
    self.trFreeSpinScene = self.transform:FindDeepChild("FreeGamesScene") -- 获取FreeSpin的背景节点
    local mapNormalPos = {}
    local mapShutcutA = {}
    local mapShutcutB = {}
    local mapShutcutC = {}
    for i = 1, 43 do
        local strPosName = "pos" .. i
        local trPos = self.trFreeSpinScene.transform:FindDeepChild(strPosName)
        table.insert(mapNormalPos, trPos.localPosition)  -- Pos[1]中存放着普通位置坐标
    end
    table.insert(self.mapFreeSpinMapPos, mapNormalPos)

    for i = 1, 3 do
        local strPosName = "posa" .. i
        local trPos = self.trFreeSpinScene.transform:FindDeepChild(strPosName)
        table.insert(mapShutcutA, trPos.localPosition)  -- Pos[2]中存放着第一个捷径位置坐标
    end
    table.insert( self.mapFreeSpinMapPos, mapShutcutA)

    for i = 1, 2 do
        local strPosName = "posb" .. i
        local trPos = self.trFreeSpinScene.transform:FindDeepChild(strPosName)
        table.insert(mapShutcutB, trPos.localPosition)  -- Pos[1]中存放着第二个捷径位置坐标
    end
    table.insert( self.mapFreeSpinMapPos, mapShutcutB)

    do
        local strPosName = "posc1"
        local trPos = self.trFreeSpinScene.transform:FindDeepChild(strPosName)
        table.insert(mapShutcutC, trPos.localPosition)  -- Pos[1]中存放着第三个捷径位置坐标
    end
    table.insert( self.mapFreeSpinMapPos, mapShutcutC)

end

--[[
    @desc: 展示进入小游戏之前，选择角色的画面
    author:coldflag
    time:2021-08-27 10:48:41
    @return:
]]
function ThemeParkFreeSpinUI:ShowCharacterSelectScene()
    -- 先读数据库，如果读到有nCharacterID的话，则跳过选择人物界面，并将人物置于上次的位置，直接展示
    local nCharacterID = LevelUI.CharacterSelectUI:getSelectedCharIDFromDB()

    if nCharacterID == nil then
        SceneSlotGame.m_bUIState = true
        ThemeParkFreeSpin:ResetCharacterPosition()
        LevelUI.CharacterSelectUI:Show()
    else
        ThemeParkLevelUI.CharacterSelectUI:FlushCharacterID(nCharacterID)
        -- 此处是说明是上次FreeSpin中途退出了
        local structPosition = ThemeParkFreeSpin:getCharPositionFromDB()
        if structPosition == nil then
            structPosition = {1, 1} -- 说明还没保存过，也就是说没有结算过，那就将位置设置为初始位置
        end
        
        self:SetCharacterPosition(nCharacterID, structPosition[1], structPosition[2])
        self:GetCardParticle(nCharacterID)
        self:ShowCorrectCharacter(nCharacterID)
        local fCardPrize = ThemeParkFreeSpin:getCharPrizeFromDB()
        local nMulti = ThemeParkFreeSpin:getCharMultiplierFromDB()
        if fCardPrize ~= nil and nMulti ~= nil then
            ThemeParkFreeSpin:SetCharacterData(nCharacterID, "prize", fCardPrize)
            ThemeParkFreeSpin:SetCharacterData(nCharacterID, "multiplier", nMulti)
            self:ChangeCardPrize(fCardPrize)
            self:ChangeCardMulti(nMulti)
        end

        local Vec3PosMapContent = Unity.Vector3.zero
        if ThemeParkFreeSpin:IsNeedToDownMap() then
            Vec3PosMapContent = Unity.Vector3(0, -500, 0)
            self.bHasDownMap = true
        else
            Vec3PosMapContent = Unity.Vector3(0, 0, 0)
        end
        local trMapContent = self.trLittleGameMap:FindDeepChild("MapContent")
        trMapContent.localPosition = Vec3PosMapContent
        local trBtnStartPlayground = self.trLittleGameMap:FindDeepChild("StartBtn")
        trBtnStartPlayground.gameObject:SetActive(true)

        local Vec3PosEnd = Unity.Vector3(0, 800, 0)
        self.trLittleGameMap.localPosition = Vec3PosEnd
        self.trLittleGameMap.gameObject:SetActive(true)
        self.trFreeSpinScene.gameObject:SetActive(true)
        local goMapStartBtn = self.trLittleGameMap:FindDeepChild("StartBtn").gameObject
        goMapStartBtn:SetActive(false)
    end
end

function ThemeParkFreeSpinUI:RecoverFreeSpin()
    local nDBFreeSpins = LevelDataHandler:getFreeSpinCount(ThemeLoader.themeKey)
    local nTotalDBFreeSpins = LevelDataHandler:getTotalFreeSpinCount(ThemeLoader.themeKey)
    
    -- nDBFreeSpins = 10
    -- nTotalDBFreeSpins = 10

    if nDBFreeSpins > nTotalDBFreeSpins then
        nDBFreeSpins = 0
        nTotalDBFreeSpins = 0

        LevelDataHandler:setFreeSpinCount(ThemeLoader.themeKey, 0)
        LevelDataHandler:setTotalFreeSpinCount(ThemeLoader.themeKey, 0)
        
        Debug.LogError("----------------------- 游戏数据异常 -----------------------")
    end

    if nDBFreeSpins > 0 then

        SlotsGameLua.m_GameResult.m_nNewFreeSpinCount = nDBFreeSpins
        SlotsGameLua.m_GameResult.m_nFreeSpinCount = nTotalDBFreeSpins - nDBFreeSpins
        SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount = nTotalDBFreeSpins
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = LevelDataHandler:getFreeSpinTotalWin(ThemeLoader.themeKey)
        
        SlotsGameLua.m_GameResult.m_bInSuperFreeSpin = LevelDatabase:Load("SlotsGameLua.m_GameResult.m_bInSuperFreeSpin", false)
        --self.m_GameResult.m_bInSuperFreeSpin = true
        SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins

        SceneSlotGame.m_SlotsNumberWins:End(SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins)  --//更新界面显示。。。
        SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_NFreeSpin

        SceneSlotGame:ShowFreeSpinUI(true)

        AudioHandler:LoadFreeGameMusic()
        
        local fDelayTime = 2.0
        if GameConfig.PLATFORM_EDITOR_TEST then
            fDelayTime = 3.5
        end
        -- SlotsGameLua:Spinable() 在fDelayTime时间内返还false
        -- 延迟点开始spin
        SceneSlotGame.m_bUIState = true
        LeanTween.delayedCall(fDelayTime, function()
            SceneSlotGame.m_bUIState = false
        end)
        
    else
        if nTotalDBFreeSpins>0 then
            --//freeSpin结束但是还没有弹出界面或者弹出界面了但是没有点collect就杀进程了，再次进入的时候就是这种情况处理
            SceneSlotGame:collectFreeSpinTotalWins()
            LevelUI.CharacterSelectUI:FlushCharacterID(nil) -- 此处是为了修复当FreeSpin为0且未点击Collect的时候杀进程，未走FreeSpinEnd流程，导致SelectedCharacterID没有置为nil, 所以下次新触发FreeSpinBegin时，进入FreeSpin会跳过选择人物界面
        end

    end

    if nDBFreeSpins==0 then
        AudioHandler:LoadBaseGameMusic()
    end
end


function ThemeParkFreeSpinUI:HideCharacterSelect()
    LevelUI.CharacterSelectUI:Hide()
end

--[[
    @desc: 播放选择角色画面到地图画面的过场动画
    author:coldflag
    time:2021-08-30 10:34:25
    @return:
]]
function ThemeParkFreeSpinUI:PlaySelectChar_To_MapCutScene(nCharacterID)
    -- 暂时好像没资源？
end

--[[
    @desc: 给小地图上的Start按钮添加监听函数
    author:coldflag
    time:2021-08-30 15:45:41
    @return:
]]
function ThemeParkFreeSpinUI:SetMapStartBtnListener()
    local trMapStartBtn = self.trLittleGameMap:FindDeepChild("StartBtn")
    if trMapStartBtn ~= nil then
        local Btn = trMapStartBtn:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(Btn)
        Btn.onClick:AddListener(function()
            self:MapStartBtnListener(trMapStartBtn.gameObject)
        end)
    end
end

--[[
    @desc: 隐藏Start按钮，并移动地图置Y:800的位置
    author:coldflag
    time:2021-08-30 16:07:17
    --@goMapStartBtn: 
    @return:
]]
function ThemeParkFreeSpinUI:MapStartBtnListener(goMapStartBtn)
    local Vec3PosEnd = Unity.Vector3(0, 800, 0)
    local time = ThemeParkConfig.FreeSpinUpMap -- 移动地图的时间

    -- 隐藏Start按钮
    goMapStartBtn:SetActive(false)

    local ltd = LeanTween.move(self.trLittleGameMap.gameObject, Vec3PosEnd, time)
    ltd:setOnComplete(function()
        self:onCompleteMapMove()
    end)
end

-- 地图移动完成后要做的事情
function ThemeParkFreeSpinUI:onCompleteMapMove()
    SceneSlotGame.m_bUIState = false -- 原先在ThemeParkLevelUI:ShowFreeSpinUI(bShowFlag)中阻塞公共FreeSpin流程，现在放行
    PayLinePayWaysEffectHandler:MatchLineHide(false) -- 后续不隐藏符号中奖特效
end

function ThemeParkFreeSpinUI:ChangeCardPrize(fPrize)
    local bRV = false

    local textPrize = self.trCharacterCard:FindDeepChild("PrizeValue")
    local textMesh = textPrize:GetComponent(typeof(Unity.TextMesh))
    if textMesh ~= nil then
        local sPrize = MoneyFormatHelper.coinCountOmit(fPrize, 0)
        textMesh.text = sPrize
        bRV = true
    end

    return bRV
end

function ThemeParkFreeSpinUI:ChangeCardMulti(nMulti)
    local bRV = false

    local textPrize = self.trCharacterCard:FindDeepChild("Multiplier")
    local textMesh = textPrize:GetComponent(typeof(Unity.TextMesh))
    if textMesh ~= nil then
        local sMulti = "X" .. nMulti
        textMesh.text = sMulti
        bRV = true
    end

    return bRV
end

function ThemeParkFreeSpinUI:IncreaseCardMulti()
    local nCharacterID = LevelUI.CharacterSelectUI:GetSelectedCharacterID()
    -- 人物  ++multi
    ThemeParkFreeSpin:IncreaseCharMultiplier(nCharacterID)
    local nMulti = ThemeParkFreeSpin.mapCharacterData[nCharacterID].multiplier
    -- 更新界面显示的值
    self:ChangeCardMulti(nMulti)
end

function ThemeParkFreeSpinUI:SetCharacterPosition(nCharacterID, nStartPos1, nStartPos2)
    local Vec3CurPos = self:GetPosV3byPosID(nStartPos1, nStartPos2)
    self.goCharacter = self.mapGoCharacter[nCharacterID]
    self.goCharacter.transform.localPosition = Vec3CurPos
    ThemeParkFreeSpin:FlushCharacterPosition(nStartPos1, nStartPos2)
end

function ThemeParkFreeSpinUI:GetCardParticle(nCharacterID)
    local objCard = self.mapGoCard[nCharacterID]
    self.trCharacterCard = objCard.transform
    local goCardPrizeLizi = self.trCharacterCard.transform:FindDeepChild("liziPrize").gameObject
    local goCardMultiLizi = self.trCharacterCard.transform:FindDeepChild("liziMulti").gameObject
    self.mapGoCardLizi = {["prize"] = goCardPrizeLizi, ["multi"] = goCardMultiLizi}
    for k, v in pairs(self.mapGoCardLizi) do
        v:SetActive(false)
    end
end

function ThemeParkFreeSpinUI:ShowCorrectCharacter(nCharacterID)
    for k = 1, 4 do
        if k == nCharacterID then
            self.mapGoCharacter[k]:SetActive(true)
            self.mapGoCard[k]:SetActive(true)
        else
            self.mapGoCharacter[k]:SetActive(false)
            self.mapGoCard[k]:SetActive(false)
        end
    end
end

--[[
    @desc: 将游乐场地图覆盖整个屏幕， 相对坐标Y:0
    author:coldflag
    time:2021-08-30 13:50:18
    @return:
]]
function ThemeParkFreeSpinUI:PlayMapStartScene()
    local nCharacterID = LevelUI.CharacterSelectUI:GetSelectedCharacterID()
    local nStartPos1, nStartPos2 = ThemeParkFreeSpin:GetNowCharacterPosition()
    self:SetCharacterPosition(nCharacterID, nStartPos1, nStartPos2)

    self:GetCardParticle(nCharacterID)

    self:ShowCorrectCharacter(nCharacterID)

    -- 修改牌面的信息
    local mapCharacterDataStruct = ThemeParkFreeSpin:GetCharacterDataStruct()
    local nPrize = mapCharacterDataStruct[nCharacterID]["prize"]
    self:ChangeCardPrize(nPrize)
    local nMulti = mapCharacterDataStruct[nCharacterID]["multiplier"]
    self:ChangeCardMulti(nMulti)

    local Vec3PosMapContent = Unity.Vector3(0, 0, 0)
    local trMapContent = self.trLittleGameMap:FindDeepChild("MapContent")
    trMapContent.localPosition = Vec3PosMapContent
    self.trLittleGameMap.localPosition = Unity.Vector3.zero
    self.trLittleGameMap.gameObject:SetActive(true)
    self.trFreeSpinScene.gameObject:SetActive(true) 

    local trBtnStartPlayground = self.trLittleGameMap:FindDeepChild("StartBtn")
    trBtnStartPlayground.gameObject:SetActive(true)



    -- 设置地图遮罩
    self:SetMapSpriteMask()
end

function ThemeParkFreeSpinUI:SetMapSpriteMask()
    local goMapContent = self.transform:FindDeepChild("MapContent").gameObject
    local trMapGroup = self.transform:FindDeepChild("MapGroup")
    local cpChildMask = goMapContent:GetComponent(typeof(CS.CustomerRectMaskGroupChildren))
    local cpMapMaskGroup = trMapGroup:GetComponent(typeof(CS.CustomerRectMaskGroup))

    cpChildMask.ValidParentMaskGroup = false -- 只有CustomerRectMaskGroupChildren组件才有ValidParentMasKGroup属性
    cpChildMask:SetGroupMask(cpMapMaskGroup)  -- 只有CustomerRectMaskGroupChildren组件才能有SetGroupMask(CustomerRectMask) 方法
end

--[[
    @desc: 根据类型和ID获取坐标, 注意，这里没有做安全性检查，请务必在外部调用前做好检查
    author:coldflag
    time:2021-08-24 11:33:38
    --@nPosType: 坐标类型（1普通， 2捷径1， 3捷径2， 4捷径3）
	--@nPosID: 坐标在其坐标集中的ID，非预制件名称
    @return: Vector3表示的坐标
]]
function ThemeParkFreeSpinUI:GetPosV3byPosID(nPosType, nPosID)
    return self.mapFreeSpinMapPos[nPosType][nPosID]
end

function ThemeParkFreeSpinUI:Move(nDistance)
    local nCharacterID = LevelUI.CharacterSelectUI:GetSelectedCharacterID()

    AudioHandler:PlayThemeSound("map_step")

    local time = ThemeParkConfig.FreeSpinCharacterMoveTimePerStep

    -- 使用相对坐标进行移动
    local ltd = LeanTween.moveLocal(self.goCharacter, self.mapPosVec3[nDistance], time):setEase(LeanTweenType.easeInOutSine)

    local id = ltd:setOnComplete(function()
        nDistance = nDistance + 1
        if nDistance <= #self.mapPosVec3 then
            self:Move(nDistance)
        else
            self.bIsCharactrerMoveFinished = true
            
            -- 判断奖励类型
            ThemeParkFreeSpin:JudgeReward()
            return
        end
    end)
end

--[[
    @desc: 人物角色移动
    author:coldflag
    time:2021-08-30 15:11:53
    @return:
]]
function ThemeParkFreeSpinUI:PlayCharMoveScene()
    local nCharacterID = LevelUI.CharacterSelectUI:GetSelectedCharacterID()
    Debug.Log("in ThemeParkFreeSpinUI:PlayCharMoveScene()")
    self.mapPosVec3 = {}
    -- 根据角色的ID，用不同的Config生成骰子值
    local nDistance = ThemeParkConfig:Dice(nCharacterID)

    -- 播放筛子动画
    LevelUI.DiceSpine:Show(nDistance)

    local time = ThemeParkConfig.FreeSpinDiceTime
    LeanTween.delayedCall(time, function()
        self:StartCharMove(nDistance)
    end)

    

end


function ThemeParkFreeSpinUI:StartCharMove(nDistance)
    -- 获得人物需要经过的路径
    self.mapPosVec3 = ThemeParkFreeSpin:GetMovePath(nDistance)
    Debug.Log("Dice Number: " .. nDistance)
    Debug.Log( "Now PosModID: " .. ThemeParkFreeSpin.nCurModID .." Now PosID: ".. ThemeParkFreeSpin.nCurPosID)

    self.bIsCharactrerMoveFinished = false
    self:Move(1)
end


--[[
    @desc: 当人物到达某个点位的时候，向下移动地图
    author:coldflag
    time:2021-09-06 16:58:20
    @return:
]]
function ThemeParkFreeSpinUI:DownMap()
    local trMapContent = self.trLittleGameMap:FindDeepChild("MapContent")
    local Vec3End = Unity.Vector3(0, -500, 0)
    LeanTween.moveLocal(trMapContent.gameObject, Vec3End, ThemeParkConfig.FreeSpinDowmMapContentTime)
end


--[[
    @desc: 播放正常场景和FreeSpin场景切换时候的过场动画
    author:coldflag
    time:2021-08-23 17:04:05
    @return: void 
]]
function ThemeParkFreeSpinUI:PlaySwitchFreeSpinScene()
    

end


--[[
    @desc: 从FreeSpin切换到Normal场景
    author:coldflag
    time:2021-08-24 09:34:20
    @return:
]]
function ThemeParkFreeSpinUI:BackToNormalScene()
    
    PayLinePayWaysEffectHandler:MatchLineHide(true)
    -- 播放过场动画
    self:PlaySwitchFreeSpinScene()

    -- 激活正常的背景和框
    self.transform:FindDeepChild("Normalbg").gameObject:SetActive(true)
    self.transform:FindDeepChild("NormalScene").gameObject:SetActive(true)

    -- 隐藏FreeSpin时候的背景和框
    self.transform:FindDeepChild("FreeGamesScene").gameObject:SetActive(false)
    self.transform:FindDeepChild("Freebg").gameObject:SetActive(false)

    PayLinePayWaysEffectHandler:MatchLineHide(false)
end