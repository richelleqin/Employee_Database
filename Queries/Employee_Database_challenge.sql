-- Join employees and titles tables on joining key emp_no 
SELECT e.*,
       t.*
FROM   PUBLIC.employees e
       LEFT JOIN PUBLIC.titles t
              ON e.emp_no = t.emp_no
ORDER  BY e.emp_no;

-- create a new table after joining with the date filter and order by emp_no
SELECT *
INTO   retirement_titles
FROM   (SELECT e.emp_no,
               e.first_name,
               e.last_name,
               t.title,
               t.from_date,
               t.to_date
        FROM   PUBLIC.employees e
               LEFT JOIN PUBLIC.titles t
                      ON e.emp_no = t.emp_no
        WHERE  Extract(year FROM e.birth_date) BETWEEN 1952 AND 1955
        ORDER  BY e.emp_no) a;

-- test to see the new table
SELECT *
FROM   PUBLIC.retirement_titles;

--  find unique record based on emp_no including only records with 'to_date = 9999-01-01'
SELECT DISTINCT ON (emp_no) emp_no,
                            first_name,
                            last_name,
                            title
FROM   PUBLIC.retirement_titles
WHERE  to_date = '9999-01-01'

-- create unique titles table
SELECT DISTINCT ON (emp_no) emp_no,
                            first_name,
                            last_name,
                            title
INTO   unique_titles
FROM   (SELECT DISTINCT ON (emp_no) emp_no,
                                    first_name,
                                    last_name,
                                    title
        FROM   PUBLIC.retirement_titles
        WHERE  to_date = '9999-01-01'
        ORDER  BY emp_no) b

-- test unique titles table 
SELECT *
FROM   unique_titles

-- to find num of employee for each category of title 
SELECT Count(*) AS count,
       title
FROM   PUBLIC.unique_titles
GROUP  BY title
ORDER  BY count DESC;

-- create a table that joins 3 tables and distinct on emp_no based on emp_no
SELECT *
INTO   mentorship_eligibility
FROM   (SELECT DISTINCT ON(e.emp_no) e.emp_no,
                                     e.birth_date,
                                     e.first_name,
                                     e.last_name,
                                     t.from_date,
                                     t.to_date,
                                     t.title
        FROM   employees e
               LEFT JOIN titles t
                      ON e.emp_no = t. emp_no
               LEFT JOIN PUBLIC.dept_emp d
                      ON e.emp_no = d. emp_no
        ORDER  BY e.emp_no,
                  t.from_date DESC) c;

-- filter data on current employees and birth date
SELECT emp_no,
       first_name,
       last_name,
       birth_date,
       from_date,
       to_date,
       title
FROM   PUBLIC.mentorship_eligibility
WHERE  ( to_date = '9999-01-01' )
       AND birth_date BETWEEN '1965-01-01' AND '1965-12-31'
ORDER  BY emp_no;

-- Summary
-- how many people have already reached the retirement age (65) but are still employing by this year?
-- & create a new table 
WITH cte
     AS (SELECT e.emp_no,
                e.birth_date,
                e.hire_date,
                t.title,
                t.from_date,
                t.to_date
         FROM   PUBLIC.employees e
                LEFT JOIN PUBLIC.titles t
                       ON e.emp_no = t.emp_no
         WHERE  t.to_date = '9999-01-01'
         ORDER  BY e.emp_no)
SELECT *
INTO   retirement_ready
FROM   (SELECT emp_no,
               title,
               birth_date,
               ( CASE
                   WHEN Extract(year FROM CURRENT_DATE) - Extract(
                        year FROM birth_date)
                        = 65
                        AND Extract(month FROM CURRENT_DATE) - Extract(
                            month FROM birth_date) <
                            0
                 THEN 64
                   WHEN Extract(year FROM CURRENT_DATE) - Extract(
                        year FROM birth_date)
                        = 65
                        AND Extract(month FROM CURRENT_DATE) - Extract(
                            month FROM birth_date) =
                            0
                        AND Extract(day FROM CURRENT_DATE) -
                            Extract(day FROM birth_date) < 0
                 THEN 64
                   ELSE Extract(year FROM CURRENT_DATE) - Extract(
                        year FROM birth_date)
                 END ) age
        FROM   cte) h

SELECT *
FROM   PUBLIC.retirement_ready

-- based on the new table  sum the number of retirement_ready employees
SELECT Count(*)
FROM   PUBLIC.retirement_ready
WHERE  age >= 65

-- are there enough qualified, retirement_ready employees to train new generation?
SELECT Count (*)
FROM   PUBLIC.retirement_ready
WHERE  title LIKE 'Senior%'
       AND age >= 65 