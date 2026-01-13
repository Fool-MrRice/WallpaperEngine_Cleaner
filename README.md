# Wallpaper Engine Cleaner

一个用于清理 Wallpaper Engine 未订阅壁纸文件的工具，帮助您释放磁盘空间。

## 🚀 功能特性

- **智能清理**：自动识别并清理未订阅的壁纸文件
- **安全可靠**：删除前提供详细的文件列表和占用空间信息
- **交互友好**：支持自定义壁纸存放路径和订阅文件路径
- **双重确认**：删除操作前进行二次确认，避免误删
- **易于使用**：提供可直接双击运行的 `.exe` 文件

## 📁 包含文件

- `WallpaperEngineCleaner.exe` - 主程序（可直接双击运行）
- `we_clean_vdf(用于清除没有订阅的壁纸).ps1` - PowerShell 核心脚本
- `we_clean_vdf_documentation.md` - 详细文档

## 📥 安装说明

1. 从 GitHub Releases 下载最新版本的压缩包
2. 解压到任意文件夹
3. 确保 `WallpaperEngineCleaner.exe` 和 `we_clean_vdf(用于清除没有订阅的壁纸).ps1` 在同一目录下

## 🎯 使用方法

### 方法一：直接运行可执行文件（推荐）

1. 双击 `WallpaperEngineCleaner.exe` 运行程序
2. 程序会以管理员权限启动
3. 按照提示进行操作：
   - 确认或修改壁纸存放路径
   - 确认或修改订阅文件路径
   - 查看待删除的壁纸列表
   - 确认删除操作
   - 退出 Wallpaper Engine 后继续

### 方法二：运行 PowerShell 脚本

1. 右键点击 `we_clean_vdf(用于清除没有订阅的壁纸).ps1`
2. 选择「以管理员身份运行」
3. 按照提示进行操作

## 🛠️ 工作原理

1. **读取订阅信息**：从 Steam 用户数据目录读取 Wallpaper Engine 的订阅列表
2. **扫描本地文件**：遍历 Wallpaper Engine 的壁纸存放目录
3. **比对分析**：找出本地存在但未订阅的壁纸文件夹
4. **展示结果**：显示待删除列表及其占用的磁盘空间
5. **执行清理**：用户确认后删除未订阅的壁纸文件

## ⚠️ 注意事项

1. **备份重要数据**：使用前建议备份 Wallpaper Engine 文件夹
2. **退出 Wallpaper Engine**：清理前必须完全退出 Wallpaper Engine（托盘图标→退出）
3. **管理员权限**：程序需要管理员权限才能删除文件
4. **文件路径**：确保提供的壁纸和订阅文件路径正确
5. **订阅文件**：订阅文件通常名为 `431960_subscriptions.vdf`

## 📝 默认路径说明

- **壁纸存放路径**：`F:\SteamLibrary\steamapps\workshop\content\431960`
- **订阅文件路径**：`D:\steam\userdata\1603085091\ugc\431960_subscriptions.vdf`

您可以在程序运行时修改这些路径。

## 🔧 常见问题

### Q: 程序无法找到订阅文件怎么办？
A: 请确保您的 Steam 已登录，并在程序运行时正确指定订阅文件路径。订阅文件通常位于 `Steam/userdata/[您的SteamID]/ugc/431960_subscriptions.vdf`。

### Q: 为什么需要管理员权限？
A: 因为 Wallpaper Engine 的文件夹通常需要管理员权限才能进行删除操作。

### Q: 清理后可以恢复吗？
A: 不可以，删除操作是永久的。请在删除前仔细检查待删除列表。

## 📄 许可证

本项目无许可证，仅仅是开源使用。

## 📧 联系方式

如有问题或建议，欢迎通过 GitHub Issues 反馈。

---

**使用本工具前请务必仔细阅读说明，作者不对任何误操作造成的损失负责。**
