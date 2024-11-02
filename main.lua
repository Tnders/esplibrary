local ESP = {}

ESP.Enabled = true
ESP.Color = Color3.fromRGB(255, 255, 255)
ESP.OutlineColor = Color3.fromRGB(0,0,0)
ESP.Size = 12
ESP.Objects = {}

function ESP:Toggle(state)
    self.Enabled = state
    for _, obj in pairs(self.Objects) do
        obj.Visible = state
    end
end

function ESP:SetColor(color)
    self.Color = color
    for _, obj in pairs(self.Objects) do
        if obj.Type == "Text" then
            obj.Color = color
        end
    end
end

function ESP:Add(object, text)
    if not object or not object:IsA("BasePart") or self.Objects[object] then return end

    local espText = Drawing.new("Text")
    espText.Visible = self.Enabled
    espText.Color = self.Color
    espText.OutlineColor = self.OutlineColor
    espText.Size = self.Size
    espText.Center = true
    espText.Outline = true
    espText.Text = text or "ESP"

    self.Objects[object] = espText

    game:GetService("RunService").RenderStepped:Connect(function()
        if not object or not object.Parent then
            espText:Remove()
            self.Objects[object] = nil
        else
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(object.Position)
            espText.Visible = onScreen and self.Enabled
            if onScreen then
                espText.Position = Vector2.new(screenPos.X, screenPos.Y)
            end
        end
    end)
end

function ESP:Remove(object)
    if self.Objects[object] then
        self.Objects[object]:Remove()
        self.Objects[object] = nil
    end
end

function ESP:Clear()
    for _, obj in pairs(self.Objects) do
        obj:Remove()
    end
    self.Objects = {}
end

function ESP:TrackFolder(folder)
    for _, object in pairs(folder:GetChildren()) do
        if object:IsA("Folder") then
            self:TrackFolder(object)
        elseif object:IsA("Model") then
            for _, part in pairs(object:GetChildren()) do
                if part:IsA("BasePart") then
                    self:Add(part, part.Name)
                end
            end
        elseif object:IsA("BasePart") then
            self:Add(object, object.Name)
        end
    end

    folder.ChildAdded:Connect(function(child)
        if child:IsA("Folder") then
            self:TrackFolder(child)
        elseif child:IsA("Model") then
            for _, part in pairs(child:GetChildren()) do
                if part:IsA("BasePart") then
                    self:Add(part, part.Name)
                end
            end
        elseif child:IsA("BasePart") then
            self:Add(child, child.Name)
        end
    end)
end

return ESP
