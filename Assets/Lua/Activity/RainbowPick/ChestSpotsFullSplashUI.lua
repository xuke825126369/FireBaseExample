--收集一个箱子，然后没有空位了的弹窗
local ChestSpotsFullSplashUI = {}

function ChestSpotsFullSplashUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("ChestSpotsFullSplashUI")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    self.btn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btn)
    self.btn.onClick:AddListener(function()
        self:hide()
    end)
end

function ChestSpotsFullSplashUI:Show()
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
    self.bCanHide = true
    ActivityAudioHandler:PlaySound("rainbow_normal_pop")
    GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    ViewScaleAni:Show(self.transform.gameObject)
end

function ChestSpotsFullSplashUI:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    ActivityAudioHandler:PlaySound("rainbow_closeWindow")
    self.popController:hide(false, function()
        RainbowPickMainUIPop.bCanClick = true
    end)
end

return ChestSpotsFullSplashUI