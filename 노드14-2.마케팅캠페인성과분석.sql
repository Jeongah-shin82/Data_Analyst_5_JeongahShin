# 노드14-2. 마케팅 캠페인 분석
# 데이터셋 : 2008~2010 전화기반 마케팅 캠페인 테이터

-- 데이터불러오기
SELECT *
FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`
LIMIT 5

# 1. 전체 고객수 : 41,188명
SELECT COUNT(*)
FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`

# 2. 전체 고객 중 정기 예금에 가입한 고객 수 : 4,640명
SELECT count(*)
FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`
WHERE y IS true

# 3. 평균 나이: 40.02세
SELECT ROUND(AVG(age),2)
FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`

# 4. job 컬럼 기준, 고객이 가장 많은 직업군은 어디인가? admin
SELECT job, count(*)
FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`
GROUP BY job
ORDER BY count(*) DESC

# 5. job 컬럼 기준, 고객 수 대비 정기 예금 가입율이 어떻게 다른가?
# 확인지표 : job 컬럼 기준, 고객수, 정기예금 가입자수, 비율
# 쿼리계산방식 : CASE WHEN을 이용하여 정기예금 가입자에 대한 indicator 생성, job 컬럼별 고객수, Job 컬럼별 정기예금 가입자수 확인
WITH ProcessedData AS(
  SELECT job, y,
       CASE WHEN y IS true THEN 1 ELSE 0 END AS indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`)
SELECT job, 
       COUNT(*) AS SubCount, 
       ROUND(AVG(indicator)*100,2) AS EnrollRateByJob
FROM ProcessedData
GROUP BY job
ORDER BY EnrollRateByJob DESC

# 6. 교육 수준에 따른 고객 수는 어떠한 트렌드를 보이고 있는가? : university.degree > high.school > basic.9y > professional.course
SELECT education, COUNT(*) AS CountByEducation
FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`
GROUP BY education
ORDER BY CountByEducation DESC;

# 7. 전체 고객 중 정기예금 가입률은 몇 %인가요? 11.27%
SELECT ROUND(AVG(enroll_indicator)*100,2)
FROM(
  SELECT CASE WHEN y IS true THEN 1 ELSE  0 END AS enroll_indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`)

# 8. 연락 수단 별 가입율은 어떻게 되나요? telephone 5.23% / cellular 14.74%
SELECT contact, ROUND(AVG(enroll_indicator)*100,2)
FROM(
  SELECT CASE WHEN y IS true THEN 1 ELSE  0 END AS enroll_indicator,
         contact       
  FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`)
GROUP BY contact

# 9. housing과 loan 대출 여부에 따른 가입률의 차이는 어떻게 되나요?
# 쿼리 계산방법 : 1) housing과 loan 각각의 기준에 따른 가입률을 구한 후, UINION ALL을 이용하여 세로로 결합
#               2) 세로로 결합시 어떤 항목으로 가입률을 분석한 내용인지 카테고리 설정
# A/B test : 두 가지 다른 버전의 기능이나 디자인을 비교하여 어떤 것이 더 효과적인지를 평가하는 방법
# A/B 테스트를 위해, 해당 조건의 수와 해당 조건에 가입자의 수를 추가로 확인
-- housing : yes 11.62% / no 10.88% / 무응답 10.81%
WITH  ProcessedData AS(
  SELECT housing, loan,
        CASE WHEN y IS true THEN 1 ELSE 0 END AS enroll_indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`)

SELECT 'HOUSING' AS category, housing AS Value, COUNT(*) AS CustomerCount,SUM(enroll_indicator) AS enroll_count, ROUND(AVG(enroll_indicator)*100,2) AS enroll_rate
FROM ProcessedData
GROUP BY housing

UNION ALL
-- loan : yes 10.93% / no 11.34% / 무응답 10.81%

SELECT 'LOAN' AS Category, loan AS Value, COUNT(*) AS CustomerCount, SUM(enroll_indicator) AS enroll_count, ROUND(AVG(enroll_indicator)*100,2) AS enroll_rate
FROM ProcessedData
GROUP BY loan

# 10. 과거에 연락한 적이 있는 고객과 그렇지 않은 고객의 가입률 차이? 과거 연락한 적이 있는 경우, 63.83%로 그렇지 않은 경우 9.26%보다 높은 수치 확
WITH ProcessedData AS(
  SELECT CASE WHEN pdays=999 THEN 'None' ELSE 'YES' END AS EverCalls,
        CASE WHEN y IS true THEN 1 ELSE 0 END AS enroll_indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`
)
SELECT EverCalls, ROUND(AVG(enroll_indicator)*100,2) AS enroll_rate
FROM ProcessedData
GROUP BY 1;

# 11. 이전 캠페인 결과(poutcome)별 가입률은 어떻게 되나요?  success 65.11% / failure 14.23% / none 8.83%
# 쿼리계산시 기존 캠페인을 진행한 이력이 없는 경우(nonexistent를 WHERE 필터링을 이용(WHERE poutcome IN ('failure','success'))하여 계산진행 가능
# 결과값 동일
SELECT poutcome, ROUND(AVG(enroll_indicator)*100,2)
FROM(
  SELECT CASE WHEN y IS true THEN 1 ELSE  0 END AS enroll_indicator,
         poutcome       
  FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`
  )
GROUP BY poutcome

# 12. 현재 캠페인 동안 각 고객에게 연락한 횟수가 정기예금 가입 여부에 영향을 미치고 있나요? 가입자 평균 2.05회 (미가입자 2.63회보다 적다)
SELECT y, ROUND(AVG(campaign), 2)
FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`
GROUP BY y

# (LMS 상 첫번째 분석 방법)
WITH ProcessedData AS(
  SELECT campaign,
        CASE WHEN y IS true THEN 1 ELSE 0 END AS enroll_indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`
)
SELECT campaign, ROUND(AVG(enroll_indicator)*100,2) AS enroll_rate
FROM ProcessedData
GROUP BY 1
ORDER BY 1 ASC;

# (LMS 상 두번째 분석 방법 : 캠페인수 구간화)
WITH ProcessedData AS(
  SELECT CASE WHEN campaign > 0 AND campaign <=5 THEN 'Group1'
              WHEN campaign > 5 AND campaign <= 10 THEN 'Group2'
              WHEN campaign > 10 AND campaign <= 15 THEN 'Group3'
              ELSE 'Group4'
         END AS campaign_group,
        CASE WHEN y IS true THEN 1 ELSE 0 END AS enroll_indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`
)
SELECT campaign_group, ROUND(AVG(enroll_indicator)*100,2) AS enroll_rate
FROM ProcessedData
GROUP BY 1
ORDER BY 1 ASC;

# 13. 나이를 10살 단위로 구간화하여 (예: 20대, 30대, 40대 등) 연령대별 가입률을 분석했을 때, 가장 높은 가입률을 보이는 연령대는 어디인가요?
-- 결과 : 10대에서 45.33%라는 가장 높은 가입률을 확인하였고, 이후 60대이상(39.56%), 20대(15.87%)로 나타났다.
SELECT
  CASE WHEN age < 20 THEN '10대'
       WHEN age BETWEEN 20 AND 29 THEN '20대'
       WHEN age BETWEEN 30 AND 39 THEN '30대'
       WHEN age BETWEEN 40 AND 49 THEN '40대'
       WHEN age BETWEEN 50 AND 59 THEN '50대'
       ELSE '60대이상'
  END AS age_group,
  COUNT(*) AS Total_customer,
  ROUND(AVG(CASE WHEN y IS true THEN 1 ELSE 0 END)*100,2) AS enroll_rate
FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`
GROUP BY age_group
ORDER BY enroll_rate DESC

# 14. 통화를 더 오래할 수록 고객의 가입률에 차이가 발생하는가? 통화시간을 구간화 하여 분석진행
-- 전체 통화시간그룹확인 : 1544그룹(0 - 1505s)
SELECT duration,
       ROUND(AVG(CASE WHEN y IS true THEN 1 ELSE 0 END)*100,2) AS enroll_rate
FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`
GROUP BY 1
ORDER BY 1 ASC

# 쿼리작성 : 1분 단위로 나누어 추세 확인 : 통화시간이 길어질 수록 가입율이 높아진다. 통화를 이어나갈 수 있는 것이 가입으로 연결된다.

SELECT
  CASE WHEN duration < 60 THEN 'under1min'
       WHEN duration >= 60 AND duration < 120 THEN 'under2min'
       WHEN duration >= 120 AND duration < 180 THEN 'under3min'
       WHEN duration >= 180 AND duration < 240 THEN 'under4min'
       WHEN duration >= 240 AND duration < 300 THEN 'under5min'
       ELSE 'Over5min'
  END AS duration_group,
  COUNT(*) AS Total_customer,
  ROUND(AVG(CASE WHEN y IS true THEN 1 ELSE 0 END)*100,2) AS enroll_rate
FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`
GROUP BY duration_group
ORDER BY enroll_rate DESC

# LMS 상 쿼리문 작성 : NTILE() 윈도우 함수 이용 - ()안의 숫자만큰 그룹화시키는 윈도우함수(OVER(공백 또는 그룹화 조건 기재))
WITH ProcessedData AS(
  SELECT duration, NTILE(4) OVER(ORDER BY duration) AS duration_group,
        CASE WHEN y IS true THEN 1 ELSE 0 END AS Indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY2.campaign`
)
SELECT duration_group, ROUND(AVG(Indicator)*100,2) AS enroll_rate
FROM ProcessedData
GROUP BY 1



