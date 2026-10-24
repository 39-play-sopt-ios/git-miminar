#!/usr/bin/env bash
# 보너스 미션: push가 거절되는 상황을 만들고 pull(merge) → push로 해결해 본다.
# 동아리 레포가 아니라 .playground/ 안에 만든 연습용 원격을 쓰므로 아무리 해도 안전하다.
# 다시 실행하면 처음 상태로 돌아간다.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
. missions/lib.sh

require_git_user

root="$(pwd)/.playground/push-rejected"
rm -rf "$root"
mkdir -p "$root"
cd "$root"

# 연습용 원격 (GitHub 역할)
git init --quiet --bare remote.git
git -C remote.git symbolic-ref HEAD refs/heads/main

# 팀원 clone: 첫 커밋을 올린다
git clone --quiet remote.git teammate 2>/dev/null
(
  cd teammate
  git config user.name '팀원'
  git config user.email 'teammate@example.com'
  git symbolic-ref HEAD refs/heads/main
  printf '# 팀 노트\n' > TEAM.md
  git add TEAM.md
  git commit --quiet -m 'docs: 팀 노트 시작'
  git push --quiet origin main
)

# 내 clone: 이 시점의 main을 받아 둔다
git clone --quiet remote.git me
git -C me config pull.rebase false

# 내가 clone한 뒤에 팀원이 먼저 push한다
(
  cd teammate
  printf -- '- 팀원: API 명세 정리 완료\n' >> TEAM.md
  git commit --quiet -am 'docs: 팀원 작업 기록'
  git push --quiet origin main
)

info '준비 완료! 연습용 폴더를 만들었어요.'
info "GitKraken에서 이 폴더를 여세요: $root/me"
info '  (File → Open Repo, 터미널이라면 cd 로 이동)'
info '1. me/NOTES.md 파일을 만들고 아무 내용이나 적은 뒤 커밋 → Push  (거절될 거예요)'
info '2. 거절 메시지를 읽고 Pull → 다시 Push'
info '다 했으면 원래 레포 폴더에서: ./missions/bonus-push-rejected/verify.sh'
