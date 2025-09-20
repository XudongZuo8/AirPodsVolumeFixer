# AirPods初始音量自动控制脚本

## 问题描述

本脚本旨在解决 macOS 在处理 AirPods Pro 2 音频切换时的两个常见问题：

1. **连接音量过高：** 当 AirPods 连接到 Mac 时，系统会默认将输出音量设为 50%。该固定值对于习惯较低音量的用户而言过于突然，严重影响听觉体验。
2. **断连音量失控：** 当 AirPods 断开连接，音频自动切换回内置扬声器时，其音量状态不确定。这可能导致声音在不合时宜的场合（如办公室、图书馆）被意外公开播放。

鉴于 macOS 原生缺少对蓝牙设备连接和断开时的精细化音量控制，本脚本提供了一个轻量、可靠的自动化解决方案。

## 功能特点

- **自动音量调节**：AirPods 连接时自动设置为预设音量，断开后将扬声器音量调节为指定值
- **智能设备识别**：支持自定义设备名称关键字，兼容各种 AirPods 型号
- **可靠的重试机制**：内置重试逻辑，确保音量设置成功
- **实时反馈**：提供详细的日志记录和系统通知
- **高度可配置**：简单修改配置即可适应不同需求

## 系统要求

- macOS 系统
- [Hammerspoon](https://www.hammerspoon.org/) 应用程序

## 安装步骤

````markdown
### 1. 安装 Hammerspoon

从 [Hammerspoon 官网](https://www.hammerspoon.org/) 下载并安装 Hammerspoon。

### 2. 配置脚本

1. 打开 Hammerspoon 配置目录：`~/.hammerspoon/`
2. 将脚本代码保存为 `init.lua` 文件
3. 根据需要修改配置参数

### 3. 启动脚本

在 Hammerspoon 控制台中运行：
```
hs.reload()
````

## 配置说明

### 用户配置区域

```lua
-- AirPods 连接后的目标音量 (0-100)
local airpodsTargetVolume = 25

-- 设备名称关键字（用于识别你的 AirPods）
local deviceNameKeyword = "AirPods Pro"

-- AirPods 断开后，扬声器的目标音量 (0-100)
local speakerTargetVolume = 0
```

### 配置参数详解

| 参数                  | 类型         | 默认值        | 说明                               |
| --------------------- | ------------ | ------------- | ---------------------------------- |
| `airpodsTargetVolume` | 整数 (0-100) | 25            | AirPods 连接后自动设置的音量百分比 |
| `deviceNameKeyword`   | 字符串       | "AirPods Pro" | 用于识别 AirPods 的设备名称关键字  |
| `speakerTargetVolume` | 整数 (0-100) | 0             | AirPods 断开后扬声器的音量百分比   |

### 常见设备名称关键字

- `"AirPods Pro"` - 适用于 AirPods Pro 系列
- `"AirPods"` - 适用于所有 AirPods 型号
- `"XXX的AirPods"` - 适用于自定义命名的 AirPods

## 使用示例

### 示例 1：标准配置

```lua
local airpodsTargetVolume = 30      -- AirPods 音量设为 30%
local deviceNameKeyword = "AirPods" -- 匹配所有 AirPods 设备
local speakerTargetVolume = 5       -- 扬声器音量设为 5%
```

### 示例 2：办公室配置

```lua
local airpodsTargetVolume = 20      -- 较低音量适合办公环境
local deviceNameKeyword = "AirPods Pro"
local speakerTargetVolume = 0       -- 完全静音避免干扰他人
```

### 示例 3：家庭配置

```lua
local airpodsTargetVolume = 20      -- 较高音量适合家庭环境
local deviceNameKeyword = "AirPods"
local speakerTargetVolume = 35      -- 扬声器保持适中音量
```

## 工作原理

1. **设备监听**：持续监听系统音频输出设备的变化
2. **设备识别**：通过设备名称关键字识别 AirPods 连接状态
3. **音量调节**：
   - AirPods 连接时：设置为 `airpodsTargetVolume`
   - AirPods 断开时：设置扬声器音量为 `speakerTargetVolume`
4. **重试机制**：如果音量设置失败，会自动重试最多 3 次
5. **状态反馈**：通过系统通知和日志提供实时反馈

## 日志输出示例

```
21:30:36 AudioControl: 音频设备变更: 从 'XXX的AirPods Pro' -> 到 'MacBook Pro Speakers'
21:30:36 AudioControl: 检测到 AirPods 断开...
21:30:36 AudioControl: [尝试 1/3] 为 'MacBook Pro Speakers' 设置音量至 0%
21:30:36 AudioControl: ✅ 'MacBook Pro Speakers' 音量设置成功: 0%

21:30:39 AudioControl: 音频设备变更: 从 'MacBook Pro Speakers' -> 到 'XXX的AirPods Pro'
21:30:39 AudioControl: 检测到 AirPods 连接...
21:30:39 AudioControl: [尝试 1/3] 为 'XXX的AirPods Pro' 设置音量至 25%
21:30:40 AudioControl: ✅ 'XXX的AirPods Pro' 音量设置成功: 25%
```

## 故障排除

### 常见问题

**Q: 脚本没有响应设备切换** 

A: 检查设备名称关键字是否与实际设备名匹配，可以在系统偏好设置的声音面板中查看设备名称。

**Q: 音量设置不生效** 

A: 脚本内置了重试机制，如果仍然失败，请检查 Hammerspoon 的系统权限设置。

**Q: 如何查看详细日志** 

A: 打开 Hammerspoon 控制台窗口，所有日志都会在那里显示。

**Q: 如何停止脚本运行** 

A: 在 Hammerspoon 控制台中运行：

```lua
hs.audiodevice.watcher.stop()
```

### 权限设置

确保 Hammerspoon 有以下权限：

- 辅助功能权限
- 音频设备访问权限

## 更新日志

### v1.1 (最新版本)

- 修复了音量获取时的数字格式化错误
- 增强了错误处理机制
- 改进了日志输出的可读性

### v1.0

- 初始版本发布
- 基本的 AirPods 音量自动控制功能