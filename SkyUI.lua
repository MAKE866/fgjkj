local p=game.Players.LocalPlayer
local pg=p:WaitForChild("PlayerGui")
local ts=game:GetService("TweenService")
local sg=game:GetService("StarterGui")
local rs=game:GetService("ReplicatedStorage")
local ws=game:GetService("Workspace")
local uis=game:GetService("UserInputService")
local run=game:GetService("RunService")
local vu=game:GetService("VirtualUser")

-- 清除旧UI
pcall(function()pg.SkyUI:Destroy()end)

-- 全局开关变量
local skillOn=false       -- 一刀修罗
local speedOn=false       -- 移速锁定
local rebirthOn=false     -- 自动重生
local espOn=false         -- 丧尸透视
local speedVal=220

-- ==================== UI框架 ====================
local g=Instance.new("ScreenGui",pg)
g.Name="SkyUI"
g.IgnoreGuiInset=true
g.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

local f=Instance.new("Frame",g)
f.Size=UDim2.new(0,280,0,230)    -- 展开高度加大，容纳4个按钮
f.Position=UDim2.new(0.5,-140,0.5,-115)
f.BackgroundColor3=Color3.new(1,1,1)
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

-- 折叠动画
local ex=true
local tw=TweenInfo.new(0.2)
tog.MouseButton1Click:Connect(function()
    ex=not ex
    ts:Create(f,tw,{Size=ex and UDim2.new(0,280,0,230) or UDim2.new(0,280,0,35)}):Play()
    tog.Text=ex and "▼" or "▲"
end)

-- 创建功能按钮的工厂函数
local function mkbtn(name,y)
    local b=Instance.new("TextButton",ct)
    b.Size=UDim2.new(0,240,0,40)
    b.Position=UDim2.new(0.5,-120,0,y)
    b.BackgroundColor3=Color3.new(1,1,1)
    b.Text=name
    b.TextColor3=Color3.fromRGB(50,50,50)
    b.TextSize=13
    b.Font=Enum.Font.GothamSemibold
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    return b
end

-- ==================== 功能按钮定义 ====================
local b1=mkbtn("一刀修罗 (开启)",10)      -- 点击后开启
local b2=mkbtn("移速锁定 (开启)",55)      -- 点击后开启
local b3=mkbtn("自动重生 (开启)",100)     -- 点击后开启
local b4=mkbtn("丧尸透视 (开启)",145)     -- 点击后开启

-- ==================== 功能实现 ====================

-- 1. 一刀修罗
local function runSkill()
    task.spawn(function()
        while task.wait(0.3) do
            if not skillOn then break end
            pcall(function()
                rs:WaitForChild("HeadCaptainOfCCTVSet"):FireServer({Skill="Kaijin"})
            end)
        end
    end)
end
b1.MouseButton1Click:Connect(function()
    skillOn=not skillOn
    if skillOn then
        b1.Text="一刀修罗 (关闭)"
        b1.BackgroundColor3=Color3.fromRGB(80,200,120)
        runSkill()
        sg:SetCore("SendNotification",{Title="一刀修罗",Text="已开启",Duration=2})
    else
        b1.Text="一刀修罗 (开启)"
        b1.BackgroundColor3=Color3.new(1,1,1)
        sg:SetCore("SendNotification",{Title="一刀修罗",Text="已关闭",Duration=2})
    end
end)

-- 2. 移速锁定
run.RenderStepped:Connect(function()
    if not speedOn then return end
    local c=p.Character
    if c then
        local h=c:FindFirstChildOfClass("Humanoid")
        if h and h.WalkSpeed~=speedVal then h.WalkSpeed=speedVal end
    end
end)
p.CharacterAdded:Connect(function(c)
    if not speedOn then return end
    task.wait(0.2)
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed=speedVal end
end)
b2.MouseButton1Click:Connect(function()
    speedOn=not speedOn
    if speedOn then
        b2.Text="移速锁定 (关闭)"
        b2.BackgroundColor3=Color3.fromRGB(80,200,120)
        local c=p.Character
        if c then
            local h=c:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed=speedVal end
        end
        sg:SetCore("SendNotification",{Title="移速锁定",Text="已开启 220",Duration=2})
    else
        b2.Text="移速锁定 (开启)"
        b2.BackgroundColor3=Color3.new(1,1,1)
        local c=p.Character
        if c then
            local
