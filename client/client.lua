local RSGCore = exports['rsg-core']:GetCoreObject()
local WagonPlate = nil
local spawncoords = nil
local spawnheading = nil
local cargohash = nil
local lightupgardehash = nil
local SpawnedWagon = nil
local wagonSpawned = false

-- job wagon menu
RegisterNetEvent('rsg-jobwagon:client:openWagonMenu', function()
    exports['rsg-menu']:openMenu({
        {
            header = 'Wagon Menu',
            isMenuHeader = true,
        },
        {
            header = "Setup Wagon (Boss)",
            txt = "",
            icon = "fas fa-box",
            params = {
                event = 'rsg-jobwagon:server:SetupWagon',
                isServer = true,
                args = {},
            }
        },
        {
            header = "Get Wagon",
            txt = "",
            icon = "fas fa-box",
            params = {
                event = 'rsg-jobwagon:client:SpawnWagon',
                isServer = false,
                args = {},
            }
        },
        {
            header = "Store Wagon",
            txt = "",
            icon = "fas fa-box",
            params = {
                event = 'rsg-jobwagon:client:storewagon',
                isServer = false,
                args = {},
            }
        },
        {
            header = ">> Close Menu <<",
            txt = '',
            params = {
                event = 'rsg-menu:closeMenu',
            }
        },
    })
end)

-- spawn company wagon
RegisterNetEvent('rsg-jobwagon:client:SpawnWagon', function()
    RSGCore.Functions.TriggerCallback('rsg-jobwagon:server:GetActiveWagon', function(data)
        if data ~= nil then
            if wagonSpawned == false then
                local ped = PlayerPedId()
                local modelhash = GetHashKey(data.wagon)
                local playerjob = RSGCore.Functions.GetPlayerData().job.name
                local plate = data.plate
                -------------------------------------------------------------
                if playerjob == 'wholesaletrader' then
                    spawncoords = Config.WholesaleTraderSpawn
                    cargohash = GetHashKey('pg_teamster_wagon04x_gen')
                    lightupgardehash = GetHashKey('pg_teamster_wagon04x_lightupgrade3')
                end
                -------------------------------------------------------------
                RequestModel(modelhash)
                while not HasModelLoaded(modelhash) do
                    Citizen.Wait(0)
                end
                local wagon = CreateVehicle(modelhash, spawncoords, true, false)
                SetVehicleOnGroundProperly(wagon)
                Wait(200)
                SetPedIntoVehicle(ped, wagon, -1)
                SetModelAsNoLongerNeeded(modelhash)
                Citizen.InvokeNative(0xD80FAF919A2E56EA, wagon, cargohash)
                Citizen.InvokeNative(0xC0F0417A90402742, wagon, lightupgardehash) 
                SpawnedWagon = wagon
                wagonSpawned = true
                RSGCore.Functions.Notify('company wagon taken out', 'primary')
            else
                RSGCore.Functions.Notify('your company wagon is already out', 'primary')
            end
        else
            RSGCore.Functions.Notify('no wagon setup', 'error')
        end
    end)
end)

-- open wagon menu
CreateThread(function()
    while true do
        Wait(1)
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, RSGCore.Shared.Keybinds['B']) then -- IsDisabledControlJustPressed
            local playercoords = GetEntityCoords(PlayerPedId())
            local wagoncoords = GetEntityCoords(SpawnedWagon)
            if #(playercoords - wagoncoords) <= 1.7 then
                RSGCore.Functions.TriggerCallback('rsg-jobwagon:server:GetActiveWagon', function(data)
                    local wagonstash = data.plate
                    TriggerServerEvent("inventory:server:OpenInventory", "stash", wagonstash, { maxweight = Config.MaxWeight, slots = Config.MaxSlots, })
                    TriggerEvent("inventory:client:SetCurrentStash", wagonstash)
                end)
            end
        end
    end
end)

-- store wagon
RegisterNetEvent('rsg-jobwagon:client:storewagon', function()
    if wagonSpawned == true then
        DeletePed(SpawnedWagon)
        SetEntityAsNoLongerNeeded(SpawnedWagon)
        RSGCore.Functions.Notify('company wagon stored', 'success')
        wagonSpawned = false
    end
end)
