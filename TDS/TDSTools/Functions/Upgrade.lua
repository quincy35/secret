local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local PathfindingService = game:GetService("PathfindingService")
local RemoteFunction = if not GameSpoof then ReplicatedStorage:WaitForChild("RemoteFunction") else SpoofEvent
local RemoteEvent = if not GameSpoof then ReplicatedStorage:WaitForChild("RemoteEvent") else SpoofEvent
--[[{
    ["TowerIndex"] = ""
    ["TypeIndex"] = "",
    ["UpgradeTo"] = number,
    ["Wave"] = number,
    ["Minute"] = number,
    ["Second"] = number,
}]]
local function moveTo(target)
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(rootPart.Position, target.Position)

    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            humanoid:MoveTo(waypoint.Position)
            humanoid.MoveToFinished:Wait()
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
        end
    else
        warn("Path not found or obstructed.")
    end
end
return function(self, p1)
    local tableinfo = p1--ParametersPatch("Upgrade",...)
    local Tower = tableinfo["TowerIndex"]
    local Path = tableinfo["PathTarget"]
    local Wave,Min,Sec,InWave = tableinfo["Wave"] or 0, tableinfo["Minute"] or 0, tableinfo["Second"] or 0, tableinfo["InBetween"] or false 
    if not CheckPlace() then
        return
    end
    local CurrentCount = StratXLibrary.CurrentCount
    SetActionInfo("Upgrade","Total")
    task.spawn(function()
        local TimerCheck = TimeWaveWait(Wave, Min, Sec, InWave, tableinfo["Debug"])
        if not TimerCheck then
            return
        end
        --prints(TimerCheck)
        --prints("Upgrade",Wave, Min, Sec, InWave, StratXLibrary.CurrentCount, tableinfo["Debug"])
        local UpgradeCheck, SkipCheck
        task.delay(50, function()
            SkipCheck = true
        end)
        repeat
            if not TowersCheckHandler(Tower) then
                prints("End Upgrade",Wave, Min, Sec, InWave)
                return
            end
            UpgradeCheck = RemoteFunction:InvokeServer("Troops","Upgrade","Set",{
                ["Troop"] = TowersContained[Tower].Instance,
                ["Path"] = Path
            })
            task.wait()
                        
        until typeof(UpgradeCheck) == "boolean" and UpgradeCheck or SkipCheck
        if Path == 1 then
            TowersContained[Tower].TopPathUpgrade += 1
        elseif Path == 2 then
            TowersContained[Tower].BottomPathUpgrade += 1
        end
        local TowerType = GetTypeIndex(tableinfo["TypeIndex"],Tower)
        if CurrentCount ~= StratXLibrary.RestartCount then
            return
        end
        if SkipCheck and not UpgradeCheck then
            ConsoleError("Failed To Upgrade Tower Index: "..Tower..", Type: \""..TowerType.."\", (Wave "..Wave..", Min: "..Min..", Sec: "..Sec..", InBetween: "..tostring(InWave)..") UpgradeCheck: "..tostring(UpgradeCheck)..", SkipCheck: "..tostring(SkipCheck))
            return
        end
        SetActionInfo("Upgrade")
                   moveTo(TowersContained[Tower].Instance.HumanoidRootPart)
                    --print(Tower)
        ConsoleInfo("Upgraded Tower Index: "..Tower..", Type: \""..TowerType.."\", (Wave "..Wave..", Min: "..Min..", Sec: "..Sec..", InBetween: "..tostring(InWave)..") UpgradeCheck: "..tostring(UpgradeCheck)..", SkipCheck: "..tostring(SkipCheck))
    end)
end
