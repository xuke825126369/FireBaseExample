LoungeAudioHandler = CommonAudioHandler:New()

function LoungeAudioHandler:InitActivityAudio()
    local name = "Lounge"
    local bundleName = LoungeManager:GetBundleName()
    local assetPathDir = "Assets/ResourceABs/Activity/Lounge/"
    local tableLoadAudioInfo = {
        {bundleName = bundleName, assetPathDir = assetPathDir}
    }
    
    self:Init(name, tableLoadAudioInfo)
end

LoungeBundleHandler = DelayLoadBundleHandlerGenerator:New()
function LoungeBundleHandler:InitBundleInfo()
    local bundleName = LoungeManager:GetBundleName()
    self:Init(bundleName, LoungeAudioHandler)
end

