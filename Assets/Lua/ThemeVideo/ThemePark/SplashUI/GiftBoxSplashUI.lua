--[[
    author:coldflag
    time:2021-09-08 16:23:35
]]

local GiftBoxSplashUI = {}


function GiftBoxSplashUI:Init()
    local assetPath = "LiHe.prefab"
    local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))

    self.obj = Unity.Object.Instantiate(goPrefab)
    self.obj.transform:SetParent(ThemeVideo2020Scene.mPopScreenCanvas, false)
    self.obj.transform.localScale = Unity.Vector3.one

    -- 
    
    self.obj:SetActive(false)
    local trTotalWin = self.obj.transform:FindDeepChild("JinBiValue")

    self.cpTotalWinText = trTotalWin:GetComponent(typeof(UnityUI.Text))
end

function GiftBoxSplashUI:Show(fValus)
    local textVal = MoneyFormatHelper.coinCountOmit(fValus)
    self.cpTotalWinText.text = textVal
    self.obj:SetActive(true)
end

function GiftBoxSplashUI:Hide()
    self.obj:SetActive(false)
    ThemeParkFreeSpin.bMapRewardFinish = true
end


return GiftBoxSplashUI