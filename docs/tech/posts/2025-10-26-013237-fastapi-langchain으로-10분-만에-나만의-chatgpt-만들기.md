---
date: 2025-10-26T01:32:37+09:00
title: "FastAPI + Langchain으로 10분 만에 나만의 ChatGPT 만들기"
description: "FastAPI와 Langchain을 활용해 10분 만에 나만의 ChatGPT API를 구축하는 실전 가이드입니다. 환경 설정부터 스트리밍, 메모리 기능까지 단계별로 설명합니다."
categories:
  - AI & ML
tags:
  - FastAPI
  - Langchain
  - ChatGPT
  - OpenAI
  - Python
---

> FastAPI와 Langchain을 활용해 10분 만에 나만의 ChatGPT API를 구축하는 실전 가이드입니다. 환경 설정부터 스트리밍, 메모리 기능까지 단계별로 설명합니다.



<!-- more -->

## 왜 FastAPI와 Langchain인가?

![FastAPI와 Langchain](https://source.unsplash.com/800x600/?programming,api,technology)

ChatGPT가 세상을 바꾸고 있는 지금, 직접 나만의 AI 챗봇을 만들고 싶으신가요? FastAPI와 Langchain을 활용하면 정말 10분 만에 가능합니다.

FastAPI는 Python 기반의 고성능 웹 프레임워크로, 자동 문서화와 비동기 처리가 강점입니다. Langchain은 LLM(Large Language Model)을 쉽게 다룰 수 있게 해주는 프레임워크죠. 이 두 가지를 결합하면 강력한 AI API 서버를 빠르게 구축할 수 있습니다.

**핵심 포인트**: FastAPI의 속도와 Langchain의 유연성이 만나면 엔터프라이즈급 AI 서비스도 손쉽게 만들 수 있습니다.

## 환경 설정과 필수 라이브러리 설치

![코딩 환경 설정](https://source.unsplash.com/800x600/?coding,setup,development)

먼저 필요한 패키지들을 설치해봅시다. 터미널을 열고 아래 명령어를 실행하세요:

bash
pip install fastapi uvicorn langchain openai python-dotenv


각 라이브러리의 역할을 간단히 설명하면:
- **fastapi**: API 서버 프레임워크
- **uvicorn**: ASGI 서버 (FastAPI 실행용)
- **langchain**: LLM 통합 프레임워크
- **openai**: OpenAI API 클라이언트
- **python-dotenv**: 환경 변수 관리

다음으로 프로젝트 폴더에 `.env` 파일을 만들고 OpenAI API 키를 저장하세요:


OPENAI_API_KEY=your-api-key-here


> 💡 **팁**: OpenAI API 키는 platform.openai.com에서 발급받을 수 있습니다. 무료 크레딧도 제공되니 부담 없이 시작해보세요!

## 핵심 코드 작성하기

![코드 작성](https://source.unsplash.com/800x600/?code,python,computer)

이제 `main.py` 파일을 만들고 핵심 코드를 작성해봅시다:

python
from fastapi import FastAPI
from pydantic import BaseModel
from langchain.chat_models import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI(title="My ChatGPT API")

# Langchain ChatOpenAI 모델 초기화
chat = ChatOpenAI(
    temperature=0.7,
    model_name="gpt-3.5-turbo",
    openai_api_key=os.getenv("OPENAI_API_KEY")
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
    
    return {
        "response": response.content,
        "model": "gpt-3.5-turbo"
    }

@app.get("/")
async def root():
    return {"message": "Welcome to My ChatGPT API!"}


**코드 설명**:
- `ChatOpenAI`: Langchain이 제공하는 OpenAI 래퍼 클래스입니다. temperature는 응답의 창의성을 조절합니다 (0~1 사이 값).
- `SystemMessage`: AI의 역할과 성격을 정의합니다.
- `HumanMessage`: 사용자의 질문을 담습니다.
- `Pydantic BaseModel`: FastAPI의 자동 검증 기능을 활용합니다.

## 서버 실행과 테스트

![서버 테스트](https://source.unsplash.com/800x600/?server,testing,monitor)

이제 서버를 실행해봅시다:

bash
uvicorn main:app --reload


서버가 시작되면 브라우저에서 `http://localhost:8000/docs`로 접속해보세요. FastAPI의 자동 문서화 기능 덕분에 Swagger UI가 자동으로 생성됩니다!

실제로 API를 호출해보려면 curl이나 Postman을 사용할 수 있습니다:

bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "FastAPI와 Langchain에 대해 설명해줘"}'


**성능 최적화 팁**:
- 프로덕션 환경에서는 `--workers` 옵션으로 멀티 프로세스를 활용하세요.
- 대화 히스토리를 저장하려면 Redis나 데이터베이스를 연동하면 좋습니다.
- 요청 제한(Rate Limiting)을 추가해 비용을 관리하세요.

## 한 단계 더: 스트리밍과 메모리 추가하기

![고급 기능](https://source.unsplash.com/800x600/?advanced,innovation,tech)

기본 챗봇이 완성되었다면, 이제 실시간 스트리밍과 대화 기억 기능을 추가해봅시다.

**스트리밍 응답 구현**:

python
from fastapi.responses import StreamingResponse
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler

@app.post("/chat/stream")
async def chat_stream(request: ChatRequest):
    async def generate():
        chat_stream = ChatOpenAI(
            streaming=True,
            callbacks=[StreamingStdOutCallbackHandler()],
            temperature=0.7
        )
        messages = [
            SystemMessage(content=request.system_prompt),
            HumanMessage(content=request.message)
        ]
        async for chunk in chat_stream.astream(messages):
            yield chunk.content
    
    return StreamingResponse(generate(), media_type="text/plain")


**대화 기억 기능**:

python
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain

memory = ConversationBufferMemory()
conversation = ConversationChain(
    llm=chat,
    memory=memory,
    verbose=True
)


이렇게 하면 이전 대화 내용을 기억하는 ChatGPT와 유사한 경험을 제공할 수 있습니다.

> 💡 **실전 팁**: 프로덕션에서는 메모리를 세션별로 관리하고, 일정 시간 후 자동으로 삭제되도록 설정하세요. 메모리 누수를 방지할 수 있습니다.

**마무리하며**: 이제 여러분만의 ChatGPT API가 완성되었습니다! 여기서 더 나아가 RAG(Retrieval-Augmented Generation)를 추가하면 특정 문서나 데이터베이스를 기반으로 답변하는 전문 AI를 만들 수도 있습니다. FastAPI의 확장성과 Langchain의 다양한 통합 기능을 활용해 계속 발전시켜보세요!

---

*이 글은 AI가 자동으로 작성했습니다.*
