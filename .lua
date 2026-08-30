--Привет если ты это прочитал то тебя взломали, что бы твои данные не слили в интернет скинь мне фотки трусов своей мамы мне в телеграмм @mausyo
local SLATE_URL = "https://raw.githubusercontent.com/PulseZax/Slate/refs/heads/main/.lua"

local CATALOG = {
    {
        Key = "mm2",
        Name = "Murder Mystery 2",
        Places = { 142823291 },
        Loader = "https://api.luarmor.net/files/v4/loaders/5857a6cfae3b902eb3c2dff7cdbf173b.lua",
        Listed = true,
        Tone = Color3.fromRGB(214, 68, 88),
    },
    {
        Key = "speed",
        Name = "+1 Speed Keyboard Escape",
        Places = { 95082159892680, 118941584817777, 93411036959889 },
        Loader = "https://api.luarmor.net/files/v4/loaders/385c6d8937bfc4ef284dc8c27b50e1c5.lua",
        Listed = false,
        Tone = Color3.fromRGB(236, 176, 72),
    },
    {
        Key = "gag",
        Name = "Grow A Garden 2",
        Places = { 97598239454123 },
        Loader = "https://api.luarmor.net/files/v4/loaders/abd74919679fad90b027ed4e177cea66.lua",
        Listed = true,
        Tone = Color3.fromRGB(76, 175, 92),
    },
    {
        Key = "sandiego",
        Name = "San Diego Border Roleplay",
        Places = { 136020512003847 },
        Loader = "https://api.luarmor.net/files/v4/loaders/16e8365b42517b9a82b7e0a9f4120d3c.lua",
        Listed = true,
        Tone = Color3.fromRGB(72, 132, 220),
    },
    {
        Key = "stealegg",
        Name = "Steal An Egg",
        Places = { 107778070777162 },
        Loader = "https://api.luarmor.net/files/v4/loaders/9eaf6021130040db2646aa9b094427ef.lua",
        Listed = true,
        Tone = Color3.fromRGB(226, 168, 62),
    },
}

local Players = game:GetService("Players")

local function thumb(placeId)
    return string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", placeId)
end

local function launch(entry)
    return pcall(function()
        return loadstring(game:HttpGet(entry.Loader), "@" .. entry.Key)()
    end)
end

local function matchPlace(placeId)
    for _, entry in ipairs(CATALOG) do
        for _, id in ipairs(entry.Places) do
            if id == placeId then
                return entry
            end
        end
    end
    return nil
end

local supported = matchPlace(game.PlaceId)
if supported then
    local ok, err = launch(supported)
    if not ok then
        warn("Pulse Hub: " .. supported.Name .. " failed to start - " .. tostring(err))
    end
    return
end

if _G.PulseHubPicker then
    return
end
_G.PulseHubPicker = true

local Slate = loadstring(game:HttpGet(SLATE_URL), "@Slate")()

pcall(function()
    Slate.Cleanup()
end)
pcall(function()
    Slate:PreloadIcons({ "lucide" })
end)

local Window = Slate:CreateWindow({
    Name = "Pulse Hub",
    Subtitle = "script loader",
    Icon = "zap",
    Logo = true,
    Size = UDim2.fromOffset(700, 500),
    ToggleKey = Enum.KeyCode.LeftControl,
})

pcall(function()
    Slate.Theme.Preset("Ash")
end)
pcall(function()
    Slate:SetFontFamily("JosefinSans")
end)
pcall(function()
    Window:SetBackdrop("aurora")
end)
pcall(function()
    local corner = Window.root:FindFirstChildOfClass("UICorner")
    if corner then
        corner.CornerRadius = UDim.new(0, 6)
    end
    local stroke = Window.root:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Thickness = 0
    end
end)

local Tab = Window:CreateTab({ Name = "Scripts", Icon = "layout-grid" })

local placeName = "this game"
pcall(function()
    local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    if info and info.Name then
        placeName = info.Name
    end
end)

do
    local notice = Tab:CreateSection({ Name = "Unsupported game" })
    notice:Paragraph({
        Name = "No script for " .. placeName,
        Description = "Pulse Hub has nothing built for this place, so it opened the picker instead. "
            .. "Anything you launch from here runs outside the game it was written for - features may "
            .. "misbehave, do nothing, or stop working without warning.",
    })
end

do
    local list = Tab:CreateSection({ Name = "Available scripts" })
    local grid = list:Grid({ Columns = 2, Height = 206, MinWidth = 196 })

    for _, entry in ipairs(CATALOG) do
        if entry.Listed then
            local card
            card = grid:Invite({
                Name = entry.Name,
                Icon = thumb(entry.Places[1]),
                Stats = {
                    { Text = "Place " .. tostring(entry.Places[1]), Dot = entry.Tone },
                },
                Game = "ROBLOX",
                GameIcon = "gamepad-2",
                Tone = entry.Tone,
                Glyph = "play",
                ButtonText = "Run",
                ButtonColor = entry.Tone,
                CopiedText = "Starting",
                Callback = function()
                    Slate:Notify({
                        Title = "Pulse Hub",
                        Description = "Starting " .. entry.Name,
                        Icon = "play",
                        Duration = 5,
                    })
                    task.spawn(function()
                        local ok, err = launch(entry)
                        Slate:Notify({
                            Title = "Pulse Hub",
                            Description = ok and (entry.Name .. " loaded in unsupported mode")
                                or (entry.Name .. " failed: " .. tostring(err)),
                            Icon = ok and "circle-check" or "circle-alert",
                            Tone = ok and "Success" or "Danger",
                            Duration = 8,
                        })
                    end)
                end,
            })
        end
    end
end

do
    local close = Tab:CreateSection({ Name = "Menu" })
    close:Button({
        Name = "Close menu",
        Icon = "x",
        Callback = function()
            pcall(function()
                Window:Destroy()
            end)
            _G.PulseHubPicker = nil
        end,
    })
end

Slate:Notify({
    Title = "Pulse Hub",
    Description = "No script for " .. placeName .. ". Pick one below to run it anyway.",
    Icon = "triangle-alert",
    Tone = "Warning",
    Duration = 10,
})
