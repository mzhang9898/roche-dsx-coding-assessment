import json
import pandas as pd

from dotenv import load_dotenv
from langchain_openai import ChatOpenAI

load_dotenv()

adae = pd.read_csv("adae.csv")

llm = ChatOpenAI(
    model="gpt-4.1-mini",
    temperature=0
)

# Reference: SDTMIG v3.4
schema = {
  "USUBJID": "Unique Subject Identifier.",
  "AGE": "Age.",
  "SEX": "Sex.",
  "RACE": "Race.",
  "ACTARM": "Description of Actual Arm.",
  
  "AESEQ": "Sequence Number.",
  "AETERM": "Reported Term for the Adverse Event.",
  "AEDECOD": "Dictionary-Derived Term.",
  "AESOC": "Primary System Organ Class.",
  "AESEV": "Severity/Intensity.",
  "AESER": "Serious Event.",
  "AEACN": "Action Taken with Study Treatment.",
  "AEACNOTH": "Other Action Taken.",
  "AEREL": "Causality.",
  "AEOUT": "Outcome of Adverse Event.",

  "AESTDTC": "Start Date/Time of Adverse Event.",
  "AEENDTC": "End Date/Time of Adverse Event.",
  "AESTDY": "Study Day of Start of Adverse Event.",
  "AEENDY": "Study Day of End of Adverse Event."
}


class ClinicalTrialDataAgent:
  def __init__(self, dataframe, llm, schema):
    self.df = dataframe
    self.llm = llm
    self.schema = schema

  def parse_question(self, question):
    prompt = f"""
    You are a clinical trial data assistant.
    This is the dataset schema:
        
    {json.dumps(self.schema, indent=2)}
      
    Convert the user's question into a JSON object containing exactly two fields:
    - target_column: the dataset column to filter
    - filter_value: the value to search for
      
    Choose the appropriate column based on the meaning of the question.
    Return only valid JSON.
    User question: {question}
    """
    response = self.llm.invoke(prompt)
    content = response.content.strip()
    if content.startswith("```"):
      content = content.removeprefix("```json").removeprefix("```")
      content = content.removesuffix("```").strip()
      
    return json.loads(content)
  
  def execute_query(self, parsed_query):
    target_column = parsed_query["target_column"]
    filter_value = parsed_query["filter_value"]

    if target_column not in self.schema or target_column not in self.df.columns:
        raise ValueError(f"Invalid column: {target_column}")

    filtered = self.df[self.df[target_column].astype("string").str.upper()== str(filter_value).upper()]

    subject_ids = filtered["USUBJID"].dropna().unique().tolist()

    return {
        "count": len(subject_ids),
        "subject_ids": subject_ids
    }
    
  def run(self, question):
    parsed_query = self.parse_question(question)
    return self.execute_query(parsed_query)
  
if __name__ == "__main__":
  agent = ClinicalTrialDataAgent(adae, llm, schema)
  questions = [
    "Which subjects had adverse events of moderate severity",
    "Which subjects experienced headache",
    "Which subjects had adverse events in the cardiac system"
  ]
  for question in questions:
    parsed_query = agent.parse_question(question)
    result = agent.execute_query(parsed_query)

    print(f"\nQuestion: {question}")
    print(f"LLM output: {parsed_query}")
    print(f"Unique subjects: {result['count']}")
    print(f"Subject IDs: {result['subject_ids']}")
