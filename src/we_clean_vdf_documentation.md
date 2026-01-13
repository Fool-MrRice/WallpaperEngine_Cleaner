# Wallpaper Engine 订阅壁纸清理脚本文档

## 1. 脚本概述

这是一个用于管理 Wallpaper Engine 壁纸的 PowerShell 脚本，主要功能是自动清理本地已下载但已取消订阅的 Steam 创意工坊壁纸，帮助用户节省磁盘空间。

### 主要特性
- ✅ 自动识别 Steam 订阅的壁纸 ID
- ✅ 智能对比本地壁纸文件夹与订阅列表
- ✅ 安全删除未订阅的壁纸文件
- ✅ 详细的清理报告和二次确认
- ✅ 防止误删的安全机制

## 2. 工作原理

### 数据来源
脚本从两个关键位置获取信息：

1. **Steam 订阅文件**：`D:\steam\userdata\1603085091\ugc\431960_subscriptions.vdf`
   - 包含所有已订阅的创意工坊项目信息
   - 格式为 Valve Data Format (VDF)
   - 记录每个壁纸的唯一标识符 `publishedfileid`

2. **本地壁纸目录**：`F:\SteamLibrary\steamapps\workshop\content\431960`
   - Wallpaper Engine 下载的所有壁纸存储位置
   - 每个壁纸文件夹名称对应创意工坊的 `publishedfileid`

### 核心工作流程

```
┌─────────────────────────────┐     ┌─────────────────────────────┐
│  读取 Steam 订阅文件        │     │  扫描本地壁纸目录           │
│  提取 publishedfileid      │     │  获取所有文件夹名称         │
└─────────────────────────────┘     └─────────────────────────────┘
              │                                  │
              ▼                                  ▼
┌─────────────────────────────┐     ┌─────────────────────────────┐
│  构建订阅 ID 列表           │     │  构建本地文件 ID 列表       │
└─────────────────────────────┘     └─────────────────────────────┘
              │                                  │
              └───────────────┬──────────────────┘
                              ▼
                      ┌─────────────────────────────┐
                      │  对比两个列表               │
                      │  找出本地存在但已取消订阅的  │
                      │  壁纸文件夹                 │
                      └─────────────────────────────┘
                              │
                              ▼
                      ┌─────────────────────────────┐
                      │  显示待删除列表             │
                      │  包含文件夹名称和大小       │
                      └─────────────────────────────┘
                              │
                              ▼
                      ┌─────────────────────────────┐
                      │  二次确认删除操作           │
                      └─────────────────────────────┘
                              │
                              ▼
                      ┌─────────────────────────────┐
                      │  确保 Wallpaper Engine      │
                      │  已完全退出                 │
                      └─────────────────────────────┘
                              │
                              ▼
                      ┌─────────────────────────────┐
                      │  执行删除操作               │
                      │  释放磁盘空间               │
                      └─────────────────────────────┘
```

## 3. 代码分析

### 3.1 脚本头部

```powershell
# WE 安全清理脚本 —— 适配 publishedfileid 格式
$weDir   = "F:\SteamLibrary\steamapps\workshop\content\431960"
$subFile = "D:\steam\userdata\1603085091\ugc\431960_subscriptions.vdf"
```

- **WE 安全清理脚本**: 脚本名称和功能说明
- **$weDir**: Wallpaper Engine 本地壁纸存储路径
- **$subFile**: Steam 订阅信息文件路径

### 3.2 订阅 ID 提取

```powershell
# 1. 提取所有 publishedfileid
$content = Get-Content $subFile -Raw
$pattern = '"publishedfileid"\s+"(\d+)"'
$matches = [regex]::Matches($content, $pattern)
$keep = $matches | ForEach-Object { $_.Groups[1].Value }
```

- **Get-Content $subFile -Raw**: 读取整个订阅文件内容
- **正则表达式模式**: `"publishedfileid"\s+"(\d+)"`
  - `"publishedfileid"`: 匹配包含双引号的字段名
  - `\s+`: 匹配一个或多个空白字符（空格或制表符）
  - `"(\d+)"`: 捕获双引号中的数字 ID
- **[regex]::Matches()**: 使用 .NET 正则引擎查找所有匹配项
- **$keep**: 存储所有已订阅壁纸的 ID 列表

### 3.3 本地文件扫描

```powershell
# 2. 找出本地存在但已取消订阅的文件夹
$trash = Get-ChildItem $weDir -Directory |
         Where-Object { $keep -notcontains $_.Name }
```

- **Get-ChildItem $weDir -Directory**: 获取本地壁纸目录的所有子文件夹
- **Where-Object**: 筛选出不在订阅列表中的文件夹
- **$trash**: 存储待删除的壁纸文件夹列表

### 3.4 无文件需清理时的处理

```powershell
if (!$trash) {
    Write-Host "没有可清理的壁纸" -ForegroundColor Yellow
    Read-Host; exit
}
```

- **条件判断**: 检查是否有待删除文件
- **提示信息**: 显示黄色提示文字
- **Read-Host**: 等待用户按回车后退出

### 3.5 显示待删除列表

```powershell
# 3. 显示待删列表
$trash | Select-Object Name, @{
    N='Size(GB)';
    E={[math]::Round((Get-ChildItem $_.FullName -Recurse -File | Measure-Object Length -Sum).Sum/1GB,2)}
}
```

- **Select-Object**: 选择要显示的属性
- **Name**: 文件夹名称（即壁纸 ID）
- **Size(GB)**: 自定义计算属性，显示文件夹大小
  - **Get-ChildItem -Recurse -File**: 递归获取所有文件
  - **Measure-Object Length -Sum**: 计算总大小
  - **/1GB**: 转换为 GB 单位
  - **[math]::Round(...,2)**: 保留两位小数

### 3.6 二次确认

```powershell
# 4. 二次确认
$confirm = Read-Host "`n即将删除以上 $($trash.Count) 个文件夹，确认继续？ y/N"
if ($confirm -ne 'y') { Write-Host "已取消"; Read-Host; exit }
```

- **Read-Host**: 等待用户输入确认信息
- **条件判断**: 只有输入 'y' 才继续执行
- **安全退出**: 否则显示取消信息并退出

### 3.7 Wallpaper Engine 退出提示

```powershell
# 5. 先退出 WE 再删，避免占用
Write-Host "请先完全退出 Wallpaper Engine（托盘图标→退出），然后按回车继续..."
Read-Host
```

- **重要提示**: 防止 Wallpaper Engine 占用文件导致删除失败
- **等待确认**: 确保用户已退出程序后再继续

### 3.8 执行删除操作

```powershell
$trash | Remove-Item -Recurse -Force -ErrorAction Stop
Write-Host "完成，已释放空间." -ForegroundColor Green
Read-Host
```

- **Remove-Item**: 删除文件夹
  - **-Recurse**: 递归删除所有内容
  - **-Force**: 强制删除只读文件
  - **-ErrorAction Stop**: 遇到错误立即停止
- **完成提示**: 显示绿色成功信息
- **等待退出**: 让用户看到结果后再关闭窗口

## 4. 使用方法

### 4.1 前置条件

1. **PowerShell**: Windows 7 及以上版本自带 PowerShell
2. **Wallpaper Engine**: 已安装并正常使用
3. **Steam**: 已安装并登录（确保订阅信息是最新的）
4. **权限**: 有本地壁纸目录的读写权限

### 4.2 操作步骤

1. **定位脚本文件**: 找到 `we_clean_vdf(用于清除没有订阅的壁纸).ps1`

2. **右键执行**: 
   - 右键点击脚本文件
   - 选择 "使用 PowerShell 运行"
   - 或按住 Shift + 右键，选择 "在此处打开 PowerShell 窗口"

3. **查看订阅信息**: 脚本会显示已订阅的壁纸数量

4. **查看待删除列表**: 如果有未订阅的壁纸，会显示详细列表

5. **确认删除**: 输入 'y' 并按回车确认删除

6. **退出 Wallpaper Engine**: 按照提示完全退出 Wallpaper Engine

7. **完成清理**: 脚本会自动删除文件并显示完成信息

### 4.3 示例输出

```
已订阅壁纸数量: 272

Name       Size(GB)
----       --------
1234567890     0.52
0987654321     1.21

即将删除以上 2 个文件夹，确认继续？ y/N: y
请先完全退出 Wallpaper Engine（托盘图标→退出），然后按回车继续...

完成，已释放空间.
```

## 5. 配置与定制

### 5.1 修改路径

如果你的 Steam 或 Wallpaper Engine 安装在不同位置，可以修改脚本头部的路径：

```powershell
# 修改为你的 Steam 库路径
$weDir   = "F:\YourSteamLibrary\steamapps\workshop\content\431960"

# 修改为你的 Steam 用户数据路径
$subFile = "D:\steam\userdata\YOUR_STEAM_ID\ugc\431960_subscriptions.vdf"
```

- **YOUR_STEAM_ID**: 你的 Steam 用户 ID，可以在 Steam 界面查看

### 5.2 调整显示格式

可以修改脚本中的显示属性，例如更改大小单位：

```powershell
# GB 改为 MB
N='Size(MB)';
E={[math]::Round((Get-ChildItem $_.FullName -Recurse -File | Measure-Object Length -Sum).Sum/1MB,2)}
```

## 6. 安全与注意事项

### 6.1 数据安全

- ✅ 脚本仅删除本地已取消订阅的壁纸
- ✅ 保留所有仍在订阅中的壁纸
- ✅ 删除前有详细列表和二次确认
- ✅ 需手动退出 Wallpaper Engine 避免文件占用

### 6.2 常见问题

1. **脚本无法运行**: 
   - 右键点击脚本 → 属性 → 勾选 "解除锁定"
   - 或在 PowerShell 中执行 `Set-ExecutionPolicy RemoteSigned`

2. **删除失败**: 
   - 确保完全退出 Wallpaper Engine
   - 检查是否有其他程序占用文件
   - 尝试以管理员身份运行脚本

3. **订阅数量显示为 0**: 
   - 检查 Steam 订阅文件路径是否正确
   - 确保 Steam 已同步最新的订阅信息

## 7. 技术细节

### 7.1 VDF 文件格式

Steam 创意工坊订阅文件采用 Valve Data Format (VDF)，格式类似：

```
"subscribedfiles"
{
    "appid"    "431960"
    "time_last_updated"    "1768211871"
    "0"
    {
        "publishedfileid"    "3049029380"
        "time_subscribed"    "1767444052"
        "disabled_locally"    "0"
    }
    ...
}
```

### 7.2 正则表达式详解

```
"publishedfileid"\s+"(\d+)"
```

- `"publishedfileid"`: 匹配包含双引号的字段名
- `\s+`: 匹配一个或多个空白字符（空格或制表符）
- `"(\d+)"`: 捕获双引号中的数字序列（壁纸 ID）
- `(\d+)`: 捕获组，提取壁纸的唯一标识符

## 8. 更新日志

### v1.1 (2026-01-13)
- ✅ 修复正则表达式匹配问题
- ✅ 优化订阅 ID 提取逻辑
- ✅ 改进错误处理机制
- ✅ 添加详细的使用文档

### v1.0 (初始版本)
- ✅ 基本的订阅与本地文件对比功能
- ✅ 安全删除机制
- ✅ 用户确认流程

## 9. 许可证

本脚本为开源工具，仅供个人使用。请遵守 Steam 用户协议和 Wallpaper Engine 相关规定。

## 10. 联系方式

如有问题或建议，欢迎反馈。

---

**温馨提示**: 定期运行此脚本可以帮助你保持 Wallpaper Engine 文件夹的整洁，释放宝贵的磁盘空间！
