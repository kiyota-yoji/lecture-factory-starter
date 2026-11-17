# lecture-factory-starter の latexmk 設定（Windows / Mac / Linux 共通）
#
# - エンジンは LuaLaTeX
# - templates/preamble と vendor/ を TeX の検索パスに追加する
#   （どの授業回のフォルダからビルドしても \usepackage{lfs-slides} 等が見つかる）
#
# 使い方: リポジトリのルートで
#   latexmk -cd courses/example/01/slides.tex
# VS Code（LaTeX Workshop）からは .vscode/settings.json の設定で自動的にこのファイルが使われます。

use File::Basename;
use File::Spec;
use Cwd 'abs_path';

$pdf_mode = 4;   # 4 = LuaLaTeX
$lualatex = 'lualatex -file-line-error -interaction=nonstopmode -synctex=1 -halt-on-error %O %S';
$max_repeat = 5;

# リポジトリのルートを探す。latexmk は rc ファイルを eval で読むため __FILE__ は使えない。
# (1) latexmk が保持している rc ファイルの絶対パス、(2) 現在のフォルダから上へ辿る、の順で探す。
my $lfs_root;
my $lfs_marker = File::Spec->catfile('templates', 'preamble', 'lfs-fonts.sty');
if (defined $abs_rc && -e File::Spec->catfile(dirname($abs_rc), $lfs_marker)) {
  $lfs_root = dirname($abs_rc);
} else {
  my $d = abs_path('.');
  while (1) {
    if (-e File::Spec->catfile($d, $lfs_marker)) { $lfs_root = $d; last }
    my $up = dirname($d);
    last if $up eq $d;
    $d = $up;
  }
}
die "lecture-factory-starter: リポジトリのルートが見つかりません\n" unless defined $lfs_root;
ensure_path('TEXINPUTS',
  File::Spec->catdir($lfs_root, 'templates', 'preamble') . '//',
  File::Spec->catdir($lfs_root, 'vendor') . '//');

# latexmk -c で消す追加ファイル
$clean_ext = 'nav snm vrb synctex.gz amc xy';
