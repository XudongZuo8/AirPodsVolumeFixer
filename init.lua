-- =============================================================================
-- == 自动调整 AirPods 音量 (融合优点最终版)
-- =============================================================================

-- --- 用户配置 ---
local airpodsTargetVolume = 10

-- 请在这里修改您的设备名称关键字
local deviceNameKeyword = "AirPods Pro"

-- 请在这里修改您的 AirPods 断开后，新设备 (如扬声器) 的音量
local speakerTargetVolume = 0
-- --- 配置结束 ---

-- 创建日志记录器
local log = hs.logger.new("AudioControl", "info")

-- 存储上一次的设备名，用于判断切换
local lastDeviceName = hs.audiodevice.defaultOutputDevice():name()

-- 带重试逻辑的音量设置函数
function setVolumeWithRetry(device, targetVolume)
    local deviceName = device:name()
    local retryCount = 0
    local maxRetries = 3
    local retryDelay = 0.5

    local function attempt()
        retryCount = retryCount + 1
        log.i(string.format("[尝试 %d/%d] 为 '%s' 设置音量至 %d%%", retryCount, maxRetries, deviceName, targetVolume))
        device:setVolume(targetVolume)

        hs.timer.doAfter(0.2, function()
            local actualVolume = device:volume()
            -- 修复：确保 actualVolume 是数字，并四舍五入到整数
            if actualVolume then
                local roundedVolume = math.floor(actualVolume + 0.5)
                if math.abs(actualVolume - targetVolume) < 1 then
                    log.i(string.format("✅ '%s' 音量设置成功: %d%%", deviceName, targetVolume))
                    hs.alert.show(string.format("🎧 %s 音量设为 %d%%", deviceName, targetVolume), 1)
                elseif retryCount < maxRetries then
                    log.w(string.format("...'%s' 音量设置未生效 (当前: %d%%)，准备重试", deviceName, roundedVolume))
                    hs.timer.doAfter(retryDelay, attempt)
                else
                    log.w(string.format("❌ '%s' 音量设置失败 (当前: %d%%)", deviceName, roundedVolume))
                end
            else
                log.w(string.format("❌ '%s' 无法获取当前音量", deviceName))
                if retryCount < maxRetries then
                    hs.timer.doAfter(retryDelay, attempt)
                end
            end
        end)
    end
    attempt()
end

-- 设备变更时的核心处理函数
function handleAudioDeviceChange()
    local currentDevice = hs.audiodevice.defaultOutputDevice()
    if not currentDevice then return end

    local currentDeviceName = currentDevice:name()
    if not currentDeviceName or currentDeviceName == lastDeviceName then
        return -- 设备名为空或未变化，则不处理
    end

    log.i(string.format("音频设备变更: 从 '%s' -> 到 '%s'", lastDeviceName or "nil", currentDeviceName))

    -- Case 1: 新设备是 AirPods
    if string.find(currentDeviceName, deviceNameKeyword) then
        log.i("检测到 AirPods 连接...")
        setVolumeWithRetry(currentDevice, airpodsTargetVolume)

    -- Case 2: 旧设备是 AirPods (表示刚刚断开)
    elseif lastDeviceName and string.find(lastDeviceName, deviceNameKeyword) then
        log.i("检测到 AirPods 断开...")
        setVolumeWithRetry(currentDevice, speakerTargetVolume)
    end

    -- 更新状态
    lastDeviceName = currentDeviceName
end

-- 启动监听器
hs.audiodevice.watcher.setCallback(handleAudioDeviceChange)
hs.audiodevice.watcher.start()

log.i("音频设备监听已启动 (最终版)")
hs.alert.show("🔊 音频设备监听已启动 (最终版)")