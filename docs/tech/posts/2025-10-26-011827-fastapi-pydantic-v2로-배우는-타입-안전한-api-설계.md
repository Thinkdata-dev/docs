---
date: 2025-10-26T01:18:27+09:00
title: "FastAPI + Pydantic V2로 배우는 타입 안전한 API 설계"
description: "Pydantic V2와 FastAPI를 활용한 타입 안전한 REST API 구축 방법을 실전 코드와 함께 소개합니다. 기본 검증부터 고급 패턴, 베스트 프랙티스까지 다룹니다."
categories:
  - Programming
tags:
  - FastAPI
  - Pydantic
  - Python
  - REST API
  - 타입안전성
---

> Pydantic V2와 FastAPI를 활용한 타입 안전한 REST API 구축 방법을 실전 코드와 함께 소개합니다. 기본 검증부터 고급 패턴, 베스트 프랙티스까지 다룹니다.



<!-- more -->

## Pydantic V2의 새로운 변화

![Pydantic V2 변화](https://source.unsplash.com/800x600/?coding,python,api)

Pydantic V2는 기존 버전 대비 최대 17배 빠른 성능을 자랑합니다. Rust로 재작성된 코어 엔진 덕분이죠. FastAPI와 함께 사용하면 런타임에서 발생할 수 있는 타입 오류를 컴파일 타임에 잡아낼 수 있어 안정성이 크게 향상됩니다.

가장 큰 변화는 `Field` 사용 방식과 `model_config` 도입입니다. 기존 `Config` 클래스 방식에서 딕셔너리 기반 설정으로 바뀌면서 더 직관적으로 사용할 수 있게 되었어요. 마이그레이션이 부담스럽다면 공식 마이그레이션 가이드를 참고하면 단계별로 진행할 수 있습니다.

## 기본 모델 정의와 검증

![데이터 검증](https://source.unsplash.com/800x600/?validation,security,code)

Pydantic V2에서는 `BaseModel`을 상속받아 타입 안전한 데이터 모델을 만듭니다. 여기서 핵심은 단순 타입 힌트가 아닌, 런타임 검증까지 수행한다는 점입니다.

python
from pydantic import BaseModel, Field, EmailStr
from typing import Optional
from datetime import datetime

class UserCreate(BaseModel):
    username: str = Field(min_length=3, max_length=20)
    email: EmailStr
    age: int = Field(ge=0, le=120)
    created_at: Optional[datetime] = None
    
    model_config = {
        "json_schema_extra": {
            "examples": [{
                "username": "john_doe",
                "email": "john@example.com",
                "age": 25
            }]
        }
    }


`Field` 함수로 세밀한 검증 규칙을 설정할 수 있습니다. `ge`(greater than or equal)는 최솟값, `le`(less than or equal)는 최댓값을 의미합니다. `EmailStr`은 이메일 형식을 자동으로 검증하는데, 사용하려면 `pip install pydantic[email]`로 추가 설치가 필요합니다.

## FastAPI 엔드포인트 구현

![API 엔드포인트](https://source.unsplash.com/800x600/?api,server,technology)

FastAPI는 Pydantic 모델을 자동으로 인식해 요청/응답 검증, API 문서 생성, JSON 스키마 변환을 모두 처리합니다. 개발자는 비즈니스 로직에만 집중할 수 있죠.

python
from fastapi import FastAPI, HTTPException, status
from typing import List

app = FastAPI(title="User Management API")

class UserResponse(BaseModel):
    id: int
    username: str
    email: EmailStr
    is_active: bool = True

@app.post("/users/", 
          response_model=UserResponse,
          status_code=status.HTTP_201_CREATED)
async def create_user(user: UserCreate):
    # 이 시점에 user는 이미 검증된 상태
    if user.username == "admin":
        raise HTTPException(
            status_code=400,
            detail="Username 'admin' is reserved"
        )
    
    return UserResponse(
        id=1,
        username=user.username,
        email=user.email
    )

@app.get("/users/", response_model=List[UserResponse])
async def list_users():
    return [
        UserResponse(id=1, username="user1", email="user1@example.com")
    ]


`response_model`을 지정하면 실제 응답 데이터가 해당 모델과 일치하는지 검증합니다. 이를 통해 API 계약(Contract)을 명확히 하고, 잘못된 데이터가 반환되는 것을 방지할 수 있습니다.

## 고급 검증 패턴

![고급 검증](https://source.unsplash.com/800x600/?development,programming,quality)

Pydantic V2는 복잡한 비즈니스 로직을 검증하는 강력한 도구들을 제공합니다. `field_validator`와 `model_validator`를 활용하면 커스텀 검증 로직을 우아하게 구현할 수 있어요.

python
from pydantic import field_validator, model_validator
import re

class UserCreateAdvanced(BaseModel):
    username: str
    password: str
    password_confirm: str
    bio: Optional[str] = None
    
    @field_validator('username')
    @classmethod
    def username_alphanumeric(cls, v: str) -> str:
        if not re.match(r'^[a-zA-Z0-9_]+$', v):
            raise ValueError('영문, 숫자, 언더스코어만 사용 가능합니다')
        return v
    
    @field_validator('password')
    @classmethod
    def password_strength(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError('비밀번호는 최소 8자 이상이어야 합니다')
        if not any(char.isdigit() for char in v):
            raise ValueError('최소 1개의 숫자를 포함해야 합니다')
        return v
    
    @model_validator(mode='after')
    def passwords_match(self):
        if self.password != self.password_confirm:
            raise ValueError('비밀번호가 일치하지 않습니다')
        return self


**핵심 포인트**: `field_validator`는 개별 필드 검증에, `model_validator`는 여러 필드 간 관계 검증에 사용합니다. `mode='after'`는 모든 필드 검증이 완료된 후 실행된다는 의미입니다.

## 실전 팁과 베스트 프랙티스

![베스트 프랙티스](https://source.unsplash.com/800x600/?tips,learning,success)

**모델 분리 전략**: 요청용(`UserCreate`), 응답용(`UserResponse`), DB용(`UserInDB`) 모델을 분리하세요. 같은 필드라도 상황에 따라 검증 규칙이 다를 수 있습니다. 예를 들어 비밀번호는 생성 시에만 필요하고 응답에는 포함되면 안 되죠.

**재사용 가능한 검증기**: 자주 사용하는 검증 로직은 별도 함수로 분리하면 여러 모델에서 재사용할 수 있습니다.

python
from pydantic import field_validator

def validate_korean_phone(v: str) -> str:
    pattern = r'^01[0-9]-\d{4}-\d{4}$'
    if not re.match(pattern, v):
        raise ValueError('올바른 전화번호 형식이 아닙니다')
    return v

class ContactModel(BaseModel):
    phone: str
    
    _validate_phone = field_validator('phone')(validate_korean_phone)


**환경별 설정**: `model_config`의 `str_strip_whitespace=True`를 설정하면 입력값의 앞뒤 공백을 자동으로 제거합니다. 사용자 실수를 방지하는 좋은 방법이에요.

FastAPI와 Pydantic V2의 조합은 Python으로 엔터프라이즈급 API를 만드는 최고의 선택입니다. 타입 안전성은 단순히 버그를 줄이는 것을 넘어, 코드의 의도를 명확히 하고 유지보수성을 높여줍니다. 지금 바로 프로젝트에 적용해보세요!

---

*이 글은 AI가 자동으로 작성했습니다.*
