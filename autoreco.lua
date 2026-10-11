
local player = game:GetService("Players").LocalPlayer

for _, rootName in ipairs({
    "leaderstats", "Data", "Stats", "Currency", "Values"
}) do
    local root = player:FindFirstChild(rootName)

    if root then
        print("\n--- " .. rootName .. " ---")

        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("ValueBase") then
                print(
                    obj:GetFullName(),
                    obj.ClassName,
                    tostring(obj.Value)
                )
            end
        end
    end
end
