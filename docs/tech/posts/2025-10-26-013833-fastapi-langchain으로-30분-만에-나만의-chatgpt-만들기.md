---
date: 2025-10-26T01:38:33+09:00
title: "FastAPI + LangChain으로 30분 만에 나만의 ChatGPT 만들기"
description: "FastAPI와 LangChain을 활용해 30분 만에 ChatGPT 같은 AI 챗봇을 만드는 방법을 단계별로 소개합니다. 환경 설정부터 대화 메모리 관리까지 실전 코드와 함께 설명합니다."
categories:
  - AI & ML
tags:
  - FastAPI
  - LangChain
  - ChatGPT
  - OpenAI
  - 챗봇개발
---

> FastAPI와 LangChain을 활용해 30분 만에 ChatGPT 같은 AI 챗봇을 만드는 방법을 단계별로 소개합니다. 환경 설정부터 대화 메모리 관리까지 실전 코드와 함께 설명합니다.



<!-- more -->

## 왜 FastAPI와 LangChain인가?

![FastAPI와 LangChain](https://source.unsplash.com/800x600/?api,programming,technology)

요즘 ChatGPT 같은 AI 챗봇을 직접 만들어보고 싶으신가요? FastAPI와 LangChain을 조합하면 놀랍도록 빠르게 구현할 수 있습니다. FastAPI는 Python 기반의 고성능 웹 프레임워크로, 비동기 처리와 자동 문서화 기능이 탁월합니다. LangChain은 대규모 언어 모델(LLM)을 쉽게 다룰 수 있게 해주는 프레임워크죠. 이 두 기술을 결합하면 복잡한 AI 챗봇도 30분이면 충분히 프로토타입을 완성할 수 있습니다.

**핵심 포인트**: FastAPI의 빠른 속도와 LangChain의 유연성이 만나면 개발 시간을 획기적으로 단축할 수 있습니다.

## 개발 환경 세팅하기

![개발환경 설정](https://source.unsplash.com/800x600/?coding,setup,computer)

먼저 필요한 패키지들을 설치해봅시다. Python 3.8 이상 환경에서 다음 명령어를 실행하세요:

bash
pip install fastapi uvicorn langchain openai python-dotenv


그리고 `.env` 파일을 생성해 OpenAI API 키를 저장합니다:


OPENAI_API_KEY=your_api_key_here


> 💡 **TIP**: OpenAI API 키는 platform.openai.com에서 발급받을 수 있습니다. 무료 크레딧도 제공되니 부담 없이 시작해보세요!

프로젝트 구조는 심플하게 가져갑니다. `main.py` 하나로 시작해도 충분합니다. 나중에 서비스가 커지면 모듈화하면 됩니다.

## 핵심 코드 구현하기

![코드 작성](https://source.unsplash.com/800x600/?code,python,developer)

이제 실제 챗봇을 만들어봅시다. 먼저 FastAPI 앱과 LangChain을 초기화합니다:

python
from fastapi import FastAPI
from langchain.chat_models import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage
from pydantic import BaseModel
import os
from dotenv import load_dotenv

load_dotenv()
app = FastAPI(title="My ChatGPT")

# LangChain 모델 초기화
chat = ChatOpenAI(
    temperature=0.7,
    model="gpt-3.5-turbo"
)

class ChatRequest(BaseModel):
    message: str
    system_prompt: str = "당신은 친절한 AI 어시스턴트입니다."

@app.post("/chat")
async def chat_endpoint(request: ChatRequest):
    messages = [
        SystemMessage(content=request.system_prompt),
        HumanMessage(content=request.message)
    ]
    response = chat(messages)
    return {"response": response.content}


**핵심 포인트**: `temperature` 값을 조절해 응답의 창의성을 제어할 수 있습니다. 0에 가까울수록 일관적이고, 1에 가까울수록 창의적입니다.

## 대화 기록 관리와 메모리 추가

![메모리 관리](https://source.unsplash.com/800x600/?memory,database,storage)

실제 ChatGPT처럼 이전 대화를 기억하게 만들어봅시다. LangChain의 `ConversationBufferMemory`를 활용합니다:

python
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain

# 세션별 메모리 저장소
sessions = {}

class ChatWithHistory(BaseModel):
    session_id: str
    message: str

@app.post("/chat/history")
async def chat_with_history(request: ChatWithHistory):
    if request.session_id not in sessions:
        sessions[request.session_id] = ConversationChain(
            llm=chat,
            memory=ConversationBufferMemory()
        )
    
    conversation = sessions[request.session_id]
    response = conversation.predict(input=request.message)
    return {"response": response}


이렇게 하면 세션별로 대화 맥락을 유지할 수 있습니다. 실제 서비스에서는 Redis나 데이터베이스에 세션 정보를 저장하는 것이 좋습니다.

> 💡 **고급 TIP**: `ConversationSummaryMemory`를 사용하면 긴 대화를 요약해서 저장하므로 토큰 비용을 절약할 수 있습니다.

## 실행하고 테스트하기

![테스트 및 실행](https://source.unsplash.com/800x600/?testing,success,laptop)

이제 서버를 실행해봅시다:

bash
uvicorn main:app --reload


브라우저에서 `http://localhost:8000/docs`로 접속하면 FastAPI가 자동 생성한 Swagger 문서를 볼 수 있습니다. 여기서 바로 API를 테스트할 수 있죠!

cURL로 테스트하려면:

bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"message":"안녕하세요! 파이썬에 대해 알려주세요."}'


**다음 단계 제안**:
- 스트리밍 응답 구현 (Server-Sent Events 활용)
- 프론트엔드 연결 (React, Vue 등)
- 벡터 데이터베이스 연동으로 RAG(Retrieval-Augmented Generation) 구현
- 사용자 인증 및 요청 제한 추가

30분이면 기본 챗봇을 완성할 수 있지만, 이제부터가 진짜 시작입니다. 여러분만의 독특한 기능을 추가하며 실력을 키워보세요!

---

*이 글은 AI가 자동으로 작성했습니다.*
