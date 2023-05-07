--[[
    author:coldflag
    time:2021-08-26 14:30:49
]]

local FreeSpinFinishSplashUI = {}

FreeSpinFinishSplashUI.m_transform = nil
FreeSpinFinishSplashUI.m_nSplashType = nil
FreeSpinFinishSplashUI.m_goAnimator = nil
FreeSpinFinishSplashUI.m_textMeshProWinCoins = nil

FreeSpinFinishSplashUI.m_bHidFlag = false
FreeSpinFinishSplashUI.m_fAge = 0.0
FreeSpinFinishSplashUI.m_fLife = ThemeParkConfig.FreeSpinSplashUILifeTime
FreeSpinFinishSplashUI.m_fAddCoinTime = 2
FreeSpinFinishSplashUI.fMoneyCount = 0.0

function FreeSpinFinishSplashUI:Init()
    local assetPath = "FreeSpinEndUI.prefab"
    local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    local obj = Unity.Object.Instantiate(goPrefab)

    obj.transform:SetParent(ThemeVideo2020Scene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    self.m_transform = obj.transform

    

    self.m_textMeshProWinCoins = self.m_transform:FindDeepChild("TextMeshProFreeSpinTotalWin"):GetComponent(typeof(UnityUI.Text))
    self.m_SlotsNumberWinCoins = SlotsNumber:create("", 0, 100000000000, 0, 2)
    self.m_SlotsNumberWinCoins:AddUIText(self.m_textMeshProWinCoins)
    self.m_SlotsNumberWinCoins:SetTimeEndFlag(true)
    self.m_SlotsNumberWinCoins:End(0)

    self.goFreeGameEnd = self.m_transform:FindDeepChild("FreeGameEndAni").gameObject
    self.levelUI = ThemeParkLevelUI
end


function FreeSpinFinishSplashUI:Update()
    if self.m_SlotsNumberWinCoins ~= nil and self.m_fAge > 0.5 then
        self.m_SlotsNumberWinCoins:Update()
    end
    
    self.m_fAge = self.m_fAge + Unity.Time.deltaTime

    if self.m_fAge > self.m_fAddCoinTime then
        if Unity.Input.GetMouseButtonUp(0) then
            self:Hide()
        end
    end

    if self.m_fAge > self.m_fLife then
        self:Hide()
    end
end


function FreeSpinFinishSplashUI:Show()
    self.OnSpinEndFlag = true
    self.m_nSplashType = SplashType.FreeSpinEnd
    self.fMoneyCount = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins

    self.m_transform.gameObject:SetActive(true)

    self.m_fAge = 0.0
    SlotsGameLua.m_fCoinTime = 3
    self.m_fLife = SlotsGameLua.m_fCoinTime + 3
    self.m_bHidFlag = false

    self.m_SlotsNumberWinCoins:End(0)
    self.m_SlotsNumberWinCoins:ChangeTo(self.fMoneyCount, SlotsGameLua.m_fCoinTime)
    AudioHandler:PlayFreeGamePopupEndSound()

end


function FreeSpinFinishSplashUI:Hide()
    if self.m_bHidFlag then
        return 
    end

    self.m_bHidFlag = true
    AudioHandler:StopWinSound()
    self.levelUI:PlayAnimator(self.goFreeGameEnd, "Hide")
    AudioHandler:PlayFreeGamePopupEndSound()

    local fTime = 5
    if SlotsGameLua:orTriggerBigWin(self.fMoneyCount, SceneSlotGame.m_nTotalBet) then
        fTime = 10
    end
    SceneSlotGame:collectFreeSpinTotalWins(fTime)
    self.m_SlotsNumberWinCoins:End(self.fMoneyCount)
    LeanTween.delayedCall(self.levelUI.fFreeSpinPlayCutSceneTime, function()
        ThemeParkFreeSpinUI:PlaySwitchFreeSpinScene() -- 播放转场动画
    end)

    LeanTween.delayedCall(self.levelUI.fFreeSpinPlayCutSceneTime + self.levelUI.fFreeSpinLoadSceneTime, function()
        self.m_transform.gameObject:SetActive(false)
        SceneSlotGame:ShowFreeSpinUI(false)
        SceneSlotGame:OnSplashHide(self.m_nSplashType)
        self.levelUI:OnFreeSpinEndSplashUIHide()

        SceneSlotGame.m_bUIState = true
        LeanTween.delayedCall(1.0, function()
            SlotsGameLua:ShowCustomBigWin(self.fMoneyCount, function()
                SceneSlotGame.m_bUIState = false
            end)
        end)
        
    end)
end

return FreeSpinFinishSplashUI