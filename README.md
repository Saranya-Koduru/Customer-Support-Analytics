# Customer Support Analytics

## Background & Business Objective

### Background

Customer support plays an important role in the post-purchase experience of an e-commerce business. High support demand, unresolved tickets, product-related issues, and refunds can affect both customer satisfaction and operational efficiency.

This project analyzes customer support ticket data to understand where support demand is coming from, how effectively tickets are being handled, what issues are affecting customers, and where refund exposure is concentrated.

### Business Objective

The organization aims to improve its post-purchase customer support operations by analyzing support demand, service performance, customer outcomes, and refund activity.

The analysis focuses on:

- Identifying products and issues driving support workload
- Evaluating support performance across priorities
- Understanding patterns associated with unresolved tickets and customer satisfaction
- Identifying issues and products associated with refunds
- Finding opportunities to improve customer experience and reduce refund exposure

---

## Dataset Overview

**Source:** [Kaggle – E-Commerce Customer Support and Returns Dataset](https://www.kaggle.com/datasets/yashch05/e-commerce-customer-support-and-returns-dataset/data)

| Attribute   | Details                               |
| ----------- | ------------------------------------- |
| Records     | \~25,000 customer support tickets     |
| Time Period | \~24 months                           |
| Domain      | E-commerce Customer Support & Returns |
| Granularity | One row per support ticket            |

Each record represents a customer support ticket containing customer, product, support process, resolution, satisfaction, and refund information.

### Source Columns

- `ticket_id` – Identifier for each support ticket
- `customer_id` – Customer identifier
- `order_id` – Associated order identifier
- `order_date` – Date the order was placed
- `ticket_created_date` – Date the support ticket was raised
- `product_category` – Product category
- `product_name` – Specific product name
- `ticket_channel` – Channel used to raise the ticket
- `issue_category` – Type of issue
- `issue_description` – Short free-text description of the complaint
- `priority` – Ticket priority level
- `agent_name` – Support agent who handled the ticket
- `region` – Customer region
- `resolution_status` – Final ticket outcome
- `first_response_time_hours` – Hours until first agent response
- `resolution_time_hours` – Hours until ticket resolution
- `csat_score` – Customer satisfaction score, 1–5
- `refund_amount` – Refund amount in ₹

---

## Data Structure & Data Modeling

The analytical model was designed as a **star schema**.
<img width="882" height="550" alt="data model" src="https://github.com/user-attachments/assets/0cd77a13-287d-46f9-9b8e-ea8519a2c86a" />


### Data Quality Issue

During data profiling, duplicate `ticket_id` values were identified. Further validation showed that some duplicate ticket IDs were associated with different customers, orders, and product details.

Since these records contained different business information and no reliable rule was available to determine the correct record, they were retained rather than removed.

A surrogate key, `support_ticket_key`, was introduced in the fact table to maintain row-level uniqueness while preserving the source data.

### Data Validation

- Duplicate ticket IDs were investigated and validated against the source data.
- Dimension lookups were used while loading the fact table.
- Foreign key relationships were validated.
- No unmatched dimension keys were found.
- Fact-table row counts were validated against the source data.

---

## Data Cleaning & Preparation

Data preparation was performed before analysis.

Key steps included:

- Removed `issue_description` from the analytical model because no text analytics/NLP was required.
- Converted date/time fields to date fields where appropriate.
- Replaced missing `region` values with `"Unknown"`.
- Retained missing CSAT values as they represent valid business scenarios.
- Verified data types and duplicate records.
- Created dimension tables and a fact table.
- Created surrogate keys where required.
- Validated relationships between fact and dimension tables.

---

## Tools & Approach

### Tools

- **Excel** — Data profiling, cleaning, validation, and correlation analysis
- **SQL** — Data preparation, validation, business analysis, and KPI calculations
- **Power BI** — Data modeling, DAX, visualization, and dashboard development

---

## Key Business Questions

The analysis was designed around four main stakeholder areas.

### Customer Support

- How much support demand is being received?
- Which channels and issues generate the most tickets?
- How efficiently are tickets being handled?
- Which tickets remain pending, escalate, or close without resolution?
- Which factors are associated with customer satisfaction?

### Product Management

- Which products generate the most support demand?
- Which products have recurring defects or other issues?
- Which products have poor customer outcomes?
- Which product problems should be investigated first?

### Finance

- Where is refund exposure concentrated?
- Which products and issues generate the most refund value?
- Are high refunds driven by refund volume, refund value per ticket, or both?

### Management

- What is happening to overall support demand and performance?
- What is creating customer friction?
- Where should the business prioritize action?

---

# Key Takeaways

1. **Support demand is increasing**, with the monthly peak rising from **1,119 to 1,199 tickets** and demand consistently higher during **Mar–Jul**.

2. **Support demand is concentrated around specific products and issues**, with **Kettles & Cookers increasing 11.56% YoY** and **Product Defect accounting for 6,155 tickets**.

3. **Support performance remained broadly stable, but resolution remains a key gap**, with **45.73% of tickets resolved** and resolution improving **2.32% YoY**.

4. **Customer outcomes vary significantly by resolution status**, with resolved cases achieving around **4.4 CSAT** compared with **2.09 for closed-no-resolution** cases.

5. **Product and fulfilment issues drive both support workload and refunds**, particularly **Product Defect, Damaged in Transit, and Late Delivery**.

6. **Refund exposure varies by both frequency and financial value**, with **Home Appliances generating more refund tickets and ₹7.59M in refund value**, while **Air Coolers generated fewer refund tickets but ₹5.86M in refund value** and a higher **₹9,263 average refund per ticket**.

7. **North has the highest unresolved-case pressure**, with **10.49% of tickets closed without resolution**, while the **Marketplace channel has the highest closed-no-resolution rate at 10.86%**.

8. **Agent outcomes vary across a relatively narrow range**, with resolution rates ranging from **42%–50%**; **Agents 12, 19, and 1** show stronger overall performance and can provide internal benchmarks for improvement.

For the complete insights deep dive across all dashboard sections, [View Insights Deep Dive](<Detailed Insights & Analysis.md>)

# Recommendations

### 1. Investigate refund reasons

Analyze refund drivers by product and issue, using both **refund frequency and refund value per ticket** to identify the biggest opportunities to reduce refund impact.

### 2. Improve unresolved tickets

Review Pending, Escalated, and Closed-No-Resolution tickets to identify the main barriers preventing successful resolution and address them through process improvements, employee feedback, or training where appropriate.

### 3. Address recurring product problems

Identify products with recurring defects and share the findings with **Product Development and Quality teams** for further investigation.

### 4. Reduce delivery and fulfilment problems

Work with **Logistics and Supply Chain teams** to investigate Damaged in Transit and Late Delivery issues and reduce recurring problems.

### 5. Prepare for higher-demand periods

Plan staffing and workload allocation ahead of the **Mar–Jul** period to prepare for the expected increase in support demand.

---

# Dashboard

Explore the dashboard [here](<Dashboard Screenshots.pdf>)

---

# Limitations

- The dataset is a synthetic e-commerce customer support dataset.
- The analysis is based on the fields available in the dataset.
- `issue_description` was not analyzed because the project does not include text analytics/NLP.
- The dataset provides refund amounts but does not provide broader financial measures such as product margin, shipping cost, or operational cost.
- The analysis identifies patterns and associations but does not establish causation.

---

# Conclusion

The analysis shows that customer support demand is increasing around specific products and recurring issues, while resolution remains an important opportunity despite stable overall performance.

Poor ticket outcomes are strongly associated with lower customer satisfaction, and several recurring product and fulfilment issues also contribute to refund exposure.

The analysis therefore points to four key areas of action: **improving resolution, addressing recurring product and fulfilment issues, managing refund exposure, and preparing support capacity for higher-demand periods.**

above is the readme structure u provided. i wany some changes there. i want all these in github language readme.md structure for easy copy and paste format. also, remove numbering in the section side headings
