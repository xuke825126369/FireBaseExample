--[[
    author:coldflag
    time:2021-09-08 17:17:50
]]


local FreeSpinExtraSplashUI = {}

FreeSpinExtraSplashUI.m_fAge = 0.0
FreeSpinExtraSplashUI.fLife = ThemeParkConfig.FreeSpinSplashUILifeTime
FreeSpinExtraSplashUI.m_fCanQuickHideTime = ThemeParkConfig.FreeSpinSplashCanQuickHideTime --需要等待一段时间才可以点击关闭
FreeSpinExtraSplashUI.m_bHidFlag = false


function FreeSpinExtraSplashUI:Init()
    local assetPath = "FreeSpinAgainUI.prefab"
    local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))

    self.obj = Unity.Object.Instantiate(goPrefab)
    self.obj.transform:SetParent(ThemeVideo2020Scene.mPopScreenCanvas, false)
    self.obj.transform.localScale = Unity.Vector3.one

    LuaAutoBindMonoBehaviour.Bind(self.obj, self)
    
    self.obj:SetActive(false)
    self.goAni = self.obj.transform:FindDeepChild("FreeGameAgainAni")

    local trTextMeshProFreeSpinNum = self.obj.transform:FindDeepChild("TextMeshProFreeSpinNum")

    self.cpExtraNumText = trTextMeshProFreeSpinNum:GetComponent(typeof(UnityUI.Text))

end


function FreeSpinExtraSplashUI:Show()
    self.obj:SetActive(true)

    self.cpExtraNumText.text = ThemeParkConfig.FreeSpinTimes_3rdScatter

    self.m_fAge = 0.0
    self.m_bHidFlag = false

    
end

function FreeSpinExtraSplashUI:Update()
    self.m_fAge = self.m_fAge + Unity.Time.deltaTime

    if self.m_fAge > self.m_fCanQuickHideTime then
        if Unity.Input.GetMouseButtonUp(0) then
            self:Hide()
        end
    end

    if self.m_fAge > self.fLife then
        self:Hide()
    end
end


function FreeSpinExtraSplashUI:Hide()
    if self.m_bHidFlag then
        return 
    end

    self.m_bHidFlag = true

    self.obj:SetActive(false)

    if ThemeParkLevelUI.bMoving then
        ThemeParkLevelUI.bMoving = false
    end

    local time = ThemeParkConfig.FreeSpinExtraCloseDelaySpinAgain

    LeanTween.delayedCall(time, function()
        SceneSlotGame.m_bUIState = false
    end)

    -- ThemeParkFreeSpin.bMapRewardFinish = true
end

return FreeSpinExtraSplashUI