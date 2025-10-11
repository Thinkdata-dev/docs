---
date: 2025-10-11T14:48:21+09:00
title: "FastAPI + LangChain으로 30분 만에 나만의 RAG 챗봇 만들기"
description: "FastAPI와 LangChain을 활용해 30분 만에 RAG 챗봇을 구축하는 실전 가이드입니다. 문서 임베딩부터 API 구축, 성능 최적화까지 단계별로 실용적인 코드와 팁을 제공합니다."
categories:
  - AI & ML
tags:
  - FastAPI
  - LangChain
  - RAG
  - 챗봇
  - 벡터DB
---

> FastAPI와 LangChain을 활용해 30분 만에 RAG 챗봇을 구축하는 실전 가이드입니다. 문서 임베딩부터 API 구축, 성능 최적화까지 단계별로 실용적인 코드와 팁을 제공합니다.



<!-- more -->

## RAG 챗봇이 뭐길래 30분이면 만들 수 있다고?

RAG(Retrieval-Augmented Generation)는 최근 AI 챗봇의 게임 체인저로 떠오르고 있습니다. 간단히 말하면, 외부 문서를 검색해서 그 정보를 기반으로 답변을 생성하는 방식이에요. ChatGPT가 학습하지 않은 여러분 회사의 내부 문서나 최신 정보도 척척 답변할 수 있게 되는 거죠.

FastAPI는 Python 기반의 빠르고 현대적인 웹 프레임워크이고, LangChain은 LLM 애플리케이션 개발을 쉽게 만들어주는 프레임워크입니다. 이 둘을 조합하면 생각보다 훨씬 간단하게 프로덕션 레벨의 챗봇을 만들 수 있어요.

**핵심 포인트**: RAG는 '검색 + 생성'의 조합이며, 사전 학습되지 않은 데이터로도 정확한 답변이 가능합니다.

## 필요한 라이브러리 설치와 기본 설정

먼저 필요한 패키지들을 설치해볼까요? 터미널에서 다음 명령어를 실행하세요.

bash
pip install fastapi uvicorn langchain langchain-openai chromadb pypdf sentence-transformers


각 라이브러리의 역할을 간단히 설명하면:
- **fastapi**: API 서버 구축
- **uvicorn**: ASGI 서버 (FastAPI 실행용)
- **langchain**: LLM 오케스트레이션
- **chromadb**: 벡터 데이터베이스 (문서 검색용)
- **pypdf**: PDF 문서 파싱
- **sentence-transformers**: 텍스트 임베딩 생성

환경변수로 OpenAI API 키를 설정해주세요:

bash
export OPENAI_API_KEY='your-api-key-here'


💡 **팁**: `.env` 파일을 만들어서 `python-dotenv`로 관리하면 더 안전하고 편리합니다!

## 문서 임베딩과 벡터 스토어 구축하기

RAG의 핵심은 문서를 벡터로 변환해서 저장하는 것입니다. 이렇게 하면 사용자 질문과 유사한 문서를 빠르게 찾을 수 있어요.

python
from langchain.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.vectorstores import Chroma

# 문서 로드
loader = PyPDFLoader("your_document.pdf")
documents = loader.load()

# 문서를 적절한 크기로 분할
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200
)
splits = text_splitter.split_documents(documents)

# 임베딩 모델 설정 (한국어는 multilingual 모델 추천)
embeddings = HuggingFaceEmbeddings(
    model_name="jhgan/ko-sroberta-multitask"
)

# 벡터 스토어 생성
vectorstore = Chroma.from_documents(
    documents=splits,
    embedding=embeddings,
    persist_directory="./chroma_db"
)


**중요한 설정 포인트**:
- `chunk_size`: 너무 크면 검색 정확도가 떨어지고, 너무 작으면 맥락이 손실됩니다. 1000자 정도가 적당해요.
- `chunk_overlap`: 청크 간 중복을 두어 문맥 단절을 방지합니다.
- 한국어 문서라면 한국어 임베딩 모델을 사용하는 것이 정확도가 훨씬 높습니다.

## FastAPI로 챗봇 API 구축하기

이제 실제 API를 만들어볼 차례입니다. FastAPI의 비동기 처리를 활용하면 여러 요청을 효율적으로 처리할 수 있어요.

python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from langchain.chains import RetrievalQA
from langchain.chat_models import ChatOpenAI

app = FastAPI(title="RAG Chatbot API")

# 요청 모델 정의
class ChatRequest(BaseModel):
    question: str
    top_k: int = 3

# LLM 및 retriever 설정
llm = ChatOpenAI(model_name="gpt-3.5-turbo", temperature=0)
retriever = vectorstore.as_retriever(search_kwargs={"k": 3})

# RAG 체인 구성
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=retriever,
    return_source_documents=True
)

@app.post("/chat")
async def chat(request: ChatRequest):
    try:
        result = qa_chain({"query": request.question})
        
        return {
            "answer": result["result"],
            "sources": [
                {"content": doc.page_content, "page": doc.metadata.get("page")}
                for doc in result["source_documents"]
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "healthy"}


서버 실행은 간단합니다:

bash
uvicorn main:app --reload --port 8000


💡 **프로덕션 팁**: `chain_type="stuff"`는 간단하지만, 문서가 많을 때는 `map_reduce`나 `refine` 방식을 고려해보세요. 각각 장단점이 있습니다.

## 실전 테스트와 성능 개선 포인트

이제 만든 API를 테스트해볼까요?

bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"question": "문서의 핵심 내용이 뭔가요?"}'


**성능 개선을 위한 체크리스트**:

1. **캐싱 활용**: 동일한 질문에 대해 매번 검색하지 말고 Redis 등으로 캐싱하세요.
2. **임베딩 모델 최적화**: 용량과 속도의 트레이드오프를 고려해서 선택하세요. 서비스 초기엔 가벼운 모델로 시작하는 게 좋습니다.
3. **비동기 처리**: LangChain의 async 메서드(`arun`, `ainvoke`)를 활용하면 처리 속도가 크게 향상됩니다.
4. **프롬프트 엔지니어링**: `RetrievalQA`의 프롬프트를 커스터마이징해서 답변 품질을 높일 수 있어요.

python
from langchain.prompts import PromptTemplate

prompt_template = """다음 문서를 참고해서 질문에 답변해주세요.
답변은 친절하고 구체적으로 작성해주세요.

{context}

질문: {question}
답변:"""

PROMPT = PromptTemplate(
    template=prompt_template, 
    input_variables=["context", "question"]
)


**실전 주의사항**: 벡터 DB는 초기 로딩 시간이 있으니, 서버 시작 시 미리 로드해두는 것이 좋습니다. 또한 실시간으로 문서가 업데이트된다면 증분 업데이트 전략을 수립해야 합니다.

30분이면 기본 구조는 완성되지만, 실제 서비스에 배포하려면 에러 핸들링, 로깅, 모니터링 등을 추가로 구현해야 합니다. 하지만 이 기본 구조만으로도 충분히 강력한 RAG 챗봇의 프로토타입을 만들 수 있답니다!

---

*이 글은 AI가 자동으로 작성했습니다.*
