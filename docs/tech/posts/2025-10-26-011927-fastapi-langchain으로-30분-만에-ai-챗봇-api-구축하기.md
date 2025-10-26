---
date: 2025-10-26T01:19:27+09:00
title: "FastAPI + LangChain으로 30분 만에 AI 챗봇 API 구축하기"
description: "FastAPI와 LangChain을 활용해 고성능 AI 챗봇 API를 구축하는 실전 가이드입니다. 비동기 처리, 대화 기록 유지, 세션 관리까지 단계별로 구현하며, 즉시 적용 가능한 코드와 팁을 제공합니다."
categories:
  - AI & ML
tags:
  - FastAPI
  - LangChain
  - 챗봇
  - OpenAI
  - Python
---

> FastAPI와 LangChain을 활용해 고성능 AI 챗봇 API를 구축하는 실전 가이드입니다. 비동기 처리, 대화 기록 유지, 세션 관리까지 단계별로 구현하며, 즉시 적용 가능한 코드와 팁을 제공합니다.



<!-- more -->

## 왜 FastAPI와 LangChain을 함께 사용할까요?

![FastAPI와 LangChain 조합](https://source.unsplash.com/800x600/?api,artificial-intelligence,coding)

AI 챗봇을 만들 때 가장 중요한 두 가지는 '빠른 응답 속도'와 '강력한 LLM 연동'입니다. FastAPI는 Python 기반 웹 프레임워크 중 가장 빠른 성능을 자랑하며, LangChain은 OpenAI, Claude 같은 LLM을 쉽게 연동할 수 있게 해주죠.

이 조합의 핵심 장점은 세 가지입니다. 첫째, FastAPI의 비동기 처리로 동시에 여러 사용자 요청을 처리할 수 있습니다. 둘째, LangChain의 체인 기능으로 복잡한 대화 흐름을 간단하게 구현할 수 있습니다. 셋째, 자동 생성되는 API 문서(Swagger UI)로 팀원들과 협업이 쉬워집니다.

**핵심 포인트**: FastAPI는 속도, LangChain은 LLM 통합을 담당하는 완벽한 조합입니다.

## 개발 환경 세팅과 필수 라이브러리 설치

![개발 환경 설정](https://source.unsplash.com/800x600/?programming,setup,developer)

먼저 필요한 패키지들을 설치해봅시다. 가상환경을 만드는 것을 권장드립니다:

bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install fastapi uvicorn langchain langchain-openai python-dotenv


각 라이브러리의 역할을 간단히 설명하면, `uvicorn`은 FastAPI 서버를 실행하는 ASGI 서버이고, `langchain-openai`는 OpenAI API 연동을 위한 패키지입니다. `python-dotenv`는 API 키를 안전하게 관리하기 위해 사용합니다.

프로젝트 루트에 `.env` 파일을 만들어 API 키를 저장하세요:


OPENAI_API_KEY=your-api-key-here


> 💡 **팁**: `.env` 파일은 반드시 `.gitignore`에 추가해서 GitHub에 업로드되지 않도록 주의하세요!

## 기본 챗봇 API 구조 만들기

![코드 구조 설계](https://source.unsplash.com/800x600/?code,structure,architecture)

이제 본격적으로 코드를 작성해봅시다. `main.py` 파일을 생성하고 다음과 같이 작성합니다:

python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="AI Chatbot API")
llm = ChatOpenAI(temperature=0.7, model="gpt-3.5-turbo")

class ChatRequest(BaseModel):
    message: str
    system_prompt: str = "당신은 친절한 AI 어시스턴트입니다."

class ChatResponse(BaseModel):
    response: str

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        messages = [
            SystemMessage(content=request.system_prompt),
            HumanMessage(content=request.message)
        ]
        response = await llm.agenerate([messages])
        return ChatResponse(response=response.generations[0][0].text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


여기서 주목할 점은 `async/await`를 사용한 비동기 처리입니다. LangChain의 `agenerate` 메서드를 사용하면 여러 요청을 동시에 처리할 수 있어 성능이 크게 향상됩니다.

**핵심 포인트**: Pydantic 모델로 요청/응답 스키마를 정의하면 자동으로 유효성 검사와 API 문서가 생성됩니다.

## 대화 기록 유지하는 스마트 챗봇 구현

![대화 기록 관리](https://source.unsplash.com/800x600/?memory,conversation,chat)

실제 챗봇은 이전 대화를 기억해야 합니다. LangChain의 `ConversationBufferMemory`를 활용해봅시다:

python
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain
from typing import Dict
import uuid

# 세션별 메모리 저장소
sessions: Dict[str, ConversationChain] = {}

class ChatWithMemoryRequest(BaseModel):
    session_id: str
    message: str

@app.post("/chat/memory")
async def chat_with_memory(request: ChatWithMemoryRequest):
    if request.session_id not in sessions:
        memory = ConversationBufferMemory()
        sessions[request.session_id] = ConversationChain(
            llm=llm,
            memory=memory,
            verbose=True
        )
    
    chain = sessions[request.session_id]
    response = await chain.apredict(input=request.message)
    return {"response": response, "session_id": request.session_id}

@app.post("/chat/new-session")
def create_session():
    session_id = str(uuid.uuid4())
    return {"session_id": session_id}


이 구현의 핵심은 세션 ID를 통해 각 사용자의 대화 기록을 분리해서 관리한다는 점입니다. 실제 프로덕션 환경에서는 Redis나 데이터베이스를 사용해 메모리를 영구 저장하는 것이 좋습니다.

> ⚠️ **주의**: 인메모리 저장은 서버 재시작 시 데이터가 사라집니다. 영구 저장이 필요하면 `RedisChatMessageHistory`를 사용하세요.

## 서버 실행과 테스트하기

![API 테스트](https://source.unsplash.com/800x600/?testing,server,deployment)

이제 서버를 실행하고 테스트해봅시다:

bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000


브라우저에서 `http://localhost:8000/docs`로 접속하면 자동 생성된 Swagger UI 문서를 확인할 수 있습니다. 여기서 바로 API를 테스트할 수 있죠!

cURL로 테스트하는 방법:

bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "FastAPI에 대해 설명해줘"}'


Python으로 클라이언트를 만들 수도 있습니다:

python
import requests

response = requests.post(
    "http://localhost:8000/chat",
    json={"message": "안녕하세요!"}
)
print(response.json())


**실전 팁**: 프로덕션 배포 시에는 `--reload` 옵션을 제거하고, Gunicorn과 함께 사용하면 더 안정적인 서비스를 운영할 수 있습니다. 또한 Rate Limiting과 인증 미들웨어를 추가해 API 보안을 강화하세요.

이제 여러분만의 AI 챗봇 API가 완성되었습니다. LangChain의 다양한 도구들(RAG, 에이전트, 도구 연동 등)을 추가하면 더욱 강력한 챗봇으로 확장할 수 있습니다!

---

*이 글은 AI가 자동으로 작성했습니다.*
