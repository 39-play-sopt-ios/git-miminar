#!/usr/bin/env bash
# 미션 1: 내 로컬에서 merge 충돌을 만들고 직접 해결해 본다.
# 원격에는 아무것도 올리지 않는다. 다시 실행하면 처음 상태로 돌아간다.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
. missions/lib.sh

readonly FILE='missions/01-conflict/LoginView.swift'

require_git_user
git merge --abort 2>/dev/null || true
if [ -n "$(git status --porcelain)" ]; then
  die '커밋하지 않은 변경이 있습니다. 커밋하거나 stash한 뒤 다시 실행하세요.'
fi

git switch --quiet main

# 팀원 브랜치: 타이틀을 "Sign in"으로 바꾼 커밋
git switch --quiet -C mission1-teammate main
sed -i.bak 's/let title = "Login"/let title = "Sign in"/' "$FILE"
rm -f "$FILE.bak"
git commit --quiet --author='팀원 <teammate@example.com>' -am 'feat: 로그인 타이틀을 Sign in으로 변경'

# 내 브랜치: 같은 줄을 "로그인"으로 바꾼 커밋
git switch --quiet -C mission1-me main
sed -i.bak 's/let title = "Login"/let title = "로그인"/' "$FILE"
rm -f "$FILE.bak"
git commit --quiet -am 'feat: 로그인 타이틀 한글화'

info '준비 완료! 지금 mission1-me 브랜치에 있어요.'
info '팀원 브랜치 mission1-teammate를 내 브랜치에 merge 해보세요.'
info '  GitKraken: 그래프에서 mission1-teammate 우클릭 → Merge mission1-teammate into mission1-me'
info '  터미널:    git merge mission1-teammate'
info "충돌이 나면 $FILE 의 타이틀을 둘 중 하나로 정리하고 커밋하세요."
info '다 했으면: ./missions/01-conflict/verify.sh'
