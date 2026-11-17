# 環境構築（Mac）

macOS（Apple Silicon / Intel）で、スライド・ワークシート・選択式問題の PDF を作れるようにするまでの手順です。
マークシートのスキャン・自動採点（AMC）まで行う場合は、この手順のあとに [SETUP_AMC.md](SETUP_AMC.md) へ進んでください。

所要時間の目安：MacTeX のダウンロードとインストールに **30分〜1時間**、それ以外は15分ほどです。

---

## 1. MacTeX 2026 をインストールする

1. [MacTeX のページ](https://www.tug.org/mactex/) から **`MacTeX.pkg`**（約6GB）をダウンロードします。
2. ダウンロードした `MacTeX.pkg` を開き、画面の指示に従ってインストールします。

> **Homebrew を使っている方は**、次のどちらかでも構いません（どちらも TeX Live 2026 一式が入ります）。
>
> ```bash
> brew install --cask mactex-no-gui
> ```
>
> ```bash
> brew install texlive
> ```

## 2. エディタ（VS Code）を入れる（推奨）

1. [Visual Studio Code](https://code.visualstudio.com/) をインストールします。
2. VS Code を起動し、左の「拡張機能」から **LaTeX Workshop**（作者 James Yu）をインストールします。

このリポジトリには、LaTeX Workshop 用の設定（`.vscode/settings.json`）が入っているので、追加の設定は不要です。

## 3. 確認する

**新しく開いた** ターミナル（「アプリケーション」→「ユーティリティ」→「ターミナル」）で、次の2つを実行します。

```bash
lualatex --version
```

```bash
latexmk --version
```

1つ目の1行目に `TeX Live 2026` と出れば OK です。
「command not found」と出る場合は、ターミナルを一度閉じて開き直してください。それでもだめなら [TROUBLESHOOTING.md](TROUBLESHOOTING.md#コマンドが見つからない) を見てください。

## 4. このリポジトリを置く

GitHub のページで「Code」→「Download ZIP」を選んでダウンロードし、展開します（Git を使える方は `git clone` でも構いません）。

置き場所は、ホームフォルダの下の `~/work/lecture-factory-starter` のような、半角英数字だけのパスを勧めます。

- **iCloud Drive の同期フォルダは避けてください。**「デスクトップ」と「書類」を iCloud に同期する設定にしている場合、その中も同期対象です。ビルド中の一時ファイルを同期が掴んで、失敗したり遅くなったりします。

## 5. 最初のビルド

ターミナルで、リポジトリのフォルダに移動してからビルドします。

```bash
cd ~/work/lecture-factory-starter
```

```bash
latexmk -cd courses/example/01/slides.tex
```

`courses/example/01/slides.pdf` ができれば成功です。

> **初回は数分かかります。** LuaLaTeX が最初にフォントの一覧（キャッシュ）を作るためです。2回目からは数秒〜十数秒で終わります。

すべての教材をまとめてビルドするには：

```bash
texlua tools/build_all.lua
```

最後に `All N files built successfully.` と出れば、環境構築は完了です。

## 6. 和文フォントを BIZ UDPゴシックにする（任意）

BIZ UDPゴシックは Mac には入っていないので、先にインストールします。

1. [Google Fonts の BIZ UDPGothic のページ](https://fonts.google.com/specimen/BIZ+UDPGothic) で「Get font」→「Download all」を押してダウンロードし、展開します。
2. 中の `BIZUDPGothic-Regular.ttf` と `BIZUDPGothic-Bold.ttf` をダブルクリックし、「インストール」を押します。

そのうえで、スライドのプリアンブルを次のように変えます。

```latex
\usepackage[bizud]{lfs-slides}
```

ワークシートは `\usepackage[bizud]{lfs-worksheet}`、選択式問題は `\usepackage[bizud]{lfs-fonts}` です。

## 7. VS Code で使う

1. VS Code の「ファイル」→ **「フォルダーを開く」** で、リポジトリのフォルダを開きます。
   - `.tex` ファイルを単体で開くのではなく、**必ずフォルダごと開いてください**（設定が読み込まれません）。
2. `courses/example/01/slides.tex` を開き、少し書き換えて保存（⌘S）すると、自動でビルドされます。
3. 右上の「View LaTeX PDF」ボタンで PDF が横に表示されます。

---

## うまくいかないとき

[TROUBLESHOOTING.md](TROUBLESHOOTING.md) にエラーメッセージ別の対処をまとめています。
