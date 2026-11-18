#!/usr/bin/env bash
# tools/publish_wiki.sh — wiki/ の原稿を GitHub の Wiki に写す（メンテナー用）
#
# 前提：
#   ・GitHub のリポジトリの「Wiki」タブで、最初のページを1度だけ手で作ってあること
#     （Wiki の保存場所 <リポジトリ>.wiki.git は、最初のページを作るまで存在しない）
#   ・git が使え、Wiki に push できる権限があること
#
# 使い方（リポジトリのルートで）:
#   tools/publish_wiki.sh            差分を見せてから、確認のうえ push する
#   tools/publish_wiki.sh --dry-run  差分を見せるだけ（push しない）
#
# wiki/README.md は写さない。Wiki にだけあるページは消す（原稿は wiki/ が正）。
set -euo pipefail

cd "$(dirname "$0")/.."
DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1

texlua tools/check_wiki.lua

ORIGIN=$(git remote get-url origin)
WIKI_URL="${ORIGIN%.git}.wiki.git"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

if ! git clone --quiet "$WIKI_URL" "$WORK/wiki"; then
  echo "Wiki のリポジトリを取得できませんでした: $WIKI_URL"
  echo "GitHub の Wiki タブで、最初のページを1度だけ作ってから実行してください。"
  exit 1
fi

# Wiki 側の .md をいったん消して、原稿で置き換える
find "$WORK/wiki" -maxdepth 1 -name '*.md' -delete
for f in wiki/*.md; do
  [ "$(basename "$f")" = "README.md" ] && continue
  cp "$f" "$WORK/wiki/"
done

cd "$WORK/wiki"
git add -A
if git diff --cached --quiet; then
  echo "Wiki は原稿と同じです。写すものはありません。"
  exit 0
fi
git -c core.quotepath=false diff --cached --stat
[ $DRY -eq 1 ] && { echo "(dry-run: push しません)"; exit 0; }

read -r -p "この内容で Wiki に push しますか？ [y/N] " ans
[ "$ans" = "y" ] || { echo "中止しました。"; exit 1; }
SRC=$(cd - >/dev/null && git rev-parse --short HEAD)
git commit --quiet -m "wiki/ の原稿から更新（リポジトリ ${SRC}）"
git push --quiet
echo "Wiki を更新しました。"
