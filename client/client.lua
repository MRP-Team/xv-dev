local QBCore = nil
local ESX = nil

CreateThread(function()
    --get resource state of qb-core
    if GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    end
    --get resource state of esx
    if GetResourceState('es_extended') == 'started' then
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
end)


RegisterCommand('dev', function()
    SendNUIMessage({
        action = "DevMenu",
        data = {
            show = true,
        }
    })
    SetNuiFocus(true, true)
end, true)


RegisterNUICallback('hideUI', function(data, cb)
    SendNUIMessage({
        action = "DevMenu",
        data = {
            show = false,
        }
    })
    SetNuiFocus(false, false)
end)

RegisterNetEvent('xv-dev:client:UpdateOutput', function(output)
    -- print(output)
    SendNUIMessage({
        action = "updateOutput",
        data = {
            output = output,
        }
    })
end)

RegisterNUICallback('ExecuteLua', function(data, cb)
    local code = data.code
    local eventType = data.eventType
    if eventType == 'client' then
        local func, err = load(code)
        if func then
            local status, result = pcall(func)
            if status then
                output = "Executed"
            else
                output = "Error: " .. result
            end
        else
            output = "Error: " .. err
        end
        TriggerEvent('xv-dev:client:UpdateOutput', output)
    elseif eventType == 'server' then
        TriggerServerEvent('xv-dev:server:ExecLua', code)
    end
    cb(1)
end)
