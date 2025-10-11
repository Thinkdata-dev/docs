---
date: 2025-10-11T04:26:01+09:00
title: "FastAPI + SQLAlchemy로 10분 만에 REST API 뚝딱 만들기"
description: "FastAPI와 SQLAlchemy를 조합하여 빠르고 견고한 REST API를 만드는 방법을 단계별로 소개합니다. 프로젝트 세팅부터 CRUD 구현까지, 초보자도 10분이면 따라할 수 있는 실전 가이드입니다."
categories:
  - Programming
tags:
  - FastAPI
  - SQLAlchemy
  - REST API
  - Python
  - 백엔드
---

> FastAPI와 SQLAlchemy를 조합하여 빠르고 견고한 REST API를 만드는 방법을 단계별로 소개합니다. 프로젝트 세팅부터 CRUD 구현까지, 초보자도 10분이면 따라할 수 있는 실전 가이드입니다.


## FastAPI와 SQLAlchemy, 왜 이 조합일까요?

파이썬으로 빠르게 API를 만들고 싶다면 FastAPI와 SQLAlchemy의 조합만한 게 없습니다. FastAPI는 자동 문서화와 빠른 성능을 자랑하고, SQLAlchemy는 데이터베이스를 파이썬 코드로 다룰 수 있게 해주는 ORM(Object-Relational Mapping)이죠. 이 둘을 합치면 타입 안정성까지 갖춘 견고한 API를 정말 빠르게 구축할 수 있습니다.

특히 FastAPI는 Pydantic을 기반으로 하기 때문에 요청/응답 데이터의 유효성 검증이 자동으로 이뤄집니다. 개발자가 일일이 검증 코드를 작성할 필요가 없다는 뜻이죠. SQLAlchemy는 Raw SQL 없이도 복잡한 쿼리를 작성할 수 있어 유지보수가 훨씬 편리합니다.

## 프로젝트 세팅하기

먼저 필요한 패키지들을 설치해볼까요? 가상환경을 만들고 다음 명령어를 실행하세요.

bash
pip install fastapi sqlalchemy uvicorn[standard]


프로젝트 구조는 이렇게 구성하는 것을 추천합니다:


project/
├── main.py
├── database.py
├── models.py
└── schemas.py


`database.py`에서 데이터베이스 연결을 설정합니다. SQLite를 사용하면 별도 설치 없이 바로 시작할 수 있어요.

python
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


## 모델과 스키마 정의하기

`models.py`에는 데이터베이스 테이블 구조를, `schemas.py`에는 API 요청/응답 형식을 정의합니다. 간단한 Todo 앱을 만들어볼게요.

python
# models.py
from sqlalchemy import Column, Integer, String, Boolean
from database import Base

class Todo(Base):
    __tablename__ = "todos"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    completed = Column(Boolean, default=False)


python
# schemas.py
from pydantic import BaseModel

class TodoCreate(BaseModel):
    title: str
    completed: bool = False

class TodoResponse(BaseModel):
    id: int
    title: str
    completed: bool
    
    class Config:
        orm_mode = True


**💡 Tip:** Pydantic의 `orm_mode=True`는 SQLAlchemy 모델을 자동으로 Pydantic 모델로 변환해줍니다. 매우 편리한 기능이죠!

## API 엔드포인트 만들기

이제 `main.py`에서 실제 API를 구현합니다. CRUD(Create, Read, Update, Delete) 기능을 모두 만들어볼게요.

python
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal, engine, Base
from models import Todo
from schemas import TodoCreate, TodoResponse

Base.metadata.create_all(bind=engine)

app = FastAPI()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/todos/", response_model=TodoResponse)
def create_todo(todo: TodoCreate, db: Session = Depends(get_db)):
    db_todo = Todo(**todo.dict())
    db.add(db_todo)
    db.commit()
    db.refresh(db_todo)
    return db_todo

@app.get("/todos/", response_model=list[TodoResponse])
def read_todos(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    todos = db.query(Todo).offset(skip).limit(limit).all()
    return todos

@app.get("/todos/{todo_id}", response_model=TodoResponse)
def read_todo(todo_id: int, db: Session = Depends(get_db)):
    todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if todo is None:
        raise HTTPException(status_code=404, detail="Todo not found")
    return todo


`Depends(get_db)`는 FastAPI의 의존성 주입(Dependency Injection) 시스템입니다. 각 요청마다 데이터베이스 세션을 생성하고 자동으로 정리해줍니다.

## 서버 실행하고 테스트하기

이제 서버를 실행해볼까요?

bash
uvicorn main:app --reload


브라우저에서 `http://localhost:8000/docs`로 접속하면 자동으로 생성된 Swagger UI 문서를 볼 수 있습니다. 여기서 바로 API를 테스트해볼 수 있어요!

**⚡ 핵심 포인트:**
- FastAPI의 자동 문서화 기능으로 별도 API 문서 작성 불필요
- 타입 힌트만 잘 작성하면 입력값 검증이 자동으로 처리됨
- SQLAlchemy의 세션 관리를 의존성 주입으로 깔끔하게 처리

실무에서는 여기에 인증, 에러 핸들링, 마이그레이션 도구(Alembic) 등을 추가하면 됩니다. 하지만 기본 골격은 이것으로 충분합니다. 10분이면 정말 작동하는 REST API가 완성되니, 직접 해보시면 그 편리함에 놀라실 거예요!

<!-- more -->

---

*이 글은 AI가 자동으로 작성했습니다.*
