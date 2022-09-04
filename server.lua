ESX = nil

TriggerEvent(
    "esx:getSharedObject",
    function(obj)
        ESX = obj
    end
)

Citizen.CreateThread(
    function()
        while true do
            local xPlayers = ESX.GetPlayers()
            for i = 1, #xPlayers, 1 do
                local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

                local myID = {
                    steamid = xPlayer.identifier,
                    playerid = xPlayer.source
                }
                local params = { ["@steam"] = myID.steamid }
                local sql = "SELECT * FROM users WHERE identifier = @steam"
                MySQL.Async.fetchAll(
                    sql,
                    params,
                    function(result)
                        if result[1].firstname == "" or result[1].firstname == nil then
                            TriggerClientEvent("tomato_identity:open_menu", myID.playerid)
                        end
                    end
                )
            end

            Citizen.Wait(5000)
        end
    end
)

RegisterServerEvent("tomato_identity:mysql_save")
AddEventHandler(
    "tomato_identity:mysql_save",
    function(id, data)
        local xPlayer = ESX.GetPlayerFromId(id)

        local myID = {
            steamid = xPlayer.identifier,
            playerid = xPlayer.source
        }

        local sql =
        "UPDATE users SET firstname = @fname, lastname = @lname, dateofbirth = @bday, sex = @sex, height = @hi WHERE identifier = @steam ;"

        local params = {
            ["fname"] = data.fn,
            ["lname"] = data.ln,
            ["bday"] = data.bd,
            ["sex"] = data.s,
            ["hi"] = data.h,
            ["steam"] = myID.steamid
        }

        MySQL.Async.execute(
            sql,
            params,
            function(affectedRows)
                if affectedRows >= 1 then
                    TriggerClientEvent("tomato_identity:close_menu", myID.playerid)
                end
            end
        )
    end
)
