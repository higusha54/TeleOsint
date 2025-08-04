--[[
  HiRum Mod v1.0 by @higusha54
  Roblox NNNIF style full cheat GUI with:
  - GodMode (9999999999 HP regen)
  - KillAura (автоудар врагов)
  - Speed x3 / Jump x3
  - FireCharge (бесконечная подпитка костра)
  - Spawn any item from ReplicatedStorage (выпадающий список)
  - Teleport to nearest player
  - Freeze nearest mob
  - Teleport nearest mob to you
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- GUI colors
local COLOR_BG = Color3.fromRGB(25, 0, 40)
local COLOR_BTN = Color3.fromRGB(180, 40, 180)
local COLOR_BTN_HOVER = Color3.fromRGB(120, 20, 140)
local COLOR_TEXT = Color3.new(1, 1, 1)

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 320, 0, 480)
Frame.Position = UDim2.new(0.05, 0, 0.1, 0)
Frame.BackgroundColor3 = COLOR_BG
Frame.Active = true
Frame.Draggable = true
Frame.Name = "HiRumModGUI"

-- Title
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "HiRum mod v1.0 by @higusha54"
Title.TextColor3 = COLOR_BTN
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22

-- Utility function: create button
local function createButton(text, posY, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 280, 0, 35)
    btn.Position = UDim2.new(0.05, 0, posY, 0)
    btn.BackgroundColor3 = COLOR_BTN
    btn.TextColor3 = COLOR_TEXT
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text
    btn.AutoButtonColor = true

    -- Hover effect
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = COLOR_BTN_HOVER
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = COLOR_BTN
    end)

    return btn
end

-- Utility function: create label
local function createLabel(text, posY, parent)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(0, 280, 0, 25)
    lbl.Position = UDim2.new(0.05, 0, posY, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COLOR_TEXT
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.Text = text
    return lbl
end

-- Speed Button
local speedBtn = createButton("Speed x3", 0.09, Frame)
speedBtn.MouseButton1Click:Connect(function()
    if humanoid then
        humanoid.WalkSpeed = 48 -- Стандартный 16 * 3 = 48
    end
end)

-- Jump Button
local jumpBtn = createButton("Jump x3", 0.16, Frame)
jumpBtn.MouseButton1Click:Connect(function()
    if humanoid then
        humanoid.JumpPower = 150 -- Стандартный 50 * 3 = 150
    end
end)

-- GodMode toggle
local godmodeEnabled = false
local godmodeBtn = createButton("GodMode: OFF", 0.23, Frame)
godmodeBtn.MouseButton1Click:Connect(function()
    godmodeEnabled = not godmodeEnabled
    godmodeBtn.Text = godmodeEnabled and "GodMode: ON" or "GodMode: OFF"
end)

-- KillAura toggle
local killAuraEnabled = false
local killAuraBtn = createButton("KillAura: OFF", 0.30, Frame)
killAuraBtn.MouseButton1Click:Connect(function()
    killAuraEnabled = not killAuraEnabled
    killAuraBtn.Text = killAuraEnabled and "KillAura: ON" or "KillAura: OFF"
end)

-- FireCharge toggle (бесконечная подпитка костра)
local fireChargeEnabled = false
local fireChargeBtn = createButton("FireCharge: OFF", 0.37, Frame)
fireChargeBtn.MouseButton1Click:Connect(function()
    fireChargeEnabled = not fireChargeEnabled
    fireChargeBtn.Text = fireChargeEnabled and "FireCharge: ON" or "FireCharge: OFF"
end)

-- FireCharge variables
local maxFireLevel = 5
local fireLevel = 0

-- Label FireCharge
local fireLabel = createLabel("FireCharge: 0 / "..maxFireLevel, 0.44, Frame)

-- KillAura loop
spawn(function()
    while true do
        task.wait(0.2)
        if killAuraEnabled then
            for _, model in pairs(Workspace:GetChildren()) do
                if model ~= char and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
                    local dist = (model.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist < 10 then
                        -- Наносим урон (примитивно)
                        model.Humanoid:TakeDamage(25)
                    end
                end
            end
        else
            task.wait(0.5)
        end
    end
end)

-- GodMode regen loop
spawn(function()
    while true do
        task.wait(0.12)
        if godmodeEnabled and humanoid and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = math.min(humanoid.Health + 9999999999, humanoid.MaxHealth)
        end
    end
end)

-- FireCharge logic loop
local function isFireNearby()
    local range = 10
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:lower():find("fire") or obj.Name:lower():find("campfire") then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local pos = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") and obj.HumanoidRootPart.Position or obj:GetModelCFrame().p) or obj.Position
                if (pos - hrp.Position).Magnitude <= range then
                    return true
                end
            end
        end
    end
    return false
end

spawn(function()
    while true do
        task.wait(1)
        if fireChargeEnabled then
            if isFireNearby() then
                if fireLevel < maxFireLevel then
                    fireLevel = fireLevel + 1
                end
            else
                if fireLevel < maxFireLevel then
                    fireLevel = maxFireLevel -- Искусственно дозаряжаем
                end
            end

            if fireLevel >= maxFireLevel then
                if humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = math.min(humanoid.Health + 5, humanoid.MaxHealth)
                end
            end
        else
            fireLevel = 0
        end

        fireLabel.Text = "FireCharge: "..fireLevel.." / "..maxFireLevel
    end
end)

-- === SPAWN ITEMS SECTION ===

-- Label for spawn section
createLabel("Spawn Items", 0.52, Frame)

-- Dropdown UI for items
local dropdownFrame = Instance.new("Frame", Frame)
dropdownFrame.Size = UDim2.new(0, 280, 0, 110)
dropdownFrame.Position = UDim2.new(0.05, 0, 0.56, 0)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 10, 70)
dropdownFrame.ClipsDescendants = true

local dropdownButton = Instance.new("TextButton", dropdownFrame)
dropdownButton.Size = UDim2.new(1, 0, 0, 35)
dropdownButton.Position = UDim2.new(0, 0, 0, 0)
dropdownButton.BackgroundColor3 = COLOR_BTN
dropdownButton.TextColor3 = COLOR_TEXT
dropdownButton.Font = Enum.Font.GothamBold
dropdownButton.TextSize = 16
dropdownButton.Text = "Выбрать предмет"
dropdownButton.AutoButtonColor = true

local itemsList = Instance.new("ScrollingFrame", dropdownFrame)
itemsList.Size = UDim2.new(1, 0, 0, 75)
itemsList.Position = UDim2.new(0, 0, 0, 35)
itemsList.CanvasSize = UDim2.new(0, 0, 0, 0)
itemsList.ScrollBarThickness = 6
itemsList.BackgroundColor3 = Color3.fromRGB(60, 15, 140)
itemsList.Visible = false

local UIListLayout = Instance.new("UIListLayout", itemsList)
UIListLayout.Padding = UDim.new(0, 2)

local selectedItem = nil

local function fillItems()
    local yOffset = 0
    for _, item in pairs(ReplicatedStorage:GetDescendants()) do
        if item:IsA("Tool") or item:IsA("Model") then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 25)
            btn.Position = UDim2.new(0, 5, 0, yOffset)
            btn.BackgroundColor3 = Color3.fromRGB(100, 30, 160)
            btn.TextColor3 = COLOR_TEXT
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.Text = item.Name
            btn.Parent = itemsList

            btn.MouseButton1Click:Connect(function()
                selectedItem = item
                dropdownButton.Text = "Выбран: "..item.Name
                itemsList.Visible = false
            end)
            yOffset = yOffset + 30
        end
    end
    itemsList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

fillItems()

dropdownButton.MouseButton1Click:Connect(function()
    itemsList.Visible = not itemsList.Visible
end)

local spawnButton = createButton("Спавнить предмет", 0.75, Frame)
spawnButton.MouseButton1Click:Connect(function()
    if not selectedItem then
        warn("Предмет не выбран!")
        return
    end

    local clone = selectedItem:Clone()
    if clone:IsA("Tool") then
        clone.Parent = player.Backpack
        print("Спавнено в рюкзак: "..clone.Name)
    else
        clone.Parent = Workspace
        if char and char.PrimaryPart then
            clone:PivotTo(char:GetPivot() + Vector3.new(3, 0, 0))
        else
            clone:SetPrimaryPartCFrame(CFrame.new(hrp.Position + Vector3.new(3, 0, 0)))
        end
        print("Спавнено рядом: "..clone.Name)
    end
end)

-- Teleport to nearest player
local tpPlayerBtn = createButton("Телепорт к ближайшему игроку", 0.82, Frame)
tpPlayerBtn.MouseButton1Click:Connect(function()
    local nearestDist = math.huge
    local nearestPlr = nil
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestPlr = plr
            end
        end
    end
    if nearestPlr then
        hrp.CFrame = nearestPlr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        print("Телепортировался к "..nearestPlr.Name)
    else
        warn("Игроки не найдены")
    end
end)

-- Freeze nearest mob
local frozenMobs = {}
local freezeMobBtn = createButton("Заморозить/Разморозить ближайшего моба", 0.89, Frame)
freezeMobBtn.MouseButton1Click:Connect(function()
    local nearestDist = math.huge
    local nearestMob = nil
    for _, model in pairs(Workspace:GetChildren()) do
        if model ~= char and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - model.HumanoidRootPart.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestMob = model
            end
        end
    end
    if nearestMob then
        local root = nearestMob.HumanoidRootPart
        if frozenMobs[nearestMob] then
            root.Anchored = false
            frozenMobs[nearestMob] = nil
            print("Разморозил моба: "..nearestMob.Name)
        else
            root.Anchored = true
            frozenMobs[nearestMob] = root
            print("Заморозил моба: "..nearestMob.Name)
        end
    else
        warn("Мобы не найдены")
    end
end)

-- Teleport nearest mob to player
local tpMobToPlayerBtn = createButton("Телепортировать ближайшего моба к себе", 0.96, Frame)
tpMobToPlayerBtn.MouseButton1Click:Connect(function()
    local nearestDist = math.huge
    local nearestMob = nil
    for _, model in pairs(Workspace:GetChildren()) do
        if model ~= char and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - model.HumanoidRootPart.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestMob = model
            end
        end
    end
    if nearestMob then
        nearestMob.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
        print("Телепортировал моба "..nearestMob.Name.." к себе")
    else
        warn("Мобы не найдены")
    end
end)

-- Reset Speed and Jump on character respawn
player.CharacterAdded:Connect(function(char)
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
end)
