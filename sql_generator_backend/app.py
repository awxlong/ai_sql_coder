from flask import Flask, request, jsonify
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
import torch
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Load model and tokenizer
tokenizer = AutoTokenizer.from_pretrained("defog/sqlcoder-7b-2")
model = AutoModelForCausalLM.from_pretrained("defog/sqlcoder-7b-2",
                                             trust_remote_code=True,
                                             torch_dtype=torch.float16,
                                             device_map="cpu", # cpu because the user input would be on the cpu by default
                                             use_cache=True,
                                            )
eos_token_id = tokenizer.eos_token_id
pipe = pipeline(
        "text-generation",
        model=model,
        tokenizer=tokenizer,
        max_new_tokens=64,
        do_sample=False,
        return_full_text=False, # added return_full_text parameter to prevent splitting issues with prompt
        num_beams=1,            # greedy search
    )
@app.route('/generate_query', methods=['POST'])
def generate_query():
    user_query = request.json.get('prompt') # ejemplo "cuántos pacientes pesan más de 60 kilogramos y tienen una frecuencia cardíaca mayor a 72 latidos por minuto?"

    prompt = f"""
    ### Task
    Generate a SQL query compatible with SQLite to answer [QUESTION]{user_query}[/QUESTION]

    ### Database Schema
    The query will run on a database with the following schema:
    CREATE TABLE mimic_iv_demo (
        subject_id INTEGER,
        hadm_id INTEGER,
        admittime DATETIME,
        dischtime DATETIME,
        deathtime DATETIME,
        admission_type TEXT,
        admit_provider_id TEXT,
        admission_location TEXT,
        discharge_location TEXT,
        insurance TEXT,
        language TEXT,
        marital_status TEXT,
        race TEXT,
        edregtime DATETIME,
        edouttime DATETIME,
        hospital_expire_flag INTEGER
    );

    ### Answer
    Given the database schema, here is the SQL query compatible with SQLite that answers [QUESTION]{user_query}[/QUESTION]:
    [SQL]
    """

    generated_query = (
        pipe(
            prompt,
            num_return_sequences=1,
            eos_token_id=eos_token_id,
            pad_token_id=eos_token_id,
        )[0]["generated_text"]
        .split(";")[0]
        .split("```")[0]
        .strip()
        + ";"
    )
    return jsonify({'query': generated_query.strip()})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001) # flask --app app run --debug --host=0.0.0.0 --port=5001
