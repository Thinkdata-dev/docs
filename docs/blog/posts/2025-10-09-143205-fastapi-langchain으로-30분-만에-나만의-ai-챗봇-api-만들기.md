---
date: 2025-10-09T14:32:05+09:00
title: "FastAPI + LangChain으로 30분 만에 나만의 AI 챗봇 API 만들기"
description: "FastAPI와 LangChain을 활용하여 30분 만에 AI 챗봇 API를 구축하는 실전 튜토리얼입니다. 환경 설정부터 세션 관리, API 엔드포인트 구현까지 단계별로 설명하며, 실제 동작하는 코드 예제를 제공합니다."
categories:
  - AI & ML
tags:
  - FastAPI
  - LangChain
  - 챗봇
  - OpenAI
  - Python
---

> FastAPI와 LangChain을 활용하여 30분 만에 AI 챗봇 API를 구축하는 실전 튜토리얼입니다. 환경 설정부터 세션 관리, API 엔드포인트 구현까지 단계별로 설명하며, 실제 동작하는 코드 예제를 제공합니다.


## 시작하기 전에

안녕하세요! 오늘은 FastAPI와 LangChain을 활용해서 여러분만의 AI 챗봇 API를 빠르게 만드는 방법을 알려드릴게요. 복잡해 보이지만, 단계별로 따라하면 정말 30분 안에 완성할 수 있답니다. 😊

이 튜토리얼에서는 OpenAI의 GPT 모델을 사용하지만, 다른 LLM으로도 쉽게 교체할 수 있어요.

## 필요한 패키지 설치

먼저 필요한 라이브러리들을 설치해볼까요?

bash
pip install fastapi uvicorn langchain langchain-openai python-dotenv


그리고 환경변수 파일(.env)을 만들어서 OpenAI API 키를 저장해주세요.


OPENAI_API_KEY=your-api-key-here


## 기본 FastAPI 앱 구조 만들기

이제 본격적으로 코딩을 시작해볼게요. `main.py` 파일을 생성하고 기본 구조를 잡아봅시다.

python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from langchain_openai import ChatOpenAI
from langchain.chains import ConversationChain
from langchain.memory import ConversationBufferMemory
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI(title="나만의 AI 챗봇 API")

# 요청 모델 정의
class ChatRequest(BaseModel):
    message: str
    session_id: str = "default"

# 응답 모델 정의
class ChatResponse(BaseModel):
    response: str
    session_id: str


## LangChain 챗봇 설정하기

이제 핵심인 LangChain 챗봇을 설정해볼게요. 대화 기록을 저장하는 메모리 기능도 추가할 거예요.

python
# 세션별 메모리 저장소
sessions = {}

def get_conversation_chain(session_id: str):
    if session_id not in sessions:
        # LLM 초기화
        llm = ChatOpenAI(
            temperature=0.7,
            model="gpt-3.5-turbo"
        )
        
        # 대화 메모리 생성
        memory = ConversationBufferMemory()
        
        # 대화 체인 생성
        conversation = ConversationChain(
            llm=llm,
            memory=memory,
            verbose=True
        )
        
        sessions[session_id] = conversation
    
    return sessions[session_id]


여기서 `session_id`를 사용해서 각 사용자별로 대화 기록을 따로 관리할 수 있어요. 정말 편리하죠?

## API 엔드포인트 구현

이제 실제로 챗봇과 대화할 수 있는 API 엔드포인트를 만들어봅시다.

python
@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        # 대화 체인 가져오기
        conversation = get_conversation_chain(request.session_id)
        
        # AI 응답 생성
        response = conversation.predict(input=request.message)
        
        return ChatResponse(
            response=response,
            session_id=request.session_id
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"message": "AI 챗봇 API에 오신 것을 환영합니다!"}

@app.delete("/session/{session_id}")
async def clear_session(session_id: str):
    if session_id in sessions:
        del sessions[session_id]
        return {"message": f"세션 {session_id}가 삭제되었습니다."}
    return {"message": "해당 세션이 존재하지 않습니다."}


세션을 삭제하는 엔드포인트도 추가했어요. 이렇게 하면 대화를 초기화할 수 있답니다.

## 서버 실행하기

자, 이제 서버를 실행해볼 시간이에요!

bash
uvicorn main:app --reload --port 8000


서버가 실행되면 `http://localhost:8000/docs`로 접속해보세요. FastAPI가 자동으로 생성해주는 멋진 API 문서를 볼 수 있어요!

## 테스트해보기

curl 명령어로 간단히 테스트해볼 수 있어요.

bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "안녕하세요!", "session_id": "user123"}'


또는 Python requests 라이브러리로 테스트해볼 수도 있죠.

python
import requests

response = requests.post(
    "http://localhost:8000/chat",
    json={"message": "파이썬에 대해 알려줘", "session_id": "user123"}
)
print(response.json())


## 마무리하며

축하합니다! 🎉 여러분은 방금 30분 만에 나만의 AI 챗봇 API를 만들었어요. 이 기본 구조를 바탕으로 다양한 기능을 추가할 수 있어요.

예를 들어 RAG(Retrieval Augmented Generation)를 추가해서 특정 문서를 기반으로 답변하는 챗봇을 만들거나, 스트리밍 응답을 구현해서 실시간으로 답변이 생성되는 모습을 보여줄 수도 있답니다.

FastAPI와 LangChain의 조합은 정말 강력해요. 여러분의 아이디어를 빠르게 프로토타입으로 만들어보세요!

<!-- more -->

---

*이 글은 AI가 자동으로 작성했습니다.*
