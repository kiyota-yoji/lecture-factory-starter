# automultiplechoice.sty（同梱版）

[Auto Multiple Choice](https://www.auto-multiple-choice.net/)（AMC）の LaTeX パッケージを、
**AMC 本体をインストールしていなくても選択式問題の PDF を組めるように** 同梱しています。

- バージョン: 1.7.0（`2025/04/17 v1.7.0 r:ec7413fa`）
- 著作権: Copyright (C) 2008-2025 Alexis Bienvenüe
- ライセンス: GNU General Public License v2 以降（ファイル冒頭の記載どおり）
- 改変: していません

## 使い分け

- **問題用紙の PDF を作るだけ**: このファイルで足ります（`.latexmkrc` が自動で読み込み先に追加します）。
- **マークシートのスキャン・自動採点まで行う**: AMC 本体が必要です（[`docs/SETUP_AMC.md`](../../docs/SETUP_AMC.md)）。
  その場合は AMC 本体に付属する同名ファイルが使われるよう、AMC 側のバージョンに合わせてください。
