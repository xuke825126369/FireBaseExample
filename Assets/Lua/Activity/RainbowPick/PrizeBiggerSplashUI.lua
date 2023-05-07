local PrizeBiggerSplashUI = {}

function PrizeBiggerSplashUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("PrizeBiggerSplashUI")
    self.gameObject = Unity.Object.Instantiate(prefabObj)
    self.gameObject:SetActive(false)
    self.transform = self.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.gameObject, nil, PopTweenType.alpha)

    self.btn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btn)
    self.btn.onClick:AddListener(function()
        self:hide()
    end)

    self.textRatio = self.transform:FindDeepChild("textRatio"):GetComponent(typeof(UnityUI.Text))
end

function PrizeBiggerSplashUI:show(nRatio)
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
    ViewScaleAni:Show(self.transform.gameObject)
    self.textRatio.text = nRatio.."%"
    ActivityAudioHandler:PlaySound("rainbow_normal_pop")
    GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
end

function PrizeBiggerSplashUI:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    ActivityAudioHandler:PlaySound("rainbow_closeWindow")
    self.popController:hide(false, function()
        RainbowPickMainUIPop.bCanClick = true
    end)
end

return PrizeBiggerSplashUI