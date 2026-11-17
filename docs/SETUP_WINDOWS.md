# 環境構築（Windows）

Windows 10 / 11 で、スライド・ワークシート・選択式問題の PDF を作れるようにするまでの手順です。
マークシートのスキャン・自動採点（AMC）まで行う場合は、この手順のあとに [SETUP_AMC.md](SETUP_AMC.md) へ進んでください。

所要時間の目安：TeX Live のインストールに **1〜2時間**（ほとんど待ち時間）、それ以外は15分ほどです。

---

## 1. TeX Live 2026 をインストールする

1. [TeX Live のダウンロードページ](https://www.tug.org/texlive/acquire-netinstall.html) から **`install-tl-windows.exe`** をダウンロードします。
2. ダウンロードしたファイルを実行します。
   - 「Windows によって PC が保護されました」と出たら、「詳細情報」→「実行」を押します。
3. インストーラの画面で **「Install」** を選び、設定は変えずに（スキーム「full」、インストール先 `C:\texlive\2026`）インストールを始めます。
4. 「Welcome to TeX Live!」と表示されたら完了です。

> **すでに W32TeX や古い TeX Live が入っている場合**：新しい TeX Live が優先されるよう、古いものはアンインストールするか、環境変数 `PATH` から外してください。確認方法は下の「3. 確認する」を見てください。

## 2. エディタ（VS Code）を入れる（推奨）

1. [Visual Studio Code](https://code.visualstudio.com/) をインストールします。
2. VS Code を起動し、左の「拡張機能」から **LaTeX Workshop**（作者 James Yu）をインストールします。

このリポジトリには、LaTeX Workshop 用の設定（`.vscode/settings.json`）が入っているので、追加の設定は不要です。

## 3. 確認する

**新しく開いた** PowerShell（スタートメニューで「PowerShell」と入力）で、次の3つを実行します。

```powershell
lualatex --version
```

```powershell
latexmk --version
```

```powershell
where.exe lualatex
```

- 1つ目の1行目に `TeX Live 2026` と出れば OK です。
- 3つ目の結果の **1行目** が `C:\texlive\2026\bin\windows\lualatex.exe` であることを確認します。別の場所が先に出る場合は、古い TeX が優先されています（上の注意を参照）。
- 「認識されません」と出る場合は、PowerShell を一度閉じて開き直してください。それでもだめなら [TROUBLESHOOTING.md](TROUBLESHOOTING.md#コマンドが見つからない) を見てください。

## 4. このリポジトリを置く

GitHub のページで「Code」→「Download ZIP」を選んでダウンロードし、展開します（Git を使える方は `git clone` でも構いません）。

**置き場所は `C:\work\lecture-factory-starter` のような、半角英数字だけのパスにしてください。**

- **OneDrive の同期フォルダ（「ドキュメント」「デスクトップ」が OneDrive に同期されている場合を含む）は避けてください。** ビルド中に作られる一時ファイルを同期が掴んで、失敗したり遅くなったりします。
- フォルダ名に日本語・空白を含めないでください。

## 5. 最初のビルド

PowerShell で、リポジトリのフォルダに移動してからビルドします。

```powershell
cd C:\work\lecture-factory-starter
```

```powershell
latexmk -cd courses/basic_math/07/slides.tex
```

`courses\basic_math\07\slides.pdf` ができれば成功です。

> **初回は数分かかります。** LuaLaTeX が最初にフォントの一覧（キャッシュ）を作るためです。止まっているように見えても待ってください。2回目からは数秒〜十数秒で終わります。

すべての教材をまとめてビルドするには：

```powershell
texlua tools/build_all.lua
```

最後に `All N files built successfully.` と出れば、環境構築は完了です。

## 6. VS Code で使う

1. VS Code の「ファイル」→ **「フォルダーを開く」** で、リポジトリのフォルダ（`C:\work\lecture-factory-starter`）を開きます。
   - `.tex` ファイルを単体で開くのではなく、**必ずフォルダごと開いてください**（設定が読み込まれません）。
2. `courses/basic_math/07/slides.tex` を開き、少し書き換えて保存（Ctrl+S）すると、自動でビルドされます。
3. 右上の「View LaTeX PDF」ボタン（虫眼鏡つきの文書アイコン）で PDF が横に表示されます。

## 7. 和文フォントを BIZ UDPゴシックにする（任意）

BIZ UDPゴシックは Windows 10（2018年10月の更新）以降に標準で入っているので、インストールは不要です。
スライドのプリアンブルを次のように変えるだけで切り替わります。

```latex
\usepackage[bizud]{lfs-slides}
```

ワークシートは `\usepackage[bizud]{lfs-worksheet}`、選択式問題は `\usepackage[bizud]{lfs-fonts}` です。

> 同じファイルを Mac の先生と共有する場合、Mac 側にも BIZ UDPゴシックのインストールが必要になります（[SETUP_MAC.md](SETUP_MAC.md#6-和文フォントを-biz-udpゴシックにする任意)）。

---

## うまくいかないとき

[TROUBLESHOOTING.md](TROUBLESHOOTING.md) にエラーメッセージ別の対処をまとめています。
