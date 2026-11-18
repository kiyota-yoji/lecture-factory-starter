# AGENTS.md — AI エージェント向けの指示

このリポジトリで作業する AI エージェント（Claude Code、Codex、Antigravity、Gemini CLI、Cursor など）への共通の指示です。人向けの説明は [README.md](README.md) にあります。

## このリポジトリについて

LaTeX（LuaLaTeX）で授業のスライド・ワークシート・選択式問題を作るためのテンプレートとサンプル教材です。教材は次の3段階で作ります（詳しくは [docs/WORKFLOW.md](docs/WORKFLOW.md)）。

| 段階 | 作るもの | 形式 | スキル |
|---|---|---|---|
| ① | `courses/<科目>/syllabus.md` | [docs/SYLLABUS_FORMAT.md](docs/SYLLABUS_FORMAT.md) | `syllabus-markdown` |
| ② | `courses/<科目>/<NN>/lesson_plan.md` | [docs/LESSON_PLAN_FORMAT.md](docs/LESSON_PLAN_FORMAT.md) | `lesson-plan` |
| ③ | `courses/<科目>/<NN>/` の教材一式 | [docs/AUTHORING_GUIDE.md](docs/AUTHORING_GUIDE.md) | `lesson-materials` |
| ②' | 既存の資料の取り込み（`source/SOURCES.md`・公開用の写し・書き起こしの `lesson_plan.md`） | [docs/SOURCE_MATERIALS.md](docs/SOURCE_MATERIALS.md) | `existing-materials` |

## スキル

- スキルの**原本**は `.agents/skills/<名前>/SKILL.md` です。上の段階の作業を頼まれたら、まず該当する `SKILL.md` を全部読み、その手順に従ってください。
- `.claude/skills/` は Claude Code 用の**写し**です。直接編集しないでください。スキルを直すときは `.agents/skills/` を編集し、`texlua tools/sync_skills.lua` で写します。
- スキルの文中の「Claude Code なら WebFetch」のような書き方は、使っているツールの同じ働きの機能に読み替えてください。

## ビルドと確認

- ビルド：リポジトリのルートで `texlua tools/build_all.lua [フォルダ]`（すべて `OK` になること）。1ファイルなら `latexmk -cd <ファイル>`。
- `.log` に `Overfull` が出ていないこと。
- 教材を作ったら、PDF をページごとに画像にして（`pdftoppm`）目で確かめ、解答・正解を計算で検算すること。
- スキルを直したら `texlua tools/sync_skills.lua --check` が通ること。
- つまずいたら [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)。

## ブランチとコミット

- 作業は作業ブランチで行う。いまの作業ブランチは `initial-draft` です（公開の準備中のため、`main` は置いていません）。
- `main` へのコミット・push・マージ、`main` の作成は、教員の指示があるまでしない。
- コミット・push は、教員に頼まれたときだけ行う。どのブランチに入れるか分からないときは、先に教員に確認する。
- `.github/workflows/build.yml` の自動ビルドは、`main`・`initial-draft` への push と PR で動く。push したら3 OS とも成功したかを確かめる。

## 守ること

- 学生個人の情報（氏名・学籍番号・成績・提出状況・配慮の具体的な内容）を、どのファイルにも書かない。
- 教科書の問題文・図、外部の画像を写さない（問題は番号とページで指す。図は TikZ で描く）。
- 既存の資料の原本は `courses/<科目>/<NN>/source/original/` に置き、Git に入れない。学生の情報を含むもの・教科書のスキャンは、リポジトリのフォルダの中に置かない（[docs/SOURCE_MATERIALS.md](docs/SOURCE_MATERIALS.md)）。
- 事例・数値には出典を書く。一次資料で確かめていない数値は使わない。
- 各段階の終わりで、教員の確認を待ってから次の段階に進む（教員が最初から続けて頼んだ場合を除く）。
- `.tex` の先頭行 `%%AMC:latex_engine=lualatex`、`handout.tex`・`worksheet_answers.tex` の中身（本体を読み込むだけのファイル）は書き換えない。
- 学生向けの文章では、学生への呼びかけを「みなさん」にする。

## フォルダの構成

```text
.agents/skills/   スキルの原本
.claude/skills/   Claude Code 用の写し（編集しない）
templates/        雛形（syllabus.md・lesson_plan.md・.tex）
courses/          サンプル教材（科目/回/。既存の資料は 回/source/）
docs/             手順書・フォーマットの仕様
tools/            build_all.lua（一括ビルド）・sync_skills.lua（スキルの写し）・redact_pdf.py（公開用の写しを作る。任意）
vendor/amc/       AMC の LaTeX パッケージ
```
