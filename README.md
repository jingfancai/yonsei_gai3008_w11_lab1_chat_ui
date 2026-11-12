# 실습 1 — 채팅 UI (GAI3008-01 · 11주차)

> 목표: **보내고 받는 모양**을 먼저 만든다. API는 다음 실습에서 붙인다.
> 기존 예제 대화를 유지하면서 말풍선, 입력창, 빈 상태와 키보드 대응을 구현했습니다.

## 실행

```bash
flutter pub get
flutter run -d chrome      # 또는 -d <에뮬레이터>
```

서버가 필요 없다. `_messages`에 들어 있는 가짜 대화로 화면만 만든다.

## 할 일

| # | 내용 | 상태 |
|---|---|---|
| 1 | `ListView.builder` + `reverse: true` — 최신이 아래 | ✅ **완성됨** |
| 2 | 말풍선 2종 — 사용자 오른쪽 / AI 왼쪽 | ✅ 완료 |
| 3 | 입력창 `TextField` + 전송 버튼 | ✅ 완료 |
| 4 | 빈 상태 — "무엇이든 물어보세요" | ✅ 완료 |
| 5 | 키보드가 입력창을 가리지 않게 | ✅ 완료 |

전송 버튼 또는 키보드 전송으로 메시지를 보냅니다. 공백 메시지는 무시하며,
약 1.5초 동안 세 점의 타이핑 애니메이션을 표시한 뒤 모의 응답을 추가합니다.
응답 대기 중에는 중복 전송을 막고, 사용자 메시지와 응답 추가 시 최신 대화로 이동합니다.
실제 AI API나 별도 패키지는 사용하지 않습니다.
`ChatPage(initialMessages: const [])`로 빈 상태를 확인할 수 있습니다.

검증 명령 (Dart 3.12 이상을 포함하는 Flutter SDK 필요):

```bash
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build web
```

위젯 테스트는 예제 대화, 빈 상태, 전송/공백 처리, 타이핑과 모의 응답,
자동 스크롤, 화면 종료 시 리소스 정리를 확인합니다.

## 완료 기준 (수업 중 통과)

- 말풍선이 **좌우로** 나뉜다
- 입력창이 화면 **아래**에 붙어 있다
- 목록이 비면 **빈 상태 문구**가 보인다
- 키보드가 올라와도 입력창이 **가려지지 않는다**

## 힌트

- `reverse: true`면 index 0이 **화면 맨 아래**다. 그래서 `_messages[length - 1 - i]`로 꺼낸다.
- 색은 `Theme.of(context).colorScheme`에서 꺼내면 다크 모드에서도 안전하다.
- `TextEditingController`는 `dispose()`에서 정리한다.
- `ListView`를 `Stack`으로 감싸면 빈 상태를 위에 겹칠 수 있다.

## 구조

```
lib/main.dart          ← 채팅 화면 및 TypingDots
test/widget_test.dart  ← 채팅 동작 위젯 테스트
```

## 제출

- 이 저장소를 `fork` → 브랜치 `feat/내이름-chat`
- 커밋 2개 이상, PR 1개
- PR 본문 3줄: 무엇 · 왜 · 시험

---

ⓒ 2026 Baryon Labs · 연세대학교 GAI3008-01 응용모바일프로그래밍 교육자료
