ActiveBetSizeChangeBar = {}

function ActiveBetSizeChangeBar:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local prefab = AssetBundleHandler:LoadAsset("ActivityCommon", "BetSizeChangeBar/BetSizeChangeBar.prefab")
    local go = Unity.Object.Instantiate(prefab)
    self.transform = go.transform
    self.transform:SetParent(UITop.m_transform, false)
    self.transform.localScale = Unity.Vector3.one
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

    self.imgFill = self.transform:FindDeepChild("Fill"):GetComponent(typeof(UnityUI.Image))
    self.trIcon = self.transform:FindDeepChild("Icon")
    
end 

function ActiveBetSizeChangeBar:Show(trUnloadedUI)
    self:Init()

    self.transform.gameObject:SetActive(true)
    self.fLife = 3
    self.transform.position = trUnloadedUI.position
    self.transform:SetAsFirstSibling()
    if ActiveThemeEntry.transform.position.x > 0 then
        self.transform.localScale = Unity.Vector3.one * 0.8
        self.trIcon.localScale = Unity.Vector3.one
    else
        self.trIcon.localScale = Unity.Vector3(-1, 1, 1)
        self.transform.localScale = Unity.Vector3(-1, 1, 1) * 0.8
    end
    ActivityHelper:PlayAni(self.transform.gameObject, "Show")

    for k, v in pairs(ActiveType) do
        local tr = self.trIcon:FindDeepChild(v)
        if tr then
            tr.gameObject:SetActive(v == ActiveManager.activeType)
        end
    end

    if ActiveManager.activeType then
        local targetValue = ActivityHelper:getAddSpinProgressBarValue({nTotalBet = SceneSlotGame.m_nTotalBet}, ActiveManager.activeType)
        self:ChangeValue(targetValue)
    end
    
end

function ActiveBetSizeChangeBar:Update()
    self.fLife = self.fLife - Unity.Time.deltaTime
    if self.fLife < 0 then
        ActivityHelper:PlayAni(self.transform.gameObject, "Hide")
        LeanTween.delayedCall(1.0, function()
            self.transform.gameObject:SetActive(false)
        end)
    end
end

function ActiveBetSizeChangeBar:ChangeValue(targetValue)
    if self.nLeanTweenId then
        if LeanTween.isTweening(self.nLeanTweenId) then
            LeanTween.cancel(self.nLeanTweenId)
        end
    end
    self.nLeanTweenId = LeanTween.value(self.imgFill.fillAmount, targetValue, 0.3):setOnUpdate(function(value)
        self.imgFill.fillAmount = value
    end).id
end