use customer_support;

/* ticket_id	customer_id	order_id	product_category	product_name	order_date	ticket_created_date	
ticket_channel	issue_category	priority	agent_name    resolution_status	
first_response_time_hours	resolution_time_hours	csat_score	refund_amount	region */

CREATE TABLE customer_support_data (
    Ticket_ID VARCHAR(30) PRIMARY KEY,
    Customer_ID VARCHAR(30),
    Order_ID VARCHAR(30),
    Product_Category VARCHAR(100),
    Product_Name VARCHAR(150),
    Order_Date DATE,
    Ticket_Created_Date DATE,
    Ticket_Channel VARCHAR(50),
    Issue_Category VARCHAR(100),
    Priority VARCHAR(20),
    Agent_Name VARCHAR(100),
    Resolution_Status VARCHAR(50),
    first_response_time_hours DECIMAL(5 , 2 ),
    resolution_time_hours DECIMAL(5 , 2 ),
    csat_score INT,
    refund_amount DECIMAL(10 , 2 ),
    region VARCHAR(50)
);

-- viewing the table structure
desc customer_support_data;

-- only few rows imported using data import wizard. so deleting all rows 
-- inside table and using sql commands to import data
truncate table customer_support_data;

SHOW VARIABLES LIKE 'local_infile';
SELECT VERSION();
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

-- importing data using sql command
LOAD DATA LOCAL INFILE 'file path'
INTO TABLE customer_support_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Ticket_ID,
 Customer_ID,
 Order_ID,
 Product_Category,
 Product_Name,
 Order_Date,
 Ticket_Created_Date,
 Ticket_Channel,
 Issue_Category,
 Priority,
 Agent_Name,
 Resolution_Status,
 first_response_time_hours,
 resolution_time_hours,
 csat_score,
 refund_amount,
 region);
 
 -- retrieving table
SELECT 
    *
FROM
    customer_support_data
LIMIT 10;
 
 -- dimensional modelling - creating star schema with dim and fact tables
CREATE TABLE dim_customer (
    Customer_ID VARCHAR(30) PRIMARY KEY
);
 
 -- dim_agent
CREATE TABLE dim_agent (
    agent_id INT AUTO_INCREMENT PRIMARY KEY,
    agent_name VARCHAR(100)
);
 
 -- dim_product
CREATE TABLE dim_product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_category VARCHAR(100),
    product_name VARCHAR(150)
);
 
 -- dim_date
CREATE TABLE dim_date (
    date_id INT AUTO_INCREMENT PRIMARY KEY,
    full_date DATE NOT NULL,
    year YEAR NOT NULL,
    quarter TINYINT NOT NULL,
    month TINYINT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day TINYINT NOT NULL,
    week_day VARCHAR(20) NOT NULL
);
 

 -- there were duplicate ticket id's with each ticket id having diff no of customer id's.
-- Since duplicate Ticket IDs contain different customer, order, and product information, they were retained.
-- Introduced support_ticket_key as a surrogate primary key to maintain row-level uniqueness.
-- fact_ticket
CREATE TABLE fact_tickets (
    support_ticket_key INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id VARCHAR(30),
    customer_id VARCHAR(30),
    agent_id INT,
    product_id INT,
    order_date_id INT,
    ticket_created_date_id INT,
    order_id VARCHAR(30),
    region VARCHAR(50),
    ticket_channel VARCHAR(50),
    issue_category VARCHAR(100),
    priority VARCHAR(20),
    resolution_status VARCHAR(50),
    first_response_time_hours DECIMAL(5 , 2 ),
    resolution_time_hours DECIMAL(5 , 2 ),
    csat_score INT,
    refund_amount DECIMAL(10 , 2 ),
    FOREIGN KEY (customer_id)
        REFERENCES dim_customer (customer_id),
    FOREIGN KEY (agent_id)
        REFERENCES dim_agent (agent_id),
    FOREIGN KEY (product_id)
        REFERENCES dim_product (product_id),
    FOREIGN KEY (order_date_id)
        REFERENCES dim_date (date_id),
    FOREIGN KEY (ticket_created_date_id)
        REFERENCES dim_date (date_id)
);

-- viewing all tables
show tables;

-- inserting values into tables
-- dim_customer
insert into dim_customer(customer_id)
select distinct customer_id from customer_support_data;

-- dim_agent
insert into dim_agent (agent_name)
select distinct agent_name from customer_support_data;

-- dim_product
insert into dim_product(product_category,product_name)
select distinct product_category ,product_name from customer_support_data
order by product_category;

-- dim_date
insert into dim_date (full_date, year, quarter, month, month_name, day, week_day)
select distinct
dt,year(dt),quarter(dt),month(dt),monthname(dt),day(dt),dayname(dt)
from 
(
select order_date as dt from customer_support_data
union
select ticket_created_date from customer_support_data) dts;

-- inserting into fact_ticket
insert into fact_tickets(ticket_id, customer_id, agent_id, product_id, order_date_id, 
ticket_created_date_id, order_id, region, ticket_channel, issue_category, priority, resolution_status, 
first_response_time_hours, resolution_time_hours, csat_score, refund_amount)
	select  
	cd.ticket_id, dc.customer_id,da.agent_id,dp.product_id,od_dt.date_id as order_date_id,
	tk_dt.date_id as ticket_created_date_id,cd.order_id,cd.region,cd.ticket_channel, 
    cd.issue_category, cd.priority, cd.resolution_status, cd.first_response_time_hours, 
    cd.resolution_time_hours,cd.csat_score, cd.refund_amount
	from customer_support_data cd
	join dim_date od_dt on od_dt.full_date = cd.order_date
	join dim_date tk_dt on tk_dt.full_date = cd.ticket_created_date
	join dim_agent da on da.agent_name = cd.agent_name
	join dim_customer dc on dc.customer_id = cd.customer_id
	join dim_product dp on dp.product_category = cd.product_category and dp.product_name = cd.product_name;
    
-- viewing all tables 
show tables;


-- csat values are converted into 0's since we used int as datatype
-- checking how many 0's since our original dataset doesnt have 0's in csat
SELECT 
    csat_score,
    COUNT(*) AS ticket_count
FROM fact_tickets
GROUP BY csat_score
ORDER BY csat_score;

-- creating a backup file
CREATE TABLE fact_tickets_csatbackup AS
SELECT * FROM fact_tickets;
select count(*) from fact_tickets_csatbackup;

-- updating our original fact_tickets table 
-- changing 0's into nulls
UPDATE fact_tickets
SET csat_score = NULL
WHERE csat_score = 0;

-- rechecking
select * from fact_tickets where csat_score = 0;
-- checking nulls
select * from fact_tickets where csat_score is null;
