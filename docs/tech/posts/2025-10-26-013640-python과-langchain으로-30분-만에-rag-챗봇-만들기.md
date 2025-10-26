---
date: 2025-10-26T01:36:40+09:00
title: "Python과 LangChain으로 30분 만에 RAG 챗봇 만들기"
description: "Python과 LangChain을 활용해 문서 기반 RAG 챗봇을 구축하는 실전 가이드입니다. 환경 설정부터 문서 임베딩, 쿼리 실행, 성능 최적화까지 단계별로 설명합니다."
categories:
  - AI & ML
tags:
  - RAG
  - LangChain
  - Python
  - 챗봇
  - 벡터데이터베이스
---

> Python과 LangChain을 활용해 문서 기반 RAG 챗봇을 구축하는 실전 가이드입니다. 환경 설정부터 문서 임베딩, 쿼리 실행, 성능 최적화까지 단계별로 설명합니다.



<!-- more -->

## RAG란 무엇이고 왜 필요할까?

![RAG 개념](https://source.unsplash.com/800x600/?artificial,intelligence,database)

RAG(Retrieval-Augmented Generation)는 '검색 증강 생성'이라는 의미로, 외부 데이터베이스에서 관련 정보를 검색해 AI의 답변 품질을 높이는 기술입니다. 일반 ChatGPT는 학습된 데이터만 알고 있지만, RAG 챗봇은 여러분의 회사 문서, 제품 매뉴얼, 개인 노트 등을 실시간으로 참조해 답변할 수 있죠.

예를 들어 2023년 이후의 최신 정보나 회사 내부 문서 내용을 물어봐도 정확하게 답변할 수 있습니다. LLM의 환각(Hallucination) 문제도 크게 줄일 수 있어서, 실무에서 AI를 활용하려면 RAG는 거의 필수적인 기술이 되었어요.

## 필요한 준비물과 환경 설정

![Python 개발환경](https://source.unsplash.com/800x600/?python,programming,code)

시작하기 전에 필요한 것들을 살펴볼게요. Python 3.9 이상과 OpenAI API 키가 필요합니다. LangChain은 LLM 애플리케이션 개발을 쉽게 해주는 프레임워크이고, 벡터 데이터베이스로는 무료인 Chroma를 사용할 거예요.

python
pip install langchain openai chromadb tiktoken
pip install langchain-community langchain-openai


**💡 TIP**: OpenAI API 키는 platform.openai.com에서 발급받을 수 있으며, 환경변수로 설정하는 것이 안전합니다. `.env` 파일에 `OPENAI_API_KEY=your-key`로 저장하고 `python-dotenv` 라이브러리로 불러오세요.

벡터 데이터베이스는 텍스트를 숫자 배열(임베딩)로 변환해 저장하는 특수한 DB입니다. 의미적으로 유사한 문서를 빠르게 찾을 수 있어 RAG의 핵심 요소죠.

## 문서 로드와 임베딩 생성하기

![문서 처리](https://source.unsplash.com/800x600/?documents,data,processing)

이제 본격적으로 RAG 시스템을 구축해봅시다. 첫 단계는 문서를 작은 청크(chunk)로 나누고 벡터화하는 것입니다.

python
from langchain_community.document_loaders import TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Chroma

# 문서 로드
loader = TextLoader('your_document.txt', encoding='utf-8')
documents = loader.load()

# 텍스트 분할 (청크 크기와 오버랩 조정 가능)
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200
)
splits = text_splitter.split_documents(documents)

# 벡터 스토어 생성
vectorstore = Chroma.from_documents(
    documents=splits,
    embedding=OpenAIEmbeddings()
)


**핵심 포인트**: `chunk_size`는 한 번에 처리할 텍스트 크기를, `chunk_overlap`은 청크 간 중복 범위를 의미합니다. 오버랩이 있어야 문맥이 끊기지 않아요. 일반적으로 1000/200 조합이 효과적이지만, 문서 특성에 따라 조정이 필요합니다.

## RAG 체인 구성과 쿼리 실행

![AI 챗봇](https://source.unsplash.com/800x600/?chatbot,conversation,ai)

이제 검색기와 LLM을 연결해 실제 질문에 답변하는 체인을 만들어볼게요.

python
from langchain_openai import ChatOpenAI
from langchain.chains import RetrievalQA
from langchain.prompts import PromptTemplate

# 프롬프트 템플릿 정의
template = """다음 컨텍스트를 사용해 질문에 답변하세요.
모르면 모른다고 답하고, 추측하지 마세요.

컨텍스트: {context}

질문: {question}

답변:"""

QA_PROMPT = PromptTemplate(
    template=template,
    input_variables=["context", "question"]
)

# RAG 체인 생성
llm = ChatOpenAI(model_name="gpt-3.5-turbo", temperature=0)
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vectorstore.as_retriever(search_kwargs={"k": 3}),
    chain_type_kwargs={"prompt": QA_PROMPT}
)

# 질문하기
query = "문서의 주요 내용은 무엇인가요?"
result = qa_chain.invoke({"query": query})
print(result["result"])


`search_kwargs={"k": 3}`는 관련 문서 3개를 검색한다는 의미입니다. 더 많은 컨텍스트가 필요하면 k 값을 늘리면 되지만, 토큰 비용도 함께 증가한다는 점 유의하세요.

## 실전 팁과 성능 최적화

![최적화 대시보드](https://source.unsplash.com/800x600/?optimization,performance,analytics)

실무에서 RAG 시스템을 운영하며 얻은 팁들을 공유합니다.

**1. 청크 전략 최적화**: 기술 문서는 chunk_size를 크게(1500-2000), 대화형 콘텐츠는 작게(500-800) 설정하는 것이 효과적입니다.

**2. 하이브리드 검색 활용**: 벡터 검색만으로 부족하다면, 키워드 기반 검색(BM25)과 결합하는 하이브리드 방식을 고려하세요. LangChain의 `EnsembleRetriever`를 사용하면 쉽게 구현할 수 있습니다.

**3. 메타데이터 활용**: 문서에 날짜, 카테고리 등 메타데이터를 추가하면 필터링이 가능해져 검색 정확도가 높아집니다.

python
# 메타데이터 필터링 예시
retriever = vectorstore.as_retriever(
    search_kwargs={
        "k": 3,
        "filter": {"category": "technical"}
    }
)


**4. 비용 관리**: 임베딩은 한 번만 생성하고 저장해 재사용하세요. Chroma는 `persist_directory`로 로컬 저장이 가능합니다.

이제 여러분만의 RAG 챗봇을 만들 준비가 되었습니다. 처음엔 작은 문서로 테스트하고, 점차 규모를 키워가면서 최적의 설정을 찾아보세요. RAG는 단순해 보이지만, 실제 운영에서는 청크 전략, 검색 알고리즘, 프롬프트 엔지니어링 등 최적화할 요소가 많습니다. 하나씩 실험하며 개선해나가는 과정이 핵심이에요!

---

*이 글은 AI가 자동으로 작성했습니다.*
