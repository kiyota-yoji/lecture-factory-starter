# 教材の作り方

新しい科目・授業回を作るときの手順と、書き方の約束事です。

---

## 1. フォルダを作る

1回分の教材は、`courses/<科目>/<回>/` の1つのフォルダにまとめます。科目のフォルダ名は半角英数字、回は2桁の番号にします。

```text
courses/
└─ my_course/
   ├─ syllabus.md          科目の概要と各回のテーマ（任意）
   ├─ 01/
   │  ├─ slides.tex        投影用スライド
   │  ├─ handout.tex       配布用（slides.tex を1ページ4枚に）
   │  ├─ worksheet.tex     ワークシート（学生用）
   │  ├─ worksheet_answers.tex  ワークシート（解答版）
   │  ├─ amc/exercise.tex  選択式問題
   │  └─ figures/          図
   └─ 02/
```

いちばん簡単なのは、`templates/` の中身をそのままコピーすることです。

```bash
mkdir -p courses/my_course/01
```

```bash
cp -r templates/slides/* templates/worksheet/* courses/my_course/01/
```

```bash
cp -r templates/amc courses/my_course/01/
```

Windows では、エクスプローラーで `templates\slides`・`templates\worksheet` の中のファイルと `templates\amc` フォルダを、新しいフォルダにコピーしても同じです。

`handout.tex` と `worksheet_answers.tex` は、それぞれ `slides.tex`・`worksheet.tex` を読み込むだけのファイルです。**編集するのは `slides.tex` と `worksheet.tex` だけ** で、配布用と解答版は自動で追従します。

## 2. スライド（`slides.tex`）

```latex
\documentclass[aspectratio=169]{beamer}
\usepackage{lfs-slides}
\lfscourse{基礎数学}              % フッター左に出る科目名

\title{微分法の基礎}
\subtitle{基礎数学 第07回}
```

### 書き方の方針

- **1枚に1つのメッセージ。** 伝えたいことを `\lfsmessage{...}` で1行にし、残りは図と短い補足にします。
- 説明の文章をスライドに詰め込まず、ワークシートや配布資料に回します。
- 数式は大きく、少なく。1枚に式は2〜3行までを目安にします。

```latex
\begin{frame}{微分係数は「接線の傾き」}
  \lfsmessage{$f'(a)$ は、点 $(a, f(a))$ での接線の傾き}
  \begin{center}
    \input{figures/tangent}
  \end{center}
\end{frame}
```

## 3. ワークシート（`worksheet.tex`）

```latex
\documentclass[a4paper,11pt]{ltjsarticle}
\usepackage{lfs-worksheet}

\begin{document}
\lfsheader{基礎数学}{第07回 ワークシート}

\problem{$f(x) = x^2$ の $x = 3$ における微分係数を求めなさい。}
\answerbox[3cm]{$f'(x) = 2x$ より $f'(3) = 6$}
```

- `\problem{問題文}` で「問1」「問2」…と番号が付きます。
- `\answerbox[高さ]{解答}` は記入欄です。学生用では空欄、解答版では赤字で解答が入ります。
- **記入欄の大きさは、答えの長さではなく、途中式を書くのに必要な広さで決めます。** 枠の大きさから答えが推測できないよう、同じ種類の欄は同じ高さにそろえてください。
- 小問 (1)(2) がある場合は、小問ごとに `\answerbox` を分けます（1つの枠にまとめると書く場所が足りなくなります）。

## 4. 選択式問題（`amc/exercise.tex`）

[Auto Multiple Choice](https://www.auto-multiple-choice.net/) の形式で書きます。この形式で書いておけば、TeX だけで問題用紙の PDF が作れます。AMC 本体を入れれば、マークシートとして自動採点もできます。

```latex
\element{basic}{
  \begin{question}{Q1}
    $f(x) = x^2$ のとき $f'(3)$ の値は？
    \begin{choices}
      \wrongchoice{$3$}
      \correctchoice{$6$}
      \wrongchoice{$9$}
    \end{choices}
  \end{question}
}
```

- `\element{グループ名}{...}` で問題を定義し、`\onecopy` の中の `\insertgroup{グループ名}` で並べます。
- `{Q1}` の部分は問題の ID です。**同じファイルの中で重複しないように** します（採点結果はこの ID で集計されます）。
- **ファイルの1行目の `%%AMC:latex_engine=lualatex` は消さないでください。** AMC 本体がこの行を見て LuaLaTeX を選びます。
- `\AMCrandomseed{数字}` は、問題と選択肢の並び順を決める乱数の種です。**一度印刷したら変えないでください**（変えると、印刷した用紙と採点用のレイアウトが一致しなくなります）。回ごとに違う数字にしておくと、並び順が回ごとに変わります。
- 学籍番号の桁数は `\AMCcodeGridInt[h]{student}{8}` の `8` で変えます。

## 5. 図（`figures/`）

- 図は各回の `figures/` に置きます。スライド・ワークシートでは `figures/` を書かずにファイル名だけで読み込めます（`\includegraphics{graph.pdf}`）。
- TikZ で描いた図は、`figures/tangent.tex` のように別ファイルにして `\input{figures/tangent}` で読み込むと、スライドとワークシートで使い回せます。
- **Web で拾った画像・教科書や他の資料の図は使わないでください。** このリポジトリの教材は CC BY-SA 4.0 で公開するため、自分で作った図か、利用条件が明確な素材（出典を明記）に限ります。

## 6. ビルドと確認

```bash
latexmk -cd courses/my_course/01/slides.tex
```

```bash
texlua tools/build_all.lua courses/my_course
```

- ビルドが通っても、**解答版は必ず PDF を目で見て確認** してください。字形の誤り（例：`\mathbf{\vec{c}}` が別の文字になる）はエラーにならず、見た目にしか出ません。
- 印刷するスライドは、[TROUBLESHOOTING.md](TROUBLESHOOTING.md#スライドの-pdf-を-adobe-acrobat-から印刷するとエラーになる) の印刷用 PDF も作っておくと、当日の印刷トラブルを避けられます。

## 7. 書き方の約束事（まとめ）

| 項目 | 約束 |
|---|---|
| ファイル名・フォルダ名 | 半角英数字・`_` のみ（日本語・空白なし） |
| 文字コード | UTF-8 |
| 区切りのスラッシュ | 半角 ` / `（全角「／」は `\quad` の直後でエラーになる） |
| 太字のベクトル | `\boldsymbol{\vec{a}}`（`\mathbf` で包まない） |
| 図 | 自作か、利用条件が明確なものだけ（出典を明記） |
