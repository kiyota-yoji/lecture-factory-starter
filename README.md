# lecture-factory-starter

LaTeX（LuaLaTeX）で **授業スライド・配布資料・ワークシート・選択式問題（マークシート）** を作るための、
テンプレートとサンプル教材のセットです。

麗澤大学工学部の授業で運用している教材制作の仕組みから、どの大学・どの科目でも使える部分だけを取り出し、
できるだけシンプルにしたものです。Windows / Mac のどちらでも同じ手順で使えます。

> **現在は公開準備中です。** テンプレート・手順書・サンプル教材（基礎数学5回分・AIビジネス入門2回分）が揃いました。

## できること

| 作るもの | ファイル | 備考 |
|---|---|---|
| 投影用スライド | `slides.tex` | Beamer・16:9 |
| 配布用ハンドアウト | `handout.tex` | `slides.tex` をA4横1ページに4枚。同じソースから自動で作られる |
| ワークシート（学生用・解答版） | `worksheet.tex` / `worksheet_answers.tex` | 同じソースから2種類。記入欄の大きさは両者で同じ |
| 選択式問題 | `amc/exercise.tex` | [Auto Multiple Choice](https://www.auto-multiple-choice.net/) 形式。問題用紙は TeX だけで作れ、スキャン・自動採点には AMC 本体を使う |

## サンプル教材

| 科目 | 回 | 内容 |
|---|---|---|
| [基礎数学](courses/basic_math/syllabus.md) | [02](courses/basic_math/02/) | 変数と関数・三角関数 |
| | [03](courses/basic_math/03/) | 指数関数 |
| | [07](courses/basic_math/07/) | 微分法の基礎 |
| | [10](courses/basic_math/10/) | ベクトルの基礎 |
| | [11](courses/basic_math/11/) | 行列の基礎 |
| [AIビジネス入門](courses/ai_business/syllabus.md) | [09](courses/ai_business/09/) | AIを構成する技術(1)：記号とルール |
| | [10](courses/ai_business/10/) | AIを構成する技術(2)：機械学習 |

- 各回に授業計画（`lesson_plan.md`）があります
- 基礎数学：スライド・配布用ハンドアウト・ワークシート（学生用／解答版）・選択式の確認問題（5問）
- AIビジネス入門：スライド（用語・出典の付録つき）・配布用ハンドアウト・講義台本・選択式の確認問題（5問）
PDF は GitHub の Releases からもダウンロードできます（公開後）。

## 授業づくりの流れ

教材は、**シラバス → 授業計画 → 教材** の3段階で作ります（[WORKFLOW.md](docs/WORKFLOW.md)）。

| 段階 | 作るもの | 形式 | スキル |
|---|---|---|---|
| ① | `syllabus.md`（科目全体：目標・各回・評価・実施要件・教材の作り方） | [SYLLABUS_FORMAT.md](docs/SYLLABUS_FORMAT.md) | `syllabus-markdown` |
| ② | `lesson_plan.md`（1回分の設計：到達目標・授業の流れ・教材の設計） | [LESSON_PLAN_FORMAT.md](docs/LESSON_PLAN_FORMAT.md) | `lesson-plan` |
| ③ | スライド・ワークシート・確認問題など | [AUTHORING_GUIDE.md](docs/AUTHORING_GUIDE.md) | `lesson-materials` |

3つのスキルは、複数の AI で使える共通の形式で `.agents/skills/` に入っています。**Claude Code・Codex・Antigravity** などでこのフォルダを開くと使えます（[WORKFLOW.md](docs/WORKFLOW.md)）。生成 AI を使わずに、`templates/` の雛形から手で作ることもできます。

## 使い始める（3ステップ）

1. **TeX Live 2026 をインストールする**（Windows: TeX Live 公式インストーラ／Mac: MacTeX）。
   → [推奨環境](docs/RECOMMENDED_ENV.md)
2. **このリポジトリを入手する**（GitHub の「Use this template」または「Code → Download ZIP」）。
3. **ビルドする**。リポジトリのフォルダで次を実行します。

   ```bash
   latexmk -cd courses/basic_math/07/slides.tex
   ```

   すべての教材をまとめてビルドするには:

   ```bash
   texlua tools/build_all.lua
   ```

   VS Code ＋ LaTeX Workshop を使う場合は、このフォルダを開いて `.tex` を保存するだけで PDF ができます（設定は `.vscode/` に同梱）。

詳しい手順は OS ごとの手順書を見てください。

| 手順書 | 内容 |
|---|---|
| [SETUP_WINDOWS.md](docs/SETUP_WINDOWS.md) | Windows での環境構築 |
| [SETUP_MAC.md](docs/SETUP_MAC.md) | Mac での環境構築 |
| [SETUP_AMC.md](docs/SETUP_AMC.md) | マークシートのスキャン・自動採点（AMC）を使う場合 |
| [WORKFLOW.md](docs/WORKFLOW.md) | シラバス → 授業計画 → 教材の流れ（AI エージェントでのスキルの使い方） |
| [SYLLABUS_FORMAT.md](docs/SYLLABUS_FORMAT.md) / [LESSON_PLAN_FORMAT.md](docs/LESSON_PLAN_FORMAT.md) | `syllabus.md`・`lesson_plan.md` の標準フォーマット |
| [AUTHORING_GUIDE.md](docs/AUTHORING_GUIDE.md) | 新しい科目・授業回の作り方 |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | エラーメッセージ別の対処 |

## フォルダ構成

```text
├─ AGENTS.md         AI エージェント向けの共通の指示（CLAUDE.md・GEMINI.md からも読み込む）
├─ .agents/skills/   スキルの原本（syllabus-markdown / lesson-plan / lesson-materials）
├─ .claude/skills/   Claude Code 用の写し（tools/sync_skills.lua で作る。直接編集しない）
├─ templates/        新しい授業回を作るときの雛形（syllabus.md・lesson_plan.md も）
│  ├─ preamble/      共通設定（lfs-fonts / lfs-slides / lfs-worksheet）
│  ├─ slides/  worksheet/  amc/
├─ courses/          サンプル教材（科目/回/）
├─ vendor/amc/       AMC の LaTeX パッケージ（AMC 本体なしで問題用紙を組むため）
├─ tools/            ビルド補助（texlua。TeX Live に同梱されているので追加インストール不要）
├─ docs/             手順書
└─ .latexmkrc        LuaLaTeX を使い、templates/preamble を自動で読み込む設定
```

## 和文フォント

既定は TeX Live に同梱されている **原ノ味フォント** です（追加インストール不要で、Windows でも Mac でも同じ見た目になります）。
BIZ UDPゴシックを使いたい場合は、プリアンブルを次のように変えます。

```latex
\usepackage[bizud]{lfs-slides}
```

BIZ UDPゴシックは Windows 10 以降に標準搭載されています。Mac では別途インストールが必要です。

## ライセンス

- 教材（`courses/`）: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/deed.ja)
- テンプレート・ツール・手順書: [MIT](LICENSE)
- `vendor/amc/automultiplechoice.sty`: GNU GPL v2 以降

詳しくは [LICENSE-CONTENT.md](LICENSE-CONTENT.md) を見てください。
