---
date: 2025-10-26T01:35:46+09:00
title: "FastAPI + Pydantic V2로 타입 안전성 100% 보장하는 API 만들기"
description: "FastAPI와 Pydantic V2를 활용해 타입 안전한 REST API를 구축하는 방법을 소개합니다. 자동 검증, 커스텀 검증 로직, OpenAPI 문서 자동 생성까지 실전 코드와 함께 상세히 다룹니다."
categories:
  - Programming
tags:
  - FastAPI
  - Pydantic
  - REST API
  - Python
  - 타입안전성
---

> FastAPI와 Pydantic V2를 활용해 타입 안전한 REST API를 구축하는 방법을 소개합니다. 자동 검증, 커스텀 검증 로직, OpenAPI 문서 자동 생성까지 실전 코드와 함께 상세히 다룹니다.



<!-- more -->

## FastAPI와 Pydantic V2의 완벽한 조합

![FastAPI and Pydantic](https://source.unsplash.com/800x600/?code,api,python)

API 개발하다가 런타임 에러 때문에 밤샘하신 적 있으신가요? FastAPI와 Pydantic V2를 함께 사용하면 이런 고민을 한 방에 해결할 수 있습니다. Pydantic V2는 기존 버전보다 최대 17배 빠른 성능을 자랑하며, Rust 기반의 코어 엔진으로 완전히 재작성되었어요. FastAPI와의 시너지는 말 그대로 환상적입니다.

타입 안전성(Type Safety)이란 컴파일 타임이나 런타임에 데이터 타입을 검증해서 오류를 사전에 방지하는 것을 말합니다. Python처럼 동적 타입 언어에서는 특히 중요한데요, Pydantic이 바로 이 역할을 톡톡히 해줍니다.

## 기본 모델 정의와 검증 자동화

![Data Validation](https://source.unsplash.com/800x600/?validation,data,structure)

Pydantic V2에서는 `BaseModel`을 상속받아 데이터 모델을 정의합니다. 이전 버전과 달리 `ConfigDict`를 사용한 설정 방식이 도입되었어요.

python
from pydantic import BaseModel, Field, ConfigDict, EmailStr
from datetime import datetime
from typing import Optional

class UserCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)
    
    username: str = Field(min_length=3, max_length=20)
    email: EmailStr
    age: int = Field(gt=0, le=150)
    created_at: Optional[datetime] = None

class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    username: str
    email: str
    age: int


여기서 핵심은 `Field` 함수입니다. `min_length`, `gt`(greater than), `le`(less than or equal) 같은 검증 규칙을 선언적으로 정의할 수 있어요. `EmailStr`은 자동으로 이메일 형식을 검증해주죠. `str_strip_whitespace` 설정은 입력값의 앞뒤 공백을 자동으로 제거합니다.

## 실전 FastAPI 엔드포인트 구현

![REST API Development](https://source.unsplash.com/800x600/?api,development,server)

이제 실제 API 엔드포인트를 만들어볼까요? FastAPI는 함수 시그니처만 보고도 자동으로 요청/응답을 검증합니다.

python
from fastapi import FastAPI, HTTPException, status
from typing import List

app = FastAPI()

# 가상 데이터베이스
users_db = []

@app.post("/users/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(user: UserCreate):
    # Pydantic이 자동으로 검증 완료
    new_user = {
        "id": len(users_db) + 1,
        **user.model_dump()
    }
    users_db.append(new_user)
    return new_user

@app.get("/users/", response_model=List[UserResponse])
async def get_users(skip: int = 0, limit: int = 10):
    return users_db[skip:skip + limit]

@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int):
    user = next((u for u in users_db if u["id"] == user_id), None)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user


`response_model` 파라미터는 응답 데이터를 지정된 모델로 직렬화하고 검증합니다. 이렇게 하면 API 문서에도 정확한 스키마가 자동으로 표시되죠. `model_dump()` 메서드는 V2에서 새로 도입된 것으로, 기존의 `dict()` 메서드를 대체합니다.

## 고급 검증 기능 활용하기

![Advanced Coding](https://source.unsplash.com/800x600/?coding,advanced,technology)

Pydantic V2의 진짜 강력함은 커스텀 검증에서 드러납니다. `@field_validator`와 `@model_validator`를 활용하면 복잡한 비즈니스 로직도 우아하게 처리할 수 있어요.

python
from pydantic import field_validator, model_validator
import re

class UserCreateAdvanced(BaseModel):
    username: str = Field(min_length=3, max_length=20)
    email: EmailStr
    password: str = Field(min_length=8)
    password_confirm: str
    age: int = Field(gt=0, le=150)
    
    @field_validator('username')
    @classmethod
    def username_alphanumeric(cls, v: str) -> str:
        if not re.match(r'^[a-zA-Z0-9_]+$', v):
            raise ValueError('사용자명은 영문, 숫자, 언더스코어만 가능합니다')
        return v
    
    @field_validator('password')
    @classmethod
    def password_strength(cls, v: str) -> str:
        if not re.search(r'[A-Z]', v):
            raise ValueError('비밀번호에 대문자가 최소 1개 필요합니다')
        if not re.search(r'[0-9]', v):
            raise ValueError('비밀번호에 숫자가 최소 1개 필요합니다')
        return v
    
    @model_validator(mode='after')
    def passwords_match(self):
        if self.password != self.password_confirm:
            raise ValueError('비밀번호가 일치하지 않습니다')
        return self


`@field_validator`는 개별 필드를 검증하고, `@model_validator`는 모델 전체를 검증합니다. V2에서는 `@classmethod` 데코레이터를 명시적으로 사용해야 하고, `mode='after'`로 모든 필드 검증 후 실행되도록 설정할 수 있어요.

## 실전 팁: OpenAPI 문서 자동 생성 활용

![API Documentation](https://source.unsplash.com/800x600/?documentation,interface,design)

FastAPI의 가장 큰 장점 중 하나는 자동으로 생성되는 대화형 API 문서입니다. 서버를 실행하고 `/docs`에 접속하면 Swagger UI를, `/redoc`에 접속하면 ReDoc을 만날 수 있어요.

더 나은 문서를 위해 모델에 설명을 추가해보세요:

python
class UserCreate(BaseModel):
    """새로운 사용자를 생성하기 위한 요청 모델"""
    
    username: str = Field(
        min_length=3,
        max_length=20,
        description="3~20자 사이의 고유한 사용자명",
        examples=["john_doe"]
    )
    email: EmailStr = Field(
        description="유효한 이메일 주소",
        examples=["user@example.com"]
    )
    age: int = Field(
        gt=0,
        le=150,
        description="사용자의 나이 (1~150)",
        examples=[25]
    )


**실전 팁**: Pydantic V2의 `computed_field`를 활용하면 계산된 필드를 응답에 포함시킬 수 있습니다. 예를 들어 `full_name`을 `first_name`과 `last_name`으로부터 자동 생성하거나, `is_adult`를 `age`로부터 계산하는 식이죠. 성능이 중요하다면 `model_config`의 `validate_assignment=True` 옵션으로 필드 할당 시에도 검증을 활성화할 수 있습니다.

FastAPI와 Pydantic V2의 조합은 타입 안전성, 성능, 개발자 경험 모두를 만족시킵니다. 자동 검증과 명확한 에러 메시지로 디버깅 시간을 크게 줄일 수 있고, 자동 생성되는 문서는 프론트엔드 개발자와의 협업을 한결 수월하게 만들어줍니다.

---

*이 글은 AI가 자동으로 작성했습니다.*
