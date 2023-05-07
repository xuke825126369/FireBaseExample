KickByServerNoticePop = {}

function KickByServerNoticePop:createAndShow()
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:init()
    end
    ViewScaleAni:Show(self.transform.gameObject)
end

function KickByServerNoticePop:init()
    local bLandscape = (not GameLevelUtil:isPortraitLevel())
    if(bLandscape ~= self.bLandscape) then
        if self.gameObject then
            Unity.GameObject.Destroy(self.gameObject)
        end
        if bLandscape then
            self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/Prefabs/prefab/KickByServerNotice.prefab"))
        else
            self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/Prefabs/prefab/KickByServerNotice_Portrait.prefab"))
        end
        self.transform = self.gameObject.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.popController = PopController:new(self.gameObject)
        local btnRetry = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnRetry)
        btnRetry.onClick:AddListener(function()
            self.gameObject:SetActive(false)
            Unity.SceneManagement.SceneManager.LoadScene(0)
        end)
    end
end