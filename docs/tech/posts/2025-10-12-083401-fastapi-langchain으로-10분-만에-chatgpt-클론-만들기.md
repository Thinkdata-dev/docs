---
date: 2025-10-12T08:34:01+09:00
title: "FastAPI + LangChain으로 10분 만에 ChatGPT 클론 만들기"
description: "FastAPI와 LangChain을 활용해 실전 수준의 ChatGPT 클론을 만드는 방법을 알아봅니다. 환경 구성부터 대화 히스토리 관리, 스트리밍 응답 구현까지 프로덕션 레벨의 챗봇 API 개발 과정을 단계별로 설명합니다."
categories:
  - AI & ML
tags:
  - FastAPI
  - LangChain
  - ChatGPT
  - OpenAI
  - 챗봇
---

> FastAPI와 LangChain을 활용해 실전 수준의 ChatGPT 클론을 만드는 방법을 알아봅니다. 환경 구성부터 대화 히스토리 관리, 스트리밍 응답 구현까지 프로덕션 레벨의 챗봇 API 개발 과정을 단계별로 설명합니다.



<!-- more -->

## 왜 직접 ChatGPT 클론을 만들어야 할까요?

최근 ChatGPT API를 활용한 맞춤형 챗봇 서비스가 많이 등장하고 있죠. 하지만 외부 서비스에 의존하기보다 직접 구축하면 데이터 보안, 커스터마이징, 비용 절감 등 여러 이점을 얻을 수 있습니다. FastAPI는 빠르고 현대적인 웹 프레임워크이고, LangChain은 LLM 애플리케이션 개발을 쉽게 만들어주는 도구입니다. 이 두 가지를 조합하면 생각보다 간단하게 나만의 ChatGPT를 만들 수 있어요.

이 글에서는 실제 프로덕션에서 사용할 수 있는 수준의 챗봇 API를 구축하는 방법을 단계별로 알아보겠습니다.

## 프로젝트 환경 구성하기

먼저 필요한 패키지들을 설치해야 합니다. 가상환경을 만든 후 다음 명령어로 필수 라이브러리를 설치하세요.

bash
pip install fastapi uvicorn langchain langchain-openai python-dotenv


프로젝트 구조는 다음과 같이 구성하는 것을 추천합니다:


project/
├── main.py
├── .env
└── requirements.txt


`.env` 파일에는 OpenAI API 키를 저장합니다. 보안을 위해 절대 코드에 직접 하드코딩하지 마세요!


OPENAI_API_KEY=your-api-key-here


**💡 팁**: 개발 단계에서는 GPT-3.5-turbo 모델을 사용하면 비용을 크게 절약할 수 있습니다. GPT-4는 필요한 경우에만 사용하세요.

## 핵심 코드 구현: FastAPI + LangChain 통합

이제 본격적으로 챗봇 API를 만들어볼까요? `main.py` 파일에 다음 코드를 작성합니다.

python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI(title="My ChatGPT Clone")

# LangChain ChatOpenAI 초기화
llm = ChatOpenAI(
    model="gpt-3.5-turbo",
    temperature=0.7,
    openai_api_key=os.getenv("OPENAI_API_KEY")
)

class ChatRequest(BaseModel):
    message: str
    system_prompt: str = "You are a helpful AI assistant."

class ChatResponse(BaseModel):
    response: str

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        messages = [
            SystemMessage(content=request.system_prompt),
            HumanMessage(content=request.message)
        ]
        
        response = llm.invoke(messages)
        
        return ChatResponse(response=response.content)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"message": "ChatGPT Clone API is running!"}


여기서 중요한 포인트는 `temperature` 설정입니다. 0에 가까울수록 일관된 답변을, 1에 가까울수록 창의적인 답변을 생성합니다. 용도에 따라 조절하세요.

서버를 실행하려면 터미널에서 다음 명령어를 입력합니다:

bash
uvicorn main:app --reload --port 8000


## 대화 히스토리 관리로 컨텍스트 유지하기

실제 ChatGPT처럼 이전 대화를 기억하게 만들려면 대화 히스토리를 관리해야 합니다. LangChain의 `ConversationBufferMemory`를 활용하면 쉽게 구현할 수 있어요.

python
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain

# 세션별 메모리 저장소 (실제 프로덕션에서는 Redis 등 사용)
sessions = {}

class ChatSessionRequest(BaseModel):
    session_id: str
    message: str

@app.post("/chat/session")
async def chat_with_history(request: ChatSessionRequest):
    # 새 세션이면 메모리 생성
    if request.session_id not in sessions:
        memory = ConversationBufferMemory()
        sessions[request.session_id] = ConversationChain(
            llm=llm,
            memory=memory
        )
    
    conversation = sessions[request.session_id]
    response = conversation.predict(input=request.message)
    
    return {"response": response}


**⚠️ 주의**: 메모리를 딕셔너리로 관리하는 것은 개발 단계에서만 적합합니다. 실제 서비스에서는 Redis나 데이터베이스를 사용해 세션을 관리해야 합니다.

## 프로덕션을 위한 최적화 팁

실제 서비스로 배포하기 전에 고려해야 할 사항들입니다:

**1. 스트리밍 응답 구현**

ChatGPT처럼 답변이 실시간으로 생성되는 것처럼 보이게 하려면 스트리밍을 구현하세요:

python
from fastapi.responses import StreamingResponse

@app.post("/chat/stream")
async def stream_chat(request: ChatRequest):
    async def generate():
        for chunk in llm.stream([HumanMessage(content=request.message)]):
            yield chunk.content
    
    return StreamingResponse(generate(), media_type="text/plain")


**2. Rate Limiting 설정**

과도한 API 호출을 방지하기 위해 `slowapi` 라이브러리를 사용해 요청 제한을 설정하세요.

**3. 에러 핸들링 강화**

OpenAI API는 간혹 타임아웃이나 레이트 리밋 에러가 발생합니다. 재시도 로직과 명확한 에러 메시지를 추가하세요.

**4. 로깅 및 모니터링**

사용자 질문과 응답을 로깅하면 서비스 개선에 큰 도움이 됩니다. 다만 개인정보 보호를 반드시 고려하세요.

이제 여러분만의 ChatGPT 클론이 완성되었습니다! `http://localhost:8000/docs`에 접속하면 Swagger UI를 통해 API를 테스트할 수 있습니다. 이 기본 구조를 바탕으로 RAG(Retrieval-Augmented Generation)를 추가하거나, 음성 인식 기능을 통합하는 등 무궁무진한 확장이 가능합니다.

---

*이 글은 AI가 자동으로 작성했습니다.*
