local InitSceneView = {}

function InitSceneView:Init()
    local bundleName = "InitScene"
    local assetPath = "Assets/ResourceABs/InitScene/View/InitScenePanel.prefab"

    local goPrefab = AssetBundleManager.Instance:LoadAsset(bundleName, assetPath)
    local go = Unity.Object.Instantiate(goPrefab)

    local goParent = InitScene.transform
    self.transform = go.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.m_progressBar = self.transform:FindDeepChild("ProgressBar"):GetComponent(typeof(Unity.RectTransform))
    self.m_progressText = self.transform:FindDeepChild("ProgressText"):GetComponent(typeof(TextMeshProUGUI))
end

function InitSceneView:Show(finishFunc)
    self.transform.gameObject:SetActive(true)

    self.fCurrentBeginProgress = 0.0
    self.fCurrentEndProgress = 0.0
    self.fNowMaxProgress = 0.0
    self.bAni = false
    self.fCdTime = 0.0
    self.fAniMaxTime = 0.0

    self.mTip = ""
    self.fJinDu = 0
    self:SetJinDuInfo(0)
    self.finishFunc = finishFunc
end

function InitSceneView:SetTip(mTip)
    self.mTip = mTip
    self:UpdateTip()
end

function InitSceneView:SetJinDuInfo(fJinDu)
    self.fJinDu = fJinDu
    self:UpdateTip()
end

function InitSceneView:UpdateTip()
    local fPosX = Unity.Screen.width * self.fJinDu
    local oriSizeDelta = self.m_progressBar.sizeDelta
    self.m_progressBar.sizeDelta = Unity.Vector2(fPosX, oriSizeDelta.y)
    
    if not LuaHelper.IsNullOrWhiteSpace(self.mTip) then
        self.m_progressText.text = self.mTip.."   "..string.format("%d%%", self.fJinDu * 10000 // 100)
    else
        self.m_progressText.text = string.format("%d%%", self.fJinDu * 10000 // 100)
    end

end

function InitSceneView:SetUIProgress(fRealProgress)
    self.fNowMaxProgress = fRealProgress
end

function InitSceneView:Update()
    local dt =  Unity.Time.deltaTime
    if not self.bAni then
        if self.fCurrentEndProgress < self.fNowMaxProgress then
            self.fCurrentBeginProgress = self.fCurrentEndProgress
            self.fCurrentEndProgress = self.fNowMaxProgress
            self.bAni = true
            self.fCdTime = 0.0
            self.fAniMaxTime = (self.fCurrentEndProgress - self.fCurrentBeginProgress) * 1.0
            self.fAniMaxTime = math.max(0.5, self.fAniMaxTime)
            self.fAniMaxTime = math.min(1.0, self.fAniMaxTime)
        else
            if self.fCurrentEndProgress >= 1.0 then
                if self.finishFunc then
                    self.finishFunc()
                end
            end
        end
    end 
        
    if self.bAni then
        self.fCdTime = self.fCdTime + dt
        local fPerent = self.fCdTime / self.fAniMaxTime
        fPerent = math.max(0, fPerent)
        fPerent = math.min(1.0, fPerent)

        local fJinDu = self.fCurrentBeginProgress * (1 - fPerent) + self.fCurrentEndProgress * fPerent
        self:SetJinDuInfo(fJinDu)
        if fPerent >= 1.0 then
            self.bAni = false
            self.fCdTime = 0.0
        end
    end

end


return InitSceneView

