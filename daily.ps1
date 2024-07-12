# 本ファイルの存在しているフォルダをルートとして扱う
$path = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $path

$today = Get-Date
$todayY = (Get-Date -Format 'yyyy')
$todayYm = (Get-Date -Format 'yyyyMM')
$todayYmd = (Get-Date -Format 'yyyyMMdd')

# 年フォルダの存在確認
if (-not (Test-Path "$path\$todayY")) {
    # なければ作成
    New-Item $todayY -ItemType Directory
}

# 年月フォルダの存在確認
if (-not (Test-Path "$path\$todayY\$todayYm")) {
    # なければ作成
    New-Item "$path\$todayY\$todayYm" -ItemType Directory
}

# テンプレートファイルの存在確認
if (-not (Test-Path $path\template.md)) {
    # なければ作成
    New-Item $path\template.md
}

# 日報ファイルをテンプレートからコピー
$todayFile="$path\$todayY\$todayYm\$todayYmd.md"
if (-not (Test-Path $todayFile)) {
    Copy-Item -Path $path\template.md -Destination $todayFile
}

# テンプレート内の日付を本日日付に置換
$ENCODING="utf8NoBOM"
(Get-Content $todayFile -Encoding $ENCODING) `
    | ForEach-Object { $_ -replace "yyyyMMdd", $(Get-Date -Format 'yyyy/MM/dd') } `
    | Set-Content $todayFile -Encoding $ENCODING

# === 週報用ファイル作成処理 ===
# 週番号を取得
$prevMonday = $today.AddDays(-6-$today.DayOfWeek)
$prevMondayYMD = $prevMonday.ToString("yyyyMMdd")
$prevMondayY = $prevMondayYMD.Substring(0,4);
$weeklyFilePath = "$path\\$prevMondayY\\w$prevMondayYMD.md"

# 週報ファイルを確認
if (-not (Test-Path $weeklyFilePath)) {
    # 週報ファイルが無ければ週報作成処理
    # 書き込むファイルを生成する
    $weekNum = Get-Date -UFormat "%W"
    $dateStr = $prevMonday.ToString("yyyy/MM/dd")
    "# 週報 ${preMondayY}年 第${weekNum}週 $dateStr" `
        | Set-Content -Path $weeklyFilePath  -Encoding $ENCODING
    # 前の週の初めから7日分日付をループする
    for ($i = 0; $i -lt 7; $i++) {
        # 対象日付=月曜日+i
        $targetDate = $prevMonday.AddDays($i);
        # 日報ファイルの存在確認
        $targetY = $targetDate.ToString("yyyy")
        $targetYM = $targetDate.ToString("yyyyMM")
        $targetYMD = $targetDate.ToString("yyyyMMdd")
        $targetPath = "$targetY\\$targetYM\\$targetYMD.md"
        if (-not (Test-Path $targetPath)) {
            # 対象の日報ファイルが存在しないなら翌日へ
            continue;
        }
        # 日報ファイルの内容を週報ファイルに書き出し
        Get-Content $targetPath `
            | Add-Content -Path $weeklyFilePath -Encoding $ENCODING
    }
}
