
-- NOVA CHAT v4 - RABEE OWNER EDITION
-- Place in StarterPlayer > StarterPlayerScripts
-- Local UI prototype; messages are not shared with other players.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("NOVAChat")
if old then old:Destroy() end

local GOLD = Color3.fromRGB(212, 175, 55)
local BLACK = Color3.fromRGB(13, 13, 16)
local PANEL = Color3.fromRGB(20, 20, 24)
local TEXT = Color3.fromRGB(245, 242, 255)
local MUTED = Color3.fromRGB(165, 158, 185)
local DARK_BUTTON = Color3.fromRGB(38, 35, 45)

local accent = GOLD
local rgbEnabled = false
local rgbNameEnabled = false
local notificationsEnabled = true
local currentTab = "عام"
local displayName = player.DisplayName
local opened = true
local busy = false
local hue = 0
local noticeId = 0
local activeBubble

local function make(class, props, parent)
    local obj = Instance.new(class)
    for key, value in pairs(props) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius or 9)
    }, obj)
end

local function outline(obj, color, thickness)
    return make("UIStroke", {
        Color = color or accent,
        Thickness = thickness or 1
    }, obj)
end

local function tween(obj, duration, props)
    local animation = TweenService:Create(
        obj,
        TweenInfo.new(duration, Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out),
        props
    )
    animation:Play()
    return animation
end

local gui = make("ScreenGui", {
    Name = "NOVAChat",
    ResetOnSpawn = false,
    DisplayOrder = 50
}, playerGui)

-- Main window
local main = make("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 18, 0.5, 0),
    Size = UDim2.fromOffset(365, 430),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    ClipsDescendants = false,
    Active = true
}, gui)

round(main, 15)
local mainStroke = outline(main, GOLD, 2)

-- Header
local header = make("TextLabel", {
    Name = "Header",
    Position = UDim2.fromOffset(12, 19),
    Size = UDim2.new(1, -105, 0, 27),
    BackgroundTransparency = 1,
    Text = "NOVA CHAT",
    TextColor3 = GOLD,
    Font = Enum.Font.GothamBold,
    TextSize = 21,
    TextXAlignment = Enum.TextXAlignment.Left,
    Active = true,
    ZIndex = 5
}, main)

-- Owner name above NOVA CHAT
local ownerLabel = make("TextLabel", {
    Name = "OwnerLabel",
    Position = UDim2.fromOffset(13, 3),
    Size = UDim2.new(1, -110, 0, 16),
    BackgroundTransparency = 1,
    Text = "Rabee1258 | THE OWNER",
    TextColor3 = GOLD,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6
}, main)

local closeButton = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -8, 0, 8),
    Size = UDim2.fromOffset(32, 32),
    BackgroundColor3 = Color3.fromRGB(68, 40, 35),
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = TEXT,
    Font = Enum.Font.GothamBold,
    TextSize = 23,
    ZIndex = 5
}, main)
round(closeButton, 9)

local settingsButton = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -47, 0, 8),
    Size = UDim2.fromOffset(32, 32),
    BackgroundColor3 = DARK_BUTTON,
    BorderSizePixel = 0,
    Text = "⚙",
    TextColor3 = GOLD,
    Font = Enum.Font.GothamBold,
    TextSize = 19,
    ZIndex = 5
}, main)
round(settingsButton, 9)

-- Drag main window from the top header
local draggingMain = false
local mainDragStart
local mainStartPosition
local dragInput

local function updateMainDrag(inputObject)
    if not draggingMain or not mainDragStart then return end

    local delta = inputObject.Position - mainDragStart
    main.Position = UDim2.new(
        mainStartPosition.X.Scale,
        mainStartPosition.X.Offset + delta.X,
        mainStartPosition.Y.Scale,
        mainStartPosition.Y.Offset + delta.Y
    )
end

header.InputBegan:Connect(function(obj)
    if obj.UserInputType == Enum.UserInputType.MouseButton1
        or obj.UserInputType == Enum.UserInputType.Touch then
        draggingMain = true
        mainDragStart = obj.Position
        mainStartPosition = main.Position

        obj.Changed:Connect(function()
            if obj.UserInputState == Enum.UserInputState.End then
                draggingMain = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(obj)
    if obj.UserInputType == Enum.UserInputType.MouseMovement
        or obj.UserInputType == Enum.UserInputType.Touch then
        dragInput = obj
    end
end)

UserInputService.InputChanged:Connect(function(obj)
    if draggingMain and (
        obj.UserInputType == Enum.UserInputType.MouseMovement
        or obj == dragInput
    ) then
        updateMainDrag(obj)
    end
end)

-- Tabs
local publicTab = make("TextButton", {
    Position = UDim2.fromOffset(10, 50),
    Size = UDim2.new(0.5, -14, 0, 36),
    BackgroundColor3 = GOLD,
    BorderSizePixel = 0,
    Text = "العام",
    TextColor3 = TEXT,
    Font = Enum.Font.GothamBold,
    TextSize = 15
}, main)
round(publicTab, 9)

local privateTab = make("TextButton", {
    Position = UDim2.new(0.5, 4, 0, 50),
    Size = UDim2.new(0.5, -14, 0, 36),
    BackgroundColor3 = DARK_BUTTON,
    BorderSizePixel = 0,
    Text = "الخاص",
    TextColor3 = TEXT,
    Font = Enum.Font.GothamBold,
    TextSize = 15
}, main)
round(privateTab, 9)

-- Message lists
local function createMessageList(name)
    local list = make("ScrollingFrame", {
        Name = name,
        Position = UDim2.fromOffset(10, 96),
        Size = UDim2.new(1, -20, 1, -165),
        BackgroundColor3 = BLACK,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = GOLD,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, main)
    round(list, 10)

    make("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8)
    }, list)

    make("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, list)

    return list
end

local publicMessages = createMessageList("PublicMessages")
local privateMessages = createMessageList("PrivateMessages")
publicMessages.Visible = true

-- Notifications
local notification = make("TextLabel", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -12, 0, -55),
    Size = UDim2.fromOffset(245, 45),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Text = "",
    TextColor3 = TEXT,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextWrapped = true,
    Visible = true,
    ZIndex = 30
}, gui)
round(notification, 10)
local notificationStroke = outline(notification, GOLD, 1)

local function notify(message)
    if not notificationsEnabled then return end

    noticeId += 1
    local id = noticeId
    notification.Text = message
    notification.Position = UDim2.new(1, -12, 0, -55)

    tween(notification, 0.3, {
        Position = UDim2.new(1, -12, 0, 12)
    })

    task.delay(2.8, function()
        if id == noticeId and notification.Parent then
            tween(notification, 0.25, {
                Position = UDim2.new(1, -12, 0, -55)
            })
        end
    end)
end

-- Message rows
local function addMessage(list, name, message, useRGB)
    local row = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(35, 31, 42),
        BackgroundTransparency = 0.05,
        Size = UDim2.new(1, -2, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    }, list)
    round(row, 8)

    make("UIPadding", {
        PaddingLeft = UDim.new(0, 9),
        PaddingRight = UDim.new(0, 9),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8)
    }, row)

    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        VerticalAlignment = Enum.VerticalAlignment.Top
    }, row)

    local nameLabel = make("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 20),
        Text = name .. ":",
        TextColor3 = GOLD,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextWrapped = true,
        LayoutOrder = 1
    }, row)

    make("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 20),
        Text = message,
        TextColor3 = TEXT,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2
    }, row)

    if useRGB then
        task.spawn(function()
            local localHue = math.random()
            while row.Parent do
                if rgbEnabled and rgbNameEnabled then
                    localHue = (localHue + 0.012) % 1
                    nameLabel.TextColor3 =
                        Color3.fromHSV(localHue, 0.75, 1)
                else
                    nameLabel.TextColor3 = GOLD
                end
                task.wait(0.04)
            end
        end)
    end

    task.defer(function()
        if list.Parent then
            list.CanvasPosition = Vector2.new(
                0, math.max(0, list.AbsoluteCanvasSize.Y)
            )
        end
    end)

    return row
end

local function clearList(list)
    for _, item in ipairs(list:GetChildren()) do
        if item:IsA("Frame") or item:IsA("TextLabel") then
            item:Destroy()
        end
    end
end

-- Local speech bubble
local function showLocalBubble(message)
    if activeBubble then
        activeBubble:Destroy()
        activeBubble = nil
    end

    local character = player.Character
    local head = character and character:FindFirstChild("Head")
    if not head then return end

    local bubble = make("BillboardGui", {
        Name = "NOVA_LocalBubble",
        Adornee = head,
        Size = UDim2.fromOffset(210, 62),
        StudsOffset = Vector3.new(0, 3, 0),
        AlwaysOnTop = true,
        MaxDistance = 45
    }, gui)
    activeBubble = bubble

    local label = make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = PANEL,
        BackgroundTransparency = 0.05,
        Text = message,
        TextColor3 = TEXT,
        TextWrapped = true,
        TextSize = 14,
        Font = Enum.Font.GothamBold
    }, bubble)
    round(label, 12)
    outline(label, accent, 1)

    task.delay(4, function()
        if bubble.Parent then bubble:Destroy() end
    end)
end

-- Input
local input = make("TextBox", {
    Name = "MessageInput",
    Position = UDim2.new(0, 10, 1, -54),
    Size = UDim2.new(1, -145, 0, 42),
    BackgroundColor3 = DARK_BUTTON,
    BorderSizePixel = 0,
    PlaceholderText = "اكتب رسالة أو /help",
    PlaceholderColor3 = MUTED,
    Text = "",
    TextColor3 = TEXT,
    ClearTextOnFocus = false,
    Font = Enum.Font.Gotham,
    TextSize = 15
}, main)
round(input, 9)

local stickerButton = make("TextButton", {
    Position = UDim2.new(1, -128, 1, -54),
    Size = UDim2.fromOffset(68, 42),
    BackgroundColor3 = DARK_BUTTON,
    BorderSizePixel = 0,
    Text = "ملصقات",
    TextColor3 = TEXT,
    TextSize = 11,
    Font = Enum.Font.GothamBold
}, main)
round(stickerButton, 9)

local sendButton = make("TextButton", {
    Position = UDim2.new(1, -48, 1, -54),
    Size = UDim2.fromOffset(38, 42),
    BackgroundColor3 = GOLD,
    BorderSizePixel = 0,
    Text = "➤",
    TextColor3 = BLACK,
    TextSize = 20,
    Font = Enum.Font.GothamBold
}, main)
round(sendButton, 9)

-- Stickers
local stickerPanel = make("Frame", {
    Position = UDim2.new(1, -10, 1, -105),
    AnchorPoint = Vector2.new(1, 1),
    Size = UDim2.fromOffset(230, 148),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 10
}, main)
round(stickerPanel, 10)
outline(stickerPanel, GOLD, 1)

make("TextLabel", {
    Position = UDim2.fromOffset(8, 4),
    Size = UDim2.new(1, -16, 0, 24),
    BackgroundTransparency = 1,
    Text = "ملصقات الصور",
    TextColor3 = TEXT,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    ZIndex = 11
}, stickerPanel)

local stickerGrid = make("Frame", {
    Position = UDim2.fromOffset(7, 31),
    Size = UDim2.new(1, -14, 1, -38),
    BackgroundTransparency = 1,
    ZIndex = 11
}, stickerPanel)

make("UIGridLayout", {
    CellSize = UDim2.fromOffset(62, 49),
    CellPadding = UDim2.fromOffset(6, 5),
    SortOrder = Enum.SortOrder.LayoutOrder
}, stickerGrid)

for i = 1, 6 do
    local sticker = make("TextButton", {
        Name = "Sticker" .. i,
        BackgroundColor3 = DARK_BUTTON,
        BorderSizePixel = 0,
        Text = "ملصق " .. i,
        TextColor3 = GOLD,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        LayoutOrder = i,
        ZIndex = 12
    }, stickerGrid)
    round(sticker, 7)
    sticker.Activated:Connect(function()
        notify("أضف صورة ملصق معتمدة لهذا الزر")
    end)
end

-- Settings panel
local settingsPanel = make("Frame", {
    Position = UDim2.new(0, 12, 0, 54),
    Size = UDim2.fromOffset(250, 235),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 40
}, gui)
round(settingsPanel, 12)
outline(settingsPanel, GOLD, 2)

make("TextLabel", {
    Position = UDim2.fromOffset(10, 5),
    Size = UDim2.new(1, -20, 0, 25),
    BackgroundTransparency = 1,
    Text = "إعدادات NOVA",
    TextColor3 = GOLD,
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    ZIndex = 41
}, settingsPanel)

local nameInput = make("TextBox", {
    Position = UDim2.fromOffset(10, 36),
    Size = UDim2.new(1, -20, 0, 34),
    BackgroundColor3 = BLACK,
    BorderSizePixel = 0,
    PlaceholderText = "اسم العرض",
    Text = displayName,
    TextColor3 = TEXT,
    ClearTextOnFocus = false,
    Font = Enum.Font.Gotham,
    TextSize = 14,
    ZIndex = 41
}, settingsPanel)
round(nameInput, 7)

local function settingButton(text, y)
    local button = make("TextButton", {
        Position = UDim2.fromOffset(10, y),
        Size = UDim2.new(1, -20, 0, 32),
        BackgroundColor3 = GOLD,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = BLACK,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        ZIndex = 41
    }, settingsPanel)
    round(button, 7)
    return button
end

local saveName = settingButton("حفظ اسم العرض", 77)
local rgbButton = settingButton("RGB: OFF", 115)
local noticeButton = settingButton("الإشعارات: ON", 153)
local serverButton = settingButton("تغيير السيرفر", 191)

-- Floating toggle
local toggle = make("TextButton", {
    Name = "ToggleChat",
    Position = UDim2.new(0, 18, 0.76, 0),
    Size = UDim2.fromOffset(58, 58),
    BackgroundColor3 = GOLD,
    BorderSizePixel = 0,
    Text = "N",
    TextColor3 = BLACK,
    TextSize = 24,
    Font = Enum.Font.GothamBold,
    Visible = false
}, gui)
round(toggle, 18)
outline(toggle, GOLD, 2)

-- Theme
local function applyTheme()
    accent = rgbEnabled and Color3.fromHSV(hue, 0.8, 1) or GOLD

    mainStroke.Color = accent
    header.TextColor3 = accent
    ownerLabel.TextColor3 = accent
    toggle.BackgroundColor3 = accent
    notificationStroke.Color = accent

    rgbButton.Text = rgbEnabled and "RGB: ON" or "RGB: OFF"
    noticeButton.Text = notificationsEnabled
        and "الإشعارات: ON" or "الإشعارات: OFF"

    rgbButton.BackgroundColor3 = accent
    saveName.BackgroundColor3 = accent
    noticeButton.BackgroundColor3 = accent
    serverButton.BackgroundColor3 = accent
    sendButton.BackgroundColor3 = accent
    stickerButton.TextColor3 = accent
    settingsButton.TextColor3 = accent
    publicTab.BackgroundColor3 =
        currentTab == "عام" and accent or DARK_BUTTON
    privateTab.BackgroundColor3 =
        currentTab == "خاص" and accent or DARK_BUTTON
end

saveName.Activated:Connect(function()
    local value = nameInput.Text:match("^%s*(.-)%s*$")
    if not value or value == "" then
        notify("اكتب اسمًا أولًا")
        return
    end
    displayName = value:sub(1, 24)
    notify("تغير الاسم داخل واجهة NOVA فقط")
end)

rgbButton.Activated:Connect(function()
    rgbEnabled = not rgbEnabled
    applyTheme()
    notify(rgbEnabled and "تم تشغيل RGB للواجهة 🌈"
        or "رجع الوضع الأسود والذهبي 🖤")
end)

noticeButton.Activated:Connect(function()
    notificationsEnabled = not notificationsEnabled
    applyTheme()
    if notificationsEnabled then
        notify("تم تشغيل الإشعارات")
    end
end)

serverButton.Activated:Connect(function()
    notify("تغيير السيرفر يحتاج وجهة Roblox مسموحة")
end)

settingsButton.Activated:Connect(function()
    settingsPanel.Visible = not settingsPanel.Visible
    if settingsPanel.Visible then
        stickerPanel.Visible = false
    end
end)

stickerButton.Activated:Connect(function()
    stickerPanel.Visible = not stickerPanel.Visible
    if stickerPanel.Visible then
        settingsPanel.Visible = false
    end
end)

-- Tab switching
local function selectTab(tab)
    currentTab = tab
    publicMessages.Visible = (tab == "عام")
    privateMessages.Visible = (tab == "خاص")
    settingsPanel.Visible = false
    stickerPanel.Visible = false
    applyTheme()
end

publicTab.Activated:Connect(function()
    selectTab("عام")
end)

privateTab.Activated:Connect(function()
    selectTab("خاص")
end)

-- Commands
local function sendMessage()
    local message = input.Text
    if message:gsub("%s", "") == "" then return end

    local command, rest = message:match("^(%S+)%s*(.*)$")
    command = command and string.lower(command) or ""

    if command == "/help" then
        notify("/rgbname | /name اسم | /clear")
        input.Text = ""
        return
    elseif command == "/rgbname" then
        rgbNameEnabled = not rgbNameEnabled
        notify(rgbNameEnabled and "RGB للاسم: ON" or "RGB للاسم: OFF")
        input.Text = ""
        return
    elseif command == "/name" then
        local value = (rest or ""):match("^%s*(.-)%s*$")
        if value and value ~= "" then
            displayName = value:sub(1, 24)
            nameInput.Text = displayName
            notify("تم تغيير الاسم داخل الواجهة")
        else
            notify("اكتب الاسم بعد /name")
        end
        input.Text = ""
        return
    elseif command == "/clear" then
        clearList(currentTab == "عام" and publicMessages or privateMessages)
        notify("تم مسح الرسائل الظاهرة")
        input.Text = ""
        return
    end

    -- Local preview only; not sent to other players.
    local list = currentTab == "عام" and publicMessages or privateMessages
    addMessage(list, displayName, message, rgbNameEnabled)
    showLocalBubble(message)

    input.Text = ""
    stickerPanel.Visible = false
end

sendButton.Activated:Connect(sendMessage)
input.FocusLost:Connect(function(enterPressed)
    if enterPressed then sendMessage() end
end)

-- Open/close
local originalPosition = main.Position

local function openChat()
    if busy or opened then return end
    busy = true
    opened = true
    main.Visible = true
    main.Position = UDim2.new(0, -main.AbsoluteSize.X - 20, 0.5, 0)
    toggle.Visible = false

    tween(main, 0.35, {Position = originalPosition}).Completed:Connect(function()
        busy = false
    end)
end

local function closeChat()
    if busy or not opened then return end
    busy = true
    opened = false
    settingsPanel.Visible = false
    stickerPanel.Visible = false

    tween(main, 0.3, {
        Position = UDim2.new(0, -main.AbsoluteSize.X - 20, 0.5, 0)
    }).Completed:Connect(function()
        main.Visible = false
        toggle.Visible = true
        busy = false
    end)
end

closeButton.Activated:Connect(closeChat)
toggle.Activated:Connect(openChat)

-- Drag floating icon
local dragging = false
local dragStart
local buttonStart

toggle.InputBegan:Connect(function(obj)
    if obj.UserInputType == Enum.UserInputType.MouseButton1
        or obj.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = obj.Position
        buttonStart = toggle.Position
    end
end)

UserInputService.InputChanged:Connect(function(obj)
    if not dragging then return end

    if obj.UserInputType == Enum.UserInputType.MouseMovement
        or obj.UserInputType == Enum.UserInputType.Touch then
        local delta = obj.Position - dragStart
        toggle.Position = UDim2.new(
            buttonStart.X.Scale, buttonStart.X.Offset + delta.X,
            buttonStart.Y.Scale, buttonStart.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(obj)
    if obj.UserInputType == Enum.UserInputType.MouseButton1
        or obj.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Responsive layout
local function resize()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local viewport = camera.ViewportSize
    if viewport.X < 600 then
        local width = math.max(260, math.min(viewport.X - 24, 390))
        local height = math.max(300, math.min(430, viewport.Y - 50))
        main.Size = UDim2.fromOffset(width, height)
        toggle.Size = UDim2.fromOffset(60, 60)
    else
        main.Size = UDim2.fromOffset(365, 430)
        toggle.Size = UDim2.fromOffset(58, 58)
    end
end

resize()

local function connectCamera()
    local camera = workspace.CurrentCamera
    if camera then
        camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
    end
end

connectCamera()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.defer(connectCamera)
    task.defer(resize)
end)

-- RGB animation
task.spawn(function()
    while gui.Parent do
        if rgbEnabled then
            hue = (hue + 0.003) % 1
            applyTheme()
        end
        task.wait(0.04)
    end
end)

applyTheme()
notify("مرحبًا بك في NOVA CHAT ✨")

task.delay(3.2, function()
    notify("صنع من قبل ربيع | Rabee1258")
end)

addMessage(publicMessages, "NOVA", "تم تشغيل الواجهة.", false)
