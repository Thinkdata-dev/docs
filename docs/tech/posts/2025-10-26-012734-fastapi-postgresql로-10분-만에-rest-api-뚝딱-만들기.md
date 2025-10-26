---
date: 2025-10-26T01:27:34+09:00
title: "FastAPI + PostgreSQL로 10분 만에 REST API 뚝딱 만들기"
description: "FastAPI와 PostgreSQL을 활용해 10분 만에 완전한 REST API를 구축하는 방법을 소개합니다. 환경 설정부터 데이터베이스 모델링, 실제 엔드포인트 구현까지 실무에 바로 적용할 수 있는 실전 가이드입니다."
categories:
  - Web Development
tags:
  - FastAPI
  - PostgreSQL
  - REST API
  - Python
  - SQLAlchemy
---

> FastAPI와 PostgreSQL을 활용해 10분 만에 완전한 REST API를 구축하는 방법을 소개합니다. 환경 설정부터 데이터베이스 모델링, 실제 엔드포인트 구현까지 실무에 바로 적용할 수 있는 실전 가이드입니다.



<!-- more -->

## 왜 FastAPI와 PostgreSQL인가?

![FastAPI와 PostgreSQL](https://source.unsplash.com/800x600/?programming,code,database)

요즘 백엔드 개발자들 사이에서 FastAPI가 정말 핫합니다. 기존 Flask나 Django에 비해 압도적으로 빠른 성능과 자동 문서화 기능이 매력적이죠. 여기에 안정성과 성능이 검증된 PostgreSQL을 결합하면 금상첨화입니다.

FastAPI는 Python 3.7+의 타입 힌트를 기반으로 하며, 비동기 처리를 기본으로 지원합니다. 이는 Node.js 수준의 높은 처리량을 자랑하죠. PostgreSQL은 복잡한 쿼리와 트랜잭션 처리에 강점이 있어, 프로덕션 환경에서도 믿고 쓸 수 있는 조합입니다.

**핵심 포인트**: 빠른 개발 속도 + 높은 성능 + 자동 문서화 = 개발자 행복

## 환경 설정과 필수 패키지 설치

![개발 환경 설정](https://source.unsplash.com/800x600/?terminal,setup,computer)

먼저 필요한 패키지들을 설치해봅시다. 가상환경을 만드는 것을 추천드립니다.

bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install fastapi uvicorn sqlalchemy psycopg2-binary


각 패키지의 역할을 간단히 설명하면:
- **fastapi**: 메인 웹 프레임워크
- **uvicorn**: ASGI 서버 (FastAPI 실행용)
- **sqlalchemy**: Python ORM (데이터베이스를 객체처럼 다룸)
- **psycopg2-binary**: PostgreSQL 어댑터

PostgreSQL 설치는 공식 홈페이지나 Docker를 활용하세요. Docker를 사용하면 한 줄로 해결됩니다:

bash
docker run --name postgres -e POSTGRES_PASSWORD=mysecret -p 5432:5432 -d postgres


💡 **실전 팁**: Docker를 사용하면 로컬 환경을 깔끔하게 유지할 수 있고, 팀원들과 동일한 환경을 공유하기 쉽습니다.

## 데이터베이스 모델 설계하기

![데이터베이스 모델링](https://source.unsplash.com/800x600/?database,structure,architecture)

간단한 Todo 앱을 만들어봅시다. `database.py`와 `models.py` 파일을 생성합니다.

python
# database.py
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "postgresql://postgres:mysecret@localhost/todoapp"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


python
# models.py
from sqlalchemy import Column, Integer, String, Boolean
from database import Base

class Todo(Base):
    __tablename__ = "todos"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String)
    completed = Column(Boolean, default=False)


SQLAlchemy의 ORM을 사용하면 SQL 쿼리 대신 Python 객체로 데이터베이스를 조작할 수 있습니다. 코드가 훨씬 직관적이고 유지보수가 쉬워지죠.

**핵심 포인트**: ORM은 데이터베이스 종류를 바꿔도 코드 변경이 최소화되는 장점이 있습니다.

## REST API 엔드포인트 구현

![API 개발](https://source.unsplash.com/800x600/?api,development,coding)

이제 메인 애플리케이션을 만들어봅시다. `main.py` 파일을 생성합니다.

python
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
import models
from database import engine, get_db

models.Base.metadata.create_all(bind=engine)
app = FastAPI(title="Todo API")

class TodoCreate(BaseModel):
    title: str
    description: str = None

class TodoResponse(BaseModel):
    id: int
    title: str
    description: str
    completed: bool
    
    class Config:
        orm_mode = True

@app.post("/todos/", response_model=TodoResponse)
def create_todo(todo: TodoCreate, db: Session = Depends(get_db)):
    db_todo = models.Todo(**todo.dict())
    db.add(db_todo)
    db.commit()
    db.refresh(db_todo)
    return db_todo

@app.get("/todos/", response_model=list[TodoResponse])
def read_todos(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    todos = db.query(models.Todo).offset(skip).limit(limit).all()
    return todos

@app.get("/todos/{todo_id}", response_model=TodoResponse)
def read_todo(todo_id: int, db: Session = Depends(get_db)):
    todo = db.query(models.Todo).filter(models.Todo.id == todo_id).first()
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    return todo


Pydantic 모델은 자동으로 입력 검증과 직렬화를 처리해줍니다. 잘못된 타입의 데이터가 들어오면 자동으로 에러를 반환하죠.

💡 **실전 팁**: `response_model`을 지정하면 FastAPI가 자동으로 응답 데이터를 검증하고 문서화해줍니다.

## 실행하고 테스트하기

![API 테스트](https://source.unsplash.com/800x600/?testing,quality,check)

드디어 실행할 시간입니다!

bash
uvicorn main:app --reload


브라우저에서 `http://localhost:8000/docs`로 접속하면 자동 생성된 Swagger UI 문서를 볼 수 있습니다. 이게 FastAPI의 진짜 매력이죠. 코드만 작성하면 API 문서가 자동으로 만들어집니다!

여기서 바로 API를 테스트할 수 있습니다:
1. POST `/todos/`로 새 Todo 생성
2. GET `/todos/`로 전체 목록 조회
3. GET `/todos/{id}`로 특정 항목 조회

**추가로 구현하면 좋을 기능들**:
- PUT 엔드포인트로 수정 기능
- DELETE 엔드포인트로 삭제 기능
- 페이지네이션 개선
- 사용자 인증 (JWT)
- 에러 핸들링 강화

실제 프로덕션 환경에서는 환경 변수로 DB 연결 정보를 관리하고, Alembic으로 마이그레이션을 처리하는 것을 추천합니다. 보안을 위해 CORS 설정도 꼭 추가하세요.

**핵심 포인트**: FastAPI의 자동 문서화는 프론트엔드 개발자와의 협업을 훨씬 수월하게 만들어줍니다. API 명세를 별도로 작성할 필요가 없으니까요!

---

*이 글은 AI가 자동으로 작성했습니다.*
