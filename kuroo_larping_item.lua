local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/KurooNeko874/KurooUI/refs/heads/main/KurooUI.lua"))()

-- ============================================================================
-- SERVICES & PLAYER REFERENCES
-- ============================================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")

local LocalPlayer       = Players.LocalPlayer
local Camera            = Workspace.CurrentCamera

-- ============================================================================
-- DAFTAR ITEM LIMITED PRESET (BISA DITAMBAHKAN KAPAN SAJA)
-- ============================================================================
-- Cara menambah item baru di kode:
-- Cukup tambahkan baris baru: { Name = "Nama Item", AssetId = 12345678, EffectType = "Sparkles" }
local PresetItems = {
    {
        Name       = "8-Bit Royal Crown",
        AssetId    = 10159600649,
        MeshId     = "rbxassetid://10138606900",
        TextureId  = "rbxassetid://10138606949",
        EffectType = "8BitCrown",
    },
    {
        Name       = "8-Bit HP Bar",
        AssetId    = 10159610478,
        EffectType = "Native",
    },
    {
        Name       = "8-Bit Extra Life",
        AssetId    = 10159606132,
        EffectType = "Native",
    },
    {
        Name       = "8-Bit Tabby Cat",
        AssetId    = 10159617728,
        EffectType = "Native",
    },
    {
        Name       = "8-Bit Roblox Coin",
        AssetId    = 10159622004,
        EffectType = "Native",
    },
    {
        Name       = "Fiery Horns of the Netherworld",
        AssetId    = 215718515,
        EffectType = "OrangeFire",
    },
    {
        Name       = "Frozen Horns of the Frigid Planes",
        AssetId    = 74891470,
        EffectType = "BlueFire",
    },
    {
        Name       = "Poisoned Horns of the Toxic Wasteland",
        AssetId    = 1744060292,
        EffectType = "GreenFire",
    },
    {
        Name       = "Sparkle Time Fedora",
        AssetId    = 1285307,
        EffectType = "Sparkles",
    },
    {
        Name       = "Valkyrie Helm",
        AssetId    = 1365767,
        EffectType = "None",
    },
    {
        Name       = "Dominus Empyreus",
        AssetId    = 21070012,
        EffectType = "None",
    },
}

-- ============================================================================
-- TABEL STATE & KONFIGURASI
-- ============================================================================
local ActiveItems   = {} -- [itemName] = { Model, Handle, Weld, BaseC0, BaseSize, BaseMeshScale, Config, ItemData }
local ItemConfigs   = {} -- Menyimpan posisi, rotasi, ukuran per nama item
local SelectedItem  = "Belum Ada Item Aktif"

local CustomItemInput = {
    Name    = "",
    AssetId = "",
}

local FreeCamConfig = {
    Enabled       = false,
    Speed         = 1.0,
    Sensitivity   = 0.25,
    FOV           = 70,
    ZoomStep      = 4,
    FreezeChar    = true,
}

local Connections = {}

-- ============================================================================
-- FUNGSI HELPER VISUAL & EFEK ITEM
-- ============================================================================
local function GetDefaultTransform()
    return {
        Scale       = 100, -- Dalam persen (100% = ukuran normal 1.0x)
        PosX        = 0,   -- Dalam 1/10 stud (10 = 1 stud) agar slider halus
        PosY        = 0,
        PosZ        = 0,
        RotX        = 0,   -- Dalam derajat (-180 s/d 180)
        RotY        = 0,
        RotZ        = 0,
        ShowEffects = true,
    }
end

local function EnsureItemConfig(itemName)
    if not ItemConfigs[itemName] then
        ItemConfigs[itemName] = GetDefaultTransform()
    end
    return ItemConfigs[itemName]
end

-- Membuat efek fallback autentik jika partikel bawaan asset perlu diperkuat di client
local function EnsureSpecialEffect(handle, effectType)
    local hasNativeEffect = false
    for _, desc in ipairs(handle:GetDescendants()) do
        if desc:IsA("ParticleEmitter") or desc:IsA("Fire") or desc:IsA("Sparkles") or desc:IsA("Smoke") then
            desc.Enabled = true
            hasNativeEffect = true
        end
    end

    if hasNativeEffect then
        return
    end

    if effectType == "8BitCrown" then
        local att = handle:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", handle)
        local pe = Instance.new("ParticleEmitter")
        pe.Name = "Kuroo8BitParticles"
        pe.Texture = "rbxassetid://241685484"
        pe.Rate = 15
        pe.Lifetime = NumberRange.new(2.5, 2.5)
        pe.Speed = NumberRange.new(1.5, 2.2)
        pe.EmissionDirection = Enum.NormalId.Top
        pe.Rotation = NumberRange.new(0, 0)
        pe.RotSpeed = NumberRange.new(-10, 10)
        pe.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.35),
            NumberSequenceKeypoint.new(0.5, 0.45),
            NumberSequenceKeypoint.new(1, 0.2),
        })
        pe.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.15, 0),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        pe.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(131, 253, 255)),
            ColorSequenceKeypoint.new(0.16, Color3.fromRGB(0, 213, 255)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 122, 34)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(59, 153, 26)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(198, 42, 11)),
        })
        pe.LightEmission = 0.8
        pe.LockedToPart = true
        pe.Parent = att
    elseif effectType == "OrangeFire" then
        local fire = Instance.new("Fire")
        fire.Name = "KurooFire"
        fire.Color = Color3.fromRGB(255, 140, 0)
        fire.SecondaryColor = Color3.fromRGB(255, 50, 0)
        fire.Heat = 9
        fire.Size = 5
        fire.Parent = handle
    elseif effectType == "BlueFire" then
        local fire = Instance.new("Fire")
        fire.Name = "KurooBlueFire"
        fire.Color = Color3.fromRGB(0, 170, 255)
        fire.SecondaryColor = Color3.fromRGB(180, 235, 255)
        fire.Heat = 9
        fire.Size = 5
        fire.Parent = handle
    elseif effectType == "GreenFire" then
        local fire = Instance.new("Fire")
        fire.Name = "KurooGreenFire"
        fire.Color = Color3.fromRGB(65, 255, 65)
        fire.SecondaryColor = Color3.fromRGB(0, 140, 0)
        fire.Heat = 9
        fire.Size = 5
        fire.Parent = handle
    elseif effectType == "Sparkles" then
        local sp = Instance.new("Sparkles")
        sp.Name = "KurooSparkles"
        sp.SparkleColor = Color3.fromRGB(255, 230, 120)
        sp.Parent = handle
    end
end

-- Mengaplikasikan perubahan Posisi, Rotasi, Ukuran, dan Efek ke Item Aktif
local function ApplyItemTransform(itemName)
    local entry = ActiveItems[itemName]
    if not entry or not entry.Handle or not entry.Handle.Parent then
        return
    end

    local cfg = entry.Config
    local scaleMultiplier = math.max(cfg.Scale / 100, 0.05)

    -- Konversi slider posisi (1 unit slider = 0.1 stud)
    local offsetX = cfg.PosX / 10
    local offsetY = cfg.PosY / 10
    local offsetZ = cfg.PosZ / 10

    -- Konversi slider rotasi (derajat ke radian)
    local rotCFrame = CFrame.Angles(
        math.rad(cfg.RotX),
        math.rad(cfg.RotY),
        math.rad(cfg.RotZ)
    )

    -- Update Weld C0
    if entry.Weld then
        entry.Weld.C0 = entry.BaseC0 * CFrame.new(offsetX, offsetY, offsetZ) * rotCFrame
    end

    -- Update Ukuran (Scale) pada SpecialMesh atau MeshPart
    local mesh = entry.Handle:FindFirstChildOfClass("SpecialMesh")
    if mesh and entry.BaseMeshScale then
        mesh.Scale = entry.BaseMeshScale * scaleMultiplier
    elseif entry.BaseSize then
        entry.Handle.Size = entry.BaseSize * scaleMultiplier
    end

    -- Update visibilitas efek partikel / api / sparkles
    for _, desc in ipairs(entry.Handle:GetDescendants()) do
        if desc:IsA("ParticleEmitter") or desc:IsA("Fire") or desc:IsA("Sparkles") or desc:IsA("Smoke") or desc:IsA("PointLight") or desc:IsA("Beam") or desc:IsA("Trail") then
            desc.Enabled = cfg.ShowEffects
        end
    end
end

-- Memasang item visual ke karakter lokal (Kompatibel Xeno)
local function AttachVisualItem(itemData)
    local char = LocalPlayer.Character
    if not char then return false end

    local head = char:FindFirstChild("Head")
    if not head then return false end

    -- Hapus instance lama jika sudah ada
    if ActiveItems[itemData.Name] and ActiveItems[itemData.Name].Model then
        pcall(function()
            ActiveItems[itemData.Name].Model:Destroy()
        end)
        ActiveItems[itemData.Name] = nil
    end

    local loadedAsset = nil
    local ok, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(itemData.AssetId))
    end)

    if ok and objects and #objects > 0 then
        loadedAsset = objects[1]
    end

    local containerModel = Instance.new("Model")
    containerModel.Name = "KurooLarp_" .. itemData.Name

    local handle = nil
    if loadedAsset then
        if loadedAsset:IsA("Accessory") or loadedAsset:IsA("Hat") or loadedAsset:IsA("Model") then
            handle = loadedAsset:FindFirstChild("Handle", true) or loadedAsset:FindFirstChildWhichIsA("BasePart", true)
            loadedAsset.Parent = containerModel
        elseif loadedAsset:IsA("BasePart") then
            handle = loadedAsset
            loadedAsset.Parent = containerModel
        end
    end

    -- Fallback pembuatan Handle jika asset gagal dimuat langsung via GetObjects
    if not handle then
        handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1, 1, 1)
        handle.Parent = containerModel

        local sm = Instance.new("SpecialMesh")
        sm.MeshType = Enum.MeshType.FileMesh
        sm.MeshId = itemData.MeshId or ""
        sm.TextureId = itemData.TextureId or ""
        sm.Parent = handle
    end

    -- Bersihkan script bawaan item & matikan fisika agar tidak mengganggu gerakan karakter
    for _, desc in ipairs(containerModel:GetDescendants()) do
        if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("TouchTransmitter") then
            desc:Destroy()
        elseif desc:IsA("BasePart") then
            desc.CanCollide = false
            desc.CanTouch = false
            desc.CanQuery = false
            desc.Massless = true
            desc.Anchored = false
        end
    end

    -- Tentukan target bagian tubuh & posisi dasar (BaseC0) menggunakan Attachment bawaan item
    local targetPart = head
    local baseC0 = CFrame.new(0, 0.6, 0)

    local itemAttachment = handle:FindFirstChildOfClass("Attachment")
    if itemAttachment then
        local charAttachment = char:FindFirstChild(itemAttachment.Name, true)
        if charAttachment and charAttachment:IsA("Attachment") and charAttachment.Parent and charAttachment.Parent:IsA("BasePart") then
            targetPart = charAttachment.Parent
            baseC0 = charAttachment.CFrame * itemAttachment.CFrame:Inverse()
        else
            baseC0 = CFrame.new(0, 0.5, 0) * itemAttachment.CFrame:Inverse()
        end
    elseif loadedAsset and (loadedAsset:IsA("Accessory") or loadedAsset:IsA("Hat")) then
        local okAp, ap = pcall(function() return loadedAsset.AttachmentPoint end)
        if okAp and typeof(ap) == "CFrame" then
            baseC0 = CFrame.new(0, 0.5, 0) * ap:Inverse()
        end
    end

    -- Pastikan efek partikel item aktif & terlihat
    EnsureSpecialEffect(handle, itemData.EffectType or "Native")

    -- Buat Weld standar ke bagian tubuh karakter
    local weld = Instance.new("Weld")
    weld.Name = "KurooLarpWeld"
    weld.Part0 = targetPart
    weld.Part1 = handle
    weld.C0 = baseC0
    weld.Parent = handle

    containerModel.Parent = char

    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
    local cfg = EnsureItemConfig(itemData.Name)

    ActiveItems[itemData.Name] = {
        Model         = containerModel,
        Handle        = handle,
        Weld          = weld,
        BaseC0        = baseC0,
        BaseSize      = handle.Size,
        BaseMeshScale = mesh and mesh.Scale or nil,
        Config        = cfg,
        ItemData      = itemData,
    }

    ApplyItemTransform(itemData.Name)
    return true
end

local function RemoveVisualItem(itemName)
    local entry = ActiveItems[itemName]
    if entry then
        if entry.Model then
            pcall(function()
                entry.Model:Destroy()
            end)
        end
        ActiveItems[itemName] = nil
    end
end

local function GetActiveItemNames()
    local names = {}
    for name, _ in pairs(ActiveItems) do
        table.insert(names, name)
    end
    table.sort(names)
    if #names == 0 then
        table.insert(names, "Belum Ada Item Aktif")
    end
    return names
end

-- ============================================================================
-- SISTEM FREE CAM (STUDIO STYLE: WASD + Q/E + MOUSE LOOK + ZOOM)
-- ============================================================================
local FreeCamState = {
    CameraCFrame  = CFrame.new(),
    Pitch         = 0,
    Yaw           = 0,
    Rotating      = false,
    SavedCamType  = nil,
    SavedFOV      = 70,
}

local function SetCharacterFrozen(freeze)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = freeze
    end
end

local function StartFreeCam()
    Camera = Workspace.CurrentCamera
    if not Camera then return end

    FreeCamState.SavedCamType = Camera.CameraType
    FreeCamState.SavedFOV = Camera.FieldOfView
    FreeCamState.CameraCFrame = Camera.CFrame

    local rx, ry, _ = Camera.CFrame:ToOrientation()
    FreeCamState.Pitch = rx
    FreeCamState.Yaw = ry

    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.FieldOfView = FreeCamConfig.FOV

    if FreeCamConfig.FreezeChar then
        SetCharacterFrozen(true)
    end
end

local function StopFreeCam()
    Camera = Workspace.CurrentCamera
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    FreeCamState.Rotating = false

    SetCharacterFrozen(false)

    if Camera then
        Camera.CameraType = FreeCamState.SavedCamType or Enum.CameraType.Custom
        Camera.FieldOfView = FreeCamState.SavedFOV or 70
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            Camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
        end
    end
end

-- ============================================================================
-- PEMBUATAN WINDOW UTAMA KUROOUI (STANDAR WAJIB)
-- ============================================================================
local Win = UI:CreateWindow({
    Title   = "Kuroo Larping Item",
    W       = 650,
    H       = 500,
    Theme   = "Toxic",
    HideKey = Enum.KeyCode.K,
})

-- Forward declaration untuk Dropdown item aktif di Tab 2
local ActiveItemDropdown = nil

local function RefreshActiveDropdown(preferredName)
    if not ActiveItemDropdown then return end
    local names = GetActiveItemNames()
    if preferredName and ActiveItems[preferredName] then
        SelectedItem = preferredName
        pcall(function() ActiveItemDropdown:Set(preferredName) end)
    else
        SelectedItem = names[1]
        pcall(function() ActiveItemDropdown:Set(SelectedItem) end)
    end
end

-- ============================================================================
-- TAB 1: ITEM LIMITED ROBLOX
-- ============================================================================
local ItemTab   = Win:AddTab({ Name = "Item Limited" })
local PresetSec = ItemTab:AddSection({ Name = "Daftar Item Limited (Visual)" })

for _, item in ipairs(PresetItems) do
    EnsureItemConfig(item.Name)
    PresetSec:AddToggle({
        Name     = item.Name .. " [" .. tostring(item.AssetId) .. "]",
        Default  = false,
        Callback = function(state)
            if state then
                local success = AttachVisualItem(item)
                if success then
                    RefreshActiveDropdown(item.Name)
                end
            else
                RemoveVisualItem(item.Name)
                RefreshActiveDropdown(nil)
            end
        end,
    })
end

local CustomSec = ItemTab:AddSection({ Name = "Tambah Item Limited Baru (Custom ID)" })

CustomSec:AddInput({
    Name        = "Nama Item Custom",
    Placeholder = "Contoh: Red Sparkle Time Fedora",
    Callback    = function(text)
        CustomItemInput.Name = text
    end,
})

CustomSec:AddInput({
    Name        = "Asset ID Katalog Roblox",
    Placeholder = "Contoh: 72082328",
    Callback    = function(text)
        CustomItemInput.AssetId = text
    end,
})

CustomSec:AddButton({
    Name     = "Pasang / Aktifkan Item Custom",
    Callback = function()
        local idNum = tonumber(CustomItemInput.AssetId)
        if not idNum then
            warn("[Kuroo Larping Item] Masukkan angka Asset ID yang valid!")
            return
        end
        local customName = (CustomItemInput.Name ~= "" and CustomItemInput.Name) or ("Custom Item " .. tostring(idNum))
        local newItemData = {
            Name       = customName,
            AssetId    = idNum,
            EffectType = "Native",
        }
        EnsureItemConfig(customName)
        if AttachVisualItem(newItemData) then
            RefreshActiveDropdown(customName)
        end
    end,
})

CustomSec:AddButton({
    Name     = "Lepas Semua Item Aktif",
    Callback = function()
        for name, _ in pairs(ActiveItems) do
            RemoveVisualItem(name)
        end
        RefreshActiveDropdown(nil)
    end,
})

-- ============================================================================
-- TAB 2: PENGATURAN POSISI, UKURAN, KEMIRINGAN & EFEK
-- ============================================================================
local AdjustTab = Win:AddTab({ Name = "Pengaturan Item" })
local SelectSec = AdjustTab:AddSection({ Name = "Pilih Item Aktif Berdasarkan Nama" })

local dropdownOptions = { "Belum Ada Item Aktif" }
for _, item in ipairs(PresetItems) do
    table.insert(dropdownOptions, item.Name)
end

ActiveItemDropdown = SelectSec:AddDropdown({
    Name     = "Nama Item yang Diatur",
    Options  = dropdownOptions,
    Default  = "8-Bit Royal Crown",
    Callback = function(val)
        SelectedItem = val
    end,
})
SelectedItem = "8-Bit Royal Crown"

SelectSec:AddToggle({
    Name     = "Tampilkan Efek Partikel / Api / Sparkles",
    Default  = true,
    Callback = function(state)
        if not SelectedItem or SelectedItem == "Belum Ada Item Aktif" then return end
        local cfg = EnsureItemConfig(SelectedItem)
        cfg.ShowEffects = state
        ApplyItemTransform(SelectedItem)
    end,
})

local ScaleSec = AdjustTab:AddSection({ Name = "Pengaturan Ukuran & Posisi (X, Y, Z)" })

ScaleSec:AddSlider({
    Name     = "Ukuran Item / Scale (%)",
    Min      = 20,
    Max      = 300,
    Default  = 100,
    Callback = function(val)
        if not SelectedItem or SelectedItem == "Belum Ada Item Aktif" then return end
        local cfg = EnsureItemConfig(SelectedItem)
        cfg.Scale = val
        ApplyItemTransform(SelectedItem)
    end,
})

ScaleSec:AddSlider({
    Name     = "Posisi Kiri / Kanan (X)",
    Min      = -50,
    Max      = 50,
    Default  = 0,
    Callback = function(val)
        if not SelectedItem or SelectedItem == "Belum Ada Item Aktif" then return end
        local cfg = EnsureItemConfig(SelectedItem)
        cfg.PosX = val
        ApplyItemTransform(SelectedItem)
    end,
})

ScaleSec:AddSlider({
    Name     = "Posisi Atas / Bawah (Y)",
    Min      = -50,
    Max      = 50,
    Default  = 0,
    Callback = function(val)
        if not SelectedItem or SelectedItem == "Belum Ada Item Aktif" then return end
        local cfg = EnsureItemConfig(SelectedItem)
        cfg.PosY = val
        ApplyItemTransform(SelectedItem)
    end,
})

ScaleSec:AddSlider({
    Name     = "Posisi Depan / Belakang (Z)",
    Min      = -50,
    Max      = 50,
    Default  = 0,
    Callback = function(val)
        if not SelectedItem or SelectedItem == "Belum Ada Item Aktif" then return end
        local cfg = EnsureItemConfig(SelectedItem)
        cfg.PosZ = val
        ApplyItemTransform(SelectedItem)
    end,
})

local RotSec = AdjustTab:AddSection({ Name = "Pengaturan Kemiringan / Rotasi" })

RotSec:AddSlider({
    Name     = "Kemiringan Depan / Belakang (Pitch X)",
    Min      = -180,
    Max      = 180,
    Default  = 0,
    Callback = function(val)
        if not SelectedItem or SelectedItem == "Belum Ada Item Aktif" then return end
        local cfg = EnsureItemConfig(SelectedItem)
        cfg.RotX = val
        ApplyItemTransform(SelectedItem)
    end,
})

RotSec:AddSlider({
    Name     = "Putaran Kiri / Kanan (Yaw Y)",
    Min      = -180,
    Max      = 180,
    Default  = 0,
    Callback = function(val)
        if not SelectedItem or SelectedItem == "Belum Ada Item Aktif" then return end
        local cfg = EnsureItemConfig(SelectedItem)
        cfg.RotY = val
        ApplyItemTransform(SelectedItem)
    end,
})

RotSec:AddSlider({
    Name     = "Kemiringan Samping (Roll Z)",
    Min      = -180,
    Max      = 180,
    Default  = 0,
    Callback = function(val)
        if not SelectedItem or SelectedItem == "Belum Ada Item Aktif" then return end
        local cfg = EnsureItemConfig(SelectedItem)
        cfg.RotZ = val
        ApplyItemTransform(SelectedItem)
    end,
})

RotSec:AddButton({
    Name     = "Reset Posisi & Ukuran Item Terpilih",
    Callback = function()
        if not SelectedItem or SelectedItem == "Belum Ada Item Aktif" then return end
        ItemConfigs[SelectedItem] = GetDefaultTransform()
        if ActiveItems[SelectedItem] then
            ActiveItems[SelectedItem].Config = ItemConfigs[SelectedItem]
            ApplyItemTransform(SelectedItem)
        end
    end,
})

-- ============================================================================
-- TAB 3: CAMERA (STUDIO FREE CAM: WASD + Q/E + ZOOM)
-- ============================================================================
local CamTab = Win:AddTab({ Name = "Camera" })
local CamSec = CamTab:AddSection({ Name = "Roblox Studio Free Cam (WASD + Q/E + Zoom)" })

CamSec:AddToggle({
    Name     = "Aktifkan Free Cam (Studio Mode)",
    Default  = false,
    Callback = function(state)
        FreeCamConfig.Enabled = state
        if state then
            StartFreeCam()
        else
            StopFreeCam()
        end
    end,
})

CamSec:AddKeybind({
    Name     = "Keybind Toggle Free Cam",
    Default  = Enum.KeyCode.P,
    Callback = function()
        FreeCamConfig.Enabled = not FreeCamConfig.Enabled
        if FreeCamConfig.Enabled then
            StartFreeCam()
        else
            StopFreeCam()
        end
    end,
})

CamSec:AddToggle({
    Name     = "Bekukan Karakter Saat Free Cam",
    Default  = true,
    Callback = function(state)
        FreeCamConfig.FreezeChar = state
        if FreeCamConfig.Enabled then
            SetCharacterFrozen(state)
        end
    end,
})

CamSec:AddSlider({
    Name     = "Kecepatan Gerak Kamera",
    Min      = 1,
    Max      = 100,
    Default  = 25,
    Callback = function(val)
        FreeCamConfig.Speed = val / 25
    end,
})

CamSec:AddSlider({
    Name     = "Zoom / Field of View (FOV)",
    Min      = 10,
    Max      = 120,
    Default  = 70,
    Callback = function(val)
        FreeCamConfig.FOV = val
        if FreeCamConfig.Enabled and Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = val
        end
    end,
})

CamSec:AddButton({
    Name     = "Reset Zoom (FOV 70)",
    Callback = function()
        FreeCamConfig.FOV = 70
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = 70
        end
    end,
})

-- ============================================================================
-- TAB 4: SETTINGS UI (WAJIB ADA DI SETIAP SCRIPT KUROOUI)
-- ============================================================================
local SetTab = Win:AddTab({ Name = "Settings" })
local SetSec = SetTab:AddSection({ Name = "UI Settings" })

SetSec:AddDropdown({
    Name     = "Select Theme",
    Options  = { "Toxic", "Cyan", "Frost", "Ruby", "Emerald", "Darkness", "Sakura", "Solar", "Yellow", "Bloody", "Monochrome" },
    Default  = "Toxic",
    Callback = function(val)
        Win:SetTheme(val)
    end,
})

SetSec:AddButton({
    Name     = "Unload / Destroy Script",
    Callback = function()
        -- Matikan Free Cam & kembalikan kamera
        if FreeCamConfig.Enabled then
            FreeCamConfig.Enabled = false
            StopFreeCam()
        end

        -- Hapus seluruh item visual yang terpasang
        for name, _ in pairs(ActiveItems) do
            RemoveVisualItem(name)
        end

        -- Putus semua event connection
        for _, conn in ipairs(Connections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end

        Win:Destroy()
    end,
})

-- ============================================================================
-- RUNTIME CONNECTIONS (FREE CAM LOOP & AUTO RE-EQUIP SAAT RESPAWN)
-- ============================================================================

-- Input Klik Kanan & Scroll Mouse untuk Free Cam (Mirip Roblox Studio)
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not FreeCamConfig.Enabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        FreeCamState.Rotating = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    end
end))

table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        FreeCamState.Rotating = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end))

table.insert(Connections, UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if not FreeCamConfig.Enabled then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement and FreeCamState.Rotating then
        local delta = input.Delta
        FreeCamState.Yaw   = FreeCamState.Yaw - math.rad(delta.X * FreeCamConfig.Sensitivity)
        FreeCamState.Pitch = math.clamp(FreeCamState.Pitch - math.rad(delta.Y * FreeCamConfig.Sensitivity), -math.rad(89), math.rad(89))
    elseif input.UserInputType == Enum.UserInputType.MouseWheel then
        -- Scroll atas untuk Zoom In, Scroll bawah untuk Zoom Out
        FreeCamConfig.FOV = math.clamp(FreeCamConfig.FOV - (input.Position.Z * FreeCamConfig.ZoomStep), 10, 120)
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = FreeCamConfig.FOV
        end
    end
end))

-- Loop Pergerakan Kamera Studio (WASD + Q Turun / E Naik + Shift)
table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
    if not FreeCamConfig.Enabled then return end
    Camera = Workspace.CurrentCamera
    if not Camera then return end

    if Camera.CameraType ~= Enum.CameraType.Scriptable then
        Camera.CameraType = Enum.CameraType.Scriptable
    end

    local moveVector = Vector3.new(0, 0, 0)
    if not UserInputService:GetFocusedTextBox() then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0, 0, -1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, 1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1, 0, 0) end
        -- Tombol E untuk Naik dan Q untuk Turun (Persis Roblox Studio)
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveVector = moveVector + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveVector = moveVector + Vector3.new(0, -1, 0) end
    end

    local speedMult = FreeCamConfig.Speed * 35
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        speedMult = speedMult * 0.35 -- Tahan LeftShift untuk gerakan presisi/lambat seperti di Studio
    end

    local rotCFrame = CFrame.fromOrientation(FreeCamState.Pitch, FreeCamState.Yaw, 0)
    local newPos = FreeCamState.CameraCFrame.Position + (rotCFrame:VectorToWorldSpace(moveVector) * speedMult * dt)

    FreeCamState.CameraCFrame = CFrame.new(newPos) * rotCFrame
    Camera.CFrame = FreeCamState.CameraCFrame
    Camera.FieldOfView = FreeCamConfig.FOV
end))

-- Pasang ulang item visual secara otomatis ketika karakter Respawn
table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(newChar)
    newChar:WaitForChild("Head", 10)
    task.wait(0.5)
    local itemsToRestore = {}
    for _, entry in pairs(ActiveItems) do
        if entry.ItemData then
            table.insert(itemsToRestore, entry.ItemData)
        end
    end
    for _, itemData in ipairs(itemsToRestore) do
        AttachVisualItem(itemData)
    end
end))
