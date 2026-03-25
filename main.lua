    y = y + 35
end

-- 🧪 TEST WEBHOOK
createButton("TEST WEBHOOK", y, function()
    sendWebhook("TEST MESSAGE ✅")
end)

-- 📡 DETECTION
PlayerGui.ChildAdded:Connect(function(gui)
    task.spawn(function()
        for i = 1,5 do
            scanUI(gui)
            task.wait(0.5)
        end
    end)
end)

backpack.ChildAdded:Connect(function(item)
    if isUltra(item.Name) then
        sendWebhook(item.Name)
    end
end)

print("🔥 UI Webhook aktif!")
