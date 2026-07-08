local p=game.Players.LocalPlayer
local pg=p:WaitForChild("PlayerGui")
local ts=game:GetService("TweenService")
local sg=game:GetService("StarterGui")
local ws=workspace
local rs=game:GetService("ReplicatedStorage")
pcall(function()pg.SkyUI:Destroy()end)

local g=Instance.new("ScreenGui",pg)
g.Name="SkyUI"
g.IgnoreGuiInset=true
g.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

local f=Instance.new("Frame",g)
f.Size=UDim2.new(0,280,0,160)
f.Position=UDim2.new(0.5,-140,0.5,-80)
f.BackgroundColor3=Color3.new(1,1,1)
f.ClipsDescendants=true
f.Active=true
f.Draggable=true
Instance.new("UICorner",f).CornerRadius=UDim.new(0,12)

local t=Instance.new("Frame",f)
t.Size=UDim2.new(1,0,0,35)
t.BackgroundColor3=Color3.fromRGB(135,206,235)
Instance.new("UICorner",t).CornerRadius=UDim.new(0,12)
local tf=Instance.new("Frame",t)
tf.Size=UDim2.new(1,0,0,17)
tf.Position=UDim2.new(0,0,0.5,0)
tf.BackgroundColor3=Color3.fromRGB(135,206,235)

local tl=Instance.new("TextLabel",t)
tl.BackgroundTransparency=1
tl.Size=UDim2.new(1,-60,1,0)
tl.Position=UDim2.new(0,10,0,0)
tl.Font=Enum.Font.GothamBold
tl.Text="☁️ 白云天空"
tl.TextColor3=Color3.new(1,1,1)
tl.TextSize=18
tl.TextXAlignment=Enum.TextXAlignment.Left

local tog=Instance.new("TextButton",t)
tog.Size=UDim2.new(0,26,0,26)
tog.Position=UDim2.new(1,-58,0.5,-13)
tog.BackgroundColor3=Color3.fromRGB(255,255,255)
tog.BackgroundTransparency=0.8
tog.Text="▼"
tog.TextColor3=Color3.new(1,1,1)
tog.TextSize=14
Instance.new("UICorner",tog).CornerRadius=UDim.new(1,0)

local c=Instance.new("TextButton",t)
c.Size=UDim2.new(0,26,0,26)
c.Position=UDim2.new(1,-30,0.5,-13)
c.BackgroundColor3=Color3.fromRGB(255,100,100)
c.Text="✕"
c.TextColor3=Color3.new(1,1,1)
c.TextSize=16
Instance.new("UICorner",c).CornerRadius=UDim.new(1,0)
c.MouseButton1Click:Connect(function()g:Destroy()end)

local ct=Instance.new("Frame",f)
ct.Size=UDim2.new(1,0,1,-35)
ct.Position=UDim2.new(0,0,0,35)
ct.BackgroundColor3=Color3.fromRGB(240,248,255)
Instance.new("UICorner",ct).CornerRadius=UDim.new(0,12)

local ex=true
local tw=TweenInfo.new(0.2)
tog.MouseButton1Click:Connect(function()
    ex=not ex
    ts:Create(f,tw,{Size=ex and UDim2.new(0,280,0,160) or UDim2.new(0,280,0,35)}):Play()
    tog.Text=ex and "▼" or "▲"
end)

local function mkbtn(name,y)
    local b=Instance.new("TextButton",ct)
    b.Size=UDim2.new(0,240,0,40)
    b.Position=UDim2.new(0.5,-120,0,y)
    b.BackgroundColor3=Color3.new(1,1,1)
    b.Text=name
    b.TextColor3=Color3.fromRGB(50,50,50)
    b.TextSize=14
    b.Font=Enum.Font.GothamSemibold
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    return b
end

--===================== 功能1：丧尸透视 ESP =====================
local EspSwitch = false
local HandledModels = {}
local TargetMonsterNames = {
    ["Mutated Zombie Scientist Toilet"] = true,
    ["Zombie Upgraded Titan Speaker V2"] = true,
    ["Z UTTV Tentacle"] = true
}

local function ClearAllESP()
    for _, obj in ipairs(pg:GetDescendants()) do
        if obj:IsA("Highlight") and obj.Name == "MonsterESP_HL" then
            obj:Destroy()
        end
    end
    table.clear(HandledModels)
end

local function AddMonsterESP(targetModel)
    if HandledModels[targetModel] then return end
    HandledModels[targetModel] = true

    local MonsterHighlight = Instance.new("Highlight")
    MonsterHighlight.Name = "MonsterESP_HL"
    MonsterHighlight.Adornee = targetModel
    MonsterHighlight.FillTransparency = 1
    MonsterHighlight.OutlineTransparency = 0
    MonsterHighlight.OutlineColor = Color3.new(1, 1, 1)
    MonsterHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    MonsterHighlight.Parent = pg

    targetModel.AncestryChanged:Connect(function(_, parent)
        if not parent then
            HandledModels[targetModel] = nil
            MonsterHighlight:Destroy()
        end
    end)
end

local function ScanAllMonsters()
    local LivingFolder = ws:WaitForChild("Living", 3)
    if LivingFolder then
        for _, model in ipairs(LivingFolder:GetChildren()) do
            if model:IsA("Model") and TargetMonsterNames[model.Name] then
                task.spawn(AddMonsterESP, model)
            end
        end
    end
    for _, obj in ipairs(ws:GetDescendants()) do
        if obj:IsA("Model") and obj.Parent ~= LivingFolder and TargetMonsterNames[obj.Name] then
            task.spawn(AddMonsterESP, obj)
        end
    end
end

ws.Living.ChildAdded:Connect(function(newObj)
    if not EspSwitch then return end
    if newObj:IsA("Model") and TargetMonsterNames[newObj.Name] then
        task.spawn(AddMonsterESP, newObj)
    end
end)

ws.DescendantAdded:Connect(function(newObj)
    if not EspSwitch then return end
    if newObj:IsA("Model") and newObj.Parent ~= ws.Living and TargetMonsterNames[newObj.Name] then
        task.spawn(AddMonsterESP, newObj)
    end
end)

local btn1 = mkbtn("丧尸透视", 10)
btn1.MouseButton1Click:Connect(function()
    EspSwitch = not EspSwitch
    if EspSwitch then
        ScanAllMonsters()
        sg:SetCore("SendNotification",{Ti
