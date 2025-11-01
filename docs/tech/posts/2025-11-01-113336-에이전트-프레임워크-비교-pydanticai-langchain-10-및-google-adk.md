---
date: 2025-11-01T11:33:36+09:00
title: "에이전트 프레임워크 비교: PydanticAI, LangChain 1.0 및 Google ADK"
description: "PydanticAI, LangChain, Google ADK 에이전트 프레임워크를 비교 분석하고 장단점을 설명"
categories:
  - AI & ML
tags:
  - LangChain
  - PydanticAI
  - Google ADK
  - Agent Frameworks
  - LLM
---

> PydanticAI, LangChain, Google ADK 에이전트 프레임워크를 비교 분석하고 장단점을 설명



<!-- more -->

{
  "content": "팀 규모가 커지고 프로젝트가 복잡해짐에 따라 Pydantic AI는 한계에 직면하지만 LangChain 1.0은 약속이 많습니다. Google ADK와 LangChain 1.0 중에서 선택한다면 LangChain을 선택하겠습니다. 아직 에이전트 프레임워크를 사용하지 않고 고수준 에이전트를 구축하려는 경우 LangChain 1.0을 사용하세요. 하지만 좌절할 준비를 하세요.\n\n_Lak은 Obin.ai의 공동 창업자이자 CTO입니다. Obin.ai는 금융 분야의 심층 도메인 에이전트를 구축하고 있습니다. 다음 채용 공고를 확인하세요:_[_https://www.obin.ai/careers/_](https://www.obin.ai/careers/)\n\n**LangChain 1.0 요약**\n\n*   미들웨어 훅을 통해 광범위한 도구가 LangChain에 연결될 수 있습니다. 이미 관측 가능성(Arize), 가드레일(Guardrails AI) 등에서 이를 확인할 수 있습니다.
*   커뮤니티에서 심층 에이전트, 심층 연구 등과 같은 프레임워크를 구축하고 있습니다. 오픈 웨이트 모델을 위한 HuggingChain과 같이 새로운 오픈 소스 에이전트 기능이 발견되는 곳이 LangChain이 될 수 있습니다.
*   정밀한 워크플로 제어를 지원하는 데 있어 Pydantic AI와 유사합니다.
*   정밀한 제어는 LLM이 스스로 서브 에이전트 또는 도구를 호출할 수 있도록 하여 보다 자율적인 애플리케이션을 구축하는 데 영향을 미치지 않습니다.\n\n**LangChain 1.0의 한계**\n\n*   LLM 추상화가 불안정합니다. 고수준 추상화를 사용해야 하지만 필요한 경우 모델로 다운그레이드할 수 있어야 합니다. 하지만 Google Gemini를 사용하는 동안 유사한 제한 사항이 Claude를 사용하는 사람에게 영향을 미칠 것이라고 의심합니다.\n*   도구 호출은 동기식이어야 하므로 원격으로 호스팅되는 API를 도구 호출을 통해 래핑하는 많은 애플리케이션에 지연 시간을 추가합니다.\n*   API에서 모델과 에이전트 간의 혼란이 많습니다. 더 많은 기능이 추가됨에 따라 더욱 악화될 가능성이 높습니다. 진지하게, 그들은 자신의 API를 발명하는 대신 Pydantic AI의 깔끔한 API 표면을 복사하거나 채택했어야 했습니다.\n\n**Google ADK와 LangChain 1.0**\n\nPydantic AI는 깨끗하고 훌륭하지만 팀 규모가 커지고 프로젝트가 복잡해지면 한계에 직면합니다. Google ADK와 LangChain 1.0 중에서 선택한다면 LangChain을 선택하겠습니다. 아직 에이전트 프레임워크를 사용하지 않고 고수준 에이전트를 구축하려는 경우 LangChain 1.0을 사용하세요. 하지만 좌절할 준비를 하세요.\n\n_Lak은 Obin.ai의 공동 창업자이자 CTO입니다. Obin.ai는 금융 분야의 심층 도메인 에이전트를 구축하고 있습니다. 다음 채용 공고를 확인하세요:_[_https://www.obin.ai/careers/_](https://www.obin.ai/careers/)\n\n**Google ADK에 대한 생각**\n\nGoogle은 훌륭한 도구를 만듭니다. 이 게시물을 통해 알 수 있듯이 Gemini의 기능과 컨텍스트 캐싱, 검색 도구, UrlContext 등과 같은 내장 도구가 생산성 애플리케이션에서 매우 효과적이라는 것을 알 수 있습니다. 불행히도 개발자 프레임워크에 대한 실적이 일관되게 떨어집니다. Google 내부의 요구 사항은 일반적인 애플리케이션의 요구 사항과 매우 다르기 때문에 도구(그리고 LLM)은 훌륭하지만 개발자 프레임워크는 이해하고 사용하기 어렵습니다.\n\n**반사**\n\nPydantic AI와 마찬가지로 Google ADK도 정밀한 출력을 검증하기 위해 출력을 명시적으로 포맷해야 했습니다. 하지만 LoopAgent와 같은 고급 제어 구조의 존재는 반영을 쉽게 할 수 있습니다.\n\ncase_creation_agent = LoopAgent(\n name=f\"{output_key}_loop_agent\",\n max_iterations=2,\n sub_agents=\[\n case_creation_agent,\n formatter_agent,\n validation_agent,\n \]\n)\n\nGoogle ADK 구현은 268줄로 실행됩니다(Pydantic은 176줄이고 LangChain은 266줄). 예상대로 고수준 추상화가 더 적은 코드 줄로 이어지지 않았습니다. 하지만 몇 개의 추가 에이전트와 더 긴 프롬프트를 작성해야 했기 때문일 수 있습니다.\n\nLangChain 1.0은 유망합니다. \n\n*   미들웨어 훅을 통해 광범위한 도구가 LangChain에 연결될 수 있습니다. 이미 관측 가능성(Arize), 가드레일(Guardrails AI) 등에서 이를 확인할 수 있습니다.\n*   커뮤니티에서 심층 에이전트, 심층 연구 등과 같은 프레임워크를 구축하고 있습니다. 오픈 웨이트 모델을 위한 HuggingChain과 같이 새로운 오픈 소스 에이전트 기능이 발견되는 곳이 LangChain이 될 수 있습니다.\n*   정밀한 워크플로 제어를 지원하는 데 있어 Pydantic AI와 유사합니다.\n*   정밀한 제어는 LLM이 스스로 서브 에이전트 또는 도구를 호출할 수 있도록 하여 보다 자율적인 애플리케이션을 구축하는 데 영향을 미치지 않습니다.\n\n**LangChain 1.0의 한계**\n\n*   LLM 추상화가 불안정합니다. 고수준 추상화를 사용해야 하지만 필요한 경우 모델로 다운그레이드할 수 있어야 합니다. 하지만 Google Gemini를 사용하는 동안 유사한 제한 사항이 Claude를 사용하는 사람에게 영향을 미칠 것이라고 의심합니다.\n*   도구 호출은 동기식이어야 하므로 원격으로 호스팅되는 API를 도구 호출을 통해 래핑하는 많은 애플리케이션에 지연 시간을 추가합니다.\n*   API에서 모델과 에이전트 간의 혼란이 많습니다. 더 많은 기능이 추가됨에 따라 더욱 악화될 가능성이 높습니다. 진지하게, 그들은 자신의 API를 발명하는 대신 Pydantic AI의 깔끔한 API 표면을 복사하거나 채택했어야 했습니다.\n\n**Google ADK와 LangChain 1.0**\n\nPydantic AI는 깨끗하고 훌륭하지만 팀 규모가 커지고 프로젝트가 복잡해지면 한계에 직면합니다. Google ADK와 LangChain 1.0 중에서 선택한다면 LangChain을 선택하겠습니다. 아직 에이전트 프레임워크를 사용하지 않고 고수준 에이전트를 구축하려는 경우 LangChain 1.0을 사용하세요. 하지만 좌절할 준비를 하세요.\n\n_Lak은 Obin.ai의 공동 창업자이자 CTO입니다. Obin.ai는 금융 분야의 심층 도메인 에이전트를 구축하고 있습니다. 다음 채용 공고를 확인하세요:_[_https://www.obin.ai/careers/_](https://www.obin.ai/careers/)\n\n**Google ADK에 대한 생각**\n\nGoogle은 훌륭한 도구를 만듭니다. 이 게시물을 통해 알 수 있듯이 Gemini의 기능과 컨텍스트 캐싱, 검색 도구, UrlContext 등과 같은 내장 도구가 생산성 애플리케이션에서 매우 효과적이라는 것을 알 수 있습니다. 불행히도 개발자 프레임워크에 대한 실적이 일관되게 떨어집니다. Google 내부의 요구 사항은 일반적인 애플리케이션의 요구 사항과 매우 다르기 때문에 도구(그리고 LLM)은 훌륭하지만 개발자 프레임워크는 이해하고 사용하기 어렵습니다.\n\n**반사**\n\nPydantic AI와 마찬가지로 Google ADK도 정밀한 출력을 검증하기 위해 출력을 명시적으로 포맷해야 했습니다. 하지만 LoopAgent와 같은 고급 제어 구조의 존재는 반영을 쉽게 할 수 있습니다.\n\ncase_creation_agent = LoopAgent(\n name=f\"{output_key}_loop_agent\",\n max_iterations=2,\n sub_agents=\[\n case_creation_agent,\n formatter_agent,\n validation_agent,\n \]\n)\n\nGoogle ADK 구현은 268줄로 실행됩니다(Pydantic은 176줄이고 LangChain은 266줄). 예상대로 고수준 추상화가 더 적은 코드 줄로 이어지지 않았습니다. 하지만 몇 개의 추가 에이전트와 더 긴 프롬프트를 작성해야 했기 때문일 수 있습니다.\n\nLangChain 1.0은 유망합니다. \n\n*   미들웨어 훅을 통해 광범위한 도구가 LangChain에 연결될 수 있습니다. 이미 관측 가능성(Arize), 가드레일(Guardrails AI) 등에서 이를 확인할 수 있습니다.\n*   커뮤니티에서 심층 에이전트, 심층 연구 등과 같은 프레임워크를 구축하고 있습니다. 오픈 웨이트 모델을 위한 HuggingChain과 같이 새로운 오픈 소스 에이전트 기능이 발견되는 곳이 LangChain이 될 수 있습니다.\n*   정밀한 워크플로 제어를 지원하는 데 있어 Pydantic AI와 유사합니다.\n*   정밀한 제어는 LLM이 스스로 서브 에이전트 또는 도구를 호출할 수 있도록 하여 보다 자율적인 애플리케이션을 구축하는 데 영향을 미치지 않습니다.\n\n**LangChain 1.0의 한계**\n\n*   LLM 추상화가 불안정합니다. 고수준 추상화를 사용해야 하지만 필요한 경우 모델로 다운그레이드할 수 있어야 합니다. 하지만 Google Gemini를 사용하는 동안 유사한 제한 사항이 Claude를 사용하는 사람에게 영향을 미칠 것이라고 의심합니다.\n*   도구 호출은 동기식이어야 하므로 원격으로 호스팅되는 API를 도구 호출을 통해 래핑하는 많은 애플리케이션에 지연 시간을 추가합니다.\n*   API에서 모델과 에이전트 간의 혼란이 많습니다. 더 많은 기능이 추가됨에 따라 더욱 악화될 가능성이 높습니다. 진지하게, 그들은 자신의 API를 발명하는 대신 Pydantic AI의 깔끔한 API 표면을 복사하거나 채택했어야 했습니다.\n\n**Google ADK와 LangChain 1.0**\n\nPydantic AI는 깨끗하고 훌륭하지만 팀 규모가 커지고 프로젝트가 복잡해지면 한계에 직면합니다. Google ADK와 LangChain 1.0 중에서 선택한다면 LangChain을 선택하겠습니다. 아직 에이전트 프레임워크를 사용하지 않고 고수준 에이전트를 구축하려는 경우 LangChain 1.0을 사용하세요. 하지만 좌절할 준비를 하세요.\n\n_Lak은 Obin.ai의 공동 창업자이자 CTO입니다. Obin.ai는 금융 분야의 심층 도메인 에이전트를 구축하고 있습니다. 다음 채용 공고를 확인하세요:_[_https://www.obin.ai/careers/_](https://www.obin.ai/careers/)\n\n**Google ADK에 대한 생각**\n\nGoogle은 훌륭한 도구를 만듭니다. 이 게시물을 통해 알 수 있듯이 Gemini의 기능과 컨텍스트 캐싱, 검색 도구, UrlContext 등과 같은 내장 도구가 생산성 애플리케이션에서 매우 효과적이라는 것을 알 수 있습니다. 불행히도 개발자 프레임워크에 대한 실적이 일관되게 떨어집니다. Google 내부의 요구 사항은 일반적인 애플리케이션의 요구 사항과 매우 다르기 때문에 도구(그리고 LLM)은 훌륭하지만 개발자 프레임워크는 이해하고 사용하기 어렵습니다.\n\n**반사**\n\nPydantic AI와 마찬가지로 Google ADK도 정밀한 출력을 검증하기 위해 출력을 명시적으로 포맷해야 했습니다. 하지만 LoopAgent와 같은 고급 제어 구조의 존재는 반영을 쉽게 할 수 있습니다.\n\ncase_creation_agent = LoopAgent(\n name=f\"{output_key}_loop_agent\",\n max_iterations=2,\n sub_agents=\[\n case_creation_agent,\n formatter_agent,\n validation_agent,\n \]\n)\n\nGoogle ADK 구현은 268줄로 실행됩니다(Pydantic은 176줄이고 LangChain은 266줄). 예상대로 고수준 추상화가 더 적은 코드 줄로 이어지지 않았습니다. 하지만 몇 개의 추가 에이전트와 더 긴 프롬프트를 작성해야 했기 때문일 수 있습니다."}

---

## 출처

원문: [https://levelup.gitconnected.com/comparing-agent-frameworks-pydanticai-langchain-1-0-and-google-adk-4d2d46d927f0](https://levelup.gitconnected.com/comparing-agent-frameworks-pydanticai-langchain-1-0-and-google-adk-4d2d46d927f0)

---

*이 글은 AI가 자동으로 작성했습니다.*
