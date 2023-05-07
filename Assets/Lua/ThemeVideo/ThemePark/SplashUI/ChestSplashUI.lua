--[[
    author:coldflag
    time:2021-09-08 11:48:20
]]

local ChestSplashUI = {}



function ChestSplashUI:Init()
    local assetPath = "Baoxiang.prefab"
    local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))

    self.obj = Unity.Object.Instantiate(goPrefab)
    self.obj.transform:SetParent(ThemeVideo2020Scene.mPopScreenCanvas, false)
    self.obj.transform.localScale = Unity.Vector3.one

    -- 
    
    self.obj:SetActive(false)
    local trTotalWin = self.obj.transform:FindDeepChild("JinBiValue")
    local trPrize = self.obj.transform:FindDeepChild("PValue")
    local trMulti = self.obj.transform:FindDeepChild("MNumber")

    self.cpTotalWinText = trTotalWin:GetComponent(typeof(UnityUI.Text))
    self.cpPrizeText = trPrize:GetComponent(typeof(UnityUI.Text))
    self.cpMultiText = trMulti:GetComponent(typeof(UnityUI.Text))
end


function ChestSplashUI:Show(fPrize, nMulti)
    local textPrize = MoneyFormatHelper.coinCountOmit(fPrize, 0)
    self.cpPrizeText.text = textPrize

    self.cpMultiText.text = nMulti

    local fReward = fPrize * nMulti
    self.cpTotalWinText.text = MoneyFormatHelper.coinCountOmit(fReward, 0)
    self.obj:SetActive(true)
end

function ChestSplashUI:Hide()
    self.obj:SetActive(false)
    ThemeParkFreeSpin.bMapRewardFinish = true
end



return ChestSplashUI