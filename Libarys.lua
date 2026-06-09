-- Libaryds.lua — Стабильная версия
local DiscordUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

function DiscordUI:CreateWindow(config)
    local player = game.Players.LocalPlayer
    local pgui = player:WaitForChild("PlayerGui")

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AndroidControl"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = pgui

    local Main = Instance.new("Frame")
    Main.Size = config.Size or UDim2.fromOffset(460, 380)
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(30, 31, 34)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(60, 63, 69)
    Stroke.Thickness = 1.5

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1,0,0,50)
    TitleBar.BackgroundColor3 = Color3.fromRGB(24, 25, 28)
    TitleBar.Parent = Main
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,-100,1,0)
    Title.Position = UDim2.fromOffset(20,0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "Android Control"
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    -- Close
    local Close = Instance.new("TextButton")
    Close.Size = UDim2.fromOffset(36,36)
    Close.Position = UDim2.new(1,-44,0,7)
    Close.BackgroundTransparency = 1
    Close.Text = "✕"
    Close.TextColor3 = Color3.fromRGB(200,200,200)
    Close.TextSize = 22
    Close.Font = Enum.Font.Gotham
    Close.Parent = TitleBar

    Close.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
    end)

    -- Content
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1,-28,1,-70)
    Content.Position = UDim2.fromOffset(14, 62)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    -- Toggle Key
    UserInputService.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == (config.ToggleKey or Enum.KeyCode.RightControl) then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    return {
        Content = Content,
        ScreenGui = ScreenGui,
        Frame = Main
    }
end

function DiscordUI:CreateToggle(parent, config)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1,0,0,66)
    Btn.BackgroundColor3 = Color3.fromRGB(47,49,54)
    Btn.Text = config.Title or "START / STOP"
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.TextSize = 17
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Parent = parent

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)

    local State = false

    local function Update()
        if State then
            Tween(Btn, {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}, 0.2)
        else
            Tween(Btn, {BackgroundColor3 = Color3.fromRGB(47,49,54)}, 0.2)
        end
    end

    Btn.MouseButton1Click:Connect(function()
        State = not State
        Update()
        if config.Callback then config.Callback(State) end
    end)

    return {
        Set = function(_, val)
            State = val
            Update()
            if config.Callback then config.Callback(State) end
        end
    }
end

return DiscordUI
