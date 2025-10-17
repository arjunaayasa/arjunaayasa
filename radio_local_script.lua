-- Radio/DJ System LocalScript
-- This script creates GUI interfaces for a radio system in Roblox

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remoteEvent = game.ReplicatedStorage:WaitForChild("RadioEvent")

-- Create the main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RadioGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ChooseSongGui - Main Song Selection Interface
local chooseSongGui = Instance.new("Frame")
chooseSongGui.Name = "ChooseSongGui"
chooseSongGui.Size = UDim2.new(0, 400, 0, 500)
chooseSongGui.Position = UDim2.new(0.5, -200, 0.5, -250)
chooseSongGui.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
chooseSongGui.BorderSizePixel = 2
chooseSongGui.BorderColor3 = Color3.fromRGB(0, 0, 0)
chooseSongGui.Style = Enum.FrameStyle.RobloxRound
chooseSongGui.Visible = false
chooseSongGui.Parent = screenGui

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -20, 0, 40)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DJ Radio System"
titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 24
titleLabel.Parent = chooseSongGui

-- Tab Container
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, -20, 0, 35)
tabContainer.Position = UDim2.new(0, 10, 0, 55)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = chooseSongGui

-- Presets Tab Button
local presetsTab = Instance.new("TextButton")
presetsTab.Name = "PresetsTab"
presetsTab.Size = UDim2.new(0.5, -5, 1, 0)
presetsTab.Position = UDim2.new(0, 0, 0, 0)
presetsTab.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
presetsTab.BorderSizePixel = 1
presetsTab.Style = Enum.ButtonStyle.RobloxButton
presetsTab.Text = "Presets"
presetsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
presetsTab.Font = Enum.Font.SourceSans
presetsTab.TextSize = 18
presetsTab.Parent = tabContainer

-- ID Tab Button
local idTab = Instance.new("TextButton")
idTab.Name = "IdTab"
idTab.Size = UDim2.new(0.5, -5, 1, 0)
idTab.Position = UDim2.new(0.5, 5, 0, 0)
idTab.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
idTab.BorderSizePixel = 1
idTab.Style = Enum.ButtonStyle.RobloxButton
idTab.Text = "ID"
idTab.TextColor3 = Color3.fromRGB(255, 255, 255)
idTab.Font = Enum.Font.SourceSans
idTab.TextSize = 18
idTab.Parent = tabContainer

-- Presets Content Frame
local presetsContent = Instance.new("Frame")
presetsContent.Name = "PresetsContent"
presetsContent.Size = UDim2.new(1, -20, 1, -150)
presetsContent.Position = UDim2.new(0, 10, 0, 100)
presetsContent.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
presetsContent.BorderSizePixel = 1
presetsContent.BorderColor3 = Color3.fromRGB(150, 150, 150)
presetsContent.Visible = true
presetsContent.Parent = chooseSongGui

-- ScrollingFrame for preset songs
local presetScroll = Instance.new("ScrollingFrame")
presetScroll.Name = "PresetScroll"
presetScroll.Size = UDim2.new(1, -10, 1, -10)
presetScroll.Position = UDim2.new(0, 5, 0, 5)
presetScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
presetScroll.BorderSizePixel = 1
presetScroll.ScrollBarThickness = 8
presetScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
presetScroll.Parent = presetsContent

-- Sample preset song buttons
local presetSongs = {
	{name = "Chill Vibes", id = 1234567890},
	{name = "Rock Anthem", id = 2345678901},
	{name = "Electronic Beat", id = 3456789012},
	{name = "Jazz Night", id = 4567890123},
	{name = "Classical Music", id = 5678901234},
}

for i, song in ipairs(presetSongs) do
	local songButton = Instance.new("TextButton")
	songButton.Name = "Song" .. i
	songButton.Size = UDim2.new(1, -10, 0, 40)
	songButton.Position = UDim2.new(0, 5, 0, (i-1) * 45 + 5)
	songButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	songButton.BorderSizePixel = 1
	songButton.Style = Enum.ButtonStyle.RobloxButton
	songButton.Text = song.name
	songButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	songButton.Font = Enum.Font.SourceSans
	songButton.TextSize = 16
	songButton.Parent = presetScroll
	
	songButton.MouseButton1Click:Connect(function()
		remoteEvent:FireServer("playSong", song.id)
		chooseSongGui.Visible = false
	end)
end

presetScroll.CanvasSize = UDim2.new(0, 0, 0, #presetSongs * 45 + 10)

-- ID Content Frame
local idContent = Instance.new("Frame")
idContent.Name = "IdContent"
idContent.Size = UDim2.new(1, -20, 1, -150)
idContent.Position = UDim2.new(0, 10, 0, 100)
idContent.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
idContent.BorderSizePixel = 1
idContent.BorderColor3 = Color3.fromRGB(150, 150, 150)
idContent.Visible = false
idContent.Parent = chooseSongGui

-- ID Input Label
local idInputLabel = Instance.new("TextLabel")
idInputLabel.Name = "IdInputLabel"
idInputLabel.Size = UDim2.new(1, -20, 0, 30)
idInputLabel.Position = UDim2.new(0, 10, 0, 20)
idInputLabel.BackgroundTransparency = 1
idInputLabel.Text = "Enter Song ID:"
idInputLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
idInputLabel.Font = Enum.Font.SourceSans
idInputLabel.TextSize = 18
idInputLabel.TextXAlignment = Enum.TextXAlignment.Left
idInputLabel.Parent = idContent

-- ID Input TextBox
local idInputBox = Instance.new("TextBox")
idInputBox.Name = "IdInputBox"
idInputBox.Size = UDim2.new(1, -20, 0, 40)
idInputBox.Position = UDim2.new(0, 10, 0, 60)
idInputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
idInputBox.BorderSizePixel = 2
idInputBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
idInputBox.Text = ""
idInputBox.PlaceholderText = "Enter audio ID here..."
idInputBox.TextColor3 = Color3.fromRGB(0, 0, 0)
idInputBox.Font = Enum.Font.SourceSans
idInputBox.TextSize = 16
idInputBox.ClearTextOnFocus = false
idInputBox.Parent = idContent

-- Play Custom ID Button
local playIdButton = Instance.new("TextButton")
playIdButton.Name = "PlayIdButton"
playIdButton.Size = UDim2.new(0.8, 0, 0, 45)
playIdButton.Position = UDim2.new(0.1, 0, 0, 120)
playIdButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
playIdButton.BorderSizePixel = 1
playIdButton.Style = Enum.ButtonStyle.RobloxButton
playIdButton.Text = "Play Song"
playIdButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playIdButton.Font = Enum.Font.SourceSansBold
playIdButton.TextSize = 20
playIdButton.Parent = idContent

playIdButton.MouseButton1Click:Connect(function()
	local songId = tonumber(idInputBox.Text)
	if songId then
		remoteEvent:FireServer("playSong", songId)
		chooseSongGui.Visible = false
	end
end)

-- Info Label (Note about customization)
local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "InfoLabel"
infoLabel.Size = UDim2.new(1, -20, 0, 60)
infoLabel.Position = UDim2.new(0, 10, 0, 180)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Note: You can customize the preset list by editing the presetSongs table in the script."
infoLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
infoLabel.Font = Enum.Font.SourceSansItalic
infoLabel.TextSize = 14
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = idContent

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 80, 0, 35)
closeButton.Position = UDim2.new(1, -90, 1, -45)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 1
closeButton.Style = Enum.ButtonStyle.RobloxButton
closeButton.Text = "Close"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSans
closeButton.TextSize = 16
closeButton.Parent = chooseSongGui

closeButton.MouseButton1Click:Connect(function()
	chooseSongGui.Visible = false
end)

-- Stop Button
local stopButton = Instance.new("TextButton")
stopButton.Name = "StopButton"
stopButton.Size = UDim2.new(0, 80, 0, 35)
stopButton.Position = UDim2.new(0, 10, 1, -45)
stopButton.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
stopButton.BorderSizePixel = 1
stopButton.Style = Enum.ButtonStyle.RobloxButton
stopButton.Text = "Stop"
stopButton.TextColor3 = Color3.fromRGB(0, 0, 0)
stopButton.Font = Enum.Font.SourceSans
stopButton.TextSize = 16
stopButton.Parent = chooseSongGui

stopButton.MouseButton1Click:Connect(function()
	remoteEvent:FireServer("stopSong")
	chooseSongGui.Visible = false
end)

-- Tab switching logic
presetsTab.MouseButton1Click:Connect(function()
	presetsContent.Visible = true
	idContent.Visible = false
	presetsTab.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
	idTab.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
end)

idTab.MouseButton1Click:Connect(function()
	presetsContent.Visible = false
	idContent.Visible = true
	idTab.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
	presetsTab.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
end)

-- Taken GUI - Dialog when radio is in use
local takenGui = Instance.new("Frame")
takenGui.Name = "TakenGui"
takenGui.Size = UDim2.new(0, 300, 0, 150)
takenGui.Position = UDim2.new(0.5, -150, 0.5, -75)
takenGui.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
takenGui.BorderSizePixel = 2
takenGui.BorderColor3 = Color3.fromRGB(0, 0, 0)
takenGui.Style = Enum.FrameStyle.RobloxRound
takenGui.Visible = false
takenGui.Parent = screenGui

local takenLabel = Instance.new("TextLabel")
takenLabel.Name = "TakenLabel"
takenLabel.Size = UDim2.new(1, -20, 0, 80)
takenLabel.Position = UDim2.new(0, 10, 0, 10)
takenLabel.BackgroundTransparency = 1
takenLabel.Text = "Radio is currently in use by another player."
takenLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
takenLabel.Font = Enum.Font.SourceSans
takenLabel.TextSize = 18
takenLabel.TextWrapped = true
takenLabel.Parent = takenGui

local takenOkButton = Instance.new("TextButton")
takenOkButton.Name = "OkButton"
takenOkButton.Size = UDim2.new(0, 100, 0, 40)
takenOkButton.Position = UDim2.new(0.5, -50, 1, -50)
takenOkButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
takenOkButton.BorderSizePixel = 1
takenOkButton.Style = Enum.ButtonStyle.RobloxButton
takenOkButton.Text = "OK"
takenOkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
takenOkButton.Font = Enum.Font.SourceSansBold
takenOkButton.TextSize = 18
takenOkButton.Parent = takenGui

takenOkButton.MouseButton1Click:Connect(function()
	takenGui.Visible = false
end)

-- Quit GUI - Confirmation dialog
local quitGui = Instance.new("Frame")
quitGui.Name = "QuitGui"
quitGui.Size = UDim2.new(0, 320, 0, 180)
quitGui.Position = UDim2.new(0.5, -160, 0.5, -90)
quitGui.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
quitGui.BorderSizePixel = 2
quitGui.BorderColor3 = Color3.fromRGB(0, 0, 0)
quitGui.Style = Enum.FrameStyle.RobloxRound
quitGui.Visible = false
quitGui.Parent = screenGui

local quitLabel = Instance.new("TextLabel")
quitLabel.Name = "QuitLabel"
quitLabel.Size = UDim2.new(1, -20, 0, 80)
quitLabel.Position = UDim2.new(0, 10, 0, 10)
quitLabel.BackgroundTransparency = 1
quitLabel.Text = "Are you sure you want to stop being the DJ?"
quitLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
quitLabel.Font = Enum.Font.SourceSans
quitLabel.TextSize = 18
quitLabel.TextWrapped = true
quitLabel.Parent = quitGui

local quitYesButton = Instance.new("TextButton")
quitYesButton.Name = "YesButton"
quitYesButton.Size = UDim2.new(0, 120, 0, 40)
quitYesButton.Position = UDim2.new(0, 20, 1, -55)
quitYesButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
quitYesButton.BorderSizePixel = 1
quitYesButton.Style = Enum.ButtonStyle.RobloxButton
quitYesButton.Text = "Yes"
quitYesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
quitYesButton.Font = Enum.Font.SourceSansBold
quitYesButton.TextSize = 18
quitYesButton.Parent = quitGui

local quitNoButton = Instance.new("TextButton")
quitNoButton.Name = "NoButton"
quitNoButton.Size = UDim2.new(0, 120, 0, 40)
quitNoButton.Position = UDim2.new(1, -140, 1, -55)
quitNoButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
quitNoButton.BorderSizePixel = 1
quitNoButton.Style = Enum.ButtonStyle.RobloxButton
quitNoButton.Text = "No"
quitNoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
quitNoButton.Font = Enum.Font.SourceSansBold
quitNoButton.TextSize = 18
quitNoButton.Parent = quitGui

quitYesButton.MouseButton1Click:Connect(function()
	remoteEvent:FireServer("quitDJ")
	quitGui.Visible = false
end)

quitNoButton.MouseButton1Click:Connect(function()
	quitGui.Visible = false
end)

-- Function to show the main GUI
local function showRadioGui()
	chooseSongGui.Visible = true
end

-- Function to show taken dialog
local function showTakenDialog()
	takenGui.Visible = true
end

-- Function to show quit confirmation
local function showQuitDialog()
	quitGui.Visible = true
end

-- Listen for remote events
remoteEvent.OnClientEvent:Connect(function(action, data)
	if action == "showGui" then
		showRadioGui()
	elseif action == "showTaken" then
		showTakenDialog()
	elseif action == "showQuit" then
		showQuitDialog()
	end
end)

-- Keybind to open radio (example: R key)
local userInputService = game:GetService("UserInputService")
userInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.R then
		if chooseSongGui.Visible then
			chooseSongGui.Visible = false
		else
			remoteEvent:FireServer("requestRadio")
		end
	end
end)
