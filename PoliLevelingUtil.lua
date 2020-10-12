local addonName, addonTable = ...

local GetTime, UnitLevel, UnitXP, UnitXPMax = GetTime, UnitLevel, UnitXP, UnitXPMax
local print, ssplit, sformat, floor, date, time = print, string.split, string.format, math.floor, date, time
local tinsert, tremove = table.insert, table.remove

local QuestDataSessions
local isRecording
local currentSession
local currentRecording
local startGetTime
local nextUpdate

local ui_reload=false

local function UI_Reloading()
     ui_reload=true
end
hooksecurefunc("ReloadUI", UI_Reloading);

SLASH_PoliLevelingUtil1 = "/plu"
SlashCmdList["PoliLevelingUtil"] = function(msg)
    local cmd, arg = ssplit(" ", msg)
    if cmd == "start" then
        if not isRecording then
            currentRecording = {}
            currentRecording.name = msg:match("^start%s+(.+)") or "Recording " .. (#currentSession.recordings + 1)
            currentRecording.startTime = date("%x %X", time())
            currentRecording.characterLevel = UnitLevel("player") + UnitXP("player") / UnitXPMax("player")
            currentRecording.snapshots = {}
            tinsert(currentSession.recordings, currentRecording)
            isRecording = true
            startGetTime = GetTime()
            currentRecording.startGetTime = startGetTime
            nextUpdate = startGetTime + 5
            print("Recording started: "..currentRecording.name)
        else
            print("Recording is already going")
        end
    elseif cmd == "stop" then
        if isRecording then
            isRecording = nil
            nextUpdate = nil
            if GetTime( ) - startGetTime < 5 then
                tremove(currentSession.recordings)
                print("Recordings must be longer than 5 seconds")
                print("Deleted Recording: " .. currentRecording.name)
                currentRecording = nil
                startGetTime = nil
                return
            end
            currentRecording.stopTime = date("%x %X", time())
            print("Recording stopped. Reload to ensure successful write to saved variables.")
            print("Name: " .. currentRecording.name)
            currentRecording = nil
            local duration = GetTime() - startGetTime
            if duration < 60 then
                print("Duration: ".. floor(duration) .. " seconds")
            else
                print("Duration: ".. floor(duration / 60) .. " minutes " .. floor(duration % 60) .. " seconds")
            end
            startGetTime = nil
        else
            print("Not recording")
        end
    elseif cmd == "list" then
        local recordings = currentSession.recordings
        print("Recordings:")
        for i=1, #recordings do
            print(i .. ".  " .. recordings[i].name .. "    " .. (recordings[i].stopTime and (recordings[i].startTime .. "    " .. recordings[i].stopTime .. "    " .. sformat("%4.2f", recordings[i].characterLevel) .. "    " .. sformat("%4.2f", recordings[i].snapshots[#recordings[i].snapshots])) or "In progress"))
        end
    elseif cmd == "delete" then
        local recordings = currentSession.recordings
        local recordingNumber, recordingName = msg:match("^delete%s+(%d+)\.%s+(.+)")
        recordingNumber = tonumber(recordingNumber)
        if recordingNumber and recordingName then
            if recordingNumber >= 1 and recordingNumber <= #recordings then
                if recordings[recordingNumber].name == recordingName and recordings[recordingNumber].stopTime then
                    tremove(recordings, recordingNumber)
                    print("Deleted recording: " .. recordingNumber .. ".  ".. recordingName)
                elseif recordings[recordingNumber].name ~= recordingName then
                    print("Could not find recording")
                else
                    print("Can't delete a recording that is in progress")
                end
                return
            end
        end
        local recordingName = msg:match("^delete%s+(.+)")
        if not recordingName then
            print("Specify the name of a recording to delete")
            return
        end
        local matches = 0
        local matchIndex
        for i=1, #recordings do
            if recordingName:match("^" .. recordings[i].name .. "$") then
                matches = matches + 1
                matchIndex = i
            end
        end
        if matches == 0 then
            print("Could not find recording")
        elseif matches > 1 then
            print("Multiple recordings with name '" .. recordingName .. "' found")
            print("Specify recording number with name")
            print("Example: '/plu delete 1. <recording name>")
        elseif matchIndex == #recordings and recordings[matchIndex].stopTime == nil then
            print("Can't delete a recording that is in progress")
        else
            print("Deleted recording: " .. recordingName)
            tremove(recordings, matchIndex)
        end
    else
        print("Commands:")
        print("/plu start <recording name>")
        print("/plu stop")
        print("/plu list")
        print("/plu delete <recording name>")
    end
end

local recordingFrame = CreateFrame("Frame")
recordingFrame:SetScript("OnUpdate", function()
    if isRecording then
        -- determine whether snapshots are up to date
        -- if they aren't, then:
        if GetTime() - nextUpdate >= 0 then
            -- check if UnitLevel, UnitXP, and UnitXPMax are giving valid values
            -- if they are, then:
            local playerLevel = UnitLevel("player")
            local playerXP = UnitXP("player")
            local playerXPMax = UnitXPMax("player")
            if playerLevel and playerXP and playerXPMax and playerXPMax > 0 then
                -- count how many missing snapshots there are
                local missingSnapshots = floor((GetTime() - startGetTime) / 5) - #currentRecording.snapshots
                if missingSnapshots ~= 0 then
                    local level = playerLevel + playerXP / playerXPMax
                    for i=1,missingSnapshots do
                        tinsert(currentRecording.snapshots, level)
                    end
                    nextUpdate = (#currentRecording.snapshots + 1) * 5 + startGetTime
                end
            end
        end
    end
end)

do
    local onEvent = function(self, event, ...)
        if event == "ADDON_LOADED" and ... == addonName then
            if LevelingSessionInProgress then
                QuestDataSessions = addonTable.JSON.decode(QuestDataJson)
                currentSession = QuestDataSessions[#QuestDataSessions]
                -- if recording in progress, restore variables
                local recordings = currentSession.recordings
                if #recordings ~= 0 and recordings[#recordings].stopTime == nil then
                    currentRecording = recordings[#recordings]
                    startGetTime = currentRecording.startGetTime
                    nextUpdate = GetTime()
                    isRecording = true
                end
            else
                if QuestDataJson == nil or QuestDataJson == "null" then
                    QuestDataSessions = {}
                else
                    QuestDataSessions = addonTable.JSON.decode(QuestDataJson)
                end
                currentSession = {}
                currentSession.loginTime = date("%x %X", time())
                currentSession.recordings = {}
                tinsert(QuestDataSessions, currentSession)
            end
        elseif event == "PLAYER_LOGOUT" then
            if ui_reload then
                LevelingSessionInProgress = true
                QuestDataJson = addonTable.JSON.encode(QuestDataSessions)
            else
                local logoutTime = date("%x %X", time())
                if isRecording then
                    isRecording = false
                    currentRecording.stopTime = logoutTime
                end
                if #currentSession.recordings == 0 then
                    tremove(QuestDataSessions)
                else
                    currentSession.logoutTime = logoutTime
                end
                QuestDataJson = addonTable.JSON.encode(QuestDataSessions)
                LevelingSessionInProgress = nil
            end
        end
    end
    local addonLoadedFrame = CreateFrame("Frame")
    addonLoadedFrame:RegisterEvent("ADDON_LOADED")
    addonLoadedFrame:RegisterEvent("PLAYER_LOGOUT")
    addonLoadedFrame:SetScript("OnEvent", onEvent)
end
