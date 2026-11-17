# トラブルシューティング

「症状（エラーメッセージそのまま）→ 原因 → 対処」の形で載せます。段階2で拡充します。

## `! LaTeX Error: File 'lfs-slides.sty' not found.`

- **原因**: `.latexmkrc` が読まれていない（`lualatex` を直接実行した、または別のフォルダで `latexmk` を実行した）。
- **対処**: リポジトリのルートで `latexmk -cd <ファイル>` を実行する。VS Code の場合は、リポジトリのフォルダごと開く（`.tex` ファイル単体で開かない）。

## `lfs-fonts: LuaLaTeX でコンパイルしてください`

- **原因**: pLaTeX・upLaTeX・pdfLaTeX でコンパイルしている。
- **対処**: `latexmk` を使う（`.latexmkrc` で LuaLaTeX が選ばれる）。エディタのビルド設定が `platex` 等になっていないか確認する。
