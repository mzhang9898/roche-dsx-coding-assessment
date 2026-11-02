import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

adae = pd.read_csv("adae.csv")

app = FastAPI(title="Clinical Trial Data API")

class AEQuery(BaseModel):
  severity: list[str] | None = None
  treatment_arm: str | None = None

@app.get("/")
def welcome():
  return {"message": "Clinical Trial Data API is running"}


@app.post("/ae-query")
def ae_query(query: AEQuery):
  filtered = adae.copy()
  if query.severity is not None:
    filtered = filtered[filtered["AESEV"].isin(query.severity)]
  if query.treatment_arm is not None:
    filtered = filtered[filtered["ACTARM"] == query.treatment_arm]
    
  return {
    "count": len(filtered),
    "subject_ids": filtered["USUBJID"].dropna().unique().tolist()
  }

@app.get("/subject-risk/{subject_id}")
def risk_score_calc(subject_id: str):
  subject_ae = adae[adae["USUBJID"] == subject_id]
  if subject_ae.empty:
    raise HTTPException(
      status_code=404,
      detail=f"Subject {subject_id} not found"
    )
    
  severity_weights = {
    "MILD": 1,
    "MODERATE": 3,
    "SEVERE": 5
  }
  risk_score = int(subject_ae["AESEV"].map(severity_weights).fillna(0).sum())
  if risk_score < 5:
    risk_category = "Low"
  elif risk_score >= 15:
    risk_category = "High"
  else:
    risk_category = "Medium"
    
  return {
  "subject_id": subject_id,
  "risk_score": risk_score,
  "risk_category": risk_category
  }
