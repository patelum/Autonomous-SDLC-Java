#!/usr/bin/env bash
# Install Autonomous-SDLC-Java into an existing Java monolith repository.
#
#   ./install.sh /path/to/your-monolith [--harness claude] [--dry-run]
#
# Safe to re-run: managed files are updated, your config.yaml, context/ and specs/ are kept,
# and only the marked ai-sdlc block inside AGENTS.md is replaced.

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT="$KIT_DIR/content"
TARGET=""
HARNESSES=""
DRY_RUN=0

usage() {
  sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --harness) HARNESSES="${HARNESSES:+$HARNESSES,}${2:?--harness needs a value}"; shift 2 ;;
    --harness=*) HARNESSES="${HARNESSES:+$HARNESSES,}${1#*=}"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage 0 ;;
    -*) echo "Unknown option: $1" >&2; usage 1 ;;
    *) [ -z "$TARGET" ] || { echo "Only one target directory allowed" >&2; exit 1; }; TARGET="$1"; shift ;;
  esac
done

[ -n "$TARGET" ] || usage 1
[ -d "$TARGET" ] || { echo "Not a directory: $TARGET" >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"

for h in ${HARNESSES//,/ }; do
  case "$h" in
    claude) ;;
    codex|copilot|gemini|opencode)
      echo "Note: $h reads AGENTS.md and .agents/skills/ natively; no extra wiring needed in v0.1." ;;
    *) echo "Unknown harness: $h (supported: claude; codex, copilot, gemini, opencode need no flag)" >&2; exit 1 ;;
  esac
done

say() { printf '  %s\n' "$*"; }
run() { if [ "$DRY_RUN" -eq 1 ]; then say "[dry-run] $*"; else "$@"; fi; }

# --- Detect project --------------------------------------------------------
BUILD_TOOL=""
if [ -f "$TARGET/pom.xml" ]; then BUILD_TOOL=maven
else
  for f in build.gradle build.gradle.kts settings.gradle settings.gradle.kts; do
    [ -f "$TARGET/$f" ] && { BUILD_TOOL=gradle; break; }
  done
fi

echo "Installing ai-sdlc into $TARGET"
if [ -z "$BUILD_TOOL" ]; then
  say "Warning: no pom.xml or build.gradle found at the repo root. Set build commands in .ai-sdlc/config.yaml by hand."
else
  say "Detected build tool: $BUILD_TOOL"
fi
[ -d "$TARGET/.git" ] || say "Warning: target is not a git repository. Reviews diff against git; run 'git init' first."

PROJECT_NAME="$(basename "$TARGET")"

# --- Managed content -------------------------------------------------------
copy_dir() {  # copy_dir <src> <dest>  (replaces dest contents for managed dirs)
  run mkdir -p "$2"
  run cp -R "$1"/. "$2"/
}

echo "Skills -> .agents/skills/"
for skill in "$CONTENT"/skills/*/; do
  name="$(basename "$skill")"
  run rm -rf "$TARGET/.agents/skills/$name"
  copy_dir "$skill" "$TARGET/.agents/skills/$name"
  say "$name"
done

echo "Process files -> .ai-sdlc/"
for d in workflows roles templates; do
  run rm -rf "$TARGET/.ai-sdlc/$d"
  copy_dir "$CONTENT/$d" "$TARGET/.ai-sdlc/$d"
  say "$d/"
done
run mkdir -p "$TARGET/.ai-sdlc/context/modules"

if [ -f "$TARGET/.ai-sdlc/config.yaml" ]; then
  say "config.yaml exists, kept"
else
  # Multi-module builds scope by build module; single-module builds scope tests by package folder.
  LAYOUT=single
  if [ "$BUILD_TOOL" = maven ] && grep -q '<modules>' "$TARGET/pom.xml"; then LAYOUT=multi; fi
  if [ "$BUILD_TOOL" = gradle ] && cat "$TARGET"/settings.gradle* 2>/dev/null | grep -Eq '^[[:space:]]*include[[:space:](]'; then LAYOUT=multi; fi
  if [ "$DRY_RUN" -eq 0 ]; then
    CFG="$TARGET/.ai-sdlc/config.yaml"
    sed "s/^  name: my-monolith .*/  name: $PROJECT_NAME/" "$CONTENT/config.yaml" > "$CFG"
    set_cmd() {  # set_cmd <key> <command>  — replace the active line for build.<key>
      awk -v key="$1" -v cmd="$2" '$0 ~ "^  " key ": " && !done { print "  " key ": " cmd; done=1; next } { print }' "$CFG" > "$CFG.tmp" && mv "$CFG.tmp" "$CFG"
    }
    case "$BUILD_TOOL-$LAYOUT" in
      maven-single)
        set_cmd verify_module "./mvnw -q test -Djacoco.skip=true -Dsurefire.failIfNoSpecifiedTests=false -Dtest='**/{module}/**'" ;;
      gradle-multi)
        set_cmd tool "gradle                 # maven | gradle"
        set_cmd verify "./gradlew check"
        set_cmd verify_module "./gradlew :{module}:check"
        set_cmd test_one "./gradlew test --tests {test}" ;;
      gradle-single)
        set_cmd tool "gradle                 # maven | gradle"
        set_cmd verify "./gradlew check"
        set_cmd verify_module "./gradlew test --tests '*.{module}.*'"
        set_cmd test_one "./gradlew test --tests {test}" ;;
    esac
    # Pre-fill a known formatter if the build already uses one.
    if grep -qs 'spring-javaformat-maven-plugin' "$TARGET/pom.xml"; then set_cmd format "./mvnw -q spring-javaformat:apply"
    elif grep -qs 'spotless-maven-plugin' "$TARGET/pom.xml"; then set_cmd format "./mvnw -q spotless:apply"
    elif cat "$TARGET"/build.gradle* 2>/dev/null | grep -q 'spotless'; then set_cmd format "./gradlew spotlessApply"
    fi
  fi
  say "config.yaml created ($BUILD_TOOL, ${LAYOUT}-module defaults) — check the build: commands"
fi

run mkdir -p "$TARGET/specs"
[ -e "$TARGET/specs/.gitkeep" ] || run touch "$TARGET/specs/.gitkeep"

# --- AGENTS.md (replace only the managed block) -----------------------------
echo "AGENTS.md"
AGENTS="$TARGET/AGENTS.md"
if [ "$DRY_RUN" -eq 0 ]; then
  if [ ! -f "$AGENTS" ]; then
    { printf '# %s\n\n' "$PROJECT_NAME"; cat "$CONTENT/AGENTS.md"; } > "$AGENTS"
    say "created"
  elif grep -q 'ai-sdlc:begin' "$AGENTS"; then
    awk -v block="$CONTENT/AGENTS.md" '
      /ai-sdlc:begin/ { while ((getline line < block) > 0) print line; skip=1; next }
      /ai-sdlc:end/   { skip=0; next }
      !skip { print }
    ' "$AGENTS" > "$AGENTS.tmp" && mv "$AGENTS.tmp" "$AGENTS"
    say "ai-sdlc block updated"
  else
    { printf '\n'; cat "$CONTENT/AGENTS.md"; } >> "$AGENTS"
    say "ai-sdlc block appended"
  fi
fi

# --- Claude Code wiring -----------------------------------------------------
render_claude_agent() {  # render_claude_agent <role.md> <out.md>
  awk '
    function add(t) { if (!(t in seen)) { seen[t] = 1; out = out (out == "" ? "" : ", ") t } }
    function map_tools(list,   n, i, a) {
      gsub(/[\[\] ]/, "", list); n = split(list, a, ",")
      out = ""
      for (i = 1; i <= n; i++) {
        if (a[i] == "read")        { add("Read"); add("Glob") }
        else if (a[i] == "search") { add("Grep"); add("Glob") }
        else if (a[i] == "edit")   { add("Edit"); add("Write") }
        else if (a[i] == "shell")  { add("Bash") }
        else if (a[i] == "web")    { add("WebFetch"); add("WebSearch") }
      }
      return out
    }
    NR == 1 && $0 == "---" { infm = 1; next }
    infm && $0 == "---" {
      infm = 0
      print "---"
      print "name: " name
      print "description: " desc
      if (tools != "") print "tools: " tools
      print "model: inherit"
      print "---"
      print ""
      print "<!-- Generated by Autonomous-SDLC-Java install.sh from .ai-sdlc/roles/" name ".md. Edit the role file and re-run the installer. -->"
      print ""
      if (skills != "") { gsub(/[\[\]]/, "", skills); print "Skills for this role (in .claude/skills/): " skills ". Use the one the orchestrator names.\n" }
      next
    }
    infm {
      line = $0; sub(/[ \t]+#.*$/, "", line)
      key = line; sub(/:.*/, "", key)
      val = line; sub(/^[^:]*:[ \t]*/, "", val)
      if (key == "name") name = val
      else if (key == "description") desc = val
      else if (key == "tools") tools = map_tools(val)
      else if (key == "skills") skills = val
      next
    }
    { print }
  ' "$1" > "$2"
}

case ",$HARNESSES," in
  *,claude,*)
    echo "Claude Code wiring"
    if [ "$DRY_RUN" -eq 0 ]; then
      if [ ! -f "$TARGET/CLAUDE.md" ]; then
        printf '@AGENTS.md\n' > "$TARGET/CLAUDE.md"; say "CLAUDE.md created (imports AGENTS.md)"
      elif ! grep -q '^@AGENTS.md' "$TARGET/CLAUDE.md"; then
        printf '\n@AGENTS.md\n' >> "$TARGET/CLAUDE.md"; say "CLAUDE.md: added @AGENTS.md import"
      else
        say "CLAUDE.md already imports AGENTS.md"
      fi
      mkdir -p "$TARGET/.claude/skills" "$TARGET/.claude/agents"
      for skill in "$CONTENT"/skills/*/; do
        name="$(basename "$skill")"
        rm -rf "$TARGET/.claude/skills/$name"
        cp -R "$skill" "$TARGET/.claude/skills/$name"
      done
      say ".claude/skills/ (copies of .agents/skills/)"
      for role in "$CONTENT"/roles/*.md; do
        render_claude_agent "$role" "$TARGET/.claude/agents/$(basename "$role")"
      done
      say ".claude/agents/ ($(ls "$CONTENT"/roles/*.md | wc -l | tr -d ' ') subagents)"
      if [ -f "$TARGET/.claude/settings.json" ]; then
        say ".claude/settings.json exists, kept (see README for suggested permissions)"
      else
        cat > "$TARGET/.claude/settings.json" <<'JSON'
{
  "permissions": {
    "allow": [
      "Bash(./mvnw:*)", "Bash(./gradlew:*)",
      "Bash(git status:*)", "Bash(git diff:*)", "Bash(git log:*)", "Bash(git show:*)", "Bash(git rev-parse:*)",
      "Bash(grep:*)", "Bash(find:*)", "Bash(ls:*)", "Bash(cat:*)", "Bash(head:*)", "Bash(tail:*)",
      "Bash(wc:*)", "Bash(sort:*)", "Bash(uniq:*)", "Bash(mkdir:*)", "Bash(date:*)"
    ],
    "ask": [
      "Bash(git commit:*)", "Bash(git push:*)", "Bash(git checkout:*)", "Bash(git switch:*)",
      "Bash(git reset:*)", "Bash(git merge:*)", "Bash(git rebase:*)", "Bash(rm:*)"
    ]
  }
}
JSON
        say ".claude/settings.json (builds and read-only git allowed; commit, push, branch changes ask)"
      fi
    fi
    ;;
esac

cat <<EOF

Done. Next:
  1. Check the build: commands in .ai-sdlc/config.yaml
  2. Start your agent CLI in $TARGET and run:  /ai-sdlc   (or say "start ai-sdlc")
  3. Choose "Set up project context", review .ai-sdlc/context/, then commit everything.
EOF
