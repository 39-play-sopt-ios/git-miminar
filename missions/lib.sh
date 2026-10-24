# 미션 스크립트가 함께 쓰는 함수. 직접 실행하지 않고 source로 불러온다.
# macOS 기본 bash(3.2)와 Windows Git Bash에서 동작하도록 bash 4 문법은 쓰지 않는다.

die() { printf '❌ %s\n' "$1" >&2; exit 1; }
info() { printf '👉 %s\n' "$1"; }
pass() { printf '✅ %s\n' "$1"; }

# 검사 하나가 실패해도 나머지를 끝까지 보여주고, 마지막에 한 번에 판정한다.
failures=0
fail() { printf '❌ %s\n' "$1"; failures=$((failures + 1)); }

finish_verify() {
  echo
  if [ "$failures" -eq 0 ]; then
    printf '🎉 %s 통과!\n' "$1"
  else
    printf '아직 %s개 남았어요. 위의 ❌를 고치고 다시 실행하세요.\n' "$failures"
    exit 1
  fi
}

require_git_user() {
  git config user.name >/dev/null && git config user.email >/dev/null \
    || die 'git 사용자 정보가 없습니다. git config --global user.name "이름" / user.email "메일"을 먼저 설정하세요.'
}

# 충돌 마커(<<<<<<<, =======, >>>>>>>)로 시작하는 줄이 있는지
has_conflict_markers() {
  grep -qE '^(<<<<<<<|=======|>>>>>>>)( |$)' "$1"
}
