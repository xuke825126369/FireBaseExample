local SlotsNumber = {}

SlotsNumber.m_bInChange = false
SlotsNumber.m_fAge = 0.0
SlotsNumber.m_fIncSpeed = 0.1
SlotsNumber.m_fInc = 0.5 -- 不传时间的情况下 数值慢慢涨...
SlotsNumber.m_fTarget = 0.0
SlotsNumber.m_fMin = 0.0
SlotsNumber.m_fMax = 1.0
SlotsNumber.m_fCurrent = 0.0

SlotsNumber.m_strFormat = "N0"
SlotsNumber.m_TMProText = nil

SlotsNumber.m_bNeedEndFlag = false
SlotsNumber.m_fEndTime = 0.0
SlotsNumber.m_fChangeTimePassed = 0.0
SlotsNumber.m_fStartValue = 0.0

-- create 方法可以不传参数
-- max 参数没有意义了。。
function SlotsNumber:create(strFormat, min, max, current, fIncSpeed)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    if strFormat == nil then
        strFormat = ""
    end
    if min == nil then
        min = 0.0
    end
    if max == nil then
        max = 10000.0 * 10000.0 * 10000.0 * 10000.0
    end
    if current == nil then
        current = 0
    end
    if fIncSpeed == nil then
        fIncSpeed = 0.001
    end

    o.m_strFormat = strFormat
    o.m_fMin = 0.0 --min
    -- o.m_fMax = 10000.0 * 10000.0 * 10000.0 * 10000.0 -- max 不用了
    o.m_fCurrent = current
    o.m_fIncSpeed = fIncSpeed
    o.m_fTarget = current
    o.m_bInChange = false

    return o
end

function SlotsNumber:SetTimeEndFlag(bNeedEndFlag)
    self.m_bNeedEndFlag = bNeedEndFlag
end

function SlotsNumber:AddUIText(textMeshPro)
    Debug.Assert(textMeshPro, "AddUIText is Null")
    self.m_TMProText = textMeshPro
    if textMeshPro~=nil then
        self.m_TMProText.text = self:ToString()
    end
end

function SlotsNumber:ChangeTo(target, fEndTime)
    if fEndTime == nil then
        fEndTime = 0.0
    end

    local fDeltaValue = Unity.Mathf.Abs(target-self.m_fTarget)
    if fDeltaValue < 0.0001 then
        return
    end

    self.m_fEndTime = fEndTime
    self.m_fChangeTimePassed = 0.0
    if target<self.m_fMin then
        target = self.m_fMin
    end

    -- 2019-12-24 不要加限制...
    -- if target>self.m_fMax then
    --     target = self.m_fMax
    -- end

    if not self.m_bInChange then
        self.m_bInChange = true
        self.m_fAge = 0.0
        self.m_fInc = 0.5
    end

    self.m_fTarget = target

end

function SlotsNumber:ChangeDelta(deltaValue, ftime)
    if ftime == nil then
        ftime = 0.0
    end

    self:ChangeTo(self.m_fTarget + deltaValue, ftime)
end

function SlotsNumber:Update()
    if not self.m_bInChange then
        return
    end

    if self.m_fEndTime > 0.001 then
        if self.m_fChangeTimePassed < self.m_fEndTime then
            self.m_fChangeTimePassed = self.m_fChangeTimePassed + Unity.Time.deltaTime
            local fCoef = self.m_fChangeTimePassed / self.m_fEndTime
            self.m_fCurrent = self.m_fStartValue + (self.m_fTarget - self.m_fStartValue) * fCoef
            if self.m_fChangeTimePassed >= self.m_fEndTime then
                self:End()
            end
        else
            self:End()
        end    
    else
        self.m_fAge = self.m_fAge + Unity.Time.deltaTime
        -- local fValue = self.m_fIncSpeed -- self.m_fAge * 
        -- self.m_fInc = self.m_fInc + fValue

        if self.m_fTarget > self.m_fCurrent then
            local fDeltaValue = self.m_fTarget - self.m_fCurrent
            self.m_fInc = fDeltaValue/2500
            if self.m_fInc < 0.1 then
                self.m_fInc = 0.1
            end

            self.m_fCurrent = self.m_fCurrent + self.m_fInc
            
            if self.m_fCurrent >= self.m_fTarget then
                self:End()
            end
        else
            self.m_fCurrent = self.m_fCurrent - self.m_fInc
            if self.m_fCurrent <= self.m_fTarget then
                self:End()
            end
        end

        if self.m_bNeedEndFlag then
            if self.m_fAge > 2.5 then
                self:End()
            end
        end
    end

    if self.m_TMProText ~= nil then
        self.m_TMProText.text = self:ToString()
    end
end

function SlotsNumber:ToString()
    local integerPart = math.floor( self.m_fCurrent )
    local fractionalPart = self.m_fCurrent - integerPart
    
    local strCur = MoneyFormatHelper.numWithCommas(self.m_fCurrent)
    return strCur
end

function SlotsNumber:End(fEndTarget)
    if fEndTarget == nil then
        self.m_bInChange = false
        self.m_fCurrent = self.m_fTarget
        self.m_fStartValue = self.m_fTarget
        return
    end

    self.m_fTarget = fEndTarget
    self.m_bInChange = false
    self.m_fCurrent = self.m_fTarget
    self.m_fStartValue = self.m_fTarget

    if self.m_TMProText ~= nil then
        self.m_TMProText.text = self:ToString()
    end
end

return SlotsNumber
