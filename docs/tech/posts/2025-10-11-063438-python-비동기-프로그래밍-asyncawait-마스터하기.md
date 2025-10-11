---
date: 2025-10-11T06:34:38+09:00
title: "Python 비동기 프로그래밍: async/await 마스터하기"
description: "Python의 async/await를 활용한 비동기 프로그래밍 완벽 가이드입니다. 기본 문법부터 실전 HTTP 요청, 에러 처리, 성능 최적화까지 실무에 바로 적용할 수 있는 내용을 다룹니다."
categories:
  - Programming
tags:
  - Python
  - 비동기프로그래밍
  - async
  - await
  - asyncio
---

> Python의 async/await를 활용한 비동기 프로그래밍 완벽 가이드입니다. 기본 문법부터 실전 HTTP 요청, 에러 처리, 성능 최적화까지 실무에 바로 적용할 수 있는 내용을 다룹니다.



<!-- more -->

## 비동기 프로그래밍이 필요한 순간

여러분은 웹 스크래핑을 하거나 API를 여러 번 호출할 때 답답함을 느껴본 적 있나요? 한 작업이 끝날 때까지 기다렸다가 다음 작업을 시작하는 동기 방식은 시간이 오래 걸립니다. 비동기 프로그래밍은 이런 대기 시간을 활용해 여러 작업을 동시에 처리하는 방식입니다.

예를 들어, 10개의 웹페이지를 크롤링한다고 가정해볼까요? 동기 방식으로는 각 페이지당 2초씩 총 20초가 걸리지만, 비동기 방식으로는 동시에 요청해서 약 2초 만에 완료할 수 있습니다. I/O 작업(파일 읽기/쓰기, 네트워크 통신, 데이터베이스 쿼리)이 많은 프로그램일수록 비동기의 효과는 극대적입니다.

## async/await 기본 문법 이해하기

Python 3.5부터 도입된 `async`와 `await` 키워드는 비동기 프로그래밍의 핵심입니다. 기본 구조를 살펴볼까요?

python
import asyncio

async def fetch_data(id):
    print(f"데이터 {id} 요청 시작")
    await asyncio.sleep(2)  # 네트워크 요청을 시뮬레이션
    print(f"데이터 {id} 요청 완료")
    return f"결과 {id}"

async def main():
    # 여러 작업을 동시에 실행
    tasks = [fetch_data(i) for i in range(3)]
    results = await asyncio.gather(*tasks)
    print(results)

# 실행
asyncio.run(main())


**핵심 포인트**: `async def`로 코루틴 함수를 정의하고, `await`로 비동기 작업의 완료를 기다립니다. `await`는 다른 작업이 실행될 수 있는 "양보 지점"을 만듭니다. `asyncio.gather()`는 여러 코루틴을 병렬로 실행하고 모든 결과를 수집합니다.

## 실전 예제: 비동기 HTTP 요청

실제 프로젝트에서 가장 많이 사용하는 패턴은 비동기 HTTP 요청입니다. `aiohttp` 라이브러리를 활용해보겠습니다.

python
import aiohttp
import asyncio
import time

async def fetch_url(session, url):
    async with session.get(url) as response:
        return await response.text()

async def fetch_multiple_urls(urls):
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        return await asyncio.gather(*tasks)

# 사용 예시
urls = [
    'https://api.example.com/data/1',
    'https://api.example.com/data/2',
    'https://api.example.com/data/3'
]

start = time.time()
results = asyncio.run(fetch_multiple_urls(urls))
print(f"완료 시간: {time.time() - start:.2f}초")


**💡 실용 팁**: `ClientSession`은 커넥션 풀을 재사용해 성능을 높입니다. 반드시 `async with`로 세션을 관리해 리소스 누수를 방지하세요.

## 에러 처리와 타임아웃 관리

비동기 프로그래밍에서 에러 처리는 더욱 중요합니다. 하나의 작업 실패가 전체를 망치지 않도록 해야 합니다.

python
async def safe_fetch(session, url):
    try:
        async with session.get(url, timeout=5) as response:
            return await response.text()
    except asyncio.TimeoutError:
        return f"타임아웃: {url}"
    except Exception as e:
        return f"에러 발생: {str(e)}"

async def fetch_with_timeout():
    async with aiohttp.ClientSession() as session:
        try:
            # 전체 작업에 타임아웃 설정
            result = await asyncio.wait_for(
                safe_fetch(session, url),
                timeout=10
            )
            return result
        except asyncio.TimeoutError:
            return "전체 작업 타임아웃"


`asyncio.wait_for()`는 특정 작업에 타임아웃을 설정할 수 있습니다. 또한 `return_exceptions=True` 옵션을 `gather()`에 추가하면 예외를 발생시키지 않고 결과 리스트에 포함시킵니다.

## 성능 최적화 팁과 주의사항

비동기 프로그래밍을 효과적으로 사용하려면 몇 가지 원칙을 지켜야 합니다.

**동시 실행 수 제한하기**: 무제한으로 요청하면 서버에 부담을 주거나 메모리가 부족할 수 있습니다. `asyncio.Semaphore`로 제한하세요.

python
async def fetch_with_semaphore(sem, session, url):
    async with sem:  # 동시 실행 수 제한
        return await fetch_url(session, url)

async def controlled_fetch(urls, limit=5):
    sem = asyncio.Semaphore(limit)
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_with_semaphore(sem, session, url) for url in urls]
        return await asyncio.gather(*tasks)


**주의사항**:
- CPU 집약적 작업(복잡한 계산)은 비동기의 이점이 없습니다. `multiprocessing`을 고려하세요.
- 블로킹 함수(일반 `requests` 라이브러리 등)를 `await` 없이 호출하면 이벤트 루프가 멈춥니다.
- 디버깅이 어려울 수 있으니 `asyncio.create_task()`에 이름을 부여하고, 로깅을 충실히 하세요.

비동기 프로그래밍은 처음엔 어렵지만, I/O 바운드 작업에서 엄청난 성능 향상을 가져다줍니다. 작은 프로젝트부터 시작해서 점진적으로 적용해보세요!

---

*이 글은 AI가 자동으로 작성했습니다.*
