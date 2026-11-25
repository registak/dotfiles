#!/usr/bin/env node
// 変更がコメントだけに収まっているかを確かめる。対象のリポジトリの直下で実行する。
//
//   node check-comment-only.mjs [--base <ref>] [--to <ref>] [パス...]
//   node check-comment-only.mjs --list <パス...>
//
// --base の既定は HEAD。--to を省くと作業ツリーと比べる。--list はコメントを行番号つきで並べる。

import { execFileSync } from "node:child_process";
import { readFileSync, existsSync } from "node:fs";
import { createRequire } from "node:module";
import { basename, dirname, extname, join, resolve } from "node:path";

const SCRIPT_EXTENSIONS = new Set([".ts", ".tsx", ".mts", ".cts", ".js", ".jsx", ".mjs", ".cjs"]);
const JS_EXTENSIONS = new Set([".js", ".jsx", ".mjs", ".cjs"]);
const HASH_EXTENSIONS = new Set([".sh", ".bash", ".zsh", ".yml", ".yaml", ".toml", ".py", ".rb"]);
const HASH_NAMES = /^(Dockerfile(\..+)?|\.env(\..+)?|\.gitignore|\.dockerignore|\.npmrc|\.nvmrc|Makefile)$/;

const DIRECTIVE =
  /eslint-(disable|enable)|@ts-(expect-error|ignore|check|nocheck)|prettier-ignore|biome-ignore|istanbul ignore|c8 ignore|v8 ignore|<reference|turbopackIgnore|webpack[A-Z]\w*:|@vite-ignore|[@#]__PURE__|@jsx|@license|@preserve|^#!|^#\s*(syntax|escape)=|shellcheck|hadolint|yamllint/;
const JSDOC_TYPE = /@(type|param|returns?|typedef|template|satisfies)\b/;

function git(args) {
  return execFileSync("git", args, { encoding: "utf8", maxBuffer: 256 * 1024 * 1024 });
}

function readAt(ref, file) {
  if (ref === null) return existsSync(file) ? readFileSync(file, "utf8") : null;
  try {
    return git(["show", `${ref}:${file}`]);
  } catch {
    return null;
  }
}

function fileKind(file) {
  const ext = extname(file);
  if (SCRIPT_EXTENSIONS.has(ext)) return "script";
  if (ext === ".css" || ext === ".scss") return "css";
  if (HASH_EXTENSIONS.has(ext) || HASH_NAMES.test(basename(file))) return "hash";
  return null;
}

let typescript;
function loadTypeScript() {
  if (typescript) return typescript;
  // git worktree には node_modules が無いので、元のリポジトリからも探す。
  const roots = [process.cwd()];
  try {
    roots.push(dirname(resolve(git(["rev-parse", "--git-common-dir"]).trim())));
  } catch {
    // git の外では作業ディレクトリだけを探す。
  }
  for (const root of roots) {
    try {
      typescript = createRequire(join(root, "package.json"))("typescript");
      return typescript;
    } catch {
      continue;
    }
  }
  throw new Error("typescript を解決できません。対象のリポジトリの直下で実行し、依存を入れておいてください。");
}

function scriptComments(text, file) {
  const ts = loadTypeScript();
  const ext = extname(file);
  const kind =
    ext === ".tsx" ? ts.ScriptKind.TSX : ext === ".jsx" ? ts.ScriptKind.JSX : JS_EXTENSIONS.has(ext) ? ts.ScriptKind.JS : ts.ScriptKind.TS;
  const source = ts.createSourceFile(file, text, ts.ScriptTarget.Latest, true, kind);
  const found = new Map();
  const add = (ranges) => {
    for (const range of ranges ?? []) found.set(range.pos, range.end);
  };
  const jsxTagEnd = (node) =>
    node.kind === ts.SyntaxKind.GreaterThanToken &&
    node.parent !== undefined &&
    (ts.isJsxOpeningElement(node.parent) ||
      ts.isJsxClosingElement(node.parent) ||
      ts.isJsxSelfClosingElement(node.parent) ||
      ts.isJsxOpeningFragment(node.parent) ||
      ts.isJsxClosingFragment(node.parent));
  const visit = (node) => {
    if (node.kind >= ts.SyntaxKind.FirstJSDocNode && node.kind <= ts.SyntaxKind.LastJSDocNode) return;
    if (node.kind !== ts.SyntaxKind.JsxText) {
      add(ts.getLeadingCommentRanges(text, node.getFullStart()));
      // JSX のタグの直後は文字列なので、そこの // をコメントとして読まない。
      if (!jsxTagEnd(node)) add(ts.getTrailingCommentRanges(text, node.getEnd()));
    }
    for (const child of node.getChildren(source)) visit(child);
  };
  visit(source);
  if (text.startsWith("#!")) {
    const end = text.indexOf("\n");
    found.set(0, end === -1 ? text.length : end);
  }
  return [...found].map(([pos, end]) => ({ pos, end })).sort((a, b) => a.pos - b.pos);
}

function cssComments(text) {
  const ranges = [];
  for (const match of text.matchAll(/\/\*[\s\S]*?\*\//g)) {
    ranges.push({ pos: match.index, end: match.index + match[0].length });
  }
  return ranges;
}

// 行末の # はシェルや YAML の文字列と見分けられないので、行全体がコメントの行だけを数える。
function hashComments(text) {
  const ranges = [];
  let pos = 0;
  for (const line of text.split("\n")) {
    const indent = line.match(/^\s*/)[0].length;
    if (line[indent] === "#") ranges.push({ pos: pos + indent, end: pos + line.length });
    pos += line.length + 1;
  }
  return ranges;
}

function commentsOf(text, file) {
  const kind = fileKind(file);
  if (kind === "script") return scriptComments(text, file);
  if (kind === "css") return cssComments(text);
  if (kind === "hash") return hashComments(text);
  return null;
}

function lineOf(text, pos) {
  let line = 1;
  for (let i = 0; i < pos; i++) if (text.charCodeAt(i) === 10) line++;
  return line;
}

// コメントを抜いた残り。コメントだけだった行は落とし、行末コメントのあった行は行末の空白を落とす。
// コメントの無い行は1文字も変えないので、空行やインデントの変更は差として残る。
function skeleton(text, ranges) {
  const inComment = new Uint8Array(text.length);
  for (const { pos, end } of ranges) inComment.fill(1, pos, end);
  const lines = [];
  let code = "";
  let hadComment = false;
  const flush = () => {
    if (!hadComment) lines.push(code);
    else {
      const trimmed = code.trim();
      if (trimmed !== "" && trimmed !== "{}") lines.push(code.replace(/\s+$/, ""));
    }
    code = "";
    hadComment = false;
  };
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (ch === "\n") {
      if (inComment[i]) hadComment = true;
      flush();
      if (inComment[i]) hadComment = true;
      continue;
    }
    if (inComment[i]) hadComment = true;
    else code += ch;
  }
  flush();
  return lines;
}

function directivesOf(text, ranges, file) {
  const js = JS_EXTENSIONS.has(extname(file));
  return ranges
    .map(({ pos, end }) => text.slice(pos, end))
    .filter((comment) => DIRECTIVE.test(comment) || (js && JSDOC_TYPE.test(comment)))
    .sort();
}

function firstDifference(before, after) {
  let head = 0;
  while (head < before.length && head < after.length && before[head] === after[head]) head++;
  return { index: head, before: before[head], after: after[head] };
}

function checkFile(file, base, to) {
  const before = readAt(base, file);
  const after = readAt(to, file);
  if (before === null && after === null) return [];
  if (before === null) return [`新しいファイルなので比べられません`];
  if (after === null) return [`ファイルが削除されています`];
  if (before === after) return [];
  if (fileKind(file) === null) return [`この形式のコメントは読めません。差分を目で確かめてください`];

  const beforeComments = commentsOf(before, file);
  const afterComments = commentsOf(after, file);
  const problems = [];

  const beforeCode = skeleton(before, beforeComments);
  const afterCode = skeleton(after, afterComments);
  if (beforeCode.length !== afterCode.length || beforeCode.some((line, i) => line !== afterCode[i])) {
    const diff = firstDifference(beforeCode, afterCode);
    problems.push(
      `コメント以外が変わっています。コメントを除いた ${diff.index + 1} 行目\n      前: ${JSON.stringify(diff.before)}\n      後: ${JSON.stringify(diff.after)}`,
    );
  }

  const beforeDirectives = directivesOf(before, beforeComments, file);
  const afterDirectives = directivesOf(after, afterComments, file);
  if (beforeDirectives.join("\u0000") !== afterDirectives.join("\u0000")) {
    const lost = beforeDirectives.filter((d) => !afterDirectives.includes(d));
    const gained = afterDirectives.filter((d) => !beforeDirectives.includes(d));
    problems.push(
      `ディレクティブが変わっています\n      消えた: ${JSON.stringify(lost)}\n      増えた: ${JSON.stringify(gained)}`,
    );
  }
  return problems;
}

function listComments(paths) {
  const files = git(["ls-files", "--", ...paths]).split("\n").filter(Boolean);
  for (const file of files) {
    const text = readAt(null, file);
    if (text === null) continue;
    const ranges = commentsOf(text, file);
    if (ranges === null) continue;
    for (const { pos, end } of ranges) {
      const from = lineOf(text, pos);
      const to = lineOf(text, end);
      const where = from === to ? `${file}:${from}` : `${file}:${from}-${to}`;
      console.log(`${where}\n${text.slice(pos, end)}\n`);
    }
  }
}

function main() {
  const args = process.argv.slice(2);
  let base = "HEAD";
  let to = null;
  let list = false;
  const paths = [];
  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--base") base = args[++i];
    else if (args[i] === "--to") to = args[++i];
    else if (args[i] === "--list") list = true;
    else paths.push(args[i]);
  }
  if (list) {
    listComments(paths.length > 0 ? paths : ["."]);
    return;
  }

  const range = to === null ? [base] : [base, to];
  const changed = git(["diff", "--name-only", "-z", ...range, "--", ...paths]).split("\u0000").filter(Boolean);
  const untracked =
    to === null ? git(["ls-files", "--others", "--exclude-standard", "-z", "--", ...paths]).split("\u0000").filter(Boolean) : [];

  let failed = 0;
  for (const file of changed) {
    const problems = checkFile(file, base, to);
    if (problems.length === 0) continue;
    failed++;
    console.log(`NG ${file}`);
    for (const problem of problems) console.log(`   - ${problem}`);
  }
  for (const file of untracked) console.log(`-- ${file}: 追跡されていないファイルは比べていません`);

  console.log(`${changed.length} ファイルを確かめ、${failed} ファイルに問題がありました。`);
  process.exit(failed === 0 ? 0 : 1);
}

main();
