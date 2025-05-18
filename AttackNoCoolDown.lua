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

_G.FastAttack = true

if _G.FastAttack then
    local _ENV = (getgenv or getrenv or getfenv)()

    local function SafeWaitForChild(parent, childName)
        local success, result = pcall(function()
            return parent:WaitForChild(childName)
        end)
        if not success or not result then
            warn("noooooo: " .. childName)
        end
        return result
    end

    local function WaitChilds(path, ...)
        local last = path
        for _, child in {...} do
            last = last:FindFirstChild(child) or SafeWaitForChild(last, child)
            if not last then break end
        end
        return last
    end

    local VirtualInputManager = game:GetService("VirtualInputManager")
    local CollectionService = game:GetService("CollectionService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TeleportService = game:GetService("TeleportService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer

    if not Player then
        warn("Không tìm thấy người chơi cục bộ.")
        return
    end

    local Remotes = SafeWaitForChild(ReplicatedStorage, "Remotes")
    if not Remotes then return end

    local Validator = SafeWaitForChild(Remotes, "Validator")
    local CommF = SafeWaitForChild(Remotes, "CommF_")
    local CommE = SafeWaitForChild(Remotes, "CommE")

    local ChestModels = SafeWaitForChild(workspace, "ChestModels")
    local WorldOrigin = SafeWaitForChild(workspace, "_WorldOrigin")
    local Characters = SafeWaitForChild(workspace, "Characters")
    local Enemies = SafeWaitForChild(workspace, "Enemies")
    local Map = SafeWaitForChild(workspace, "Map")

    local EnemySpawns = SafeWaitForChild(WorldOrigin, "EnemySpawns")
    local Locations = SafeWaitForChild(WorldOrigin, "Locations")

    local RenderStepped = RunService.RenderStepped
    local Heartbeat = RunService.Heartbeat
    local Stepped = RunService.Stepped

    local Modules = SafeWaitForChild(ReplicatedStorage, "Modules")
    local Net = SafeWaitForChild(Modules, "Net")

    local sethiddenproperty = sethiddenproperty or function(...) return ... end
    local setupvalue = setupvalue or (debug and debug.setupvalue)
    local getupvalue = getupvalue or (debug and debug.getupvalue)

    local Settings = {
        AutoClick = true,
        ClickDelay = 0
    }

    local Module = {}

    Module.FastAttack = (function()
        if _ENV.rz_FastAttack then
            return _ENV.rz_FastAttack
        end

        local FastAttack = {
            Distance = 100,
            attackMobs = true,
            attackPlayers = true,
            Equipped = nil
        }

        local RegisterAttack = SafeWaitForChild(Net, "RE/RegisterAttack")
        local RegisterHit = SafeWaitForChild(Net, "RE/RegisterHit")

        local function IsAlive(character)
            return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
        end

        local function ProcessEnemies(OthersEnemies, Folder)
            local BasePart = nil
            for _, Enemy in Folder:GetChildren() do
                local Head = Enemy:FindFirstChild("Head")
                if Head and IsAlive(Enemy) and Player:DistanceFromCharacter(Head.Position) < FastAttack.Distance then
                    if Enemy ~= Player.Character then
                        table.insert(OthersEnemies, { Enemy, Head })
                        BasePart = Head
                    end
                end
            end
            return BasePart
        end

        function FastAttack:Attack(BasePart, OthersEnemies)
            if not BasePart or #OthersEnemies == 0 then return end
            RegisterAttack:FireServer(Settings.ClickDelay or 0)
            RegisterHit:FireServer(BasePart, OthersEnemies)
        end

        function FastAttack:AttackNearest()
            local OthersEnemies = {}
            local Part1 = ProcessEnemies(OthersEnemies, Enemies)
            local Part2 = ProcessEnemies(OthersEnemies, Characters)

            local character = Player.Character
            if not character then return end
            local equippedWeapon = character:FindFirstChildOfClass("Tool")

            if equippedWeapon and equippedWeapon:FindFirstChild("LeftClickRemote") then
                for _, enemyData in ipairs(OthersEnemies) do
                    local enemy = enemyData[1]
                    local direction = (enemy.HumanoidRootPart.Position - character:GetPivot().Position).Unit
                    pcall(function()
                        equippedWeapon.LeftClickRemote:FireServer(direction, 1)
                    end)
                end
            elseif #OthersEnemies > 0 then
                self:Attack(Part1 or Part2, OthersEnemies)
            else
                task.wait(0)
            end
        end

        function FastAttack:BladeHits()
            local Equipped = IsAlive(Player.Character) and Player.Character:FindFirstChildOfClass("Tool")
            if Equipped and Equipped.ToolTip ~= "Gun" then
                self:AttackNearest()
            else
                task.wait(0)
            end
        end

        task.spawn(function()
            while task.wait(Settings.ClickDelay) do
                if Settings.AutoClick then
                    FastAttack:BladeHits()
                end
            end
        end)

        _ENV.rz_FastAttack = FastAttack
        return FastAttack
    end)()
end
   
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