local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("headphones", function(source, item)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then
        --print("[DEBUG SERVER] Error: Player not found for source " .. tostring(source))
        return false
    end
    
    --print("[DEBUG SERVER] Player " .. xPlayer.PlayerData.name .. " used the headphones item")
    TriggerClientEvent('slothy-headphones:useHeadphone', source)
    return true
end)

RegisterServerEvent('slothy-headphones:processYouTubeLink', function(youtubeLink)
    local src = source
    if not youtubeLink or youtubeLink == "" or not youtubeLink:match("^https?://") then
        TriggerClientEvent('QBCore:Notify', src, "Invalid YouTube link! Please use a valid URL.", "error")
        --print("[DEBUG SERVER] Invalid YouTube link received from " .. src .. ": " .. tostring(youtubeLink))
        return
    end

    local videoId = youtubeLink:match("v=([^&]+)") or youtubeLink:match("youtu%.be/([^?]+)") or "Unknown"
    local oEmbedUrl = "https://www.youtube.com/oembed?url=" .. youtubeLink

    PerformHttpRequest(oEmbedUrl, function(statusCode, response, headers)
        local videoName = "YouTube Video: " .. videoId -- Fallback name for the menu
        if statusCode == 200 and response then
            local data = json.decode(response)
            if data and data.title then
                videoName = data.title
            else
                --print("[DEBUG SERVER] Failed to parse oEmbed response for " .. youtubeLink .. ": " .. tostring(response))
            end
        else
            --print("[DEBUG SERVER] oEmbed request failed for " .. youtubeLink .. " - Status: " .. statusCode)
        end

        --print("[DEBUG SERVER] Relaying YouTube link for " .. src .. ": " .. videoName .. ", URL: " .. youtubeLink)
        TriggerClientEvent('slothy-headphones:playYouTubeLink', src, videoName, youtubeLink)
    end, "GET", "", { ["Content-Type"] = "application/json" })
end)
