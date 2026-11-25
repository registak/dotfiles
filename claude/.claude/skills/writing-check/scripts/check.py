#!/usr/bin/env python3
"""日本語の文書から、AI の書き癖として指摘されやすい箇所を数えて示す。

指摘は疑いで、直すかどうかは文脈で決める。終了コードは常に 0。
"""

from __future__ import annotations

import argparse
import json
import re
import statistics
import sys
from dataclasses import dataclass, field
from pathlib import Path

BENRI = ["支え", "つなぐ", "つなげ", "つなが", "届け", "となりで", "土台", "形にする", "形にし", "仕組み"]
ENSHUTSU = [
    "徹底的", "圧倒的", "劇的", "非常に", "極めて", "まさに", "本質的", "革新的", "包括的", "多角的",
    "画期的", "飛躍的", "シームレス", "例外なく", "一切", "他ならない", "不可欠", "鍵となる", "鍵を握る",
    "重要なのは", "と言えるでしょう", "ではないでしょうか", "いかがでしたか", "と言っても過言ではない",
]
MAEOKI = [
    "本資料では", "本記事では", "本稿では", "本ドキュメントでは", "本ページでは", "以下で詳しく", "見ていきましょう",
    "見ていきます", "まとめると", "要するに", "一般的に", "結論から言うと", "言うまでもなく", "ご存知の通り",
    "ご存じの通り", "以上のように", "以上を踏まえ", "このように、",
]
JOUCHOU = [
    "することができ", "することが可能", "という形で", "という形に", "というような", "といった形",
    "を行う", "を行い", "を行っ", "を実施する", "を実施し", "していく必要があ", "と思われます", "と考えられます",
]
HIYU = [
    "拾う", "拾い", "拾っ", "効く", "効い", "響く", "響い", "刺さる", "刺さっ", "潰す", "潰し", "吐く", "吐い",
    "投げる", "投げて", "宙に浮", "浮かび上が", "育ってい", "育てていく", "語ってい", "物語ってい", "入口", "受け口",
    "真実の源", "一級市民", "低くぶら下が", "重心を", "解像度", "腹落ち", "言語化", "深掘り", "紐づ", "紐付",
    "落とし込", "寄与", "担保", "醸成",
]
RENYOU = ["の確かめ", "の知らせ", "の突き合わせ", "の取り込み直し", "の読み直し", "の書き直し"]
UCHIKESHI = ["ではなく", "ではありません。", "ではない。", "わけではな", "だけではな", "にとどまら", "に留まら"]

EMOJI = re.compile("[\U0001F300-\U0001FAFF☀-➿⬀-⯿]")
BOLD = re.compile(r"\*\*[^*\n]+\*\*")
BOLD_LABEL = re.compile(r"^\s*(?:[-*+]|\d+[.)])\s+\*\*[^*\n]+\*\*\s*[:：]")
PLAIN_LABEL = re.compile(r"^\s*(?:[-*+]|\d+[.)])\s+[^\s:：。、]{2,12}[:：]\s*\S")
HEADING = re.compile(r"^(#{1,6})\s+(.*)$")
LIST_ITEM = re.compile(r"^\s*(?:[-*+]|\d+[.)])\s+(.*)$")
PAUSE_COMMA = re.compile(r"(?:^|[。！？\n])\s*[^\s、。]{1,6}(?:は|も|には|では|とは)、")
PAREN = re.compile(r"[（(]([^（）()]{16,})[）)]")
SENT_END = re.compile(r"[^。！？\n]*[。！？]")
NUM = re.compile(r"\d[\d,.]*\s*(?:%|％|人|名|件|社|円|万|億|回|本|枚|週|日|月|年|時間|分|倍|割|点|ページ|p)?")
LATIN = re.compile(r"[A-Za-z][A-Za-z0-9_.+-]{2,}")
KATAKANA = re.compile(r"[ァ-ヴー]{4,}")


@dataclass
class Finding:
    kind: str
    line: int
    text: str
    hint: str


@dataclass
class Doc:
    body: list[tuple[int, str]] = field(default_factory=list)
    headings: list[tuple[int, str]] = field(default_factory=list)
    items: list[tuple[int, str]] = field(default_factory=list)
    paragraphs: list[tuple[int, str]] = field(default_factory=list)


def parse(text: str) -> Doc:
    """コード、frontmatter、HTML コメント、引用、表の区切りを除いて行を分類する。"""
    doc = Doc()
    lines = text.splitlines()
    in_code = in_front = in_comment = False
    para: list[str] = []
    para_start = 0

    def flush() -> None:
        nonlocal para
        if para:
            doc.paragraphs.append((para_start, "".join(para)))
            para = []

    for i, raw in enumerate(lines, 1):
        s = raw.strip()
        if i == 1 and s == "---":
            in_front = True
            continue
        if in_front:
            in_front = s != "---"
            continue
        if s.startswith("```") or s.startswith("~~~"):
            in_code = not in_code
            flush()
            continue
        if in_code:
            continue
        if "<!--" in s:
            in_comment = "-->" not in s
            s = s.split("<!--")[0].strip()
            if not s:
                continue
        elif in_comment:
            in_comment = "-->" not in s
            continue
        if not s:
            flush()
            continue
        if s.startswith(">") or re.fullmatch(r"[|\-:\s]+", s):
            flush()
            continue
        s = re.sub(r"`[^`]*`", "", s)
        s = re.sub(r"\]\([^)]*\)", "]", s)
        s = re.sub(r"https?://\S+", "", s)
        m = HEADING.match(s)
        if m:
            flush()
            doc.headings.append((i, m.group(2).strip()))
            continue
        doc.body.append((i, s))
        m = LIST_ITEM.match(raw)
        if m:
            flush()
            doc.items.append((i, m.group(1).strip()))
        elif s.startswith("|"):
            flush()
        else:
            if not para:
                para_start = i
            para.append(s)
    flush()
    return doc


def sentences(doc: Doc) -> list[tuple[int, str]]:
    out = []
    for line, s in doc.body:
        for m in SENT_END.finditer(s):
            out.append((line, m.group(0).strip()))
    return out


def count_words(doc: Doc, words: list[str]) -> dict[str, list[int]]:
    hits: dict[str, list[int]] = {}
    for line, s in doc.body + doc.headings:
        for w in words:
            n = s.count(w)
            if n:
                hits.setdefault(w, []).extend([line] * n)
    return hits


def check(text: str, audience: str) -> tuple[list[Finding], dict[str, int]]:
    doc = parse(text)
    f: list[Finding] = []
    counts: dict[str, int] = {}
    sents = sentences(doc)

    bold = [(ln, m.group(0)) for ln, s in doc.body + doc.headings for m in BOLD.finditer(s)]
    counts["太字"] = len(bold)
    if len(bold) > 2:
        f.append(Finding("太字", bold[0][0], f"{len(bold)}か所（例: {bold[0][1]}）", "強調が本当に要る1〜2か所に絞る"))

    labels = [(ln, s) for ln, s in doc.body if BOLD_LABEL.match(s)]
    counts["太字ラベルとコロンの箇条"] = len(labels)
    for ln, s in labels[:5]:
        f.append(Finding("太字ラベルとコロンの箇条", ln, s[:40], "値のラベルは太字なしで残し、説明文のラベルは文に溶かす"))
    plain = [(ln, s) for ln, s in doc.body if PLAIN_LABEL.match(s) and not BOLD_LABEL.match(s)]
    counts["ラベルとコロンの箇条"] = len(plain)
    if len(plain) >= 4:
        f.append(Finding("ラベルとコロンの箇条", plain[0][0], f"{len(plain)}項目（例: {plain[0][1][:30]}）", "値でない説明文のラベルが並んでいないか確かめる"))

    hyougo = [(ln, h) for ln, h in doc.headings if "、" in h or h.endswith("。") or re.search(r"から.+へ$", h)]
    counts["読点や句点のある見出し"] = len(hyougo)
    for ln, h in hyougo[:8]:
        f.append(Finding("読点や句点のある見出し", ln, h, "言い切りの一文か、何の節かが分かる項目名にする"))
    for ln, h in doc.headings:
        if h.endswith("について") or "ではなく" in h or re.search(r"[（(][^0-9（）()]+[）)]$", h):
            f.append(Finding("見出しの形", ln, h, "「〜について」・打ち消し・後ろの括弧を外し、節の中身が分かる語にする"))

    for kind, words, limit, hint in [
        ("打ち消し", UCHIKESHI, 2, "誤解を正す・意味を絞る・注意を促すもの以外は肯定の文にする"),
        ("便利な語", BENRI, 3, "何が起きるかを書く。同じ語を繰り返さない"),
        ("調子を強める語", ENSHUTSU, 1, "削っても文が成り立つなら削る。言い換えない"),
        ("前置きや締めの定型", MAEOKI, 1, "いきなり中身から書く"),
        ("冗長な言い回し", JOUCHOU, 2, "「〜できる」「〜で進める」のように縮める"),
        ("比喩や直訳の候補", HIYU, 1, "指しているものを具体的な語で言えるなら、その語で書く。定着した言い方なら残す"),
        ("動詞を名詞にした言い方", RENYOU, 1, "「〜の確認」か「〜を確かめる」にする"),
    ]:
        hits = count_words(doc, words)
        total = sum(len(v) for v in hits.values())
        counts[kind] = total
        if total >= limit:
            detail = "、".join(f"{w}×{len(v)}（{','.join(map(str, v[:4]))}行）" for w, v in sorted(hits.items(), key=lambda x: -len(x[1])))
            f.append(Finding(kind, min(v[0] for v in hits.values()), detail, hint))

    for i in range(len(sents) - 1):
        a, b = sents[i][1], sents[i + 1][1]
        if re.search(r"では(?:ない|ありません)。$", a) and re.search(r"(?:です|だ|である|でした|だった)。$", b):
            f.append(Finding("2文に分けた否定対比", sents[i][0], f"{a} {b}"[:60], "打ち消しを削って肯定の1文にする。誤解を正す打ち消しなら残す"))

    dash = [(ln, s) for ln, s in doc.body + doc.headings if re.search(r"——|──|—|―{2}", s)]
    counts["ダッシュ"] = len(dash)
    for ln, s in dash[:3]:
        f.append(Finding("ダッシュ", ln, s[:40], "文として組み込むか、2文に分ける"))

    emoji = [(ln, s) for ln, s in doc.body + doc.headings if EMOJI.search(s)]
    counts["絵文字のある行"] = len(emoji)
    if len(emoji) >= 3:
        f.append(Finding("絵文字", emoji[0][0], f"{len(emoji)}行", "凡例のように役割があるものだけ残す"))

    parens = [(ln, m.group(0)) for ln, s in doc.body for m in PAREN.finditer(s) if re.search(r"[、。]", m.group(1)) and not m.group(1)[0].isdigit()]
    counts["文や列挙の入った括弧"] = len(parens)
    for ln, p in parens[:5]:
        f.append(Finding("文や列挙の入った括弧", ln, p[:50], "括弧の中身を本文に出す"))

    pause = [(ln, m.group(0).strip("。！？\n ")) for ln, s in doc.body for m in PAUSE_COMMA.finditer(s)]
    counts["短い主題の直後の読点"] = len(pause)
    if len(pause) >= 3:
        f.append(Finding("短い主題の直後の読点", pause[0][0], "、".join(p for _, p in pause[:6]), "誤読を防ぐ読点だけ残す"))

    long_s = [(ln, s) for ln, s in sents if len(s) > 90]
    counts["90字を超える文"] = len(long_s)
    for ln, s in long_s[:5]:
        f.append(Finding("90字を超える文", ln, f"{len(s)}字: {s[:30]}…", "主張が2つ以上なら分ける。長さだけを理由に削らない"))

    para_sents = [m.group(0) for _, p in doc.paragraphs for m in SENT_END.finditer(p)]
    keitai_re = re.compile(r"(?:です|ます|でした|ました|ません|でしょう|ください)[。！？]$")
    keitai = sum(1 for s in para_sents if keitai_re.search(s))
    joutai = sum(1 for s in para_sents if not keitai_re.search(s) and re.search(r"(?:だ|である|だった|ない|た|る|い)。$", s))
    counts["段落の文: です・ます"] = keitai
    counts["段落の文: だ・である"] = joutai
    if keitai and joutai and min(keitai, joutai) / (keitai + joutai) >= 0.15:
        f.append(Finding("文体の混在", doc.paragraphs[0][0], f"です・ます {keitai}文／だ・である {joutai}文", "文書の中でそろえる"))

    for label, seq in [("箇条", doc.items), ("段落", doc.paragraphs)]:
        run = 1
        for i in range(1, len(seq)):
            same = seq[i][1][:3] == seq[i - 1][1][:3] and len(seq[i][1]) > 8
            run = run + 1 if same else 1
            if run == 3:
                f.append(Finding("同じ書き出しの3連続", seq[i - 2][0], f"{label}が「{seq[i][1][:6]}…」で続く", "文の順序や主語を入れ替える。体言止めや疑問形で崩さない"))

    if audience == "external":
        lens = [len(p) for _, p in doc.paragraphs if len(p) >= 40]
        if len(lens) >= 5:
            cv = statistics.pstdev(lens) / statistics.mean(lens)
            counts["段落の長さのばらつき×100"] = round(cv * 100)
            if cv < 0.25:
                f.append(Finding("段落の長さがそろっている", doc.paragraphs[0][0], f"変動係数 {cv:.2f}（{len(lens)}段落）", "話題を均等に割り振らず、関心のあるところを厚く書く"))
        counts["箇条書きの行"] = len(doc.items)
        body_chars = sum(len(s) for _, s in doc.body) or 1
        if sum(len(s) for _, s in doc.items) / body_chars > 0.4:
            f.append(Finding("箇条書きが多い", doc.items[0][0], f"{len(doc.items)}項目", "社外発信の本文は段落で書く"))
        marks = sum(s.count("→") + s.count("：") + s.count("（") for _, s in doc.paragraphs)
        counts["段落内の矢印・コロン・丸括弧"] = marks
        if marks >= 5:
            f.append(Finding("記号が多い", doc.paragraphs[0][0], f"{marks}か所", "文として組み込む。消して不自然になるなら残す"))
    else:
        prose = [(ln, p) for ln, p in doc.paragraphs if len(p) >= 200]
        counts["200字を超える段落"] = len(prose)
        for ln, p in prose[:3]:
            f.append(Finding("長い段落", ln, f"{len(p)}字: {p[:25]}…", "社内の資料は1項目1論点の箇条に切り分ける"))

    return sorted(f, key=lambda x: x.line), counts


def tokens(text: str) -> set[str]:
    out = {re.sub(r"[\s,]", "", m.group(0)) for m in NUM.finditer(text)}
    out |= {m.group(0) for m in LATIN.finditer(text)}
    out |= {m.group(0) for m in KATAKANA.finditer(text)}
    return out


def new_facts(source: str, draft: str) -> list[str]:
    src = tokens(source)
    src_text = re.sub(r"[\s,]", "", source)
    return sorted(t for t in tokens(draft) - src if t not in src_text and not re.fullmatch(r"\d", t))


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("file", help="点検する文書。- で標準入力")
    ap.add_argument("--audience", choices=["internal", "external"], default="internal", help="社内の資料か社外発信か")
    ap.add_argument("--source", action="append", default=[], help="素材や元の文書。草稿にだけある数値・英字・カタカナ語を挙げる。複数指定できる")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()

    text = sys.stdin.read() if a.file == "-" else Path(a.file).read_text(encoding="utf-8")
    findings, counts = check(text, a.audience)
    added = new_facts("\n".join(Path(p).read_text(encoding="utf-8") for p in a.source), text) if a.source else None

    if a.json:
        json.dump({"findings": [vars(x) for x in findings], "counts": counts, "new_facts": added}, sys.stdout, ensure_ascii=False, indent=1)
        return

    print(f"# 指摘 {len(findings)}件（疑い。直すか残すかは文脈で決める）")
    for x in findings:
        print(f"- {x.line}行 [{x.kind}] {x.text}\n    → {x.hint}")
    if added is not None:
        print(f"\n# 素材にない数値・英字・カタカナ語 {len(added)}件（足した事実でないか確かめる）")
        if added:
            print("  " + "、".join(added))
    print("\n# 数の一覧（直す前後の比較に使う）")
    for k, v in counts.items():
        print(f"- {k}: {v}")


if __name__ == "__main__":
    main()
