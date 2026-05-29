-- Query 1: Funnel Stage Drop-off
SELECT
  event_name,
  COUNT(DISTINCT user_pseudo_id) AS users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name IN ('session_start','view_item','add_to_cart','begin_checkout','purchase')
GROUP BY event_name
ORDER BY users DESC

-- Query 2: CVR by Traffic Source
SELECT
  traffic_source.source,
  traffic_source.medium,
  COUNT(DISTINCT user_pseudo_id) AS total_users,
  COUNTIF(event_name = 'purchase') AS purchases,
  ROUND(COUNTIF(event_name = 'purchase') / COUNT(DISTINCT user_pseudo_id) * 100, 2) AS cvr_pct
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY 1, 2
HAVING total_users > 100
ORDER BY cvr_pct DESC

-- Query 3: Revenue by Device
SELECT
  device.category AS device,
  COUNT(DISTINCT user_pseudo_id) AS users,
  ROUND(SUM((SELECT value.double_value FROM UNNEST(event_params) WHERE key = 'value')), 2) AS total_revenue
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name = 'purchase'
GROUP BY device
ORDER BY total_revenue DESC

-- Query 4: Daily Sessions & Purchases
SELECT
  PARSE_DATE('%Y%m%d', event_date) AS date,
  COUNTIF(event_name = 'session_start') AS sessions,
  COUNTIF(event_name = 'purchase') AS purchases
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY date
ORDER BY date
