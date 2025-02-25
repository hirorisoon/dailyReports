# === 週報用ファイル作成処理 ===
$path = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $path
$ENCODING="utf8NoBOM"

# 週報を作りたい日付をプロンプトから取得する
$ymd = Read-Host "対象の日付: "
try {
    $date = [datetime](($ymd[0..3] -Join '') + "/" +($ymd[4..5] -Join '') + "/" +($ymd[6..7] -Join ''))
    $date
} catch {
    Write-Host "日付の形式が正しくありません(yyyyMMdd). 入力値:"  + $ymd
    exit;
}

# 週番号を取得
$monday = $date.AddDays(1-$date.DayOfWeek)
$mondayYMD = $monday.ToString("yyyyMMdd")
$mondayY = $mondayYMD.Substring(0,4);
$weeklyFilePath = "$path\\$mondayY\\w$mondayYMD.md"

# 週報ファイルを確認
if (-not (Test-Path $weeklyFilePath)) {
    # 週報ファイルが無ければ週報作成処理
    # 書き込むファイルを生成する
    $weekNum = Get-Date -UFormat "%W"
    $dateStr = $monday.ToString("yyyy/MM/dd")
    "# 週報 ${preMondayY}年 第${weekNum}週 $dateStr" `
        | Set-Content -Path $weeklyFilePath  -Encoding $ENCODING
    # 前の週の初めから7日分日付をループする
    for ($i = 0; $i -lt 7; $i++) {
        # 対象日付=月曜日+i
        $targetDate = $monday.AddDays($i);
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

    # まとめとArchiveのタイトルを出力する
    Get-Content $targetPath `
        | Add-Content "\n## まとめ()\n\n" -Encoding $ENCODING
}
