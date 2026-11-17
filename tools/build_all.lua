-- tools/build_all.lua — リポジトリ内のすべての教材（ルート .tex）を latexmk でビルドする
--
-- texlua は TeX Live に必ず入っているため、Windows / Mac / Linux で追加インストールなしに動く。
-- （Windows の TeX Live では perl コマンドが PATH に入らないので、Perl ではなく texlua で書いている）
--
-- 使い方（リポジトリのルートで）:
--   texlua tools/build_all.lua            すべてビルド
--   texlua tools/build_all.lua courses    courses/ 配下だけ
--   texlua tools/build_all.lua --clean    中間ファイルを削除
--
-- 「ルート .tex」とは、\documentclass を含むか、\input{slides} / \input{worksheet} で
-- 本体を読み込むラッパー（handout.tex, worksheet_answers.tex）のこと。
-- figures/ 内の TikZ 断片のように単独でビルドしないファイルは対象外になる。
--
-- 画面に出すメッセージは英語のみ（Windows の古いコンソールで日本語が文字化けするため）。

local lfs = require("lfs")
local is_windows = package.config:sub(1, 1) == "\\"
local devnull = is_windows and "NUL" or "/dev/null"

-- リポジトリのルート（このスクリプトの1つ上）へ移動
local script_dir = arg[0]:match("^(.*)[/\\]") or "."
assert(lfs.chdir(script_dir .. "/.."), "cannot find repository root")

local clean = false
local dirs = {}
for _, a in ipairs(arg) do
  if a == "--clean" then clean = true else dirs[#dirs + 1] = a end
end
if #dirs == 0 then dirs = { "templates", "courses" } end

local function read_file(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

local function is_root_tex(path)
  local src = read_file(path)
  if not src then return false end
  src = "\n" .. src
  return src:find("\n%s*\\documentclass") ~= nil
      or src:find("\n%s*\\input{slides}") ~= nil
      or src:find("\n%s*\\input{worksheet}") ~= nil
end

local skip_dir = { figures = true, build = true, [".git"] = true }
local targets = {}
local function walk(dir)
  for name in lfs.dir(dir) do
    if name ~= "." and name ~= ".." then
      local path = dir .. "/" .. name
      local mode = lfs.attributes(path, "mode")
      if mode == "directory" then
        if not skip_dir[name] then walk(path) end
      elseif mode == "file" and name:match("%.tex$") and is_root_tex(path) then
        targets[#targets + 1] = path
      end
    end
  end
end
for _, d in ipairs(dirs) do
  if lfs.attributes(d, "mode") == "directory" then walk(d) end
end
table.sort(targets)

local function run(cmd)
  local ok, _, code = os.execute(cmd)
  if type(ok) == "number" then return ok == 0 end  -- Lua 5.1 互換
  return ok == true and (code == nil or code == 0)
end

local failed = {}
for _, t in ipairs(targets) do
  io.write(string.format("%-60s ", t))
  io.flush()
  local opt = clean and "-c" or "-quiet"
  if run(string.format('latexmk -cd %s "%s" > %s 2>&1', opt, t, devnull)) then
    print("OK")
  else
    print("FAILED")
    failed[#failed + 1] = t
  end
end

if #failed > 0 then
  print("\nFailed files (see the .log next to each file):")
  for _, t in ipairs(failed) do
    print("  " .. t)
    local log = read_file((t:gsub("%.tex$", ".log")))
    if log then
      local n = 0
      for line in log:gmatch("[^\r\n]+") do
        if line:match("^!") or line:match(":%d+: ") then
          print("    " .. line)
          n = n + 1
          if n >= 5 then break end
        end
      end
    end
  end
  os.exit(1)
end
if not clean then print(string.format("\nAll %d files built successfully.", #targets)) end
