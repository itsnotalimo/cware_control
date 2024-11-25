local Modules = {Colors =  {["Green"] = "0,255,0", ["Cyan"] = "33, 161, 163",["White"] = "255,255,255",["Pink"] = "255, 102, 153",}, Services = {RunService = game:GetService("RunService"),CoreGui = game:GetService("CoreGui")}}

Modules.HookText = function() 
    for index, label in pairs(Modules.Services.CoreGui:FindFirstChild("DevConsoleMaster"):GetDescendants()) do 
        if label:IsA("TextLabel") then 
            label.RichText = true 
        end 
    end 

    Modules.Services.CoreGui:FindFirstChild("DevConsoleMaster").DescendantAdded:Connect(function(label)
        if label:IsA("TextLabel") then 
            label.RichText = true 
        end
    end)
end

Modules.WriteLine = function(watermark,color, delay,loadingsymbol, loadingTxt, authTxt)
    delay = delay or 0.1 

    local Text = watermark.. " "
    local start = tick()
    print (Text)

    local loadingLabel = nil
    local progress = ""

    repeat task.wait()
        for index,label in pairs(Modules.Services.CoreGui:FindFirstChild("DevConsoleMaster"):GetDescendants()) do 
             if label:IsA("TextLabel") and string.find(label.Text:lower(),Text:lower()) then 
                loadingLabel = label 
				break
            end 
        end 
    until loadingLabel


    for i = 1, 15 do
        progress = progress .. loadingsymbol
        loadingLabel.Text = string.format("<font color='rgb(%s)' size='15'>[ %s ]: (%d%%) [%s] " .. loadingTxt .. "</font>", Modules.Colors["White"],watermark, i*4, progress)
        task.wait(delay)
    end

    loadingLabel.Text = string.format("<font color='rgb(%s)' size='15'>[ %s ]: [    SUCCESS    ] - " .. authTxt .. "</font>", Modules.Colors[color],watermark, tick() - start)
end

Modules.HookText()

return Modules
