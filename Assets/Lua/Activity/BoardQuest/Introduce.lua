--介绍弹窗
local Introduce = {}

function Introduce:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("Introduce")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    local btn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btn)
    btn.onClick:AddListener(function()
        if self.bCanHide then
            ActivityAudioHandler:PlaySound("board_closeWindow")
            self:hide()
        end
    end)
end

function Introduce:Show()
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
    GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
end

function Introduce:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    ViewScaleAni:Hide(self.transform.gameObject)
end

return Introduce
