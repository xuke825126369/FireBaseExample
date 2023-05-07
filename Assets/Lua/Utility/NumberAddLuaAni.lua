NumberAddLuaAni = {}

function NumberAddLuaAni:New(textMeshPro)
    local o = {}
	setmetatable(o, self)
	self.__index = self
    o:Init(textMeshPro)
    return o
end

function NumberAddLuaAni:Init(textMeshPro)
    Debug.Assert(textMeshPro, "AddUIText is Null")
    LuaAutoBindMonoBehaviour.Bind(textMeshPro.gameObject, self)
    self.m_TMProText = textMeshPro
    self.nTargetNumber = 0

    if self.bUpdate then
        self:Update()
    else
        self:End(self.nTargetNumber)
    end
end

function NumberAddLuaAni:UpdateText(des)
    self.m_TMProText.text = des
end

function NumberAddLuaAni:FormatText(nNumber)
    local nNumber = math.floor(nNumber)
    if nNumber == 0 then
        self:UpdateText("")
    else
        local strCur = MoneyFormatHelper.numWithCommas(nNumber)
        self:UpdateText(strCur)
    end
end

function NumberAddLuaAni:End(nTarget)
    self.nTargetNumber = nTarget
    self:FormatText(self.nTargetNumber)
    self.bUpdate = false
end

function NumberAddLuaAni:ChangeTo(nTarget, fDuringTime)
    if not fDuringTime then
        fDuringTime = 2.0
    end

    self:End(self.nTargetNumber)
    if nTarget > self.nTargetNumber and fDuringTime > 0.01 then
        self.nAddNumber = nTarget - self.nTargetNumber
        self.nTargetNumber = nTarget
        self.fBeginUpdateTime = Unity.Time.time
        self.fDuringTime = fDuringTime
        self.bUpdate = true
    else
        self.nTargetNumber = nTarget
        self:End(self.nTargetNumber)
    end
end

function NumberAddLuaAni:Update()
    if self.bUpdate then
        local fTime = Unity.Time.time - self.fBeginUpdateTime
        if fTime <= self.fDuringTime then
            local fPercent = 1.0 - fTime / self.fDuringTime
            fPercent = math.min(fPercent, 1.0)
            fPercent = math.max(fPercent, 0.0)
            local fTargetNumber = self.nTargetNumber - fPercent * self.nAddNumber
            self:FormatText(fTargetNumber)
        else
            self:End(self.nTargetNumber)
        end
    end
end
