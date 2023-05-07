local WheelUI = {}
WheelUI.tableYellowMultuile = {7, 2, 4, 8, 3, 2, 6, 2, 5, 10, 4, 3} -- 12
WheelUI.tableRedMultuile = {5, 15, 8, 5, 20, 6, 5, 6, 10 , 8, 7, 5, 6, 10, 7} -- 15
WheelUI.tableGreenMultuile = {2, 5, 3, 6, 2, 10, 3, 4} -- 8

WheelUI.m_transform = nil -- GameObject

function WheelUI:Init()
    self.m_transform = MardiGrasLevelUI.m_transform:FindDeepChild("MardigrasLevel")

    self.goWheelYellowRotateObj = self.m_transform:FindDeepChild("zhuanpanY/ZPhneirongbai").gameObject
    self.goWheelRedRotateObj = self.m_transform:FindDeepChild("zhuanpanR/ZPhneirongbai").gameObject
    self.goWheelGreenRotateObj = self.m_transform:FindDeepChild("zhuanpaG/ZPhneirongbai").gameObject

    self.goYellowWinEffect = self.m_transform:FindDeepChild("zhuanpanY/WinPSEffect").gameObject
    self.goRedWinEffect = self.m_transform:FindDeepChild("zhuanpanR/WinPSEffect").gameObject
    self.goGreenWinEffect = self.m_transform:FindDeepChild("zhuanpaG/WinPSEffect").gameObject

    self:ResetAngle()
end

function WheelUI:ResetAngle()
    self.goWheelYellowRotateObj.transform.localEulerAngles = Unity.Vector3.zero
    self.goWheelRedRotateObj.transform.localEulerAngles = Unity.Vector3.zero
    self.goWheelGreenRotateObj.transform.localEulerAngles = Unity.Vector3.zero
    
    self.goYellowWinEffect:SetActive(false)
    self.goRedWinEffect:SetActive(false)
    self.goGreenWinEffect:SetActive(false)
end

function WheelUI:PlayRotateAni()
    local nFindDistance = self.currentSelectYellowAngles + 360 * math.random(7, 9)
    local fRotateTime = math.random(5, 7)
    LeanTween.rotate(self.goWheelYellowRotateObj.gameObject, Unity.Vector3(0, 0, nFindDistance), fRotateTime):setEase(LeanTweenType.easeOutSine):setOnUpdate(function()
        
    end):setOnComplete(function()
        self.goYellowWinEffect:SetActive(true)
    end)    

    local nFindDistance = self.currentSelectRedAngles + 360 * math.random(7, 9)
    LeanTween.rotate(self.goWheelRedRotateObj.gameObject, Unity.Vector3(0, 0, nFindDistance), fRotateTime):setEase(LeanTweenType.easeOutSine):setOnUpdate(function()
       
    end):setOnComplete(function()
        self.goRedWinEffect:SetActive(true)
    end)

    local nFindDistance = self.currentSelectGreenAngles + 360 * math.random(7, 9)
    LeanTween.rotate(self.goWheelGreenRotateObj.gameObject, Unity.Vector3(0, 0, nFindDistance), fRotateTime):setEase(LeanTweenType.easeOutSine):setOnUpdate(function()

    end):setOnComplete(function()
        self.goGreenWinEffect:SetActive(true)
    end)

    LeanTween.delayedCall(fRotateTime + 2.0, function()
        MardiGrasLevelUI.mFreeSpinBeginSplashUI:Show()
    end)

end

function WheelUI:SetMultuile()
    local nYellowIndex = math.random(1, #self.tableYellowMultuile)
    local nRedIndex = math.random(1, #self.tableRedMultuile)
    local nGreenIndex = math.random(1, #self.tableGreenMultuile)

    MardiGrasFunc.nSelectedYellowMultuile = self.tableYellowMultuile[nYellowIndex]
    MardiGrasFunc.nSelectedRedMultuile = self.tableRedMultuile[nRedIndex]
    MardiGrasFunc.nSelectedGreenMultuile = self.tableGreenMultuile[nGreenIndex]

    self.currentSelectYellowAngles = (nYellowIndex - 1) * 360 / #self.tableYellowMultuile + 1.5 * 360 / #self.tableYellowMultuile
    self.currentSelectRedAngles = (nRedIndex - 1) * 360 / #self.tableRedMultuile + 360 / #self.tableRedMultuile / 2 - 2 * 360 / #self.tableRedMultuile
    self.currentSelectGreenAngles = (nGreenIndex - 1) * 360 / #self.tableGreenMultuile - 1 * 360 / #self.tableGreenMultuile

    local fAddMoneyCount = SceneSlotGame.m_nTotalBet * MardiGrasFunc.nSelectedYellowMultuile * MardiGrasFunc.nSelectedGreenMultuile
    MardiGrasLevelUI:CollectMoneyToDB(fAddMoneyCount)
    
    if not MardiGrasFunc.m_bSimulationFlag then
        Debug.Log("nSelected Yellow Multuile: "..MardiGrasFunc.nSelectedYellowMultuile)
        Debug.Log("nSelected Red Multuile: "..MardiGrasFunc.nSelectedRedMultuile)
        Debug.Log("nSelected Green Multuile: "..MardiGrasFunc.nSelectedGreenMultuile)
    end

end

return WheelUI