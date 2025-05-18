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