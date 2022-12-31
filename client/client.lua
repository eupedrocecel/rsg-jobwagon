local RSGCore = exports['rsg-core']:GetCoreObject()
local WagonPlate = nil
local spawncoords = nil
local spawnheading = nil
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
                local model = GetHashKey(data.wagon)
                local playerjob = RSGCore.Functions.GetPlayerData().job.name
                local plate = data.plate
                -------------------------------------------------------------
                if playerjob == 'wholesaletrader' then
                    spawncoords = Config.WholesaleTraderSpawn
                end
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Wait(100)
                end
                Wait(1000)
                local vehicle = CreateVehicle(model, spawncoords, true, false)
                SetModelAsNoLongerNeeded(model)
                Citizen.InvokeNative(0x58A850EAEE20FAA3, vehicle, true) -- PlaceObjectOnGroundProperly
                while not DoesEntityExist(vehicle) do
                    Wait(10)
                end
                Wait(100)
                getControlOfEntity(vehicle)
                Citizen.InvokeNative(0x283978A15512B2FE, vehicle, true) -- SetRandomOutfitVariation
                Citizen.InvokeNative(0x23F74C2FDA6E7C61, 631964804, vehicle) -- BlipAddForEntity
                Citizen.InvokeNative(0x9CB1A1623062F402, vehicle, 'Supply Wagon') -- SetBlipName
                local playerHash = `PLAYER`
                Citizen.InvokeNative(0xADB3F206518799E8, vehicle, playerHash) -- SetPedRelationshipGroupDefaultHash
                Citizen.InvokeNative(0xCC97B29285B1DC3B, vehicle, 1) -- SetAnimalMood
                Citizen.InvokeNative(0x931B241409216C1F , PlayerPedId(), vehicle , 0) -- SetPedOwnsAnimal
                SetModelAsNoLongerNeeded(model)
                SetPedNameDebug(vehicle, plate)
                SetPedPromptName(vehicle, plate)
                SpawnedWagon = vehicle
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

-- getControlOfEntity()
function getControlOfEntity(entity)
    NetworkRequestControlOfEntity(entity)
    SetEntityAsMissionEntity(entity, true, true)
    local timeout = 2000
    while timeout > 0 and NetworkHasControlOfEntity(entity) == nil do
        Wait(100)
        timeout = timeout - 100
    end
    return NetworkHasControlOfEntity(entity)
end
