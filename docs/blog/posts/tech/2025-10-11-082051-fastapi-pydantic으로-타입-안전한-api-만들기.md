---
date: 2025-10-11T08:20:51+09:00
title: "FastAPI + Pydantic으로 타입 안전한 API 만들기"
description: "FastAPI와 Pydantic을 활용해 타입 안전한 REST API를 구축하는 실전 가이드입니다. 데이터 검증, 모델 설계, 고급 검증 패턴부터 실무 베스트 프랙티스까지 다룹니다."
categories:
  - Programming
tags:
  - FastAPI
  - Pydantic
  - Python
  - REST API
  - 타입안전성
---

> FastAPI와 Pydantic을 활용해 타입 안전한 REST API를 구축하는 실전 가이드입니다. 데이터 검증, 모델 설계, 고급 검증 패턴부터 실무 베스트 프랙티스까지 다룹니다.



<!-- more -->

## FastAPI와 Pydantic, 왜 함께 사용할까요?

파이썬은 동적 타입 언어라는 장점이 있지만, API 개발에서는 이것이 오히려 위험 요소가 될 수 있습니다. 클라이언트가 잘못된 타입의 데이터를 보내거나, 개발자가 실수로 다른 타입을 반환하면 런타임 에러가 발생하죠.

FastAPI는 Pydantic을 활용해 이 문제를 완벽하게 해결합니다. 요청과 응답 데이터의 타입을 컴파일 타임에 검증하고, 자동으로 문서화까지 해주는 강력한 조합입니다. 실제 프로덕션 환경에서 타입 관련 버그를 90% 이상 줄일 수 있는 효과적인 방법이에요.

## Pydantic 모델로 데이터 구조 정의하기

Pydantic 모델은 단순한 데이터 검증을 넘어 비즈니스 로직까지 표현할 수 있는 강력한 도구입니다. 실무에서 자주 사용하는 패턴을 살펴볼까요?

python
from pydantic import BaseModel, Field, EmailStr, validator
from typing import Optional
from datetime import datetime

class UserCreate(BaseModel):
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=20)
    password: str = Field(..., min_length=8)
    age: Optional[int] = Field(None, ge=18, le=120)
    
    @validator('username')
    def username_alphanumeric(cls, v):
        assert v.isalnum(), '영문자와 숫자만 사용 가능합니다'
        return v

class UserResponse(BaseModel):
    id: int
    email: EmailStr
    username: str
    created_at: datetime
    
    class Config:
        orm_mode = True  # ORM 객체를 자동 변환


여기서 핵심은 `Field`를 사용한 세밀한 검증과 `validator`를 통한 커스텀 로직입니다. `EmailStr`은 이메일 형식을 자동 검증하고, `orm_mode`는 SQLAlchemy 같은 ORM 객체를 직접 응답 모델로 변환해줍니다.

**💡 실무 팁**: 요청 모델과 응답 모델을 분리하세요. `UserCreate`는 비밀번호를 받지만, `UserResponse`는 보안상 비밀번호를 제외합니다.

## FastAPI 엔드포인트에서 타입 안전성 확보하기

이제 정의한 모델을 FastAPI 엔드포인트에 적용해봅시다. 타입 힌트만 추가하면 자동으로 검증과 문서화가 이루어집니다.

python
from fastapi import FastAPI, HTTPException, status
from typing import List

app = FastAPI()

@app.post("/users", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(user: UserCreate):
    # user는 이미 검증된 UserCreate 인스턴스
    if await check_user_exists(user.email):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="이미 존재하는 이메일입니다"
        )
    
    db_user = await save_user(user)
    return db_user  # UserResponse로 자동 변환됨

@app.get("/users", response_model=List[UserResponse])
async def get_users(skip: int = 0, limit: int = 100):
    users = await fetch_users(skip, limit)
    return users

@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int):
    user = await fetch_user_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="사용자를 찾을 수 없습니다"
        )
    return user


`response_model` 파라미터가 핵심입니다. 이것이 있으면 FastAPI는 반환값을 자동으로 검증하고, 모델에 정의되지 않은 필드는 제외합니다. 예를 들어 데이터베이스 객체에 `password_hash`가 있어도 응답에는 포함되지 않죠.

## 고급 검증 패턴과 에러 핸들링

실무에서는 더 복잡한 검증 로직이 필요합니다. Pydantic의 고급 기능을 활용해봅시다.

python
from pydantic import BaseModel, root_validator
from typing import Optional

class DateRangeQuery(BaseModel):
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    
    @root_validator
    def check_date_range(cls, values):
        start = values.get('start_date')
        end = values.get('end_date')
        if start and end and start > end:
            raise ValueError('시작일은 종료일보다 앞서야 합니다')
        return values

class PasswordChange(BaseModel):
    old_password: str
    new_password: str = Field(..., min_length=8)
    confirm_password: str
    
    @root_validator
    def passwords_match(cls, values):
        new_pw = values.get('new_password')
        confirm_pw = values.get('confirm_password')
        if new_pw != confirm_pw:
            raise ValueError('새 비밀번호가 일치하지 않습니다')
        return values


`root_validator`는 여러 필드를 함께 검증할 때 사용합니다. 날짜 범위 검증이나 비밀번호 확인처럼 필드 간 관계를 체크할 때 필수적이죠.

**⚠️ 주의사항**: ValidationError는 FastAPI가 자동으로 422 응답으로 변환합니다. 커스텀 에러 메시지를 원한다면 HTTPException을 사용하세요.

## 실전 체크리스트와 베스트 프랙티스

타입 안전한 API를 구축할 때 꼭 기억해야 할 포인트들을 정리했습니다.

**모델 설계 원칙**
- 요청/응답 모델을 명확히 분리하세요
- `Optional`은 필수가 아닌 필드에만 사용하세요
- 민감한 정보는 응답 모델에서 제외하세요

**검증 전략**
- `Field`로 기본 제약사항을 정의하고, `validator`로 복잡한 로직을 처리하세요
- 비즈니스 로직 검증은 엔드포인트에서, 데이터 형식 검증은 모델에서 수행하세요
- 에러 메시지는 사용자 친화적으로 작성하세요

**성능 최적화**
- `response_model_exclude_unset=True`를 사용해 설정되지 않은 필드를 제외하세요
- 대용량 리스트 응답에는 페이지네이션을 적용하세요
- `Config.orm_mode`로 ORM 객체 변환 오버헤드를 줄이세요

python
@app.get("/users/{user_id}", response_model=UserResponse, response_model_exclude_unset=True)
async def get_user(user_id: int):
    return await fetch_user(user_id)


FastAPI와 Pydantic의 조합은 파이썬 API 개발의 새로운 표준이 되었습니다. 타입 안전성을 확보하면서도 파이썬의 생산성을 유지할 수 있는 최고의 선택이죠. 오늘 배운 패턴들을 프로젝트에 적용해보시고, 더 견고한 API를 만들어보세요!

---

*이 글은 AI가 자동으로 작성했습니다.*
