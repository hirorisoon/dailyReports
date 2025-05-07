## これは？

毎日作成する必要のある日報ファイルを自動的に生成するためのスクリプト。

## 何がある？
- daily.ps1  
現在のフォルダを対象に日報ファイルが作成される。
システムの日付に応じた「年」「月」のディレクトリを作成し、template.mdを基に「yyyyMMdd.md」でファイルが作成される。
また前の週の日報が存在する場合は、前週分の日報を1つのファイルに週報としてまとめる。
- makeWeeklyReport.ps1  
週報作成用の独立した処理
プロンプトから`yyyyMMdd`形式で年月を入力すると、その日が含まれる週の月曜日から1週間分の日報ファイルを確認し、週報を作成する
GWなどの休みで、起動が1週間空いてしまったりした場合など、daily.ps1で作りきれなかった分の週報を作成する。
- template.md
日報ファイルのテンプレート
このファイルの内容で各日報ファイルが作成される。

## 使うには？
- Powershellで実行する
- VSCodeのタスクに登録する
  ```json
  "tasks": [
        {
            "label": "daily batch",
            "type": "shell",
            "command": "./daily.bat",
            "runOptions": {
                "runOn": "folderOpen"
            },
            "isBackground": true
        }
    ]
  ```
