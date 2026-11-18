# 推奨環境

| 項目 | 推奨 | 補足 |
|---|---|---|
| TeX | **TeX Live 2026**（Windows: [公式インストーラ](https://www.tug.org/texlive/acquire-netinstall.html)／Mac: [MacTeX 2026](https://www.tug.org/mactex/)） | フルインストールを推奨。W32TeX や古い TeX Live は非推奨 |
| エンジン | LuaLaTeX | `.latexmkrc` で自動的に選ばれる |
| ビルド | latexmk ＋ `texlua tools/build_all.lua`（一括） | どちらも TeX Live に同梱。Python・Perl のインストールは不要 |
| 和文フォント | 原ノ味（既定）／BIZ UDPゴシック（任意） | 原ノ味は TeX Live に同梱。見つからない環境では自動で IPAex に切り替わる |
| エディタ | VS Code ＋ LaTeX Workshop | 任意。設定は `.vscode/` に同梱 |
| AMC（スキャン・採点をする場合のみ） | **AMC 1.7.0**。Windows 11: WSL2 ＋ Ubuntu 24.04（作者の PPA）／Linux: 同左／Mac: Homebrew（上級者向け） | → [SETUP_AMC.md](SETUP_AMC.md)。Ubuntu 24.04 の apt の TeX（`texlive-lang-japanese`）にも原ノ味が入っているので、AMC の問題用紙も原ノ味で組まれる |

## 動作確認済みの組み合わせ

| OS | TeX | 確認方法 | 日付 |
|---|---|---|---|
| macOS 26（Apple Silicon） | TeX Live 2026（Homebrew） | 手元でビルド（全教材・BIZ UD 切替・IPAex 切替） | 2026-11-17 |
| macOS 26（Apple Silicon） | AMC 1.7.0（Homebrew）＋ LuaLaTeX | 問題用紙作成〜スキャン読み取りまでコマンドで確認 | 2026-11-17 |
| Ubuntu 24.04 / Windows Server / macOS（GitHub Actions） | TeX Live 2026（TeX-Live/setup-texlive-action） | 全39ファイルを自動ビルド | 2026-11-18 |
| Windows 11 | TeX Live 2026 | 手元で [SETUP_WINDOWS.md](SETUP_WINDOWS.md) どおりに導入し、全39ファイルをビルド（スマート アプリ コントロールはオフ） | 2026-11-18 |
| Windows 11 | WSL2 ＋ Ubuntu 24.04 ＋ AMC 1.7.0（apt の TeX） | 手元で [SETUP_AMC.md](SETUP_AMC.md) どおりに導入し、問題用紙の作成（原ノ味で組まれる）と画面の起動を確認。スキャン読み取りは未確認 | 2026-11-18 |
