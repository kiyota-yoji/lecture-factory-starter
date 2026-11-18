#!/usr/bin/env python3
"""tools/redact_pdf.py — 既存の授業資料の PDF から、第三者の素材（ロゴ・画面写真・写真など）を消した公開用の PDF を作る

既存の資料をリポジトリに入れるとき、元の PDF（source/original/、Git の外）から、
公開してよい版（source/<名前>_public.pdf）を作るための道具です。
消した場所には灰色の枠と「削除」の文字を置き、何かがあったことが分かるようにします。
くわしい使い方は docs/SOURCE_MATERIALS.md を見てください。

必要なもの：Python 3.9 以上と PyMuPDF（この作業をする人だけ。教材のビルドには不要）
    python3 -m pip install pymupdf

使い方（リポジトリのルートで）:
    # 指定したページの画像をすべて消す（ページ番号は 1 から。all ですべてのページ）
    python3 tools/redact_pdf.py 元.pdf 公開用.pdf --images 8,9,10,12

    # 画像ではない部分（文字・図形で描かれたロゴ、個人名など）を範囲で消す
    #   範囲はページの左上を原点とする pt 単位（1pt = 1/72 インチ）。--list で画像の位置が分かる
    python3 tools/redact_pdf.py 元.pdf 公開用.pdf --rect "35:500,330,700,400:締切の記載を削除"

    # 画像の一覧（ページ・位置・大きさ）を見るだけ
    python3 tools/redact_pdf.py 元.pdf --list

終わったら、消し残しがないかを自分の目で確かめること（pdftoppm で画像にする・pdfimages -list で画像が残っていないかを見る）。
"""
import argparse
import sys

try:
    import pymupdf
except ImportError:  # 古い PyMuPDF は fitz という名前
    try:
        import fitz as pymupdf
    except ImportError:
        sys.exit("PyMuPDF が見つかりません。 python3 -m pip install pymupdf で入れてください。")

DEFAULT_LABEL = "第三者の素材のため削除"
FILL = (0.85, 0.85, 0.85)


def parse_pages(spec, n):
    if spec.strip().lower() == "all":
        return list(range(1, n + 1))
    pages = []
    for part in spec.split(","):
        part = part.strip()
        if "-" in part:
            a, b = part.split("-")
            pages.extend(range(int(a), int(b) + 1))
        elif part:
            pages.append(int(part))
    for p in pages:
        if not 1 <= p <= n:
            sys.exit(f"ページ {p} はありません（全 {n} ページ）")
    return sorted(set(pages))


def parse_rect(spec):
    # "ページ:x0,y0,x1,y1[:ラベル]"
    parts = spec.split(":", 2)
    if len(parts) < 2:
        sys.exit(f"--rect の形が違います: {spec}（例: 35:500,330,700,400:説明）")
    coords = [float(v) for v in parts[1].split(",")]
    if len(coords) != 4:
        sys.exit(f"--rect の座標は4つ必要です: {spec}")
    return int(parts[0]), pymupdf.Rect(*coords), (parts[2] if len(parts) == 3 else DEFAULT_LABEL)


def image_rects(page):
    rects = []
    for info in page.get_image_info():
        r = pymupdf.Rect(info["bbox"]) & page.rect
        if not r.is_empty:
            rects.append(r)
    return rects


def add_box(page, rect, label):
    page.add_redact_annot(rect, fill=FILL)
    return (rect, label)


def draw_label(page, rect, label):
    page.draw_rect(rect, color=(0.55, 0.55, 0.55), width=0.6)
    size = max(4.0, min(9.0, rect.height / 3, rect.width / max(4, len(label)) * 1.6))
    page.insert_textbox(rect + (2, 2, -2, -2), label, fontname="japan", fontsize=size,
                        color=(0.3, 0.3, 0.3), align=pymupdf.TEXT_ALIGN_CENTER)


def main():
    ap = argparse.ArgumentParser(description="PDF から第三者の素材を消した公開用の PDF を作る")
    ap.add_argument("input")
    ap.add_argument("output", nargs="?")
    ap.add_argument("--images", help="画像を消すページ（例: 8,9,12-14 / all）")
    ap.add_argument("--rect", action="append", default=[], help='範囲で消す（例: "35:500,330,700,400:説明"）')
    ap.add_argument("--label", default=DEFAULT_LABEL, help=f"--images で消した場所に置く文字（既定: {DEFAULT_LABEL}）")
    ap.add_argument("--title", help="公開用 PDF の文書情報のタイトル（作成者などの文書情報は消す）")
    ap.add_argument("--list", action="store_true", help="画像の一覧を出すだけ")
    args = ap.parse_args()

    doc = pymupdf.open(args.input)
    if args.list:
        for i, page in enumerate(doc, 1):
            for r in image_rects(page):
                print(f"page {i}: {r.x0:.0f},{r.y0:.0f},{r.x1:.0f},{r.y1:.0f}  ({r.width:.0f}x{r.height:.0f}pt)")
        return
    if not args.output:
        sys.exit("出力するファイル名を指定してください")
    if not args.images and not args.rect:
        sys.exit("--images か --rect で、消すものを指定してください")

    todo = {}  # page_no -> [(rect, label, remove_text)]
    if args.images:
        for p in parse_pages(args.images, len(doc)):
            for r in image_rects(doc[p - 1]):
                todo.setdefault(p, []).append((r, args.label, False))
    for spec in args.rect:
        p, r, label = parse_rect(spec)
        if not 1 <= p <= len(doc):
            sys.exit(f"ページ {p} はありません（全 {len(doc)} ページ）")
        todo.setdefault(p, []).append((r, label, True))

    for p, items in sorted(todo.items()):
        page = doc[p - 1]
        remove_text = any(t for _, _, t in items)
        for r, _, _ in items:
            page.add_redact_annot(r, fill=FILL)
        page.apply_redactions(
            images=pymupdf.PDF_REDACT_IMAGE_REMOVE,
            graphics=pymupdf.PDF_REDACT_LINE_ART_NONE,
            text=pymupdf.PDF_REDACT_TEXT_REMOVE if remove_text else pymupdf.PDF_REDACT_TEXT_NONE,
        )
        for r, label, _ in items:
            draw_label(page, r, label)
        print(f"page {p}: {len(items)} か所を削除")

    title = args.title or (doc.metadata or {}).get("title", "") or ""
    doc.set_metadata({"title": title, "author": "", "subject": "", "keywords": "",
                      "creator": "", "producer": ""})
    doc.save(args.output, garbage=4, deflate=True, clean=True)

    # 消し残しの確認：処理したページに画像が残っていないか
    out = pymupdf.open(args.output)
    left = [p for p in todo if image_rects(out[p - 1]) and args.images and p in parse_pages(args.images, len(out))]
    if left:
        print("注意：画像が残っているページがあります:", ", ".join(map(str, left)))
        sys.exit(1)
    print(f"保存しました: {args.output}（画像の残り：処理したページには 0 個）")


if __name__ == "__main__":
    main()
