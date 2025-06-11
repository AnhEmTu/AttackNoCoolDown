local MatsuneA1 = {};

MatsuneA1["1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"));
MatsuneA1["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;

MatsuneA1["2"] = Instance.new("Frame", MatsuneA1["1"]);
MatsuneA1["2"]["BorderSizePixel"] = 0;
MatsuneA1["2"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
MatsuneA1["2"]["Size"] = UDim2.new(0, 50, 0, 50);
MatsuneA1["2"]["Draggable"] = true
MatsuneA1["2"]["Position"] = UDim2.new(0.20, 0, -0.1, 0);
MatsuneA1["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);


MatsuneA1["3"] = Instance.new("UICorner", MatsuneA1["2"]);
MatsuneA1["3"]["CornerRadius"] = UDim.new(1, 0);

MatsuneA1["4"] = Instance.new("TextButton", MatsuneA1["2"]);
MatsuneA1["4"]["TextWrapped"] = true;
MatsuneA1["4"]["BorderSizePixel"] = 0;
MatsuneA1["4"]["TextSize"] = 14;
MatsuneA1["4"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
MatsuneA1["4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
MatsuneA1["4"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
MatsuneA1["4"]["Size"] = UDim2.new(0, 50, 0, 56);
MatsuneA1["4"]["BackgroundTransparency"] = 1;
MatsuneA1["4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
MatsuneA1["4"]["Text"] = [[STOP TWEEN]];
MatsuneA1["4"]["Position"] = UDim2.new(0, 0, -0.07273, 0);
MatsuneA1["5"] = Instance.new("UIStroke", MatsuneA1["4"]);
MatsuneA1["5"]["Color"] = Color3.fromRGB(255, 0, 0);

MatsuneA1["6"] = Instance.new("UIStroke", MatsuneA1["2"]);
MatsuneA1["6"]["Color"] = Color3.fromRGB(169, 238, 8);

local function StopTween()
    if _G.StopTween then
        return
    end
    
    _G.StopTween = true
    wait()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character and character:IsDescendantOf(game.Workspace) then
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame
        end
    end
    wait()    
    if character:FindFirstChild("BodyClip") then
        character.BodyClip:Destroy()
    end
    if character:FindFirstChild("PartTele") then
        character.PartTele:Destroy()
    end
    _G.StopTween = false
end

MatsuneA1["4"].MouseButton1Click:Connect(function()
    StopTween()
end)
   
   local player = game.Players.LocalPlayer
function AttackNoCoolDown()
    local character = player.Character
    if not character then return end
    local equippedWeapon = nil
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then
            equippedWeapon = item
            break
        end
    end
    if not equippedWeapon then return end
    local function IsEntityAlive(entity)
        return entity and entity:FindFirstChild("Humanoid") and entity.Humanoid.Health > 0
    end
    local function GetEnemiesInRange(range)
        local enemies = game:GetService("Workspace").Enemies:GetChildren()
        local targets = {}
        local playerPos = character:GetPivot().Position
        for _, enemy in ipairs(enemies) do
            local primaryPart = enemy:FindFirstChild("HumanoidRootPart")
            if primaryPart and IsEntityAlive(enemy) and (primaryPart.Position - playerPos).Magnitude <= range then
                table.insert(targets, enemy)
            end
        end
        return targets
    end
    if equippedWeapon:FindFirstChild("LeftClickRemote") then
        local attackCount = 1  
        local enemiesInRange = GetEnemiesInRange(60)
        for _, enemy in ipairs(enemiesInRange) do
            local direction = (enemy.HumanoidRootPart.Position - character:GetPivot().Position).Unit
            pcall(function()
                equippedWeapon.LeftClickRemote:FireServer(direction, attackCount)
            end)
            attackCount = attackCount + 1
            if attackCount > 1000000000 then attackCount = 1 end
        end
    else
        local targets = {}
        local enemies = game:GetService("Workspace").Enemies:GetChildren()
        local playerPos = character:GetPivot().Position
        local mainTarget = nil
        for _, enemy in ipairs(enemies) do
            if not enemy:GetAttribute("IsBoat") and IsEntityAlive(enemy) then
                local head = enemy:FindFirstChild("Head")
                if head and (playerPos - head.Position).Magnitude <= 60 then
                    table.insert(targets, { enemy, head })
                    mainTarget = head
                end
            end
        end
        if not mainTarget then return end
        pcall(function()
            local storage = game:GetService("ReplicatedStorage")
            local attackEvent = storage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterAttack")
            local hitEvent = storage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterHit")
            if #targets > 0 then
                attackEvent:FireServer(0.000000001)
                hitEvent:FireServer(mainTarget, targets)
            else
                task.wait(0.000000001)
            end
        end)
    end
end

_G.FastAttack = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
if not player.Team then
    if getgenv().Team == "Marines" then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
    elseif getgenv().Team == "Pirates" then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
    end
    repeat
        task.wait(1)
        local chooseTeam = playerGui:FindFirstChild("ChooseTeam", true)
        local uiController = playerGui:FindFirstChild("UIController", true)
        if chooseTeam and chooseTeam.Visible and uiController then
            for _, v in pairs(getgc(true)) do
                if type(v) == "function" and getfenv(v).script == uiController then
                    local constant = getconstants(v)
                    pcall(function()
                        if (constant[1] == "Pirates" or constant[1] == "Marines") and #constant == 1 then
                            if constant[1] == getgenv().Team then
                                v(getgenv().Team)
                            end
                        end
                    end)
                end
            end
        end
    until player.Team
end   