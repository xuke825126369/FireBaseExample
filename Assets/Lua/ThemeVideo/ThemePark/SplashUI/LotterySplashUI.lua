--[[
    author:coldflag
    time:2021-09-08 19:23:31
]]

local LotterySplashUI = {}
LotterySplashUI.nFreeSpinNum = nil -- Hot Air Balloon Trip 的已用的FreeSpin次数

function LotterySplashUI:Init()
    local assetPath = "Lottery.prefab"
    local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))

    self.obj = Unity.Object.Instantiate(goPrefab)
    self.obj.transform:SetParent(ThemeVideo2020Scene.mPopScreenCanvas, false)
    self.obj.transform.localScale = Unity.Vector3.one

    
    
    self.obj:SetActive(false)

    self.nFreeSpinNum = 0 -- 初始已用0次
    
    self.trHotAirBalloon = self.obj.transform:FindDeepChild("HotAirBalloon")
    self.trHotAirBalloonTrip = self.obj.transform:FindDeepChild("HotAirBalloonTrip")
    local cpHotAirFreeSpinNum = self.trHotAirBalloonTrip:FindDeepChild("NumberCount"):GetComponent(typeof(UnityUI.Text))
    cpHotAirFreeSpinNum.text = ThemeParkConfig.FreeSpin_HotAirBalloonTrip_FreeSpinNums -- 总次数
    self.cpHotAirLeftNum = self.trHotAirBalloonTrip:FindDeepChild("Left"):GetComponent(typeof(UnityUI.Text))
    self.cpHotAirLeftNum.text = self.nFreeSpinNum
end

function LotterySplashUI:Show(nGameType)
    self.trHotAirBalloon.gameObject:SetActive(false)
    self.trHotAirBalloonTrip.gameObject:SetActive(false)
    
    
end


return LotterySplashUI