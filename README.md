# Amazon E-Commerce Analytics

Business Analytics project completed as part of the **NextLeap Business Analyst Fellowship — Milestone 4**.

## Project Overview

This project analyzes the Amazon Brazil e-commerce dataset using **PostgreSQL/pgAdmin** and **Excel** to identify patterns in payments, sales, products, customers, seasonality, and revenue.

The analysis contains **19 business questions** across three analytical sections.

## Tools Used

- PostgreSQL
- pgAdmin
- SQL
- Microsoft Excel

## Analysis Areas

### Analysis I — Payment & Product Insights
- Average payment value by payment type
- Order distribution by payment type
- Product/category filtering by price and keywords
- Top sales months
- Product categories with large price ranges
- Payment variability
- Missing/short product categories

### Analysis II — Orders, Categories & Customers
- Order value segmentation
- Category-level price statistics
- Repeat customers
- Customer type classification
- Top product categories by revenue

### Analysis III — Advanced Analytics
- Seasonal sales analysis
- Above-average product sales volume
- Monthly revenue trends for 2018
- Customer segmentation
- Top customers by average order value
- Monthly cumulative product sales using a recursive CTE
- Monthly payment trends and month-over-month growth using window functions

## Key Findings

- **Credit card** payments account for the largest share of recorded payment transactions.
- **May, August and July** were the highest-sales months in the analysis.
- **Beauty & Health** generated the highest category revenue among the categories analyzed.
- Most customers fall into the **Occasional** segment based on order frequency.
- Payment performance shows different month-to-month patterns across payment types.
- Advanced SQL techniques including **CTEs, recursive CTEs, subqueries and window functions** were used.

## Repository Structure

```text
amazon-ecommerce-analytics/
│
├── README.md
├── sql/
│   └── Amazon_Brazil_SQL_Analysis.sql
│
├── report/
│   └── Amazon_Analytics_Final_Submission_Report.docx
│
├── dashboard/
│   ├── Monthly_Revenue_2018.xlsx
│   └── Customer_Segmentation_Analysis_III_Q4.xlsx
│
├── presentation/
│   └── Amazon_Analytics_Final_Presentation.pptx
│
└── visuals/
    ├── monthly_revenue_report_chart.png
    └── customer_segmentation_report_chart.png
```

## Deliverables

- [SQL Analysis](sql/Amazon_Brazil_SQL_Analysis.sql)
- [Final Report](report/Amazon_Analytics_Final_Submission_Report.docx)
- [Monthly Revenue Analysis](dashboard/Monthly_Revenue_2018.xlsx)
- [Customer Segmentation Analysis](dashboard/Customer_Segmentation_Analysis_III_Q4.xlsx)
- [Final Presentation](presentation/Amazon_Analytics_Final_Presentation.pptx)

## Author

**Shivika Agrawal**

NextLeap Business Analyst Fellowship — Milestone 4
