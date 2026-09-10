/*    campaign with the highest number of impressions, clicks and conversions  */


SELECT campaign, SUM(impressions) AS total_impressions
FROM marketing_data
GROUP BY campaign
ORDER BY total_impressions DESC
LIMIT 3;

SELECT campaign, SUM(clicks) AS total_clicks
FROM marketing_data
GROUP BY campaign
ORDER BY total_clicks DESC
LIMIT 3;

SELECT campaign, SUM(marketing_data.coversions) AS total_conversions
FROM marketing_data
GROUP BY campaign
ORDER BY total_conversions DESC
LIMIT 3;

/* Average cost-per-click (CPC) and click-through rate (CTR) for each campaign  */

SELECT campaign,
       ROUND(AVG(daily_average_cpc)::numeric, 3) AS avg_cpc,
       ROUND(AVG(ctr)::numeric, 3) AS avg_ctr
FROM marketing_data
GROUP BY campaign
ORDER BY avg_ctr DESC;



/*          channel has the highest ROI?        */
SELECT 
    channel,
    SUM("total_conversion_value_(gbp)") AS total_revenue,
    SUM("spend_(gbp)") AS total_spend,
    ROUND(
        (
            (SUM("total_conversion_value_(gbp)") - SUM("spend_(gbp)")) 
            / NULLIF(SUM("spend_(gbp)"), 0)
        )::numeric,
        2
    ) AS roi
FROM 
    marketing_data
GROUP BY 
    channel
ORDER BY 
    roi;


/*    How impressions, clicks, and conversions vary across different channels?    */
SELECT 
    channel,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(marketing_data.coversions) AS total_conversions
FROM 
    marketing_data
GROUP BY 
    channel
ORDER BY 
    total_impressions DESC;



/*    cities with the highest engagement rates (likes, shares, comments)     */
SELECT 
    city,
    SUM(likes) AS total_likes,
    SUM(shares) AS total_shares,
    SUM(comments) AS total_comments,
    SUM(impressions) AS total_impressions,
    ROUND(
        (
            (SUM(likes) + SUM(shares) + SUM(comments)) 
            / NULLIF(SUM(impressions), 0)
        )::NUMERIC,
        4
    ) AS engagement_rate
FROM 
    marketing_data
GROUP BY 
    city
ORDER BY 
    engagement_rate DESC
LIMIT 10;


/*    What is the conversion rate by city?     */
SELECT 
    city,
    SUM(clicks) AS total_clicks,
    SUM(marketing_data.coversions) AS total_conversions,
    ROUND(
        SUM(marketing_data.coversions)::NUMERIC / NULLIF(SUM(clicks), 0),
        4
    ) AS conversion_rate
FROM 
    marketing_data
GROUP BY 
    city
ORDER BY 
    conversion_rate DESC;

/*   ad performances across different devices (mobile, desktop)     */
SELECT 
    device,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    ROUND(
        (SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0)::NUMERIC),
        4
    ) AS ctr,
    SUM(marketing_data.coversions) AS total_conversions,
    ROUND(
        (SUM(marketing_data.coversions)::NUMERIC / NULLIF(SUM(clicks), 0)::NUMERIC),
        4
    ) AS conversion_rate,
    SUM("spend_(gbp)") AS total_spend,
    SUM("total_conversion_value_(gbp)") AS total_revenue,
    ROUND(
        (
            (SUM("total_conversion_value_(gbp)") - SUM("spend_(gbp)"))::NUMERIC 
            / NULLIF(SUM("spend_(gbp)"), 0)::NUMERIC
        ),
        4
    ) AS roi
FROM 
    marketing_data
GROUP BY 
    device
ORDER BY 
    roi DESC;


/* Which device type generates the highest conversion rates? */
SELECT 
    device,
    SUM(clicks) AS total_clicks,
    SUM(marketing_data.coversions) AS total_conversions,
    ROUND(
        SUM(marketing_data.coversions)::NUMERIC / NULLIF(SUM(clicks), 0),
        4
    ) AS conversion_rate
FROM 
    marketing_data
GROUP BY 
    device
ORDER BY 
    conversion_rate DESC
LIMIT 2;

5. Ad-Level Analysis:
/* Which specific ads are performing best in terms of engagement and conversions? */

SELECT 
    ad,
    SUM(likes) AS total_likes,
    SUM(shares) AS total_shares,
    SUM(comments) AS total_comments,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(marketing_data.coversions) AS total_conversions,
    ROUND(
        (
            (SUM(likes) + SUM(shares) + SUM(comments)) 
            / NULLIF(SUM(impressions), 0)
        )::NUMERIC,
        4
    ) AS engagement_rate,
    ROUND(
        (
            SUM(marketing_data.coversions) 
            / NULLIF(SUM(clicks), 0)
        )::NUMERIC,
        4
    ) AS conversion_rate
FROM 
    marketing_data
GROUP BY 
    ad
ORDER BY 
    total_conversions DESC, engagement_rate DESC
LIMIT 10;



/* What are the common characteristics of high-performing ads? */

WITH ad_performance AS (
    SELECT 
        ad,
        channel,
        device,
        city,
        SUM(clicks) AS total_clicks,
        SUM(marketing_data.coversions) AS total_conversions,
        ROUND(
            (
                SUM(marketing_data.coversions) / NULLIF(SUM(clicks), 0)
            )::NUMERIC,
            4
        ) AS conversion_rate,
        ROUND(
            (
                (SUM(likes) + SUM(shares) + SUM(comments)) 
                / NULLIF(SUM(impressions), 0)
            )::NUMERIC,
            4
        ) AS engagement_rate
    FROM marketing_data
    GROUP BY ad, channel, device, city
),
top_ads AS (
    SELECT * FROM ad_performance
    WHERE conversion_rate >= (
        SELECT PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY conversion_rate)
        FROM ad_performance
    )
)
SELECT 
    channel,
    device,
    city,
    COUNT(*) AS high_performing_ads
FROM top_ads
GROUP BY channel, device, city
ORDER BY high_performing_ads DESC;










6. ROI Calculation:
/* What is the ROI for each campaign, and how does it compare across different channels and devices? */

SELECT 
    campaign,
    channel,
    device,
    SUM("total_conversion_value_(gbp)") AS total_revenue,
    SUM("spend_(gbp)") AS total_spend,
    ROUND(
        CAST(
            (SUM("total_conversion_value_(gbp)") - SUM("spend_(gbp)")) 
            / NULLIF(SUM("spend_(gbp)"), 0) 
            AS NUMERIC
        ),
        4
    ) AS roi
FROM 
    marketing_data
GROUP BY 
    campaign, channel, device
ORDER BY 
    roi DESC;


/* How does spend correlate with conversion value across different campaigns? */
Summary Table: Spend vs. Conversion Value by Campaign

SELECT 
    campaign,
    SUM("spend_(gbp)") AS total_spend,
    SUM("total_conversion_value_(gbp)") AS total_conversion_value
FROM 
    marketing_data
GROUP BY 
    campaign
ORDER BY 
    total_spend DESC;


7. Time Series Analysis:
a) Are there any noticeable trends or seasonal effects in ad performance over time? 

SELECT 
    date_trunc('week', date) AS week_start,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(marketing_data.coversions) AS total_conversions,
    SUM("spend_(gbp)") AS total_spend,

    ROUND(
        (SUM(marketing_data.coversions) / NULLIF(SUM(clicks), 0))::NUMERIC,
        4
    ) AS conversion_rate,

    ROUND(
        (SUM(clicks) / NULLIF(SUM(impressions), 0))::NUMERIC,
        4
    ) AS ctr,

    ROUND(
        (
            (SUM("total_conversion_value_(gbp)") - SUM("spend_(gbp)")) 
            / NULLIF(SUM("spend_(gbp)"), 0)
        )::NUMERIC,
        4
    ) AS roi

FROM 
    marketing_data
GROUP BY 
    week_start
ORDER BY 
    week_start;
