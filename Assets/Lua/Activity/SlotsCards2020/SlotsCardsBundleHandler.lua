SlotsCardsAudioHandler = CommonAudioHandler:New()

function SlotsCardsAudioHandler:InitActivityAudio()
    local name = "~SlotsCardsAudioHandler"
    local bundleName = SlotsCardsManager:GetBundleName()
    local assetPathDir = "Assets/ResourceABs/Activity/"..SlotsCardsManager.path.."/"
    local tableLoadAudioInfo = {
        {bundleName = bundleName, assetPathDir = assetPathDir}
    }
    
    self:Init(name, tableLoadAudioInfo)
end

SlotsCardsBundleHandler = DelayLoadBundleHandlerGenerator:New()
function SlotsCardsBundleHandler:InitBundleInfo()
    local bundleName = SlotsCardsManager:GetBundleName()
    self:Init(bundleName, SlotsCardsAudioHandler)
end
