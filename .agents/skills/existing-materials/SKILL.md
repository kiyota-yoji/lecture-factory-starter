---
name: existing-materials
description: Use this skill when the user already has teaching materials for a class session in another format (PowerPoint, Google Slides, Keynote, Word, or a PDF exported from them) and wants to bring them into this repository — placing the original safely outside Git, checking each page for third-party content (logos, screenshots, photos, others' figures), operational details and facts to verify, recording the result in source/SOURCES.md, optionally producing a redacted public copy, and writing a transcription-mode lesson_plan.md so that the lesson-materials skill can rebuild the slides in LaTeX. Trigger on requests like「既存の授業資料を取り込みたい」「この PDF（PowerPoint）をもとに第08回を作り直して」「去年のスライドをこのリポジトリの形にして」「既存資料から lesson_plan を起こして」, even if the user only attaches a file.
---

# 既存の授業資料を取り込んで作り直す

PowerPoint・Google スライド・PDF などの既存の資料を、このリポジトリの形（`lesson_plan.md` と LaTeX の教材）に作り直します。
置き場所と扱いの約束は [`docs/SOURCE_MATERIALS.md`](../../../docs/SOURCE_MATERIALS.md) にあります。**最初に全部読んでください。**
例は [`courses/ai_business/08/`](../../../courses/ai_business/08/)（Google スライドの PDF から作り直した回）です。

このスキルの範囲は、原本の置き場所・点検・記録（`SOURCES.md`）・公開用の写し・書き起こしの `lesson_plan.md` までです。教材（`.tex`）は、教員の確認のあとで `lesson-materials` スキルで作ります。

## 1. 最初に確かめること

| 項目 | 確かめ方・決め方 |
|---|---|
| 科目 ID と回 | 原本の表紙・ファイル名と `courses/<course_id>/syllabus.md` の授業計画を照らし合わせる。`syllabus.md` がなければ先に `syllabus-markdown` スキルを勧める |
| 原本のファイル | PDF が最も扱いやすい。PowerPoint・Keynote・Google スライドは、教員に PDF への書き出しを頼む（元の形式のファイルも一緒に置いてよい） |
| 原本の作者 | 教員本人が作ったものか。**他の人が作った資料なら、作者の了解と公開してよいかを教員に確かめるまで進めない** |
| 学生の情報 | 原本に学生の名前・提出物・成績などが写っていないか。写っていたら、**リポジトリに置かずに**教員に知らせる |
| 作り直しの度合い | 既定は「**書き起こし**」：内容と順番は原本のまま、形（スライドの型・色・ページ構成）と、公開できない素材の置き換えだけを変える。内容まで直す（改訂）ときは、教員の指示を受けてから |
| 既存のファイル | 回のフォルダに `lesson_plan.md` や `.tex` があれば、上書きする前に教員に確かめる |

## 2. 原本を置く

1. `courses/<course_id>/<NN>/source/original/` を作り、原本を `<略号NN>_original.<拡張子>` の名前でコピーする（例：`aib08_original.pdf`。略号は科目 ID の頭文字の小文字）。元の場所のファイルは動かさない・消さない。
2. `git status --ignored courses/<course_id>/<NN>` で、`source/original/` が無視されている（`!!` が付く）ことを確かめる。

## 3. 中身を読み出して点検する

1. **文字**：`pdftotext -layout <原本>.pdf -` で読み出す。PDF を直接読む機能で読んだ文字は、康熙部首（`⼈` など見た目が同じ別の文字）が混ざることがあるので、`pdftotext` と照らし合わせ、Unicode の NFKC で正規化する。
2. **見た目**：`pdftoppm -r 40 -png` で全ページを画像にし、一覧にして見る（ImageMagick があれば `montage -tile 5x7`）。細かいところは 100dpi 前後で1ページずつ見る。
3. **画像**：`pdfimages -list <原本>.pdf` で、画像のあるページ・大きさを調べる（`python3 tools/redact_pdf.py <原本>.pdf --list` なら位置も出る）。画像のあるページは必ず目で見て、何の画像か（ロゴ・画面写真・写真・自作の図）を判断する。
4. ページごとに、[`docs/SOURCE_MATERIALS.md`](../../../docs/SOURCE_MATERIALS.md) §2 の表の種類（ロゴ・画面写真・写真・他の人の図表・引用・運用上の情報・個人の名前・年号や数値）に当たるものを書き出す。
5. **事実を確かめる**：年号・数値・企業の事例は、発表元の沿革・プレスリリース・統計などの一次資料で確かめる（Web ページを取得する機能を使う。Claude Code なら WebSearch・WebFetch）。
   - 原本の誤りは、作り直す教材では正しく直し、`SOURCES.md` の `## 事実の確認` に「原本の記述・確かめた結果・出典」を書く。
   - 一次資料で確かめられないものは、教材では使わないか、教員の見解として書き分け、`## 未確定事項` に書く。
   - 「〜の失敗例」のような評価・解釈は、事実として断定しない書き方にする。

## 4. 記録を書く（`source/SOURCES.md`）

[`docs/SOURCE_MATERIALS.md`](../../../docs/SOURCE_MATERIALS.md) §4 の形で書く。ページごとの点検の表は、**全ページ**について書く（素材のないページも「なし」と書く）。

## 5. 公開用の写しを作る（教員が求めたとき）

1. `tools/redact_pdf.py` で、第三者の素材を消した `source/<略号NN>_public.pdf` を作る。消す理由ごとにラベルを変えるときは、出力を次の入力にして分けて実行する。
   - PyMuPDF がなければ、教員の了解を得て `python3 -m pip install pymupdf` で入れる（仮想環境を使ってよい）。
2. 実行したコマンドを `SOURCES.md` の `## 公開用の写しの作り方` にそのまま書く（パスはリポジトリのルートから）。
3. 確かめる：`pdfimages -list` で画像が 0 個（消すべきものだけのとき）、`pdftoppm -r 60` で消したページを見て、消し残し・消しすぎ（タイトルの文字まで消えていないか）がないか。`pdfinfo` で作成者などの文書情報が消えているか。
4. `git status` で `_public.pdf` が追加の対象になっていること（原本は出てこないこと）を確かめる。

## 6. 書き起こしの `lesson_plan.md` を書く

`lesson-plan` スキルの手順に従い、[`docs/LESSON_PLAN_FORMAT.md`](../../../docs/LESSON_PLAN_FORMAT.md) §4 の「既存の資料からの書き起こし」で書く。特に次を守る。

- `references` に `source/SOURCES.md` と、公開用の写しがあればそのファイルを挙げる。
- `# スライド設計` は原本のページの順に、1ページ＝1枚を基本にする。表紙・講義計画のような科目共通のページを省くとき、原本の1ページを2枚に分けるときは、その旨を書く。
- `# 元資料との対応` に、原本のページ → 新しいスライドの番号と扱い（そのまま／書き換え／模式図に置き換え／削除／追加）を表で書く。**原本にない内容を足したところ**（`syllabus.md` の「1回の授業の型」に合わせて足した問いかけなど）は「追加」と明記する。
- 原本と `syllabus.md` の食い違い（授業の型・評価・課題の字数・締切の決め方など）は、勝手にどちらかに合わせず、`# 未確定事項` に書く。ただし、運用上の情報（年度・締切の日付・LMS の名前）は教材に持ち込まない。
- 原本に問題の中身がない教材（例：「小テスト」のページだけで問題がない）を `outputs` に入れるときは、原本にない新しい内容として作ることを `# 元資料との対応` と `# 教員レビュー項目` に書く。

## 7. 報告して確認を待つ

教員に次を短く報告し、「この設計で教材を作ってよいか」を確かめる。

- 置いたファイルと、Git に入るもの・入らないもの（`git status` の結果）
- 見つけた第三者の素材と、その扱い
- 事実の確認で見つかった原本の誤り
- `# 元資料との対応` の要点（削除・置き換え・追加したところ）と `# 未確定事項`

教員が最初から「教材まで作って」と頼んでいた場合は、報告のあと `lesson-materials` スキルに進む。そのとき、次も守る。

- ロゴは使わず、サービス名を文字で書く。画面写真は TikZ の模式図にし、「〇〇の画面の例（模式図）」と書く。
- 原本の見た目（色・レイアウト）をまねる必要はない。科目の `syllabus.md` の `# 教材の作り方` と、同じ科目の他の回の型に合わせる。
- 作り直した PDF を、原本と並べて見比べ、内容の抜け・順番の入れ替わりがないかを確かめる。

## してはいけないこと

- 原本・学生の情報・教科書のスキャンを Git に入れない（`source/original/` の外に原本を置かない）。
- 原本のロゴ・画面写真・写真・他の人の図を、教材に貼らない（画像として切り出して `figures/` に置くことも含む）。
- 一次資料で確かめていない年号・数値を、原本にあったという理由だけで使わない。
- 原本の誤りや `syllabus.md` との食い違いを、記録せずに黙って直さない。
