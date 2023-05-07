MoneyFormatHelper = {}

-- 从高位往低位保留最多digitNum个非零数字
function MoneyFormatHelper.normalizeCoinCount(count, digitNum)
    digitNum = digitNum or 3
    local result = count
    local index = 0
    while(result >= 10^digitNum) do
        result = result / 10
        index = index + 1
    end
    result = math.floor(result)
    result = result * (10^index)
    return result
end

-- 去尾法 保留小数点后n位
function MoneyFormatHelper.keepNDecimalPlaces(decimal)
    local n = 0
    if decimal >= 100 then
        n = 0
    elseif decimal >= 10 then
        n = 1
    else
        n = 2
    end

    local nBase = 1
    local fCoef = 1.0

    for i = 1, n do
        nBase = nBase * 10
        fCoef = fCoef / 10.0
    end

    local decimal = math.floor(decimal * nBase) * fCoef
    return decimal
end

--==============================--
--@return string 
--e.g: 123000 -> 123K
-- Bug 出现的 1.1213123123K 这种，因此加个修改版
--==============================---
function MoneyFormatHelper.coinCountOmit(count)
    -- quadrillion -- 千万亿
    local trillion = 1000 * 1000 * 1000 * 1000 -- 万亿
    local billion = 1000 * 1000 * 1000
    local million = 1000 * 1000
    local thousand = 1000
    if count >= trillion then
        local count1 = MoneyFormatHelper.keepNDecimalPlaces(count / trillion)
        if count1 == math.floor(count1) then
            return string.format( "%dT", count1)
        else
            return count1.."T"
        end
    elseif count >= billion then
        local count1 = MoneyFormatHelper.keepNDecimalPlaces(count / billion)
        if count1 == math.floor(count1) then
            return string.format( "%dB", count1)
        else
            return count1.."B"
        end
    elseif count >= million then
        local count1 = MoneyFormatHelper.keepNDecimalPlaces(count / million)
        if count1 == math.floor(count1) then
            return string.format( "%dM", count1)
        else
            return count1.."M"
        end
    elseif count >= thousand then
        local count1 = MoneyFormatHelper.keepNDecimalPlaces(count / thousand)
        if count1 == math.floor(count1) then
            return string.format( "%dK", count1)
        else
            return count1.."K"
        end
    else 
        return string.format( "%d", count)
    end
    
end

--==============================--
--desc:Format number return string with commas
--e.g: 28999333 -> 28,999,333
--==============================----
function MoneyFormatHelper.numWithCommas(n)
  return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()
end
