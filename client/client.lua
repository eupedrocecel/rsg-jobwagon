local RSGCore = exports['rsg-core']:GetCoreObject()
local WagonPlate = nil
local spawncoords = nil
local spawnheading = nil
local wagonSpawned = false
local SpawnedWagon = nil

-- wholesale trader menu
RegisterNetEvent('rsg-jobwagon:client:openWagonMenu', function()
    exports['rsg-menu']:openMenu({
        {
            header = 'Wagon Menu',
            isMenuHeader = true,
        },
        {
            header = "Setup Wagon",
            txt = "",
            icon = "fas fa-box",
            params = {
                event = 'rsg-jobwagon:server:SetupWagon',
                isServer = true,
                args = {},
            }
        },
        {
            header = "Company Wagon",
            txt = "",
            icon = "fas fa-box",
            params = {
                event = 'rsg-jobwagon:client:openCompanyWagons',
                isServer = false,
                args = {},
            }
        },
        {
            header = "Take out Wagon",
            txt = "",
            icon = "fas fa-box",
            params = {
                event = 'rsg-jobwagon:client:SpawnWagon',
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

-- get company wagons
RegisterNetEvent('rsg-jobwagon:client:openCompanyWagons', function()
    local GetWagons = {
        {
            header = "| Company Wagons |",
            isMenuHeader = true,
            icon = "fa-solid fa-circle-user",
        },
    }
    RSGCore.Functions.TriggerCallback('rsg-jobwagon:server:GetWagons', function(cb)
        for _, v in pairs(cb) do
            GetWagons[#GetWagons + 1] = {
                header = v.plate,
                txt = "take out this wagon",
                icon = "fa-solid fa-circle-user",
                params = {
                    event = "rsg-jobwagon:client:SetActiveWagon",
                    args = {
                        plate = v.plate,
                        active = 1
                    }
                }
            }
        end
        exports['rsg-menu']:openMenu(GetWagons)
    end)
end)

-- set active company wagon
RegisterNetEvent('rsg-jobwagon:client:SetActiveWagon', function(data)
    WagonPlate = data.plate
    TriggerServerEvent('rsg-jobwagon:server:SetActiveWagon', WagonPlate)
end)

RegisterNetEvent('rsg-jobwagon:client:SpawnWagon', function()
    RSGCore.Functions.TriggerCallback('rsg-jobwagon:server:GetActiveWagon', function(data)
        if (data) then
            local ped = PlayerPedId()
            local model = GetHashKey(data.wagon)
            local playerjob = RSGCore.Functions.GetPlayerData().job.name
            local plate = data.plate
            -------------------------------------------------------------
            if playerjob == 'wholesaletrader' then
                spawncoords = vector4(2333.1894, -1479.587, 45.956836, 148.38502)
            else
                RSGCore.Functions.Notify('job does not exist!', 'error')
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
        end
    end)
end)

-- open wagon menu
CreateThread(function()
    while true do
        Wait(1)
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, RSGCore.Shared.Keybinds['B']) then
            local playercoords = GetEntityCoords(PlayerPedId())
            local wagoncoords = GetEntityCoords(SpawnedWagon)
            if #(playercoords - wagoncoords) <= 1.7 then
                RSGCore.Functions.TriggerCallback('rsg-jobwagon:server:GetActiveWagon', function(data)
                    local wagonstash = data.plate
                    print(wagonstash)
                    TriggerServerEvent("inventory:server:OpenInventory", "stash", wagonstash, { maxweight = Config.MaxWeight, slots = Config.MaxSlots, })
                    TriggerEvent("inventory:client:SetCurrentStash", wagonstash)
                end)
            end
        end
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
