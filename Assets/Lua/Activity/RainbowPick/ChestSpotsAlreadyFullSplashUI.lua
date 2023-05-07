--已经没有空位了，然后又点出来一个箱子的弹窗
local ChestSpotsAlreadyFullSplashUI = {}

function ChestSpotsAlreadyFullSplashUI:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("ChestSpotsAlreadyFullSplashUI")
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

function ChestSpotsAlreadyFullSplashUI:show(goChest)
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
    self.goChest = goChest
end

function ChestSpotsAlreadyFullSplashUI:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    ActivityAudioHandler:PlaySound("rainbow_closeWindow")
    self.popController:hide(false, function()
        RainbowPickMainUIPop.bCanClick = true
        local v3 = self.goChest.transform.position + Unity.Vector3(2000,1000,0)
        local id = LeanTween.move(self.goChest, v3, 1).id
        table.insert(ActivityHelper.m_LeanTweenIDs, id)
    end)
end

return ChestSpotsAlreadyFullSplashUI