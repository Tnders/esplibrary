local ESP = {}

ESP.Enabled = true
ESP.Color = Color3.fromRGB(255, 255, 255)
ESP.OutlineColor = Color3.fromRGB(0,0,0)
ESP.Size = 12
ESP.Objects = {}

function ESP:Toggle(state)
    self.Enabled = state
    for _, obj in pairs(self.Objects) do
        obj.Text.Visible = state
    end
end

function ESP:SetColor(color)
    self.Color = color
    for _, obj in pairs(self.Objects) do
        obj.Text.Color = color
    end
end

function ESP:Add(object, customText)
    if not object or self.Objects[object] then return end

    local espData = {
        Text = Drawing.new("Text"),
    }

    espData.Text.Visible = self.Enabled
    espData.Text.Color = self.Color
    espData.Text.OutlineColor = self.OutlineColor
    espData.Text.Size = self.TextSize
    espData.Text.Center = true
    espData.Text.Outline = true

    self.Objects[object] = espData

    game:GetService("RunService").RenderStepped:Connect(function()
        if not object or not object.Parent then
            espData.Text:Remove()
            self.Objects[object] = nil
        else
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(object.Position)
            espData.Text.Visible = onScreen and self.Enabled
            if onScreen then
                espData.Text.Position = Vector2.new(screenPos.X, screenPos.Y)

                -- Update ESP Text
                espData.Text.Text = customText or object.Name  -- Display custom text or object name
            end
        end
    end)
end

function ESP:Remove(object)
    if self.Objects[object] then
        self.Objects[object].Text:Remove()
        self.Objects[object] = nil
    end
end

function ESP:Clear()
    for _, obj in pairs(self.Objects) do
        obj.Text:Remove()
    end
    self.Objects = {}
end

return ESP
