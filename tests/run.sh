#!/usr/bin/env bash
# Kit self-test. Run from anywhere:  ./tests/run.sh
# Checks content consistency and the installer across build layouts. Needs bash, git, awk, python3.
set -uo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
C="$KIT/content"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
FAILS=0
pass() { printf '  ok   %s\n' "$1"; }
fail() { printf '  FAIL %s\n' "$1"; FAILS=$((FAILS+1)); }
check() { if eval "$2" >/dev/null 2>&1; then pass "$1"; else fail "$1"; fi; }

echo "Content"
check "install.sh parses" "bash -n '$KIT/install.sh'"
for f in "$C"/skills/*/SKILL.md; do
  d="$(basename "$(dirname "$f")")"
  name="$(awk '/^---$/{n++; next} n==1 && /^name:/{sub(/^name:[ \t]*/,""); print; exit}' "$f")"
  desc="$(awk '/^---$/{n++; next} n==1 && /^description:/{sub(/^description:[ \t]*/,""); print; exit}' "$f")"
  [ "$name" = "$d" ] && [ -n "$desc" ] && [ "${#desc}" -le 1024 ] && pass "skill $d frontmatter" || fail "skill $d frontmatter (name='$name', desc ${#desc} chars)"
done
for f in "$C"/roles/*.md; do
  r="$(basename "$f" .md)"
  for key in name description tools model skills; do
    grep -q "^$key:" "$f" || fail "role $r has $key"
  done
  for s in $(sed -n 's/^skills: *\[\(.*\)\].*/\1/p' "$f" | tr -d ' ' | tr ',' ' '); do
    [ -d "$C/skills/$s" ] || fail "role $r references missing skill $s"
  done
  pass "role $r"
done
# Every skill, template and workflow named anywhere in content must exist.
refs="$(grep -rhoE '`sdlc-[a-z-]+`|templates/[a-z-]+\.md|workflows/[a-z-]+\.md|standards/[a-z]+\.md' "$C" | tr -d '`' | sort -u)"
missing=0
for r in $refs; do
  case "$r" in
    sdlc-*) [ -d "$C/skills/$r" ] || { fail "reference to missing skill $r"; missing=1; } ;;
    *) [ -f "$C/$r" ] || { fail "reference to missing file $r"; missing=1; } ;;
  esac
done
[ $missing -eq 0 ] && pass "all cross-references resolve ($(echo "$refs" | wc -l | tr -d ' '))"
# Every gate named in config must be a stage of its workflow.
for track in defect feature refactor; do
  gates="$(sed -n "s/^  $track: *\[\(.*\)\].*/\1/p" "$C/config.yaml" | tr -d ' ' | tr ',' ' ')"
  for g in $gates; do
    grep -qE "^\| [0-9]+ \| $g \|" "$C/workflows/$track.md" || fail "gate '$g' is not a stage in workflows/$track.md"
  done
  pass "gates for $track exist as stages"
done
if python3 -c 'import yaml' 2>/dev/null; then
  check "config.yaml is valid YAML" "python3 -c 'import yaml; yaml.safe_load(open(\"$C/config.yaml\"))'"
else
  printf '  skip config.yaml YAML check (pip install pyyaml to enable)\n'
fi

echo "Installer"
mk() {  # mk <dir> <layout>
  mkdir -p "$WORK/$1" && git -C "$WORK/$1" init -q
  case "$2" in
    maven-single) printf '<project/>' > "$WORK/$1/pom.xml"; touch "$WORK/$1/mvnw" ;;
    maven-multi-nowrapper) printf '<project><modules><module>a</module></modules></project>' > "$WORK/$1/pom.xml" ;;
    gradle-multi) printf "include 'app', 'core'\n" > "$WORK/$1/settings.gradle"; touch "$WORK/$1/gradlew" ;;
    gradle-single) printf "plugins { id 'java' }\n" > "$WORK/$1/build.gradle"; touch "$WORK/$1/gradlew" ;;
  esac
}
cfg() { grep -E "^  $2:" "$WORK/$1/.ai-sdlc/config.yaml" | head -1; }

mk ms maven-single
"$KIT/install.sh" "$WORK/ms" --harness claude >/dev/null 2>&1 || fail "install maven-single"
check "maven single-module: package-scoped verify_module" "cfg ms verify_module | grep -q \"\\*\\*/{module}/\\*\\*\""
check "maven single-module: keeps ./mvnw" "cfg ms verify | grep -q './mvnw'"
for p in AGENTS.md CLAUDE.md .ai-sdlc/config.yaml .ai-sdlc/lessons.md .ai-sdlc/VERSION .ai-sdlc/standards/testing.md \
         .ai-sdlc/improvements/log.md .agents/skills/ai-sdlc/SKILL.md .claude/skills/sdlc-retro/SKILL.md \
         .claude/agents/reviewer.md .claude/settings.json specs/.gitkeep; do
  [ -e "$WORK/ms/$p" ] || fail "installed $p"
done
pass "expected files installed"
check "claude agent tools mapped" "grep -q '^tools: Read, Glob, Grep, Bash, Edit, Write' '$WORK/ms/.claude/agents/reviewer.md'"
check "settings.json is valid JSON" "python3 -m json.tool '$WORK/ms/.claude/settings.json'"

mk mm maven-multi-nowrapper
"$KIT/install.sh" "$WORK/mm" >/dev/null 2>&1 || fail "install maven-multi"
check "maven multi-module: -pl verify_module" "cfg mm verify_module | grep -q -- '-pl {module}'"
check "no wrapper: uses mvn" "cfg mm verify | grep -q 'mvn -q verify' && ! grep -q '\./mvnw ' '$WORK/mm/.ai-sdlc/config.yaml'"

mk gm gradle-multi
"$KIT/install.sh" "$WORK/gm" >/dev/null 2>&1 || fail "install gradle-multi"
check "gradle multi-project: :{module}:check" "cfg gm verify_module | grep -q ':{module}:check'"
mk gs gradle-single
"$KIT/install.sh" "$WORK/gs" >/dev/null 2>&1 || fail "install gradle-single"
check "gradle single project: --tests pattern" "cfg gs verify_module | grep -q -- \"--tests '\\*.{module}.\\*'\""

echo "Upgrade keeps team-owned files"
printf -- '- custom lesson\n' >> "$WORK/ms/.ai-sdlc/lessons.md"
printf -- '- custom rule\n' >> "$WORK/ms/.ai-sdlc/standards/testing.md"
sed -i.bak 's/^  retry_budget: 3/  retry_budget: 7/' "$WORK/ms/.ai-sdlc/config.yaml" && rm -f "$WORK/ms/.ai-sdlc/config.yaml.bak"
mkdir -p "$WORK/ms/specs/T-1" && echo "state: done" > "$WORK/ms/specs/T-1/status.md"
printf '\n# Team notes\nkeep this\n' >> "$WORK/ms/AGENTS.md"
"$KIT/install.sh" "$WORK/ms" --harness claude >/dev/null 2>&1 || fail "re-install"
check "lessons.md kept" "grep -q 'custom lesson' '$WORK/ms/.ai-sdlc/lessons.md'"
check "standards kept" "grep -q 'custom rule' '$WORK/ms/.ai-sdlc/standards/testing.md'"
check "config.yaml kept" "grep -q 'retry_budget: 7' '$WORK/ms/.ai-sdlc/config.yaml'"
check "specs kept" "[ -f '$WORK/ms/specs/T-1/status.md' ]"
check "AGENTS.md: own text kept, one managed block" "grep -q 'keep this' '$WORK/ms/AGENTS.md' && [ \$(grep -c 'ai-sdlc:begin' '$WORK/ms/AGENTS.md') -eq 1 ]"

echo
if [ "$FAILS" -eq 0 ]; then echo "All checks passed."; else echo "$FAILS check(s) failed."; exit 1; fi
