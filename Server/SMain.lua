RegisterCommand("dadosr", function(source, args)
    local _src <const> = source
    TriggerClientEvent("guille_dice:client:spawnPeds", _src)
end, false)

RegisterCommand("rfin", function(source, args)
    local _src <const> = source
    TriggerClientEvent("guille_dice:client:removePeds", _src)
end, false)

if Cfg['others']['enableControlCommand'] then
    RegisterCommand("control", function(source, args)
        local _src <const> = source
        TriggerClientEvent("guille_dice:client:requestPedControl", _src)
    end, false)
end