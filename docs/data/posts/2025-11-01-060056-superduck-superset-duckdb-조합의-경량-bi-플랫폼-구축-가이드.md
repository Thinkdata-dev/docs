---
date: 2025-11-01T06:00:56+09:00
title: "SuperDuck: Superset + DuckDB 조합의 경량 BI 플랫폼 구축 가이드"
description: "Superset와 DuckDB를 결합하여 Azure Data Lake Storage에 저장된 데이터를 직접 읽는 경량 BI 플랫폼 SuperDuck 구축 방법을 소개합니다. 복잡한 BI 툴 대신 자체 BI 환경을 구축하고 싶을 때 유용한 가이드입니다."
categories:
  - Data Engineering
tags:
  - SuperDuck
  - Superset
  - DuckDB
  - ADLS Gen2
  - Delta Lake
---

> Superset와 DuckDB를 결합하여 Azure Data Lake Storage에 저장된 데이터를 직접 읽는 경량 BI 플랫폼 SuperDuck 구축 방법을 소개합니다. 복잡한 BI 툴 대신 자체 BI 환경을 구축하고 싶을 때 유용한 가이드입니다.



<!-- more -->

{
  "content": "## BI를 임대하는 대신 직접 구축했습니다.\n\n저는 더 이상 BI를 임대하지 않습니다. 직접 구축했습니다.\n\n[![이미지 1: Alex Anthraper](https://miro.medium.com/v2/resize:fill:64:64/1*YGSDpN76bUchreXWyF1QgA.jpeg)](https://medium.com/@alex.anthraper?source=post_page---byline--92939490ffb0---------------------------------------)\n\n6분 읽기\n\n2025년 9월 14일\n\n이미지를 전체 크기로 보려면 Enter 키를 누르거나 클릭하세요.\n\n![이미지 2](https://miro.medium.com/v2/resize:fit:700/1*laJH3PcBBidepPk724aQaw.png)\n\n_귀하의 BI는 데이터 비용보다 더 높아서는 안 됩니다._\n\n**SuperDuck**을 만나보세요. 작고 휴대 가능한 스택입니다. **Superset**은 UI, **DuckDB**는 엔진, 그리고 오픈 데이터는 레이크에 있습니다. 노트북이나 작은 VM에서 실행할 수 있는 컨테이너 하나, 필요할 때 확장할 수 있습니다. 클릭하고 드래그하여 대시보드를 만들고, 강력 사용자를 위한 SQL을 사용하고, 벤더 종속성을 제거하세요.\n\n> 예제에서는 **Azure Data Lake Storage (ADLS Gen2) + Delta Lake**를 사용합니다. 대부분의 문서에서는 S3 + Parquet을 보여줍니다. ADLS + Delta는 문서화가 부족합니다. S3를 사용하는 경우 동일한 패턴이 적용됩니다.\n\n## SuperDuck이란 무엇이며 누구를 위한 것인가\n\n전통적인 BI는 조용히 **두 사람의 일자리**가 됩니다. 요청자와 개발자가 있습니다. 기능은 번역 과정에서 손실되고, 티켓 대기열이 형성되고, 호기심은 사라집니다. 저는 SuperDuck을 **셀프 서비스**형으로 설계했습니다. 클릭하고 드래그하여 대시보드를 만들고, 'SELECT', 'JOIN', 'GROUP BY' 및 'WHERE'를 아는 사람은 누구나 직접 SQL을 사용할 수 있습니다. 티켓이 필요 없습니다.\n\n이것은 다음을 원하는 팀을 위한 것입니다.\n\n*   **종속성 없는 휴대성**\n*   **독점 형식이 아닌 개방형 형식**\n*   **예측 가능한 비용** (좌석 세금 없음)\n*   **호기심을 처벌하지 않는** 환경\n\n## 아키텍처\n\n*   **소규모 팀:** 1개의 컨테이너, SQLite 메타데이터, ADLS를 통한 데이터 저장\n*   **성장하는 팀:** Superset 메타데이터를 **Postgres**로 이동하여 여러 컨테이너가 상태를 공유할 수 있도록 합니다. 이러한 컨테이너를 **Nginx** 또는 관리형 로드 밸런서 뒤에 배치합니다. 작은 CDN을 통해 정적 에셋을 제공하여 로딩 속도를 높입니다.\n\n## 거버넌스 및 공유\n\n*   Superset **역할**을 사용하여 데이터셋 생성자와 뷰어(viewer)를 구분합니다.\n*   이름이 지정된 스키마(main)에 뷰를 유지하고 도메인(sales_, ops_)으로 접두사를 붙여 사람들이 쉽게 찾을 수 있도록 합니다.\n*   데이터셋을 추가하는 방법에 대한 짧은 **“How to add a dataset”** 페이지를 위키에 추가합니다. 대부분의 사람들은 더 이상 필요하지 않습니다.\n\n## 로드맵\n\n*   Superset 메타데이터를 위한 Postgres 및 간단한 백업\n*   Docker 이미지에 대한 CI/CD (버전 핀, 기본 이미지 스캔)\n*   작은 “시작 갤러리”의 유용한 SQL 조각과 함께 제공\n*   모델링 및 혈통 (lineage)이 필요한 팀을 위한 선택적 dbt 레이어\n\n## 결론\n\n더 이상 BI를 임대할 필요가 없습니다. **SuperDuck**을 실행할 수 있습니다. 레이크를 직접 읽고 호기심을 처벌하지 않는 작고 강력한 스택입니다. 설정하기 쉽고, 실행 비용이 저렴하며, 소유하기 때문에 신뢰할 수 있습니다.\n\n_시작점과 체크리스트가 포함된 시작 갤러리를 원하시면 **SuperDuck**에 댓글을 남겨주세요. 공유해 드리겠습니다._\n\n\n## 기술 참고 사항\n\n*   **SAS 비밀번호**: 환경 변수에 SAS를 넣고 시작 시 DuckDB **영구 비밀번호**를 만듭니다. 새 환경 값으로 다시 시작하여 회전시킵니다.\n*   **튜닝**: Superset 연결 “extras”에서 스레드/메모리를 설정합니다 (기본적으로 'threads: 8', 'memory_limit: 16GB' - 박스에 맞게 조정).\n\n**SAS 비밀번호**는 코드에 넣지 마세요. 환경 변수에 넣고, 시작 시 DuckDB **영구 비밀번호**를 만들고, 새 환경 값으로 다시 시작하여 회전시킵니다.\n\nAzure Delta 참고 사항:\n\n*   테이블 루트(테이블을 포함하는 _delta_log/ 폴더)를 사용하고 'delta_scan(...)/read_parquet(...)'에 **후행 슬래시**를 포함합니다.\n*   스캔을 **영구 뷰**로 감쌉니다. 'delta_scan(...)'/'read_parquet(...)'가 데이터셋 브라우저에 표시되지 않으면 표시되지 않습니다.\n*   **비밀번호를 코드에 넣지 마세요**. SAS를 환경 변수를 사용합니다. 시작 시 DuckDB **영구 비밀번호**를 만듭니다. 새 환경 값으로 다시 시작하여 회전시킵니다.\n*   **튜닝**: Superset 연결 “extras”에 스레드/메모리를 설정합니다 (기본적으로 'threads: 8', 'memory_limit: 16GB' - 박스에 맞게 조정).\n\n**SAS 비밀번호**는 코드에 넣지 마세요. 환경 변수에 넣고, 시작 시 DuckDB **영구 비밀번호**를 만들고, 새 환경 값으로 다시 시작하여 회전시킵니다.\n\nAzure Delta 참고 사항:\n\n*   테이블 루트(테이블을 포함하는 _delta_log/ 폴더)를 사용하고 'delta_scan(...)/read_parquet(...)'에 **후행 슬래시**를 포함합니다.\n*   스캔을 **영구 뷰**로 감쌉니다. 'delta_scan(...)'/'read_parquet(...)'가 데이터셋 브라우저에 표시되지 않으면 표시되지 않습니다.\n*   **비밀번호를 코드에 넣지 마세요**. SAS를 환경 변수를 사용합니다. 시작 시 DuckDB **영구 비밀번호**를 만들고, 새 환경 값으로 다시 시작하여 회전시킵니다.\n*   **튜닝**: Superset 연결 “extras”에 스레드/메모리를 설정합니다 (기본적으로 'threads: 8', 'memory_limit: 16GB' - 박스에 맞게 조정).\n\n**SAS 비밀번호**는 코드에 넣지 마세요. 환경 변수에 넣고, 시작 시 DuckDB **영구 비밀번호**를 만들고, 새 환경 값으로 다시 시작하여 회전시킵니다.\n\nAzure Delta 참고 사항:\n\n*   테이블 루트(테이블을 포함하는 _delta_log/ 폴더)를 사용하고 'delta_scan(...)/read_parquet(...)'에 **후행 슬래시**를 포함합니다.\n*   스캔을 **영구 뷰**로 감쌉니다. 'delta_scan(...)'/'read_parquet(...)'가 데이터셋 브라우저에 표시되지 않으면 표시되지 않습니다.\n*   **비밀번호를 코드에 넣지 마세요**. SAS를 환경 변수를 사용합니다. 시작 시 DuckDB **영구 비밀번호**를 만들고, 새 환경 값으로 다시 시작하여 회전시킵니다.\n*   **튜닝**: Superset 연결 “extras”에 스레드/메모리를 설정합니다 (기본적으로 'threads: 8', 'memory_limit: 16GB' - 박스에 맞게 조정).\n\n**SAS 비밀번호**는 코드에 넣지 마세요. 환경 변수에 넣고, 시작 시 DuckDB **영구 비밀번호**를 만들고, 새 환경 값으로 다시 시작하여 회전시킵니다.\n\nAzure Delta 참고 사항:\n\n*   테이블 루트(테이블을 포함하는 _delta_log/ 폴더)를 사용하고 'delta_scan(...)/read_parquet(...)'에 **후행 슬래시**를 포함합니다.\n*   스캔을 **영구 뷰**로 감쌉니다. 'delta_scan(...)'/'read_parquet(...)'가 데이터셋 브라우저에 표시되지 않으면 표시되지 않습니다.\n*   **비밀번호를 코드에 넣지 마세요**. SAS를 환경 변수를 사용합니다. 시작 시 DuckDB **영구 비밀번호**를 만들고, 새 환경 값으로 다시 시작하여 회전시킵니다.\n*   **튜닝**: Superset 연결 “extras”에 스레드/메모리를 설정합니다 (기본적으로 'threads: 8', 'memory_limit: 16GB' - 박스에 맞게 조정).\n\n**SAS 비밀번호**는 코드에 넣지 마세요. 환경 변수에 넣고, 시작 시 DuckDB **영구 비밀번호**를 만들고, 새 환경 값으로 다시 시작하여 회전시킵니다.\n\nAzure Delta 참고 사항:\n\n*   테이블 루트(테이블을 포함하는 _delta_log/ 폴더)를 사용하고 'delta_scan(...)/read_parquet(...)'에 **후행 슬래시**를 포함합니다.\n*   스캔을 **영구 뷰**로 감쌉니다. 'delta_scan(...)'/'read_parquet(...)'가 데이터셋 브라우저에 표시되지 않으면 표시되지 않습니다.\n*   **비밀번호를 코드에 넣지 마세요**. SAS를 환경 변수를 사용합니다. 시작 시 DuckDB **영구 비밀번호**를 만들고, 새 환경 값으로 다시 시작하여 회전시킵니다.\n*   **튜닝**: Superset 연결 “extras”에 스레드/메모리를 설정합니다 (기본적으로 'threads: 8', 'memory_limit: 16GB' - 박스에 맞게 조정).\n\n**SAS 비밀번호**는 코드에 넣지 마세요. 환경 변수에 넣고, 시작 시 DuckDB **영구 비밀번호**를 만들고, 새 환경 값으로 다시 시작하여 회전시킵니다.\n")
}

---

## 출처

원문: [https://medium.com/@alex.anthraper/superduck-superset-duckdb-a-tiny-but-mighty-bi-platform-92939490ffb0](https://medium.com/@alex.anthraper/superduck-superset-duckdb-a-tiny-but-mighty-bi-platform-92939490ffb0)

---

*이 글은 AI가 자동으로 작성했습니다.*
