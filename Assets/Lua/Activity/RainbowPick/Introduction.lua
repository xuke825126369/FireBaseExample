--介绍弹窗
local Introduction = {}

function Introduction:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("Introduction")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        if self.bCanHide then
            ActivityAudioHandler:PlaySound("rainbow_closeWindow")
            self:hide()
        end
    end)

    self.N_PAGE_COUNT = 2
    self.nPageIndex = 1
    self.tableGoPage = LuaHelper.GetTableFindChild(self.transform, self.N_PAGE_COUNT, "Page")

    local btnLeft = self.transform:FindDeepChild("btnLeft"):GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnLeft)
    btnLeft.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self.nPageIndex = LuaHelper.Loop(self.nPageIndex - 1, 1, self.N_PAGE_COUNT)
        self:setPage(self.nPageIndex)
    end)

    local btnRight = self.transform:FindDeepChild("btnRight"):GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnRight)
    btnRight.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self.nPageIndex = LuaHelper.Loop(self.nPageIndex + 1, 1, self.N_PAGE_COUNT)
        self:setPage(self.nPageIndex)
    end)
end

function Introduction:setPage(nPageIndex)
    for i = 1, self.N_PAGE_COUNT do
        self.tableGoPage[i]:SetActive(nPageIndex == i)
    end
end

function Introduction:Show()
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

function Introduction:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    ViewScaleAni:Hide(self.transform.gameObject)
    ActivityHelper:PlayAni(self.transform.gameObject, "Hide")
end

return Introduction
