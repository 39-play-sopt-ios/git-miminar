#!/usr/bin/env bash
# 미션 2 PR 검사. GitHub Actions에서 실행되지만 로컬에서도 돌려볼 수 있다.
# 사용법: ./scripts/check-member-pr.sh <base 커밋> <GitHub ID> <브랜치 이름> [PR 본문]
#   예)   ./scripts/check-member-pr.sh origin/main limtjdghks 'feat/#12-limtjdghks' 'Closes #12'
#   PR 본문을 빼면 Closes 검사는 건너뛴다 (push 전에 로컬에서 볼 때)
set -uo pipefail

cd "$(git rev-parse --show-toplevel)"
. missions/lib.sh

[ $# -ge 3 ] || die "사용법: ./scripts/check-member-pr.sh <base 커밋> <GitHub ID> <브랜치 이름> [PR 본문]"
base="$1"
author="$2"
branch="$3"
body="${4-}"
readonly FILE='missions/02-pr-conflict/Members.swift'

# 1. 브랜치 이름에 이슈 번호: feat/#12-limtjdghks
issue="$(printf '%s' "$branch" | sed -n 's|^feat/#\([0-9][0-9]*\)-.*|\1|p')"
if [ -n "$issue" ]; then
  pass "브랜치 이름에서 이슈 #$issue 를 확인했어요."
else
  fail "브랜치 이름은 feat/#이슈번호-본인ID 형식이어야 해요. (예: feat/#12-$author) 지금: $branch"
fi

# 2. 커밋 메시지에 이슈 번호 (main을 merge한 커밋은 빼고)
if [ -n "$issue" ]; then
  if git log --no-merges --format=%s "$base"..HEAD | grep -qE "#${issue}([^0-9]|$)"; then
    pass "커밋 메시지에 #$issue 가 있어요."
  else
    fail "커밋 메시지 끝에 (#$issue) 를 붙여 주세요. 예) feat: 인사말 추가 (#$issue)"
  fi
fi

# 3. PR 본문에 Closes #이슈번호
if [ $# -ge 4 ] && [ -n "$issue" ]; then
  if printf '%s' "$body" | grep -qiE "(close[sd]?|fix(e[sd])?|resolve[sd]?) #${issue}([^0-9]|$)"; then
    pass "PR 본문에 Closes #$issue 가 있어요. merge되면 이슈가 자동으로 닫혀요."
  else
    fail "PR 본문에 Closes #$issue 를 적어 주세요. (고친 뒤 PR 본문을 저장하면 검사가 다시 돌아요)"
  fi
fi

# 4. 바꾼 파일 (base와 갈라진 지점부터, main을 merge해 온 부분은 빠진다)
changed="$(git diff --name-only "$base"...HEAD)"
if [ "$changed" = "$FILE" ]; then
  pass "$FILE 하나만 바꿨어요."
else
  fail "$FILE 하나만 바꿔야 해요. 지금 바뀐 파일:"
  printf '%s\n' "$changed" | sed 's/^/     /'
fi

# 5. 충돌 마커
if has_conflict_markers "$FILE"; then
  fail "$FILE 에 충돌 마커(<<<<<<< ======= >>>>>>>)가 남아 있어요."
  finish_verify 'PR 검사'
fi
pass '충돌 마커가 남아 있지 않아요.'

# 6. githubID 줄에 내 ID가 들어간 블록: "// MARK: - N번" 줄부터 다음 MARK 직전까지
range="$(awk -v id="githubID: \"$author\"" '
  index($0, "// MARK: - ") == 1 { if (mine) { print start, NR - 1; done = 1; exit } start = NR }
  index(tolower($0), tolower(id)) { mine = 1 }
  END { if (mine && !done) print start, NR }' "$FILE")"
if [ -z "$range" ]; then
  fail "githubID: \"$author\" 줄이 있는 블록을 찾지 못했어요. 내 번호 블록의 githubID에 본인 ID를 적어 주세요."
  finish_verify 'PR 검사'
fi
set -- $range
start="$1"; end="$2"
pass "내 블록(${start}~${end}번째 줄)에 본인 ID($author)가 있어요."

# 7. 바꾼 줄 번호가 모두 내 블록 안에 있는지
outside="$(git diff -U0 "$base"...HEAD -- "$FILE" | awk -v s="$start" -v e="$end" '
  /^@@/ { split($3, a, ","); n = substr(a[1], 2) + 0; c = (a[2] == "" ? 1 : a[2] + 0); if (c == 0) c = 1
          for (i = n; i < n + c; i++) if (i < s || i > e) { print i; exit } }')"
if [ -z "$outside" ]; then
  pass '내 블록 안만 고쳤어요.'
else
  fail "내 블록 밖(${outside}번째 줄 근처)을 고쳤어요. 다른 번호 블록은 그대로 두세요."
fi

finish_verify 'PR 검사'
