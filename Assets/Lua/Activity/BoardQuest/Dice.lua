--介绍弹窗
local Dice = {}

function Dice:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("Dice")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)

    self.tableGoDice = LuaHelper.GetTableFindChild(self.transform, 2, "Dice")
    self.tableSpineDice = LuaHelper.GetTableFindChild(self.transform, 2, "Dice", CS.Spine.Unity.SkeletonAnimation)

    self.tableDice1 = {"dice_1_top","dice_1_left","dice_1_right","dice_1_left_back","dice_1_bot"}
    self.tableDice1Num = {
        {1, 2, 4, 5, 6},
        {2, 3, 6, 4, 5},
        {3, 5, 1, 2, 4},
        {4, 2, 6, 5, 3},
        {5, 4, 1, 3, 2},
        {6, 3, 5, 4, 1},
    }

    self.tableDice2 = {"dice_2_top","dice_2_left","dice_2_right","dice_2_left_back","dice_2_right_back","dice_2_bot"}
    self.tableDice2Num = {
        {1, 2, 4, 5, 3, 6},
        {2, 3, 6, 4, 1, 5},
        {3, 5, 1, 2, 6, 4},
        {4, 2, 6, 5, 1, 3},
        {5, 4, 1, 3, 6, 2},
        {6, 3, 5, 4, 2, 1},
    }
    self.goResult = self.transform:FindDeepChild("Result").gameObject
    self.textDice1 = self.transform:FindDeepChild("textDice1"):GetComponent(typeof(TextMeshProUGUI))
    self.textDice2 = self.transform:FindDeepChild("textDice2"):GetComponent(typeof(TextMeshProUGUI))
    self.textDice3 = self.transform:FindDeepChild("textDice3"):GetComponent(typeof(TextMeshProUGUI))
end

function Dice:show(nDice1, nDice2)
    if self.transform.gameObject == nil then
        self.m_bInitFlag = false
    else
        if self.transform.gameObject:Equals(nil) then
            self.m_bInitFlag = false
        end
    end
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:Init()
    end
    self.bCanHide = true

    self.transform.gameObject:SetActive(true)
    self.goResult:SetActive(false)

    --nDice2 = 6

    --控制骰子的面上的数字
    local skeletonAnimation1 = self.tableSpineDice[1]
    for i = 1, 5 do
        skeletonAnimation1.skeleton:SetAttachment(self.tableDice1[i], "num_"..(self.tableDice1Num[nDice1][i]))
    end

    local skeletonAnimation2 = self.tableSpineDice[2]
    for i = 1, 6 do
        skeletonAnimation2.skeleton:SetAttachment(self.tableDice2[i], "num_"..(self.tableDice2Num[nDice2][i]))
    end

    skeletonAnimation1.AnimationState:ClearTracks()
    skeletonAnimation1.AnimationState:SetAnimation(0, "dice_1", false).TrackTime = 0   
    skeletonAnimation2.AnimationState:ClearTracks()
    skeletonAnimation2.AnimationState:SetAnimation(0, "dice_2", false).TrackTime = 0

    for i = 1, 2 do
        self.tableSpineDice[i].timeScale = 0
        self.tableGoDice[i].transform.localScale = Unity.Vector3.zero
    end

    self.textDice1.text = tostring(nDice1)
    self.textDice2.text = tostring(nDice2)
    self.textDice3.text = tostring(nDice1 + nDice2)

    LeanTween.delayedCall(0.75, function()
        for i = 1, 2 do
            self.tableSpineDice[i].timeScale = 1
            self.tableGoDice[i].transform.localScale = Unity.Vector3.one * 0.55
        end
    end)

    LeanTween.delayedCall(1.18, function()
        ActivityAudioHandler:PlaySound("board_roll_dice")
    end)

    LeanTween.delayedCall(1.75, function()
        self.goResult:SetActive(true) --两个数字合并成一个
    end)

    LeanTween.delayedCall(2.2, function()
        ActivityAudioHandler:PlaySound("board_dice_combine")
    end)

    LeanTween.delayedCall(3.55, function()
        self:hide()
    end)
end

function Dice:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false

    ActivityHelper:PlayAni(self.transform.gameObject, "Hide")
    LeanTween.delayedCall(1, function()
        self.transform.gameObject:SetActive(false)
    end)
end

return Dice
