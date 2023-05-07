--过了一关，给的奖励弹窗
local RewardCardPackOnBoard = {}

function RewardCardPackOnBoard:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("RewardCardPackOnBoard")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

   
    local btn = self.transform:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btn)
    btn.onClick:AddListener(function()
        if self.bCanHide then
            self:hide()
        end
    end)
    self.cardPackUI = CardPackUI:new(self.transform:FindDeepChild("CardPack").gameObject)
end

function RewardCardPackOnBoard:Show()
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
    self.popController:show(nil , function()
        ActivityAudioHandler:PlaySound("board_reward_pop")
        GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    end, true)
end

function RewardCardPackOnBoard:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    ActivityAudioHandler:PlaySound("board_closeWindow")
    ViewScaleAni:Hide(self.transform.gameObject)
    BoardQuestMainUIPop:setInAnimation(false)
end

return RewardCardPackOnBoard
