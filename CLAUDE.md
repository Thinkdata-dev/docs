# Thinkdata Blog - Claude AI 가이드

## 프로젝트 개요

AI가 자동으로 작성하는 기술 블로그입니다.

**주요 기술:**
- MkDocs Material (정적 사이트 생성기)
- GitHub Pages (호스팅)
- n8n (워크플로우 자동화)
- Claude API (콘텐츠 생성)

**배포 URL:** https://thinkdata-dev.github.io/docs/

---

## 프로젝트 구조

```
docs/
├── CLAUDE.md              # 이 파일 - Claude를 위한 가이드
├── mkdocs.yml            # MkDocs 설정 파일
├── docs/                 # 콘텐츠 디렉토리
│   ├── index.md         # 홈페이지
│   ├── blog/
│   │   ├── index.md     # 블로그 메인 페이지
│   │   └── posts/       # ⭐ 블로그 포스트들이 여기에!
│   └── assets/
│       └── images/      # 이미지 파일들
├── .github/
│   └── workflows/
│       └── deploy.yml   # GitHub Actions 자동 배포
└── site/                # 빌드 결과물 (git ignore)
```

---

## 블로그 포스트 작성 규칙

### 파일 위치 및 명명
- **위치:** `docs/blog/posts/`
- **파일명 형식:** `YYYY-MM-DD-slug.md`
  - 예: `2025-01-10-python-async-tutorial.md`
- **슬러그 규칙:**
  - 소문자만 사용
  - 공백은 하이픈(-)으로
  - 특수문자 제거
  - 50자 이내

### Front Matter (필수)

모든 블로그 포스트는 다음 형식의 YAML Front Matter로 시작해야 합니다:

```yaml
---
date: YYYY-MM-DD
title: "포스트 제목"
description: "SEO를 위한 간단한 설명 (150-160자)"
categories:
  - Technology
  - (필요시 추가 카테고리)
tags:
  - 관련태그1
  - 관련태그2
  - 관련태그3
  - (5-7개 권장)
---
```

### 포스트 구조 템플릿

```markdown
---
date: 2025-01-10
title: "제목"
description: "설명"
categories:
  - Technology
tags:
  - python
  - tutorial
---

# 제목

간단한 도입부나 요약 (1-2문단)

<!-- more -->

## 서론 (Introduction)

문제 제기 또는 배경 설명

## 본론 (Main Content)

### 소제목 1

내용 작성...

```python
# 코드 예제는 언어를 명시
def example_function():
    """독스트링 포함"""
    pass
```

### 소제목 2

내용 작성...

## 결론 (Conclusion)

요약 및 핵심 포인트

## 참고 자료 (References)

- [링크 텍스트](URL)

---

*이 글은 AI가 자동으로 작성했습니다.*
```

---

## 콘텐츠 작성 가이드라인

### 1. 타겟 독자
- **주 대상:** 초중급 개발자
- **톤:** 친근하고 설명적
- **깊이:** 실용적이고 따라할 수 있는 수준

### 2. 글쓰기 스타일
- ✅ **명확하고 간결하게:** 복잡한 개념도 쉽게 설명
- ✅ **예제 중심:** 이론보다 실제 코드 예제
- ✅ **단계별 설명:** 초보자도 따라할 수 있게
- ✅ **시각 자료:** 필요시 다이어그램이나 스크린샷 제안
- ❌ **지나친 전문용어:** 필수 용어는 설명 추가
- ❌ **너무 길게:** 읽기 시간 5-10분 내외

### 3. 코드 예제 작성
```python
# ✅ 좋은 예제
def calculate_total(items: list[float]) -> float:
    """
    주어진 아이템들의 총합을 계산합니다.
    
    Args:
        items: 숫자 리스트
    
    Returns:
        총합
    """
    return sum(items)

# 예제 사용
prices = [10.5, 20.0, 15.75]
total = calculate_total(prices)
print(f"Total: ${total:.2f}")  # Total: $46.25
```

**코드 예제 규칙:**
- 주석으로 설명 추가
- 독스트링 포함
- 실행 가능한 완전한 코드
- 출력 결과 표시

### 4. SEO 최적화
- **제목:** 50-60자, 키워드 포함
- **Description:** 150-160자, 핵심 내용 요약
- **헤딩 구조:** H1(제목) → H2(섹션) → H3(하위 섹션)
- **내부 링크:** 관련 포스트 연결
- **태그:** 구체적이고 검색 가능한 키워드

---

## 카테고리 시스템

### 사용 가능한 카테고리
- `Technology` - 일반 기술 주제
- `Programming` - 프로그래밍 언어, 패턴
- `Web Development` - 웹 개발
- `AI & ML` - 인공지능, 머신러닝
- `DevOps` - 배포, 인프라
- `Data Science` - 데이터 분석, 시각화
- `Tutorial` - 단계별 튜토리얼
- `Opinion` - 의견, 리뷰

### 카테고리 선택 가이드
- **주 카테고리 1개:** 가장 적합한 것
- **부 카테고리 0-1개:** 필요시만 추가
- **일관성 유지:** 비슷한 주제는 같은 카테고리

---

## 자주 사용하는 명령어

### 로컬 개발
```bash
# 개발 서버 시작 (자동 리로드)
mkdocs serve

# 브라우저에서 http://127.0.0.1:8000 접속
```

### 빌드 및 배포
```bash
# 로컬 빌드 테스트
mkdocs build

# 배포 (일반적으로 자동이지만 수동시)
mkdocs gh-deploy

# 정상 배포는 git push만 하면 자동
git add .
git commit -m "Add new post"
git push
```

### 유효성 검사
```bash
# 링크 체크 (빌드 strict 모드)
mkdocs build --strict

# 마크다운 린팅
markdownlint docs/**/*.md
```

---

## ⚠️ 절대 하지 말아야 할 것

### 1. 파일 및 디렉토리
- ❌ **`gh-pages` 브랜치 직접 수정 금지**
  - GitHub Actions가 자동 관리
- ❌ **`site/` 디렉토리 커밋 금지**
  - 빌드 결과물이므로 .gitignore에 포함
- ❌ **`docs/blog/posts/` 외부에 포스트 생성 금지**
  - 반드시 이 디렉토리 안에만

### 2. 보안
- ❌ **API 키나 토큰 절대 커밋 금지**
- ❌ **개인정보 포함 금지**
- ❌ **`.env` 파일 커밋 금지**

### 3. 콘텐츠
- ❌ **저작권 침해 금지**
  - 코드 예제는 출처 명시
  - 이미지는 라이센스 확인
- ❌ **표절 금지**
  - AI 생성 후에도 독창성 유지
- ❌ **부정확한 정보 금지**
  - 기술 내용은 검증 필수

---

## 우선순위

작업 시 다음 우선순위를 따릅니다:

1. **🎯 사용자 경험**
   - 읽기 쉽고 유용한 콘텐츠
   - 명확한 설명과 예제
   - 접근성 고려

2. **🔍 SEO 최적화**
   - 적절한 메타데이터
   - 의미있는 제목 구조
   - 내부 링크 구축

3. **⚡ 성능**
   - 빠른 로딩
   - 최적화된 이미지
   - 불필요한 플러그인 지양

4. **🎨 디자인 일관성**
   - 통일된 스타일
   - 표준 템플릿 준수
   - 브랜딩 유지

---

## Claude Code 사용 예시

## 개발 환경 설정

로컬 개발을 시작하기 전에 Python 가상환경(venv)을 설정하세요. 자세한 단계는 `VENV_SETUP.md` 파일을 참고하세요.


### 새 포스트 작성
```bash
claude "Python type hints에 대한 초보자용 튜토리얼을 작성해줘.
docs/blog/posts/ 디렉토리에 오늘 날짜로 파일 생성하고,
실제 동작하는 코드 예제 5개 이상 포함해줘."
```

### 기존 포스트 개선
```bash
claude "docs/blog/posts/2025-01-10-example.md 파일을 열어서
코드 예제에 주석을 더 자세히 추가하고,
각 섹션에 요약 문단을 추가해줘."
```

### 일괄 작업
```bash
claude "docs/blog/posts/ 디렉토리의 모든 포스트에서
'```' 코드 블록에 언어가 명시되지 않은 것들을 찾아서
적절한 언어를 추가해줘."
```

### 구조 분석
```bash
claude "현재 블로그의 모든 포스트를 분석해서:
1. 가장 많이 사용된 태그 10개
2. 카테고리별 포스트 수
3. 평균 글자 수
4. 개선 제안
을 알려줘."
```

---

## 참고 문서

- **MkDocs Material:** https://squidfunk.github.io/mkdocs-material/
- **Markdown 가이드:** https://www.markdownguide.org/
- **GitHub Pages:** https://docs.github.com/en/pages
- **n8n 문서:** https://docs.n8n.io/

---

## 변경 이력

- 2025-01-10: 초기 가이드 작성

---

**마지막 업데이트:** 2025-01-10  
**관리자:** Thinkdata-dev