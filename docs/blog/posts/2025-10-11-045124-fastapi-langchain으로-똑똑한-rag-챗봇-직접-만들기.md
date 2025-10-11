---
date: 2025-10-11T04:51:24+09:00
title: "FastAPI + LangChain으로 똑똑한 RAG 챗봇 직접 만들기"
description: "FastAPI와 LangChain을 활용해 실전 RAG 챗봇을 구축하는 방법을 단계별로 소개합니다. 문서 벡터화부터 API 서버 구축, 성능 최적화까지 실무에 바로 적용 가능한 내용을 담았습니다."
categories:
  - AI & ML
tags:
  - FastAPI
  - LangChain
  - RAG
  - 챗봇
  - 벡터데이터베이스
---

> FastAPI와 LangChain을 활용해 실전 RAG 챗봇을 구축하는 방법을 단계별로 소개합니다. 문서 벡터화부터 API 서버 구축, 성능 최적화까지 실무에 바로 적용 가능한 내용을 담았습니다.


## RAG 챗봇, 왜 지금 주목받을까요?

최근 ChatGPT의 등장 이후 많은 기업들이 자체 챗봇 구축에 관심을 갖고 있습니다. 하지만 일반 LLM은 학습 데이터에 없는 최신 정보나 회사 내부 문서는 답변하지 못한다는 한계가 있죠. 바로 이 문제를 해결하는 기술이 **RAG(Retrieval-Augmented Generation)**입니다.

RAG는 외부 지식 베이스에서 관련 정보를 검색(Retrieval)한 후, 그 정보를 기반으로 답변을 생성(Generation)하는 방식입니다. 마치 시험 볼 때 교과서를 참고할 수 있는 것과 비슷하다고 생각하면 쉽습니다. 이번 글에서는 FastAPI와 LangChain을 활용해 실전에서 사용 가능한 RAG 챗봇을 직접 구축하는 방법을 소개해드리겠습니다.

## 핵심 기술 스택 이해하기

### FastAPI - 빠르고 현대적인 API 프레임워크

FastAPI는 Python 기반의 고성능 웹 프레임워크로, 비동기 처리를 기본 지원하며 자동 API 문서화 기능을 제공합니다. 챗봇 서비스처럼 실시간 응답이 중요한 애플리케이션에 최적화되어 있죠.

### LangChain - LLM 애플리케이션의 Swiss Army Knife

LangChain은 LLM 기반 애플리케이션 개발을 위한 프레임워크입니다. 문서 로딩, 텍스트 분할, 임베딩, 벡터 스토어 연동 등 RAG 구현에 필요한 모든 컴포넌트를 모듈화하여 제공합니다. 마치 레고 블록처럼 필요한 기능을 조립해서 사용할 수 있어요.

### 벡터 데이터베이스 - 의미 기반 검색의 핵심

문서를 벡터(숫자 배열)로 변환해 저장하는 데이터베이스입니다. ChromaDB, Pinecone, Faiss 등이 있으며, 단순 키워드 매칭이 아닌 의미적 유사도를 기반으로 검색합니다.

## 단계별 구축 가이드

### 1단계: 환경 설정 및 패키지 설치

bash
pip install fastapi uvicorn langchain openai chromadb python-dotenv
pip install langchain-community pypdf sentence-transformers


### 2단계: 문서 로딩 및 벡터화

python
from langchain.document_loaders import PyPDFLoader, TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import Chroma

# 문서 로딩
loader = PyPDFLoader("your_document.pdf")
documents = loader.load()

# 텍스트 분할 (청크 단위로)
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200
)
splits = text_splitter.split_documents(documents)

# 벡터 스토어 생성
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(splits, embeddings)


**💡 팁:** chunk_size는 너무 작으면 맥락이 손실되고, 너무 크면 관련 없는 정보가 포함될 수 있습니다. 1000-1500자가 일반적으로 적절합니다.

### 3단계: RAG 체인 구성

python
from langchain.chat_models import ChatOpenAI
from langchain.chains import RetrievalQA

llm = ChatOpenAI(model_name="gpt-3.5-turbo", temperature=0)

qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vectorstore.as_retriever(search_kwargs={"k": 3}),
    return_source_documents=True
)


### 4단계: FastAPI 서버 구축

python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="RAG Chatbot API")

class Query(BaseModel):
    question: str

@app.post("/chat")
async def chat(query: Query):
    try:
        result = qa_chain({"query": query.question})
        return {
            "answer": result["result"],
            "sources": [doc.page_content[:200] for doc in result["source_documents"]]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)


## 성능 최적화 & 프로덕션 배포 팁

### 응답 속도 개선하기

1. **캐싱 전략**: 자주 묻는 질문은 Redis를 활용해 캐싱하면 응답 속도를 10배 이상 향상시킬 수 있습니다.

2. **임베딩 모델 선택**: OpenAI Embeddings는 정확하지만 비용이 발생합니다. 무료 대안으로 HuggingFace의 sentence-transformers를 사용하면 비용을 절감할 수 있어요.

3. **비동기 처리**: FastAPI의 async/await를 적극 활용해 동시 요청 처리 성능을 높이세요.

### 답변 품질 높이기

python
# 프롬프트 템플릿 커스터마이징
from langchain.prompts import PromptTemplate

template = """
당신은 친절한 고객 지원 AI입니다. 주어진 컨텍스트를 기반으로 정확하게 답변하세요.
답변을 모를 경우 모른다고 솔직히 말씀해주세요.

컨텍스트: {context}

질문: {question}

답변:"""

PROMPT = PromptTemplate(
    template=template, input_variables=["context", "question"]
)


### 보안 & 모니터링

- **API 키 관리**: 환경 변수(.env)로 민감 정보 분리
- **Rate Limiting**: 과도한 요청 방지를 위한 제한 설정
- **로깅**: 질문-답변 쌍을 로깅해 지속적인 개선에 활용

## 다음 단계로 나아가기

기본 RAG 챗봇을 구축했다면, 이제 다음 단계를 고려해보세요:

**Multi-Query Retrieval**: 사용자 질문을 여러 버전으로 재작성해 검색 정확도를 높이는 기법입니다. LangChain의 MultiQueryRetriever를 활용하면 쉽게 구현할 수 있습니다.

**Hybrid Search**: 벡터 검색과 키워드 검색을 결합하면 더 정확한 문서 검색이 가능합니다. 특히 전문 용어나 고유명사가 많은 도메인에서 효과적이죠.

**대화 기록 관리**: ConversationBufferMemory를 사용해 이전 대화 맥락을 유지하면 더 자연스러운 대화가 가능합니다.

RAG 챗봇은 계속 진화하는 기술입니다. 기본기를 탄탄히 다진 후, 실제 사용자 피드백을 받아가며 개선해나가는 것이 가장 중요합니다. 여러분만의 특별한 챗봇을 만들어보세요!

<!-- more -->

---

*이 글은 AI가 자동으로 작성했습니다.*
