USE app;

-- Total completed trips
-- checking if any duplicate tripid is present
SELECT 
	tripid,
    COUNT(tripid) AS cnt
FROM trips_details4
GROUP BY tripid
HAVING COUNT(tripid)>1;    -- No duplicate tripids in trip_details4

SELECT 
	COUNT(DISTINCT tripid) AS Total_trips
FROM trips_details4
WHERE end_ride=1;      -- Total successful trips on 1st July is 983




-- Total no of drivers
SELECT
    COUNT(DISTINCT driverid) AS Total_drivers
FROM trips;       -- Total no of drivers completing trips on 1st July is 30




-- Total Driver Earnings
-- checking if any duplicate tripid is present
SELECT
	tripid,
	COUNT(tripid)
FROM trips
GROUP BY tripid
HAVING COUNT(tripid)>1;       -- No duplicate tripids in trips

SELECT 
	SUM(fare) AS Total_earnings
FROM trips;                   -- Total Drivers' Earnings is 7,51,343




-- Total no of searches 
SELECT
	COUNT(searches) Total_searches
FROM trips_details4
WHERE searches=1;                    -- Total searches is 2161

-- Total no of searches which got estimated
SELECT
	COUNT(searches_got_estimate) AS Estimated_searches
FROM trips_details4
WHERE searches_got_estimate=1;       -- Total searches which got estimated for fare searches is 1758

-- Total no of searches which got quoted after seeing fare price
SELECT
	COUNT(searches_for_quotes) AS Estimated_searches
FROM trips_details4
WHERE searches_for_quotes=1;         -- Total searches which got quoted after seeing the fare price is 1455

-- Total no of searches which got a driver
SELECT
	COUNT(searches_got_quotes) AS Estimated_searches_assigned_driver
FROM trips_details4
WHERE searches_got_quotes=1;         -- Total searches which got a driver after the search was quoted is 1277

-- Total driver cancelled trips
SELECT 
	COUNT(driver_not_cancelled) Driver_cancelled_trips
FROM trips_details4
WHERE driver_not_cancelled=0;        -- Total no of trips cancelled by drivers is 1021

-- Total Customer cancelled trips
SELECT 
	COUNT(customer_not_cancelled) Customer_cancelled_trips
FROM trips_details4
WHERE customer_not_cancelled=0;      -- Total no of trips cancelled by customers is 1041

-- Total otp entered by driver
SELECT 
	COUNT(otp_entered) Otp_entered_trips
FROM trips_details4
WHERE otp_entered=1;                 -- Total no of trips with otp entered is 983

-- Total end ride or completed trips
SELECT 	
	COUNT(end_ride) Completed_trips
FROM trips_details4
WHERE end_ride=1;                    -- Total no of end-ride or completed trips is 983




-- Average distance per trip
SELECT 
	ROUND(AVG(distance),2) AS Avg_distance
FROM trips;                          -- Average distance per trip is 14.39 km




-- Average fare per trip
SELECT
	ROUND(AVG(fare),2) Avg_fare
FROM trips;                          -- Average fare per trip is 764.34 rupees 




-- Total distance travelled
SELECT 
	SUM(distance) Total_distance
FROM trips;                          -- Total distance travelled is 14,148 km




-- Most used payment method
SELECT 
	t.faremethod faremethod_id,
    p.method,
	COUNT(DISTINCT t.tripid) Max_Cnt
FROM trips t INNER JOIN
payment p ON t.faremethod=p.id
GROUP BY t.faremethod,p.method
ORDER BY COUNT(t.faremethod) DESC LIMIT 1;    -- Most used payment method is credit card with count 262




-- Highest payment was made through which instrument
SELECT 
	t.faremethod faremethod_id,
    p.method,
	MAX(t.fare) Max_fare
FROM trips t INNER JOIN
payment p ON t.faremethod=p.id
GROUP BY t.faremethod,p.method
ORDER BY MAX(t.fare) DESC LIMIT 2;     -- Highest payment method was through credit card and cash each of amount 1500 rupees

SELECT 
	t.faremethod faremethod_id,
    p.method,
	SUM(t.fare) Total_fare
FROM trips t INNER JOIN
payment p ON t.faremethod=p.id
GROUP BY t.faremethod,p.method
ORDER BY SUM(t.fare) DESC LIMIT 1;      -- Highest total sum of payments among all methods is credit card with amount of 1,97,941 rupees
 
 
 

-- Which two locations had the most trips
SELECT
	*
FROM (SELECT
	*,
    DENSE_RANK() OVER (ORDER BY trips_cnt DESC) rnk
FROM (SELECT
	t.loc_from,
    t.loc_to,
    COUNT(DISTINCT t.tripid) as trips_cnt
FROM trips t 
GROUP BY t.loc_from,t.loc_to
ORDER BY COUNT(DISTINCT t.tripid) DESC) t) u
WHERE rnk=1;                                    -- Here we can see 16 to 21 and 35 to 5 have the most number of trips each equal to 5
-- Here we had to use dense_rank() since there can be multiple 2 locations with the same no of trips. This makes the query dynamic.




-- Top 5 earning drivers
SELECT
	*
FROM (SELECT 
	*,
    DENSE_RANK() OVER (ORDER BY total_earnings DESC) rnk
FROM (SELECT
	driverid,
    SUM(fare) total_earnings
FROM trips
GROUP BY driverid) t) u
WHERE rnk IN (1,2,3,4,5);                 -- Top 5 earning driverids are 12,8,21,24,30
-- Here we had to use dense_rank() since there can be multiple drivers with the same income. This makes the query dynamic.




-- Which duration had more trips
SELECT 
	*
FROM (SELECT 
	*,
    DENSE_RANK() OVER (ORDER BY trips_cnt DESC) rnk
FROM (SELECT 
	duration, 
    COUNT(DISTINCT tripid) trips_cnt
FROM trips 
GROUP BY duration) t) u
WHERE rnk<=1;                               -- The duration 1 had the most no of trips
-- Here we had to use dense_rank() since there can be multiple duration with the same number of trips. This makes the query dynamic.




-- Which driver, customer pair had more orders
SELECT 
	*
FROM (SELECT
	*,
    DENSE_RANK() OVER (ORDER BY trips_cnt DESC) rnk
FROM (SELECT 
	driverid,
    custid,
    COUNT(DISTINCT tripid) trips_cnt
FROM trips
GROUP BY driverid,custid) t) u
WHERE rnk=1;                                -- The (17,96) and (28,15), driverid,custid pair had the most no of orders
-- Here we had to use dense_rank() since there can be multiple pairs with the same number of trips. This makes the query dynamic. 




-- Search to estimate rate
SELECT 
	CONCAT(ROUND((((SUM(searches_got_estimate)*1.0)/SUM(searches))*100),2),'%') Estimate_rate_percent 
FROM trips_details4;                         -- 81.35% searches of the total searches have got their searches estimated





-- Estimate to search for quote rates
SELECT 
	CONCAT(ROUND((((SUM(searches_for_quotes)*1.0)/SUM(searches_got_estimate))*100),2),'%') Price_shown_rate_percent 
FROM trips_details4;          -- 82.76% searches of the searches which got estimated have got their searches quoted after seeing the tripfare




-- Quote acceptance rate
SELECT 
	CONCAT(ROUND((((SUM(searches_got_quotes)*1.0)/SUM(searches_for_quotes))*100),2),'%') Alloted_driver_rate_percent 
FROM trips_details4;         -- 87.77% searches of the searches which got quoted have got their searches alloted a driver




-- Booking Cancellation rate
SELECT 
	CONCAT(ROUND((((COUNT(*)-SUM(customer_not_cancelled)*1.0)/SUM(searches_got_quotes))*100),2),'%') Booking_cancellation_rate 
FROM trips_details4;          -- 81.52% searches among the searches which got quoted got their booking cancelled by customers




-- Conversion rate
SELECT
	CONCAT(ROUND((((SUM(end_ride)*1.0)/SUM(searches))*100),2),'%') Conversion_rate 
FROM trips_details4;          -- 45.49% searches of the total searches actually completed the ride




-- Which area got highest trips in which duration
SELECT
	loc_from,
    assembly1,
    duration,
    trips_cnt,
    rnk
FROM (SELECT 
	*,
    DENSE_RANK() OVER (PARTITION BY duration ORDER BY trips_cnt DESC) rnk
FROM (SELECT 
	loc_from,
    duration,
	COUNT(DISTINCT tripid) trips_cnt
FROM trips
GROUP BY loc_from,duration) t) u
INNER JOIN loc ON loc_from=id
WHERE rnk=1
ORDER BY duration;
-- Here we were to find in each duration which area got the highest no of trips

SELECT
	loc_from,
    assembly1,
    duration,
    trips_cnt,
    rnk
FROM (SELECT 
	*,
    DENSE_RANK() OVER (PARTITION BY loc_from ORDER BY trips_cnt DESC) rnk
FROM (SELECT 
	loc_from,
    duration,
	COUNT(DISTINCT tripid) trips_cnt
FROM trips
GROUP BY loc_from,duration) t) u
INNER JOIN loc ON loc_from=id
WHERE rnk=1
ORDER BY loc_from;
-- Here we were to find in each area what was the duration for the highest no of trips




-- Which area got the highest fares, cancellations trips
SELECT
	*
FROM (SELECT
	*,
    DENSE_RANK() OVER (ORDER BY Total_fare DESC) rnk
FROM (SELECT
	loc_from,
    SUM(fare) Total_fare
FROM trips
GROUP BY loc_from) t) u
WHERE rnk=1;                    -- 6 is the area with the highest fares


SELECT
	*
FROM (SELECT
	*,
    DENSE_RANK() OVER (ORDER BY Customer_cancellations DESC) rnk
FROM (SELECT
	loc_from,
    COUNT(*)-SUM(customer_not_cancelled) Customer_cancellations
FROM trips_details4
GROUP BY loc_from) t) u
WHERE rnk=1;                    -- 4 is the area with the highest customer cancellations


SELECT
	*
FROM (SELECT
	*,
    DENSE_RANK() OVER (ORDER BY Driver_cancellations DESC) rnk
FROM (SELECT
	loc_from,
    COUNT(*)-SUM(driver_not_cancelled) Driver_cancellations
FROM trips_details4
GROUP BY loc_from) t) u
WHERE rnk=1;                           -- 1 is the area with the highest driver cancellations




-- Which duration got the highest trips and fares
SELECT 
	*
FROM (SELECT 
	*,
	DENSE_RANK() OVER (ORDER BY Total_fares DESC) rnk
FROM (SELECT
	duration,
    SUM(fare) Total_fares
FROM trips
GROUP BY duration) t) u
WHERE rnk=1;                      -- Duration 1 had the highest fares


SELECT 
	*
FROM (SELECT 
	*,
	DENSE_RANK() OVER (ORDER BY Total_trips DESC) rnk
FROM (SELECT
	duration,
    COUNT(*) Total_trips
FROM trips
GROUP BY duration) t) u
WHERE rnk=1;                     -- Duration 1 had the highest no of trips


