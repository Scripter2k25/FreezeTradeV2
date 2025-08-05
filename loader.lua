local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "TradeUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 360)
frame.Position = UDim2.new(0.5, -210, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Title Label
local title = Instance.new("TextLabel")
title.Text = "freeze trade @redo"
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

-- Username Input Box
local inputBox = Instance.new("TextBox")
inputBox.PlaceholderText = "Enter username"
inputBox.Size = UDim2.new(0.9, 0, 0, 40)
inputBox.Position = UDim2.new(0.05, 0, 0, 60)
inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.Font = Enum.Font.Gotham
inputBox.TextScaled = true
inputBox.ClearTextOnFocus = false
inputBox.BorderSizePixel = 0
inputBox.Parent = frame
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 8)

-- Profile Picture
local targetPfp = Instance.new("ImageLabel")
targetPfp.Size = UDim2.new(0, 120, 0, 120)
targetPfp.Position = UDim2.new(0.5, 0, 0, 100)
targetPfp.AnchorPoint = Vector2.new(0.5, 0)
targetPfp.BackgroundTransparency = 1
targetPfp.Image = ""
targetPfp.Parent = frame

-- @username Label
local targetUsername = Instance.new("TextLabel")
targetUsername.Text = ""
targetUsername.Size = UDim2.new(1, 0, 0, 30)
targetUsername.Position = UDim2.new(0.5, 0, 0, 230)
targetUsername.AnchorPoint = Vector2.new(0.5, 0)
targetUsername.BackgroundTransparency = 1
targetUsername.TextColor3 = Color3.fromRGB(200, 200, 200)
targetUsername.Font = Enum.Font.GothamBold
targetUsername.TextScaled = true
targetUsername.TextXAlignment = Enum.TextXAlignment.Center
targetUsername.TextYAlignment = Enum.TextYAlignment.Center
targetUsername.Parent = frame

-- Toggle Button Template
local function createToggleButton(name, position)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.4, 0, 0, 40)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local toggled = false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = "✅ " .. name

            -- Roblox Notification
            local notifText = name == "Freeze Trade" and "Target Trade Freeze" or "Target Auto Accept"
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Trade Tool";
                    Text = notifText;
                    Duration = 3;
                })
            end)
        else
            btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextColor3 = Color3.fromRGB(0, 0, 0)
            btn.Text = name
        end
    end)

    return btn
end

-- Buttons
local freezeBtn = createToggleButton("Freeze Trade", UDim2.new(0.05, 0, 1, -50))
local acceptBtn = createToggleButton("Auto Accept", UDim2.new(0.55, 0, 1, -50))

-- Username Input Functionality
inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local username = inputBox.Text
        if username ~= "" then
            local body = HttpService:JSONEncode({
                usernames = { username },
                excludeBannedUsers = false
            })

            local success, response = pcall(function()
                return HttpService:JSONDecode(
                    game:HttpPost("https://users.roblox.com/v1/usernames/users", body, Enum.HttpContentType.ApplicationJson)
                )
            end)

            if success and response and response.data and response.data[1] then
                local userData = response.data[1]
                local userId = userData.id
                local userName = userData.name

                targetPfp.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
                targetUsername.Text = "@" .. userName
            else
                targetPfp.Image = ""
                targetUsername.Text = "User not found"
            end
        end
    end
end)
