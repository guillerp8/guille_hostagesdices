local _Wait, _CreateThread, _RequestModel, _GetHashKey, _HasModelLoaded, _CreatePed = Wait, CreateThread, RequestModel, GetHashKey, HasModelLoaded, CreatePed
local _RequestAnimDict, _HasAnimDictLoaded = RequestAnimDict, HasAnimDictLoaded
local _RegisterNetEvent, _inPedControl = RegisterNetEvent, false
local _spawnedPeds = {}
local _plyPedOnChange = nil
local _hasSpawnedPeds = false
local _enablePeds = false

_RegisterNetEvent("guille_dice:client:spawnPeds", function()
    Dice['functions']['log']("Spawning peds")
    if _hasSpawnedPeds then return end
    if Cfg['others']['usingEvents'] then 
        if not _enablePeds then
            return
        end
    end
    _hasSpawnedPeds = true
    local _num <const> = math.random(Cfg['randoms']['min'], Cfg['randoms']['max'])
    local _ped <const> = PlayerPedId()
    local _pCoords <const> = GetEntityCoords(_ped)
    local _pHeading <const> = GetEntityHeading(_ped)
    for i = 1, _num, 1 do
        _pedHash = _GetHashKey(Cfg['models'][math.random(1, #Cfg['models'])])
        _RequestModel(_pedHash)
        while not _HasModelLoaded(_pedHash) do
            _Wait(1)
        end
        _pedSpawned = _CreatePed(4, _pedHash, _pCoords['x'] + math.random(-2, 2), _pCoords['y'] + math.random(-2, 2), _pCoords['z'], _pHeading, true, false)
        SetModelAsNoLongerNeeded(_pedHash)
        _RequestAnimDict("random@arrests@busted")
        while not _HasAnimDictLoaded("random@arrests@busted") do
            _Wait(1)
        end
        TaskPlayAnim(_pedSpawned, "random@arrests@busted", "idle_a", 1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
        SetBlockingOfNonTemporaryEvents(_pedSpawned, true)
        _Wait(650)
        FreezeEntityPosition(_pedSpawned, true)
        table.insert(_spawnedPeds, _pedSpawned)
    end 
end)

if Cfg['others']['usingEvents'] then 
    _RegisterNetEvent("guille_dice:client:enableSpawn", function()
        _enablePeds = true
    end)

    _RegisterNetEvent("guille_dice:client:disableSpawn", function()
        _enablePeds = false
    end)
end

_RegisterNetEvent("guille_dice:client:requestPedControl", function()
    _inPedControl = true
    _CreateThread(function()
        while _inPedControl do
            _Wait(0)
            Dice['functions']['helpNotification']("Press ~INPUT_CONTEXT~ aiming a hostage to control it")
            local _, _ped = GetEntityPlayerIsFreeAimingAt(PlayerId()) 
            for k, v in pairs(_spawnedPeds) do 
                if _ped == v then
                    local _pedCoords = GetEntityCoords(v)
                    DrawMarker(1, _pedCoords['x'], _pedCoords['y'], _pedCoords['z'] - 1.02, 0.1, 1, 0, 0.0, 0.00, 0, 0.5, 0.5, 0.2, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0)
                    if IsControlJustPressed(1, 38) then
                        DoScreenFadeOut(100)
                        _plyPedOnChange = PlayerPedId()
                        _Wait(500)
                        SetEntityInvincible(_plyPedOnChange, true)
                        FreezeEntityPosition(v, false)
                        FreezeEntityPosition(_plyPedOnChange, true)
                        ChangePlayerPed(PlayerId(), v, true, true)
                        DoScreenFadeIn(100)
                        enableControlTask()
                        break
                    end
                end
            end
        end
    end)
end)

enableControlTask = function()
    while _inPedControl do
        SetBlockingOfNonTemporaryEvents(_plyPedOnChange, true)
        TaskStandStill(_plyPedOnChange, 1000)
        _Wait(0)
        Dice['functions']['helpNotification']("Press ~INPUT_CONTEXT~ to go back to your ped and delete this one")
        if IsControlJustPressed(1, 38) then
            DoScreenFadeOut(100)
            local _actualPed = PlayerPedId()
            _Wait(100)
            for _, v in pairs(_spawnedPeds) do
                if v == _actualPed then
                    table.remove(_spawnedPeds, _)
                end
            end
            if #_spawnedPeds == 0 then
                _hasSpawnedPeds = false
            end
            ChangePlayerPed(PlayerId(), _plyPedOnChange, true, true)
            SetEntityInvincible(_plyPedOnChange, false)
            FreezeEntityPosition(_plyPedOnChange, false)
            DeleteEntity(_actualPed)
            _inPedControl = false
            DoScreenFadeIn(100)
            break
        end
    end
end

_RegisterNetEvent("guille_dice:client:removePeds", function()
    for _, v in pairs(_spawnedPeds) do 
        DeleteEntity(v)
    end
    _hasSpawnedPeds = false
    _spawnedPeds = {}
end)

_RegisterNetEvent("onResourceStop", function(res)
    if res == GetCurrentResourceName() then
        for _, v in pairs(_spawnedPeds) do 
            DeleteEntity(v)
        end
    end
end)

GiveWeaponToPed(PlayerPedId(), GetHashKey("weapon_combatpistol"), 200, false, true)