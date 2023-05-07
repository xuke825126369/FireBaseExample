NewUserHandler = {}

---------------------------------------------------------------------------------------------
function NewUserHandler:orIsNewUser()
    return PlayerHandler.nLoginDayCount >= 1 and PlayerHandler.nLoginDayCount <= 7
end