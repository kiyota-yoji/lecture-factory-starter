-- tools/sync_skills.lua — スキルの原本（.agents/skills/）を Claude Code 用の .claude/skills/ に写す
--
-- スキルの原本は .agents/skills/ にあり、Codex・Antigravity などはここを読む。
-- Claude Code は .claude/skills/ を読むので、同じ内容を写しておく。
-- （シンボリックリンクは Windows で git から取り出したときに壊れることがあるため、実ファイルで持つ）
--
-- 使い方（リポジトリのルートで）:
--   texlua tools/sync_skills.lua          .agents/skills/ → .claude/skills/ に写す
--   texlua tools/sync_skills.lua --check  食い違いがあれば一覧を出して終了コード 1（CI 用）
--
-- スキルを直すときは .agents/skills/ の方を編集し、このスクリプトで写すこと。

local lfs = require("lfs")
local script_dir = arg[0]:match("^(.*)[/\\]") or "."
assert(lfs.chdir(script_dir .. "/.."), "cannot find repository root")

local SRC, DST = ".agents/skills", ".claude/skills"
local check = (arg[1] == "--check")

local function read(path)
  local f = io.open(path, "rb"); if not f then return nil end
  local s = f:read("a"); f:close(); return s
end

local function list(root)
  local files = {}
  local function walk(dir, rel)
    if lfs.attributes(dir, "mode") ~= "directory" then return end
    for name in lfs.dir(dir) do
      if name ~= "." and name ~= ".." and name ~= ".DS_Store" then
        local path, r = dir .. "/" .. name, (rel == "" and name or rel .. "/" .. name)
        local mode = lfs.attributes(path, "mode")
        if mode == "directory" then walk(path, r) elseif mode == "file" then files[r] = true end
      end
    end
  end
  walk(root, "")
  return files
end

local function mkdirs(path)
  local acc = ""
  for part in path:gmatch("[^/]+") do
    acc = (acc == "" and part or acc .. "/" .. part)
    if lfs.attributes(acc, "mode") == nil then lfs.mkdir(acc) end
  end
end

local src, dst = list(SRC), list(DST)
local problems = {}

for rel in pairs(src) do
  local a, b = read(SRC .. "/" .. rel), read(DST .. "/" .. rel)
  if a ~= b then
    problems[#problems + 1] = (b == nil and "missing in .claude/skills: " or "differs: ") .. rel
    if not check then
      mkdirs(DST .. "/" .. (rel:match("^(.*)/[^/]+$") or ""))
      local f = assert(io.open(DST .. "/" .. rel, "wb")); f:write(a); f:close()
    end
  end
end
for rel in pairs(dst) do
  if not src[rel] then
    problems[#problems + 1] = "not in .agents/skills (stale): " .. rel
    if not check then os.remove(DST .. "/" .. rel) end
  end
end
table.sort(problems)

if check then
  if #problems > 0 then
    print("Skills are out of sync. Run: texlua tools/sync_skills.lua")
    for _, p in ipairs(problems) do print("  " .. p) end
    os.exit(1)
  end
  print("Skills are in sync.")
else
  for _, p in ipairs(problems) do print("synced: " .. p) end
  print(#problems == 0 and "Already in sync." or "Done.")
end
