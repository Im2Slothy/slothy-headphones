------------------------------------------------------------
-- GTA Radio Headphones - A Simple FiveM Script, Made By Slothy#0 --
------------------------------------------------------------
----------------------------------------------------------------------------------------------
                  -- !WARNING! !WARNING! !WARNING! !WARNING! !WARNING! --
        -- DO NOT TOUCH THIS FILE OR YOU /WILL/ MESS SOMETHING UP! EDIT THE CONFIG.LUA --
----------------------------------------------------------------------------------------------

local QBCore = exports['qb-core']:GetCoreObject()

currentStationName = ""
local isHeadphonesOn = false -- Track if headphones are active

-- Event for using the headphone item
RegisterNetEvent('qb-core:useHeadphone', function()
    TriggerEvent('qb-headphones:openMenu')
end)

-- Headphone Menu
RegisterNetEvent('qb-headphones:openMenu', function()
    local elements = {
        {
            header = "🎧 Headphone Menu",
            isMenuHeader = true
        },
        {
            header = "Turn On",
            txt = "Put on the headphones and listen to the radio",
            params = {
                event = "qb-headphones:turnOn"
            }
        },
        {
            header = "Turn Off",
            txt = "Take off the headphones",
            params = {
                event = "qb-headphones:turnOff"
            }
        },
        {
            header = "Change Radio Station",
            txt = "Select a radio station to listen to",
            params = {
                event = "qb-headphones:changeStation"
            }
        },
        {
            header = "Current Station: " .. currentStationName,
            txt = "Playing Music!" 
        },
    }
    
    exports['qb-menu']:openMenu(elements)
end)

-- Turn On Headphones
RegisterNetEvent('qb-headphones:turnOn', function()
    local playerPed = PlayerPedId()

    SetPedPropIndex(playerPed, 0, 15, 1, true) -- Headphones
    SetMobileRadioEnabledDuringGameplay(true)

    local defaultStation = Config.RadioStations[1].stationName
    SetRadioToStationName(defaultStation)
    currentStationName = Config.RadioStations[1].name
    isHeadphonesOn = true -- Set headphones as active
    TriggerEvent('QBCore:Notify', "Headphones on, radio playing: " .. Config.RadioStations[1].name)
end)

-- Turn Off Headphones
RegisterNetEvent('qb-headphones:turnOff', function()
    local playerPed = PlayerPedId()

    ClearPedProp(playerPed, 0) -- Remove headphones prop
    SetMobileRadioEnabledDuringGameplay(false)
    currentStationName = "None"
    isHeadphonesOn = false -- Set headphones as inactive
    TriggerEvent('QBCore:Notify', "Headphones off.")
end)

-- Change Radio Station
RegisterNetEvent('qb-headphones:changeStation', function()
    local elements = {}

    for _, station in ipairs(Config.RadioStations) do
        table.insert(elements, {
            header = station.name,
            txt = "Listen to " .. station.name,
            params = {
                event = "qb-headphones:setStation",
                args = station.stationName
            }
        })
    end

    exports['qb-menu']:openMenu(elements)
end)

-- Update current station when changing the station
RegisterNetEvent('qb-headphones:setStation', function(stationName)
    SetRadioToStationName(stationName)

    for _, station in ipairs(Config.RadioStations) do
        if station.stationName == stationName then
            currentStationName = station.name
            break
        end
    end

    TriggerEvent('QBCore:Notify', "Radio station changed to: " .. currentStationName)
    TriggerEvent('qb-headphones:openMenu')
end)

-- Inventory Check Thread
Citizen.CreateThread(function()
    while true do
        Wait(1000) -- Check every second
        if isHeadphonesOn then
            QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasItem)
                if not hasItem then
                    TriggerEvent('qb-headphones:turnOff') -- Turn off if headphones are not in inventory
                end
            end, "headphones")
        end
    end
end)
