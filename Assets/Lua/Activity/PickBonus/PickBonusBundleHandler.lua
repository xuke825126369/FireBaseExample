PickBonusAudioHandler = CommonAudioHandler:New()

function PickBonusAudioHandler:InitActivityAudio()
    local name = "~PickBonusAudioHandler"
    local bundleName = PickBonusManager:GetBundleName()
    local assetPathDir = "Assets/ResourceABs/Active/PickBonus/"
    local tableLoadAudioInfo = {
        {bundleName = bundleName, assetPathDir = assetPathDir}
    }     
    self:Init(name, tableLoadAudioInfo)
end

PickBonusBundleHandler = DelayLoadBundleHandlerGenerator:New()
function PickBonusBundleHandler:InitBundleInfo()
    local bundleName = PickBonusManager:GetBundleName()
    self:Init(bundleName, PickBonusAudioHandler)
end
