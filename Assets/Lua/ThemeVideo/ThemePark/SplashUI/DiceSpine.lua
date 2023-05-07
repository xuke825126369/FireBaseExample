--[[
    abstruct: 这是掷骰子的动画画面
    author:coldflag
    time:2021-09-08 18:45:07
]]

local DiceSpine = {}


function DiceSpine:Init()
    local trLevelBG = ThemeVideo2020Scene.mNewGameNodeParent.transform:FindDeepChild("LevelBG")

    local trDice = trLevelBG:FindDeepChild("Shaizi")
    local trDiceSpine = trDice:FindDeepChild("DiceSpine")

    self.goDice = trDiceSpine.gameObject
    self.cpSpineDice = trDiceSpine:GetComponent(typeof(CS.Spine.Unity.SkeletonAnimation))
    self.tableDiceNum = {
        {1, 2, 4, 5, 3, 6},
        {2, 3, 6, 4, 1, 5},
        {3, 5, 1, 2, 6, 4},
        {4, 2, 6, 5, 1, 3},
        {5, 4, 1, 3, 6, 2},
        {6, 3, 5, 4, 2, 1},
    }

end

function DiceSpine:Show(nDiceNum)
    if self.trDice == nil then
        self.bInited = false
    else
        if self.trDice:Equals(nil) then
            self.bInited = false
        end
    end

    if not self.bInited then
        self.bInited = true
        self:Init()
    end

    self.bCanHide = true
    local ArrayNum = self:GetArrayElemByFirstNum(nDiceNum)
    Debug.Assert(ArrayNum, "ArrayNum: "..nDiceNum)
    local skeletonAnimation = self.cpSpineDice
    for i = 1, 5 do
        Debug.Assert(skeletonAnimation.Skeleton ~= nil, skeletonAnimation.gameObject.name)
        skeletonAnimation.Skeleton:SetAttachment(i, ArrayNum[i])
    end

    skeletonAnimation.AnimationState:ClearTracks()
    skeletonAnimation.AnimationState:SetAnimation(0, "animation", false).TrackTime = 0
    
    self.cpSpineDice.timeScale = 0
    LeanTween:delayedCall(0.75, function()
        self.cpSpineDice.timeScale = 1
    end)

end

--[[
    @desc: 根据子元素的第一个元素，返回该子元素
    author:coldflag
    time:2021-09-09 15:11:45
    --@nFirstNum: 
    @return:
]]
function DiceSpine:GetArrayElemByFirstNum(nFirstNum)
    for k, v in pairs(self.tableDiceNum) do
        if v[1] == nFirstNum then
            return v
        end
    end
end


return DiceSpine