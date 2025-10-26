---
date: 2025-10-26T01:20:24+09:00
title: "FastAPI + SQLAlchemy로 비동기 RESTful API 완벽 구현하기"
description: "FastAPI와 SQLAlchemy를 활용한 비동기 RESTful API 구축 방법을 실전 코드와 함께 소개합니다. 데이터베이스 연결부터 CRUD 구현, 성능 최적화까지 실무에 바로 적용 가능한 내용을 담았습니다."
categories:
  - Programming
tags:
  - FastAPI
  - SQLAlchemy
  - 비동기처리
  - RESTful API
  - Python
---

> FastAPI와 SQLAlchemy를 활용한 비동기 RESTful API 구축 방법을 실전 코드와 함께 소개합니다. 데이터베이스 연결부터 CRUD 구현, 성능 최적화까지 실무에 바로 적용 가능한 내용을 담았습니다.



<!-- more -->

## FastAPI와 SQLAlchemy, 왜 함께 써야 할까요?

![FastAPI SQLAlchemy](https://source.unsplash.com/800x600/?api,programming,code)

요즘 파이썬 백엔드 개발에서 FastAPI의 인기가 정말 뜨겁죠. 특히 SQLAlchemy와 함께 사용하면 타입 안정성과 비동기 처리를 모두 잡을 수 있어요. FastAPI는 자동 API 문서화와 빠른 성능을, SQLAlchemy는 강력한 ORM 기능을 제공합니다. 여기에 비동기 처리까지 더하면 동시 요청이 많은 환경에서도 효율적으로 동작하는 API를 만들 수 있습니다.

핵심은 SQLAlchemy 2.0의 비동기 확장인 `asyncpg`를 사용하는 것입니다. 기존 동기 방식보다 훨씬 많은 동시 연결을 처리할 수 있어 실무에서 필수적인 기술이 되었어요.

## 프로젝트 설정과 데이터베이스 연결

![Database Connection Setup](https://source.unsplash.com/800x600/?database,server,technology)

먼저 필요한 패키지를 설치하고 기본 구조를 만들어볼게요. 비동기 PostgreSQL 드라이버인 `asyncpg`를 사용할 거예요.

python
# 필요한 패키지 설치
# pip install fastapi sqlalchemy asyncpg databases uvicorn

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "postgresql+asyncpg://user:password@localhost/dbname"

# 비동기 엔진 생성
engine = create_async_engine(
    DATABASE_URL,
    echo=True,  # SQL 쿼리 로깅
    future=True
)

# 비동기 세션 팩토리
AsyncSessionLocal = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)

Base = declarative_base()


**핵심 포인트**: `create_async_engine`을 사용할 때 URL에 `postgresql+asyncpg`를 명시해야 합니다. 일반 `postgresql`을 쓰면 동기 방식으로 동작해요. 또한 `expire_on_commit=False` 설정으로 커밋 후에도 객체 속성에 접근할 수 있게 합니다.

## 모델 정의와 CRUD 작업 구현

![Database Models](https://source.unsplash.com/800x600/?data,structure,coding)

이제 실제 사용할 모델과 CRUD 함수를 만들어봅시다. User 모델을 예시로 들게요.

python
from sqlalchemy import Column, Integer, String, DateTime
from datetime import datetime
from sqlalchemy.future import select

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    name = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)

# 비동기 CRUD 함수
async def get_user(db: AsyncSession, user_id: int):
    result = await db.execute(
        select(User).filter(User.id == user_id)
    )
    return result.scalars().first()

async def create_user(db: AsyncSession, email: str, name: str):
    user = User(email=email, name=name)
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


**실용 팁**: SQLAlchemy 2.0 스타일에서는 `select()` 함수를 사용하고, 결과는 `scalars()`로 추출합니다. `await db.refresh(user)`를 통해 DB에 저장된 값(자동 생성된 ID 등)을 다시 가져올 수 있어요.

## FastAPI 엔드포인트 구현

![API Endpoints](https://source.unsplash.com/800x600/?api,network,cloud)

이제 실제 API 엔드포인트를 만들어봅시다. 의존성 주입으로 DB 세션을 관리하는 것이 핵심이에요.

python
from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel

app = FastAPI()

class UserCreate(BaseModel):
    email: str
    name: str

class UserResponse(BaseModel):
    id: int
    email: str
    name: str
    
    class Config:
        orm_mode = True

# 의존성: DB 세션 제공
async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()

@app.post("/users/", response_model=UserResponse)
async def create_user_endpoint(
    user: UserCreate,
    db: AsyncSession = Depends(get_db)
):
    db_user = await create_user(db, user.email, user.name)
    return db_user

@app.get("/users/{user_id}", response_model=UserResponse)
async def read_user(
    user_id: int,
    db: AsyncSession = Depends(get_db)
):
    user = await get_user(db, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user


**핵심 포인트**: `get_db()` 의존성 함수는 `async with`를 사용해 세션을 자동으로 관리합니다. 요청이 끝나면 자동으로 세션이 닫히죠. Pydantic 모델의 `orm_mode = True` 설정으로 SQLAlchemy 모델을 자동으로 직렬화할 수 있어요.

## 성능 최적화와 실전 팁

![Performance Optimization](https://source.unsplash.com/800x600/?speed,performance,optimization)

비동기 처리의 진가는 대량의 동시 요청에서 나타납니다. 몇 가지 최적화 팁을 알려드릴게요.

**1. 커넥션 풀 설정**: 엔진 생성 시 `pool_size`와 `max_overflow`를 조정하세요.

python
engine = create_async_engine(
    DATABASE_URL,
    pool_size=20,  # 기본 커넥션 수
    max_overflow=10  # 추가 가능한 커넥션 수
)


**2. N+1 쿼리 문제 해결**: 관계 데이터를 조회할 때는 `selectinload` 또는 `joinedload`를 사용하세요.

**3. 배치 작업**: 여러 레코드를 처리할 때는 `db.execute()`의 배치 기능을 활용하면 성능이 크게 향상됩니다.

**실무 꿀팁**: 개발 환경에서는 `echo=True`로 SQL 쿼리를 확인하고, 프로덕션에서는 꼭 `False`로 설정하세요. 또한 Alembic을 사용한 마이그레이션 관리는 필수입니다. 비동기 환경에서도 Alembic은 동기 방식으로 동작하니 마이그레이션 스크립트 작성 시 주의하세요.

마지막으로, FastAPI의 자동 문서화(`/docs`)를 적극 활용하세요. API 테스트와 문서화를 동시에 해결할 수 있어 팀 협업에 정말 유용합니다!

---

*이 글은 AI가 자동으로 작성했습니다.*
