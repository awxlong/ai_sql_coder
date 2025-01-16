<img src="assets/inquery_logo.png" alt="InQuery Logo" width="50" height="50" /> # InQuery: Text to SQL Generator

Text-to-SQL in the medical domain is a task which converts natural language text to its corresponding SQL syntax. This is aimed at increasing accessibility for medical personnel who is not familiar with SQL syntax, but needs to query a structured database.

This is an app built written in Dart which queries a text-to-SQL model, [sqlcoder-7b](https://huggingface.co/defog/sqlcoder-7b-2). Dart allows for cross-platform (IOS and Android) compilation. The code is written with perplexity.AI, DeepSeek-V3 and ChatGPT's help 😊. 

## Demo: 

![Demo of InQuery app](imgs/inquery_demo.gif)


To run it, please:
1. `git clone https://github.com/awxlong/ai_sql_coder`
2. `pip install -r sql_generator_backend/requirements.txt` 
3. Run the backend which initializes sqlcoder-7b using the command `flask --app app run --debug --host=0.0.0.0 --port=5001`
4. Inside `lib/main.dart`, you can select a virtual device and run the app (`flutter pub get; flutter run`), and make natural language queries. Feel free to **modify the database schema in** `sql_generator_backend/app.py` according to your needs. If you've installed the app in a virtual device or your android/IOS, then you can just run the app and input queries as shown in the demo. 

## Brief explanation

1. sqlcoder-7b is hosted in a backend server with flask. 
2. A template prompt is fed to sqlcoder-7b which specifies a database schema. The schema we're currently using is from a small table obtained from a [free, open-source demo of the MIMIC-IV Clinical Database](https://physionet.org/content/mimic-iv-demo/1.0/)
3. The app sends user input queries to the sqlcoder-7b and displays the corresponding SQL syntax. 
4. Some postprocessing occurs where we ensure the output SQL adheres to SQLite syntax, since sqlcoder-7b also outputs PostgreSQL. 
5. The query is executed on the demo database, and shows results. We handle errors such as mentioning columns which aren't in the schema by showing an answer "Not Applicable". 

## Future updates
- Currently, inference takes very long (~3 mins), so we need to optimize throughput. I'm looking at [activation-aware quantization](https://arxiv.org/abs/2306.00978), which could hopefully give me both speed up, and a dramatic reduction in computational memory consumption. 
- Recently, there's also work [on text to FHIR as part of MIMIC-IV](https://github.com/kind-lab/mimic-fhir), so it'd be interesting to train and deploy a model in that domain. 

## Tutorial on getting started with Flutter

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
