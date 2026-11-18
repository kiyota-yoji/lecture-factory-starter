---
name: lesson-materials
description: Use this skill when the user wants to generate the teaching materials for a class session in this repository — Beamer slides, the handout, the worksheet with its answer version, the multiple-choice check quiz in AMC format, and optionally a lecture script — from that session's lesson_plan.md, then build and check them. Trigger on requests like「第07回の教材を作って」「授業計画からスライドとワークシートを作って」「lesson_plan.md から教材一式を起こして」「確認問題を作って」, even if the user names only one of the materials.
---

# 授業計画から教材一式を作る

`courses/<course_id>/<NN>/lesson_plan.md` を元に、`outputs` に挙げられた教材を作り、ビルドして点検します。
教材の書き方の基本は [`docs/AUTHORING_GUIDE.md`](../../../docs/AUTHORING_GUIDE.md)、つまずきやすい点は [`docs/TROUBLESHOOTING.md`](../../../docs/TROUBLESHOOTING.md) にあります。

## 1. 最初に確かめること

| 項目 | 確かめ方 |
|---|---|
| `lesson_plan.md` がある | なければ先に `lesson-plan` スキルを勧める |
| 作る教材 | front matter の `outputs`（教員が一部だけを求めたら、それだけ作る） |
| 既存の教材 | 同じフォルダに `.tex` があれば、上書きする前に教員に確かめる |
| 科目の方針 | `courses/<course_id>/syllabus.md` の `# 教材の作り方` と `# 表記の約束` |
| 既存の資料から作り直す回か | `source/SOURCES.md` があれば読む。`lesson_plan.md` の `# 元資料との対応` に従い、ロゴ・画面写真などは使わない（[SOURCE_MATERIALS.md](../../../docs/SOURCE_MATERIALS.md)）。できたら原本と並べて、抜け・順番の違いがないかを見比べる |

## 2. ファイルを用意する

`templates/` から、`outputs` に応じてコピーします。

| `outputs` | コピー元 → コピー先（`courses/<course_id>/<NN>/` の中） |
|---|---|
| `slides` | `templates/slides/slides.tex` → `slides.tex` |
| `handout` | `templates/slides/handout.tex` → `handout.tex`（中身は書き換えない） |
| `worksheet` | `templates/worksheet/worksheet.tex`・`worksheet_answers.tex` → 同名（`worksheet_answers.tex` は書き換えない） |
| `exercise` | `templates/amc/exercise.tex` → `amc/exercise.tex` |
| `lecture_script` | （テンプレートなし。`courses/ai_business/09/lecture_script.md` を形の参考にする） |

図は `figures/` に TikZ の断片（`figures/<名前>.tex`）として置き、`\input{figures/<名前>}` で読み込みます。

コピーしたファイルの冒頭の説明コメント（「〜の雛形」）は、`% <科目名> 第NN回 <タイトル>（CC BY-SA 4.0）` のような1行に書き換えます。

## 3. 書く

### スライド（`slides.tex`）

- `\lfscourse{科目名}`、`\title`、`\subtitle{科目名 第NN回}` を設定する。
- `# スライド設計` の1行メッセージの順に、1枚ずつ作る。各スライドは `\lfsmessage{1行メッセージ}` ＋ 図 ＋ 短い補足。説明の文章を詰め込まない。
- `# 授業の流れ` の順番・区切りと一致させる。演習の時間にはその合図のスライドを置く。
- 最初に「今日のねらい」、最後に「まとめ」（`# 強調したいポイント`）と次回予告（`## 次回へ`）。
- 図は TikZ で描く。外部の画像を使わない。

### ワークシート（`worksheet.tex`）

- `\lfsheader{科目名}{第NN回 タイトル ワークシート}`。
- `# ワークシート設計` の問題ごとに `\problem{問題文}` と `\answerbox[高さ]{解答}`。解答は途中式を含めて書く（解答版に表示される）。
- 図と記入欄を横に並べるときは `minipage` を2つ並べる（`courses/basic_math/03/worksheet.tex` の問3が例）。A4 で1〜2ページに収める。
- 同じ種類の記入欄は同じ高さにそろえる。小問は小問ごとに欄を分ける。

### 確認問題（`amc/exercise.tex`）

- 1行目の `%%AMC:latex_engine=lualatex` を消さない。
- `\AMCrandomseed{YYNN01}` のように、回ごとに違う数字にする（YY＝年度の下2桁、NN＝回）。
- `# 確認問題の設計` の問題ごとに `\element{グループ}{\begin{question}{ID}...}`。ID は `<略号><NN>-Q1` のように一意にする。略号は科目 ID の頭文字を大文字にしたもの（`basic_math` → `BM`、`ai_business` → `AIB`）。
- 問の順番は `# 確認問題の設計` の順に固定する（`\shufflegroup` は使わない。選択肢の順番は AMC が入れ替える）。
- 選択肢が短いときは `choiceshoriz`、文章のときは `choices`。正解は `\correctchoice`。

### 講義台本（`lecture_script.md`）

スライドの見出しごとに、話す内容の骨子を `>` で書き、言い回しや事実の注意を `⚠` で添える。冒頭に、ねらい・時間配分の表・削る順を置く。

## 4. ビルドして点検する（必ず行う）

1. リポジトリのルートで `texlua tools/build_all.lua courses/<course_id>/<NN>` を実行し、すべて `OK` になるまで直す。エラーは `.log` の `!` の行と [`docs/TROUBLESHOOTING.md`](../../../docs/TROUBLESHOOTING.md) を見る。
2. `.log` に `Overfull` がないか確かめる（`grep -c Overfull <ファイル>.log`）。スライドでは、はみ出した枚の図や文字を小さく・短くする。どの枚かは、`.log` の `Overfull` の行の**直後に最初に出てくる `[数字`** がページ番号（＝スライドの番号）。
3. **見た目を確かめる**：ページを画像にして目で見る。スライドは `slides.pdf` を 1枚ずつ 100〜150dpi で（`pdftoppm -r 120 -png -f N -l N slides.pdf 出力名`）、ワークシート・確認問題は 60〜80dpi で見る。ハンドアウト（4枚を1ページ）では小さすぎて重なりが分からない。図の向き・ラベルの重なり・記入欄の大きさ・問題文と記入欄がページで離れていないかを確かめる。
4. **正解を検算する**：ワークシートの解答と確認問題の正解を、計算スクリプトなどで機械的に確かめる。
5. 次の既知の落とし穴を避けているか確かめる：
   - `\quad` の直後に全角の「／」を置かない（半角 ` / ` にする）
   - ベクトルを含む式を `\mathbf` で包まない（`\boldsymbol` を使う）
   - 確認問題の誤答の選択肢に、正解と同じ値が混ざっていない

## 5. 報告する

作ったファイル、ビルドの結果、目で見て直したこと、検算した結果、`lesson_plan.md` から変えた点（あれば `lesson_plan.md` も直す）を教員に報告します。

## してはいけないこと

- `lesson_plan.md` にない内容を勝手に足さない（足すなら先に `lesson_plan.md` を直し、教員に伝える）。
- 教科書の問題文・図、外部の画像を写さない。
- ビルドと点検をせずに「できた」と報告しない。
