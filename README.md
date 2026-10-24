# Git 협업 미니 세미나 실습

세미나에서 배운 "꼬이는 상황"을 직접 만들어 보고 풀어보는 레포입니다.
미션마다 `setup.sh`로 상황을 만들고, 해결한 뒤 `verify.sh`로 채점합니다.

> Windows는 **Git Bash**에서 실행하세요. macOS/Linux는 기본 터미널이면 됩니다.

## 시작하기

1. 이 레포를 clone 합니다. (GitKraken: Clone a Repo → GitHub.com)
2. 터미널에서 레포 폴더로 이동합니다.

```bash
git config pull.rebase false   # 이 실습의 pull 방식: merge
```

## 미션 목록

| 미션 | 상황 | 원격에 올리나요? |
|---|---|---|
| [미션 1](missions/01-conflict) | 팀원과 같은 줄을 고쳐서 merge 충돌 | 아니요 (내 컴퓨터에서만) |
| [미션 2](missions/02-pr-conflict) | 이슈 → 브랜치 → PR → 충돌 해결 → 병합 | 예 (이슈, PR) |
| [보너스](missions/bonus-push-rejected) | 팀원이 먼저 push해서 내 push가 거절됨 | 아니요 (연습용 원격) |

## 미션 1: merge 충돌 해결

```bash
./missions/01-conflict/setup.sh
```

- `mission1-me` 브랜치에 `mission1-teammate` 브랜치를 merge 하세요.
- `LoginView.swift`에서 충돌이 납니다. 타이틀을 `"Sign in"`이나 `"로그인"` 중 하나로 정리하고 커밋하세요.
- 충돌 난 파일은 Xcode로 열어 마커 3줄을 지우고 저장한 뒤, GitKraken에서 Stage → Commit 하세요.

```bash
./missions/01-conflict/verify.sh
```

`setup.sh`를 다시 실행하면 처음 상태로 돌아갑니다.

## 미션 2: 이슈부터 병합까지, 실제 협업 순서대로

세미나에서 본 협업 흐름 그대로 진행합니다.
**이슈 생성 → 이슈 번호로 브랜치 → 작업 → PR → 충돌 해결 → 병합**

각자 받은 번호의 블록만 고칩니다. 중간에 진행자가 **모든 블록의 인사말을 바꾸는 PR**을 먼저 merge하면,
모두의 PR에 동시에 충돌이 생기고 각자 자기 PR의 충돌을 풉니다.
블록끼리는 떨어져 있어서, 다른 사람이 먼저 merge해도 내 PR에 새 충돌이 생기지 않습니다. 순서를 기다릴 필요가 없어요.

### 1. 이슈 만들기
- GitHub 레포 → Issues → New issue → **실습 - 인사말 추가** 템플릿 선택
- 제목의 `N번`을 내 번호로 바꾸고, Assignees에 나를 지정한 뒤 Create
- 만들어진 이슈 번호를 확인합니다. 예) `#12`

### 2. 이슈 번호로 브랜치 만들기
- `main`을 최신으로 받은 뒤 `feat/#이슈번호-본인ID` 브랜치를 만듭니다. 예) `feat/#12-limtjdghks`
- GitKraken: main 더블클릭 → Pull → main 우클릭 → Create branch here

### 3. 작업하고 커밋
- `missions/02-pr-conflict/Members.swift`에서 **내 번호 블록**의 두 줄만 고칩니다.

```swift
// MARK: - 3번
let seoyeong = Member(
    githubID: "본인GitHubID",
    greeting: "하고 싶은 인사말"
)
```

- 커밋 메시지 끝에 이슈 번호를 붙입니다. 예) `feat: 인사말 추가 (#12)` → Push

### 4. PR 올리기
- GitHub에서 `main`으로 PR을 엽니다. 본문의 `Closes #` 뒤에 내 이슈 번호를 적어요. 예) `Closes #12`
- 검사가 초록색이 되면 **merge하지 말고 기다립니다.**

### 5. 충돌 해결 (진행자 PR이 merge된 뒤)
진행자가 PR을 merge하면 내 PR에 `This branch has conflicts that must be resolved`가 뜹니다.

1. GitKraken: 위의 Pull 옆 ▾ → Fetch All
2. 내 브랜치를 더블클릭해서 체크아웃
3. 그래프의 `origin/main` 우클릭 → Merge origin/main into 내 브랜치
4. Xcode에서 `Members.swift`를 열고 내 블록의 마커 3줄을 지웁니다.
   `githubID`는 내 ID로, `greeting`은 둘 중 하나를 고르거나 합칩니다.
5. GitKraken에서 Stage → Commit and Merge → Push

터미널이라면: `git switch feat/#12-본인ID` → `git pull origin main` → 정리 → `git add .` → `git commit` → `git push`

### 6. 병합
- 검사가 초록색이 되면 Merge 합니다. 이슈 #12가 자동으로 Closed 되는지 확인하세요.

검사 내용

- 브랜치 이름이 `feat/#이슈번호-본인ID`인지
- 커밋 메시지에 `#이슈번호`가 있는지
- PR 본문에 `Closes #이슈번호`가 있는지 (본문을 고쳐 저장하면 검사가 다시 돌아요)
- 바꾼 파일이 `Members.swift` 하나뿐인지
- 충돌 마커(`<<<<<<<`, `=======`, `>>>>>>>`)가 남아 있지 않은지
- `githubID`에 PR을 연 계정의 ID가 들어간 블록이 있고, 그 블록 안만 고쳤는지

> PR에 충돌이 남아 있는 동안에는 검사가 실행되지 않아요. 충돌을 풀고 Push 하면 그때 돌아갑니다.

Push 전에 로컬에서 미리 확인할 수도 있어요. (PR 본문 검사는 빠져요)

```bash
git fetch origin
./scripts/check-member-pr.sh origin/main 본인GitHubID 'feat/#12-본인GitHubID'
```

## 보너스: push 거절 해결

```bash
./missions/bonus-push-rejected/setup.sh
```

- `.playground/push-rejected/me` 폴더를 GitKraken에서 엽니다. (동아리 레포와 상관없는 연습용이라 마음껏 해도 돼요)
- 아무 파일이나 만들어 커밋 → Push 하면 거절됩니다.
- 거절 메시지를 읽고 Pull → Push 로 해결하세요.

```bash
./missions/bonus-push-rejected/verify.sh
```
