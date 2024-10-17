 --// SERVICES
        local PLAYERS = game:GetService("Players")
        local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
        local SCRIPT_CONTEXT = game:GetService("ScriptContext")

        --// VARIABLES
        local PLAYER = PLAYERS.LocalPlayer
        local CHAR = PLAYER.Character
        local ROOT = CHAR.PrimaryPart
        local HUM = CHAR.Humanoid
        local CAMERA = workspace.CurrentCamera

        local BALLS = {}

        --// ADD BALLS
        for i,v in pairs (workspace:GetDescendants()) do
            if (v.Name == "Basketball" and v:IsA("Tool")) then
                table.insert(BALLS, v)
            end
        end

        workspace.DescendantAdded:Connect(function(d)
            if (d.Name == "Basketball" and d:IsA("Tool") and PLAYERS:GetPlayerFromCharacter(d.Parent)) then
                table.insert(BALLS, d)
            elseif (d.Name == "Basketball" and d:IsA("Tool")) then
                table.insert(BALLS, d)
            end
        end)
        workspace.DescendantRemoving:Connect(function(d)
            if (d.Name == "Basketball" and d:IsA("Tool") and PLAYERS:GetPlayerFromCharacter(d.Parent)) then
                for i,v in pairs (BALLS) do
                    if (v == d) then
                        table.remove(BALLS, i)
                    end
                end
            elseif (d.Name == "Basketball" and d:IsA("Tool")) then
                for i,v in pairs (BALLS) do
                    if (v == d) then
                        table.remove(BALLS, i)
                    end
                end
            end
        end)

        local IN_RANGE_UI = Instance.new("ScreenGui")
        IN_RANGE_UI.Parent = game:GetService("CoreGui")
        IN_RANGE_UI.Enabled = true
        IN_RANGE_UI.IgnoreGuiInset = true

        local MAIN_FRAME = Instance.new("Frame", IN_RANGE_UI)
        MAIN_FRAME.Name = "Main"
        MAIN_FRAME.BackgroundColor3 = Color3.fromRGB(13,13,13)
        MAIN_FRAME.BorderSizePixel = 0
        MAIN_FRAME.AnchorPoint = Vector2.new(0.5, 0)
        MAIN_FRAME.Position = UDim2.new(0.5,0,0,0)
        MAIN_FRAME.Size = UDim2.new(0.112, 0, 0.037, 0)

        local IN_RANGE = Instance.new("TextLabel", MAIN_FRAME)
        IN_RANGE.Text = "NOT IN RANGE"
        IN_RANGE.TextColor3 = Color3.new(1,0,0)
        IN_RANGE.Position = UDim2.new(0.5,0,0.5,0)
        IN_RANGE.BackgroundTransparency = 1
        IN_RANGE.Size = UDim2.new(1,0,1,0)
        IN_RANGE.AnchorPoint = Vector2.new(0.5, 0.5)
        IN_RANGE.TextScaled = true
        IN_RANGE.Font = Enum.Font.SourceSansBold

        local GOAL_NAMES = {'FieldGoal','FieldGoalAway','FieldGoalHome'}
        local GOALS = {}

        local DEFENSE_CIRCLE = Drawing.new("Circle")
        DEFENSE_CIRCLE.Radius = 70
        DEFENSE_CIRCLE.Visible = false
        DEFENSE_CIRCLE.NumSides = 100
        DEFENSE_CIRCLE.Filled = false
        DEFENSE_CIRCLE.Thickness = 2

        for i,v in pairs(workspace:GetDescendants()) do
            if table.find(GOAL_NAMES, v.Name) and v:IsA("Part") then
                table.insert(GOALS, v)
            end
        end

        getgenv().FLAGS = {
            WALKSPEED = 0,
            WALKSPEED_ON = false,
        }
        local TELEPORTS = {
            PRACTICE = CFrame.new(392.587524, 55.5888443, -971.261475, 0.999916852, -4.9409401e-09, 0.0128930854, 4.95773911e-09, 1, -1.27099808e-09, -0.0128930854, 1.33481304e-09, 0.999916852),
            SPAWN = CFrame.new(391.798706, 41.8911438, -740.281555, -0.990407765, 0.000326213485, -0.138175085, -2.92406207e-06, 0.999997139, 0.00238179928, 0.138175458, 0.00235935627, -0.990404963),
            CITY = CFrame.new(120.548203, 57.8781815, -736.873474, -0.01078171, -0.00447023148, 0.999931872, -1.44455726e-05, 0.999989986, 0.00447033579, -0.999941885, 3.37529891e-05, -0.0107816672),
            TOWN = CFrame.new(390.760529, 55.5743713, -506.967957, -0.99999994, -1.91453e-05, 0.000470968895, -1.69260493e-05, 0.999989092, 0.00466914522, -0.000471052714, 0.00466913683, -0.999989033)
        }

        --// AVOID CRASHING
        SCRIPT_CONTEXT:SetTimeout(0)

        --// METAMETHODS
        local CONNECTIONS = {}; CONNECTIONS.__index = CONNECTIONS
        local self = setmetatable({}, CONNECTIONS)

        --// LOGGING CONNECTIONS
        for _, v in pairs (CHAR:GetChildren()) do

            if (v:IsA("BasePart") and v.Name:lower():find('arm')) then

                for _, l in pairs (getconnections(v:GetPropertyChangedSignal("Size"))) do
                    table.insert(CONNECTIONS, l)
                end
            elseif (v:IsA("Humanoid")) then
                for _, l in pairs (getconnections(v:GetPropertyChangedSignal("WalkSpeed"))) do
                    table.insert(CONNECTIONS, l)
                end
            end
        end

        --// DISCONNECT ALL CONNECTIONS
        for _, l in pairs (CONNECTIONS) do

            local FAKE_CONNECTION = workspace.Changed:Connect(function()
            end)
            
            pcall(function()
                l:Disable()
            end)
        end

        --// FUNCTIONS
        local function GET_BALL()
            local MAX, BALL = getgenv().FLAGS.BALL_REACH_DISTANCE, nil

            for i,v in pairs (BALLS) do
                local DISTANCE = (v.Ball.Position - ROOT.Position).magnitude

                if (DISTANCE < MAX) then
                    MAX = DISTANCE
                    BALL = v.Ball
                end
            end

            return BALL
        end

        --// LIBRARY
        local LIBRARY = loadstring(game:HttpGet("https://raw.githubusercontent.com/itsUnseen/UI-Libraries/main/test.lua"))()
        LIBRARY = getgenv().library

        local HOOPZ_TAB = LIBRARY:AddTab("Hoopz", 250)
        local LEFT_COLUMN, RIGHT_COLUMN = HOOPZ_TAB:AddColumn(), HOOPZ_TAB:AddColumn()
        local PLAYER_SECTION = LEFT_COLUMN:AddSection("Player")
        local AIMBOT_SECTION = RIGHT_COLUMN:AddSection("Aimbot")
        local TP_SECTION = RIGHT_COLUMN:AddSection("Teleport")
        local BASKETBALL_SECTION = LEFT_COLUMN:AddSection("Basketball")
        local DEFENSE_SECTION = LEFT_COLUMN:AddSection("Defense")

        local AUTO_DEFENSE = DEFENSE_SECTION:AddBind({text = "Auto Defense", mode = "hold", nomouse = false, noflag = true, key = "G", callback = function(...)
            local d = {...}
            d = d[1]
            getgenv().FLAGS.AUTO_DEFENSE = d
        end})

        local ANTI_TRAVEL = BASKETBALL_SECTION:AddToggle({text = "Anti Travel", value = false, callback = function(d)
            getgenv().FLAGS.ANTI_TRAVEL = d
        end})
        local BALL_REACH = BASKETBALL_SECTION:AddToggle({text = 'Ball Reach', value = false, callback = function (d)
            getgenv().FLAGS.BALL_REACH = d
        end})
        local REACH_DISTANCE = BALL_REACH:AddSlider({value = 1, min = 1, max = 30, callback = function (d)
            getgenv().FLAGS.BALL_REACH_DISTANCE = d
        end})

        local WS_BUTTON = PLAYER_SECTION:AddToggle({text = "Walkspeed", value = false, callback = function(d)
            getgenv().FLAGS.WALKSPEED_ON = d
        end})
        local WALKSPEED = WS_BUTTON:AddSlider({min = 16, max = 100, value = 16, callback = function(d)
            getgenv().FLAGS.WALKSPEED = d
        end})
        local JP_BUTTON = PLAYER_SECTION:AddToggle({text = "Jump Power", value = false, callback = function(d)
            getgenv().FLAGS.JUMPPOWER_ON = d
        end})
        local JP = JP_BUTTON:AddSlider({min = 50, max = 150, value = 50, callback = function(d)
            getgenv().FLAGS.JUMPPOWER = d
        end})

        local AIMBOT = AIMBOT_SECTION:AddBind({text = "Aimbot", noflag = true, nomouse = true, key = "X", callback = function()
            getgenv().FLAGS.AIMBOT = not getgenv().FLAGS.AIMBOT
        end})
        local AUTO_POWER = AIMBOT_SECTION:AddToggle({text = "Auto Power", value = false, callback = function(d)
            getgenv().FLAGS.AUTOPOWER = d
        end})
        local AUTO_POWER = AIMBOT_SECTION:AddToggle({text = "In Range Indicator", value = false, callback = function(d)
            getgenv().FLAGS.IN_RANGE = d
        end})

        local WORLD_TELEPORT = TP_SECTION:AddLabel("-- World Teleports --")
        local SPAWN_TELEPORT = TP_SECTION:AddButton({text = "Spawn", callback = function()
            CHAR:SetPrimaryPartCFrame(TELEPORTS.SPAWN)
        end})
        local TOWN_TELEPORT = TP_SECTION:AddButton({text = "Town", callback = function()
            CHAR:SetPrimaryPartCFrame(TELEPORTS.TOWN)
        end})
        local CITY_TELEPORT = TP_SECTION:AddButton({text = "City", callback = function()
            CHAR:SetPrimaryPartCFrame(TELEPORTS.CITY)
        end})
        local PRACTICE_TELEPORT = TP_SECTION:AddButton({text = "Practice", callback = function()
            CHAR:SetPrimaryPartCFrame(TELEPORTS.PRACTICE)
        end})
        local PLAYER_TELEPORT = TP_SECTION:AddList({text = "Player Teleport", values = PLAYERS:GetPlayers(), value = PLAYERS:GetPlayers()[1], callback = function(d)
            local p = PLAYERS:FindFirstChild(d)

            CHAR:SetPrimaryPartCFrame(p.Character:GetPrimaryPartCFrame())
        end})

        --// FUNCTIONS
        local function GET_CLOSEST_GOAL()
            local G,M = nil,math.huge

            for i,v in pairs(GOALS) do
                local MAG = (ROOT.Position - v.Position).Magnitude
                if MAG < M then
                    M = MAG
                    G = v
                end
            end

            return G
        end

        local function LERP(NUM, END_NUM, T, D)
            return NUM + (END_NUM - NUM) * (T / (D or 100) )
        end

        --// SETTINGS
        do
            LIBRARY.SettingsTab=LIBRARY:AddTab("Settings",100)LIBRARY.SettingsColumn=LIBRARY.SettingsTab:AddColumn()LIBRARY.SettingsColumn1=LIBRARY.SettingsTab:AddColumn()LIBRARY.SettingsMain=LIBRARY.SettingsColumn:AddSection"Main"LIBRARY.SettingsMain:AddButton({text="Unload Cheat",nomouse=true,callback=function()LIBRARY:Unload()getgenv().uwuware=nil end})LIBRARY.SettingsMain:AddBind({text="Panic Key",callback=LIBRARY.options["Unload Cheat"].callback})LIBRARY.SettingsMenu=LIBRARY.SettingsColumn:AddSection"Menu"LIBRARY.SettingsMenu:AddBind({text="Open / Close",flag="UI Toggle",nomouse=true,key="LeftAlt",callback=function()LIBRARY:Close()end})LIBRARY.SettingsMenu:AddColor({text="Accent Color",flag="Menu Accent Color",color=Color3.fromRGB(255,65,65),callback=function(a)if LIBRARY.currentTab then LIBRARY.currentTab.button.TextColor3=a end;for b,c in next,LIBRARY.theme do c[c.ClassName=="TextLabel"and"TextColor3"or c.ClassName=="ImageLabel"and"ImageColor3"or"BackgroundColor3"]=a end end})local d={["Floral"]=5553946656,["Flowers"]=6071575925,["Circles"]=6071579801,["Hearts"]=6073763717,["Polka dots"]=6214418014,["Mountains"]=6214412460,["Zigzag"]=6214416834,["Zigzag 2"]=6214375242,["Tartan"]=6214404863,["Roses"]=6214374619,["Hexagons"]=6214320051,["Leopard print"]=6214318622}LIBRARY.SettingsMenu:AddList({text="Background",flag="UI Background",max=6,values={"Floral","Flowers","Circles","Hearts","Polka dots","Mountains","Zigzag","Zigzag 2","Tartan","Roses","Hexagons","Leopard print"},callback=function(e)if d[e]then LIBRARY.main.Image="rbxassetid://"..d[e]end end}):AddColor({flag="Menu Background Color",color=Color3.new(),callback=function(a)LIBRARY.main.ImageColor3=a end,trans=1,calltrans=function(e)LIBRARY.main.ImageTransparency=1-e end})LIBRARY.SettingsMenu:AddSlider({text="Tile Size",value=90,min=50,max=500,callback=function(e)LIBRARY.main.TileSize=UDim2.new(0,e,0,e)end})LIBRARY.ConfigSection=LIBRARY.SettingsColumn1:AddSection"Configs"LIBRARY.ConfigSection:AddBox({text="Config Name",skipflag=true})LIBRARY.ConfigSection:AddButton({text="Create",callback=function()LIBRARY:GetConfigs()writefile(LIBRARY.foldername.."/"..LIBRARY.flags["Config Name"]..LIBRARY.fileext,"{}")LIBRARY.options["Config List"]:AddValue(LIBRARY.flags["Config Name"])end})LIBRARY.ConfigWarning=LIBRARY:AddWarning({type="confirm"})LIBRARY.ConfigSection:AddList({text="Configs",skipflag=true,value="",flag="Config List",values=LIBRARY:GetConfigs()})LIBRARY.ConfigSection:AddButton({text="Save",callback=function()local f,g,h=LIBRARY.round(LIBRARY.flags["Menu Accent Color"])LIBRARY.ConfigWarning.text="Are you sure you want to save the current settings to config <font color='rgb("..f..","..g..","..h..")'>"..LIBRARY.flags["Config List"].."</font>?"if LIBRARY.ConfigWarning:Show()then LIBRARY:SaveConfig(LIBRARY.flags["Config List"])end end})LIBRARY.ConfigSection:AddButton({text="Load",callback=function()local f,g,h=LIBRARY.round(LIBRARY.flags["Menu Accent Color"])LIBRARY.ConfigWarning.text="Are you sure you want to load config <font color='rgb("..f..","..g..","..h..")'>"..LIBRARY.flags["Config List"].."</font>?"if LIBRARY.ConfigWarning:Show()then LIBRARY:LoadConfig(LIBRARY.flags["Config List"])end end})LIBRARY.ConfigSection:AddButton({text="Delete",callback=function()local f,g,h=LIBRARY.round(LIBRARY.flags["Menu Accent Color"])LIBRARY.ConfigWarning.text="Are you sure you want to delete config <font color='rgb("..f..","..g..","..h..")'>"..LIBRARY.flags["Config List"].."</font>?"if ConfigWarning:Show()then local i=LIBRARY.flags["Config List"]if table.find(LIBRARY:GetConfigs(),i)and isfile(LIBRARY.foldername.."/"..i..LIBRARY.fileext)then LIBRARY.options["Config List"]:RemoveValue(i)delfile(LIBRARY.foldername.."/"..i..LIBRARY.fileext)end end end})
        end

        for i,v in pairs (LIBRARY.tabs) do
            if (v.canInit) then
                v:Init()
                LIBRARY:selectTab(v)
            end
        end

        --// FUNCTIONS
        function CHANGE_POWER(POWER)
            local CURRPOWER = PLAYER.Power
            local STARTED = tick()

            repeat 
                if POWER < CURRPOWER.Value then
                    keypress(0x51)
                    keyrelease(0x51)
                elseif POWER > CURRPOWER.Value then
                    keypress(0x45)
                    keyrelease(0x45)
                end
                wait()
            until POWER == CURRPOWER.Value or tick() - STARTED > 1
        end

        function GET_POWER()
            local HOOP = GET_CLOSEST_GOAL()
            local DIST = (HOOP.Position - ROOT.Position).Magnitude
            
            local POWER = LERP(15,85,DIST+20,85)
            local HUMSTATE = HUM:GetState()
            
            if HUMSTATE == Enum.HumanoidStateType.Freefall or HUMSTATE == Enum.HumanoidStateType.Jumping then
                POWER = POWER - 5 
            end
            
            return 5 * math.floor(POWER / 5)
        end

        --// METAMETHODS & AIMBOT
        local o;

        o = hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...}
            local method = getnamecallmethod()

            if method:find("FindPartOnRay") and getgenv().FLAGS.AIMBOT then
                local goal = GET_CLOSEST_GOAL()
                local origin = ROOT.Position
                local mag = (origin-goal.Position).Magnitude
                local l = 0
                local y = 50
                if mag < 40 then
                    y = 60
                    l = LERP(50,0,mag,60)
                else
                    l = LERP(50,0,mag,75)
                end
                local offset = Vector3.new(0,y-l,0)
                local unit = ( (goal.Position + offset) - origin).unit
                args[1] = Ray.new(origin, unit * 1000)
                return o(self, unpack(args))
            elseif (method == "FireServer" and tostring(self) == 'shootingEvent' and args[1] == 'xd') then
                if (getgenv().FLAGS.ANTI_TRAVEL) then return end
            end
            return o(self,...)
        end)

        --// LOOPS
        runService.RenderStepped:Connect(function()
            if (getgenv().FLAGS.WALKSPEED_ON) then
                HUM.WalkSpeed = getgenv().FLAGS.WALKSPEED
            end
            if (getgenv().FLAGS.JUMPPOWER_ON) then
                HUM.JumpPower = getgenv().FLAGS.JUMPPOWER
            end
            
            if (getgenv().FLAGS.AIMBOT) then
                PLAYER.PlayerGui.PowerUI.Frame.Circle.BackgroundColor3 = Color3.fromRGB(0, 150, 300)
            else
                PLAYER.PlayerGui.PowerUI.Frame.Circle.BackgroundColor3 = Color3.fromRGB(15,15,15)
            end

            if (getgenv().FLAGS.AUTO_DEFENSE) then
                for i,v in pairs (PLAYERS:GetPlayers()) do
                    --// VARIABLES
                    if (v.Name ~= PLAYER.Name and v.Character and (v.Character.Torso.Position - CHAR.Torso.Position).magnitude < 25) then
                        if v.Character.Torso.Velocity.magnitude > 0.5 and v.Character:FindFirstChild("Basketball") then
                            local WORLD_POSITION, ON_SCREEN = CAMERA:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                        
                            DEFENSE_CIRCLE.Visible = true
                            DEFENSE_CIRCLE.Position = Vector2.new(WORLD_POSITION.X, WORLD_POSITION.Y)
                            CHAR.Humanoid:MoveTo(v.Character.Torso.CFrame.p + v.Character.Torso.Velocity.unit * 7)
                        elseif v.Character.Torso.Velocity.magnitude < 0.5 and v.Character:FindFirstChild("Basketball") then
                            local WORLD_POSITION, ON_SCREEN = CAMERA:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                        
                            DEFENSE_CIRCLE.Visible = true
                            DEFENSE_CIRCLE.Position = Vector2.new(WORLD_POSITION.X, WORLD_POSITION.Y)
                            CHAR.Humanoid:MoveTo(v.Character.Torso.CFrame.p)
                        end
                        task.wait()
                    else
                        DEFENSE_CIRCLE.Visible = false
                    end
                end
            else
                DEFENSE_CIRCLE.Visible = false
            end

            if (getgenv().FLAGS.BALL_REACH) then
                local BALL = GET_BALL()

                if (BALL) then
                    firetouchinterest(ROOT, BALL, 0)
                    firetouchinterest(ROOT, BALL, 1)
                end
            end

            MAIN_FRAME.Visible = getgenv().FLAGS.IN_RANGE
            MAIN_FRAME.Position = UDim2.new(.5,0,0,0)
            if (GET_POWER() > 90) then
                IN_RANGE.Text = "NOT IN RANGE"
                IN_RANGE.TextColor3 = Color3.new(1,0,0)
            else
                IN_RANGE.Text = "IN RANGE"
                IN_RANGE.TextColor3 = Color3.new(0,1,0)
            end
        end)

        while wait() do
            if (getgenv().FLAGS.AUTOPOWER) then
                if (CHAR:FindFirstChild("Basketball")) then
                    CHANGE_POWER(GET_POWER())
                end
            end
        end
