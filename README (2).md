# Question 5: Clinical Data API

## Overview

This project implements a RESTful API using FastAPI that serves clinical trial data, performs dynamic cohort analysis, and calculates patient risk scores.

The API uses `adae.csv`, exported from R.

## Requirements

- Python 3.10 or later
- FastAPI
- Uvicorn
- Pandas

## Installation

Open a Terminal and navigate to the project folder:

```bash
cd question_5_api
```

Install the required packages:

```bash
python -m pip install fastapi uvicorn pandas
```

## Running the API

Open a Terminal and navigate to the question_5_api directory. Start the FastAPI server:

```bash
python -m uvicorn main:app --reload
```

Once the server starts successfully, the Terminal displays a message similar to:

```bash
INFO: Uvicorn running on http://127.0.0.1:8000
```

## API Endpoints

### 1. GET /

Returns a welcome message confirming that the API is running.

### 2. POST /ae-query

Filters adverse event records using severity and treatment arm.

Example request:

```json
{
  "severity": ["MILD", "MODERATE"],
  "treatment_arm": "Placebo"
}
```

Returns the number of matching AE records and a list of unique subject IDs.

If a field is missing or null in the request, it returns all records for that dimension.

### 3. GET /subject-risk/{subject_id}

Calculates a safety risk score based on AE severity:

- MILD: 1 point
- MODERATE: 3 points
- SEVERE: 5 points

Risk categories:

- Low: Score below 5
- Medium: Score from 5 to 14
- High: Score of 15 or higher

Returns the subject ID, total risk score, and risk category.

If the subject ID is not found, the API returns HTTP 404.

## Project Files

- `main.py`: FastAPI application and endpoint implementations.
- `adae.csv`: Clinical trial adverse event data.
- `README.md`: Setup instructions and API documentation.
