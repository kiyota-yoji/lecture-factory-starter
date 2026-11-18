-- tools/check_wiki.lua — Wiki の原稿（wiki/）のリンク切れを確かめる
--
-- 確かめること:
--   ・Wiki のページどうしのリンク [表示](ページ名) の先のページ（wiki/ページ名.md）があるか
--   ・リポジトリのファイルへのリンク https://github.com/<REPO>/blob|tree/main/<パス> の先が、このリポジトリにあるか
--   ・すべてのページが目次（_Sidebar.md）から辿れるか
-- 外部のサイトへのリンクは確かめない。
--
-- 使い方（リポジトリのルートで）:  texlua tools/check_wiki.lua
-- 画面に出すメッセージは英語のみ（Windows の古いコンソールで日本語が文字化けするため）。

local lfs = require("lfs")
local script_dir = arg[0]:match("^(.*)[/\\]") or "."
assert(lfs.chdir(script_dir .. "/.."), "cannot find repository root")

local REPO = "https://github.com/kiyota-yoji/lecture-factory-starter/"
local WIKI = "wiki"
local SKIP = { ["README.md"] = true }   -- Wiki に写さないファイル

local function read(path)
  local f = io.open(path, "rb"); if not f then return nil end
  local s = f:read("a"); f:close(); return s
end

local pages = {}
for name in lfs.dir(WIKI) do
  if name:match("%.md$") and not SKIP[name] then pages[name:sub(1, -4)] = true end
end

local problems, linked = {}, {}
local function problem(page, msg) problems[#problems + 1] = page .. ".md: " .. msg end

for page in pairs(pages) do
  local src = read(WIKI .. "/" .. page .. ".md")
  -- コードブロックの中は対象外
  src = src:gsub("```.-```", "")
  for target in src:gmatch("%]%(([^%)%s]+)%)") do
    local t = target:gsub("#.*$", "")
    if target:sub(1, #REPO) == REPO then
      local rest = target:sub(#REPO + 1)
      local path = rest:match("^blob/main/([^#]*)") or rest:match("^tree/main/([^#]*)")
      if path then
        path = path:gsub("/$", "")
        if lfs.attributes(path, "mode") == nil then problem(page, "missing file in repository: " .. path) end
      elseif not (rest:match("^releases") or rest:match("^issues")) then
        problem(page, "unexpected repository link (use blob/main or tree/main): " .. target)
      end
    elseif t:match("^%a[%w+.-]*:") then
      -- 外部のサイト（確かめない）
    elseif t == "" then
      -- ページ内のアンカー
    elseif t:find("/") then
      problem(page, "relative path link (use a full GitHub URL): " .. target)
    else
      if not pages[t] then problem(page, "missing wiki page: " .. t) end
      if page == "_Sidebar" then linked[t] = true end
    end
  end
end

if not pages["Home"] then problem("Home", "Home.md is missing") end
if not pages["_Sidebar"] then
  problem("_Sidebar", "_Sidebar.md is missing")
else
  for page in pairs(pages) do
    if not page:match("^_") and not linked[page] then problem("_Sidebar", "page not listed in sidebar: " .. page) end
  end
end

table.sort(problems)
if #problems > 0 then
  print("Wiki check failed:")
  for _, p in ipairs(problems) do print("  " .. p) end
  os.exit(1)
end
local n = 0; for _ in pairs(pages) do n = n + 1 end
print(("Wiki links OK (%d pages)."):format(n))
