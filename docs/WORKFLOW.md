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
   │  ③ 教材一式を作る（lesson-materials）
   ▼
courses/<科目>/<NN>/slides.tex, handout.tex, worksheet.tex, amc/exercise.tex, …
```

| 段階 | 作るもの | 形式 | 人がすること |
|---|---|---|---|
| ① | `syllabus.md` | [SYLLABUS_FORMAT.md](SYLLABUS_FORMAT.md) | 実施要件・教材の作り方を決める |
| ② | `lesson_plan.md` | [LESSON_PLAN_FORMAT.md](LESSON_PLAN_FORMAT.md) | 授業の流れと到達目標を確認する |
| ③ | 教材一式 | [AUTHORING_GUIDE.md](AUTHORING_GUIDE.md) | 解答・図・見た目を確認する |

**各段階の終わりで、必ず教員が確認してから次へ進みます。** 生成 AI に任せる場合も同じです。

---

## Claude Code で行う場合

このリポジトリには、3つの段階に対応する **スキル**（`.claude/skills/`）が入っています。リポジトリのフォルダで Claude Code を開くと、自動で使えるようになります。

| 段階 | スキル | 頼み方の例 |
|---|---|---|
| ① | `syllabus-markdown` | 「この PDF（または URL）から `courses/my_course/syllabus.md` を作って」 |
| ② | `lesson-plan` | 「`my_course` の第03回の授業計画を作って」 |
| ③ | `lesson-materials` | 「第03回の授業計画から教材一式を作って」 |

- ①では、公式シラバスに書かれていない「実施要件」「教材の作り方」について、Claude から質問されます。答えた内容が `syllabus.md` に書き込まれます。
- ②は、1回ずつでも、複数回まとめてでも頼めます。できた `lesson_plan.md` を読んで、直したいところを伝えてから③へ進んでください。
- ③では、作った教材をビルドし、画像にして見た目を確かめ、解答を検算してから報告するよう指示してあります。それでも、**最後は必ず人が PDF を見て確認**してください。

## 手で行う場合（生成 AI を使わない）

1. `templates/syllabus.md` を `courses/<科目>/syllabus.md` にコピーし、[SYLLABUS_FORMAT.md](SYLLABUS_FORMAT.md) に従って埋める。
2. `templates/lesson_plan.md` を `courses/<科目>/<NN>/lesson_plan.md` にコピーし、[LESSON_PLAN_FORMAT.md](LESSON_PLAN_FORMAT.md) に従って埋める。
3. `templates/` の `.tex` をコピーして教材を書き（[AUTHORING_GUIDE.md](AUTHORING_GUIDE.md)）、`texlua tools/build_all.lua courses/<科目>/<NN>` でビルドする。

ほかの生成 AI（ChatGPT など）を使う場合も、`.claude/skills/*/SKILL.md` の本文を指示として渡せば、同じ手順で作業させられます。

## 例

[`courses/basic_math/`](../courses/basic_math/) に、3段階すべての例があります。

- 科目：[`syllabus.md`](../courses/basic_math/syllabus.md)
- 授業計画と教材：第02・03・07・10・11回（各回のフォルダの `lesson_plan.md` と教材）
