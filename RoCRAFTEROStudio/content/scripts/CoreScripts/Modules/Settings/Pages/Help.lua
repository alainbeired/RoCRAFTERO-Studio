--[[
		Filename: Help.lua
		Written by: jeditkacheff
		Version 1.0
		Description: Takes care of the help page in Settings Menu
--]]
-------------- CONSTANTS --------------
local KEYBOARD_MOUSE_TAG = "KeyboardMouse"
local TOUCH_TAG = "Touch"
local GAMEPAD_TAG = "Gamepad"
local PC_TABLE_SPACING = 4

-------------- SERVICES --------------
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

----------- UTILITIES --------------
local utility = require(RobloxGui.Modules.Settings.Utility)
  
------------ Variables -------------------
local PageInstance = nil
RobloxGui:WaitForChild("Modules"):WaitForChild("TenFootInterface")
local isTenFootInterface = require(RobloxGui.Modules.TenFootInterface):IsEnabled()

local enablePortraitModeSuccess, enablePortraitModeValue = pcall(function() return settings():GetFFlag("EnablePortraitMode") end)
local enablePortraitMode = enablePortraitModeSuccess and enablePortraitModeValue

----------- CLASS DECLARATION --------------

local function Initialize()
  local settingsPageFactory = require(RobloxGui.Modules.Settings.SettingsPageFactory)
  local this = settingsPageFactory:CreateNewPage()
  this.HelpPages = {}

  local lastInputType = nil

  function this:GetCurrentInputType()
    if lastInputType == nil then -- we don't know what controls the user has, just use reasonable defaults
      local platform = UserInputService:GetPlatform()
      if platform == Enum.Platform.XBoxOne or platform == Enum.Platform.WiiU then

        return GAMEPAD_TAG
      elseif platform == Enum.Platform.Windows or platform == Enum.Platform.OSX then
        return KEYBOARD_MOUSE_TAG
      else
        return TOUCH_TAG
      end
    end

    if lastInputType == Enum.UserInputType.Keyboard or lastInputType == Enum.UserInputType.MouseMovement or 
    lastInputType == Enum.UserInputType.MouseButton1 or lastInputType == Enum.UserInputType.MouseButton2 or
    lastInputType == Enum.UserInputType.MouseButton3 or lastInputType == Enum.UserInputType.MouseWheel then
      return KEYBOARD_MOUSE_TAG
    elseif lastInputType == Enum.UserInputType.Touch then
      return TOUCH_TAG
    elseif lastInputType == Enum.UserInputType.Gamepad1 or lastInputType == Enum.UserInputType.Gamepad2 or 
    inputType == Enum.UserInputType.Gamepad3 or lastInputType == Enum.UserInputType.Gamepad4 then
      return GAMEPAD_TAG
    end

    return KEYBOARD_MOUSE_TAG
  end


  local function createPCHelp(parentFrame)
    local function createPCGroup(title, actionInputBindings)
      local textIndent = 9

      local pcGroupFrame = utility:Create'Frame'
      {
        Size = UDim2.new(1/3,-PC_TABLE_SPACING,1,0),
        BackgroundTransparency = 1,
        Name = "PCGroupFrame" .. tostring(title)
      };
      local pcGroupTitle = utility:Create'TextLabel'
      {
        Position = UDim2.new(0,textIndent,0,0),
        Size = UDim2.new(1,-textIndent,0,30),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.SourceSansBold,
        FontSize = Enum.FontSize.Size18,
        TextColor3 = Color3.new(1,1,1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Name = "PCGroupTitle" .. tostring(title),
        ZIndex = 2,
        Parent = pcGroupFrame
      };

      local count = 0
      local frameHeight = 42
      local spacing = 2
      local offset = pcGroupTitle.Size.Y.Offset
      for i = 1, #actionInputBindings do
        for actionName, inputName in pairs(actionInputBindings[i]) do
          local actionInputFrame = utility:Create'Frame'
          {
            Size = UDim2.new(1,0,0,frameHeight),
            Position = UDim2.new(0,0,0, offset + ((frameHeight + spacing) * count)),
            BackgroundTransparency = 0.65,
            BorderSizePixel = 0,
            ZIndex = 2,
            Name = "ActionInputBinding" .. tostring(actionName),
            Parent = pcGroupFrame
          };

          local nameLabel = utility:Create'TextLabel'
          {
            Size = UDim2.new(0.4,-textIndent,0,frameHeight),
            Position = UDim2.new(0,textIndent,0,0),
            BackgroundTransparency = 1,
            Text = actionName,
            Font = Enum.Font.SourceSansBold,
            FontSize = Enum.FontSize.Size18,
            TextColor3 = Color3.new(1,1,1),
            TextXAlignment = Enum.TextXAlignment.Left,
            Name = actionName .. "Label",
            ZIndex = 2,
            Parent = actionInputFrame,
            TextWrapped = true,
            TextScaled = true
          };
          do
            local textSizeConstraint = Instance.new("UITextSizeConstraint",nameLabel)
            textSizeConstraint.MaxTextSize = 18
          end
          

          local inputLabel = utility:Create'TextLabel'
          {
            Size = UDim2.new(0.5,0,0,frameHeight),
            Position = UDim2.new(0.5,-4,0,0),
            BackgroundTransparency = 1,
            Text = inputName,
            Font = Enum.Font.SourceSans,
            FontSize = Enum.FontSize.Size18,
            TextColor3 = Color3.new(1,1,1),
            TextXAlignment = Enum.TextXAlignment.Left,
            Name = inputName .. "Label",
            ZIndex = 2,
            Parent = actionInputFrame,
            TextWrapped = true,
            TextScaled = true
          };
          do
            local textSizeConstraint = Instance.new("UITextSizeConstraint",inputLabel)
            textSizeConstraint.MaxTextSize = 18
          end

          count = count + 1
        end
      end

      pcGroupFrame.Size = UDim2.new(pcGroupFrame.Size.X.Scale,pcGroupFrame.Size.X.Offset,
        0, offset + ((frameHeight + spacing) * count))

      return pcGroupFrame
    end

    local rowOffset = 50
    local isOSX = UserInputService:GetPlatform() == Enum.Platform.OSX

    local charMoveFrame = createPCGroup( "Character Movement", {[1] = {["Move Forward"] = "W/Up Arrow"}, 
        [2] = {["Move Backward"] = "S/Down Arrow"},
        [3] = {["Move Left"] = "A/Left Arrow"},
        [4] = {["Move Right"] = "D/Right Arrow"},
        [5] = {["Jump"] = "Space"}} )
    charMoveFrame.Parent = parentFrame

    local accessoriesFrame = createPCGroup("Accessories", {	
        [1] = {["Equip Tools"] = "1,2,3..."}, 
        [2] = {["Unequip Tools"] = "1,2,3..."},
        [3] = {["Drop Tool"] = "Backspace"},
        [4] = {["Use Tool"] = "Left Mouse Button"} })
    accessoriesFrame.Position = UDim2.new(1/3,PC_TABLE_SPACING,0,0)
    accessoriesFrame.Parent = parentFrame

    local miscFrame = nil
    miscFrame = createPCGroup("Misc", {	
        [1] = {["Screenshot"] = "Print Screen"}, 
        [2] = {["Record Video"] = isOSX and "F12/fn + F12" or "F12"},
        [3] = {["Dev Console"] = isOSX and "F9/fn + F9" or "F9"},
        [4] = {["Mouselock"] = "Shift"},
        [5] = {["Graphics Level"] = isOSX and "F10/fn + F10" or "F10"},
        [6] = {["Fullscreen"] = isOSX and "F11/fn + F11" or "F11"},
        [7] = {["Perf. Stats"] = isOSX and "Fn+Opt+Cmd+F7" or "Ctrl + Shift + F7"}, 
      }
    )

    miscFrame.Position = UDim2.new(2/3,PC_TABLE_SPACING * 2,0,0)
    miscFrame.Parent = parentFrame

    local camFrame = createPCGroup("Camera Movement", {	[1] = {["Rotate"] = "Right Mouse Button"}, 
        [2] = {["Zoom In/Out"] = "Mouse Wheel"},
        [3] = {["Zoom In"] = "I"},
        [4] = {["Zoom Out"] = "O"} })
    camFrame.Position = UDim2.new(0,0,charMoveFrame.Size.Y.Scale,charMoveFrame.Size.Y.Offset + rowOffset)
    camFrame.Parent = parentFrame

    local menuFrame = createPCGroup("Menu Items", {		[1] = {["Roblox Menu"] = "ESC"}, 
        [2] = {["Backpack"] = "~"},
        [3] = {["Playerlist"] = "TAB"},
        [4] = {["Chat"] = "/"} })
    menuFrame.Position = UDim2.new(1/3,PC_TABLE_SPACING,charMoveFrame.Size.Y.Scale,charMoveFrame.Size.Y.Offset + rowOffset)
    menuFrame.Parent = parentFrame

    parentFrame.Size = UDim2.new(parentFrame.Size.X.Scale, parentFrame.Size.X.Offset, 0, 
      menuFrame.Size.Y.Offset + menuFrame.Position.Y.Offset)
  end

  local function createGamepadHelp(parentFrame)
    local gamepadImage = "rbxasset://textures/ui/Settings/Help/GenericController.png"
    local imageSize = UDim2.new(0,650,0,239)
    local imagePosition = UDim2.new(0.5,-imageSize.X.Offset/2,0.5,-imageSize.Y.Offset/2)
    if UserInputService:GetPlatform() == Enum.Platform.XBoxOne or UserInputService:GetPlatform() == Enum.Platform.XBox360 then
      gamepadImage = "rbxasset://textures/ui/Settings/Help/XboxController.png"
      imageSize = UDim2.new(0,1334,0,570)
      imagePosition = UDim2.new(0.5, (-imageSize.X.Offset/2) - 50, 0.5, -imageSize.Y.Offset/2)
    elseif UserInputService:GetPlatform() == Enum.Platform.PS4 or UserInputService:GetPlatform() == Enum.Platform.PS3 then
      gamepadImage = "rbxasset://textures/ui/Settings/Help/PSController.png"
    end

    local gamepadImageLabel = utility:Create'ImageLabel'
    {
      Name = "GamepadImage",
      Size = imageSize,
      Position = imagePosition,
      Image = gamepadImage,
      BackgroundTransparency = 1,
      ZIndex = 2,
      Parent = parentFrame
    };
    parentFrame.Size = UDim2.new(parentFrame.Size.X.Scale, parentFrame.Size.X.Offset, 0, gamepadImageLabel.Size.Y.Offset + 100)

    local gamepadFontSize = isTenFootInterface and Enum.FontSize.Size36 or Enum.FontSize.Size24
    local function createGamepadLabel(text, position, size, rightAligned)
      local nameLabel = utility:Create'TextLabel'
      {
        Position = position,
        Size = size,
        BackgroundTransparency = 1,
        Text = text,
        TextXAlignment = rightAligned and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left,
        AnchorPoint = rightAligned and Vector2.new(1, 0) or Vector2.new(0, 0),
        Font = Enum.Font.SourceSansBold,
        FontSize = gamepadFontSize,
        TextColor3 = Color3.new(1,1,1),
        Name = text .. "Label",
        ZIndex = 2,
        Parent = gamepadImageLabel
      };
    end

    local textVerticalSize = (gamepadFontSize == Enum.FontSize.Size36) and 36 or 24

    if gamepadImage == "rbxasset://textures/ui/Settings/Help/XboxController.png" then
      createGamepadLabel("Switch Tool", UDim2.new(0,200,0,-textVerticalSize/2), UDim2.new(0,100,0,textVerticalSize), true)
      createGamepadLabel("Game Menu Toggle", UDim2.new(0,200,0.15,-textVerticalSize/2), UDim2.new(0,164,0,textVerticalSize), true)
      createGamepadLabel("Move", UDim2.new(0,-20,0.31,-textVerticalSize/2), UDim2.new(0,46,0,textVerticalSize), true)
      createGamepadLabel("Menu Navigation", UDim2.new(0,160,0.46,-textVerticalSize/2), UDim2.new(0,164,0,textVerticalSize), true)
      createGamepadLabel("Use Tool", UDim2.new(0.96,0,0,-textVerticalSize/2), UDim2.new(0,73,0,textVerticalSize))
      createGamepadLabel("Roblox Menu", UDim2.new(0.96,0,0.15,-textVerticalSize/2), UDim2.new(0,122,0,textVerticalSize))
      createGamepadLabel("Back", UDim2.new(0.96,0,0.31,-textVerticalSize/2), UDim2.new(0,43,0,textVerticalSize))
      createGamepadLabel("Jump", UDim2.new(0.96,0,0.46,-textVerticalSize/2), UDim2.new(0,49,0,textVerticalSize))
      createGamepadLabel("Rotate Camera", UDim2.new(1,0,0.62,-textVerticalSize/2), UDim2.new(0,132,0,textVerticalSize))
      createGamepadLabel("Camera Zoom", UDim2.new(1,0,0.77,-textVerticalSize/2), UDim2.new(0,122,0,textVerticalSize))
    else
      createGamepadLabel("Switch Tool", UDim2.new(-0.01,0,0,-textVerticalSize/2), UDim2.new(0,100,0,textVerticalSize))
      createGamepadLabel("Game Menu Toggle", UDim2.new(-0.11,0,0.15,-textVerticalSize/2), UDim2.new(0,164,0,textVerticalSize))
      createGamepadLabel("Move", UDim2.new(-0.08,0,0.31,-textVerticalSize/2), UDim2.new(0,46,0,textVerticalSize))
      createGamepadLabel("Menu Navigation", UDim2.new(-0.125,0,0.46,-textVerticalSize/2), UDim2.new(0,164,0,textVerticalSize))
      createGamepadLabel("Use Tool", UDim2.new(0.96,0,0,-textVerticalSize/2), UDim2.new(0,73,0,textVerticalSize))
      createGamepadLabel("Roblox Menu", UDim2.new(0.9,0,0.15,-textVerticalSize/2), UDim2.new(0,122,0,textVerticalSize))
      createGamepadLabel("Back", UDim2.new(1.01,0,0.31,-textVerticalSize/2), UDim2.new(0,43,0,textVerticalSize))
      createGamepadLabel("Jump", UDim2.new(0.91,0,0.46,-textVerticalSize/2), UDim2.new(0,49,0,textVerticalSize))
      createGamepadLabel("Rotate Camera", UDim2.new(0.91,0,0.62,-textVerticalSize/2), UDim2.new(0,132,0,textVerticalSize))
      createGamepadLabel("Camera Zoom", UDim2.new(0.91,0,0.77,-textVerticalSize/2), UDim2.new(0,122,0,textVerticalSize))
    end


    -- NOTE: On consoles we put the dev console in the settings menu. Only place
    -- owners can see this for now.
  end

  local function createTouchHelp(parentFrame)
    local smallScreen = utility:IsSmallTouchScreen()
    local ySize = GuiService:GetScreenResolution().y - 350
    if smallScreen then
      ySize = GuiService:GetScreenResolution().y - 100
    end
    parentFrame.Size = UDim2.new(1,0,0,ySize)

    local function createTouchLabel(text, position, size, parent)
      local nameLabel = utility:Create'TextLabel'
      {
        Position = position,
        Size = size,
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.SourceSansBold,
        FontSize = Enum.FontSize.Size14,
        TextColor3 = Color3.new(1,1,1),
        Name = text .. "Label",
        ZIndex = 3,
        Parent = parent,
        TextScaled = true,
        TextWrapped = true
      };
      if not smallScreen then
        nameLabel.FontSize = Enum.FontSize.Size18
        nameLabel.Size = UDim2.new(nameLabel.Size.X.Scale, nameLabel.Size.X.Offset, nameLabel.Size.Y.Scale, nameLabel.Size.Y.Offset + 4)
      end
      local nameBackgroundImage = utility:Create'ImageLabel'
      {
        Name = text .. "BackgroundImage",
        Size = UDim2.new(1.25,0,1.25,0),
        Position = UDim2.new(-0.125,0,-0.065,0),
        BackgroundTransparency = 1,
        Image = "rbxasset://textures/ui/Settings/Radial/RadialLabel.png",
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(12,2,65,21),
        ZIndex = 2,
        Parent = nameLabel
      };
      
      local textSizeConstraint = Instance.new("UITextSizeConstraint",nameLabel)
      textSizeConstraint.MaxTextSize = 18

      return nameLabel
    end

    local function createTouchGestureImage(name, image, position, size, parent)
      local gestureImage = utility:Create'ImageLabel'
      {
        Name = name,
        Size = size,
        Position = position,
        BackgroundTransparency = 1,
        Image = image,
        ZIndex = 2,
        Parent = parent
      };

      return gestureImage
    end

    local xSizeOffset = 30
    local ySize = 25
    if smallScreen then xSizeOffset = 0 end

    local moveLabel = createTouchLabel("Move", UDim2.new(0.06,0,0.58,0), UDim2.new(0,77 + xSizeOffset,0,ySize), parentFrame)
    local jumpLabel = createTouchLabel("Jump", UDim2.new(0.8,0,0.58,0), UDim2.new(0,77 + xSizeOffset,0,ySize), parentFrame)
    local equipLabel = createTouchLabel("Equip/Unequip Tools", UDim2.new(0.5,-60,0.64,0), UDim2.new(0,120 + xSizeOffset,0,ySize), parentFrame)

    local zoomLabel = createTouchLabel("Zoom In/Out", UDim2.new(0.15,-60,0.02,0), UDim2.new(0,120,0,ySize), parentFrame)
    createTouchGestureImage("ZoomImage", "rbxasset://textures/ui/Settings/Help/ZoomGesture.png", UDim2.new(0.5,-26,1,3), UDim2.new(0,53,0,59), zoomLabel)
    local rotateLabel = createTouchLabel("Rotate Camera", UDim2.new(0.5,-60,0.02,0), UDim2.new(0,120,0,ySize), parentFrame)
    createTouchGestureImage("RotateImage", "rbxasset://textures/ui/Settings/Help/RotateCameraGesture.png", UDim2.new(0.5,-32,1,3), UDim2.new(0,65,0,48), rotateLabel)
    local useToolLabel = createTouchLabel("Use Tool", UDim2.new(0.85,-60,0.02,0), UDim2.new(0,120,0,ySize), parentFrame)
    createTouchGestureImage("ToolImage", "rbxasset://textures/ui/Settings/Help/UseToolGesture.png", UDim2.new(0.5,-19,1,3), UDim2.new(0,38,0,52), useToolLabel)

  end

  local function createHelpDisplay(typeOfHelp)
    local helpFrame = utility:Create'Frame'
    {
      Size = UDim2.new(1,0,1,0),
      BackgroundTransparency = 1,
      Name = "HelpFrame" .. tostring(typeOfHelp)
    };

    if typeOfHelp == KEYBOARD_MOUSE_TAG then
      createPCHelp(helpFrame)
    elseif typeOfHelp == GAMEPAD_TAG then
      createGamepadHelp(helpFrame)
    elseif typeOfHelp == TOUCH_TAG then
      createTouchHelp(helpFrame)
    end

    return helpFrame
  end

  local function displayHelp(currentPage)
    for i, helpPage in pairs(this.HelpPages) do
      if helpPage == currentPage then
        helpPage.Parent = this.Page
        this.Page.Size = helpPage.Size
      else
        helpPage.Parent = nil
      end
    end
    if UserInputService:GetPlatform() == Enum.Platform.XBoxOne then
      this.HubRef.PageViewClipper.ClipsDescendants = false
      this.HubRef.PageView.ClipsDescendants = false
    end
  end

  local function switchToHelp(typeOfHelp)
    local helpPage = this.HelpPages[typeOfHelp]
    if helpPage then
      displayHelp(helpPage)
    else
      this.HelpPages[typeOfHelp] = createHelpDisplay(typeOfHelp)
      switchToHelp(typeOfHelp)
    end
  end

  local function showTypeOfHelp()
    switchToHelp(this:GetCurrentInputType())
  end

  ------ TAB CUSTOMIZATION -------
  this.TabHeader.Name = "HelpTab"

  this.TabHeader.Icon.Image = "rbxasset://textures/ui/Settings/MenuBarIcons/HelpTab.png"

  this.TabHeader.Icon.Title.Text = "Help"


  ------ PAGE CUSTOMIZATION -------
  this.Page.Name = "Help"

  UserInputService.InputBegan:connect(function(inputObject)
      local inputType = inputObject.UserInputType
      if inputType ~= Enum.UserInputType.Focus and inputType ~= Enum.UserInputType.None then
        lastInputType = inputObject.UserInputType
        showTypeOfHelp()
      end
    end)

  return this
end


----------- Public Facing API Additions --------------
do
  PageInstance = Initialize()

  PageInstance.Displayed.Event:connect(function()
      local isPortrait = enablePortraitMode and utility:IsPortrait()
      if PageInstance:GetCurrentInputType() == TOUCH_TAG then
        if PageInstance.HubRef.BottomButtonFrame and not utility:IsSmallTouchScreen() and not isPortrait then
          PageInstance.HubRef.BottomButtonFrame.Visible = false
        end
      end
    end)

  PageInstance.Hidden.Event:connect(function()
      PageInstance.HubRef.PageViewClipper.ClipsDescendants = true
      PageInstance.HubRef.PageView.ClipsDescendants = true

      PageInstance.HubRef:ShowShield()

      local isPortrait = enablePortraitMode and utility:IsPortrait()
      if PageInstance:GetCurrentInputType() == TOUCH_TAG then
        if PageInstance.HubRef.BottomButtonFrame and not utility:IsSmallTouchScreen() and not isPortrait then
          PageInstance.HubRef.BottomButtonFrame.Visible = true
        end
      end
    end)
end


return PageInstance