---
date: 2025-10-11T04:31:08+09:00
title: "10분이면 충분해! FastAPI + LangChain으로 나만의 ChatGPT 만들기"
description: "FastAPI와 LangChain을 활용해 10분 만에 나만의 ChatGPT를 구축하는 방법을 소개합니다. 환경 설정부터 핵심 코드 구현, 실전 활용 팁까지 바로 따라할 수 있는 실용적인 가이드입니다."
categories:
  - AI & ML
tags:
  - FastAPI
  - LangChain
  - ChatGPT
  - OpenAI
  - Python
---

> FastAPI와 LangChain을 활용해 10분 만에 나만의 ChatGPT를 구축하는 방법을 소개합니다. 환경 설정부터 핵심 코드 구현, 실전 활용 팁까지 바로 따라할 수 있는 실용적인 가이드입니다.


## 왜 직접 ChatGPT를 만들어야 할까요?

시중의 ChatGPT를 사용하는 것도 좋지만, 비즈니스 로직에 맞춘 커스텀 기능이나 자체 데이터베이스 연동, 그리고 사용자 인증 시스템까지 구현하려면 결국 직접 만들어야 합니다. FastAPI와 LangChain을 조합하면 놀랍게도 10분 안에 기본적인 ChatGPT 클론을 완성할 수 있어요. FastAPI는 Python 기반의 초고속 웹 프레임워크이고, LangChain은 LLM(대규모 언어 모델)을 쉽게 다룰 수 있게 해주는 라이브러리입니다. 두 기술의 궁합이 정말 환상적이죠!

## 개발 환경 준비하기

먼저 필요한 패키지들을 설치해볼게요. 터미널에서 다음 명령어를 실행하세요.

bash
pip install fastapi uvicorn langchain openai python-dotenv


그리고 프로젝트 루트에 `.env` 파일을 만들어 OpenAI API 키를 저장합니다.


OPENAI_API_KEY=your-api-key-here


> 💡 **팁**: OpenAI API 키는 platform.openai.com에서 발급받을 수 있습니다. 무료 크레딧도 제공되니 부담 없이 시작해보세요!

## 핵심 코드 구현하기

이제 `main.py` 파일을 만들어 실제 코드를 작성해볼게요. 생각보다 코드가 간결해서 놀라실 거예요.

python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from langchain.chat_models import ChatOpenAI
from langchain.schema import HumanMessage, AIMessage, SystemMessage
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI(title="나만의 ChatGPT")

# LangChain 모델 초기화
chat_model = ChatOpenAI(
    model_name="gpt-3.5-turbo",
    temperature=0.7,
    openai_api_key=os.getenv("OPENAI_API_KEY")
)

class ChatRequest(BaseModel):
    message: str
    conversation_history: list = []

class ChatResponse(BaseModel):
    response: str

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        # 대화 히스토리를 LangChain 메시지 형식으로 변환
        messages = [
            SystemMessage(content="당신은 친절하고 유용한 AI 어시스턴트입니다.")
        ]
        
        for msg in request.conversation_history:
            if msg["role"] == "user":
                messages.append(HumanMessage(content=msg["content"]))
            else:
                messages.append(AIMessage(content=msg["content"]))
        
        messages.append(HumanMessage(content=request.message))
        
        # LLM 호출
        response = chat_model(messages)
        
        return ChatResponse(response=response.content)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"message": "나만의 ChatGPT API에 오신 것을 환영합니다!"}


**핵심 포인트**를 짚어볼게요:
- `temperature` 파라미터는 응답의 창의성을 조절합니다(0.0~1.0). 0.7은 적당히 창의적인 값이에요.
- `conversation_history`를 통해 대화 맥락을 유지할 수 있습니다. 이게 있어야 진짜 ChatGPT처럼 작동하죠!
- `SystemMessage`로 AI의 페르소나를 정의할 수 있어요. 이 부분을 수정하면 전문가 챗봇, 친구 같은 챗봇 등 다양하게 커스터마이징 가능합니다.

## 실행하고 테스트하기

서버를 실행해볼까요?

bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000


브라우저에서 `http://localhost:8000/docs`로 접속하면 FastAPI가 자동으로 생성한 멋진 API 문서를 볼 수 있습니다. 여기서 바로 테스트도 가능해요!

cURL로 테스트해보는 방법:

bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "안녕하세요! 파이썬에 대해 알려주세요."}'


> 💡 **실전 팁**: 프로덕션 환경에서는 대화 히스토리를 Redis나 데이터베이스에 저장해서 관리하는 것이 좋습니다. 메모리만 사용하면 서버 재시작 시 모든 대화가 사라지거든요.

## 더 나아가기: 실전 활용 아이디어

기본 구조를 완성했으니 이제 다양하게 확장할 수 있습니다:

**1. 스트리밍 응답 구현**: `ChatOpenAI`의 `streaming=True` 옵션과 FastAPI의 `StreamingResponse`를 조합하면 실시간으로 답변이 생성되는 것을 볼 수 있어요.

**2. RAG(Retrieval Augmented Generation) 추가**: LangChain의 Vector Store를 활용해 자체 문서 기반으로 답변하는 전문 챗봇을 만들 수 있습니다.

**3. 사용자 인증**: FastAPI의 OAuth2 인증을 추가하면 사용자별로 대화 히스토리를 관리할 수 있죠.

**4. 비용 최적화**: 대화 히스토리가 길어지면 토큰 비용이 급증합니다. 최근 N개의 메시지만 유지하거나 요약 기능을 추가하는 것이 좋아요.

이렇게 10분이면 기본적인 ChatGPT 클론이 완성됩니다. 물론 실제 프로덕션 레벨로 만들려면 에러 핸들링, 로깅, 모니터링 등 더 많은 작업이 필요하지만, 핵심 기능은 이게 전부예요. 이제 여러분만의 AI 챗봇을 만들어보세요!

<!-- more -->

---

*이 글은 AI가 자동으로 작성했습니다.*
