# Python – Data Cleaning & Preprocessing

This folder contains the Jupyter Notebook used for data cleaning and preprocessing in the **Fashion Retail Sales & Inventory Analytics** project.

## Notebook

### Amazon_Sale_Report.ipynb

The notebook contains the Python-based data preparation performed before loading the cleaned data into MySQL and Power BI.

## Data Cleaning & Transformation

Key tasks performed include:

- Standardizing column names
- Handling missing values
- Converting and correcting data types
- Cleaning categorical values
- Preparing date-related fields for analysis
- Creating year, month, month name, and year-month fields
- Creating weekend indicators
- Standardizing product categories
- Grouping order statuses for analysis
- Converting B2B information into customer-type categories
- Cleaning shipping location information
- Identifying repeated-order SKUs
- Creating analytical flags for missing and zero-value records
- Preparing the cleaned dataset for SQL analysis and Power BI visualization

## Libraries Used

- Pandas
- NumPy
- Matplotlib

## Output

The cleaning process produced the sales dataset used throughout the project.

The complete cleaned sales dataset contains **128,975 rows and 36 columns**.

A **30,000-row sample** of the cleaned dataset is available in the `data` folder for GitHub portfolio demonstration.
