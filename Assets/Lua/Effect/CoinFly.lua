CoinFly = {}

function CoinFly:fly(worldStart, worldEnd, count)
	GlobalAudioHandler:PlaySound("coinsFlyBegin")
	CS.CoinFly.instance:Fly(worldStart, worldEnd, count, function()
		EventHandler:Brocast("UpdateMyInfo")
		GlobalAudioHandler:PlaySound("coinsCollection")
	end)
end

function CoinFly:clear()
	CS.CoinFly.instance:Clear()
end
