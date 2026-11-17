# AMC（マークシートのスキャン・自動採点）の環境構築

[Auto Multiple Choice](https://www.auto-multiple-choice.net/)（AMC）は、選択式問題をマークシートとして印刷し、
回収した答案をスキャンして自動で採点するフリーソフトです。

## まず：AMC は必要ですか？

| やりたいこと | AMC 本体 |
|---|---|
| 選択式問題の PDF を作って配る・投影する（手で採点する） | **不要**。TeX だけでビルドできます（`amc/exercise.tex`） |
| マークシートを印刷し、スキャンして自動採点する | **必要**。このページの手順でインストールします |

AMC 本体の導入は、TeX のインストールより手間がかかります。必要になってからで十分です。

## OS ごとの推奨

| OS | 方法 | 難しさ |
|---|---|---|
| Windows 11 | **WSL2（Windows 上の Ubuntu）に入れる** | 中（30分〜1時間） |
| Linux（Ubuntu など） | apt で入れる（WSL2 の手順の後半と同じ） | 易 |
| Mac | Homebrew でソースからビルド（修正3か所） | **難**（1〜2時間・ターミナル操作に慣れた方向け） |

AMC には Windows 用・Mac 用の公式インストーラがありません。
Mac の方で手順が難しいと感じる場合は、学内の Windows 11 PC か Linux PC で AMC を使い、問題の作成だけ Mac で行う分担もできます。

---

## A. Windows 11：WSL2 ＋ Ubuntu 24.04

### A-1. WSL2 と Ubuntu を入れる

1. スタートメニューで「PowerShell」を右クリックし、**「管理者として実行」** で開きます。
2. 次を実行します。

   ```powershell
   wsl --install -d Ubuntu-24.04
   ```

3. 再起動を求められたら再起動します。
4. 再起動後に Ubuntu のウィンドウが開き、ユーザー名とパスワードの設定を求められます。半角英数字で設定してください（このパスワードは次の `sudo` で使います）。

以後、スタートメニューの「Ubuntu 24.04」で Ubuntu の端末を開けます。

### A-2. AMC と TeX を入れる（Ubuntu の端末で）

Ubuntu 24.04 の標準の AMC は 1.6.0 なので、作者が公開している配布元（PPA）から 1.7.0 を入れます。

```bash
sudo add-apt-repository ppa:alexis.bienvenue/amc-stable
```

```bash
sudo apt update
```

```bash
sudo apt install auto-multiple-choice texlive-luatex texlive-lang-japanese fonts-noto-cjk
```

- `texlive-luatex` と `texlive-lang-japanese` は、LuaLaTeX と日本語のためです（AMC は Windows 側の TeX Live ではなく、Ubuntu 側の TeX を使います）。
- `fonts-noto-cjk` は、AMC の画面の日本語が □ に化けないようにするためです。
- Ubuntu の TeX には原ノ味フォントが入っていないため、問題用紙は **IPAex フォント** で組まれます（`lfs-fonts` が自動で切り替えます）。見た目が少し変わるだけで、採点には影響しません。

### A-3. 共通設定をリンクする

問題ファイルは `\usepackage{lfs-fonts}` でリポジトリの共通設定を読み込みます。
AMC からも見つかるように、ユーザー用の TeX フォルダにリンクを張ります。

Windows の `C:\work\lecture-factory-starter` に置いている場合、Ubuntu からは `/mnt/c/work/lecture-factory-starter` に見えます。

```bash
TEXMFHOME=$(kpsewhich -var-value TEXMFHOME) && mkdir -p "$TEXMFHOME/tex/latex"
```

```bash
ln -s /mnt/c/work/lecture-factory-starter/templates/preamble "$(kpsewhich -var-value TEXMFHOME)/tex/latex/lecture-factory-starter"
```

確認（パスが表示されれば OK）：

```bash
kpsewhich lfs-fonts.sty
```

### A-4. 起動する

```bash
auto-multiple-choice &
```

Windows 11 では、AMC のウィンドウが Windows のデスクトップに表示されます（WSLg という仕組みです）。

> Windows 10 では、Microsoft Store 版の WSL に更新すると表示できる場合がありますが、本リポジトリでは Windows 11 を推奨します。

---

## B. Linux（Ubuntu 24.04 など）

上の A-2〜A-4 と同じです。A-3 のリンク元は、リポジトリを置いた場所に読み替えてください。

TeX Live を公式インストーラで入れている場合は、`texlive-luatex texlive-lang-japanese` は不要です（原ノ味フォントで組まれます）。

---

## C. Mac：Homebrew（上級者向け）

> AMC の Homebrew 用レシピ（[maelvls/homebrew-amc](https://github.com/maelvls/homebrew-amc)）は更新が止まっていて、
> **macOS 26 / Homebrew 6 では、そのままではインストールできません**（2026年8月時点で確認）。
> 以下の3か所を直したレシピを手元に作ってビルドします。

### C-1. 準備

```bash
brew install --cask xquartz
```

（インストール中にパスワードを求められます。終わったら一度ログアウトしてログインし直します。）

TeX は [SETUP_MAC.md](SETUP_MAC.md) の手順で入っていることが前提です。

### C-2. レシピを手元に複製する

```bash
brew tap maelvls/amc
```

```bash
brew tap-new local/amc --no-git
```

```bash
cp "$(brew --repository maelvls/amc)/Formula/auto-multiple-choice.rb" "$(brew --repository local/amc)/Formula/"
```

以降、`$(brew --repository local/amc)/Formula/auto-multiple-choice.rb` をテキストエディタで編集します。

```bash
open -e "$(brew --repository local/amc)/Formula/auto-multiple-choice.rb"
```

### C-3. 3か所を直す

**(1) ソースの取得先**（公式の配布サーバに接続できないため、MacPorts のミラーに変える）

`url` と `sha256` の行を次に置き換えます。また、`bottle do` 〜 `end` のブロックがあれば削除します。

```ruby
url "https://distfiles.macports.org/auto-multiple-choice/auto-multiple-choice_1.7.0_dist.tar.gz"
sha256 "95c08477ae41f1b2a98881b677b0dce03f70c4a7ab5ac440311091175d9c98f6"
```

**(2) OpenCV のバージョン**（Homebrew の `opencv` が 5 系になり、AMC が対応していないため）

```ruby
depends_on "opencv@4"   # 元は depends_on "opencv"
```

**(3) ビルド時の作業フォルダの取得**（Homebrew のサンドボックス内で Perl の `Cwd::cwd()` が失敗するため）

`def install` の中の `ENV["PERL_MM_USE_DEFAULT"] = "1"` の直後に、次を挿入します。

```ruby
cwdfix = buildpath/"brew-cwdfix"
cwdfix.mkpath
(cwdfix/"SandboxCwdFix.pm").write <<~PERL
  package SandboxCwdFix;
  use Cwd ();
  BEGIN { no warnings "redefine"; *Cwd::cwd = \\&Cwd::getcwd; }
  1;
PERL
ENV.prepend_path "PERL5LIB", cwdfix
ENV["PERL5OPT"] = "-MSandboxCwdFix"
```

### C-4. ビルドする（30分〜1時間）

```bash
brew install --build-from-source local/amc/auto-multiple-choice
```

AMC の LaTeX パッケージを TeX から見えるようにします。

```bash
auto-multiple-choice latex-link
```

（`WARNING: This command should be called by root!` と出ても、Homebrew の TeX Live なら問題ありません。MacTeX の場合は `sudo env PATH="$PATH" auto-multiple-choice latex-link` を実行します。）

### C-5. 共通設定をリンクして起動する

```bash
TEXMFHOME=$(kpsewhich -var-value TEXMFHOME) && mkdir -p "$TEXMFHOME/tex/latex"
```

```bash
ln -s ~/work/lecture-factory-starter/templates/preamble "$(kpsewhich -var-value TEXMFHOME)/tex/latex/lecture-factory-starter"
```

```bash
kpsewhich lfs-fonts.sty
```

```bash
open -a XQuartz && auto-multiple-choice &
```

> ユーザー用の TeX フォルダの場所は TeX の入れ方で違います（MacTeX は `~/Library/texmf`、Homebrew の TeX Live は `~/texmf`）。上のコマンドは `kpsewhich` で場所を調べてから作るので、どちらでも同じです。
>
> `brew upgrade` は、このインストールを正しく更新できません。AMC を更新するときは C-2 からやり直してください。

---

## D. 使い方（最小の流れ）

AMC の画面は日本語で表示されます。タブは左から「試験問題作成」「レイアウト検出」「マーク認識」「採点」「レポート」の順です。

1. **プロジェクトを作る**：「新規プロジェクト」で名前を付け、問題の元として **「ファイル」** を選んで、リポジトリの `amc/exercise.tex`（または自分で作った問題ファイル）を指定します。「プロジェクトディレクトリにコピーする（推奨）」を選びます。
   - 問題ファイルの1行目にある `%%AMC:latex_engine=lualatex` により、LuaLaTeX が自動で選ばれます。この行は消さないでください。
   - AMC はファイルを**コピー**して使います。リポジトリ側のファイルを直したら、プロジェクトに入れ直すか、AMC の「ソースファイル編集」で同じ修正をしてください。
2. **「試験問題作成」タブ**：部数を指定して問題用紙を作り、「レイアウト検出」を実行します。
3. **印刷**：問題用紙の PDF を **「実際のサイズ」（拡大縮小なし・100%）** で印刷します。
   - 「用紙に合わせる」で印刷すると、マークの位置がずれて読み取れなくなります。
   - **印刷したあとはプロジェクトのフォルダを消さず、部数も変えないでください。** 同じ答案を後から読み直すときに、印刷時のレイアウトが必要になります。
4. **スキャン**：回収した答案を、**300dpi・グレースケール** で PDF にスキャンします。
5. **「マーク認識」タブ**：スキャンした PDF を読み込みます。
6. **「採点」タブ**：採点を実行し、学籍番号欄から答案と学生を対応づけます（学生の名簿 CSV が必要です）。
7. **「レポート」タブ**：採点結果を表計算ソフト用のファイルに書き出します。

詳しい使い方は、AMC の「ヘルプ」メニューから日本語のマニュアルを開けます。

### 学生の記入方法とマーク判定のしきい値

| 学生の記入方法 | マーク判定閾値（「編集」→「設定」） |
|---|---|
| 枠を濃く塗りつぶす | 既定の **0.15** のまま |
| 枠に細いペンでチェック（✓）を入れる | **0.05** に下げる |

- 塗りつぶし式の答案で 0.05 に下げると、消し残りや汚れを拾って「複数マーク」扱いになり、正答が0点になることがあります。
- **記入方法をどちらかに統一し、事前に学生へ伝えてください。** 混在している場合は 0.15 のままにし、0点や学籍番号の読み取りエラーが出た答案だけ、画像を見て確認するのが安全です。
- 学籍番号が読み取れなかった答案は、解答欄も同じく薄く書かれていて読み落としていることがあります。学籍番号を直すついでに、解答欄も目で確認してください。

---

## うまくいかないとき

[TROUBLESHOOTING.md](TROUBLESHOOTING.md#amc) の「AMC」の節を見てください。
