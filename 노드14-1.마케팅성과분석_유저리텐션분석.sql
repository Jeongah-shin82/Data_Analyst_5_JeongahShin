# 유저 리텐션 분석
-- 테이블 불러오기
SELECT *
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
LIMIT 1000

# 1. 전체 고객 수는 몇명인가요? 440,832명
SELECT COUNT(CustomerID) AS CostomerCount
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`

# 2. 전체 고객 중 이탈한 고객(Churn=1)의 비율은? 56.71%
SELECT round(AVG(Churn)*100,2) AS ChurnRate
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`

# 3. 고객들의 평균 나이 : 39.37세
SELECT round(AVG(Age),2) AS Average_Age
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`

# 4. 구독 상품(Subscription)별 고객수 : Primium 148,678명 / Basic 143,026명, / Standard 149,128명
-- 빅쿼리상 띄어쓰기는 각 다른 명령어로 인식 : 백틱(``)을 이용하여 해결
SELECT `Subscription Type`, COUNT(CustomerID) AS CustomerCount_by_Subscription
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
GROUP BY `Subscription Type`

# 5. 계약 기간(Contract Length) 별 고객수, 특정 트렌드 확인 가능여부 : 연간 177,198 / 분기별 176,530 / 월간 87,104
-- 대부분 분기별 또는 연간 계약을 진행하고 있으며, 월간고객은 19.76% 이다.
SELECT `Contract Length`, COUNT(CustomerID) AS CustomerCount_by_ContractLength
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
GROUP BY `Contract Length`

# 6. 성별(Gender) 비율 : 남성 56.77%, 여성 43.23%
# 쿼리 계산방법 : CASE WHEN을 이용한 Gender지표 설정 후 비율 계산
SELECT ROUND(AVG(man_indicator)*100,2) AS MaleRate,
       ROUND(AVG(female_indicator)*100,2) AS FemaleRate
FROM(
  SELECT CASE WHEN Gender LIKE 'Male' THEN 1 ELSE 0 END AS man_indicator,
         CASE WHEN Gender LIKE 'Female' THEN 1 ELSE 0 END AS female_indicator
  FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`)

# 7. 성별(Gender)에 따른 이탈비율 : 남성고객 이탈비율 49.18%, 여성고객 이탈비율 50.82%
# 쿼리 계산방법
-- 1) CASE WHEN 을 이용하여 성별 indicator 생성
-- 2) Churn=1인 조건하에서 각 성별 비율 확인
SELECT ROUND(AVG(man_indicator)*100,2) AS ManRate,
       ROUND(AVG(female_indicator)*100,2) AS FemaleRate
FROM(
  SELECT CASE WHEN Gender LIKE 'Male' THEN 1 ELSE 0 END AS man_indicator,
         CASE WHEN Gender LIKE 'Female' THEN 1 ELSE 0 END AS female_indicator,
         Churn
  FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`)
WHERE Churn=1;

# 8. 구독 유형별 이탈율 : 프리미엄 55.94% / 베이직 58.18% / 스탠다드 56.07% 
--> 베이직 구독자의 경우, 가장 높은 58.18% 이탈율을 보이지만, 전반적으로 구독 유형과 무관하게 유사한 이탈율을 보임
# 쿼리 계산방법 : 구독 유형을 그룹화하여, Churn 비율(Churn컬럼의 경우, 0과 1로 구성되어 있기 때문에 그룹의 평균이 비율와 같다) 산출
SELECT `Subscription Type`,ROUND(AVG(Churn)*100,2)  
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
GROUP BY `Subscription Type`

# 9. 계약기간 별 이탈율 : 월 구독자 100% / 분기별 구독 46.03% / 연간구독 46.08% -> 월 구독자의 경우, 이탈율이 100%이다.
# 쿼리 계산방법 : 계약기간을 그룹화하여 Churn의 비율 산출 (위 쿼리문에서 그룹화하는 대상만 변경)
SELECT `Contract Length`,ROUND(AVG(Churn)*100,2)  
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
GROUP BY `Contract Length`

# 10. 고객센터 문의가 많은 순으로 상위 10명의 이탈 여부 확인 : 10명 모두 이탈
# 쿼리계산방법 : 고객센터 문의수로 내림차수 정렬진행
SELECT CustomerID, `Support Calls`, Churn
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
ORDER BY `Support Calls` DESC
LIMIT 10;

# 11. 이탈 여부에 따른 평균 고객센터 문의 횟수 : 이탈한 경우, 평균 5.14회 / 유지 고객의 경우, 1.59회
# 쿼리계산방법 : 이탈여부를 구분하기 위해 Churn 컬럼을 GROUP화 하고, 고객센터 문의횟수 평균 계산진행
SELECT CHurn,ROUND(AVG(`Support Calls`),2)
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
GROUP BY Churn

# 12. 서비스 평균 사용빈도 10 이하인 고객의 이탈율 : 60.64%
# 쿼리 계산방법  : CASE WHEN 서비스평균 사용빈도 10이하인 고객을 필터링한 후, 고객 이탈율 계산
SELECT ROUND(AVG(Churn)*100,2) AS UserFrequencyBelow10ChurnRate
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
Where `Usage Frequency`<=10

# 13. 이탈 여부에 따른 평균 사용빈도 : 이탈 15.46%/ 유지 16.26%
SELECT Churn, ROUND(AVG(`Usage Frequency`),2)
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
GROUP BY Churn

# 14. 지불 지연이 평균 이상인 고객의 이탈율 : 66.92%
# 쿼리 계산방법 : 지불지연의 평균 확인 -> 해당 기준 고객 이탈율 계산
# 주의사항 : WHERE 절에는 AVG가 포함될 수 없음 -> 서브쿼리 이용
SELECT ROUND(AVG(Churn)*100,2)
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
WHERE `Payment Delay`>= (SELECT AVG(`Payment Delay`) FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`)

# 15. 총 지불금액(Total Spend)이 하위 25% 해당 고객 이탈율 : 100%
# 쿼리계산방법 : 총 지불금액 하위 25% 계산 후 이탈율 계산
# PERCENTILE_CONT 함수이용하여 구간별 평균 계산방법 이용
SELECT ROUND(AVG(Churn)*100,2)
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
WHERE `Total Spend`<=(
  SELECT DISTINCT PERCENTILE_CONT(`Total Spend`,0.25) OVER() AS Spend25
  FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
  )

# 16. 총 지불금액(Total Spend)이 상위 25% 해당 고객 이탈율 : 41.13%
# 쿼리계산방법 : 총 지불금액 상위 25%(하위 75%) 계산 후 이탈율 계산
# PERCENTILE_CONT 함수이용하여 구간별 평균 계산방법 이용
SELECT ROUND(AVG(Churn)*100,2)
FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
WHERE `Total Spend`>=(
  SELECT DISTINCT PERCENTILE_CONT(`Total Spend`,0.75) OVER() AS Spend75
  FROM `project-5faeab26-b699-4f50-a43.DAY2.churn`
  )