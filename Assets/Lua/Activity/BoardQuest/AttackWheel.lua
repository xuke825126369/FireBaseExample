local AttackWheel = {}

function AttackWheel:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("AttackWheel")
    Debug.Assert(prefabObj)
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    if GameConfig.IS_GREATER_169 then
        self.popController.adapterContainer.localScale = Unity.Vector3.one * 0.9
    end

    self.btn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btn)
    self.btn.onClick:AddListener(function()
        self:OnClick()
    end)

    self.trWheel = self.transform:FindDeepChild("Wheel")
    self.goWheel = self.trWheel.gameObject

    self.fMaxSpeed = -400

    self.goCannon = self.transform:FindDeepChild("Cannon").gameObject

    self.tableGoBomb = {}
    local tableGoBox = LuaHelper.GetTableFindChild(self.transform, 8, "box")
    for i = 1, 8 do
        self.tableGoBomb[i] = tableGoBox[i].transform:FindDeepChild("bomb").gameObject
    end
end

function AttackWheel:show(bShowFireAgain, goCannonOnBoard)
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
    self.btn.interactable = true
    --ViewScaleAni:Show(self.transform.gameObject)
    self.transform.gameObject:SetActive(true)
    self.bShowFireAgain = bShowFireAgain
    self.goCannonOnBoard = goCannonOnBoard
    for i = 1, 8 do
        self.tableGoBomb[i]:SetActive(true)
    end
    self.trWheel.localEulerAngles = Unity.Vector3.zero
    ActivityAudioHandler:PlaySound("board_wheel_pop")
    if bShowFireAgain then
        GlobalAudioHandler:SwitchActiveBackgroundMusic("board_attack_music")
    end
end

function AttackWheel:OnClick()
    self.btn.interactable = false
    local nIndex = LuaHelper.GetIndexByRate(BoardQuestConfig.ATTACK_WHEEL_STOP_RATE)
    self:Rotate(nIndex)
    ActivityAudioHandler:PlaySound("board_button")
end

function AttackWheel:Rotate(nTargetIndex)
    local fAngle = 45
    local fHalfAngle = fAngle/2
    local fTargetAngle = (nTargetIndex - 1) * fAngle --中点

    local fTime2 = 1.5
    local fTimt3 = 4.5

    local nIndex = math.floor(((self.trWheel.localEulerAngles.z % 360 + fHalfAngle) % 360) / fAngle)

    local seq = LeanTween.sequence()
    local l = LeanTween.rotateZ(self.goWheel, -360 * 3 + fTargetAngle / 2, fTime2)
    :setEase(LeanTweenType.easeInSine)
    :setOnUpdate(function()
        local nIndex2 = math.floor(((self.trWheel.localEulerAngles.z % 360 + fHalfAngle) % 360) / fAngle)
        if nIndex2 ~= nIndex then
            nIndex = nIndex2
            ActivityAudioHandler:PlaySound("board_wheel_tik")
        end
    end)
    seq:append(l)
    table.insert(ActivityHelper.m_LeanTweenIDs, l.id)
    
    local l = LeanTween.rotateZ(self.goWheel, -360 * 6 + fTargetAngle, fTimt3)
    :setEase(LeanTweenType.easeOutQuad)
    :setOnUpdate(function()
        local nIndex2 = math.floor(((self.trWheel.localEulerAngles.z % 360 + fHalfAngle) % 360) / fAngle)
        if nIndex2 ~= nIndex then
            nIndex = nIndex2
            ActivityAudioHandler:PlaySound("board_wheel_tik")
        end
    end)
    :setOnComplete(function()
        ActivityAudioHandler:PlaySound("board_wheel_stop")
    end)
    seq:append(l)
    table.insert(ActivityHelper.m_LeanTweenIDs, l.id)

    local l = LeanTween.delayedCall(0.5, function()
        self:RotateEnd(nTargetIndex)
    end)
    seq:append(l)
    table.insert(ActivityHelper.m_LeanTweenIDs, l.id)
end

function AttackWheel:RotateEnd(nTargetIndex)
    local nIndex = nTargetIndex
    local nType = BoardQuestConfig.ATTACK_WHEEL[nTargetIndex]
    local nValue = BoardQuestConfig.ATTACK_WHEEL_POWER[nType]

    BoardQuestConfig.BOOMER_NAME =  BoardQuestConfig.BOOMER_NAME or LuaHelper.GetKeyValueSwitchTable(BoardQuestConfig.BOOMER)
    ActivityHelper:PlayAni(self.goCannon, BoardQuestConfig.BOOMER_NAME[nType])
    ActivityAudioHandler:PlaySound("board_ball_flyto_cannon")
    GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    self.tableGoBomb[nTargetIndex]:SetActive(false)
    LeanTween.delayedCall(2, function()
        ActivityHelper:PlayAni(self.transform.gameObject, "Hide")
        --ViewScaleAni:Hide(self.transform.gameObject)
    end)
    LeanTween.delayedCall(3, function()
        self.transform.gameObject:SetActive(false)
        ActivityAudioHandler:PlaySound("board_cannon_fire")
        GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
        ActivityHelper:PlayAni(self.goCannonOnBoard, "Shoot")
    end)
    LeanTween.delayedCall(3.5, function()
        BoardQuestMainUIPop:atk(nValue, self.bShowFireAgain, self.goCannonOnBoard)
    end)
end

return AttackWheel