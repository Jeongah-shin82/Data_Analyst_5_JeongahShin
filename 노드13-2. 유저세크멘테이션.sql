# 노드13-2. 상품 추천 전략 수립을 위한 유저 세그멘테이션
# 데이터 형태 출력 확인
SELECT *
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 
LIMIT 1000

-- 1. 전체 고객수는 몇명인가요? 8,068명
# 확인지표 : 고객수
# 쿼리계산방법 : 고객 ID를 기준으로 고유값 개수 확인

SELECT COUNT(DISTINCT ID) AS Customer_count
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 

-- 2. 성별 구성비는 어떻게 되나요?
# 확인지표 : 성별 구성비
# 쿼리 계산 방법 : 
-- (1) 성별(Gender / STRING) 기준 그룹화 
-- (2) 성별에 따른 고객수 계산 COUNT(DISTINCT ID) GROUP BY Gender
-- (3) 전체 고객수 산출 (집계함수 + 윈도우함수(전체테이블 기준) : SUM(COUNT(DISTINCT ID)) OVER()
-- (4) 성별에 따른 비율 계산 : 예) 남성 고객수 / 전체 고객수 *100

SELECT Gender, 
       COUNT(DISTINCT ID) AS Customer_count,
       ROUND(COUNT(DISTINCT ID)/(SUM(COUNT(DISTINCT ID)) OVER())*100,2) AS rate
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 
GROUP BY Gender
-- [LMS 상 쿼리 작성 방법]
-- (1) 성별기준, 고객ID개수 계산
-- (2) SELECT에 전체 고객수를 산출한 쿼리문을 '서브쿼리'로 반영
SELECT Gender, 
       ROUND(COUNT(DISTINCT ID)/(SELECT COUNT(DISTINCT ID) FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend`),2) AS Rate
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 
GROUP BY Gender

-- 3. 고객의 평균 나이는 몇인가요?
# 확인지표 : 고객의 평균 나이 43.5세
# 쿼리계산 방법 : AVG(Age) 

SELECT ROUND(AVG(Age),1) AS Customer_Avg_Age
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 

-- 4. 결혼 여부(Ever_Married)가 'Yes'인 고객은 몇 명인가요? 전체 대비 비율은 어떻게 되나요?
# 확인지표 : 결혼한 고객수 확인 및 전체 고객수 대비 비율 확인 - 4643명 / 57.55%
# 쿼리계산 방법 1. 앞선 성별(Gender)에 따른 고객수 및 비율 확인과 유사한 쿼리문, 그룹핑 기준을 Ever_Married로 변경
-- (1) 결혼 여부(Ever_Married / BOOLEAN) 을 이용한  
-- (2) 성별에 따른 고객수 계산 COUNT(DISTINCT ID) GROUP BY Ever_Married
-- (3) 전체 고객수 산출 (집계함수 + 윈도우함수(전체테이블 기준) : SUM(COUNT(DISTINCT ID)) OVER()
-- (4) Ever_Married에 따른 비율 계산 : 예) 결혼한('true') 고객수 / 전체 고객수 *100

SELECT Ever_Married, 
       COUNT(DISTINCT ID) AS Customer_count,
       ROUND(COUNT(DISTINCT ID)/(SUM(COUNT(DISTINCT ID)) OVER())*100,2) AS rate
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 
GROUP BY Ever_Married

# 쿼리계산 방법 2. 
-- (1) 결혼 여부(Ever_Married / BOOLEAN) 값이 true인 데이터로 필터링 => Ever_Married IS false
-- (2) 필터링 된 데이터에서 고객수 계산 COUNT(DISTINCT ID)
-- (3) 전체 고객수 산출 (서브쿼리 이용): SELECT COUNT(DISTINCT ID) FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend`
-- (4) Ever_Married에 따른 비율 계산 : 예) 결혼한('true') 고객수 / 전체 고객수 *100

SELECT COUNT(DISTINCT ID) AS Customer_count,
       ROUND(COUNT(DISTINCT ID)/(SELECT COUNT(DISTINCT ID) FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend`),2) AS rate
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 
WHERE Ever_Married = true

# 쿼리계산 방법 3. LMS 노드 상 사용방법 : 'Ever_Married'
-- CASE WHEN 을 이용하여 결혼 여부를 확인하는 Indicator 설정 
WITH RawData AS (
  SELECT ID, Gender, Ever_Married, CASE WHEN Ever_Married IS true THEN 1 ELSE 0 END AS Indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 
)
SELECT SUM(Indicator) AS MarriedNumber, ROUND(AVG(Indicator)*100,2) AS Rate_Of_Married
FROM RawData

-- 5. 대학을 졸업한 (Graduated='Yes') 고객의 비율은 얼마인가요? 0.62 (4,968명)
# 확인지표 : 대학을 졸업한 고객(Graduated='true')의 비율 (대학을 졸업한 고객수 / 전체 고객수)
# 쿼리계산방법 - ※ 4번 결혼한 고객수 계산방식과 동일
-- (1) 대학을 졸업한 고객(Graduated='true') 수 계산 
-- (2) 전체고객수를 서브쿼리를 이용하여 산출후 비율계산

SELECT COUNT(DISTINCT ID) AS Customer_count,
       ROUND(COUNT(DISTINCT ID)/(SELECT COUNT(DISTINCT ID) FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend`),2) AS rate
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 
WHERE Graduated = true;

# 쿼리계산 방법(LMS 노드 상 사용방법) : Graduated IS true
-- CASE WHEN 을 이용하여 졸업 여부를 확인하는 Indicator 설정 
WITH RawData AS (
  SELECT ID, Graduated, CASE WHEN Graduated IS true THEN 1 ELSE 0 END AS Indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 
)
SELECT SUM(Indicator) AS GraduatedNumber, ROUND(AVG(Indicator)*100,2) AS Rate_Of_Graduated
FROM RawData

-- 6. 가장 많은 고객이 속한 직업군은 무엇인가요?
# 확인지표 : 직업군 별 고객수 확인하여 가장 많은 고객이 있는 직업군 확인
# 쿼리계산방법 : 직업군을 그룹핑하여 고객수 확인, 많은 순서대로 정렬

SELECT Profession, COUNT(DISTINCT ID) Customer_count
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 
GROUP BY Profession
ORDER BY Customer_count DESC;

-- 7. Segmentation이 'A'인 고객의 평균 나이는 몇인가요?
# 확인지표 : Segmentation 기준으로 A 등급으로 분류된 고객의 평균 나이
# 쿼리계산방법
-- (1) Segmentation 기준 A등급인 고객 확인 : WHERE 절을 이용하여 필터링 (WHERE Segmentation LIKE 'A') 
-- (2) A등급에 속한 고객의 나이 확인 후 서브쿼리 이용 : SELECT ID, Age
-- (3) 고객의 평균 나이 계산 AVG(Age)
SELECT ROUND(AVG(Age),2) AS Avg_age_of_AgradeCustomer
FROM(
    SELECT ID, Age
    FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 
    WHERE Segmentation LIKE 'A'
)

# 쿼리계산 방법(간단하게)
SELECT ROUND(AVG(Age),2) AS Avg_age_of_AgradeCustomer
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 
WHERE Segmentation LIKE 'A'

-- 8. 직업별 평균 소비 점수(Spending_Score)의 분포를 계산했을 때, High의 비율이 가장 높은 직업군은 어디인가요?
# 확인지표 : 고객의 직업별 소비점수 분포 비율을 확인하고, High의 비율이 가장 높은 직업군 확인
# 쿼리작성방법
-- (1) 각 직업군별 고객의 소비점수(High, Average, Low) 분포 확인 : 각 분포에 속하는 고객수 확인
-- (2) 직업군별 고객수 확인 : SUM(COUNT(ID)) OVER(PARTITION BY Prefession)
-- (3) 직업군별 소비점수 분포 비율(SS_Variation_rate) = 각 분포에 속하는 고객수(1) / 직업군별 고객수(2)
-- (4) (1)~(3)에서 생성한 임시테이블 RawData를 이용하여 소비점수(Spending_Score)가 'High'인 데이터를 필터링 : WHERE Spending_Score LIKE 'High'
-- (5) SS_Variation_rate 기준 내림차순 정렬, LIMIT 1 => 가장 High 비율이 높은 직업군 1행만 출력

WITH RawData AS (
  SELECT Profession,Spending_Score, COUNT(DISTINCT ID), SUM(COUNT(ID)) OVER(PARTITION BY Profession),
       ROUND(COUNT(DISTINCT ID)/SUM(COUNT(ID)) OVER(PARTITION BY Profession)*100,2) AS SS_Variation_rate
  FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend`
  GROUP BY 1, 2
  ORDER BY SS_Variation_rate DESC, Spending_Score)

SELECT Profession, Spending_Score, SS_Variation_rate
FROM RawData
WHERE Spending_Score LIKE 'High'
ORDER BY SS_Variation_rate DESC
LIMIT 1;

# 쿼리계산 방법(LMS상 진행방법)
-- CASE WHEN 이용하여 각 등급에 해당하는 데이터 별도 컬럼화 => 각 컬럼의 평균은 각 등급별 비율
WITH ProcessedData AS (
  SELECT ID, Profession, Spending_Score,
        CASE WHEN Spending_Score = 'Low' THEN 1 ELSE 0 END AS IsLow,
        CASE WHEN Spending_Score = 'Average' THEN 1 ELSE 0 END AS IsAvg,
        CASE WHEN Spending_Score = 'High' THEN 1 ELSE 0 END AS IsHigh
  FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend`
)
SELECT Profession, 
       ROUND(AVG(IsLow),2) AS LowRate, 
       ROUND(AVG(IsAvg),2) AS AvgRate, 
       ROUND(AVG(IsHigh),2) AS HighRate
FROM ProcessedData
GROUP BY 1
ORDER BY HighRate DESC

-- 9. 세그먼트 A, B, C, D에 속한 고객 수는 각각 몇이며, 고객 수가 가장 많은 그룹은 어디인가요?
# 확인지표 : 각 세그먼트에 속한 고객수를 확인하고, 고객이 가장 많이 분포된 그룹 확인
# 쿼리계산방법
-- (1) 세그먼트 기준 고객수 확인
-- (2) 분류된 고객수 기준 내림차순 배열

SELECT Segmentation, COUNT(ID) AS CountBySegment
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend`
GROUP BY Segmentation
ORDER BY CountBySegment DESC;

-- 10. 세그먼트 별 Ever_Married = 'Yes'의 비율이 어떻게 다른가요? 두드러지는 트렌드가 있나요? D등급에서 결혼비율이 다른 등급에 비해 현저히 낮은 26.85%이다.
# 확인지표 : 세그먼트별 고객수, 세그먼트별 기혼고객수를 통한 비율확인
# 쿼리계산방법 1) 
-- (1) 세그먼트 기준 총 고객수 및 기혼 고객수 확인 및 임시테이블 SegmentByMarrige 생성
-- (2) 임시테이블 기준 비율계산 및 필터링
WITH SegmentByMarrige AS(
  SELECT Segmentation, Ever_Married, COUNT(ID) AS MarriedCount, SUM(COUNT(ID)) OVER(PARTITION BY Segmentation) AS Total_count
  FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend`
  GROUP BY 1,2
)

SELECT Segmentation, ROUND(SegmentByMarrige.MarriedCount/Total_count*100,2) Married_Rate
FROM SegmentByMarrige
WHERE Ever_Married = true

# 쿼리계산방법 2) CASE WHEN 사용
WITH MarriedData AS (
  SELECT Segmentation, Ever_Married,
        CASE WHEN Ever_Married IS true THEN 1 ELSE 0 END AS M_Indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend`
)
SELECT Segmentation,
       ROUND(AVG(M_Indicator)*100,2) AS MarriedRate
FROM MarriedData
GROUP BY 1
ORDER BY 1;

-- 11. 세그먼트와 Spending_Score 별 고객 분포를 확인했을 때, 두드러지는 트렌드가 있나요? 
--     'High'가 가장 많이 분포해 있는 세그먼트는 어디이며 'Average', 'Low'가 가장 많이 분포해있는 세그먼트는 어디인가요?
# 확인지표 : 각 세그먼트에 속한 고객을 소비점수를 기준으로 분류하여 분포를 확인하고, 각 소비 점수별 많이 분포되어있는 세그먼트 확인
# 쿼리계산방법 1:
-- (1) 세그먼트 기준 각 세그먼트별 전체 고객수 확인 및 세그먼트 내 고객을 Spending_Score을 기준으로 분류하여 고객수 확인, 분포비율 계산
-- (2) (1)에서 확인한 테이블을 임시테이블 RawData로 지정
-- (3) 세그멘테이션 및 소비점수 분포 추출

WITH RawData AS (
  SELECT Segmentation,Spending_Score, COUNT(DISTINCT ID), SUM(COUNT(ID)) OVER(PARTITION BY Segmentation),
       ROUND(COUNT(DISTINCT ID)/SUM(COUNT(ID)) OVER(PARTITION BY Segmentation)*100,2) AS SS_Variation_rate
  FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend`
  GROUP BY 1, 2
  ORDER BY SS_Variation_rate DESC, Spending_Score)

SELECT Segmentation,Spending_Score, MAX(SS_Variation_rate)
FROM RawData
GROUP BY 1, 2
ORDER BY 1, MAX(SS_Variation_rate) DESC

# 쿼리계산방법 2:
-- CASE WHEN 사용
WITH ProcessedData2 AS (
  SELECT Segmentation, Spending_Score, 
        CASE WHEN Spending_Score = 'Low' THEN 1 ELSE 0 END IsLow,
        CASE WHEN Spending_Score = 'Average' THEN 1 ELSE 0 END IsAvg,
        CASE WHEN Spending_Score = 'High' THEN 1 ELSE 0 END IsHigh
  FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend`
)
SELECT Segmentation,
       SUM(IsLow) AS LowNo,       
       SUM(IsAvg) AS AVGNo,        
       SUM(IsHigh) AS HighNo,
       ROUND(AVG(IsLow)*100,2) AS LowRate,
       ROUND(AVG(IsAvg)*100,2) AS AvgRate,
       ROUND(AVG(IsHigh)*100,2) AS HighRate
FROM ProcessedData2
GROUP BY Segmentation

-- 12. 각 세그먼트 별 평균 나이가 어떻게 되나요?
# 확인지표 : 고객을 세그먼트로 구분해서, 각 세그먼트에 속한 고객의 평균 나이 구하기
# 쿼리작성방법 : 고객을 세그먼트로 그룹화하여, 해당 구간 AVG(Age) 계산

SELECT Segmentation,ROUND(AVG(Age),1) AS Segment_Avg_Age
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 
GROUP BY 1
ORDER BY 1

-- 13. 각 세그먼트 별 평균 가족크기 어떻게 되나요?
# 확인지표 : 고객을 세그먼트로 구분해서, 각 세그먼트에 속한 고객의 평균 나이 구하기
# 쿼리작성방법 : 고객을 세그먼트로 그룹화하여, 해당 구간 AVG(Family_Size) 계산

SELECT Segmentation,ROUND(AVG(Family_Size),1) AS Segment_Avg_Age
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend` 
GROUP BY 1
ORDER BY 1

-- 14. 각 세그먼트 별 고객수가 많은 직업군 TOP 3는 어떻게 되나요?
SELECT Segmentation, Profession, Count(ID)
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend`
GROUP BY 1,2
ORDER BY 1,COUNT(ID) DESC

-- 15. 세그먼트별 페르소나 정의 : 각 세그먼트가 어떤 고객들로 구성되어 있는 지 
-- 구체적인 지표(평균나이, 결혼비율, 주된 직업군, 소비성향 등)을 파악하고 각 그룹의 페르소나를 명확하게 정의
SELECT
  Segmentation,
  COUNT(*) AS customer_count,
  ROUND(AVG(Age), 1) AS avg_age,
  -- 결혼한 고객 비율 계산
  ROUND(SUM(CASE WHEN Ever_Married IS true THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS married_ratio_pct,
  -- 소비 성향별 고객 수 분포
  SUM(CASE WHEN Spending_Score = 'Low' THEN 1 ELSE 0 END) AS spending_low,
  SUM(CASE WHEN Spending_Score = 'Average' THEN 1 ELSE 0 END) AS spending_average,
  SUM(CASE WHEN Spending_Score = 'High' THEN 1 ELSE 0 END) AS spending_high,
  ROUND(AVG(Family_Size), 1) AS avg_family_size
FROM `project-5faeab26-b699-4f50-a43.DAY1.recommend`
GROUP BY
  Segmentation
ORDER BY
  Segmentation;



