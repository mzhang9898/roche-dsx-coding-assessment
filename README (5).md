# Question 6 – GenAI Clinical Data Assistant

## Overview

This is a Generative AI Clinical Data Assistant that translates natural language questions into structured Pandas queries.

## Dataset

- `adae.csv`: Adverse event analysis dataset.
- Relevant variables include `AESEV`, `AETERM`, `AESOC`, etc.

## Implementation

The `ClinicalTrialDataAgent` class contains:

- `parse_question()`: Uses an LLM to identify the appropriate column and filter value.
- `execute_query()`: Applies the filter and returns unique subject IDs.
- `run()`: Connects question interpretation with data execution.

## Setup

Install dependencies:

```bash
/usr/local/bin/python3 -m pip install -r requirements.txt
```

Create a `.env` file containing:

```text
OPENAI_API_KEY=your_api_key
```

## Run

```bash
/usr/local/bin/python3 main.py
```

The script executes three example natural-language questions and prints the LLM-generated filters, unique subject counts, and matching subject IDs.