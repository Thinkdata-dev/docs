---
date: 2025-10-11T04:22:10+09:00
title: "FastAPI + Pydantic으로 10분 만에 타입 안전 API 구축하기"
description: "FastAPI와 Pydantic을 활용해 타입 안전한 REST API를 빠르게 구축하는 방법을 소개합니다. 자동 데이터 검증, API 문서 생성, 그리고 실전에서 바로 쓸 수 있는 팁까지 담았습니다."
categories:
  - Programming
tags:
  - FastAPI
  - Pydantic
  - REST API
  - Python
  - 타입힌트
---

> FastAPI와 Pydantic을 활용해 타입 안전한 REST API를 빠르게 구축하는 방법을 소개합니다. 자동 데이터 검증, API 문서 생성, 그리고 실전에서 바로 쓸 수 있는 팁까지 담았습니다.


## 왜 FastAPI와 Pydantic인가?

파이썬으로 REST API를 만들 때 가장 큰 고민은 무엇일까요? 바로 타입 안정성과 데이터 검증입니다. Flask나 Django도 훌륭하지만, FastAPI는 **Pydantic**과의 완벽한 통합으로 런타임 전에 타입 오류를 잡아내고, 자동으로 API 문서까지 생성해줍니다.

FastAPI는 Python 3.6+의 타입 힌트를 기반으로 작동하며, Starlette과 Pydantic을 활용해 현대적인 비동기 API를 빠르게 구축할 수 있게 해줍니다. 실제로 Uber, Netflix 같은 기업들도 프로덕션 환경에서 사용하고 있죠.

## 5분 만에 기본 API 구축하기

먼저 필요한 패키지를 설치합니다:

bash
pip install fastapi uvicorn[standard] pydantic


이제 간단한 사용자 관리 API를 만들어볼까요? `main.py` 파일을 생성하고 다음 코드를 작성합니다:

python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

app = FastAPI()

class User(BaseModel):
    id: Optional[int] = None
    username: str = Field(..., min_length=3, max_length=20)
    email: EmailStr
    age: int = Field(..., gt=0, lt=150)
    created_at: datetime = Field(default_factory=datetime.now)

users_db = {}

@app.post("/users/", response_model=User)
async def create_user(user: User):
    user.id = len(users_db) + 1
    users_db[user.id] = user
    return user

@app.get("/users/{user_id}", response_model=User)
async def get_user(user_id: int):
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다")
    return users_db[user_id]


서버 실행은 단 한 줄이면 됩니다:

bash
uvicorn main:app --reload


이제 `http://localhost:8000/docs`에 접속하면 **자동 생성된 Swagger UI 문서**를 확인할 수 있습니다!

## Pydantic의 강력한 데이터 검증

Pydantic이 정말 빛나는 순간은 데이터 검증입니다. 위 코드에서 `Field`를 사용한 부분을 주목해보세요:

- `min_length=3, max_length=20`: username은 3~20자 사이여야 합니다
- `EmailStr`: 이메일 형식을 자동으로 검증합니다
- `gt=0, lt=150`: age는 0보다 크고 150보다 작아야 합니다

만약 잘못된 데이터를 보내면 어떻게 될까요?

python
# 잘못된 요청 예시
{
    "username": "ab",  # 너무 짧음
    "email": "invalid-email",  # 잘못된 형식
    "age": -5  # 음수
}


FastAPI는 자동으로 422 Unprocessable Entity 응답과 함께 **정확히 어떤 필드가 왜 잘못되었는지** 친절하게 알려줍니다. 별도의 검증 로직을 작성할 필요가 없죠!

**Pro Tip**: `EmailStr`을 사용하려면 `pip install pydantic[email]`로 추가 패키지를 설치해야 합니다.

## 타입 안전성이 가져다주는 이점

타입 힌트를 사용하면 개발 경험이 완전히 달라집니다:

**1. IDE 자동완성**: VSCode, PyCharm 등에서 속성과 메서드를 자동으로 제안받을 수 있습니다.

**2. 런타임 전 오류 발견**: mypy 같은 정적 분석 도구로 배포 전에 타입 오류를 잡아낼 수 있습니다.

**3. 리팩토링 안전성**: 모델 구조를 변경할 때 영향받는 코드를 쉽게 찾을 수 있습니다.

python
from pydantic import validator

class User(BaseModel):
    username: str
    password: str
    
    @validator('password')
    def password_strength(cls, v):
        if len(v) < 8:
            raise ValueError('비밀번호는 최소 8자 이상이어야 합니다')
        if not any(char.isdigit() for char in v):
            raise ValueError('비밀번호는 숫자를 포함해야 합니다')
        return v


`@validator` 데코레이터로 커스텀 검증 로직도 깔끔하게 추가할 수 있습니다.

## 프로덕션을 위한 추가 팁

실전에서 사용할 때 알아두면 좋은 팁들입니다:

**환경별 설정 관리**:

python
from pydantic import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    
    class Config:
        env_file = ".env"

settings = Settings()


`.env` 파일의 환경 변수를 타입 안전하게 불러올 수 있습니다.

**의존성 주입 활용**:

python
from fastapi import Depends

async def get_current_user(token: str) -> User:
    # 토큰 검증 로직
    return user

@app.get("/me")
async def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user


인증, 데이터베이스 세션 등을 의존성으로 주입하면 코드가 훨씬 깔끔해집니다.

**응답 모델 분리**:

python
class UserCreate(BaseModel):
    username: str
    password: str

class UserResponse(BaseModel):
    id: int
    username: str
    # 비밀번호는 응답에서 제외


입력과 출력 모델을 분리하면 보안과 명확성이 향상됩니다.

이제 여러분도 FastAPI와 Pydantic으로 타입 안전하고 깔끔한 API를 10분 만에 만들 수 있습니다. 자동 문서화, 강력한 검증, 뛰어난 성능까지 한 번에 얻을 수 있죠. 다음 프로젝트에서 한번 시도해보세요!

<!-- more -->

---

*이 글은 AI가 자동으로 작성했습니다.*
