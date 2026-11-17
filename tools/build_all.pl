#!/usr/bin/env perl
# リポジトリ内のすべての教材（ルート .tex）を latexmk でビルドする。
# Perl は TeX Live に同梱されているため、Windows / Mac / Linux で追加インストールなしに動く。
#
# 使い方（リポジトリのルートで）:
#   perl tools/build_all.pl            # すべてビルド
#   perl tools/build_all.pl courses    # courses/ 配下だけ
#   perl tools/build_all.pl --clean    # 中間ファイルを削除
#
# 「ルート .tex」とは、\documentclass を含むか、\input{slides} / \input{worksheet} で
# 本体を読み込むラッパー（handout.tex, worksheet_answers.tex）のこと。
# figures/ 内の TikZ 断片のように単独でビルドしないファイルは対象外になる。
use strict;
use warnings;
use File::Find;
use File::Basename;
use Cwd 'abs_path';
use File::Spec;

my $root = abs_path(dirname(abs_path(__FILE__)) . '/..');
chdir $root or die "cannot chdir to $root\n";

my $clean = grep { $_ eq '--clean' } @ARGV;
my @dirs  = grep { $_ ne '--clean' } @ARGV;
@dirs = ('templates', 'courses') unless @dirs;

my @targets;
find(sub {
  return unless /\.tex$/ && -f $_;
  return if $File::Find::dir =~ m{(^|/)(figures|build)(/|$)};
  open my $fh, '<:encoding(UTF-8)', $_ or return;
  local $/; my $src = <$fh>; close $fh;
  push @targets, $File::Find::name
    if $src =~ /^\s*\\documentclass/m || $src =~ /^\s*\\input\{(slides|worksheet)\}/m;
}, grep { -d } @dirs);
@targets = sort @targets;

my @failed;
for my $t (@targets) {
  my @cmd = ('latexmk', '-cd', ($clean ? '-c' : '-quiet'), $t);
  printf "%-60s ", $t;
  open my $oldout, ">&", \*STDOUT; open my $olderr, ">&", \*STDERR;
  open STDOUT, ">", File::Spec->devnull; open STDERR, ">&", \*STDOUT;
  my $rc = system(@cmd);
  open STDOUT, ">&", $oldout; open STDERR, ">&", $olderr;
  if ($rc == 0) { print "OK\n" } else { print "FAILED\n"; push @failed, $t }
}

if (@failed) {
  print "\nビルドに失敗したファイル:\n";
  for my $t (@failed) {
    (my $log = $t) =~ s/\.tex$/.log/;
    print "  $t\n";
    if (open my $lf, '<', $log) {
      my @err = grep { /^!|:\d+: / } <$lf>;
      print "    $_" for @err[0 .. ($#err < 4 ? $#err : 4)];
    }
  }
  exit 1;
}
printf "\n%d 件すべて成功しました。\n", scalar @targets unless $clean;
