-------------- GLOBOX ONLINE MARKETPLACE A/B TESTING --------------

/* 

The aim of this SQL script is to analyze user engagement and effectiveness
of group-based A/B testing within GLOBOX. 

By querying data from the
- users
- groups
- activity tables   
this script intends to uncover insights into total user counts, conversion rates, and 
spending patterns across different test groups (Control(A) and Test(B)). 

*/


-- Count the total number of unique users in the dataset

SELECT 
		COUNT(DISTINCT id) 
FROM 
		users;


-- Count the total users in each group (Control(A) and Test(B)).


SELECT
		groups.group, 
		COUNT(uid) as total_users
FROM 
		groups 
GROUP BY 1;


-- Calculate the number of converted and non-converted users.

SELECT
    (SELECT COUNT(DISTINCT id) FROM Users) as converted_user_count,
    (SELECT COUNT(DISTINCT id) FROM Users) -
    (SELECT COUNT(DISTINCT uid) FROM  Activity) AS not_converted_user_count;


-- Calculate the conversion rate per user 

SELECT 
			(COUNT(DISTINCT activity.uid)*100) / 
      (COUNT(DISTINCT users.id)) as conversian_rate_per_user
FROM 
			users
LEFT JOIN 
			activity ON users.id = activity.uid;
      

-- Calculate the number of converted users per group 

SELECT 
		g.group,
    COUNT(DISTINCT uid) as total_converted_users
FROM groups as g 
WHERE g.uid in (
		   		select uid 
       		from activity 
      		where spent >0)
group by 1;



-- Calculate the number of non-converted users per group


SELECT 
		g.group,
    COUNT(DISTINCT uid) as total_converted_users
FROM
		groups as g 
WHERE g.uid NOT IN (
		   select uid 
       from activity)
group by 1;

-- Calculate the conversion rate for each group.



SELECT g.group, 
		(COUNT(DISTINCT CASE WHEN ac.spent>0 then g.uid end))*100/
    (COUNT(DISTINCT g.uid))
FROM groups as g
LEFT JOIN activity as ac
ON g.uid=ac.uid
GROUP BY  1;

-- Calculate the average amount spent per user for each group.

WITH amount_spent AS(
  SELECT uid,
  COALESCE(SUM(spent),0) as total_spent
  FROM activity
  GROUP BY 1
)

SELECT 
		g.group, 
    avg(coalesce((total_spent),0)) as avg_spent_per_user,
    sum(total_spent) as total_spent_per_group
    
FROM groups as g
LEFT JOIN 
		amount_spent
		ON amount_spent.uid = g.uid
group by 1;

-- Join tables for further analysis, combining user, group, and activity data


SELECT
    u.id AS user_id,
    u.country,
    u.gender,
    g.group AS ab_groups,
    g.join_dt as join_date,
    g.device AS device,
    a.dt AS purchase_date,
   
    COALESCE(a.spent, 0) AS spent_amount
FROM
    users as u
LEFT JOIN
    groups g ON u.id = g.uid
LEFT JOIN
    activity a ON u.id = a.uid;









