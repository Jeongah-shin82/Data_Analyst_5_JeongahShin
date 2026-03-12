-- 테이블 불러오기 : (Tip) 데이터세트에서 테이블명 우측 (:)을 클릭 후 '쿼리' 선택
SELECT *
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
LIMIT 5 
-- 전체 몇 개의 행으로 구성되어 있는 지 확
SELECT COUNT(*) AS Total_Row
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 

-- 데이터 EDA 1

-- 1. 2011년 10월 한달동안, 취소를 제외한 영국(United Kingdom)의 유효 주문수는 몇 건인가요? 1,955건
-- (유효주문 : InvoiceNo가 'C'로 시작하지 않는 거래)
-- [내가 작성한 답]
SELECT COUNT(DISTINCT InvoiceNo)
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
WHERE 1=1
  AND InvoiceDate BETWEEN '2011-10-01' AND '2011-10-31'
  AND Country LIKE 'United Kingdom'
  AND InvoiceNo NOT LIKE 'C%'

-- 2. 전체 고객(CustomerID)은 몇명인가요? 4,372명
-- 고객수 파악 : 비즈니스 규모 또는 시장 점유율 파악
SELECT COUNT(DISTINCT CustomerID) AS num_of_customer
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
WHERE CustomerID IS NOT NULL;

-- 3. 데이터에 포함되어 있는 국가(Country)는 몇개이며, 어느 나라가 유효 주문 수가 가장 많은가요? 38개 국가, United Kingdom
-- 국가별 주요 시장 파악을 위한 쿼리문 : 어떤 국가가 이커머스에서 핵심 시장인지 파악 / 국가별 주문수 분포 파악하여 주문에 얼마나 기여하는 지
--                                  마케팅 시 타겟 국가 설정 / 운영전략과 물류 - 주문이 많은 국가에 재고나 운송자원 등 물류 우선 배치
SELECT Country, COUNT(DISTINCT InvoiceNo) AS order_count
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
WHERE InvoiceNo NOT LIKE 'C%'
GROUP BY 1
ORDER BY order_count DESC;

-- 4. 가장 많이 판매된 상품은 무엇인가요?(Quantity 합계 기준) : 
-- 베스트셀러 상품 확인 : 전략 상품, 재고운영 방법, 마케팅 대상 등 다양한 의사 결정의 핵심 기준
--                     재고와 공급 전략에 활용, 상품별 마케팅 우선 순위 설정
--                     추가적으로 WHERE 절, GROUP BY 절을 이용하여 시즌 상품, 계절 상품 등 파악 가능

--[기본] Description 없이 가장 많이 판매된 StockCode : 22197 / 56,450
SELECT StockCode, SUM(Quantity)
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
GROUP BY 1
ORDER BY SUM(Quantity) DESC;

--StockCode에 대한 상품 설명 반영 : 84077 / WORLD WAR 2 GLIDERS ASSTD DESIGNS/ 53,847건
SELECT StockCode, Description, SUM(Quantity)
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
GROUP BY 1,2
ORDER BY SUM(Quantity) DESC;

--[비교 : Description 구분 반영 전, 최대 판매된 제품 22197에 대한 정보 확인]
-- POPCORN HOLDER (36,334건), SMALL POPCORN HOLDER (20,116건)으로 나뉘어진 결과 확인 
SELECT StockCode, Description, SUM(Quantity)
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
WHERE StockCode = '22197'
GROUP BY 1,2
ORDER BY SUM(Quantity) DESC;

-- 5. 고객 당 평균 유효 주문 수는 몇 개인가요? (유효 주문 기준)
SELECT CustomerID, COUNT(DISTINCT InvoiceNo)
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
WHERE InvoiceNo NOT LIKE 'C%'
GROUP BY CustomerID
ORDER BY COUNT(DISTINCT InvoiceNo) DESC;
-- [해석] 
-- - 약 1년의 기간동안 몇몇 고객의 경우, 200건 이상
-- - 회원가입하지 않은 고객의 구입건수 3,528건
-- - 회원가입하지 않은 고객의 구입건수를 제외하는 경우,
SELECT CustomerID, COUNT(DISTINCT InvoiceNo)
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
WHERE InvoiceNo NOT LIKE 'C%'
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY COUNT(DISTINCT InvoiceNo) DESC;
-- ※ 충성고객 확인, VIP 기준 설정 가능, 고객을 구매 건수 기준으로 세그먼트 후 고객 마케팅 전략 설정 가능, 또는 비정상적인 구매패턴 확인 및 파악
--    구매 패턴 확인 후, 일반 고객과 비즈니스 고객 여부 확인 및 특성파악

-- 6. 유효 주문을 기준으로 했을 때, 가장 자주 구매한 고객은 누구인가요? (구매 건수 기준)
-- 앞선 문제로 CustomerID 12748 고객이 연간 210건의 구매를 진행한 것을 확인할 수 있다. 

-- 7. 1건의 주문에서 가장 많은 금액을 지불한 주문은 무엇인가요? (주문 당 총 결제금액 기준)
SELECT InvoiceNo, SUM(UnitPrice * Quantity) AS Total_payment
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
GROUP BY 1
ORDER BY SUM(UnitPrice * Quantity) DESC
LIMIT 1

-- 상세 주문 내역 확인 (InvoiceNo : 581483)
SELECT *
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
WHERE InvoiceNo = '581483'

-- [분석 목적]
-- 고액주문 파악 => 가장 큰 매출을 발생시키는 주문 파악, BtoB 또는 BtoC 대량주문, VIP 고객 주문 가능성 가늠. 매출액 집중도(특정 물품에 매출이 밀집되어 있는지) 확인, 이상치(단가, 수량 입력 오류 여부 원인) 탐지

-- 8. 월별 주문 수는 어떻게 변동되었나요? (Month 별 집계)
-- Month별 집계 함수 : FORMAT_DATE('%Y-%m',DATE(InvoiceDate))
-- %Y : 4자리 연도(2010), %m : 2자리 월
SELECT 
  FORMAT_DATE('%Y-%m',DATE(InvoiceDate)) AS Month, 
  COUNT(DISTINCT InvoiceNo) AS Order_count
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
GROUP BY Month
ORDER BY Month;

-- 'FORMAT_TIMESTAMP' 변환:
-- (1) FORMAT_TIMESTAMP(변환할 형태, 변환할 컬럼명) : ※ 'FORMAT_' 뒤에 'DATE'나 'TIMESTAMP'와 같이 원래 데이터형태 작성
-- (2) 변환할 형태 : %Y - 4자리 연도(2010), %m - 2자리 월
SELECT 
  -- FORMAT_TIMESTAMP의 경우, timezone을 고려하기 때문에, 정확한 사용을 위해서는 timezone을 입력해야 함
  FORMAT_TIMESTAMP('%Y-%m',InvoiceDate, 'UTC') AS Month, 
  COUNT(DISTINCT InvoiceNo) AS Order_count
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
GROUP BY Month
ORDER BY Month;

-- 'YYYY-MM' 추출 : 
-- (1) InvoiceDate 컬럼이 Timestamp 형태이므로 LEFT 함수를 적용하기 위해 CAST 함수를 이용하여'STRING' 형태로 변환
-- (2) LEFT 함수를 이용하여, 왼쪽 7자리 글자 추출
SELECT 
  LEFT(CAST(InvoiceDate AS STRING), 7) AS Month, 
  COUNT(DISTINCT InvoiceNo) AS Order_count
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
GROUP BY Month
ORDER BY Month;

-- [월별 분석]
-- 월별 주문수 추이 확인 : 월별 성장, 감소 흐름 파악
-- 시즌성, 이벤트 효과 파악
-- 마케팅, 운영전략 수립 및 수요예측에 활용 : 예) 주문수가 낮은 월 - 마케팅 집중, 주문수가 높은 월 - 물량 확보 등

-- 9. 전체 주문 중 취소된 주문(C로 시작하는 InvoiceNo)은 몇 건인가요?
SELECT COUNT(DISTINCT InvoiceNo) AS cancel_count
FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
WHERE InvoiceNo LIKE 'C%'

-- 10. 나라별로 전체 주문 대비 취소율을 계산하고, 취소율이 가장 높은 국가는 어디인지 확인하세요.
WITH CancelRateByCountry AS (
  SELECT 
    Country, 
    COUNT(DISTINCT InvoiceNo) AS total_order, 
    COUNT(DISTINCT CASE WHEN InvoiceNo LIKE 'C%' THEN InvoiceNo END) AS cancel_count
  FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
  GROUP BY 1
) 
  
SELECT Country, ROUND(cancel_count/total_order * 100, 2) AS cancel_rate 
FROM CancelRateByCountry
ORDER BY cancel_rate DESC;

-- (LMS 상 작성 방식)
-- (1) CASE WHEN THEN 함수 사용 : InvoiceNo에서 'C'로 시작하는 경우, 1, 유효 주문인 경우, 0 으로 지정
--     ※ 실무에서 비율을 구할 때, 'CASE WHEN 조건 1 THEN 결과값 ELSE 결과값 END' 많이 사용
-- (2) 서브쿼리(RawData) 생성 후 이를 이용하여,
-- (3) Country별 주문건수, 취소건수(SUM(Indicator))를 이용하여 취소율 계산

SELECT Country, ROUND(SUM(Indicator)/Count(DISTINCT InvoiceNo) * 100 ,2) AS cancel_rate 
FROM (
  SELECT DISTINCT Country, InvoiceNo, CASE WHEN InvoiceNo LIKE 'C%' THEN 1 ELSE 0 END AS Indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail`
) AS RawData
GROUP BY 1
ORDER BY cancel_rate DESC;

-- 11. 위의 결과에 추가로, 나라별 평균 주문 금액 계산
-- **쿼리문 작성 순서**
-- (1) 서브쿼리로 각 나라별 주문번호에 따른 상품(StockCode)의 구매가격(수량 *단가), 정상거래 여부 Indicator 설정
-- (2) 임시테이블 OrderProcessed 생성 : 나라별, 주문별, 총구매액, 정상거래여부 확인자 설정 
-- (3) 최종 구하고자 하는 나라별 평균구매금액, 취소율 계산 
  
  -- (2) 임시테이블 OrderProcessed 생성 : 나라별, 주문별, 총구매액, 정상거래여부 확인자 설정 
WITH OrderProcessed AS (
  SELECT Country, InvoiceNo,Indicator,Sum(RawData.PurchasePrice) AS TotalPrice
  FROM (
  -- (1) 서브쿼리로 각 나라별 주문번호에 따른 상품(StockCode)의 구매가격(수량 *단가), 정상거래 여부 Indicator 설정 
    SELECT Country, InvoiceNo,StockCode, Quantity*UnitPrice AS PurchasePrice, CASE WHEN InvoiceNo LIKE 'C%' THEN 1 ELSE 0 END AS Indicator
    FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
) AS RawData
  GROUP BY 1,2,3
)
-- (3) 최종 구하고자 하는 나라별 평균구매금액, 취소율 계산 
SELECT Country, ROUND(AVG(TotalPrice),2) AS AvgPurchaceAmount, ROUND(SUM(Indicator)/Count(DISTINCT InvoiceNo) * 100 ,2) AS cancel_rate
FROM OrderProcessed
GROUP BY 1
ORDER BY cancel_rate DESC;

-- [취소율 분석기법 사용용도]
-- 취소율이 높은 국가 판단 -> 배송 품질 향상, 제품설명 보강
-- 평균 구매금액이 높은 국가 확인 -> 고가상품 타겟팅 대상 설정 가능 
-- 국가별 구매력 확인

-- 12. 가장 취소율이 높은 상품은 무엇인가요? (상품 취소율 =  취소된 수량/총 주문수량)
-- 주문번호  123 : 정상주문 10건 / 주문번호 456 : 취소주문 5건
-- 전체 주문건수 : 15건
-- 취소율 = 5건/15건

-- <나의 쿼리문 작성 방법>
-- (1) 서브쿼리 작성 : 취소 주문 중 제품별 취소수량(음수 조정) 및 취소확인자(Indicator) 설정
-- (2) 상품별 총 주문 수량 및 취소수량, 비율 계산

SELECT 
  StockCode, 
  Description, 
  SUM(CASE WHEN Indicator = 1 THEN FixedQuantity Else 0 END) AS Cancel_Quantity,
  -- (2) 상품별 총 주문 수량 및 취소수량, 비율 계산
  ROUND(SUM(CASE WHEN Indicator = 1 THEN FixedQuantity Else 0 END)/SUM(FixedQuantity) *100,2) AS CancelRate_byStockCode
FROM(
  -- (1) 서브쿼리 작성 : 취소 주문 중 제품별 취소수량(음수 조정) 및 취소확인자(Indicator) 설정
  SELECT InvoiceNo, 
        StockCode, 
        Description, 
        CASE WHEN Quantity < 0 THEN Quantity *(-1) ELSE Quantity END AS FixedQuantity,
        CASE WHEN InvoiceNo LIKE 'C%' THEN 1 ELSE 0 END AS Indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
)
GROUP BY 1,2
ORDER BY CancelRate_byStockCode DESC, Cancel_Quantity DESC;

--[LMS 쿼리문]
WITH RawData AS(
  SELECT InvoiceNo, 
        StockCode, 
        Description, 
        CASE WHEN Quantity < 0 THEN Quantity *(-1) ELSE Quantity END AS FixedQuantity,
        CASE WHEN InvoiceNo LIKE 'C%' THEN 1 ELSE 0 END AS Indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY1.onlineretail` 
)

SELECT 
  StockCode, 
  Description, 
  SUM(FixedQuantity*Indicator), -- 취소된 건에 한하여 합계 추출
  ROUND(SUM(FixedQuantity*Indicator)/SUM(FixedQuantity)*100,2) AS CancelRate 
FROM RawData
GROUP BY 1,2
ORDER BY CancelRate DESC, SUM(FixedQuantity*Indicator) DESC;

-- [제품별 취소율 분석]
-- 제품별 전체 판매량 대비 취소율 확인 : 취소율이 높은 경우, 취소에 대한 원인 분석(제품의 품질 상태, 제품의 상세페이지와 실제 상품의 질의 일치여부, 배송문제 등 역으로 문제 진단 가능) 
-- 취소율이 높은 상품의 경우, CS 클레임으로 연결될 강능성이 높음 -> 추가적인 고객 불만 분석
-- 재고운영 전략을 세울 때에도 반품율이 높은 상품의 경우, 재입고를 보수적으로 진행  
-- 상품의 보관, 판매에서의 물류비 등 비용과 연관되어 있음 -> 운영관리 의사결정에 사용










