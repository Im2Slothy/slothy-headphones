------------------------------------------------------------
-- Slothy-Headphones - A Simple FiveM Script, Made By Im2Slothy#0 --
------------------------------------------------------------
----------------------------------------------------------------------------------------------
                  -- !WARNING! !WARNING! !WARNING! !WARNING! !WARNING! --
        -- DO NOT TOUCH THIS FILE OR YOU /WILL/ MESS SOMETHING UP! EDIT THE CONFIG.LUA --
----------------------------------------------------------------------------------------------

local QBCore = exports['qb-core']:GetCoreObject()

currentStationName = ""
local isHeadphonesOn = false
local isYouTubeMode = false
local youTubeVideoName = ""

RegisterNetEvent('slothy-headphones:useHeadphone', function()
    TriggerEvent('slothy-headphones:openMenu')
end)

RegisterNetEvent('slothy-headphones:openMenu', function()
    --print("[DEBUG CLIENT] Opening headphone menu")
    --print("[DEBUG CLIENT] Config.EnableYouTubeLink: " .. tostring(Config.EnableYouTubeLink))
    
    local elements = {
        { header = "🎧 Headphone Menu", isMenuHeader = true },
        { header = "Turn On", txt = "Put on the headphones and listen to the radio", params = { event = "slothy-headphones:turnOn" } },
        { header = "Turn Off", txt = "Take off the headphones", params = { event = "slothy-headphones:turnOff" } },
        { header = "Change Radio Station", txt = "Select a radio station to listen to", params = { event = "slothy-headphones:changeStation" } }
    }

    if Config.EnableYouTubeLink then
        --print("[DEBUG CLIENT] Adding YouTube Link option to menu")
        table.insert(elements, { 
            header = "YouTube Link", 
            txt = "Play a YouTube video", 
            params = { event = "slothy-headphones:openYouTubeInput" } 
        })
    end

    table.insert(elements, { 
        header = "Current Station: " .. (isYouTubeMode and youTubeVideoName or currentStationName or "None"), 
        txt = "Playing Music!" 
    })
    
    --print("[DEBUG CLIENT] Menu elements: " .. json.encode(elements))
    exports['qb-menu']:openMenu(elements)
end)

RegisterNetEvent('slothy-headphones:openYouTubeInput', function()
    local input = exports['qb-input']:ShowInput({
        header = "YouTube Link",
        submitText = "Play",
        inputs = { { text = "YouTube URL", name = "youtube_link", type = "text", isRequired = true } }
    })

    if input ~= nil then
        local youtubeLink = input["youtube_link"]
        --print("[DEBUG CLIENT] YouTube link input: " .. tostring(youtubeLink))
        TriggerServerEvent('slothy-headphones:processYouTubeLink', youtubeLink)
    else
        --print("[DEBUG CLIENT] No input received from qb-input")
    end
end)

RegisterNetEvent('slothy-headphones:playYouTubeLink', function(videoName, streamUrl)
    --print("[DEBUG CLIENT] Received playYouTubeLink event with videoName: " .. tostring(videoName) .. ", streamUrl: " .. tostring(streamUrl))
    isYouTubeMode = true
    isHeadphonesOn = true
    youTubeVideoName = videoName or "YouTube Video"
    
    SetMobileRadioEnabledDuringGameplay(false)
    
    local xsound = exports['xsound']
    if xsound and xsound.PlayUrl then
        xsound:PlayUrl("youtube_audio", streamUrl, Config.DefaultVolume, false)
        --print("[DEBUG CLIENT] Playing audio with xsound (PlayUrl): " .. streamUrl)
    else
        --print("[DEBUG CLIENT] xsound or PlayUrl export not available")
        TriggerEvent('QBCore:Notify', "Error: xsound PlayUrl not available!", "error")
    end
    
    TriggerEvent('QBCore:Notify', "Now playing: " .. youTubeVideoName)
    --print("[DEBUG CLIENT] Notification sent: Now playing: " .. youTubeVideoName)
    
    Citizen.SetTimeout(Config.TimeoutSeconds * 1000, function()
        if xsound and xsound.Destroy then
            xsound:Destroy("youtube_audio")
            --print("[DEBUG CLIENT] Destroyed youtube_audio")
        end
        isYouTubeMode = false
        youTubeVideoName = ""
        TriggerEvent('slothy-headphones:turnOn')
        --print("[DEBUG CLIENT] YouTube mode timeout triggered")
    end)
end)

RegisterNetEvent('slothy-headphones:turnOn', function()
    local playerPed = PlayerPedId()
    SetPedPropIndex(playerPed, 0, 15, 1, true)
    
    if not isYouTubeMode then
        SetMobileRadioEnabledDuringGameplay(true)
        local defaultStation = Config.RadioStations[1].stationName
        SetRadioToStationName(defaultStation)
        currentStationName = Config.RadioStations[1].name
    end
    
    isHeadphonesOn = true
    local notifyMsg = isYouTubeMode and "Headphones on, YouTube mode: " .. youTubeVideoName or "Headphones on, radio playing: " .. currentStationName
    TriggerEvent('QBCore:Notify', notifyMsg)
end)

RegisterNetEvent('slothy-headphones:turnOff', function()
    local playerPed = PlayerPedId()
    ClearPedProp(playerPed, 0)
    SetMobileRadioEnabledDuringGameplay(false)
    
    local xsound = exports['xsound']
    if xsound and xsound.Destroy and isYouTubeMode then
        xsound:Destroy("youtube_audio")
        --print("[DEBUG CLIENT] Destroyed youtube_audio on turn off")
    end
    
    currentStationName = "None"
    isHeadphonesOn = false
    isYouTubeMode = false
    youTubeVideoName = ""
    TriggerEvent('QBCore:Notify', "Headphones off.")
end)

RegisterNetEvent('slothy-headphones:changeStation', function()
    local elements = {}
    for _, station in ipairs(Config.RadioStations) do
        table.insert(elements, { header = station.name, txt = "Listen to " .. station.name, params = { event = "slothy-headphones:setStation", args = station.stationName } })
    end
    exports['qb-menu']:openMenu(elements)
end)

RegisterNetEvent('slothy-headphones:setStation', function(stationName)
    local xsound = exports['xsound']
    if xsound and xsound.Destroy and isYouTubeMode then
        xsound:Destroy("youtube_audio")
        --print("[DEBUG CLIENT] Destroyed youtube_audio on station change")
        isYouTubeMode = false
        youTubeVideoName = ""
    end
    
    SetRadioToStationName(stationName)
    for _, station in ipairs(Config.RadioStations) do
        if station.stationName == stationName then
            currentStationName = station.name
            break
        end
    end
    TriggerEvent('QBCore:Notify', "Radio station changed to: " .. currentStationName)
    TriggerEvent('slothy-headphones:openMenu')
end)

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        if isHeadphonesOn then
            local hasItem = QBCore.Functions.HasItem("headphones")
            if not hasItem then
                local xsound = exports['xsound']
                if xsound and xsound.Destroy and isYouTubeMode then
                    xsound:Destroy("youtube_audio")
                end
                local playerPed = PlayerPedId()
                ClearPedProp(playerPed, 0)
                SetMobileRadioEnabledDuringGameplay(false)
                currentStationName = "None"
                isHeadphonesOn = false
                isYouTubeMode = false
                youTubeVideoName = ""
                TriggerEvent('QBCore:Notify', "Headphones dropped—audio stopped.")
            end
        end
    end
end)
