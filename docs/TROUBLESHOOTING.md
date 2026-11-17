# トラブルシューティング

**エラーメッセージの一部でページ内検索（Ctrl+F / ⌘F）してください。**
各項目は「症状 → 原因 → 対処」の順に書いています。

エラーの詳細は、ビルドした `.tex` と同じフォルダにできる **`.log` ファイル** に出ています。
`!` で始まる行が、エラーの本体です。

- [インストール・実行](#インストール実行)
- [ビルド（LaTeX のエラー）](#ビルドlatex-のエラー)
- [見た目・印刷](#見た目印刷)
- [AMC](#amc)

---

## インストール・実行

### コマンドが見つからない

> `lualatex : 用語 'lualatex' は、コマンドレット、関数、スクリプト ファイル、または操作可能なプログラムの名前として認識されません。`（Windows）
>
> `zsh: command not found: lualatex`（Mac）

- **原因**：TeX のインストール先が `PATH` に入っていない、またはインストール前に開いた端末を使っている。
- **対処**：
  1. PowerShell / ターミナルを **一度閉じて開き直す**。
  2. それでもだめなら、Windows はサインアウトしてサインインし直す。Mac は `/Library/TeX/texbin` があるか確認する（MacTeX の場合）。
  3. Windows で `where.exe lualatex` の1行目が `C:\texlive\2026\...` でない場合は、古い TeX（W32TeX など）が先に見つかっている。古い方をアンインストールするか、環境変数 `PATH` の順番を入れ替える。

### 初回のビルドが止まったように見える

- **原因**：LuaLaTeX が最初の1回だけ、パソコンに入っているフォントの一覧（キャッシュ）を作る。フォントが多いと数分かかる。
- **対処**：待つ。2回目からは速くなる。10分以上進まない場合は、Ctrl+C で止めてもう一度実行する。

### `perl` が見つからない（Windows）

- **原因**：Windows の TeX Live は `perl` コマンドを `PATH` に入れない。
- **対処**：一括ビルドは `texlua tools/build_all.lua` を使う（Perl は不要）。`latexmk` 自体は TeX Live 内蔵の Perl で動くので、そのまま使える。

---

## ビルド（LaTeX のエラー）

### `! LaTeX Error: File 'lfs-slides.sty' not found.`

（`lfs-worksheet.sty`、`lfs-fonts.sty`、`automultiplechoice.sty` の場合も同じ）

- **原因**：リポジトリ直下の `.latexmkrc` が読まれていない。`lualatex` を直接実行した、またはエディタのビルド設定が独自のものになっている。
- **対処**：
  - 端末からは、**リポジトリのルートで** `latexmk -cd <ファイル>` を実行する。
  - VS Code は、**リポジトリのフォルダごと開く**（`.tex` 単体で開かない）。
  - TeXworks・TeXShop など別のエディタを使う場合は、ビルドのコマンドを `latexmk -r <リポジトリの場所>/.latexmkrc <ファイル>` にする。
- AMC 本体で `lfs-fonts.sty` が見つからない場合は、[AMC の節](#amc-で-lfs-fontssty-が見つからない) を見てください。

### `! Package lfs-fonts Error: LuaLaTeX でコンパイルしてください.`

> `! Package luatexja-core Error: This package requires Lua(HB)(La)TeX.`

- **原因**：pLaTeX・upLaTeX・pdfLaTeX でコンパイルしている。
- **対処**：`latexmk` でビルドする（`.latexmkrc` が LuaLaTeX を選ぶ）。エディタのビルド設定が `platex`・`uplatex`・`pdflatex` になっていないか確認する。

### `! Package fontspec Error: The font "BIZ UDPGothic" cannot be found`

- **原因**：`[bizud]` を指定したが、そのパソコンに BIZ UDPゴシックが入っていない（Mac・Linux では標準で入っていない）。
- **対処**：フォントを入れる（[SETUP_MAC.md](SETUP_MAC.md#6-和文フォントを-biz-udpゴシックにする任意)）か、`[bizud]` を外して原ノ味に戻す。
  - 入れた直後にこのエラーが出る場合は、フォントのキャッシュが古い。`luaotfload-tool --update` を実行してから、もう一度ビルドする。

### `Package lfs-fonts Warning: 原ノ味フォントが見つからないため IPAex フォントを使います`

- **原因**：TeX に原ノ味フォントが入っていない（Ubuntu の apt で入れた TeX など）。エラーではなく警告で、PDF はできる。
- **対処**：そのままで問題なし（字形が少し変わるだけ）。原ノ味で組みたい場合は、公式インストーラの TeX Live を使う。

### `! Undefined control sequence.` で、行に全角スラッシュ「／」がある

> ```
> ! Undefined control sequence.
> l.4 A\quad／B
> ```

- **原因**：`\quad` の直後に全角スラッシュ「／」を置くと、LuaLaTeX の和文処理（luatexja）と組み合わさってエラーになる。問題文が `\element{...}` などの中にあると、エラーの行番号がずれて原因が分かりにくい。
- **対処**：区切りの「／」は半角の ` / ` にするか、`\quad` との間に別の文字を入れる。

### `! Missing } inserted.`（記入欄や枠のマクロの中で）

- **原因**：引数を内部で数式モードとして扱うマクロ（`\ensuremath` を使うものなど）に `$...$` を入れると、数式モードが入れ子になって壊れる。
- **対処**：そのマクロには `$` を付けずに数式を書く（例：`\fillbox{\tfrac12}`）。
  - このリポジトリの `\answerbox{...}` は中身を通常の文章として扱うので、数式は `$...$` で書いて構わない。

### `! String contains an invalid utf-8 sequence.`

- **原因**：ファイルが UTF-8 以外（Shift_JIS など）で保存されている。古い教材ファイルを流用したときに起きやすい。
- **対処**：エディタで「UTF-8」を指定して保存し直す。VS Code は右下の文字コード表示（`Shift JIS` など）をクリック →「エンコード付きで保存」→「UTF-8」。

### ビルドは通るが、PDF が古いまま変わらない

- **原因**：前回のエラーの中間ファイルが残っていて、`latexmk` が「最新」と判断している。
- **対処**：`latexmk -C -cd <ファイル>` で中間ファイルを消してからビルドし直す。一括なら `texlua tools/build_all.lua --clean`。

---

## 見た目・印刷

### 太字のベクトル `\mathbf{\vec{c}}` が別の文字（「e」など）に化ける

- **原因**：`\mathbf` の中で `\vec` を使うと、太字の数式フォントで正しい字形が選ばれないことがある。**エラーにならず、見た目だけが誤る**ので気づきにくい。
- **対処**：ベクトルを含む式は `\mathbf` で包まない。太字が必要なら `\boldsymbol{\vec{c}}` を使う。解答版を作ったら、PDF を目で確認する。

### 記入欄の大きさで答えが推測できてしまう

- **原因**：答えの長さに合わせて枠の大きさを変えている（例：○× の欄が答えによって違う幅になる）。
- **対処**：同じ種類の記入欄は同じ大きさにそろえる。`\answerbox[高さ]{解答}` は、学生用・解答版で枠の大きさが変わらない。

### スライドの PDF を Adobe Acrobat から印刷するとエラーになる

- **原因**：Beamer の PDF に含まれる透明効果やリンクを、一部のプリンタ（大学のオンデマンド印刷など）が処理できない。PDF 自体は壊れていない。
- **対処**：印刷用に単純化した PDF を作って、そちらを印刷する（文字は図形になるので、検索はできなくなる）。Ghostscript は MacTeX に含まれる。Windows では TeX Live に入っている `rungs` を、下のコマンドの `gs` の代わりに使う。

  ```bash
  gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.3 -dShowAnnots=false -dPDFSETTINGS=/prepress -sOutputFile=slides_print.pdf slides.pdf
  ```

  投影には元の PDF を使う。

---

## AMC

### AMC で `lfs-fonts.sty` が見つからない

> `! LaTeX Error: File 'lfs-fonts.sty' not found.`（AMC の「試験問題作成」で問題用紙を作るとき）

- **原因**：AMC は問題ファイルをプロジェクトのフォルダにコピーし、そこで単独でコンパイルするため、リポジトリの `.latexmkrc` が使われない。
- **対処**：[SETUP_AMC.md](SETUP_AMC.md) の「共通設定をリンクする」を行う。`kpsewhich lfs-fonts.sty` がパスを返せば OK。

### AMC で `! Package luatexja-core Error: This package requires Lua(HB)(La)TeX.`

- **原因**：AMC が pLaTeX など別のエンジンで処理している。問題ファイルの1行目の `%%AMC:latex_engine=lualatex` が消えているか、1行目より後ろにある。
- **対処**：ファイルの **先頭（1行目）** に `%%AMC:latex_engine=lualatex` を書く。または AMC の「編集」→「設定」で、プロジェクトの LaTeX エンジンを `lualatex` にする。
  - 実際に使われたエンジンは、プロジェクトのフォルダの `amc-compiled.log` の1行目で確認できる（`This is LuaHBTeX` なら LuaLaTeX）。

### `automultiplechoice.sty` が見つからない（AMC 本体で）

- **原因**：AMC をインストールしたが、AMC の LaTeX パッケージが TeX に登録されていない（Mac の Homebrew 版で起きやすい）。
- **対処**：`auto-multiple-choice latex-link` を実行する（MacTeX なら `sudo env PATH="$PATH" auto-multiple-choice latex-link`）。`kpsewhich automultiplechoice.sty` がパスを返せば OK。

### マークを読み取れない／正答なのに0点になる

- **原因1：マーク判定のしきい値が記入方法に合っていない。** 細いペンのチェック（✓）は既定の 0.15 では面積が足りず、未記入と判定される。逆に塗りつぶし式で 0.05 に下げると、消し残りを拾って「複数マーク」になる。
- **対処1**：記入方法に合わせて「編集」→「設定」の「マーク判定閾値」を 0.15（塗りつぶし）／0.05（チェック）にする。混在している場合は 0.15 のまま、0点や読み取りエラーの答案だけ目で確認する。
- **原因2：印刷時に拡大縮小された。**「用紙に合わせる」で印刷すると、マークの位置がずれる。
- **対処2**：「実際のサイズ」（100%）で印刷し直す。

### 全員の学籍番号が読み取りエラーになる／読み取り位置が全体的にずれる

- **原因1：問題用紙を作り直した。** 印刷した後に部数や内容を変えて問題用紙を作り直すと、レイアウトが印刷した用紙と一致しなくなる。
- **対処1**：印刷に使ったプロジェクトのフォルダを消さずに残しておく。作り直す場合は、**印刷時と同じ部数** で作る。印刷後に問題ファイルを直さない。
- **原因2：四隅の丸い目印（位置合わせ用のマーカー）の検出がずれた。** スキャンの傾き・汚れ・影で起きることがある。
- **対処2**：スキャンし直す（まっすぐ置く、300dpi・グレースケール、余白の影を避ける）。AMC の「マーク認識」で答案の画像を開き、読み取り枠が印刷の枠と重なっているか確認する。

### AMC の画面の日本語が □ になる（WSL・Linux）

- **原因**：日本語の表示用フォントが入っていない。
- **対処**：`sudo apt install fonts-noto-cjk` を実行し、AMC を起動し直す。

### AMC のウィンドウが表示されない

- **Windows**：Windows 11 の WSL2 で使う（WSLg が必要）。`wsl --update` を実行してから、Ubuntu を開き直す。
- **Mac**：XQuartz を起動してから `auto-multiple-choice` を実行する。XQuartz をインストールした直後は、一度ログアウトしてログインし直す。
