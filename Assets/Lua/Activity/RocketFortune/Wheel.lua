local Wheel = {}

local WheelConfig = {
    steps = {1, 2, 3, 4, 5, 6}, -- 转轮格子(格子ID: 1 2 3 4 5 6)对应的移动步数 steps
    probs = {20, 30, 30, 20, 10, 10} -- 随机到每个格子的概率是不一样的
}

function Wheel:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("Wheel")
    Debug.Assert(prefabObj)
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    if GameConfig.IS_GREATER_169 then
        self.popController.adapterContainer.localScale = Unity.Vector3.one * 0.85
    end

    self.m_btnSpin = self.transform:FindDeepChild("SpinBtn"):GetComponent(typeof(UnityUI.Button))
    self.m_btnSpin.onClick:AddListener(function()
        self:onSpinBtnClicked()
    end)
    DelegateCache:addOnClickButton(self.m_btnSpin)
    ActivityHelper:addUIEventObserver(self, function(bFlag)
        self.m_btnSpin.interactable = bFlag
    end)

    self.m_trWheel = self.transform:FindDeepChild("Wheel")

    self.m_textSpinCount = self.transform:FindDeepChild("SpinCount"):GetComponent(typeof(TextMeshProUGUI))
    --Action次数
    ActivityHelper:addDataObserver("nAction", self, function(self, nAction)
        self.m_textSpinCount.text = "SPINS LEFT: "..tostring(nAction)
    end)
end

function Wheel:Show()
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
    if RocketFortuneDataHandler.data.nSuperSpinCount > 0 then
        -- TODO 
    end
    ActivityHelper:postUIEvent(self, true)
    ActivityHelper:postUIEvent(RocketFortuneMainUIPop, true)
    self.m_trWheel.rotation = Unity.Quaternion.Euler(0, 0, 0)
    ViewScaleAni:Show(self.transform.gameObject)
end

function Wheel:getWheelRandomIndex()
    local nRandomIndex = LuaHelper.GetIndexByRate(WheelConfig.probs)
    local nStep = WheelConfig.steps[nRandomIndex]
    return nRandomIndex
end

function Wheel:onSpinBtnClicked()  
    ActivityHelper:postUIEvent(RocketFortuneMainUIPop, false)
    ActivityHelper:postUIEvent(self, false)
    ActivityAudioHandler:PlaySound("click_spin")
    RocketFortuneUnloadedUI:refreshUI(false)
    ActivityHelper:AddMsgCountData("nAction", -1)

    local nWheelIndex = self:getWheelRandomIndex()
    local nStep = WheelConfig.steps[nWheelIndex]
    RocketFortuneLevelManager.nCurrentTarget = RocketFortuneDataHandler.data.nLevelProgress + nStep
    local isWin = RocketFortuneMainUIPop:checkIsWin(RocketFortuneLevelManager.nCurrentTarget)
    if not isWin then
        RocketFortuneMainUIPop:checkIsSpecialItem(RocketFortuneLevelManager.nCurrentTarget)
    end

    local toDegree = -360 * 10 - 360 / 6 * (nWheelIndex-1)
    local lastDegree = 0
    LeanTween.value(0, toDegree, 2.0):setEase (LeanTweenType.easeInOutQuad):setOnUpdate(function(value)
        local index = math.floor((math.floor(value) % 360 + 18 ) / 36) + 1
        if(index ~= self.lastIndex) then
            self.lastIndex = index
            ActivityAudioHandler:PlaySound("golden_wheel_tick")
        end
        local angularSpeed = math.abs(value - lastDegree) / Unity.Time.deltaTime
        local blurAlpha = angularSpeed >= 400 and 1 or angularSpeed / 400
        self.m_trWheel.rotation = Unity.Quaternion.Euler(0, 0, value)
        lastDegree = value
    end):setOnComplete(function()
        --self.m_goEndAnim:SetActive(true)
        ActivityAudioHandler:PlaySound("reel_stop")
        LeanTween.delayedCall(self.transform.gameObject, 1.7, function()
            --self.m_goEndAnim:SetActive(false)
            self:hide()
            LeanTween.delayedCall(0.5, function()
                RocketFortuneLevelManager:beginPlayerToTarget()
            end)
        end)
    end)
end

function Wheel:hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

return Wheel