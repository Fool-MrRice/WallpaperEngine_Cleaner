# WE 安全清理脚本 —— 适配 publishedfileid 格式
$weDir   = "F:\SteamLibrary\steamapps\workshop\content\431960"
$subFile = "D:\steam\userdata\1603085091\ugc\431960_subscriptions.vdf"

# 1. 提取所有 publishedfileid
$content = Get-Content $subFile -Raw
$pattern = '"publishedfileid"\s+"(\d+)"'
$matches = [regex]::Matches($content, $pattern)
$keep = $matches | ForEach-Object { $_.Groups[1].Value }

Write-Host "已订阅壁纸数量: $($keep.Count)" -ForegroundColor Green

# 2. 找出本地存在但已取消订阅的文件夹
$trash = Get-ChildItem $weDir -Directory |
         Where-Object { $keep -notcontains $_.Name }

if (!$trash) {
    Write-Host "没有可清理的壁纸" -ForegroundColor Yellow
    Read-Host; exit
}

# 3. 显示待删列表
$trash | Select-Object Name, @{
    N='Size(GB)';
    E={[math]::Round((Get-ChildItem $_.FullName -Recurse -File | Measure-Object Length -Sum).Sum/1GB,2)}
}

# 4. 二次确认
$confirm = Read-Host "`n即将删除以上 $($trash.Count) 个文件夹，确认继续？ y/N"
if ($confirm -ne 'y') { Write-Host "已取消"; Read-Host; exit }

# 5. 先退出 WE 再删，避免占用
Write-Host "请先完全退出 Wallpaper Engine（托盘图标→退出），然后按回车继续..."
Read-Host

$trash | Remove-Item -Recurse -Force -ErrorAction Stop
Write-Host "完成，已释放空间." -ForegroundColor Green
Read-Host
