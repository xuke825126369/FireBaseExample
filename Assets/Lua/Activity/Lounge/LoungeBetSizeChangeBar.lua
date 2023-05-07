--改变BetSize时，BottomUI BetSize上方弹出的宝箱收集条
LoungeBetSizeChangeBar = {}

function LoungeBetSizeChangeBar:Init()
    if not LoungeHandler:isLoungeMember() then
        return
    end

    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local goPrefab = AssetBundleHandler:LoadGoldenLoungeAsset("LoungeBetSizeChangeBar/BetSizeChangeBar.prefab")
    local goPanel = Unity.Object.Instantiate(goPrefab)
    self.transform = goPanel.transform
    self.transform:SetParent(UITop.m_transform, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.imgFill = self.transform:FindDeepChild("Fill"):GetComponent(typeof(UnityUI.Image))
    EventHandler:AddListener("OnTotalBetChange", self)
end 

function LoungeBetSizeChangeBar:Show(targetValue)
    if self.bActive then
        self.fLife = 3
    else
        self.bActive = true
        self.transform.gameObject:SetActive(true)
        self.transform:SetAsLastSibling()
        if GameLevelUtil.isPortraitLevel(ThemeLoader.themeKey) then
            self.transform.localScale = Unity.Vector3.one * 0.8
        else
            self.transform.localScale = Unity.Vector3.one 
        end
        self.fLife = 3
        self.transform.position = SceneSlotGame.m_goBottomUILeftNormal.transform.position
    end

    self:ChangeValue(targetValue)
end

function LoungeBetSizeChangeBar:Update(dt)
    if not self.bActive then return end
    self.fLife = self.fLife - Unity.Time.deltaTime
    if self.fLife < 0 then
        self.bActive = false
        self.transform.gameObject:SetActive(false)
    end
end

function LoungeBetSizeChangeBar:OnDestroy()
    EventHandler:RemoveListener("OnTotalBetChange", self)
    if self.nLeanTweenId then
        if LeanTween.isTweening(self.nLeanTweenId) then
            LeanTween.cancel(self.nLeanTweenId)
        end
    end
end

function LoungeBetSizeChangeBar:ChangeValue(targetValue)
    if self.nLeanTweenId then
        if LeanTween.isTweening(self.nLeanTweenId) then
            LeanTween.cancel(self.nLeanTweenId)
        end
    end
    self.nLeanTweenId = LeanTween.value(self.imgFill.fillAmount, targetValue, 0.3):setOnUpdate(function(value)
        self.imgFill.fillAmount = value
    end).id
end

function LoungeBetSizeChangeBar:OnTotalBetChange()
    local nTotalBet = SceneSlotGame.m_nTotalBet
    local nBaseCoin = LoungeConfig:getOneDollarCoins()
    local fCoef = nTotalBet / nBaseCoin
    local fValue = LuaHelper.Clamp(fCoef, 0.0, 1.0)
    self:Show(fValue)
end