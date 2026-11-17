# 推奨環境

| 項目 | 推奨 | 補足 |
|---|---|---|
| TeX | **TeX Live 2026**（Windows: [公式インストーラ](https://www.tug.org/texlive/acquire-netinstall.html)／Mac: [MacTeX 2026](https://www.tug.org/mactex/)） | フルインストールを推奨。W32TeX や古い TeX Live は非推奨 |
| エンジン | LuaLaTeX | `.latexmkrc` で自動的に選ばれる |
| ビルド | latexmk | TeX Live に同梱 |
| 和文フォント | 原ノ味（既定）／BIZ UDPゴシック（任意） | 原ノ味は TeX Live に同梱 |
| エディタ | VS Code ＋ LaTeX Workshop | 任意。設定は `.vscode/` に同梱 |
| AMC（スキャン・採点をする場合のみ） | Windows: WSL2 ＋ Ubuntu 24.04／Mac: Homebrew／Linux: apt | → [SETUP_AMC.md](SETUP_AMC.md) |

## 動作確認済みの組み合わせ

| OS | TeX | 確認方法 | 日付 |
|---|---|---|---|
| macOS 26（Apple Silicon） | TeX Live 2026（Homebrew） | 手元でビルド | 2026-11-17 |
| Ubuntu / Windows / macOS | TeX Live（最新） | GitHub Actions | （公開後に記入） |
| Windows 11 | TeX Live 2026 | 手元で手順書どおりに確認 | （未実施） |
