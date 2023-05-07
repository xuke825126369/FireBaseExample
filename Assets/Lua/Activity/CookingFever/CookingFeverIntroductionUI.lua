CookingFeverIntroductionUI = {}

function CookingFeverIntroductionUI:Show()
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

    ViewScaleAni:Show(self.transform.gameObject)
    self.bCanHide = true
end

function CookingFeverIntroductionUI:Init()
    local prefab = AssetBundleHandler:LoadActivityAsset("Introduction")
    self.transform.gameObject = Unity.Object.Instantiate(prefab)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.anchoredPosition3D = Unity.Vector3.zero
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        if self.bCanHide then
            ActivityAudioHandler:PlaySound("cook_button")
            self:hide()
        end
    end)
end

function CookingFeverIntroductionUI:hide()
    self.bCanHide = false
    ViewScaleAni:Hide(self.transform.gameObject)
    --ActivityHelper:SetTrigger(self.transform.gameObject, "Hide")
end