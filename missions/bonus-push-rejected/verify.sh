#!/usr/bin/env bash
# 보너스 미션 채점: 팀원 커밋을 받은 뒤 내 커밋까지 원격에 올렸는지 확인한다.
set -uo pipefail

cd "$(git rev-parse --show-toplevel)"
. missions/lib.sh

root="$(pwd)/.playground/push-rejected"
[ -d "$root/me" ] || die '연습용 폴더가 없습니다. ./missions/bonus-push-rejected/setup.sh 를 먼저 실행하세요.'

remote="$root/remote.git"
teammate_head="$(git -C "$root/teammate" rev-parse main)"
remote_head="$(git -C "$remote" rev-parse main)"

if git -C "$remote" merge-base --is-ancestor "$teammate_head" "$remote_head"; then
  pass '팀원 커밋이 원격에 그대로 남아 있어요.'
else
  fail '원격에서 팀원 커밋이 사라졌어요. setup.sh로 다시 시작하세요.'
fi

my_commits="$(git -C "$remote" log --format='%an' main | grep -vcx '팀원' || true)"
if [ "$my_commits" -gt 0 ]; then
  pass '내 커밋이 원격에 올라갔어요.'
else
  fail '원격에 내 커밋이 없어요. 커밋 → Push 했는지 확인하세요.'
fi

git -C "$root/me" fetch --quiet origin
if [ "$(git -C "$root/me" rev-parse main)" = "$remote_head" ]; then
  pass '내 main과 원격 main이 같아요.'
else
  fail '내 main과 원격 main이 달라요. Pull 또는 Push가 남아 있어요.'
fi

if [ -z "$(git -C "$root/me" status --porcelain)" ]; then
  pass '커밋 안 한 변경이 없어요.'
else
  fail 'me 폴더에 커밋 안 한 변경이 있어요.'
fi

finish_verify '보너스 미션'
