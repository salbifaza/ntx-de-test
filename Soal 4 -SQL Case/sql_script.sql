/*
Created by Salbi Faza Rinaldi

Familiarize column
1. channelGrouping: The channel or source through which the user accessed the website or made a visit, such as "Organic Search," "Paid Search," "Direct," etc.
2. country: The country from which the visitor or customer is accessing the website.
3. fullVisitorId: A unique identifier for the visitor or customer. It typically represents a single user.
4. timeOnSite: The total time the visitor spent on the website during a session, typically measured in seconds.
5. pageviews: The number of pages viewed by the visitor during their visit.
6. sessionQualityDim: A dimension or score indicating the quality or engagement level of the session.
7. v2ProductName: The name or description of a product or service.
8. productRevenue: The revenue generated from the sale of a product or service.
9. productQuantity: The quantity of a product or service purchased.
10. productRefundAmount: The amount refunded for a product or service.


Data Quality Issues
1. productRevenue is always null even though there are people who buy the product, seen from product quantity that is not null and product price that is not 0.
2. productRefundAmount is always null which assumes that no product is returned.
3. sessionQualityDim mostly have null values
4. there are some typos in v2productname like it should be Waterproof Gear Bag but written as Waterpoof Gear Bag.

Insight
1. the country that generates the most revenue is the United States with a channel source that comes from referrals. even though the United States has more organic search than referrals so there needs to be organic search channel optimization to generate revenue.
2. Not all items that make high money are purchased in great quantities; for example, the Waterpoof Gear Bag managed to rank third despite a little purchase. so We can create a strategy may be established for selling products like this so that more items are sold. 
**/

-- Create Table 

CREATE TABLE IF NOT EXISTS public.ecommerce_session_bigquery (
	fullvisitorid varchar(50) NULL,
	channelgrouping varchar(50) NULL,
	"time" int8 NULL,
	country varchar(50) NULL,
	city varchar(50) NULL,
	totaltransactionrevenue float8 NULL,
	transactions int4 NULL,
	timeonsite int8 NULL,
	pageviews int4 NULL,
	sessionqualitydim int4 NULL,
	"date" varchar(100) NULL,
	visitid int4 NULL,
	"type" varchar(50) NULL,
	productrefundamount float8 NULL,
	productquantity int4 NULL,
	productprice int4 NULL,
	productrevenue float8 NULL,
	productsku varchar(50) NULL,
	v2productname varchar(64) NULL,
	v2productcategory varchar(50) NULL,
	productvariant varchar(50) NULL,
	currencycode varchar(50) NULL,
	itemquantity varchar(50) NULL,
	itemrevenue varchar(50) NULL,
	transactionrevenue float8 NULL,
	transactionid varchar(50) NULL,
	pagetitle varchar(50) NULL,
	searchkeyword varchar(50) NULL,
	pagepathlevel1 varchar(50) NULL,
	ecommerceaction_type int4 NULL,
	ecommerceaction_step int4 NULL,
	ecommerceaction_option varchar(50) NULL
);

--Test Case 1: Channel Analysis
SELECT
    channelGrouping,
    country,
    SUM(COALESCE(totaltransactionrevenue,0)) AS totalRevenue
FROM
    ecommerce_session_bigquery esb
GROUP BY
    channelGrouping, country
ORDER BY
    totalRevenue DESC
LIMIT 5;


-- Test Case 2: User Behavior Analysis
WITH AvgMetrics AS (
    SELECT
        fullVisitorId,
        ROUND(AVG(COALESCE(timeOnSite,0)),2) AS avgTimeOnSite,
        ROUND(AVG(COALESCE(pageviews,0)),2) AS avgPageviews,
        ROUND(AVG(COALESCE(sessionQualityDim,0)),3) AS avgSessionQualityDim
    FROM
        ecommerce_session_bigquery esb
    GROUP BY
        fullVisitorId
)
SELECT
    t.fullVisitorId,
    t.timeOnSite,
    t.pageviews,
    COALESCE(t.sessionQualityDim,0) AS sessionQualityDim,
    am.avgTimeOnSite AS avgTimeOnSiteForUser,
    am.avgPageviews AS avgPageviewsForUser,
    am.avgSessionQualityDim AS avgSessionQualityDimForUser
FROM
    ecommerce_session_bigquery t
JOIN
    AvgMetrics am ON t.fullVisitorId = am.fullVisitorId
WHERE
    t.timeOnSite > am.avgTimeOnSite AND
    t.pageviews < am.avgPageviews
   ;

--Test Case 3: Product Performance
WITH ProductMetrics AS (
    SELECT
        TRIM(v2ProductName) AS productname,
        SUM(COALESCE(productquantity ,0) * COALESCE(productprice ,0)) AS totalRevenue,
        SUM(COALESCE(productQuantity,0)) AS totalQuantitySold,
        SUM(COALESCE(productRefundAmount,0)) AS totalRefundAmount
    FROM
        ecommerce_session_bigquery
    GROUP BY
        v2ProductName
)
SELECT
    pm.productname,
    pm.totalRevenue,
    pm.totalQuantitySold,
    pm.totalRefundAmount,
    pm.totalRevenue - pm.totalRefundAmount AS netRevenue,
    RANK() OVER(ORDER BY pm.totalRevenue - pm.totalRefundAmount DESC ) AS rank,
    CASE
        WHEN pm.totalRefundAmount > 0.1 * pm.totalRevenue THEN 'High Refund'
        ELSE 'Normal'
    END AS refundFlag
FROM
    ProductMetrics pm
ORDER BY
    netRevenue DESC;  
   
-- Additional for checking visitorid by country and channel
  SELECT
    channelGrouping,
    country,
    COUNT(DISTINCT fullvisitorid) AS totalRevenue
FROM
    ecommerce_session_bigquery esb
GROUP BY
    channelGrouping, country
ORDER BY
    3 DESC
;
