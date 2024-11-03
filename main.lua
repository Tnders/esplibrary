local ESP = {}
ESP.Types = {}

function ESP:CreateType(typeName)
    if self.Types[typeName] then
        return self.Types[typeName]
    end

    local espType = {
        Enabled = false,
        Color = Color3.fromRGB(255,255,255),
        OutlineColor = Color3.fromRGB(0,0,0),
        Size = 12,
        Objects = {}
    }

    function espType:Toggle(state)
        self.Enabled = state
        for _, obj in pairs(self.Objects) do
            obj.Text.Visible = state
        end
    end

    function espType:SetColor(color)
        self.Color = color
        for _, obj in pairs(self.Objects) do
            obj.Text.Color = color
        end
    end

    function espType:Add(object, customText, flags, offsetY)
        if not object then return end

        local espData = {
            Text = Drawing.new("Text"),
            Object = object,
            Flags = flags or {},
        }

        espData.Text.Visible = self.Enabled
        espData.Text.Color = self.Color
        espData.Text.OutlineColor = self.OutlineColor
        espData.Text.Size = self.Size
        espData.Text.Center = true
        espData.Text.Outline = true

        self.Objects[object] = espData

        game:GetService("RunService").RenderStepped:Connect(function()
            if not object or not object.Parent then
                espData.Text:Remove()
                self.Objects[object] = nil
            end
                
            if object.parent and object.parent.parent and object.parent.parent.Parent and workspace.TargetFilter and workspace.TargetFilter.Misc then
                if object.parent.parent.Parent == workspace.TargetFilter.Misc then
                    espData.Text.Visible = false
                    return
                end
            end
            
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(object.Position)
            espData.Text.Visible = onScreen and self.Enabled
            if onScreen then
                espData.Text.Position = Vector2.new(screenPos.X, screenPos.Y - (offsetY or 0))

                local displayText = customText or object.Name
                for flag, value in pairs(espData.Flags) do
                    displayText = displayText .. " | " .. flag .. ": " .. tostring(value)
                end
                espData.Text.Text = displayText
            end
        end)
        return espData
    end

    function espType:Remove(object)
        if self.Objects[object] then
            self.Objects[object].Text:Remove()
            self.Objects[object] = nil
        end
    end

    function espType:Update(object, newCustomText)
        if self.Objects[object] then
            self.Objects[object].Flags.CustomText = newCustomText or self.Objects[object].Flags.CustomText
        end
    end

    self.Types[typeName] = espType
    return espType
end

return ESP
