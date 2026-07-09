-- 加载 WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
wait(0.5)

-- ========== 提前异步获取慢加载的远程事件（解决自动重生卡顿） ==========
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeCharRemote = nil
task.spawn(function()
    pcall(function()
        ChangeCharRemote = ReplicatedStorage:WaitForChild("ForChangeCharacter", 10)
    end)
end)

-- ========== WindUI 主窗口 ==========
local Window = WindUI:CreateWindow({
    Title = "丧尸2 功能集",
    Icon = "skull",
    Author = "整合脚本",
    Folder = "ZombieHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true,
})

local ZombieTab = Window:Tab({ Title = "丧尸2", Icon = "zombie" })
local SpinTab = Window:Tab({ Title = "自动抽奖", Icon = "ticket" })

-- ========== 抽奖功能（WindUI 内置开关） ==========
local spinRunning = false
SpinTab:Toggle({
    Title = "自动抽卡",
    Default = false,
    Callback = function(value)
        spinRunning = value
        if value then
            task.spawn(function()
                while spinRunning do
                    task.wait(0.1)
                    if not spinRunning then break end
                    pcall(function()
                        ReplicatedStorage:WaitForChild("GachaSkins"):FireServer("100Spins")
                    end)
                    task.wait(15)
                end
            end)
        end
    end
})

-- ========== 四个丧尸功能（保留原始可拖动开关，WindUI 按钮负责召唤） ==========

-- 通用召唤函数：如果开关不存在则创建，显示并自动点击开启
local function summonSwitch(createFunc)
    local btn = createFunc()
    btn.Visible = true
    -- 强制 ScreenGui 置顶（避免被 WindUI 遮挡）
    if btn.Parent and btn.Parent:IsA("ScreenGui") then
        btn.Parent.DisplayOrder = 999
    end
    -- 如果按钮文字包含“开启”，自动模拟点击
    if btn.Text:find("开启") then
        pcall(function() btn.MouseButton1Click:Fire() end)
    end
end

-- 1. 丧尸透视（原始代码）
local espBtn
local function createESP()
    if espBtn then return espBtn end

    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

    local MainSwitch = false
    local dragStart, startPos
    local isDragging = false
    local HandledModels = {}

    local TargetMonsterNames = {
        ["Mutated Zombie Scientist Toilet"] = true,
        ["Zombie Upgraded Titan Speaker V2"] = true,
        ["Z UTTV Tentacle"] = true
    }

    local ScreenUI = Instance.new("ScreenGui")
    ScreenUI.Name = "ESP_UI"
    ScreenUI.ResetOnSpawn = false
    ScreenUI.IgnoreGuiInset = true
    ScreenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenUI.DisplayOrder = 999
    ScreenUI.Parent = PlayerGui

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 160, 0, 50)
    ToggleBtn.Position = UDim2.new(0.02, 0, 0.20, 0)   -- 位置错开
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 220)
    ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.TextSize = 18
    ToggleBtn.Text = "开启丧尸透视"
    ToggleBtn.Draggable = true
    ToggleBtn.Visible = false
    ToggleBtn.Parent = ScreenUI

    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = ToggleBtn.AbsolutePosition
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.TouchMovement then
            local delta = input.Position - dragStart
            ToggleBtn.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.TouchEnd then
            isDragging = false
        end
    end)

    local function ClearAllESP()
        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            if obj:IsA("Highlight") and obj.Name == "MonsterESP_HL" then
                obj:Destroy()
            end
        end
        table.clear(HandledModels)
    end

    local function AddMonsterESP(targetModel)
        if HandledModels[targetModel] then return end
        HandledModels[targetModel] = true
        local hl = Instance.new("Highlight")
        hl.Name = "MonsterESP_HL"
        hl.Adornee = targetModel
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.OutlineColor = Color3.new(1, 1, 1)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = PlayerGui
        targetModel.AncestryChanged:Connect(function(_, parent)
            if not parent then
                HandledModels[targetModel] = nil
                hl:Destroy()
            end
        end)
    end

    local function ScanAllMonsters()
        local LivingFolder = Workspace:WaitForChild("Living", 3)
        if LivingFolder then
            for _, model in ipairs(LivingFolder:GetChildren()) do
                if model:IsA("Model") and TargetMonsterNames[model.Name] then
                    task.spawn(AddMonsterESP, model)
                end
            end
        end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Parent ~= LivingFolder and TargetMonsterNames[obj.Name] then
                task.spawn(AddMonsterESP, obj)
            end
        end
    end

    Workspace.Living.ChildAdded:Connect(function(newObj)
        if not MainSwitch then return end
        if newObj:IsA("Model") and TargetMonsterNames[newObj.Name] then
            task.spawn(AddMonsterESP, newObj)
        end
    end)
    Workspace.DescendantAdded:Connect(function(newObj)
        if not MainSwitch then return end
        if newObj:IsA("Model") and newObj.Parent ~= Workspace.Living and TargetMonsterNames[newObj.Name] then
            task.spawn(AddMonsterESP, newObj)
        end
    end)

    ToggleBtn.MouseButton1Click:Connect(function()
        MainSwitch = not MainSwitch
        if MainSwitch then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 60)
            ToggleBtn.Text = "关闭丧尸透视"
            ScanAllMonsters()
            StarterGui:SetCore("SendNotification", { Title = "功能提示", Text = "已开启丧尸透视", Duration = 2 })
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 220)
            ToggleBtn.Text = "开启丧尸透视"
            ClearAllESP()
            StarterGui:SetCore("SendNotification", { Title = "功能提示", Text = "已关闭丧尸透视", Duration = 2 })
        end
    end)

    espBtn = ToggleBtn
    return ToggleBtn
end

-- 2. 一刀修罗（原始代码）
local skillBtn
local function createSkill()
    if skillBtn then return skillBtn end

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

    local SkillSwitch = false
    local dragStart, startPos
    local isDragging = false

    local ScreenUI = Instance.new("ScreenGui")
    ScreenUI.Name = "Skill_UI"
    ScreenUI.ResetOnSpawn = false
    ScreenUI.IgnoreGuiInset = true
    ScreenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenUI.DisplayOrder = 999
    ScreenUI.Parent = PlayerGui

    local SkillBtn = Instance.new("TextButton")
    SkillBtn.Size = UDim2.new(0, 160, 0, 50)
    SkillBtn.Position = UDim2.new(0.02, 0, 0.33, 0)   -- 位置错开
    SkillBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 220)
    SkillBtn.TextColor3 = Color3.new(1, 1, 1)
    SkillBtn.Font = Enum.Font.SourceSansBold
    SkillBtn.TextSize = 18
    SkillBtn.Text = "开启一刀修罗"
    SkillBtn.Draggable = true
    SkillBtn.Visible = false
    SkillBtn.Parent = ScreenUI

    SkillBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = SkillBtn.AbsolutePosition
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.TouchMovement then
            local delta = input.Position - dragStart
            SkillBtn.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.TouchEnd then
            isDragging = false
        end
    end)

    local function RunSkill()
        task.spawn(function()
            while task.wait(0.3) do
                if not SkillSwitch then break end
                local args = { { Skill = "Kaijin" } }
                pcall(function()
                    ReplicatedStorage:WaitForChild("HeadCaptainOfCCTVSet"):FireServer(unpack(args))
                end)
            end
        end)
    end

    SkillBtn.MouseButton1Click:Connect(function()
        SkillSwitch = not SkillSwitch
        if SkillSwitch then
            SkillBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 60)
            SkillBtn.Text = "关闭一刀修罗"
            RunSkill()
            StarterGui:SetCore("SendNotification", { Title = "功能提示", Text = "已开启一刀修罗", Duration = 2 })
        else
            SkillBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 220)
            SkillBtn.Text = "开启一刀修罗"
            StarterGui:SetCore("SendNotification", { Title = "功能提示", Text = "已关闭一刀修罗", Duration = 2 })
        end
    end)

    skillBtn = SkillBtn
    return SkillBtn
end

-- 3. 怪物远距离跟随（原始代码）
local followBtn
local function createFollow()
    if followBtn then return followBtn end

    local Players = game:GetService("Players")
    local UserInputService local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

local MainSwitch = false
local dragStart, startPos
local isDragging = false
local followConnection = nil

local ScreenUI = Instance.new("ScreenGui")
ScreenUI.Name = "Follow_UI"
ScreenUI.ResetOnSpawn = false
ScreenUI.IgnoreGuiInset = true
ScreenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenUI.DisplayOrder = 999
ScreenUI.Parent = PlayerGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 160, 0, 50)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.46, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 220)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 18
ToggleBtn.Text = "开启怪物远距离跟随"
ToggleBtn.Draggable = true
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenUI

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = ToggleBtn.AbsolutePosition
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.TouchMovement then
        local delta = input.Position - dragStart
        ToggleBtn.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.TouchEnd then
        isDragging = false
    end
end)

local function StartFollow()
    if followConnection then return end
    followConnection = RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        local targetModel = Workspace.Living:FindFirstChild("Zombie Upgraded Titan Speaker V2")
        if not (char and targetModel) then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local targetHrp = targetModel:FindFirstChild("HumanoidRootPart")
        if not (hrp and targetHrp) then return end
        local targetPos = targetHrp.Position
        local playerPos = targetPos + Vector3.new(90, 15, -130)
        hrp.CFrame = CFrame.new(playerPos, targetPos)
    end)
end

local function StopFollow()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    MainSwitch = not MainSwitch
    if MainSwitch then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 60)
        ToggleBtn.Text = "关闭怪物远距离跟随"
        StartFollow()
        StarterGui:SetCore("Notification", { Title = "功能提示", Text = "已开启远距离跟随", Duration = 2 })
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 220)
        ToggleBtn.Text = "开启怪物远距离跟随"
        StopFollow()
        StarterGui:SetCore("Notification", { Title = "功能提示", Text = "已关闭远距离跟随", Duration = 2 })
    end
end)

followBtn = ToggleBtn
return ToggleBtn
end

-- 4. 自动重生（原始代码，已优化加载速度）
local rebornBtn
local function createReborn()
    if rebornBtn then return rebornBtn end

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

    local TeleportSwitch = false
    local dragStart, startPos
    local isDragging = false

    local FirstTeleportPos = Vector3.new(429.45, -620.79, 335.26)
    local RebornTeleportPos = Vector3.new(1490.10, 5.45, 1315.10)
    local charArgs = { "Head Captain Of The CCTV", 0 }

    local ScreenUI = Instance.new("ScreenGui")
    ScreenUI.Name = "Reborn_UI"
    ScreenUI.ResetOnSpawn = false
    ScreenUI.IgnoreGuiInset = true
    ScreenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenUI.DisplayOrder = 999
    ScreenUI.Parent = PlayerGui

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 160, 0, 50)
    ToggleBtn.Position = UDim2.new(0.02, 0, 0.59, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 220)
    ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.TextSize = 18
    ToggleBtn.Text = "开启自动重生"
    ToggleBtn.Draggable = true
    ToggleBtn.Visible = false
    ToggleBtn.Parent = ScreenUI

    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = ToggleBtn.AbsolutePosition
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.TouchMovement then
            local delta = input.Position - dragStart
            ToggleBtn.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.TouchEnd then
            isDragging = false
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.3)
        if not TeleportSwitch then return end
        local rootPart = newChar:WaitForChild("HumanoidRootPart", 3)
        if rootPart then
            rootPart.CFrame = CFrame.new(RebornTeleportPos)
        end
    end)

    ToggleBtn.MouseButton1Click:Connect(function()
        TeleportSwitch = not TeleportSwitch
        local currentChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = currentChar:WaitForChild("HumanoidRootPart", 3)

        if TeleportSwitch then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 60)
            ToggleBtn.Text = "关闭自动重生"
            if root then
                root.CFrame = CFrame.new(FirstTeleportPos)
            end
            task.wait(0.3)
            if ChangeCharRemote then
                pcall(function()
                    ChangeCharRemote:FireServer(unpack(charArgs))
                end)
            else
                warn("远程事件未就绪，尝试同步获取...")
                pcall(function()
                    ReplicatedStorage:WaitForChild("ForChangeCharacter", 3):FireServer(unpack(charArgs))
                end)
            end
            StarterGui:SetCore("SendNotification", {
                Title = "功能提示",
                Text = "已开启自动重生",
                Duration = 2
            })
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 220)
            ToggleBtn.Text = "开启自动重生"
            StarterGui:SetCore("SendNotification", {
                Title = "功能提示",
                Text = "已关闭自动重生",
                Duration = 2
            })
        end
    end)

    rebornBtn = ToggleBtn
    return ToggleBtn
end

-- ========== WindUI 按钮绑定（点击后召唤原始可拖动开关） ==========
ZombieTab:Button({
    Title = "丧尸透视",
    Icon = "eye",
    Desc = "召唤原始透视开关",
    Callback = function() summonSwitch(createESP) end
})

ZombieTab:Button({
    Title = "一刀修罗",
    Icon = "sword",
    Desc = "召唤原始一刀修罗开关",
    Callback = function() summonSwitch(createSkill) end
})

ZombieTab:Button({
    Title = "怪物远距离跟随",
    Icon = "move",
    Desc = "召唤原始跟随开关",
    Callback = function() summonSwitch(createFollow) end
})

ZombieTab:Button({
    Title = "自动重生",
    Icon = "refresh-cw",
    Desc = "召唤原始重生开关",
    Callback = function() summonSwitch(createReborn) end
})

-- 默认选中第一个标签页
Window:SelectTab(1)

print("WindUI 整合完毕｜原始可拖动开关已保留，且不会被遮挡，自动重生已优化")
