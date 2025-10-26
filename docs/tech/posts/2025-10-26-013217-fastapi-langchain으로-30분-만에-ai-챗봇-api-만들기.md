---
date: 2025-10-26T01:32:17+09:00
title: "FastAPI + LangChain으로 30분 만에 AI 챗봇 API 만들기"
description: "FastAPI와 LangChain을 결합하여 30분 만에 대화 기록을 유지하는 AI 챗봇 API를 구축하는 방법을 소개합니다. 환경 설정부터 핵심 코드 구현, 테스트, 실전 확장 방법까지 단계별로 안내합니다."
categories:
  - AI & ML
tags:
  - FastAPI
  - LangChain
  - 챗봇
  - OpenAI
  - Python
---

> FastAPI와 LangChain을 결합하여 30분 만에 대화 기록을 유지하는 AI 챗봇 API를 구축하는 방법을 소개합니다. 환경 설정부터 핵심 코드 구현, 테스트, 실전 확장 방법까지 단계별로 안내합니다.



<!-- more -->

## 왜 FastAPI와 LangChain인가?

![FastAPI와 LangChain 개발 환경](https://source.unsplash.com/800x600/?coding,api,development)

AI 챗봇을 만들 때 가장 중요한 것은 빠른 응답 속도와 유연한 확장성입니다. FastAPI는 Python 기반의 현대적인 웹 프레임워크로, 비동기 처리를 기본 지원하며 자동 API 문서화 기능까지 제공합니다. 여기에 LangChain을 결합하면 LLM(대규모 언어 모델)을 손쉽게 통합할 수 있죠.

LangChain은 프롬프트 관리, 메모리 처리, 다양한 LLM 연동을 추상화해주는 프레임워크입니다. 복잡한 AI 로직을 몇 줄의 코드로 구현할 수 있어 개발 시간을 획기적으로 단축시킵니다. 두 프레임워크의 조합은 프로덕션 레벨의 AI API를 빠르게 구축하는 최적의 선택입니다.

## 환경 설정 및 필수 패키지 설치

![개발 환경 설정](https://source.unsplash.com/800x600/?python,programming,terminal)

먼저 가상환경을 생성하고 필요한 패키지를 설치합니다:

bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install fastapi uvicorn langchain langchain-openai python-dotenv


프로젝트 루트에 `.env` 파일을 만들어 OpenAI API 키를 저장하세요:


OPENAI_API_KEY=your-api-key-here


**💡 팁**: OpenAI 대신 Anthropic의 Claude나 오픈소스 모델을 사용하려면 `langchain-anthropic` 또는 `langchain-community` 패키지를 설치하면 됩니다. LangChain의 강점은 바로 이런 모델 전환의 용이성입니다.

## 핵심 코드 구현하기

![코딩 작업](https://source.unsplash.com/800x600/?code,programming,computer)

`main.py` 파일을 생성하고 아래 코드를 작성합니다:

python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from langchain_openai import ChatOpenAI
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI(title="AI Chatbot API")

# 메모리 저장소 (실제 운영시 Redis 등 사용 권장)
sessions = {}

class ChatRequest(BaseModel):
    session_id: str
    message: str

class ChatResponse(BaseModel):
    response: str
    session_id: str

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    # 세션별 대화 체인 생성 또는 가져오기
    if request.session_id not in sessions:
        llm = ChatOpenAI(temperature=0.7, model="gpt-3.5-turbo")
        memory = ConversationBufferMemory()
        sessions[request.session_id] = ConversationChain(
            llm=llm,
            memory=memory
        )
    
    chain = sessions[request.session_id]
    response = await chain.apredict(input=request.message)
    
    return ChatResponse(
        response=response,
        session_id=request.session_id
    )

@app.get("/health")
async def health_check():
    return {"status": "healthy"}


**핵심 포인트**: `ConversationBufferMemory`는 대화 컨텍스트를 유지합니다. 더 긴 대화를 처리하려면 `ConversationSummaryMemory`를 사용해 토큰 사용량을 최적화할 수 있습니다.

## API 실행 및 테스트

![API 테스트](https://source.unsplash.com/800x600/?testing,api,interface)

서버를 실행합니다:

bash
uvicorn main:app --reload --port 8000


브라우저에서 `http://localhost:8000/docs`로 접속하면 FastAPI가 자동 생성한 Swagger UI를 볼 수 있습니다. 여기서 바로 API를 테스트할 수 있죠.

cURL로 테스트하려면:

bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"session_id": "user123", "message": "안녕하세요!"}'


**실전 팁**: 프로덕션 환경에서는 세션을 메모리가 아닌 Redis에 저장하고, rate limiting을 구현하며, CORS 설정을 추가해야 합니다.

## 실전 활용 및 확장 아이디어

![AI 챗봇 활용](https://source.unsplash.com/800x600/?chatbot,ai,technology)

이제 기본 챗봇 API가 완성되었습니다! 여기서 더 나아가려면:

**1. RAG(검색 증강 생성) 추가**: LangChain의 `VectorStore`와 `RetrievalQA`를 사용해 자체 문서 기반 답변이 가능한 챗봇으로 업그레이드할 수 있습니다.

**2. 스트리밍 응답**: 긴 답변의 경우 `streaming=True` 옵션으로 실시간 토큰 스트리밍을 구현하면 사용자 경험이 크게 향상됩니다.

**3. 프롬프트 템플릿**: LangChain의 `PromptTemplate`으로 챗봇의 페르소나나 답변 스타일을 정의할 수 있습니다. 예를 들어 고객 지원 봇, 기술 상담 봇 등 목적에 맞게 커스터마이징하세요.

**4. 모니터링**: LangSmith나 Weights & Biases를 연동하면 프롬프트 성능, 토큰 사용량, 응답 품질을 추적할 수 있습니다.

30분이면 충분히 동작하는 AI 챗봇 API를 만들 수 있지만, 진짜 가치는 이를 자신의 비즈니스 요구사항에 맞게 확장하는 데 있습니다. FastAPI의 빠른 성능과 LangChain의 유연성이 여러분의 AI 프로젝트를 가속화할 것입니다!

---

*이 글은 AI가 자동으로 작성했습니다.*
