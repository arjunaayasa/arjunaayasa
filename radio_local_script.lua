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
chooseSongGui.BackgroundColor3 = Color3.fromRGB(43, 45, 49) -- Modern dark background #2B2D31
chooseSongGui.BorderSizePixel = 0
chooseSongGui.Visible = false
chooseSongGui.Parent = screenGui

-- Add UICorner for modern rounded corners
local chooseSongCorner = Instance.new("UICorner")
chooseSongCorner.CornerRadius = UDim.new(0, 12)
chooseSongCorner.Parent = chooseSongGui

-- Add UIPadding for better spacing
local chooseSongPadding = Instance.new("UIPadding")
chooseSongPadding.PaddingTop = UDim.new(0, 15)
chooseSongPadding.PaddingBottom = UDim.new(0, 15)
chooseSongPadding.PaddingLeft = UDim.new(0, 15)
chooseSongPadding.PaddingRight = UDim.new(0, 15)
chooseSongPadding.Parent = chooseSongGui

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DJ Radio System"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text for dark background
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 26
titleLabel.Parent = chooseSongGui

-- Tab Container
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 40)
tabContainer.Position = UDim2.new(0, 0, 0, 50)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = chooseSongGui

-- Presets Tab Button
local presetsTab = Instance.new("TextButton")
presetsTab.Name = "PresetsTab"
presetsTab.Size = UDim2.new(0.5, -2, 1, 0)
presetsTab.Position = UDim2.new(0, 0, 0, 0)
presetsTab.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Modern blue #5865F2 for active tab
presetsTab.BorderSizePixel = 0
presetsTab.Text = "Presets"
presetsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
presetsTab.Font = Enum.Font.GothamSemibold
presetsTab.TextSize = 16
presetsTab.AutoButtonColor = false
presetsTab.Parent = tabContainer

-- Add UICorner to tab
local presetsTabCorner = Instance.new("UICorner")
presetsTabCorner.CornerRadius = UDim.new(0, 8)
presetsTabCorner.Parent = presetsTab

-- ID Tab Button
local idTab = Instance.new("TextButton")
idTab.Name = "IdTab"
idTab.Size = UDim2.new(0.5, -2, 1, 0)
idTab.Position = UDim2.new(0.5, 2, 0, 0)
idTab.BackgroundColor3 = Color3.fromRGB(78, 80, 88) -- Modern gray #4E5058 for inactive tab
idTab.BorderSizePixel = 0
idTab.Text = "ID"
idTab.TextColor3 = Color3.fromRGB(255, 255, 255)
idTab.Font = Enum.Font.GothamSemibold
idTab.TextSize = 16
idTab.AutoButtonColor = false
idTab.Parent = tabContainer

-- Add UICorner to tab
local idTabCorner = Instance.new("UICorner")
idTabCorner.CornerRadius = UDim.new(0, 8)
idTabCorner.Parent = idTab

-- Presets Content Frame
local presetsContent = Instance.new("Frame")
presetsContent.Name = "PresetsContent"
presetsContent.Size = UDim2.new(1, 0, 1, -145)
presetsContent.Position = UDim2.new(0, 0, 0, 95)
presetsContent.BackgroundColor3 = Color3.fromRGB(35, 37, 41) -- Slightly darker for content area
presetsContent.BorderSizePixel = 0
presetsContent.Visible = true
presetsContent.Parent = chooseSongGui

-- Add UICorner to content frame
local presetsContentCorner = Instance.new("UICorner")
presetsContentCorner.CornerRadius = UDim.new(0, 8)
presetsContentCorner.Parent = presetsContent

-- ScrollingFrame for preset songs
local presetScroll = Instance.new("ScrollingFrame")
presetScroll.Name = "PresetScroll"
presetScroll.Size = UDim2.new(1, -16, 1, -16)
presetScroll.Position = UDim2.new(0, 8, 0, 8)
presetScroll.BackgroundTransparency = 1
presetScroll.BorderSizePixel = 0
presetScroll.ScrollBarThickness = 6
presetScroll.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242) -- Modern blue scrollbar
presetScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
presetScroll.Parent = presetsContent

-- Add UIPadding to scroll frame
local presetScrollPadding = Instance.new("UIPadding")
presetScrollPadding.PaddingTop = UDim.new(0, 5)
presetScrollPadding.PaddingBottom = UDim.new(0, 5)
presetScrollPadding.PaddingLeft = UDim.new(0, 5)
presetScrollPadding.PaddingRight = UDim.new(0, 5)
presetScrollPadding.Parent = presetScroll

-- Add UIListLayout for automatic arrangement
local presetListLayout = Instance.new("UIListLayout")
presetListLayout.Padding = UDim.new(0, 8)
presetListLayout.SortOrder = Enum.SortOrder.LayoutOrder
presetListLayout.Parent = presetScroll

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
	songButton.Size = UDim2.new(1, -10, 0, 45)
	songButton.BackgroundColor3 = Color3.fromRGB(78, 80, 88) -- Modern gray for buttons
	songButton.BorderSizePixel = 0
	songButton.Text = song.name
	songButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	songButton.Font = Enum.Font.Gotham
	songButton.TextSize = 15
	songButton.AutoButtonColor = false
	songButton.LayoutOrder = i
	songButton.Parent = presetScroll
	
	-- Add UICorner to button
	local songButtonCorner = Instance.new("UICorner")
	songButtonCorner.CornerRadius = UDim.new(0, 8)
	songButtonCorner.Parent = songButton
	
	-- Hover effect
	songButton.MouseEnter:Connect(function()
		songButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Blue on hover
	end)
	
	songButton.MouseLeave:Connect(function()
		songButton.BackgroundColor3 = Color3.fromRGB(78, 80, 88) -- Back to gray
	end)
	
	songButton.MouseButton1Click:Connect(function()
		remoteEvent:FireServer("playSong", song.id)
		chooseSongGui.Visible = false
	end)
end

-- Update canvas size based on UIListLayout
presetScroll.CanvasSize = UDim2.new(0, 0, 0, #presetSongs * 53 + 10)

-- ID Content Frame
local idContent = Instance.new("Frame")
idContent.Name = "IdContent"
idContent.Size = UDim2.new(1, 0, 1, -145)
idContent.Position = UDim2.new(0, 0, 0, 95)
idContent.BackgroundColor3 = Color3.fromRGB(35, 37, 41) -- Slightly darker for content area
idContent.BorderSizePixel = 0
idContent.Visible = false
idContent.Parent = chooseSongGui

-- Add UICorner to content frame
local idContentCorner = Instance.new("UICorner")
idContentCorner.CornerRadius = UDim.new(0, 8)
idContentCorner.Parent = idContent

-- Add UIPadding to content frame
local idContentPadding = Instance.new("UIPadding")
idContentPadding.PaddingTop = UDim.new(0, 15)
idContentPadding.PaddingBottom = UDim.new(0, 15)
idContentPadding.PaddingLeft = UDim.new(0, 15)
idContentPadding.PaddingRight = UDim.new(0, 15)
idContentPadding.Parent = idContent

-- ID Input Label
local idInputLabel = Instance.new("TextLabel")
idInputLabel.Name = "IdInputLabel"
idInputLabel.Size = UDim2.new(1, 0, 0, 30)
idInputLabel.Position = UDim2.new(0, 0, 0, 5)
idInputLabel.BackgroundTransparency = 1
idInputLabel.Text = "Enter Song ID:"
idInputLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text for dark background
idInputLabel.Font = Enum.Font.GothamSemibold
idInputLabel.TextSize = 16
idInputLabel.TextXAlignment = Enum.TextXAlignment.Left
idInputLabel.Parent = idContent

-- ID Input TextBox
local idInputBox = Instance.new("TextBox")
idInputBox.Name = "IdInputBox"
idInputBox.Size = UDim2.new(1, 0, 0, 45)
idInputBox.Position = UDim2.new(0, 0, 0, 45)
idInputBox.BackgroundColor3 = Color3.fromRGB(49, 51, 56) -- Darker gray for input
idInputBox.BorderSizePixel = 0
idInputBox.Text = ""
idInputBox.PlaceholderText = "Enter audio ID here..."
idInputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
idInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
idInputBox.Font = Enum.Font.Gotham
idInputBox.TextSize = 15
idInputBox.ClearTextOnFocus = false
idInputBox.Parent = idContent

-- Add UICorner to input box
local idInputCorner = Instance.new("UICorner")
idInputCorner.CornerRadius = UDim.new(0, 8)
idInputCorner.Parent = idInputBox

-- Add UIPadding to input box
local idInputPadding = Instance.new("UIPadding")
idInputPadding.PaddingLeft = UDim.new(0, 12)
idInputPadding.PaddingRight = UDim.new(0, 12)
idInputPadding.Parent = idInputBox

-- Play Custom ID Button
local playIdButton = Instance.new("TextButton")
playIdButton.Name = "PlayIdButton"
playIdButton.Size = UDim2.new(1, 0, 0, 45)
playIdButton.Position = UDim2.new(0, 0, 0, 105)
playIdButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Modern blue for primary action
playIdButton.BorderSizePixel = 0
playIdButton.Text = "Play Song"
playIdButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playIdButton.Font = Enum.Font.GothamBold
playIdButton.TextSize = 16
playIdButton.AutoButtonColor = false
playIdButton.Parent = idContent

-- Add UICorner to button
local playIdCorner = Instance.new("UICorner")
playIdCorner.CornerRadius = UDim.new(0, 8)
playIdCorner.Parent = playIdButton

-- Hover effect
playIdButton.MouseEnter:Connect(function()
	playIdButton.BackgroundColor3 = Color3.fromRGB(100, 113, 255) -- Lighter blue on hover
end)

playIdButton.MouseLeave:Connect(function()
	playIdButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
end)

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
infoLabel.Size = UDim2.new(1, 0, 0, 60)
infoLabel.Position = UDim2.new(0, 0, 0, 165)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Note: You can customize the preset list by editing the presetSongs table in the script."
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150) -- Lighter gray for better visibility on dark background
infoLabel.Font = Enum.Font.GothamMedium
infoLabel.TextSize = 13
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = idContent

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 90, 0, 40)
closeButton.Position = UDim2.new(1, -90, 1, -50)
closeButton.BackgroundColor3 = Color3.fromRGB(237, 66, 69) -- Modern red for close/cancel
closeButton.BorderSizePixel = 0
closeButton.Text = "Close"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamSemibold
closeButton.TextSize = 15
closeButton.AutoButtonColor = false
closeButton.Parent = chooseSongGui

-- Add UICorner to button
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Hover effect
closeButton.MouseEnter:Connect(function()
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 83)
end)

closeButton.MouseLeave:Connect(function()
	closeButton.BackgroundColor3 = Color3.fromRGB(237, 66, 69)
end)

closeButton.MouseButton1Click:Connect(function()
	chooseSongGui.Visible = false
end)

-- Stop Button
local stopButton = Instance.new("TextButton")
stopButton.Name = "StopButton"
stopButton.Size = UDim2.new(0, 90, 0, 40)
stopButton.Position = UDim2.new(0, 0, 1, -50)
stopButton.BackgroundColor3 = Color3.fromRGB(78, 80, 88) -- Modern gray for secondary actions
stopButton.BorderSizePixel = 0
stopButton.Text = "Stop"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamSemibold
stopButton.TextSize = 15
stopButton.AutoButtonColor = false
stopButton.Parent = chooseSongGui

-- Add UICorner to button
local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 8)
stopCorner.Parent = stopButton

-- Hover effect
stopButton.MouseEnter:Connect(function()
	stopButton.BackgroundColor3 = Color3.fromRGB(95, 97, 105)
end)

stopButton.MouseLeave:Connect(function()
	stopButton.BackgroundColor3 = Color3.fromRGB(78, 80, 88)
end)

stopButton.MouseButton1Click:Connect(function()
	remoteEvent:FireServer("stopSong")
	chooseSongGui.Visible = false
end)

-- Tab switching logic with modern colors
presetsTab.MouseButton1Click:Connect(function()
	presetsContent.Visible = true
	idContent.Visible = false
	presetsTab.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Active blue
	idTab.BackgroundColor3 = Color3.fromRGB(78, 80, 88) -- Inactive gray
end)

idTab.MouseButton1Click:Connect(function()
	presetsContent.Visible = false
	idContent.Visible = true
	idTab.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Active blue
	presetsTab.BackgroundColor3 = Color3.fromRGB(78, 80, 88) -- Inactive gray
end)

-- Taken GUI - Dialog when radio is in use
local takenGui = Instance.new("Frame")
takenGui.Name = "TakenGui"
takenGui.Size = UDim2.new(0, 320, 0, 170)
takenGui.Position = UDim2.new(0.5, -160, 0.5, -85)
takenGui.BackgroundColor3 = Color3.fromRGB(43, 45, 49) -- Modern dark background
takenGui.BorderSizePixel = 0
takenGui.Visible = false
takenGui.Parent = screenGui

-- Add UICorner for modern rounded corners
local takenCorner = Instance.new("UICorner")
takenCorner.CornerRadius = UDim.new(0, 12)
takenCorner.Parent = takenGui

-- Add UIPadding for better spacing
local takenPadding = Instance.new("UIPadding")
takenPadding.PaddingTop = UDim.new(0, 20)
takenPadding.PaddingBottom = UDim.new(0, 20)
takenPadding.PaddingLeft = UDim.new(0, 20)
takenPadding.PaddingRight = UDim.new(0, 20)
takenPadding.Parent = takenGui

local takenLabel = Instance.new("TextLabel")
takenLabel.Name = "TakenLabel"
takenLabel.Size = UDim2.new(1, 0, 0, 70)
takenLabel.Position = UDim2.new(0, 0, 0, 0)
takenLabel.BackgroundTransparency = 1
takenLabel.Text = "Radio is currently in use by another player."
takenLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text for dark background
takenLabel.Font = Enum.Font.Gotham
takenLabel.TextSize = 16
takenLabel.TextWrapped = true
takenLabel.Parent = takenGui

local takenOkButton = Instance.new("TextButton")
takenOkButton.Name = "OkButton"
takenOkButton.Size = UDim2.new(1, 0, 0, 45)
takenOkButton.Position = UDim2.new(0, 0, 1, -45)
takenOkButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Modern blue for primary action
takenOkButton.BorderSizePixel = 0
takenOkButton.Text = "OK"
takenOkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
takenOkButton.Font = Enum.Font.GothamBold
takenOkButton.TextSize = 16
takenOkButton.AutoButtonColor = false
takenOkButton.Parent = takenGui

-- Add UICorner to button
local takenOkCorner = Instance.new("UICorner")
takenOkCorner.CornerRadius = UDim.new(0, 8)
takenOkCorner.Parent = takenOkButton

-- Hover effect
takenOkButton.MouseEnter:Connect(function()
	takenOkButton.BackgroundColor3 = Color3.fromRGB(100, 113, 255)
end)

takenOkButton.MouseLeave:Connect(function()
	takenOkButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
end)

takenOkButton.MouseButton1Click:Connect(function()
	takenGui.Visible = false
end)

-- Quit GUI - Confirmation dialog
local quitGui = Instance.new("Frame")
quitGui.Name = "QuitGui"
quitGui.Size = UDim2.new(0, 340, 0, 190)
quitGui.Position = UDim2.new(0.5, -170, 0.5, -95)
quitGui.BackgroundColor3 = Color3.fromRGB(43, 45, 49) -- Modern dark background
quitGui.BorderSizePixel = 0
quitGui.Visible = false
quitGui.Parent = screenGui

-- Add UICorner for modern rounded corners
local quitCorner = Instance.new("UICorner")
quitCorner.CornerRadius = UDim.new(0, 12)
quitCorner.Parent = quitGui

-- Add UIPadding for better spacing
local quitPadding = Instance.new("UIPadding")
quitPadding.PaddingTop = UDim.new(0, 20)
quitPadding.PaddingBottom = UDim.new(0, 20)
quitPadding.PaddingLeft = UDim.new(0, 20)
quitPadding.PaddingRight = UDim.new(0, 20)
quitPadding.Parent = quitGui

local quitLabel = Instance.new("TextLabel")
quitLabel.Name = "QuitLabel"
quitLabel.Size = UDim2.new(1, 0, 0, 70)
quitLabel.Position = UDim2.new(0, 0, 0, 0)
quitLabel.BackgroundTransparency = 1
quitLabel.Text = "Are you sure you want to stop being the DJ?"
quitLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text for dark background
quitLabel.Font = Enum.Font.Gotham
quitLabel.TextSize = 16
quitLabel.TextWrapped = true
quitLabel.Parent = quitGui

local quitYesButton = Instance.new("TextButton")
quitYesButton.Name = "YesButton"
quitYesButton.Size = UDim2.new(0.48, 0, 0, 45)
quitYesButton.Position = UDim2.new(0, 0, 1, -45)
quitYesButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Modern blue for confirmation
quitYesButton.BorderSizePixel = 0
quitYesButton.Text = "Yes"
quitYesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
quitYesButton.Font = Enum.Font.GothamBold
quitYesButton.TextSize = 16
quitYesButton.AutoButtonColor = false
quitYesButton.Parent = quitGui

-- Add UICorner to button
local quitYesCorner = Instance.new("UICorner")
quitYesCorner.CornerRadius = UDim.new(0, 8)
quitYesCorner.Parent = quitYesButton

-- Hover effect
quitYesButton.MouseEnter:Connect(function()
	quitYesButton.BackgroundColor3 = Color3.fromRGB(100, 113, 255)
end)

quitYesButton.MouseLeave:Connect(function()
	quitYesButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
end)

local quitNoButton = Instance.new("TextButton")
quitNoButton.Name = "NoButton"
quitNoButton.Size = UDim2.new(0.48, 0, 0, 45)
quitNoButton.Position = UDim2.new(0.52, 0, 1, -45)
quitNoButton.BackgroundColor3 = Color3.fromRGB(237, 66, 69) -- Modern red for cancel
quitNoButton.BorderSizePixel = 0
quitNoButton.Text = "No"
quitNoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
quitNoButton.Font = Enum.Font.GothamBold
quitNoButton.TextSize = 16
quitNoButton.AutoButtonColor = false
quitNoButton.Parent = quitGui

-- Add UICorner to button
local quitNoCorner = Instance.new("UICorner")
quitNoCorner.CornerRadius = UDim.new(0, 8)
quitNoCorner.Parent = quitNoButton

-- Hover effect
quitNoButton.MouseEnter:Connect(function()
	quitNoButton.BackgroundColor3 = Color3.fromRGB(255, 80, 83)
end)

quitNoButton.MouseLeave:Connect(function()
	quitNoButton.BackgroundColor3 = Color3.fromRGB(237, 66, 69)
end)

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
