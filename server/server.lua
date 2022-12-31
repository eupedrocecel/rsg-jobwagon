local RSGCore = exports['rsg-core']:GetCoreObject()
local wagontype = nil

-- setup wagon
RegisterServerEvent('rsg-jobwagon:server:SetupWagon', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local isBoss = Player.PlayerData.job.isboss
    local job = Player.PlayerData.job.name
    if job == 'wholesaletrader' then
        wagontype = Config.WholesaleTrader
    end
    if isBoss == true then
        local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM job_wagons WHERE job = ?", { job })
        if result == 0 then
            local plate = GeneratePlate()
            MySQL.insert('INSERT INTO job_wagons(job, plate, wagon, active) VALUES(@job, @plate, @wagon, @active)', {
                ['@job'] = job,
                ['@plate'] = plate,
                ['@wagon'] = wagontype,
                ['@active'] = 1,
            })
            TriggerClientEvent('RSGCore:Notify', src, 'successfully setup your company wagon', 'success')
        else
            TriggerClientEvent('RSGCore:Notify', src, 'you already have a company wagon', 'error')
        end
    else
        TriggerClientEvent('RSGCore:Notify', src, 'you are not the boss', 'error')
    end
end)

-- get active wagon
RSGCore.Functions.CreateCallback('rsg-jobwagon:server:GetActiveWagon', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local job = Player.PlayerData.job.name
    local result = MySQL.query.await('SELECT * FROM job_wagons WHERE job=@job AND active=@active', {
        ['@job'] = job,
        ['@active'] = 1
    })
    if (result[1] ~= nil) then
        cb(result[1])
    else
        cb(nil)
    end
end)

-- generate wagon plate
function GeneratePlate()
    local UniqueFound = false
    local plate = nil
    while not UniqueFound do
        plate = tostring(RSGCore.Shared.RandomStr(3) .. RSGCore.Shared.RandomInt(3)):upper()
        local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM job_wagons WHERE plate = ?", { plate })
        if result == 0 then
            UniqueFound = true
        end
    end
    return plate
end
