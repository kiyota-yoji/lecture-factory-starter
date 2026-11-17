% AIビジネス入門 サンプル共通：色と、よく使うスライドの型（CC BY-SA 4.0）
% slides.tex のプリアンブルで \input{../aib-common.tex.inc} として読み込む
\usetikzlibrary{positioning,shapes.geometric,decorations.pathreplacing}

\definecolor{boom}{RGB}{214,90,49}
\definecolor{winter}{RGB}{70,110,170}
\definecolor{genai}{RGB}{140,70,160}
\definecolor{gain}{RGB}{50,135,85}

% 見出しスライド
\newcommand{\sectionframe}[1]{%
  \begin{frame}{}
  \begin{center}{\Huge #1}\end{center}
  \end{frame}}

% 問いかけスライド（受講者が考えて書く・話し合う）
\newcommand{\thinkframe}[1]{%
  \begin{frame}{}
  \begin{center}\vspace{1em}{\LARGE #1}\end{center}
  \vfill\hfill{\small\colorbox{genai!15}{\textbf{考えてみよう}}}
  \end{frame}}
