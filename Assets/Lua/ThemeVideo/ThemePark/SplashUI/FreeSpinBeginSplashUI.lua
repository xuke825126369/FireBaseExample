--[[
    author:coldflag
    time:2021-08-26 09:53:58
]]

local FreeSpinBeginSplashUI = {}

FreeSpinBeginSplashUI.m_nSplashType = nil
FreeSpinBeginSplashUI.mFreeSpinCountText = nil
FreeSpinBeginSplashUI.goFreeGameBegin = nil
FreeSpinBeginSplashUI.levelUI = nil

FreeSpinBeginSplashUI.m_fAge = 0.0
FreeSpinBeginSplashUI.fLife = ThemeParkConfig.FreeSpinSplashUILifeTime
FreeSpinBeginSplashUI.m_fCanQuickHideTime = ThemeParkConfig.FreeSpinSplashCanQuickHideTime --需要等待一段时间才可以点击关闭
FreeSpinBeginSplashUI.m_bHidFlag = false

--[[
    @desc: 读取FreeSpinBeginUI预制件，并初始化相关参数
    author:coldflag
    time:2021-08-26 10:18:09
    @return:
]]
function FreeSpinBeginSplashUI:Init()
    local assetPath = "FreeSpinBeginUI.prefab"
    local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))   

    local obj = Unity.Object.Instantiate(goPrefab)
    obj.transform:SetParent(ThemeVideo2020Scene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)

    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

    self.mFreeSpinCountText = self.m_transform:FindDeepChild("TextMeshProFreeSpinNum"):GetComponent(typeof(UnityUI.Text))
    self.goFreeGameBegin = self.m_transform:FindDeepChild("FreeGameBegin").gameObject
    self.buttonStart = self.m_transform:FindDeepChild("ButtonStart"):GetComponent(typeof(UnityUI.Button))

    DelegateCache:addOnClickButton(self.buttonStart)
    self.buttonStart.onClick:AddListener(function()
		self:OnClickBtn()
    end)
    
    self.levelUI = ThemeParkLevelUI
end

function FreeSpinBeginSplashUI:Show()
    self.m_nSplashType = SplashType.FreeSpin
    self.m_transform.gameObject:SetActive(true)

    self.mFreeSpinCountText.text = SlotsGameLua.m_GameResult.m_nNewFreeSpinCount

    self.m_fAge = 0.0
    self.m_bHidFlag = false

    AudioHandler:PlayFreeGamePopupSound()
end

function FreeSpinBeginSplashUI:OnClickBtn()
    if not self.buttonStart.interactable then
        return
    end

    self.buttonStart.interactable = false
    AudioHandler:PlayFreeGamePopupBtnSound()
    self:Hide()
end

function FreeSpinBeginSplashUI:Update()
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

function FreeSpinBeginSplashUI:Hide()
    if self.m_bHidFlag then
        return 
    end

    self.m_bHidFlag = true
    self.levelUI:PlayAnimator(self.goFreeGameBegin, "Hide")

    AudioHandler:PlayFreeGamePopupSound()
    LeanTween.delayedCall(self.levelUI.fFreeSpinPlayCutSceneTime, function()
        ThemeParkFreeSpinUI:PlaySwitchFreeSpinScene() -- 播放转场动画
    end)

    LeanTween.delayedCall(self.levelUI.fFreeSpinPlayCutSceneTime + self.levelUI.fFreeSpinLoadSceneTime, function()
        self.m_transform.gameObject:SetActive(false)
        self.levelUI:OnFreeSpinBeginSplashUIHide()
        SceneSlotGame:OnSplashHide(self.m_nSplashType)
    end)
end


return FreeSpinBeginSplashUI