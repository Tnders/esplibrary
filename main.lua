local ESP = {}

ESP.Enabled = true
ESP.Color = Color3.fromRGB(255, 255, 255)  -- Default color: white
ESP.OutlineColor = Color3.fromRGB(0,0,0)
ESP.Size = 12  -- Default text size
ESP.Objects = {}  -- Store all ESP instances here

-- Function to enable or disable ESP
function ESP:Toggle(state)
    self.Enabled = state
    for _, obj in pairs(self.Objects) do
        obj.Visible = state
    end
end

-- Function to set ESP text color
function ESP:SetColor(color)
    self.Color = color
    for _, obj in pairs(self.Objects) do
        if obj.Type == "Text" then
            obj.Color = color
        end
    end
end

-- Function to create an ESP for an object
function ESP:Add(object, text)
    -- Ensure the object is valid and not already in the ESP list
    if not object or not object:IsA("BasePart") or self.Objects[object] then return end

    local espText = Drawing.new("Text")
    espText.Visible = self.Enabled
    espText.Color = self.Color
    espText.OutlineColor = self.OutlineColor
    espText.Size = self.Size
    espText.Center = true
    espText.Outline = true
    espText.Text = text or "ESP"

    -- Store the ESP object in the library
    self.Objects[object] = espText

    -- Update the ESP object’s position on render
    game:GetService("RunService").RenderStepped:Connect(function()
        if not object or not object.Parent then
            espText:Remove()  -- Remove the ESP if the object is no longer in the game
            self.Objects[object] = nil
        else
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(object.Position)
            espText.Visible = onScreen and self.Enabled  -- Only show ESP if on screen and enabled
            if onScreen then
                espText.Position = Vector2.new(screenPos.X, screenPos.Y)
            end
        end
    end)
end

-- Function to remove ESP for a specific object
function ESP:Remove(object)
    if self.Objects[object] then
        self.Objects[object]:Remove()
        self.Objects[object] = nil
    end
end

-- Function to clear all ESP instances
function ESP:Clear()
    for _, obj in pairs(self.Objects) do
        obj:Remove()
    end
    self.Objects = {}
end

-- Function to auto-add ESP for objects in a specified folder
function ESP:TrackFolder(folder)
    -- Add ESP for all existing objects in the folder
    for _, object in pairs(folder:GetChildren()) do
        self:Add(object, object.Name)
    end

    -- Automatically add ESP for any new object added to the folder
    folder.ChildAdded:Connect(function(child)
        self:Add(child, child.Name)
    end)
end

return ESP
