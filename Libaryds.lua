-- lib/main.lua
local DiscordUI = {}

function DiscordUI:CreateWindow(config)
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = config.Name or "DiscordUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = playerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = config.Size or UDim2.fromOffset(480, 400)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 31, 34)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(60, 63, 69)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.4
    Stroke.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 42)
    TitleBar.BackgroundColor3 = Color3.fromRGB(26, 27, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -90, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "Android Control"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 17
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Position = UDim2.fromOffset(16, 0)
    Title.Parent = TitleBar

    -- Close Button
    local Close = Instance.new("TextButton")
    Close.Size = UDim2.fromOffset(28, 28)
    Close.Position = UDim2.new(1, -36, 0, 7)
    Close.BackgroundTransparency = 1
    Close.Text = "✕"
    Close.TextColor3 = Color3.fromRGB(200, 200, 200)
    Close.TextSize = 20
    Close.Font = Enum.Font.Gotham
    Close.Parent = TitleBar

    Close.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
    end)

    local Window = {
        Frame = MainFrame,
        ScreenGui = ScreenGui,
        Content = nil,
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    }

    -- Создаём область контента
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -62)
    Content.Position = UDim2.fromOffset(10, 52)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame
    Window.Content = Content

    return Window
end

function DiscordUI:CreateToggle(parent, config)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 58)
    Btn.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
    Btn.Text = config.Title or "Toggle"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 17
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Btn

    local State = false

    local function updateVisual()
        if State then
            Btn.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Discord blue
        else
            Btn.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
        end
    end

    Btn.MouseButton1Click:Connect(function()
        State = not State
        updateVisual()
        if config.Callback then
            config.Callback(State)
        end
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
