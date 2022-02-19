-- Join employees and titles tables on joining key emp_no 
select e.*, t.*
from public.employees e left join public.titles t on e.emp_no = t.emp_no
order by e.emp_no; 

-- create a new table after joining with the date filter and order by emp_no
select * into retirement_titles
from (
select e.emp_no, e.first_name, e.last_name, t.title, t.from_date, t.to_date
from public.employees e left join public.titles t on e.emp_no = t.emp_no
where extract(year from e.birth_date) between 1952 and 1955
order by e.emp_no
	) a; 

-- test to see the new table
 select * from public.retirement_titles; 

--  find unique record based on emp_no including only records with 'to_date = 9999-01-01'

select distinct on (emp_no) emp_no, first_name, last_name, title
from public.retirement_titles
where to_date = '9999-01-01'

-- create unique titles table

SELECT DISTINCT ON (emp_no) emp_no, first_name, last_name, title
INTO unique_titles
FROM 
(
select distinct on (emp_no) emp_no, first_name, last_name, title
from public.retirement_titles
where to_date = '9999-01-01'
order by emp_no
	) b
	
-- test unique titles table 
select * from unique_titles

-- to find num of employee for each category of title 
select count(*) as count, title 
from public.unique_titles
group by title 
order by count desc;

-- create a table that joins 3 tables and distinct on emp_no based on emp_no
select * into Mentorship_Eligibility from 
(
select distinct on(e.emp_no) e.emp_no, 
	e.birth_date,
	e.first_name,
	e.last_name,
	t.from_date,
	t.to_date,
	t.title
from employees e left join titles t on e.emp_no = t. emp_no
left join public.dept_emp d on e.emp_no = d. emp_no

order by e.emp_no, t.from_date desc
	) c;



-- filter data on current employees and birth date
select emp_no, 
	first_name,  
	last_name, 
	birth_date, 
	from_date, 
	to_date,
	title
from public.mentorship_eligibility
where (to_date = '9999-01-01') and birth_date between '1965-01-01' and '1965-12-31'
order by emp_no 
;

-- how many people have already reached the retirement age (65) but are still employing by this year?
-- & create a new table 
with cte as 
(
select e.emp_no, e.birth_date, e.hire_date, 
t.title, t.from_date, t.to_date
from public.employees e left join public.titles t on e.emp_no = t.emp_no
where t.to_date = '9999-01-01'
order by e.emp_no
	) 
	

	select * into retirement_ready
	from (
	select emp_no, 
		title,
		birth_date,
		(
		case 
		when extract(year from current_date) - extract(year from birth_date)= 65 and 
				extract(month from current_date) - extract(month from birth_date)<0 
			then 64
		when extract(year from current_date) - extract(year from birth_date)= 65 and 
				extract(month from current_date) - extract(month from birth_date)=0 and 
				extract(day from current_date) - extract(day from birth_date)<0
			then 64
		else extract(year from current_date) - extract(year from birth_date)
		 end 
	
	) age 
	from cte 
		) h
		 
	select * from public.retirement_ready
-- based on the new table  sum the number of retirement_ready employees
select count(*) from public.retirement_ready
where age >= 65
-- are there enough qualified, retirement_ready employees to train new generation?
select count (*) from public.retirement_ready
where title like 'Senior%' and age >=65







