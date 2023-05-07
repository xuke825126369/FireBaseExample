ScreenHelper = {}

function ScreenHelper:isLandScape()
    return Unity.Screen.width >= Unity.Screen.height
end

function ScreenHelper:GetScreenWidthHeightRatio(bLandScape)
    local fActualReferenceWidth, fActualReferenceHeight = 0, 0
    if bLandScape then
        if Unity.Screen.width > Unity.Screen.height then
            fActualReferenceWidth = Unity.Screen.width
            fActualReferenceHeight = Unity.Screen.height
        else
            fActualReferenceWidth = Unity.Screen.height
            fActualReferenceHeight = Unity.Screen.width
        end
    else
        if Unity.Screen.width > Unity.Screen.height then
            fActualReferenceWidth = Unity.Screen.height
            fActualReferenceHeight = Unity.Screen.width
        else
            fActualReferenceWidth = Unity.Screen.width
            fActualReferenceHeight = Unity.Screen.height
        end
    end
    
    local ratio = fActualReferenceWidth / fActualReferenceHeight
    return ratio
end

-- 根据屏幕分辨率 进行插值
function ScreenHelper:GetResultByScreenRatio(f1x2Value, f3x4Value)
    if f1x2Value == f3x4Value or math.abs(f1x2Value - f3x4Value) < 0.001 then
        return (f1x2Value + f3x4Value) / 2
    end
    
    local ratio = self:GetScreenWidthHeightRatio(false)
    local fMaxRatio = 3 / 4
    local fMinRatio = 1125 / 2436
    local fResult = -1
    if ratio < fMaxRatio and ratio > fMinRatio then
        fResult = f1x2Value + (ratio - fMinRatio) / (fMaxRatio - fMinRatio) * (f3x4Value - f1x2Value)
    elseif ratio >= fMaxRatio then
        fResult = f3x4Value
    elseif ratio <= fMinRatio then
        fResult = f1x2Value
    end

    return fResult
end

