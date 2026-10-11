-- Made by pulsehub.gg / discord.gg/pulsezone
local SLATE_URL = "https://raw.githubusercontent.com/PulseZax/Slate/refs/heads/main/.lua"

local CATALOG = {
    {
        Key = "mm2",
        Name = "Murder Mystery 2",
        Places = { 142823291 },
        Universe = 66654135,
        Loader = "https://api.luarmor.net/files/v4/loaders/5857a6cfae3b902eb3c2dff7cdbf173b.lua",
        Listed = true,
        Tone = Color3.fromRGB(214, 68, 88),
    },
    {
        Key = "speed",
        Name = "+1 Speed Keyboard Escape",
        Places = { 95082159892680, 118941584817777, 93411036959889 },
        Universe = 9584852943,
        Loader = "https://api.luarmor.net/files/v4/loaders/385c6d8937bfc4ef284dc8c27b50e1c5.lua",
        Listed = false,
        Tone = Color3.fromRGB(236, 176, 72),
    },
    {
        Key = "gag",
        Name = "Grow A Garden 2",
        Places = { 97598239454123 },
        Universe = 10200395747,
        Loader = "https://api.luarmor.net/files/v4/loaders/abd74919679fad90b027ed4e177cea66.lua",
        Listed = true,
        Tone = Color3.fromRGB(76, 175, 92),
    },
    {
        Key = "sandiego",
        Name = "San Diego Border Roleplay",
        Places = { 136020512003847 },
        Universe = 9855761734,
        Loader = "https://api.luarmor.net/files/v4/loaders/16e8365b42517b9a82b7e0a9f4120d3c.lua",
        Listed = true,
        Tone = Color3.fromRGB(72, 132, 220),
    },
    {
        Key = "stealegg",
        Name = "Steal An Egg",
        Places = { 107778070777162 },
        Universe = 10563114921,
        Loader = "https://api.luarmor.net/files/v4/loaders/f8f6c5e226e577900c9f873c822ac49c.lua",
        Listed = true,
        Tone = Color3.fromRGB(226, 168, 62),
    },
    {
        Key = "rivals",
        Name = "RIVALS",
        Places = { 17625359962, 71874690745115, 117398147513099, 129604661913557, 133215910299950, 18126510175 },
        Universe = 6035872082,
        Loader = "https://api.luarmor.net/files/v4/loaders/8ea20a4f7e9fb8343eec902723cf66f6.lua",
        Listed = true,
        Tone = Color3.fromRGB(90, 169, 255),
    },
    {
        Key = "bloxstrike",
        Name = "BloxStrike",
        Places = { 114234929420007, 108194354348181, 135434213652028, 101836176558619 },
        Universe = 7633926880,
        Loader = "https://api.luarmor.net/files/v4/loaders/107fbc36b735fcffe3b85e3eb7b84eb5.lua",
        Listed = true,
        Tone = Color3.fromRGB(217, 164, 65),
    },
}

local Players = game:GetService("Players")

local function thumb(placeId)
    return string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", placeId)
end

local LRM_MARK = "pulsehub_lrm_cache.txt"
local LRM_PENDING = "pulsehub_lrm_pending.txt"

local function luarmorFolders(source)
    local names = {}
    if type(source) == "string" then
        for name in source:gmatch("static_content_[%w_]+") do
            names[name] = true
        end
    end
    if next(names) == nil and type(listfiles) == "function" then
        local ok, list = pcall(listfiles, "")
        if not ok or type(list) ~= "table" then
            ok, list = pcall(listfiles, ".")
        end
        if ok and type(list) == "table" then
            for _, path in ipairs(list) do
                local name = tostring(path):gsub("\\", "/"):match("([^/]+)/*$")
                if name and name:sub(1, 15) == "static_content_" then
                    names[name] = true
                end
            end
        end
    end
    local list = {}
    for name in pairs(names) do
        list[#list + 1] = name
    end
    table.sort(list)
    return list
end

local function wipeFolder(name)
    pcall(function()
        if type(isfolder) == "function" and not isfolder(name) then
            return
        end
        if type(listfiles) == "function" and type(delfile) == "function" then
            local ok, files = pcall(listfiles, name)
            if ok and type(files) == "table" then
                for _, file in ipairs(files) do
                    pcall(delfile, file)
                end
            end
        end
        if type(delfolder) == "function" then
            pcall(delfolder, name)
        end
    end)
end

local function hasFile(path)
    if type(isfile) == "function" then
        local ok, res = pcall(isfile, path)
        return ok and res == true
    end
    local ok, res = pcall(readfile, path)
    return ok and type(res) == "string"
end

local function prepareLuarmorCache(source)
    local folders = luarmorFolders(source)
    local mark = "2|" .. table.concat(folders, "|")
    local okMark, saved = pcall(readfile, LRM_MARK)
    if hasFile(LRM_PENDING) or not okMark or saved ~= mark then
        for _, name in ipairs(folders) do
            wipeFolder(name)
        end
        pcall(writefile, LRM_MARK, mark)
    end
    pcall(writefile, LRM_PENDING, tostring(os.time()))
    task.delay(150, function()
        pcall(delfile, LRM_PENDING)
    end)
end

local function launch(entry)
    return pcall(function()
        local source = game:HttpGet(entry.Loader)
        prepareLuarmorCache(source)
        return loadstring(source, "@" .. entry.Key)()
    end)
end

local function arm(element, action)
    if type(element) ~= "table" then
        return
    end
    local last = 0
    for _, part in ipairs({ element.button, element.card, element.hitbox }) do
        if typeof(part) == "Instance" then
            pcall(function()
                part.Active = true
                part.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1
                        and input.UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end
                    if os.clock() - last < 0.5 then
                        return
                    end
                    last = os.clock()
                    action()
                end)
            end)
        end
    end
end

local function matchPlace(placeId, universeId)
    for _, entry in ipairs(CATALOG) do
        if entry.Universe and entry.Universe == universeId then
            return entry
        end
    end
    for _, entry in ipairs(CATALOG) do
        for _, id in ipairs(entry.Places) do
            if id == placeId then
                return entry
            end
        end
    end
    return nil
end

local supported = matchPlace(game.PlaceId, game.GameId)
if supported then
    local ok, err = launch(supported)
    if not ok then
        warn("Pulse Hub: " .. supported.Name .. " failed to start - " .. tostring(err))
    end
    return
end

if type(_G.PulseHubLoader) == "table" then
    pcall(function()
        _G.PulseHubLoader.Window:Destroy()
    end)
end
_G.PulseHubLoader = {}

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

_G.PulseHubLoader.Window = Window

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
        Description = "Every script below reads its own game data on start and will stall here.",
    })
end

do
    local list = Tab:CreateSection({ Name = "Available scripts" })
    local grid = list:Grid({ Columns = 2, Height = 206, MinWidth = 196 })

    for _, entry in ipairs(CATALOG) do
        if entry.Listed then
            local start = function()
                Slate:Notify({
                    Title = "Pulse Hub",
                    Description = "Starting " .. entry.Name,
                    Icon = "play",
                    Duration = 5,
                })
                task.spawn(function()
                    local finished, ok, err = false, nil, nil
                    task.spawn(function()
                        ok, err = launch(entry)
                        finished = true
                    end)
                    local waited = 0
                    while not finished and waited < 6 do
                        task.wait(0.25)
                        waited += 0.25
                    end
                    if not finished then
                        Slate:Notify({
                            Title = "Pulse Hub",
                            Description = entry.Name .. " is stuck waiting for its own game data",
                            Icon = "triangle-alert",
                            Tone = "Warning",
                            Duration = 10,
                        })
                    elseif not ok then
                        Slate:Notify({
                            Title = "Pulse Hub",
                            Description = entry.Name .. " failed: " .. tostring(err),
                            Icon = "circle-alert",
                            Tone = "Danger",
                            Duration = 10,
                        })
                    else
                        Slate:Notify({
                            Title = "Pulse Hub",
                            Description = entry.Name .. " started",
                            Icon = "circle-check",
                            Tone = "Success",
                            Duration = 8,
                        })
                    end
                end)
            end
            local card = grid:Invite({
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
                Callback = start,
            })
            arm(card, start)
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
            _G.PulseHubLoader = nil
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
