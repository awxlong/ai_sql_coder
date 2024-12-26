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
                                             device_map="auto",
                                             use_cache=True,
                                            )
eos_token_id = tokenizer.eos_token_id
pipe = pipeline(
        "text-generation",
        model=model,
        tokenizer=tokenizer,
        max_new_tokens=42,
        do_sample=False,
        return_full_text=False, # added return_full_text parameter to prevent splitting issues with prompt
        num_beams=1,            # greedy search
    )
@app.route('/generate_query', methods=['POST'])
def generate_query():
    user_query = request.json.get('prompt') # ejemplo "cuántos pacientes pesan más de 60 kilogramos y tienen una frecuencia cardíaca mayor a 72 latidos por minuto?"

    prompt = f"""
    Tarea
    Generar una consulta SQL para responder [QUESTION]{user_query}[/QUESTION]
    Esquema de Base de Datos
    La consulta se ejecutará en una base de datos con el siguiente esquema:

    CREATE TABLE Pacientes (
        id_paciente INT PRIMARY KEY,
        nombre VARCHAR(50),
        apellido VARCHAR(50),
        fecha_nacimiento DATE,
        genero CHAR(1),  -- 'M' para Masculino, 'F' para Femenino
        telefono VARCHAR(15),
        correo_electronico VARCHAR(100)
    );

    CREATE TABLE Factores_Fisiológicos (
        id_factor INT PRIMARY KEY,
        id_paciente INT,
        altura DECIMAL(5,2),  -- Altura en metros
        peso DECIMAL(5,2),    -- Peso en kilogramos
        presion_arterial VARCHAR(10),  -- Ejemplo: '120/80'
        frecuencia_cardiaca INT,  -- Frecuencia cardíaca en latidos por minuto
        fecha_registro DATE,
        FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente)
    );

    Respuesta
    Dado el esquema de la base de datos, aquí está la consulta SQL que [QUESTION]{user_query}[/QUESTION]:
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
