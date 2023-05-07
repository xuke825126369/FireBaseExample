SweetBlastBonusGameUI = {}

SweetBlastBonusGameUI.m_transform = nil -- BonusGameUI
SweetBlastBonusGameUI.m_LeanTweenIDs = {} -- 退出关卡时候要取消的leantween动画

SweetBlastBonusGameUI.m_btnSpin = nil --BtnSpin 不可点状态。。

SweetBlastBonusGameUI.m_listGingermanNum = {200, 300, 500} --  对应 1 4 7 三个格子
-- 转到某个格子的概率
SweetBlastBonusGameUI.m_listWeelItemProb = {100, 10, 10, 100, 10, 10, 5000, 10}

-- 格子都有哪些种类
SweetBlastBonusGameUI.EnumBonusGameItemType = {
    ItemType_Credit = 1,
    ItemType_AddReels = 2,
    ItemType_FreeSpinAdd1 = 3,
    ItemType_FreeSpinAdd2 = 4,
    ItemType_FreeSpinAdd3 = 5,
    ItemType_WildReel = 6,
    ItemType_AddRow = 7
}
--1饼 2蓝 3红 4绿 5紫 6 黄 2,4,6,2,8,3,1,5 蓝 绿 黄 蓝5---8
-- 颜色都有哪些种类 -- 转轮上Cyan对应姜饼人 地图上没有Cyan Type
SweetBlastBonusGameUI.EnumColorType = {
    ColorType_Cyan = 1,
    ColorType_Blue = 2,
    ColorType_Red = 3,
    ColorType_Green = 4,
    ColorType_Purple = 5,
    ColorType_Yellow = 6
}

SweetBlastBonusGameUI.m_mapbackgrids = {}

--这三不用每次进游戏都初始化
SweetBlastBonusGameUI.m_listWheelColorType = {1, 2, 3, 1, 4, 5, 1, 6} -- 轮子颜色顺序

-- 固定不会变的 起始点到终点的顺序 28个值
SweetBlastBonusGameUI.m_listMapColorType = {6, 3, 4, 5, 2, 6, 3, 4, 5, 2, 6, 3, 4, 5,
                                            2, 6, 3, 4, 5, 2, 6, 3, 4, 5, 2, 6, 3, 4}

-- 对应 EnumBonusGameItemType 表
-- 初始值如下 但是踩过之后都会变成 ItemType_Credit = 1  需要存数据库 2018-9-27挪过去了
-- SweetBlastBonusGameUI.m_listMapItemType = {2, 1, 4, 1, 2, 1, 5, 6, 1, 3, 1, 6, 4, 1, 2,
--                             1, 3, 1, 6, 3, 1, 3, 1, 3, 6, 5, 1, 7}

-- 每个WheelItem 对应的角度 (逆时针旋转) -- 顺时针数数分布是item1到8
SweetBlastBonusGameUI.m_nAngle0 = 15 -- wheelItem1 对应的角度  后面的每个加45度 一共8个

-- todo -- SweetBlastLevelParam
--SweetBlastBonusGameUI.m_listWheelSpinSequence = {} -- 对应wheelItem key: 1-8

-- 根据 m_listWheelSpinSequence 算出来的 不存数据库
--SweetBlastBonusGameUI.m_listGingermanSequence = {} -- 对应大地图上的key: 1-28  走的所有步数

SweetBlastBonusGameUI.m_trGameItems = {} -- 28个节点的tr

-- 地图上初始11个Credit Type 对应的textPro 28个节点都要有的。。。
SweetBlastBonusGameUI.m_mapTextMeshProCreditValue = {} -- key:1-28 value: textPro

-- FreeGamesQiZiEffect
SweetBlastBonusGameUI.m_goFreeSpinLogoEffect = nil -- 扫光要隐藏掉 在弹freespin的时候。。包括下面2节点一起
SweetBlastBonusGameUI.gowheelNode = nil -- 需要转动的gameobject
SweetBlastBonusGameUI.m_goSantaClaus = nil
SweetBlastBonusGameUI.m_spineEffectSantaClaus = nil

SweetBlastBonusGameUI.m_mapgoBridges = {}

SweetBlastBonusGameUI.m_nGridsAmount = 28

--
--TextMeshProBonusCoins
--TextMeshProGummies
--TextMeshProBonusFreeSpins
--gowheelNode 需要转动的gameobject

--SantaClaus gameObject 控制移动
--SantaClaus Animator 走 滑行等动作

-- 3个姜饼人格子 wheel
--TextMeshProGingermanNumItem1
--TextMeshProGingermanNumItem4
--TextMeshProGingermanNumItem7


SweetBlastBonusGameUI.m_textMeshProGingermanNumItem1 = nil
SweetBlastBonusGameUI.m_textMeshProGingermanNumItem4 = nil
SweetBlastBonusGameUI.m_textMeshProGingermanNumItem7 = nil

SweetBlastBonusGameUI.m_slotsNumberBonusCoins = nil 
SweetBlastBonusGameUI.TextMeshProBonusCoins = nil
--橡皮人textpro
SweetBlastBonusGameUI.TextMeshProGummies = nil
--freespin
SweetBlastBonusGameUI.TextMeshProBonusFreeSpins = nil

SweetBlastBonusGameUI.listgowildreels = {} -- wildreel1 ... 2 3 4 
SweetBlastBonusGameUI.listGoReelBG4 = {} -- ReelBG4  默认是3行的 ADD ROW 之后变成4行..
-- 上面的wild scaleY改为0.75 ...

SweetBlastBonusGameUI.listtrWildPos1 = {}
SweetBlastBonusGameUI.listtrWildPos2 = {}
SweetBlastBonusGameUI.listtrWildPos3 = {}
SweetBlastBonusGameUI.listtrWildPos4 = {}

SweetBlastBonusGameUI.m_goWinCoinEffect = nil -- 默认隐藏 赚到金币了显示3秒
SweetBlastBonusGameUI.m_aniFreeGamesQiZiEffect = nil -- 默认播放0
SweetBlastBonusGameUI.m_goBridgeEffect1 = nil -- 以下都是默认隐藏的..
SweetBlastBonusGameUI.m_goBridgeEffect2 = nil
SweetBlastBonusGameUI.m_goWheelStopEffect = nil
SweetBlastBonusGameUI.m_goWheelRotateEffect = nil

SweetBlastBonusGameUI.m_goWildReelsInfoEffect = nil
-- WildReelsInfoEffect 粒子特效 获得reels wild 或 addrow 的时候显示3秒之后隐藏

-- WinCoinEffect 粒子特效 控制节点的显示隐藏 3秒
-- FreeGamesQiZiEffect animator在子节点上 0是默认循环扫光 1是单次播放的获得freespin次数时播的特效
-- BridgeEffect 节点下有 BridgeEffect1 和 2 粒子特效 控制显示隐藏。。2秒钟
-- WheelEffect 节点下有3组粒子特效 1. idleEffect 一直播放 2. StopEffect 1.5秒 3. RotateEffect 循环

-- position
SweetBlastBonusGameUI.m_listMovePath = {} -- 对应1--28的mapKey的坐标 本轮转结束圣诞老人要走的格子路径

-- 都是position 不是localPosition
SweetBlastBonusGameUI.m_posGingermanCollectTarget = Unity.Vector3.zero
SweetBlastBonusGameUI.m_posBonusGameCoinWin = Unity.Vector3.zero
SweetBlastBonusGameUI.m_posFreeGamesBG = Unity.Vector3.zero
SweetBlastBonusGameUI.m_posWildReelLogo = Unity.Vector3.zero

SweetBlastBonusGameUI.m_posWheelArrowLogo = Unity.Vector3.zero

--
SweetBlastBonusGameUI.m_aniGingermanCollectTarget = nil --todo 还没有做
SweetBlastBonusGameUI.m_strGingermanCollectTargetDefaultname = "GingermanCollectTargetAni"


-- GingermanCollectTarget 获取收集位置 飞特效用
-- BonusGameCoinWin
-- FreeGamesBG
-- wildreel1
-- WheelArrowLogo 

-- 特效
-- GingermanCollectEffect 控制显示隐藏 收集到的时候播放一次 1.233秒
-- MapBonusRewardEffect 
SweetBlastBonusGameUI.m_goGingermanCollectEffect = nil
SweetBlastBonusGameUI.m_goMapBonusRewardEffect = nil
SweetBlastBonusGameUI.m_nInitFreeSpinNum0 = 5 -- 初始值。。

-- 转轮上的 StartFreeGames 标记节点 在最后阶段显示..
SweetBlastBonusGameUI.m_mapGoStartFreeGames = {} -- key 1 4 7 对应的值是nil
-- StartFreeGames

-- 取 JianTou2 的 position  gingerman滑动的中途点
SweetBlastBonusGameUI.m_posBridge2Cent = Unity.Vector3.zero

SweetBlastBonusGameUI.m_aniBtnGummyBoard = nil -- 地图左下角收集罐子上的动画


function SweetBlastBonusGameUI:initUI()
    local assetPath = "BonusGameUI.prefab"
    local uiPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    if uiPrefab == nil then
        return nil
    end

    local go = Unity.Object.Instantiate(uiPrefab)
    go.transform:SetParent(SceneSlotGame.m_trPayTableCanvas, false)
    go.transform.localScale = Unity.Vector3.one
    go:SetActive(false)
    self.m_transform = go.transform
    LuaAutoBindMonoBehaviour.Bind(go, self)
    
    -- 9-28
    self.m_goWinCoinEffect = self.m_transform:FindDeepChild("WinCoinEffect").gameObject
    self.m_goWinCoinEffect:SetActive(false)

    local trBridgeEffect = self.m_transform:FindDeepChild("BridgeEffect")
    self.m_goBridgeEffect1 = trBridgeEffect:FindDeepChild("BridgeEffect1").gameObject
    self.m_goBridgeEffect1:SetActive(false)
    self.m_goBridgeEffect2 = trBridgeEffect:FindDeepChild("BridgeEffect2").gameObject
    self.m_goBridgeEffect2:SetActive(false)

    local trWheelEffect = self.m_transform:FindDeepChild("WheelEffect")
    self.m_goWheelStopEffect = trWheelEffect:FindDeepChild("StopEffect").gameObject
    self.m_goWheelStopEffect:SetActive(false)
    self.m_goWheelRotateEffect = trWheelEffect:FindDeepChild("RotateEffect").gameObject
    self.m_goWheelRotateEffect:SetActive(false)

    local trFlagEffect = self.m_transform:FindDeepChild("FreeGamesQiZiEffect")
    self.m_goFreeSpinLogoEffect = trFlagEffect.gameObject
    self.m_goFreeSpinLogoEffect:SetActive(true)
    self.m_aniFreeGamesQiZiEffect = trFlagEffect:GetComponentInChildren( typeof(Unity.Animator) )

    local trReelsEffect = self.m_transform:FindDeepChild("WildReelsInfoEffect")
    self.m_goWildReelsInfoEffect = trReelsEffect.gameObject
    self.m_goWildReelsInfoEffect:SetActive(false)

    --

    local trSpin = self.m_transform:FindDeepChild("BtnSpin")
    self.m_btnSpin = trSpin:GetComponent(typeof(UnityUI.Button))
    
    DelegateCache:addOnClickButton(self.m_btnSpin)
    self.m_btnSpin.onClick:AddListener(function()
        self:onSpin()
    end)

    self.TextMeshProGummies = self.m_transform:FindDeepChild("TextMeshProCollectNum"):GetComponent(typeof(Unity.TextMesh))
    self.TextMeshProBonusCoins = self.m_transform:FindDeepChild("TextMeshProBonusCoins"):GetComponent(typeof(UnityUI.Text))
    self.TextMeshProBonusFreeSpins = self.m_transform:FindDeepChild("TextMeshProBonusFreeSpins"):GetComponent(typeof(UnityUI.Text))
    
    self.m_slotsNumberBonusCoins = SlotsNumber:create()
    self.m_slotsNumberBonusCoins:AddUIText(self.TextMeshProBonusCoins)

    -----

    local trGemButtons = self.m_transform:FindDeepChild("GemButtons")

    for key=1, self.m_nGridsAmount do
        
        local strName = "element" .. tostring(key)
        local trItem = trGemButtons:FindDeepChild(strName)
        self.m_trGameItems[key] = trItem
        
        local trTextCoinValue = trItem:FindDeepChild("TextCoinValue")
        local textPro = trTextCoinValue:GetComponentInChildren(typeof(TextMeshProUGUI))
        self.m_mapTextMeshProCreditValue[key] = textPro
        
    end

    self.gowheelNode = self.m_transform:FindDeepChild("WheelNode").gameObject
    self.m_goSantaClaus = trGemButtons:FindDeepChild("SantaClaus").gameObject
    self.m_spineEffectSantaClaus = SpineEffect:create(self.m_goSantaClaus)

    self.m_mapgoBridges[11] = self.m_transform:FindDeepChild("Bridge1").gameObject

    local trBridge2 = self.m_transform:FindDeepChild("Bridge2")
    self.m_mapgoBridges[21] = trBridge2.gameObject

    local pos = trBridge2:FindDeepChild("JianTou2").position
    self.m_posBridge2Cent = Unity.Vector3(pos.x + 20, pos.y + 50, pos.z)
    
    
    for i=1, 4 do
        local strName = "wildreel" .. tostring(i)
        local trWildReel = self.m_transform:FindDeepChild(strName)
        self.listgowildreels[i] = trWildReel.gameObject

        local trReel4 = trWildReel:FindDeepChild("ReelBG4")
        local go = trReel4.gameObject
        go:SetActive(false)
        self.listGoReelBG4[i] = go
    end
    
    
    --初始化wildreel位置
    local trildPos1 = self.m_transform:FindDeepChild("wildPos1")
    local trildPos2 = self.m_transform:FindDeepChild("wildPos2")
    local trildPos3 = self.m_transform:FindDeepChild("wildPos3")
    local trildPos4 = self.m_transform:FindDeepChild("wildPos4")

    self.listtrWildPos1[1] = trildPos1:FindDeepChild("1th")
    self.listtrWildPos2[1] = trildPos2:FindDeepChild("1th")
    self.listtrWildPos2[2] = trildPos2:FindDeepChild("2th")
    self.listtrWildPos3[1] = trildPos3:FindDeepChild("1th")
    self.listtrWildPos3[2] = trildPos3:FindDeepChild("2th")
    self.listtrWildPos3[3] = trildPos3:FindDeepChild("3th")
    self.listtrWildPos4[1] = trildPos4:FindDeepChild("1th")
    self.listtrWildPos4[2] = trildPos4:FindDeepChild("2th")
    self.listtrWildPos4[3] = trildPos4:FindDeepChild("3th")
    self.listtrWildPos4[4] = trildPos4:FindDeepChild("4th")
    
    local trGingermanItem1Text = self.m_transform:FindDeepChild("TextMeshProGingermanNumItem1")
    self.m_textMeshProGingermanNumItem1 = trGingermanItem1Text:GetComponent(typeof(UnityUI.Text))
    self.m_textMeshProGingermanNumItem1.text = tostring(self.m_listGingermanNum[1])

    local trGingermanItem4Text = self.m_transform:FindDeepChild("TextMeshProGingermanNumItem4")
    self.m_textMeshProGingermanNumItem4 = trGingermanItem4Text:GetComponent(typeof(UnityUI.Text))
    self.m_textMeshProGingermanNumItem4.text = tostring(self.m_listGingermanNum[2])

    local trGingermanItem7Text = self.m_transform:FindDeepChild("TextMeshProGingermanNumItem7")
    self.m_textMeshProGingermanNumItem7 = trGingermanItem7Text:GetComponent(typeof(UnityUI.Text))
    self.m_textMeshProGingermanNumItem7.text = tostring(self.m_listGingermanNum[3])
    
    --

    -- 都是position 不是localPosition
    local trGingermanCollectTarget = self.m_transform:FindDeepChild("GingermanCollectTarget")
    self.m_posGingermanCollectTarget = trGingermanCollectTarget.position
    --self.m_aniGingermanCollectTarget = trGingermanCollectTarget:GetComponentInChildren(typeof(Unity.Animator))

    local trBonusGameCoinWin = self.m_transform:FindDeepChild("BonusGameCoinWin")
    self.m_posBonusGameCoinWin = trBonusGameCoinWin.position

    local trFreeGamesBG = self.m_transform:FindDeepChild("FreeGamesBG")
    self.m_posFreeGamesBG = trFreeGamesBG.position
    
    local trwildreel1 = self.m_transform:FindDeepChild("wildreel1")
    self.m_posWildReelLogo = trwildreel1.position

    local trWheelArrowLogo = self.m_transform:FindDeepChild("WheelArrowLogo")
    self.m_posWheelArrowLogo = trWheelArrowLogo.position
    
    -- 特效
    self.m_goGingermanCollectEffect = self.m_transform:FindDeepChild("GingermanCollectEffect").gameObject
    self.m_goMapBonusRewardEffect = self.m_transform:FindDeepChild("MapBonusRewardEffect").gameObject
    self.m_goGingermanCollectEffect:SetActive(false)
    self.m_goMapBonusRewardEffect:SetActive(false)
    
    --

    local trCollectUIAni = self.m_transform:FindDeepChild("CollectUIAni")
    self.m_aniBtnGummyBoard = trCollectUIAni:GetComponent(typeof(Unity.Animator))
    self.m_aniBtnGummyBoard:SetInteger("nPlayMode", 0)
    
    --

    --
    local trWheelNode = self.gowheelNode.transform
    for i=1, 8 do
        local strName = "item" .. tostring(i)
        local trItem = trWheelNode:FindDeepChild(strName)
        local trStartFreeGame = trItem:FindDeepChild("StartFreeGames")
        local goStartFreeGame = nil
        if trStartFreeGame ~= nil then
            goStartFreeGame = trStartFreeGame.gameObject
            goStartFreeGame:SetActive(false)
        end

        -- key 1 4 7 对应的值是nil
        self.m_mapGoStartFreeGames[i] = goStartFreeGame
        
    end

end

function SweetBlastBonusGameUI:getBackGrids()
    local mapBackGrids = {}
    mapBackGrids[11] = 5
    mapBackGrids[21] = 15
    return mapBackGrids
end

function SweetBlastBonusGameUI:OnEnable()
end

function SweetBlastBonusGameUI:Start()
end

function SweetBlastBonusGameUI:Update()
    self.m_slotsNumberBonusCoins:Update()
    
    -- bug todo。。。。。
    -- if SceneSlotGame.m_btnLobby.interactable then
    --     SceneSlotGame.m_btnLobby.interactable = false
    -- end
end

function SweetBlastBonusGameUI:OnDisable()
end

function SweetBlastBonusGameUI:OnDestroy()
    local count = #self.m_LeanTweenIDs
    for i = 1, count do
        local id = self.m_LeanTweenIDs[i]
        if LeanTween.isTweening(id) then
            LeanTween.cancel(id)
        end
    end
    self.m_LeanTweenIDs = {}
    
    self.m_mapbackgrids = {}
    self.m_trGameItems = {}
    self.m_mapTextMeshProCreditValue = {}
    self.m_mapgoBridges = {}
    self.listgowildreels = {}
    self.listGoReelBG4 = {}
    self.listtrWildPos1 = {}
    self.listtrWildPos2 = {}
    self.listtrWildPos3 = {}
    self.listtrWildPos4 = {}
    self.m_listMovePath = {}
    self.m_mapGoStartFreeGames = {}
end

-- nType 1: 3个bonus牌触发的   2: 姜饼人开箱子兑换到的。。。
function SweetBlastBonusGameUI:Show()
    LeanTween.delayedCall(1.0, function()
        SweetBlastLevelUI.m_transform.gameObject:SetActive(false)
        SweetBlastLevelUI.m_goSlotsDataInfo:SetActive(false)
    end)

    SweetBlastLevelUI:addBonusGameNum() -- 统计进过多少次bonusgame
    
    AudioHandler:LoadAndPlayBonusGameMusic()
    
    self:initUIAndData()
    
    self.m_transform.gameObject:SetActive(true)
    
    SceneSlotGame:ButtonEnable(false)
    
    SceneSlotGame.m_btnSpin.interactable = false
    SceneSlotGame.m_bUIState = true
	SpinButton.m_bEnableSpinFlag = false -- 让按钮不可点

    self.m_goFreeSpinLogoEffect:SetActive(true)
    self.gowheelNode:SetActive(true)
    self.m_goSantaClaus:SetActive(true)
end

function SweetBlastBonusGameUI:initUIAndData()
    local param = SweetBlastLevelParam.m_BonusGameInfo
    if param.m_nWheelSpinIndex == nil then
        param.m_nWheelSpinIndex = 0
    end

    --第一次
    if param.m_nWheelSpinIndex == 0 then
        --初始化序列

        self:initBonusGameParam() -- 每次触发都要调用的 杀进程恢复的情况不能调用

        if param.m_listWheelSpinSequence == nil then
            param.m_listWheelSpinSequence = {}
        end
        if param.m_listGingermanSequence == nil then
            param.m_listGingermanSequence = {}
        end
        self:initWheelSpinSequenceList()

        self.m_goSantaClaus.transform.position = self.m_transform:FindDeepChild("Start").position

        self.gowheelNode.transform.eulerAngles = Unity.Vector3(0, 0, 15)
        self.m_btnSpin.interactable = true
        -- 圣诞老人的休闲动作
        self.m_spineEffectSantaClaus:PlayAnimation("animation", 0, true, 1)
        
    else
        if param.m_nCurGingermanKey == nil then
            param.m_nCurGingermanKey = 0
        else
            -- 还在初始位置处 没转过或者转了的都是姜饼人 就杀进程了的情况
            -- 再进来 m_nCurGingermanKey还是0 不用去修改什么位置..
            
            if param.m_nCurGingermanKey > 0 then 
                self.m_goSantaClaus.transform.position = self.m_trGameItems[param.m_nCurGingermanKey].position
            end
        end

        local nWheelKey = param.m_listWheelSpinSequence[param.m_nWheelSpinIndex]
        local rotateAngle = 45 * (nWheelKey - 1) + 15
        self.gowheelNode.transform.eulerAngles = Unity.Vector3(0, 0, rotateAngle)
    end

    self:initAllGameItems()

    if param.m_nFreeSpinNum == nil then
        param.m_nFreeSpinNum = self.m_nInitFreeSpinNum0 -- 5
    end
    if param.m_nBonusGameCoins == nil then
        param.m_nBonusGameCoins = 0
    end
    if param.m_nBonusGingermanNum == nil then
        param.m_nBonusGingermanNum = 0
    end

    self.TextMeshProBonusFreeSpins.text = param.m_nFreeSpinNum
    local strCoins = MoneyFormatHelper.numWithCommas( param.m_nBonusGameCoins )
    self.TextMeshProBonusCoins.text = strCoins
    self.m_slotsNumberBonusCoins:End(param.m_nBonusGameCoins)
    
    local nGingermanNum = SweetBlastLevelParam.m_CollectInfo.m_nCollectNum
    if nGingermanNum == nil then
        nGingermanNum = 0
        SweetBlastLevelParam.m_CollectInfo.m_nCollectNum = 0
    end

    local strGingerman = MoneyFormatHelper.numWithCommas(nGingermanNum)
    self.TextMeshProGummies.text = strGingerman

    self.m_mapbackgrids = self:getBackGrids() -- 初始两条。。检查把已经走过的删掉。。

    for k, v in pairs(self.m_mapbackgrids) do
        self.m_mapgoBridges[k]:SetActive(true)
    end

    if param.m_nMoveTimes == nil then
        param.m_nMoveTimes = 0
    end

    for k, v in pairs(self.m_mapbackgrids) do
        for k2, v2 in pairs(param.m_listGingermanSequence) do
            if k == v2 and param.m_nMoveTimes >= k2 then
                self.m_mapgoBridges[k]:SetActive(false)
                self.m_mapbackgrids[k] = nil
            end
        end
    end

    --
    self:setWheelItemStartFreeGameLogos()
    --

    --初始化whilreel
    self:refreshWildReelsAmout()

    --初始化bar
    for k, v in pairs(self.listgowildreels) do
        for i=1, 5 do
            v.transform:FindDeepChild(tostring(i)).gameObject:SetActive(false)
        end
    end
    
    if param.m_listWildReelKey == nil then
        param.m_listWildReelKey = {}
    end

    for i=1, #param.m_listWildReelKey do
        local index = param.m_listWildReelKey[i]
        self:refreshSingleWildReel(index)
    end
    
end

function SweetBlastBonusGameUI:setWheelItemStartFreeGameLogos()
    local param = SweetBlastLevelParam.m_BonusGameInfo

    local nGingermanKey = param.m_nCurGingermanKey
    if nGingermanKey == nil then
        nGingermanKey = 0
    end

    for i=1, 8 do
        local goStart = self.m_mapGoStartFreeGames[i]
        if goStart ~= nil then
            goStart:SetActive(false)
            if nGingermanKey > 23 then -- 只有剩下格子数已经不足5个了才有可能部分格子上需要显示start..
                local nWheelColorType = self.m_listWheelColorType[i]
                local bFind = false
                for nMapKey=nGingermanKey+1, self.m_nGridsAmount do
                    local nMapColorType = self.m_listMapColorType[nMapKey]
                    if nMapColorType == nWheelColorType then
                        bFind = true
                        break
                    end
                end

                if not bFind then
                    goStart:SetActive(true) -- 表示再转到这个格子就该游戏结束了。。
                end
            end
        end
    end
end

function SweetBlastBonusGameUI:hide()
    if not self.m_transform.gameObject.activeSelf then
        return
    end

    self.m_spineEffectSantaClaus:StopActiveAnimation()

    for i=1, 4 do
        self.listGoReelBG4[i]:SetActive(false)
    end

    self.m_goFreeSpinLogoEffect:SetActive(true)
    self.gowheelNode:SetActive(true)
    self.m_goSantaClaus:SetActive(true)

    SweetBlastLevelUI.m_transform.gameObject:SetActive(true)
    SweetBlastLevelUI.m_goSlotsDataInfo:SetActive(true)
    self.m_transform.gameObject:SetActive(false)
    SceneSlotGame:ButtonEnable(true)
	SpinButton.m_bEnableSpinFlag = true
end

function SweetBlastBonusGameUI:gameOver()
    AudioHandler:PlayThemeSound("map_end")
    
    -- 转场特效在levelbg下 所以这里要把levelbg先显示出来..
    SweetBlastLevelUI.m_transform.gameObject:SetActive(true)

    self.m_btnSpin.interactable = false

    SweetBlastLevelUI:BonusGameEnd() -- 领取奖励、重置参数、设置UI等

    -- BonusGameEnd 里4秒会显示freespinbegin界面
    LeanTween.delayedCall(4.1, function()
        -- 这三个节点层级太高了 会显示到freespinbegin界面上
        self.m_goFreeSpinLogoEffect:SetActive(false)
     --   self.gowheelNode:SetActive(false)
        self.m_goSantaClaus:SetActive(false)

    end)

    -- 在 BonusGameEnd 里会调用hide
    
end

-- 杀进程恢复的情况不能调用。。
function SweetBlastBonusGameUI:initBonusGameParam()
    -- 仿真也用
    --1. 初始化棋盘参数 写数据库

    --2. 获取操作序列 返回结果 todo...

    -- local listTotalBet = GameLevelUtil:getTotalBetList()
    -- local cnt = #listTotalBet

    -- local nTotalBet0 = listTotalBet[cnt]
    -- if cnt > 10 then
    --     local offset = math.floor((cnt - 10) / 2)
    --     nTotalBet0 = listTotalBet[cnt - offset]
    -- end

    local param = SweetBlastLevelParam.m_BonusGameInfo
    local nTotalBet0 = param.m_nTotalBet
    if nTotalBet0 == nil then -- 打补丁。。ios某次更新出去一个中间版本？
        SweetBlastLevelParam:setBonusGameBetByType(1)
        Debug.Log("-------error!!------")
    end

    if param.m_mapCreditItemValue == nil then
        param.m_mapCreditItemValue = {}
    end

    if param.m_listMapItemType == nil then
        param.m_listMapItemType = {2, 1, 4, 1, 2, 1, 5, 6, 1, 3, 1, 6, 4, 1, 2,
                                        1, 3, 1, 6, 3, 1, 3, 1, 3, 6, 5, 1, 7}
    end

    local listCreditCoef = {0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0,
                            3.5, 4.0, 4.5, 5.0, 5.5, 6.0}
    local listProbs = {120, 160, 150, 120, 90, 80, 70, 60, 50, 30, 30, 10, 10, 5, 2, 1}
    
    -- 每次进游戏时初始化好 写数据库 杀进程再进时候恢复 不是credit的也要填上 当踩过之后就会变成credit了
    for key = 1, self.m_nGridsAmount do
        local itemType = param.m_listMapItemType[key]
        local value = 0

        local nRandomIndex = LuaHelper.GetIndexByRate(listProbs)
        local fCoef = listCreditCoef[nRandomIndex]
        value = fCoef * nTotalBet0
        
        if not SweetBlastFunc.m_bSimulationFlag then
            value = MoneyFormatHelper.normalizeCoinCount(value, 3) -- 仿真不用 否则都是零了。。
        end

        param.m_mapCreditItemValue[key] = value
        -- key: 格子ID value: creditItem的金币数

        if not SweetBlastFunc.m_bSimulationFlag then
            if itemType == self.EnumBonusGameItemType.ItemType_Credit then
                local textPro = self.m_mapTextMeshProCreditValue[key]
    
                local strCoins = MoneyFormatHelper.coinCountOmit(value)
                textPro.text = strCoins
            end
        end
    end

    if not SweetBlastFunc.m_bSimulationFlag then
        SweetBlastLevelParam:saveParam() -- 杀进程再进 要让盘面恢复
    end
    
end

function SweetBlastBonusGameUI:initWheelGingermanSequences()
    local param = SweetBlastLevelParam.m_BonusGameInfo
    param.m_listWheelSpinSequence = {}
    param.m_listGingermanSequence = {}

    local temp_currentindex = 1 -- 对应地图格子key 1--28

    local mapBackGrids = self:getBackGrids()
    
    while true do
        --转到的轮子下标
        local nrandom = math.random(1, 8)
        --转到姜饼人直接加
        if nrandom == 1 or nrandom == 4 or nrandom == 7 then
            table.insert(param.m_listWheelSpinSequence, nrandom)
        else
            --转到的轮子颜色
            local ncolorIndex = self.m_listWheelColorType[nrandom]

            local bFind = false
            while true do
                if self.m_listMapColorType[temp_currentindex] == ncolorIndex then
                    bFind = true
                    break
                else
                    temp_currentindex = temp_currentindex + 1
                    if temp_currentindex > self.m_nGridsAmount then
                        bFind = false
                        break
                    end
                end
            end
            
            table.insert(param.m_listWheelSpinSequence, nrandom)
            if bFind then
                table.insert(param.m_listGingermanSequence, temp_currentindex)
            else
                break
            end
            
            --如果转到返回的格子要返回
            for key, value in pairs(mapBackGrids) do
                if temp_currentindex == key  then
                    if mapBackGrids[key] == nil then
                        break
                    end
                    --要返回
                    mapBackGrids[key] = nil
                    temp_currentindex = value
                    table.insert(param.m_listGingermanSequence, value)
                    break
                end
            end

            -- 开始下一个点的查找 从当前位置的下一个位置开始找。。
            temp_currentindex = temp_currentindex + 1
            --

        end
    end
    
end

-- 至少要踩一个ADD REELS -- 进入freespin至少是两个棋盘.. 至少踩一个格子 ItemType_AddReels
-- 中途退出再回来的情况不会来调用这个
function SweetBlastBonusGameUI:initWheelSpinSequenceList()
    local listAddReelsGridKey = {1, 5, 15} -- ItemType_AddReels
    
    local listFreeSpinNum1Key = {10, 17, 20, 22, 24}
    local listFreeSpinNum2Key = {3, 13}
    local listFreeSpinNum3Key = {7, 26}

    local listWildReelKey = {8, 12, 19, 25}

    local listProbs = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.0, 1.0, 1.0}
    -- 大于等于8次freespin就一定概率重新随机..

    while true do
        self:initWheelGingermanSequences()
    
        local nTotalFreeSpinNum = 5 -- 5是初始值
        local bMoreReelsFlag = false
        local bFreeSpinFlag = false -- FreeSpin次数是否满足条件
        local nWildReelNum = 0 -- 不允许等于4 最多只能3

        local listCheckedKeys = {} -- freespin的格子踩过一次之后就变成金币格子了
        
        local param = SweetBlastLevelParam.m_BonusGameInfo
        local cnt = #param.m_listGingermanSequence
        for i=1, cnt do
            local nMapKey = param.m_listGingermanSequence[i]
            local bCheckedFlag = LuaHelper.tableContainsElement(listCheckedKeys, nMapKey)

            local flag = LuaHelper.tableContainsElement(listAddReelsGridKey, nMapKey)
            if flag and (not bCheckedFlag) then
                bMoreReelsFlag = true
                table.insert( listCheckedKeys, nMapKey )
            end
            
            local flag1 = LuaHelper.tableContainsElement(listFreeSpinNum1Key, nMapKey)
            if flag1 and (not bCheckedFlag) then
                nTotalFreeSpinNum = nTotalFreeSpinNum + 1
                table.insert( listCheckedKeys, nMapKey )
            end

            local flag2 = LuaHelper.tableContainsElement(listFreeSpinNum2Key, nMapKey)
            if flag2 and (not bCheckedFlag) then
                nTotalFreeSpinNum = nTotalFreeSpinNum + 2
                table.insert( listCheckedKeys, nMapKey )
            end
            
            local flag3 = LuaHelper.tableContainsElement(listFreeSpinNum3Key, nMapKey)
            if flag3 and (not bCheckedFlag) then
                nTotalFreeSpinNum = nTotalFreeSpinNum + 3
                table.insert( listCheckedKeys, nMapKey )
            end
            
            local flag4 = LuaHelper.tableContainsElement(listWildReelKey, nMapKey)
            if flag4 and (not bCheckedFlag) then
                nWildReelNum = nWildReelNum + 1
                table.insert( listCheckedKeys, nMapKey )
            end
        end

        if nTotalFreeSpinNum < 8 then
            bFreeSpinFlag = true
        else
            local index = nTotalFreeSpinNum - 7
            local prob = listProbs[index]
            if math.random() > prob then
                bFreeSpinFlag = true
            end
        end

        if bMoreReelsFlag and bFreeSpinFlag and (nWildReelNum < 4) then
            break
        end
    end
    
    --下面是测试检验结果。。

    -- SweetBlastBonusGameUI.EnumColorType = {
    --     ColorType_Cyan = 1,
    --     ColorType_Blue = 2,
    --     ColorType_Red = 3,
    --     ColorType_Green = 4,
    --     ColorType_Purple = 5,
    --     ColorType_Yellow = 6
    -- }

    local listColorName = {"Cyan", "Blue", "Red", "Green", "Purple", "Yellow"}

    local param = SweetBlastLevelParam.m_BonusGameInfo
    local cnt1 = #param.m_listWheelSpinSequence
    local cnt2 = #param.m_listGingermanSequence
    local strWheelColor = tostring(cnt1) .. "  :  "
    for i=1, cnt1 do
        local nWheelKey = param.m_listWheelSpinSequence[i]
        local nColorType = self.m_listWheelColorType[nWheelKey]
        local strColor = listColorName[nColorType] .. "  --  "

        strWheelColor = strWheelColor .. strColor
    end
    Debug.Log( "" .. strWheelColor)

    local strMapColor = tostring(cnt2) .. "  :  "
    for i=1, cnt2 do
        local nMapKey = param.m_listGingermanSequence[i]
        local nColorType = self.m_listMapColorType[nMapKey]
        local strColor = listColorName[nColorType] .. " : " .. tostring(nMapKey) .. "  --  "

        strMapColor = strMapColor .. strColor
    end
    Debug.Log( "" .. strMapColor)

    --
end

-- 开始旋转的时候不修改存储数据 等旋转结束并且所有动画都做完了再修改存储吧。。
-- 没存储之前杀进程了再进的时候就重复来一遍。。。
function SweetBlastBonusGameUI:onSpin()
    self.m_btnSpin.interactable = false

    local param = SweetBlastLevelParam.m_BonusGameInfo
    
    if param.m_nWheelSpinIndex >= #param.m_listWheelSpinSequence then
        Debug.Log("---------error!!!!!!----------") -- 这种情况的时候按钮就不该让能点击。。
        return
    end
    
    AudioHandler:PlayThemeSound("map_spin_press")

    local nSpinIndex = param.m_nWheelSpinIndex -- 初始值是0

    local nWheelKey = param.m_listWheelSpinSequence[nSpinIndex + 1] -- 旋转到下一个格子
    self:RotateWheel(nWheelKey) -- 要到达的key

    self.m_goWheelRotateEffect:SetActive(true)
end

function SweetBlastBonusGameUI:RotateWheel(nWheelKey)
    local param = SweetBlastLevelParam.m_BonusGameInfo

    local fWheelTargetAngle = (nWheelKey - 1) * 45 + 15 -- 先归为到起点然后转相应的角度

    local fAngle = fWheelTargetAngle - 360 * 9
    local vector3Angle = Unity.Vector3(0, 0, fAngle)

    local ftime = 8.0

    -- 每旋转一格播放一次音效。。 map_wheel_tik
    local nSpinIndex = param.m_nWheelSpinIndex -- 初始值是0
    if nSpinIndex == 0 then
        nSpinIndex = 1
    end
    local nPreWheelKey = param.m_listWheelSpinSequence[nSpinIndex]
    local startValue = (nPreWheelKey - 1) * 45 + 15
    local endValue = fAngle

    local nStep = 1
    local fDeltaAngle = 45

    local ltd = LeanTween.value(startValue, endValue, ftime):setEase(LeanTweenType.easeInOutSine):setOnUpdate(function(value)
        local fRotateAngle = startValue - value
        if fRotateAngle > nStep * fDeltaAngle then
          --  Debug.Log("------------nStep: " .. nStep .. "    ---fRotateAngle: " .. fRotateAngle)

            nStep = nStep + 1
            AudioHandler:PlayThemeSound("map_wheel_tik")
        end
    end):setOnComplete(function()
        AudioHandler:PlayThemeSound("map_wheel_tik")
    end)
    --

    local ltd = LeanTween.rotate(self.gowheelNode, vector3Angle, ftime):setEase(LeanTweenType.easeInOutSine)
    
    table.insert(self.m_LeanTweenIDs, ltd.id)

    local id =ltd:setOnComplete(function()
        self:RotateEnd(nWheelKey)
        LuaHelper.removeElementFromTable(self.m_LeanTweenIDs, ltd.id)
        
        self.gowheelNode.transform.eulerAngles = Unity.Vector3(0, 0, fWheelTargetAngle)
        
        self.m_goWheelRotateEffect:SetActive(false)
        self.m_goWheelStopEffect:SetActive(true)
        LeanTween.delayedCall(1.5, function()
            self.m_goWheelStopEffect:SetActive(false)
        end)

    end).id

    table.insert(self.m_LeanTweenIDs, id)
end

function SweetBlastBonusGameUI:RotateEnd(nWheelKey)
    local param = SweetBlastLevelParam.m_BonusGameInfo

    -- 转盘停止发现没有可以走的路径。。。
    if param.m_nWheelSpinIndex+1 == #param.m_listWheelSpinSequence then
        if param.m_nMoveTimes == #param.m_listGingermanSequence then
            self:gameOver()
            return
        end
    end

    ---加姜饼人
    local nGingermanNum = 0
    if nWheelKey == 1 then
        nGingermanNum = self.m_listGingermanNum[1]
    elseif nWheelKey == 4 then
        nGingermanNum = self.m_listGingermanNum[2]
    elseif nWheelKey == 7 then
        nGingermanNum = self.m_listGingermanNum[3]
    else
        self:onJumpToNewGrid()
    end

    if nWheelKey == 1 or nWheelKey == 4 or nWheelKey == 7 then
        -- 其它情况等动画结束了再去修改存数据等。。

        param.m_nWheelSpinIndex = param.m_nWheelSpinIndex + 1

        self:onAddGingerman(nGingermanNum)

        SweetBlastLevelParam:saveParam()
        self.m_btnSpin.interactable = true
    end
end

-- 顺序跳的情况，不包含滑梯传递的情况
function SweetBlastBonusGameUI:onJumpToNewGrid()
    local param = SweetBlastLevelParam.m_BonusGameInfo
    local nMoveTimes = param.m_nMoveTimes + 1
    local nTargetMoveKey = param.m_listGingermanSequence[nMoveTimes]
    
    local nGingermanKey = param.m_nCurGingermanKey -- 圣诞老人之前是在哪个格子。。
    if nGingermanKey == nil then
        nGingermanKey = 0
    end

    --求所有要走的节点
    self.m_listMovePath = {}
    for i=nGingermanKey + 1, nTargetMoveKey do
        table.insert(self.m_listMovePath, self.m_trGameItems[i].position)
    end
    
    if #self.m_listMovePath == 0 then
        Debug.Log("------- error!!!! ---------")
    end

    self:move(1)
end

function SweetBlastBonusGameUI:move(ncounter)
    AudioHandler:PlayThemeSound("map_step")

    local t = 1.167

    self.m_spineEffectSantaClaus:PlayAnimation("animation2", 0, false, 1)

    local ltd = LeanTween.move(self.m_goSantaClaus, self.m_listMovePath[ncounter], t):setEase(LeanTweenType.easeInOutSine)
    local id = ltd:setOnComplete(function()
        self.m_spineEffectSantaClaus:StopActiveAnimation()
        ncounter = ncounter + 1
        if ncounter <= #self.m_listMovePath then
            self:move(ncounter)
        else
            self:onWalkOver()
        end
    end)
end

function SweetBlastBonusGameUI:onWalkOver()
    local param = SweetBlastLevelParam.m_BonusGameInfo

    param.m_nMoveTimes = param.m_nMoveTimes + 1
    local nTargetMoveKey = param.m_listGingermanSequence[param.m_nMoveTimes]
    param.m_nCurGingermanKey = nTargetMoveKey
    
    param.m_nWheelSpinIndex = param.m_nWheelSpinIndex + 1

    self:refreshMoveEndData(false)

    local nGingermanKey = param.m_nCurGingermanKey
    ---看看是不是要返回
    local bIsBack = false
    for key, value in pairs(self.m_mapbackgrids) do
        if nGingermanKey == key then
            self.m_mapbackgrids[key] = nil
            param.m_nMoveTimes = param.m_nMoveTimes + 1
            param.m_nCurGingermanKey = param.m_listGingermanSequence[param.m_nMoveTimes]
            
            self:refreshMoveEndData(true) -- 界面更新的地方要延迟到动画播完...
            
            bIsBack = true

            self:handleBridge() -- 动画过程 与逻辑无关

        end
    end

    if not bIsBack then
        self.m_btnSpin.interactable = true
    end
    
    SweetBlastLevelParam:saveParam()
    
    if nGingermanKey == self.m_nGridsAmount then -- 走到终点了。。
        self:gameOver()
    else
        self:setWheelItemStartFreeGameLogos()
    end

end

function SweetBlastBonusGameUI:handleBridge() -- 动画处理 与逻辑无关了
    AudioHandler:PlayThemeSound("map_bridge")

    local param = SweetBlastLevelParam.m_BonusGameInfo
    local nMoveTimes = param.m_nMoveTimes

    local nNextPosKey = param.m_listGingermanSequence[nMoveTimes]
    local pos = self.m_trGameItems[nNextPosKey].position
    
    -- 滑动。。。
    self.m_spineEffectSantaClaus:PlayAnimation("animation1", 0, false, 1)

    local nBridgeKey = param.m_listGingermanSequence[nMoveTimes-1]
    if nBridgeKey == 11 then
        LeanTween.move(self.m_goSantaClaus, pos, 1.35):setEase(LeanTweenType.easeInOutSine)

    else
        LeanTween.move(self.m_goSantaClaus, self.m_posBridge2Cent, 0.75):setOnComplete(function()
            LeanTween.move(self.m_goSantaClaus, pos, 0.6):setEase(LeanTweenType.easeInOutSine)
        end)
        
    end
    
    LeanTween.delayedCall(1.2, function()
        self.m_mapgoBridges[nBridgeKey]:SetActive(false)

        local goEffect = nil -- 11 21
        if nBridgeKey == 11 then
            goEffect = self.m_goBridgeEffect1
        elseif nBridgeKey == 21 then
            goEffect = self.m_goBridgeEffect2
        end

        goEffect:SetActive(true)
        LeanTween.delayedCall(2.0, function()
            goEffect:SetActive(false)

            self.m_btnSpin.interactable = true
        end)
    end)

end

-- bDelayFlag true : 落在桥上的情况 11 21 
function SweetBlastBonusGameUI:refreshMoveEndData(bDelayFlag)
    -- 1. 调到目标格子了 
    -- 2. 还有传送到下一个格子的情况也在这里把数据更新了。。后面就是视觉表现了，断线不恢复。。
    
    local param = SweetBlastLevelParam.m_BonusGameInfo
    local nGingermanKey = param.m_nCurGingermanKey

    --领奖励
    local nType = param.m_listMapItemType[nGingermanKey]
    if nType == self.EnumBonusGameItemType.ItemType_Credit then
        local nCoin = param.m_mapCreditItemValue[nGingermanKey]
        self:Credit(nCoin, bDelayFlag)

    elseif nType == self.EnumBonusGameItemType.ItemType_AddReels then
        self:AddReels(bDelayFlag)
        self:onChangeGridState(nGingermanKey, bDelayFlag)

    elseif nType == self.EnumBonusGameItemType.ItemType_FreeSpinAdd1 then
        self:FreeSpinAdd(1)
        self:onChangeGridState(nGingermanKey)

    elseif nType == self.EnumBonusGameItemType.ItemType_FreeSpinAdd2 then
        self:FreeSpinAdd(2)
        self:onChangeGridState(nGingermanKey)

    elseif nType == self.EnumBonusGameItemType.ItemType_FreeSpinAdd3 then
        self:FreeSpinAdd(3)
        self:onChangeGridState(nGingermanKey)

    elseif nType == self.EnumBonusGameItemType.ItemType_WildReel then
        self:WildReel()
        self:onChangeGridState(nGingermanKey)    

    elseif nType == self.EnumBonusGameItemType.ItemType_AddRow then
        self:AddRow()
        self:onChangeGridState(nGingermanKey)
    end

    -- 只要是领过的 都是credit类型
    param.m_listMapItemType[nGingermanKey] = self.EnumBonusGameItemType.ItemType_Credit

end

function SweetBlastBonusGameUI:onChangeGridState(nIndex, bDelayFlag)
    local ftime = 0
    if bDelayFlag then
        ftime = 2.5
    end

    local param = SweetBlastLevelParam.m_BonusGameInfo

    LeanTween.delayedCall(ftime, function()
        if self.m_trGameItems[nIndex]:FindDeepChild("elementBG2") ~= nil then
            self.m_trGameItems[nIndex]:FindDeepChild("elementBG2").gameObject:SetActive(false)
        end

        local textPro = self.m_mapTextMeshProCreditValue[nIndex]
        local fCoins = param.m_mapCreditItemValue[nIndex]
        local strCoins = MoneyFormatHelper.coinCountOmit(fCoins)
        textPro.text = strCoins
    end)

end

function SweetBlastBonusGameUI:onAddGingerman(nvalue)
    AudioHandler:PlayBonusCollectionFly()

    local param = SweetBlastLevelParam.m_BonusGameInfo
    param.m_nBonusGingermanNum = param.m_nBonusGingermanNum  + nvalue

    local nCurTotalNum = SweetBlastLevelParam.m_CollectInfo.m_nCollectNum
    SweetBlastLevelParam.m_CollectInfo.m_nCollectNum = nCurTotalNum + nvalue

    self.m_goGingermanCollectEffect:SetActive(true) -- 1.2 秒动画结束 但是后面还有粒子特效等...
    LeanTween.delayedCall(2.5, function()
        self.m_goGingermanCollectEffect:SetActive(false)
    end)

    LeanTween.delayedCall(1.25, function()
        local strGingerman = MoneyFormatHelper.numWithCommas(nCurTotalNum + nvalue)
        self.TextMeshProGummies.text = strGingerman

        AudioHandler:PlayThemeSound("target")

        self.m_aniBtnGummyBoard:SetInteger("nPlayMode", 1)
        LeanTween.delayedCall(0.5, function()
            self.m_aniBtnGummyBoard:SetInteger("nPlayMode", 0)
        end)
    end)
    
end

-- nCollectType ---- 1: Credit 2: freespin 3: WildReels
function SweetBlastBonusGameUI:playMapCollectEffect(nCollectType) -- 地图上28个格子的收集特效
    AudioHandler:PlayBonusCollectionFly()

    local ftime = 1.2

    local param = SweetBlastLevelParam.m_BonusGameInfo
    local nGingermanKey = param.m_nCurGingermanKey
    local pos = self.m_trGameItems[nGingermanKey].position
    self.m_goMapBonusRewardEffect.transform.position = pos

    local posEnd = self.m_posBonusGameCoinWin
    if nCollectType == 1 then
        posEnd = self.m_posBonusGameCoinWin

    elseif nCollectType == 2 then
        posEnd = self.m_posFreeGamesBG

    elseif nCollectType == 3 then
        posEnd = self.m_posWildReelLogo

    end
    
    self.m_goMapBonusRewardEffect:SetActive(true)
    LeanTween.move(self.m_goMapBonusRewardEffect, posEnd, ftime):setOnComplete(function()
        self.m_goMapBonusRewardEffect:SetActive(false)

        AudioHandler:PlayThemeSound("target")
    end)
    
    return ftime
end

function SweetBlastBonusGameUI:Credit(nvalue, bDelayFlag)
    local param = SweetBlastLevelParam.m_BonusGameInfo
    param.m_nBonusGameCoins = math.floor( param.m_nBonusGameCoins + nvalue )
    
    local ftime = 0
    if bDelayFlag then -- 滑过桥的时间...
        ftime = 2.5
    end

    LeanTween.delayedCall(ftime, function()
        -- playEffect
        local ftime1 = self:playMapCollectEffect(1)
        LeanTween.delayedCall(ftime1, function()
            AudioHandler:PlayThemeSound("map_coin_up")

            self.m_slotsNumberBonusCoins:ChangeDelta(nvalue, 2.5)

            -- local strCoins = MoneyFormatHelper.numWithCommas( param.m_nBonusGameCoins )

            -- self.TextMeshProBonusCoins.text = strCoins
            
            self.m_goWinCoinEffect:SetActive(true)
            LeanTween.delayedCall(3.0, function()
                self.m_goWinCoinEffect:SetActive(false)
            end)
        end)

        -- 

    end)
    
end

function SweetBlastBonusGameUI:AddReels()
    local param = SweetBlastLevelParam.m_BonusGameInfo
    if param.m_nSlotsGameNum == nil then
        param.m_nSlotsGameNum = 1
    end
    param.m_nSlotsGameNum = param.m_nSlotsGameNum + 1
    
    local ftime1 = self:playMapCollectEffect(3)
    LeanTween.delayedCall(ftime1, function()
        self:refreshWildReelsAmout()
        self.m_goWildReelsInfoEffect:SetActive(true)
    end)

    LeanTween.delayedCall(ftime1 + 3.0, function()
        self.m_goWildReelsInfoEffect:SetActive(false)
    end)

end

function SweetBlastBonusGameUI:refreshWildReelsAmout()
    local param = SweetBlastLevelParam.m_BonusGameInfo
    
    if param.m_nSlotsGameNum == nil then
        param.m_nSlotsGameNum = 1
    end

    for i=1, 4 do
        self.listgowildreels[i]:SetActive(false)
    end

    for i=1, param.m_nSlotsGameNum do
        self.listgowildreels[i]:SetActive(true)
    end

    if param.m_nSlotsGameNum == 1 then
        for i=1, #self.listtrWildPos1 do
            self.listgowildreels[i].transform.position = self.listtrWildPos1[i].position
            self.listgowildreels[i].transform.localScale = Unity.Vector3(1, 1, 1)
        end
    elseif param.m_nSlotsGameNum == 2 then
        for i=1, #self.listtrWildPos2 do
            self.listgowildreels[i].transform.position = self.listtrWildPos2[i].position
            self.listgowildreels[i].transform.localScale = Unity.Vector3(0.7, 0.7, 0.7)
        end
    elseif param.m_nSlotsGameNum == 3 then
        for i=1, #self.listtrWildPos3 do
            self.listgowildreels[i].transform.position = self.listtrWildPos3[i].position
            self.listgowildreels[i].transform.localScale = Unity.Vector3(0.5, 0.5, 0.5)
        end
    elseif param.m_nSlotsGameNum == 4 then
        for i=1, #self.listtrWildPos4 do
            self.listgowildreels[i].transform.position = self.listtrWildPos4[i].position
            self.listgowildreels[i].transform.localScale = Unity.Vector3(0.5, 0.5, 0.5)
        end
    end
end

function SweetBlastBonusGameUI:FreeSpinAdd(nNum)
    local param = SweetBlastLevelParam.m_BonusGameInfo
    
    if param.m_nFreeSpinNum == nil then
        param.m_nFreeSpinNum = 0
    end
    param.m_nFreeSpinNum = param.m_nFreeSpinNum + nNum

    local ftime1 = self:playMapCollectEffect(2)
    LeanTween.delayedCall(ftime1, function()
        self.TextMeshProBonusFreeSpins.text = param.m_nFreeSpinNum 
            
        self.m_aniFreeGamesQiZiEffect:SetInteger("nPlayMode", 1)
        LeanTween.delayedCall(2.5, function()
            self.m_aniFreeGamesQiZiEffect:SetInteger("nPlayMode", 0)
        end)

    end)

end

function SweetBlastBonusGameUI:WildReel()
  --  Debug.Log("WildReel")
    
    local param = SweetBlastLevelParam.m_BonusGameInfo
    if param.m_listWildReelKey == nil then
        param.m_listWildReelKey = {}
    end
    local nsize = LuaHelper.tableSize(param.m_listWildReelKey)

    local nWildIndex = 0
    if nsize == 0 then
        nWildIndex = 2

    elseif nsize == 1 then
        nWildIndex = 0
        
    elseif nsize == 2 then
        nWildIndex = 4
        
    elseif nsize == 3 then
        nWildIndex = 1
        
    elseif nsize == 4 then
        nWildIndex = 3
        Debug.Log("------error!!--------")
    end

    table.insert(param.m_listWildReelKey, nWildIndex)

    local ftime1 = self:playMapCollectEffect(3)
    LeanTween.delayedCall(ftime1, function()
        self:refreshSingleWildReel(nWildIndex)
        self.m_goWildReelsInfoEffect:SetActive(true)

    end)

    LeanTween.delayedCall(ftime1 + 3.0, function()
        self.m_goWildReelsInfoEffect:SetActive(false)
    end)

end

function SweetBlastBonusGameUI:refreshSingleWildReel(nWildIndex)
    
    for k, v in pairs(self.listgowildreels) do
        local tr = v.transform:FindDeepChild(tostring(nWildIndex+1))
        tr.gameObject:SetActive(true)

        tr.localScale = Unity.Vector3(0.97, 0.75, 1.0)
    end

end

function SweetBlastBonusGameUI:initAllGameItems()
    local param = SweetBlastLevelParam.m_BonusGameInfo

    for i=1, self.m_nGridsAmount do
        local itemType = param.m_listMapItemType[i]
        if itemType == self.EnumBonusGameItemType.ItemType_Credit then
            local textPro = self.m_mapTextMeshProCreditValue[i]
            local value = param.m_mapCreditItemValue[i]
            local strCoins = MoneyFormatHelper.coinCountOmit(value)
            textPro.text = strCoins
            
            local trBG2 = self.m_trGameItems[i]:FindDeepChild("elementBG2")
            if trBG2 ~= nil then
                trBG2.gameObject:SetActive(false)
            end
        else 
            -- 非credit节点
            self.m_trGameItems[i]:FindDeepChild("elementBG2").gameObject:SetActive(true)
            self.m_mapTextMeshProCreditValue[i].text = ""
        end
    end

end

function SweetBlastBonusGameUI:AddRow()
    Debug.Log("AddRow")

    local param = SweetBlastLevelParam.m_BonusGameInfo
    if param.m_bAddRowFlag == nil then
        param.m_bAddRowFlag = false
    end
    param.m_bAddRowFlag = true
    param.m_WildReelRows = 4

    local ftime = self:playMapCollectEffect(3)
    LeanTween.delayedCall(ftime, function()
        self:updateWildReelsRow()
        self.m_goWildReelsInfoEffect:SetActive(true)
    end)

    LeanTween.delayedCall(ftime + 3.0, function()
        self.m_goWildReelsInfoEffect:SetActive(false)
    end)
end

function SweetBlastBonusGameUI:updateWildReelsRow()
    for i=1, 4 do
        local go = self.listGoReelBG4[i]
        go:SetActive(true)
    end

    for i=1, 4 do
        local goReels = self.listgowildreels[i]
        local trReels = goReels.transform
        for index=1, 5 do
            local tr = trReels:FindDeepChild(tostring(index))
            tr.localScale = Unity.Vector3(0.97, 0.97, 1.0)

        end
    end
    
end