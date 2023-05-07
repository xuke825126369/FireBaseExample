--介绍弹窗
local FirstIntroduction = {}

function FirstIntroduction:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("FirstIntroduction")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)

    self.N_PAGE_COUNT = 3
    self.nPageIndex = 1
    self.tableGoPage = LuaHelper.GetTableFindChild(self.transform, self.N_PAGE_COUNT, "P")
    self.tableGoPage[1]:SetActive(true)
    for i = 2, self.N_PAGE_COUNT do
        self.tableGoPage[i]:SetActive(false)
    end

    local goFrame = self.transform:FindDeepChild("Frame").gameObject
    self.btn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btn)
    self.btn.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self.tableGoPage[self.nPageIndex]:SetActive(false)
        self.nPageIndex = self.nPageIndex + 1
        if self.nPageIndex <= self.N_PAGE_COUNT then
            self.tableGoPage[self.nPageIndex]:SetActive(true)
            ActivityHelper:PlayAni(self.transform.gameObject, "Pop")
        else
            self:hide()
        end
    end)
end

function FirstIntroduction:Show()
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
    RainbowPickDataHandler.data.bFirstIntroduction = false
    RainbowPickDataHandler:writeFile()
    self.transform.gameObject:SetActive(true)
    GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    self.btn.interactable = true
end

function FirstIntroduction:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    ActivityHelper:PlayAni(self.transform.gameObject, "Hide")
    LeanTween.delayedCall(1, function()
        self.transform.gameObject:SetActive(false)
    end)
    self.btn.interactable = false
end

return FirstIntroduction
