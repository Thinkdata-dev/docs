---
date: 2025-10-26T01:37:38+09:00
title: "FastAPI + Pydantic V2로 완성하는 타입 안전 REST API"
description: "Pydantic V2와 FastAPI를 결합한 타입 안전한 REST API 구축 방법을 다룹니다. 고급 검증 패턴, 제네릭 응답 모델, 성능 최적화 기법까지 실전 예제로 배워보세요."
categories:
  - Programming
tags:
  - FastAPI
  - Pydantic
  - Python
  - REST API
  - 타입안전성
---

> Pydantic V2와 FastAPI를 결합한 타입 안전한 REST API 구축 방법을 다룹니다. 고급 검증 패턴, 제네릭 응답 모델, 성능 최적화 기법까지 실전 예제로 배워보세요.



<!-- more -->

## Pydantic V2가 가져온 혁신적인 변화

![Pydantic V2 변화](https://source.unsplash.com/800x600/?coding,typescript,validation)

Pydantic V2는 기존 버전 대비 무려 5~50배 빠른 성능을 자랑합니다. Rust로 작성된 pydantic-core 덕분이죠. FastAPI와 결합하면 타입 안전성과 성능을 동시에 잡을 수 있어요. 특히 `ConfigDict`를 통한 설정 방식이 명확해지고, `Field` 검증 기능이 대폭 강화되었습니다.

가장 눈에 띄는 변화는 `Config` 클래스가 사라지고 `model_config`로 통합된 점입니다. 이제 모델 설정이 훨씬 직관적이에요.

python
from pydantic import BaseModel, ConfigDict, Field

class UserBase(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, validate_assignment=True)
    
    username: str = Field(min_length=3, max_length=20)
    email: str = Field(pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$')
    age: int = Field(gt=0, le=150)


## 타입 안전한 API 엔드포인트 설계하기

![API 엔드포인트 설계](https://source.unsplash.com/800x600/?api,restful,architecture)

FastAPI의 진정한 강점은 타입 힌트를 통한 자동 검증입니다. Pydantic V2와 결합하면 런타임 에러를 사전에 방지할 수 있죠. 요청 본문, 쿼리 파라미터, 경로 파라미터 모두 타입 안전하게 처리할 수 있어요.

여기서 핵심은 명확한 입출력 모델 분리입니다. `UserCreate`, `UserResponse`, `UserUpdate`처럼 용도별로 모델을 나누면 API가 훨씬 명확해집니다.

python
from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel
from typing import Annotated

app = FastAPI()

class UserCreate(BaseModel):
    username: str = Field(min_length=3)
    email: str
    password: str = Field(min_length=8)

class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    username: str
    email: str

@app.post("/users/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(user: UserCreate) -> UserResponse:
    # 실제로는 DB 저장 로직
    return UserResponse(id=1, username=user.username, email=user.email)


## 고급 검증 패턴과 커스텀 밸리데이터

![데이터 검증](https://source.unsplash.com/800x600/?security,validation,data)

Pydantic V2는 `@field_validator`와 `@model_validator`로 검증 로직이 더 강력해졌습니다. 필드 단위 검증부터 모델 전체 검증까지 세밀하게 제어할 수 있어요.

`field_validator`는 특정 필드에 대한 커스텀 검증을, `model_validator`는 여러 필드 간 관계를 검증할 때 사용합니다. `mode` 파라미터로 검증 시점도 조절 가능하죠.

python
from pydantic import field_validator, model_validator
from typing import Self
import re

class UserRegistration(BaseModel):
    username: str
    password: str
    password_confirm: str
    email: str
    
    @field_validator('password')
    @classmethod
    def validate_password_strength(cls, v: str) -> str:
        if not re.search(r'[A-Z]', v):
            raise ValueError('비밀번호는 대문자를 포함해야 합니다')
        if not re.search(r'[0-9]', v):
            raise ValueError('비밀번호는 숫자를 포함해야 합니다')
        return v
    
    @model_validator(mode='after')
    def validate_passwords_match(self) -> Self:
        if self.password != self.password_confirm:
            raise ValueError('비밀번호가 일치하지 않습니다')
        return self


## 실전 예제: 중첩 모델과 제네릭 응답

![실전 API 구조](https://source.unsplash.com/800x600/?json,structure,programming)

실무에서는 중첩된 데이터 구조를 자주 다룹니다. Pydantic V2는 중첩 모델 검증이 더욱 효율적이고, 제네릭 타입을 완벽히 지원해요. 페이지네이션 응답이나 표준화된 API 응답 형식을 만들 때 특히 유용합니다.

`TypeVar`와 `Generic`을 활용하면 재사용 가능한 응답 래퍼를 만들 수 있어요.

python
from typing import Generic, TypeVar, List
from pydantic import BaseModel

T = TypeVar('T')

class PaginatedResponse(BaseModel, Generic[T]):
    items: List[T]
    total: int
    page: int
    page_size: int
    
    @property
    def total_pages(self) -> int:
        return (self.total + self.page_size - 1) // self.page_size

class Product(BaseModel):
    id: int
    name: str
    price: float

@app.get("/products/", response_model=PaginatedResponse[Product])
async def list_products(page: int = 1, page_size: int = 10):
    # 실제 DB 쿼리 대신 예제 데이터
    products = [Product(id=i, name=f"Product {i}", price=10.0 * i) for i in range(1, 6)]
    return PaginatedResponse(
        items=products,
        total=50,
        page=page,
        page_size=page_size
    )


## 에러 핸들링과 성능 최적화 팁

![성능 최적화](https://source.unsplash.com/800x600/?performance,speed,optimization)

Pydantic V2의 검증 에러는 훨씬 상세해졌습니다. `ValidationError`를 적절히 핸들링하면 사용자 친화적인 에러 메시지를 제공할 수 있어요. FastAPI는 자동으로 422 상태 코드와 함께 검증 에러를 반환하지만, 커스텀 핸들러로 포맷을 조정할 수 있습니다.

성능 최적화를 위해서는 `model_config`에서 `validate_assignment=False`로 설정하거나, 필요한 경우에만 검증을 수행하는 것이 좋습니다. 또한 `computed_field`를 활용해 파생 속성을 효율적으로 관리할 수 있어요.

**핵심 팁**: `model_dump()`와 `model_dump_json()`을 활용하면 직렬화 성능이 크게 향상됩니다. 특히 `exclude_unset=True` 옵션으로 실제 설정된 필드만 반환하면 API 응답 크기를 줄일 수 있죠.

Pydantic V2의 `TypeAdapter`를 사용하면 모델 클래스 없이도 타입 검증이 가능합니다. 일회성 검증이 필요할 때 유용한 기능입니다.

---

*이 글은 AI가 자동으로 작성했습니다.*
