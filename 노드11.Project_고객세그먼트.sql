SELECT COUNT(InvoiceNo) AS COUNT_InvoiceNo,
       COUNT(StockCode) AS COUNT_StockCode, 
       COUNT(Description) AS COUNT_Description,
       COUNT(Quantity) AS COUNT_Quantity,
       COUNT(InvoiceDate) AS COUNT_InvoiceDate,
       COUNT(UnitPrice) AS COUNT_UnitPrice,
       COUNT(CustomerID) AS COUNT_CustomerID,
       COUNT(Country) AS COUNT_Country
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`

-- 11-4. 데이터 전처리(1): 결측치 처리

-- 결측치 계산방법 1 
SELECT
    'InvoiceNo' AS column_name,
    ROUND(SUM(CASE WHEN InvoiceNo IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS missing_percentage
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
UNION ALL
SELECT
    'StockCode' AS column_name,
    ROUND(SUM(CASE WHEN StockCode IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS missing_percentage
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
UNION ALL
SELECT
    'Description' AS column_name,
    ROUND(SUM(CASE WHEN Description IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS missing_percentage
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
UNION ALL
SELECT
    'Quantity' AS column_name,
    ROUND(SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS missing_percentage
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
UNION ALL
SELECT
    'InvoiceDate' AS column_name,
    ROUND(SUM(CASE WHEN InvoiceDate IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS missing_percentage
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
UNION ALL
SELECT
    'UnitPrice' AS column_name,
    ROUND(SUM(CASE WHEN UnitPrice IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS missing_percentage
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
UNION ALL
SELECT
    'CustomerID' AS column_name,
    ROUND(SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS missing_percentage
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
UNION ALL
SELECT
    'Country' AS column_name,
    ROUND(SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS missing_percentage
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`


-- 결측치 비율 계산법 2 --
-- 1) 각 컬럼별 결측치를 제외한 숫자 및 행수 계산
-- 2) 각 컬럼을 세로로 연결하여(UNION ALL이용), 새로운 테이블 생성
-- 3) 새로운 테이블에서 최종 결측치 비율을 계산한 데이터 추출

SELECT column_name, ROUND((total - column_value) / total * 100, 2)
FROM (
     SELECT 'InvoiceNo' AS column_name, COUNT(InvoiceNo) AS column_value, COUNT(*) AS total
     FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
     UNION ALL
     SELECT 'StockCode' AS column_name, COUNT(StockCode) AS column_value, COUNT(*) AS total
     FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
     UNION ALL
     SELECT 'Description' AS column_name, COUNT(Description) AS column_value, COUNT(*) AS total
     FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
     UNION ALL
     SELECT 'Quantity' AS column_name, COUNT(Quantity) AS column_value, COUNT(*) AS total
     FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
     UNION ALL
     SELECT 'InvoiceDate' AS column_name, COUNT(InvoiceDate) AS column_value, COUNT(*) AS total
     FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
     UNION ALL
     SELECT 'UnitPrice' AS column_name, COUNT(UnitPrice) AS column_value, COUNT(*) AS total
     FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
     UNION ALL
     SELECT 'CustomerID' AS column_name, COUNT(CustomerID) AS column_value, COUNT(*) AS total
     FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
     UNION ALL
     SELECT 'Country' AS column_name, COUNT(Country) AS column_value, COUNT(*) AS total
     FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`)
     AS column_data

-- 결측치 처리 전략
-- CustomerID : 24.93% (약 4분의 1) -> 누락된 값을 다른 값으로 대체할 경우, 분석에 편향을 주고 노이즈가 될 수 있음
--             RFM 분석 기법에 따른 고객 세그멘테이션이기때문에 고객 식별자 데이터를 임의로 대체할 수 없음(정확해야 함) => 삭제
-- Description : 0.27%/ 데이터 일관성 확인 필요 (중복값을 제거하고, 해당 컬럼내 데이터 확인)
--              => 동일한 제품이지만 제품 설명이 일관적으로 기록되지 않았음을 확인 -> 누락된 설명이 있는 행 제거

SELECT DISTINCT Description
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
WHERE StockCode = '85123A'

-- Description : 중복값을 제거하고, 각각의 데이터가 몇 개 들어가 있는지 확인)
SELECT Description, COUNT(*) AS cnt
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
WHERE StockCode = '85123A'
GROUP BY 1
ORDER BY cnt DESC

-- BigQuery에서 데이터 복구 방법
-- 1) Time Travel 확인 : 기본적으로 7일간 이전 상태로 복구할 수 있는 TimeTravel 기능 제공
-- 삭제 전 시점의 데이터 확인
-- SELECT *
-- FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
-- FOR SYSTEM_TIME AS OF TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)

-- 2) 임시테이블에 삭제 전 데이터 저장(data_backup)
-- CREATE TABLE `project-5faeab26-b699-4f50-a43.modulabs_project.data_backup`
-- AS
-- SELECT *
-- FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
-- FOR SYSTEM_TIME AS OF TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)

-- 3) 임시테이블에서 원본테이블로 복구
-- INSERT INTO `project-5faeab26-b699-4f50-a43.modulabs_project.data`
-- SELECT *
-- FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data_backup`

-- 결측치 처리 : 결측치 제거
-- ※ DELETE 전에 항상 먼저 확인!
-- SELECT * FROM `...`
-- WHERE 조건
-- 결과 확인 후 → DELETE FROM `...` WHERE 조건

DELETE FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
WHERE Description IS NULL OR CustomerID IS NULL

-- 11-5. 데이터 전처리(2): 중복값 처리
-- 중복값 확인 : 8개의 컬럼에 그룹함수를 적용하여, COUNT가 1보다 큰 데이터 확인 - 총 4,837

SELECT *,
       COUNT(*) AS cnt
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
GROUP BY InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country
HAVING cnt > 1

SELECT COUNT(*) AS Duplicate_count
FROM(
SELECT *,
       COUNT(*) AS cnt
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
GROUP BY InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country
HAVING cnt > 1)

-- 중복값 처리
-- CREATE OR REPLACE TABLE + 테이블명 : 테이블명의 테이블을 생성하거나 대체하는 명령어
-- 테이블 생성 : CREATE OR REPLACE TABLE + 테이블명 + (컬럼명, 스키마)
-- 테이블 대체 : CREATE OR REPLACE TABLE + 테이블명 AS (대체할 테이블)
CREATE OR REPLACE TABLE `project-5faeab26-b699-4f50-a43.modulabs_project.data`
AS
SELECT DISTINCT *
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`

SELECT COUNT(*)
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`

-- 11-6. 데이터 전처리(3): 오류값 처리
-- 세부적으로 데이터를 살펴 보며, 클렌징이 필요한 값들이 있는지 확인

-- InvoiceNo
-- 고유한 InvoiceNo 개수 출력
SELECT COUNT(*)
FROM (
SELECT InvoiceNo, COUNT(*) AS cnt
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
GROUP BY 1
ORDER BY cnt DESC)

SELECT DISTINCT InvoiceNo
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
LIMIT 100

-- InvoiceNo가 'C'로 시작하는 행 필터링 (100행까지)
-- 특징 : Quantity 컬럼에 음수(-)값 확인
-- RFM 기준으로 고객 세그먼트를 진행하는 프로젝트로서, 취소 패턴을 이해하는 것도 중요

SELECT *
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
WHERE InvoiceNo LIKE 'C%'
LIMIT 100

-- 구매 건 상태가 Canceled 인 데이터의 비율 계산 (소숫점 첫째자리 반올림) : 2.2%

SELECT ROUND(SUM(CASE WHEN InvoiceNo LIKE 'C%' THEN 1 ELSE 0 END)/COUNT(*)*100,1)
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`

-- StockCode

-- 고유 개수 출력
SELECT COUNT(*)
FROM(
SELECT StockCode, COUNT(*) AS cnt
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
GROUP BY 1)

-- 판매 기준 상위 10개 제품 출력
SELECT StockCode, COUNT(*) AS sell_cnt
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
GROUP BY 1
ORDER BY sell_cnt DESC
LIMIT 10

SELECT *
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
WHERE StockCode LIKE 'POST'

-- StockCode의 문자열 내 숫자길이 확인
-- 임시테이블 UniqueStockCode 생성 : StockCode 컬럼에 있어서, 중복을 제외한 고유값 데이터 추출
-- 길이함수 LENGTH(컬럼명)
-- REGEXP_REPLACE 함수 : 특정 조건에 부합하는 텍스트를 다른 텍스트로 대체하는 함수
-- 사용구조) REGEXP_REPLACE(컬럼명 X, r'A','B') : 컬럼명 X에 포함된 값 중에서 A를 B로 대체
-- 사용예시) REGEXP_REPLACE(StockCode, r'[0-9]','') : 컬럼명 StockCode 에 포함된 값 중에서 0부터 9 사이의 숫자[0-9]를 비어있는 값('')으로 대체

WITH UniqueStockCodes AS (
  SELECT DISTINCT StockCode
  FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
)
SELECT
  LENGTH(StockCode) - LENGTH(REGEXP_REPLACE(StockCode, r'[0-9]', '')) AS number_count,
  COUNT(*) AS stock_cnt
FROM UniqueStockCodes
GROUP BY number_count
ORDER BY stock_cnt DESC;

-- 위 결과, 숫자가 0개인 코드는 7개, 1개인 코드는 1개 존재
-- 숫자가 0~1개인 코드 확인

SELECT DISTINCT StockCode, number_count
FROM(
    SELECT StockCode, 
           LENGTH(StockCode) - LENGTH(REGEXP_REPLACE(StockCode, r'[0-9]', '')) AS number_count
    FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
)
WHERE number_count = 0 OR number_count = 1

-- 해당 코드 값들을 가지고 있는 데이터 수는 전체 데이터 수 대비 몇 퍼센트 차지?(소수점 두번째 자리까지)

SELECT ROUND(
    SUM(CASE WHEN number_count<=1 THEN 1 ELSE 0 END)/COUNT(*) * 100 ,2) AS abnormal_rate
FROM(
    SELECT StockCode, 
           LENGTH(StockCode) - LENGTH(REGEXP_REPLACE(StockCode, r'[0-9]', '')) AS number_count
    FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`)

-- 이상치 확인 및 처리
-- 이상치 : POST, M, C2, D, BANK CHARGES, PADS, DOT, CRUK
-- 제품과 관련되지 않은 거래 기록 => RFM 기반 고객 세그멘테이션 목표와 맞지 않으므로, 제외

SELECT *
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
WHERE StockCode IN (
    SELECT DISTINCT StockCode
    FROM(
         SELECT StockCode, 
                LENGTH(StockCode) - LENGTH(REGEXP_REPLACE(StockCode, r'[0-9]', '')) AS number_count
         FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
    )
    WHERE number_count = 0 OR number_count = 1)


DELETE FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
WHERE StockCode IN (
    SELECT DISTINCT StockCode
    FROM(
         SELECT StockCode, 
                LENGTH(StockCode) - LENGTH(REGEXP_REPLACE(StockCode, r'[0-9]', '')) AS number_count
         FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
    )
    WHERE number_count = 0 OR number_count = 1)

-- Description 살펴보기

-- Description별 출현 빈도 계산, 상위 30개 출력
SELECT Description, COUNT(*) AS description_cnt
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
GROUP BY 1
ORDER BY description_cnt DESC
LIMIT 30

-- 대소문자가 혼합된 Description 확인
-- REGEXP_CONTAINS(value, regex): 컬럼안에 조건(regex)가 포함되어 있으면 True, 포함되어 있지 않으면 False
-- 눈으로 확인된 데이터 상 Description은 주로 대문자로 작성된 것으로 보임
-- 추가적으로 소문자[a-z]가 포함되어 있는 지 여부 확인
-- 19개의 결과 확인, 이중 Next Dat Carriage, High Resolution Image 관련 서비스 정보
SELECT DISTINCT Description
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
WHERE REGEXP_CONTAINS(Description, r'[a-z]')

--서비스 정보 데이터 (Next Day Carriage, High Resolution Image) 제거 : 83개 행
SELECT *
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
WHERE Description LIKE 'Next Day%' OR Description  LIKE '%High Resolution%'

DELETE
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
WHERE Description LIKE 'Next Day%' OR Description  LIKE '%High Resolution%'

-- 대소문자를 혼합하고 있는 데이터를 대문자로 표준화하는 쿼리문 작성
-- UPPER(컬럼명) : 모든 소문자를 대문자로 변환

CREATE OR REPLACE TABLE `project-5faeab26-b699-4f50-a43.modulabs_project.data`
SELECT
  * EXCEPT (Description),
  UPPER(Description) AS Description
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`

-- UnitPrice 살펴보기 : 이상치 확인 - 최솟값, 최댓값, 평균데이터 확인
-- 단위가격(UnitPrice)의 요약 통계량 : 최솟값, 최댓값, 평균

SELECT MIN(UnitPrice) AS min_price, MAX(UnitPrice) AS max_price, AVG(UnitPrice) AS avg_price
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`

-- 단가(UnitPrice)가 0원인 거래의 개수, 구매수량(Quantity)의 최솟값, 최댓값, 평균을 구하기
-- 단가(UnitPrice)가 0원인 거래수는 33개로 적음, 데이터 오류일 가능성이 높아보임 => 삭제
SELECT COUNT(Quantity) AS cnt_quantity, MIN(Quantity) AS min_quantity, MAX(Quantity) AS max_quantity, AVG(Quantity) AS avg_quantity
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
WHERE UnitPrice = 0

-- 단가(UnitPrice)가 0원인 데이터 제거
-- 제거방식 : DELETE가 아닌 기존 테이블 대체 (UnitPrice != 0 인 데이터만)
CREATE OR REPLACE TABLE `project-5faeab26-b699-4f50-a43.modulabs_project.data` AS 
SELECT *
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
WHERE UnitPrice != 0

-- 11-7. RFM 스코어
-- 구매 최신성(Recency), 구매 빈도(Frequency), 구매 가치(Monetary)에 따라 고객을 그룹으로 나누는 세그멘테이션(segmentation) 방법
-- 구매 최신성(Recency) : 고객이 마지막으로 구매한 시점. 최근에 구매한 고객이 더 자주 구매할 가능성이 높다.
-- 구매 빈도(Frequency) : 특정 기간 동안 고객이 얼마나 자주 우리의 제품이나 서비스를 구매하는지 빈도. 빈도가 높은 고객은 충성도가 높은 고객일 가능성이 높다.
-- 구매 가치(Monetary) : 고객이 지출한 총 금액. 많은 금액을 지불한 고객일수록 더 가치가 높은 충성고객일 수 있다. 

-- 구매 최신성(Recency) : 마지막 구매일로부터 현재까지 경과한 일수 계산
-- InvoiceDate를 'YYYY-MM-DD' 변환

SELECT DATE(InvoiceDate) AS InvoiceDay, *
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`

-- 실제 회사에서 다루는 데이터라면, 오늘 날짜를 기준으로 최종 구매일이 몇 일 지났는지 계산
-- 해당 데이터셋은 2010 ~ 2011년 사이의 데이터로, 최종 구매일 기준으로 Recency 산출
-- 최근 구매일 : MAX(집계함수) + 윈도우함수 OVER()
-- ※ OVER()안의 내용에 따라 계산 범위가 달라짐
-- 1. MAX(DATE(InvoiceDate)) OVER() : 괄호 안이 비어있을 때, 전체 테이블을 하나의 그룹으로 보고 MAX 계산
SELECT 
      MAX(DATE(InvoiceDate)) OVER() AS most_recent_date,
      DATE(InvoiceDate) AS InvoiceDay,
      *
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`

-- 2. MAX(DATE(InvoiceDate)) OVER(PARTITION BY InvoiceNo) : 괄호 안 그룹별 기준에 따라 MAX 계산
SELECT 
      MAX(DATE(InvoiceDate)) OVER(PARTITION BY InvoiceNo ORDER BY InvoiceNo DESC) AS most_recent_date,
      DATE(InvoiceDate) AS InvoiceDay,
      *
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
ORDER BY most_recent_date DESC

-- 유저 별로 가장 최근에 일어난 구매정보 정리
-- 유저 별로 가장 큰 InvoiceDay를 찾아서, 가장 최근 구매일로 저장
SELECT
     CustomerID, 
     MAX(DATE(InvoiceDate)) AS InvoiceDay
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
GROUP BY 1

-- 가장 최근 일자(most_recent_date)와 유저별 마지막 구매일(InvoiceDay)와 차이 계산
SELECT
    CustomerID,
    EXTRACT(DAY FROM MAX(InvoiceDay) OVER() - InvoiceDay) AS recency
FROM(
    SELECT
        CustomerID,
        MAX(DATE(InvoiceDate)) AS InvoiceDay
    FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
    GROUP BY 1
);
-- 코드 설명 --
-- EXTRACT(DAY FROM ...): EXTRACT 함수는 날짜 또는 시간 데이터 타입에서 특정부분 추출, SQL에서 시간과 날짜 연산 수행시 사용
--                        FROM 뒤에서 계산된 날짜 차이에서 DAY(일) 부분만 추출
-- MAX(InvoiceDay) OVER() : 전체 데이터 기준 가장 최근 Invoice날짜 추출 (most_recent_date)
-- SELECT CustomerID, EXTRACT(DAY FROM MAX(InvoiceDay) OVER()- InvoiceDay)
-- : 각 고객별 각 구매일과 전체 데이터 기준 가장 마지막 구매일(most_recent_date) 간의 차이를 일(DAY)로 계산

-- 최종 데이터셋에 필요한 데이터를 정제 후, 'user_r'테이블명으로 저장
CREATE OR REPLACE TABLE `project-5faeab26-b699-4f50-a43.modulabs_project.user_r` AS
SELECT
    CustomerID,
    EXTRACT(DAY FROM MAX(InvoiceDay) OVER() - InvoiceDay) AS recency
FROM(
    SELECT
        CustomerID,
        MAX(DATE(InvoiceDate)) AS InvoiceDay
    FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
    GROUP BY 1
);

-- 구매 빈도(Frequency) : 고객의 구매 빈도 또는 참여 빈도
-- 1. 전체 거래 건수 계산 : 고객별 고유한 InvoiceNo 수
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS purchase_cnt
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
GROUP BY 1; 

-- 2. 구매한 아이템의 총 수량 계산
SELECT
    CustomerID,
    SUM(Quantity) AS item_cnt
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
GROUP BY 1; 

-- (1. 전체 거래 건수 계산)과 (2. 구매한 아이텐 총 수량 계산)의 결과를 합쳐서 'user_rf'테이블에 저장
CREATE OR REPLACE TABLE `project-5faeab26-b699-4f50-a43.modulabs_project.user_rf` AS

-- (1) 전체 거래 건수 계산
WITH purchase_cnt AS ( 
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS purchase_cnt
    FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
    GROUP BY 1 
),

-- (2) 구매한 아이템 총 수량 계산
item_cnt AS (
    SELECT
        CustomerID,
        SUM(Quantity) AS item_cnt
    FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
    GROUP BY 1
)

-- 기존의 user_r에 (1)과 (2)를 통합
SELECT
  pc.CustomerID,
  pc.purchase_cnt,
  ic.item_cnt,
  ur.recency
FROM purchase_cnt AS pc
JOIN item_cnt AS ic
  ON pc.CustomerID = ic.CustomerID
JOIN `project-5faeab26-b699-4f50-a43.modulabs_project.user_r` AS ur
  ON pc.CustomerID = ur.CustomerID;

-- 구매 가치(Monetary) : 고객이 지출한 총 금액. 총 지출액 or 거래당 평균 거래금액
-- 1. 고객별 총 지출액 계산 (소숫점 첫째 자리에서 반올림)
SELECT
    CustomerID,
    ROUND(SUM(Quantity * UnitPrice), 1) AS user_total
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
GROUP BY 1;

-- 고객별 평균 거래 금액 계산
-- 1) data 테이블을 user_rf 테이블과 조인(LEFT JOIN)
-- 2) purchase_cnt로 나누어
-- 3) user_rfm 테이블로 저장
CREATE OR REPLACE TABLE `project-5faeab26-b699-4f50-a43.modulabs_project.user_rfm` AS   
SELECT
  rf.CustomerID AS CustomerID,
  rf.purchase_cnt,
  rf.item_cnt,
  rf.recency,
  ut.user_total,
  ROUND(ut.user_total/rf.purchase_cnt, 1) AS user_average
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.user_rf` AS rf
LEFT JOIN (
  -- 고객 별 총 지출액
  SELECT
      CustomerID,
      ROUND(SUM(Quantity * UnitPrice), 1) AS user_total
  FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
  GROUP BY 1  
) AS ut
ON rf.CustomerID = ut.CustomerID;

-- RFM 통합테이블 출력하기
SELECT *
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.user_rfm`

-- 11-8. 추가 Feature 추출
-- RFM 분석 보완 : 유저별 구매패턴 확인
-- 구매하는 제품의 폭이 넓은 사람일수록, 장기적으로 봤을 때, 온라인 커머스 사이트 방문 및 구매 가능성이 높음
-- <클러스터링 알고리즘> : 비슷한 특성을 가진 데이터 포인트들을 그룹화
-- 종류 : K-Means 클러스터링, 계층적 클러스터링, DBSCAN 등
-- (1) 고객 세그먼테이션 : 고객 데이터를 기반으로 비슷한 구매 패턴이나 선호도를 가진 고객 그룹을 찾아서 타겟 마케팅 전략 최적화
-- (2) 이미지 분류 : 비슷한 특징을 가진 이미지를 그룹화, 이미지 검색 및 분류 개선
-- (3) 자연어 처리 : 비슷한 주제를 가진 문서를 그룹화하여 정보 검색 및 텍스트 분석 활용
-- (4) 의학 분야 : 유사한 진단 패턴이나 환자그룹을 식별하여 질병 진단
-- (5) 이상 탐지 : 정상 데이터 그룹과 다른 패턴을 가진 이상 데이터 그룹을 찾아 보안 및 이상 탐지에 사용

-- 1. 구매하는 제품의 다양성
-- (1) 고객 별로 구매한 상품의 고유한 수를 계산 (높은 숫자 : 다양한 제품 구매, 낮은 값 : 특정 제품 구매)
-- (2) user_rfm 테이블과 결과를 합치고, 
-- (3) user_data라는 이름의 테이블에 저장

CREATE OR REPLACE TABLE `project-5faeab26-b699-4f50-a43.modulabs_project.user_data` AS  
WITH unique_products AS (
  SELECT
    CustomerID,
    COUNT(DISTINCT StockCode) AS unique_products
  FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
  GROUP BY CustomerID
)
SELECT ur.*, up.* EXCEPT (CustomerID)
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.user_rfm` AS ur
JOIN unique_products AS up
ON ur.CustomerID = up.CustomerID;

-- 2. 평균 구매 주기 : 고객별 재방문 주기
-- (1) 고객별 구매와 구매 사이의 기간 계산
-- (2) 고객별 구매와 구매 사이의 평균 소요일수
-- (3) user_data에 통합

CREATE OR REPLACE TABLE `project-5faeab26-b699-4f50-a43.modulabs_project.user_data` AS 
WITH purchase_intervals AS (
    -- (2) 고객별 구매와 구매사이 기간 평균
    SELECT 
        CustomerID,
        CASE WHEN ROUND(AVG(interval_), 2) IS NULL THEN 0 ELSE ROUND(AVG(interval_), 2) END AS average_interval
    FROM(
    -- (1) 고객별 구매와 구매 사이의 기간 계산
        SELECT
            CustomerID,
            DATE_DIFF(InvoiceDate, LAG(InvoiceDate, 1) OVER (PARTITION BY CustomerID ORDER BY InvoiceDate), DAY) AS interval_
        FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
        WHERE CustomerID IS NOT NULL
    )
    GROUP BY 1
)
        
SELECT u.*, pi.* EXCEPT (CustomerID)
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.user_data` AS u
LEFT JOIN purchase_intervals AS pi
ON u.CustomerID = pi.CustomerID;

-- * 쿼리문 분석하기
-- WITH 임시테이블명 AS (쿼리문)
-- (1) 고객 별 구매와 구매 사이의 기간 계산하기
-- -- FROM(SELECT 컬럼명 FROM 테이블 WHERE 조건) : 고객별 구매와 구매사이 기간 계산 내역이 SELECT에 연산함수(DATE_DIFF)로 반영
-- -- LAG(컬럼명, n) OVER(그룹화 기준): 해당 컬럼에서 이전 n번째 데이터를 고객ID 별, 인보이스날짜를 기준 오름차순으로 추출
-- -- DATE_DIFF(A, B, DAY) : A와 B의 차이를 계산하여 DAY(일)로 추출
-- (2) 고객별 구매 사이기간 평균 계산 : CASE WHEN ~ THEN ELSE END 이용
-- -- ROUND(AVG(interval_), 2) IS NULL THEN 0 : 바로 직전 구매가 없는 경우(단 하나의 구매만 있는 경우) 0으로 처리
-- -- ELSE ROUND(AVG(interval_), 2) : 그 외의 경우, 평균 구매일수 계산값 반영

-- 3. 구매 취소 경향성
-- (1) 취소 빈도(cancel_frequency) : 고객 별로 취소한 거래의 총 횟수 / 취소 = 불만족의 정도 또는 다른 문제점에 대한 지표 -> 고객 만족도 향상을 위한 전략
-- (2) 취소 비율(cancel_rate) : 각 고객이 한 모든 거래 중 취소를 한 거래 비율, 특정 고객에 대한 특징 파악 지표

CREATE OR REPLACE TABLE `project-5faeab26-b699-4f50-a43.modulabs_project.user_data` AS
WITH TransactionInfo AS (
  SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_transactions,
    COUNT(DISTINCT CASE WHEN InvoiceNo LIKE 'C%' THEN InvoiceNo END) AS cancel_frequency
  FROM `project-5faeab26-b699-4f50-a43.modulabs_project.data`
  GROUP BY 1
)

SELECT u.*, t.* EXCEPT(CustomerID), ROUND(cancel_frequency/total_transactions * 100,2) AS cancel_rate
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.user_data` AS u
LEFT JOIN TransactionInfo AS t
ON u.CustomerID = t.CustomerID

-- 최종 'user_data' 출력
SELECT *
FROM `project-5faeab26-b699-4f50-a43.modulabs_project.user_data`











