# 授業づくりの流れ：シラバス → 授業計画 → 教材

このリポジトリでは、1つの科目の教材を次の3段階で作ります。前の段階の文書が、次の段階の入力になります。

```text
公式シラバス（Web・PDF）
   │  ① シラバスを Markdown にする（syllabus-markdown）
   ▼
courses/<科目>/syllabus.md          … 科目全体：目標・各回のテーマ・評価・実施要件・教材の作り方
   │  ② 各回の授業計画を作る（lesson-plan）
   ▼
courses/<科目>/<NN>/lesson_plan.md  … 1回分の設計：到達目標・授業の流れ・教材ごとの設計
   │                                   （既存の資料がある回は、②の前に ②' で取り込んでから書き起こす）
   │  ③ 教材一式を作る（lesson-materials）
   ▼
courses/<科目>/<NN>/slides.tex, handout.tex, worksheet.tex, amc/exercise.tex, …
```

| 段階 | 作るもの | 形式 | 人がすること |
|---|---|---|---|
| ① | `syllabus.md` | [SYLLABUS_FORMAT.md](SYLLABUS_FORMAT.md) | 実施要件・教材の作り方を決める |
| ② | `lesson_plan.md` | [LESSON_PLAN_FORMAT.md](LESSON_PLAN_FORMAT.md) | 授業の流れと到達目標を確認する |
| ③ | 教材一式 | [AUTHORING_GUIDE.md](AUTHORING_GUIDE.md) | 解答・図・見た目を確認する |
| ②' | 既存の資料の取り込み：`source/SOURCES.md`・公開用の写し・書き起こしの `lesson_plan.md` | [SOURCE_MATERIALS.md](SOURCE_MATERIALS.md) | 第三者の素材の扱い・直した事実・追加した内容を確認する |

**各段階の終わりで、必ず教員が確認してから次へ進みます。** 生成 AI に任せる場合も同じです。

---

## AI エージェントで行う場合

このリポジトリには、3つの段階と既存の資料の取り込みに対応する **スキル**（作業手順書）が入っています。スキルは、複数の AI で使える共通の形式（[Agent Skills](https://agentskills.io/)）で書いてあり、リポジトリのフォルダを開くと各ツールが読み込みます。

| ツール | スキルを読む場所 | 共通の指示を読むファイル |
|---|---|---|
| Claude Code | `.claude/skills/`（`.agents/skills/` の写し） | `CLAUDE.md`（→ `AGENTS.md`） |
| Codex（OpenAI） | `.agents/skills/` | `AGENTS.md` |
| Antigravity（Google） | `.agents/skills/` | `GEMINI.md`（→ `AGENTS.md`）・`AGENTS.md` |
| そのほか Agent Skills に対応したツール（Cursor、Gemini CLI、GitHub Copilot など） | 各ツールの説明書を確認（多くは `.agents/skills/` か、設定で指定） | 多くは `AGENTS.md` |

- スキルの**原本**は `.agents/skills/` です。`.claude/skills/` はその写しなので、スキルを直すときは `.agents/skills/` を編集し、`texlua tools/sync_skills.lua` で写してください（自動ビルドで食い違いを検査しています）。
- 動作を確かめているのは Claude Code です。ほかのツールは、各社の公式文書にある置き場所と形式に合わせています。

頼み方は、どのツールでも同じです。

| 段階 | スキル | 頼み方の例 |
|---|---|---|
| ① | `syllabus-markdown` | 「この PDF（または URL）から `courses/my_course/syllabus.md` を作って」 |
| ② | `lesson-plan` | 「`my_course` の第03回の授業計画を作って」 |
| ③ | `lesson-materials` | 「第03回の授業計画から教材一式を作って」 |
| ②' | `existing-materials` | 「この PDF（去年の PowerPoint）をもとに、`my_course` の第05回を作り直して」 |

- ①では、公式シラバスに書かれていない「実施要件」「教材の作り方」について、AI から質問されます。答えた内容が `syllabus.md` に書き込まれます。
- ②は、1回ずつでも、複数回まとめてでも頼めます。できた `lesson_plan.md` を読んで、直したいところを伝えてから③へ進んでください。
- ②'では、原本を `source/original/`（Git の外）に置き、ページごとにロゴ・画面写真・他の人の図・運用上の情報・確かめるべき事実を点検して `source/SOURCES.md` に記録します。内容と順番は原本のまま書き起こし、原本との対応を `lesson_plan.md` の `# 元資料との対応` に書きます。そのあと③へ進みます。
- ③では、作った教材をビルドし、画像にして見た目を確かめ、解答を検算してから報告するよう指示してあります。それでも、**最後は必ず人が PDF を見て確認**してください。

## 手で行う場合（生成 AI を使わない）

既存の資料がある回は、先に [SOURCE_MATERIALS.md](SOURCE_MATERIALS.md) に従って原本を置き、`source/SOURCES.md` を書いてから始めます。

1. `templates/syllabus.md` を `courses/<科目>/syllabus.md` にコピーし、[SYLLABUS_FORMAT.md](SYLLABUS_FORMAT.md) に従って埋める。
2. `templates/lesson_plan.md` を `courses/<科目>/<NN>/lesson_plan.md` にコピーし、[LESSON_PLAN_FORMAT.md](LESSON_PLAN_FORMAT.md) に従って埋める。
3. `templates/` の `.tex` をコピーして教材を書き（[AUTHORING_GUIDE.md](AUTHORING_GUIDE.md)）、`texlua tools/build_all.lua courses/<科目>/<NN>` でビルドする。

## スキルに対応していない AI・ローカル LLM で行う場合

- **ファイルの読み書きとコマンドの実行ができるツール**（ローカルのモデルにつないだエージェント型のツールなど）なら、最初に「`AGENTS.md` と `.agents/skills/<名前>/SKILL.md` を読んで、その手順で作業して」と頼めば、同じ流れで作業させられます。
- **チャットだけの AI** なら、`SKILL.md` の本文と、元にする文書（`syllabus.md` など）を貼り付けて頼み、返ってきた内容を自分でファイルに保存してビルドします。
- この流れは、日本語の文章・LaTeX・数式を正確に書き、ビルドのエラーを読んで直すことを前提にしています。小さなモデルでは、ビルドが通らない・計算を誤るなどが起きやすいので、**ビルドとはみ出しの確認、正解の検算は必ず行ってください**。

## 例

[`courses/basic_math/`](../courses/basic_math/) に、3段階すべての例があります。

- 科目：[`syllabus.md`](../courses/basic_math/syllabus.md)
- 授業計画と教材：第02・03・07・10・11回（各回のフォルダの `lesson_plan.md` と教材）

既存の資料から作り直した例は [`courses/ai_business/08/`](../courses/ai_business/08/) です（`source/SOURCES.md`・`source/aib08_public.pdf`・`lesson_plan.md` の `# 元資料との対応`）。
