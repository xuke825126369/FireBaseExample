BuildGameRulesPop = {}

BuildGameRulesPop.m_gameObject = nil
BuildGameRulesPop.m_transform = nil
BuildGameRulesPop.m_btnLeft = nil
BuildGameRulesPop.m_btnRight = nil

local nCurIndex = 1

function BuildGameRulesPop:createAndShow()
    if not self.m_gameObject then
        local goPrefab = Util.getBuildGamePrefab("Assets/BuildYourCity/RulesPop.prefab")
        self.m_gameObject = Unity.Object.Instantiate(goPrefab)
        self.m_transform = self.m_gameObject.transform
        self.m_transform:SetParent(LobbyScene.popCanvas, false)
        self.m_trContent = self.m_transform:FindDeepChild("RuleContainer")
        self.popController = PopController:new(self.m_gameObject)

        self.m_transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button)).onClick:AddListener(function()
            AudioHandler:PlayBuildGameSound("click")
            self:hide()
        end)

        self.m_btnLeft = self.m_transform:FindDeepChild("BtnLeft"):GetComponent(typeof(UnityUI.Button))
        self.m_btnRight = self.m_transform:FindDeepChild("BtnRight"):GetComponent(typeof(UnityUI.Button))
        nCurIndex = 1
        self:refreshBtnStatus()

        self.m_btnLeft.onClick:AddListener(function()
            self:changeIndex(-1)
        end)

        self.m_btnRight.onClick:AddListener(function()
            self:changeIndex(1)
        end)
    end
    ViewScaleAni:Show(self.transform.gameObject)
end

function BuildGameRulesPop:hide()
    self.popController:hide(true)
end

function BuildGameRulesPop:changeIndex(count)
    AudioHandler:PlayBuildGameSound("click")
    self.m_trContent:GetChild(nCurIndex-1).gameObject:SetActive(false)
    nCurIndex = nCurIndex + count
    self.m_trContent:GetChild(nCurIndex-1).gameObject:SetActive(true)
    self:refreshBtnStatus()
end

function BuildGameRulesPop:refreshBtnStatus()
    if nCurIndex == 1 then
        self.m_btnLeft.gameObject:SetActive(false)
        self.m_btnRight.gameObject:SetActive(true)
    elseif nCurIndex == 4 then
        self.m_btnLeft.gameObject:SetActive(true)
        self.m_btnRight.gameObject:SetActive(false)
    else
        self.m_btnLeft.gameObject:SetActive(true)
        self.m_btnRight.gameObject:SetActive(true)
    end
end