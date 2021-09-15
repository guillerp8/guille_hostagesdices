Dice = {}

Dice['functions'] = {
    ['helpNotification'] = function(msg)
        AddTextEntry('HelpNotification', msg)
        BeginTextCommandDisplayHelp('HelpNotification')
        EndTextCommandDisplayHelp(0, false, beep, duration or -1)
    end,
    ['log'] = function(msg)
        if msg then
            print("^2["..GetCurrentResourceName().."] [INFO] ^7" ..msg)
        end
    end,
}