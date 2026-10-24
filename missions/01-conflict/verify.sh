#!/usr/bin/env bash
# 미션 1 채점: 충돌을 끝까지 해결하고 merge 커밋까지 만들었는지 확인한다.
set -uo pipefail

cd "$(git rev-parse --show-toplevel)"
. missions/lib.sh

readonly FILE='missions/01-conflict/LoginView.swift'

git show-ref --verify --quiet refs/heads/mission1-teammate \
  || die '미션 브랜치가 없습니다. ./missions/01-conflict/setup.sh 를 먼저 실행하세요.'

if [ "$(git branch --show-current)" = 'mission1-me' ]; then
  pass '지금 mission1-me 브랜치에 있어요.'
else
  fail 'mission1-me 브랜치에서 작업해야 해요. (git switch mission1-me)'
fi

if git rev-parse --quiet --verify MERGE_HEAD >/dev/null; then
  fail 'merge가 아직 끝나지 않았어요. 파일을 정리하고 add → commit 까지 해주세요.'
else
  pass '진행 중인 merge가 없어요.'
fi

if git merge-base --is-ancestor mission1-teammate HEAD; then
  pass '팀원 커밋이 내 브랜치에 들어왔어요.'
else
  fail '아직 mission1-teammate를 merge하지 않았어요.'
fi

if has_conflict_markers "$FILE"; then
  fail "$FILE 에 충돌 마커(<<<<<<< ======= >>>>>>>)가 남아 있어요."
else
  pass '충돌 마커가 남아 있지 않아요.'
fi

title_lines="$(grep -c 'let title = ' "$FILE" || true)"
if [ "$title_lines" = '1' ] && grep -qE 'let title = "(Sign in|로그인)"' "$FILE"; then
  pass "타이틀이 하나로 정리됐어요: $(grep 'let title = ' "$FILE" | sed 's/^ *//')"
else
  fail 'let title 줄이 정확히 하나, "Sign in" 또는 "로그인" 중 하나여야 해요.'
fi

if [ -z "$(git status --porcelain -- "$FILE")" ]; then
  pass '정리한 내용이 커밋됐어요.'
else
  fail "$FILE 에 커밋 안 한 변경이 있어요."
fi

finish_verify '미션 1'
