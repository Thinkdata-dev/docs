---
date: 2025-10-26T01:25:41+09:00
title: "FastAPI + LangChain으로 30분 만에 나만의 ChatGPT 만들기"
description: "FastAPI와 LangChain을 활용해 30분 만에 커스텀 ChatGPT를 만드는 실전 가이드입니다. 개발 환경 설정부터 REST API 구축, 대화 체인 구성, 그리고 고급 기능 확장까지 단계별로 설명합니다."
categories:
  - AI & ML
tags:
  - FastAPI
  - LangChain
  - ChatGPT
  - OpenAI
  - Python
---

> FastAPI와 LangChain을 활용해 30분 만에 커스텀 ChatGPT를 만드는 실전 가이드입니다. 개발 환경 설정부터 REST API 구축, 대화 체인 구성, 그리고 고급 기능 확장까지 단계별로 설명합니다.



<!-- more -->

## 왜 지금 나만의 ChatGPT를 만들어야 할까요?

![FastAPI와 LangChain 개발 환경](https://source.unsplash.com/800x600/?coding,artificial-intelligence)

요즘 ChatGPT를 사용하지 않는 개발자를 찾기 어렵죠. 하지만 여러분만의 커스텀 AI 챗봇을 만들면 어떨까요? 특정 도메인 지식을 학습시키거나, 회사 내부 문서를 기반으로 답변하는 AI 어시스턴트를 구축할 수 있습니다. FastAPI의 빠른 성능과 LangChain의 강력한 LLM 통합 기능을 결합하면, 놀랍게도 30분 안에 프로토타입을 만들 수 있습니다.

핵심은 **FastAPI로 API 서버를 구축**하고, **LangChain으로 OpenAI API를 쉽게 연동**하는 것입니다. 이 조합은 확장성과 유지보수성이 뛰어나 실무에서도 많이 활용되고 있습니다.

## 개발 환경 설정과 필수 라이브러리 설치

![Python 개발 환경 설정](https://source.unsplash.com/800x600/?python,programming)

먼저 Python 3.9 이상이 설치되어 있는지 확인하세요. 가상환경을 만들고 필요한 라이브러리를 설치합니다:

bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install fastapi uvicorn langchain openai python-dotenv


**주요 라이브러리 역할:**
- `fastapi`: 고성능 웹 프레임워크로 API 엔드포인트 구성
- `uvicorn`: ASGI 서버로 FastAPI 애플리케이션 실행
- `langchain`: LLM 체인 구성과 프롬프트 관리
- `openai`: OpenAI API 클라이언트

OpenAI API 키는 `.env` 파일에 안전하게 보관하세요:

OPENAI_API_KEY=your-api-key-here


> 💡 **Tip:** API 키는 절대 코드에 직접 작성하지 마세요. 환경 변수나 .env 파일을 사용하는 것이 보안상 필수입니다.

## LangChain으로 대화 체인 구성하기

![AI 대화 체인 구조](https://source.unsplash.com/800x600/?chain,network,technology)

LangChain의 핵심은 **체인(Chain)** 개념입니다. 여러 컴포넌트를 연결해 복잡한 작업을 수행할 수 있죠. 기본적인 대화 체인을 만들어봅시다:

python
from langchain.chat_models import ChatOpenAI
from langchain.prompts import ChatPromptTemplate
from langchain.schema import StrOutputParser
import os
from dotenv import load_dotenv

load_dotenv()

# LLM 초기화
llm = ChatOpenAI(
    model="gpt-3.5-turbo",
    temperature=0.7,
    openai_api_key=os.getenv("OPENAI_API_KEY")
)

# 프롬프트 템플릿 정의
prompt = ChatPromptTemplate.from_messages([
    ("system", "당신은 친절하고 전문적인 AI 어시스턴트입니다."),
    ("user", "{question}")
])

# 체인 구성 (LCEL 문법)
chain = prompt | llm | StrOutputParser()


**temperature 파라미터**는 응답의 창의성을 조절합니다. 0에 가까우면 일관적이고 예측 가능한 답변을, 1에 가까우면 더 창의적이고 다양한 답변을 생성합니다.

LCEL(LangChain Expression Language)의 파이프 연산자(`|`)는 각 컴포넌트를 순차적으로 연결해 깔끔한 체인을 만듭니다.

## FastAPI로 REST API 엔드포인트 만들기

![REST API 개발](https://source.unsplash.com/800x600/?api,server,backend)

이제 FastAPI로 실제 서비스를 만들어봅시다. 비동기 처리를 활용해 여러 요청을 효율적으로 처리합니다:

python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="나만의 ChatGPT API")

# CORS 설정 (프론트엔드 연동용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# 요청 모델 정의
class ChatRequest(BaseModel):
    question: str
    
class ChatResponse(BaseModel):
    answer: str

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        # LangChain 체인 실행
        answer = await chain.ainvoke({"question": request.question})
        return ChatResponse(answer=answer)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "healthy"}


**Pydantic 모델**을 사용하면 자동으로 요청/응답 검증과 문서화가 이루어집니다. `/docs` 경로로 접속하면 자동 생성된 Swagger UI를 확인할 수 있어요.

서버 실행은 간단합니다:
bash
uvicorn main:app --reload --port 8000


> 💡 **Tip:** `--reload` 옵션은 코드 변경 시 자동으로 서버를 재시작해주어 개발 시 매우 유용합니다. 프로덕션 환경에서는 제거하세요.

## 실전 테스트와 고급 기능 확장하기

![소프트웨어 테스팅](https://source.unsplash.com/800x600/?testing,software,quality)

이제 여러분의 ChatGPT를 테스트해봅시다! `curl` 명령어나 Postman을 사용할 수 있습니다:

bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"question": "FastAPI의 장점은 무엇인가요?"}'


**더 발전시키려면 이런 기능들을 추가해보세요:**

1. **대화 히스토리 관리**: LangChain의 `ConversationBufferMemory`로 이전 대화 맥락 유지
2. **스트리밍 응답**: `astream` 메서드로 실시간 응답 구현
3. **RAG(Retrieval Augmented Generation)**: 벡터 데이터베이스를 연결해 특정 문서 기반 답변 생성
4. **Rate Limiting**: 과도한 API 호출 방지를 위한 제한 설정
5. **로깅과 모니터링**: 요청/응답 추적 및 에러 모니터링

특히 RAG 패턴을 적용하면 회사 문서, 제품 매뉴얼 등을 학습시켜 맞춤형 지식 베이스를 구축할 수 있습니다. LangChain의 `VectorStore`와 `RetrievalQA` 체인을 활용하면 생각보다 쉽게 구현 가능합니다.

**성능 최적화 팁:**
- OpenAI API 호출 결과를 Redis에 캐싱해 비용 절감
- 비동기 처리를 극대화해 동시 요청 처리 능력 향상
- 프로덕션 환경에서는 Gunicorn + Uvicorn worker 조합 사용

이제 여러분만의 AI 챗봇 서비스를 세상에 선보일 차례입니다. 30분이면 충분합니다!

---

*이 글은 AI가 자동으로 작성했습니다.*
