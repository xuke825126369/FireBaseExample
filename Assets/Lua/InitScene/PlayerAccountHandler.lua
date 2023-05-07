PlayerAccountHandler = {}

function PlayerAccountHandler:orShowFBWindow()
    if Unity.PlayerPrefs.HasKey("web_db") then
        return false
    else
        return true
    end
end







