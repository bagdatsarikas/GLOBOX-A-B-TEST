-- Tables and columns information 

-- users table ( id, country, gender) 
	
-- groups table ( uid , group, join_dt, device )

-- activity table (uid, dt, device, spent)



-- TOTAL USERS IN DATASET 

SELECT 
		COUNT(DISTINCT id) 
FROM 
		users;


-- TOTAL USERS FOR EACH GROUP CONTROL(A) AND TEST(B) 


SELECT
		groups.group, 
		COUNT(uid) as total_users
FROM 
		groups 
GROUP BY 1;


-- CONVERTED AND NON CONVERTED TOTAL USERS 

SELECT
    (SELECT COUNT(DISTINCT id) FROM Users) as converted_user_count,
    (SELECT COUNT(DISTINCT id) FROM Users) -
    (SELECT COUNT(DISTINCT uid) FROM  Activity) AS not_converted_user_count;


-- CONVERSION PERCENTAGE PER USER 

SELECT 
			(COUNT(DISTINCT activity.uid)*100) / 
      (COUNT(DISTINCT users.id)) as conversian_rate_per_user
FROM 
			users
LEFT JOIN 
			activity ON users.id = activity.uid;
      

-- CONVERTED USERS PER GROUPS CONTRO(A)L AND TEST(B) 

SELECT 
		g.group,
    COUNT(DISTINCT uid) as total_converted_users
FROM groups as g 
WHERE g.uid in (
		   		select uid 
       		from activity 
      		where spent >0)
group by 1;



-- NOT CONVERTED USERS PER GROUPS CONTROL AND TEST 


SELECT 
		g.group,
    COUNT(DISTINCT uid) as total_converted_users
FROM
		groups as g 
WHERE g.uid NOT IN (
		   select uid 
       from activity)
group by 1;

-- CONVERSION RATE FOR PER  CONTROL(A) AND TEST(B) GROUP 



SELECT g.group, 
		(COUNT(DISTINCT CASE WHEN ac.spent>0 then g.uid end))*100/
    (COUNT(DISTINCT g.uid))
FROM groups as g
LEFT JOIN activity as ac
ON g.uid=ac.uid
GROUP BY  1;

-- AVERAGE AMOUNT SPENT PER USER FOR EACH GROUP 

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

-- join tables for further analysis 

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
