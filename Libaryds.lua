-- Libaryds.lua - Красивая Discord/TG Style UI (Исправленная)
local DiscordUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function Tween(obj, props, time)
    time = time or 0.25
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

function DiscordUI:CreateWindow(config)
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AndroidControlUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = playerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = config.Size or UDim2.fromOffset(460, 380)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = MainFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(55, 58, 64)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.4
    Stroke.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 48)
    TitleBar.BackgroundColor3 = Color3.fromRGB(26, 27, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 16)
    TitleCorner.Parent = TitleBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -110, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "Android Control"
    Title.TextColor3 = Color3.fromRGB(245, 245, 245)
    Title.TextSize = 17.5
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Position = UDim2.fromOffset(20, 0)
    Title.Parent = TitleBar

    -- Close Button
    local Close = Instance.new("TextButton")
    Close.Size = UDim2.fromOffset(34, 34)
    Close.Position = UDim2.new(1, -42, 0, 7)
    Close.BackgroundTransparency = 1
    Close.Text = "✕"
    Close.TextColor3 = Color3.fromRGB(170, 170, 170)
    Close.TextSize = 21
    Close.Font = Enum.Font.Gotham
    Close.Parent = TitleBar

    Close.MouseEnter:Connect(function() Tween(Close, {TextColor3 = Color3.fromRGB(255, 70, 70)}) end)
    Close.MouseLeave:Connect(function() Tween(Close, {TextColor3 = Color3.fromRGB(170, 170, 170)}) end)

    -- Content
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -28, 1, -72)
    Content.Position = UDim2.fromOffset(14, 60)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true
    Content.Parent = MainFrame

    local Window = {
        Frame = MainFrame,
        ScreenGui = ScreenGui,
        Content = Content,
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    }

    -- Close Button
    Close.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.fromOffset(0, 0)}, 0.28)
        task.wait(0.28)
        ScreenGui.Enabled = false
        MainFrame.Size = config.Size or UDim2.fromOffset(460, 380)
    end)

    -- Toggle Window (Right Ctrl)
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Window.ToggleKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
            if ScreenGui.Enabled then
                MainFrame.Size = UDim2.fromOffset(0, 0)
                Tween(MainFrame, {Size = config.Size or UDim2.fromOffset(460, 380)}, 0.35)
            end
        end
    end)

    return Window
end

function DiscordUI:CreateToggle(parent, config)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 64)
    Btn.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
    Btn.Text = config.Title or "START / STOP"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 17
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Btn

    local State = false

    local function updateVisual()
        if State then
            Tween(Btn, {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}, 0.2)
        else
            Tween(Btn, {BackgroundColor3 = Color3.fromRGB(47, 49, 54)}, 0.2)
        end
    end

    -- Hover (без расширения)
    Btn.MouseEnter:Connect(function()
        Tween(Btn, {BackgroundColor3 = State and Color3.fromRGB(105, 115, 255) or Color3.fromRGB(60, 63, 69)}, 0.2)
    end)
    Btn.MouseLeave:Connect(function()
        updateVisual()
    end)

    Btn.MouseButton1Click:Connect(function()
        State = not State
        updateVisual()
        if config.Callback then config.Callback(State) end
    end)

    return {
        Set = function(self, value)
            State = value
            updateVisual()
            if config.Callback then config.Callback(State) end
        end
    }
end

return DiscordUI
