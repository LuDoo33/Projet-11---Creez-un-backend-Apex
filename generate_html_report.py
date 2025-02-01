import json
import os
import pdfkit  # Si tu utilises pdfkit pour convertir en PDF

# Fonction pour extraire les données du fichier test-result.txt
def parse_test_result(file_path):
    data = {}

    with open(file_path, 'r') as f:
        lines = f.readlines()

    for line in lines:
        line = line.strip()
        if 'Outcome' in line:
            data['Outcome'] = line.split('  ')[-1]
        elif 'Tests Ran' in line:
            data['Tests Ran'] = int(line.split('  ')[-1])
        elif 'Passing' in line:
            data['Passing'] = int(line.split('  ')[-1])
        elif 'Failing' in line:
            data['Failing'] = int(line.split('  ')[-1])
        elif 'Skipped' in line:
            data['Skipped'] = int(line.split('  ')[-1])
        elif 'Pass Rate' in line:
            data['Pass Rate'] = float(line.split('  ')[-1].replace('%', ''))  # Ajout du %
        elif 'Fail Rate' in line:
            data['Fail Rate'] = float(line.split('  ')[-1].replace('%', ''))  # Ajout du %
        elif 'Test Start Time' in line:
            data['Test Start Time'] = line.split('  ')[-1]
        elif 'Test Execution Time' in line:
            data['Test Execution Time'] = int(line.split('  ')[-1].replace(' ms', ''))
        elif 'Test Total Time' in line:
            data['Test Total Time'] = int(line.split('  ')[-1].replace(' ms', ''))
        elif 'Command Time' in line:
            data['Command Time'] = int(line.split('  ')[-1].replace(' ms', ''))
        elif 'Hostname' in line:
            data['Hostname'] = line.split('  ')[-1]
        elif 'Org Id' in line:
            data['Org Id'] = line.split('  ')[-1]
        elif 'Username' in line:
            data['Username'] = line.split('  ')[-1]
        elif 'Test Run Id' in line:
            data['Test Run Id'] = line.split('  ')[-1]
        elif 'User Id' in line:
            data['User Id'] = line.split('  ')[-1]
        elif 'Test Run Coverage' in line:
            data['Test Run Coverage'] = float(line.split('  ')[-1].replace('%', ''))  # Ajout du %
        elif 'Org Wide Coverage' in line:
            data['Org Wide Coverage'] = float(line.split('  ')[-1].replace('%', ''))  # Ajout du %

    return data

# Fonction pour générer le tableau HTML à partir des données JSON
def generate_json_table(data):
    html_content = """
    <h2>Apex Test Coverage Report (JSON Data)</h2>
    <table border="1" cellpadding="5" cellspacing="0" style="width: 100%; margin-top: 20px;">
        <thead>
            <tr>
                <th>Class Name</th>
                <th>Total Lines</th>
                <th>Covered Lines</th>
                <th>Coverage (%)</th>
            </tr>
        </thead>
        <tbody>
    """
    for test_result in data:
        class_name = test_result['name']
        total_lines = test_result['totalLines']
        covered_lines = test_result['totalCovered']
        coverage_percent = test_result['coveredPercent']
        html_content += f"<tr><td>{class_name}</td><td>{total_lines}</td><td>{covered_lines}</td><td>{coverage_percent}%</td></tr>"

    html_content += """
        </tbody>
    </table>
    """
    return html_content

# Fonction pour générer le tableau HTML avec les données du test-result.txt
def generate_test_result_table(test_result_data):
    html_content = """
    <h2>Test Run Summary</h2>
    <table border="1" cellpadding="5" cellspacing="0" style="width: 100%; margin-top: 20px;">
        <thead>
            <tr>
                <th>Field</th>
                <th>Value</th>
            </tr>
        </thead>
        <tbody>
    """
    for key, value in test_result_data.items():
        if isinstance(value, float):
            value = f"{value}%"  # Ajouter le % à la fin des valeurs pertinentes
        html_content += f"<tr><td>{key}</td><td>{value}</td></tr>"

    html_content += """
        </tbody>
    </table>
    """
    return html_content

# Fonction principale pour générer le fichier HTML final
def generate_html_report(json_file, txt_file, html_file, pdf_file=None):
    # Lire les données JSON
    with open(json_file, 'r') as f:
        data = json.load(f)

    # Extraire les données du fichier test-result.txt
    test_result_data = parse_test_result(txt_file)

    # Générer le contenu HTML pour les deux tableaux
    json_table = generate_json_table(data)
    test_result_table = generate_test_result_table(test_result_data)

    # Générer le fichier HTML complet
    html_content = f"""
    <html>
    <head>
        <title>Apex Test Coverage Report</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                margin: 0;
                padding: 0;
                background-color: #f4f4f4;
            }}
            .container {{
                width: 80%;
                margin: 50px auto;
                background: #fff;
                padding: 20px;
                box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            }}
            h1 {{
                text-align: center;
                color: #333;
            }}
            table {{
                width: 100%;
                border-collapse: collapse;
                margin: 20px 0;
            }}
            table, th, td {{
                border: 1px solid #ddd;
            }}
            th, td {{
                padding: 12px;
                text-align: left;
            }}
            th {{
                background-color: #f2f2f2;
            }}
            tr:nth-child(even) {{
                background-color: #f9f9f9;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Apex Test Coverage Report</h1>
            {json_table}  <!-- Tableau JSON -->
            {test_result_table}  <!-- Tableau Test Run Summary -->
        </div>
    </body>
    </html>
    """

    # Écrire le contenu HTML dans le fichier
    with open(html_file, 'w') as f:
        f.write(html_content)

    print(f"HTML report generated: {html_file}")

    # Si un fichier PDF est spécifié, générer le PDF à partir du HTML
    if pdf_file:
        pdfkit.from_file(html_file, pdf_file)
        print(f"PDF report generated: {pdf_file}")

# Main
if __name__ == "__main__":
    json_file = r'\\192.168.1.38\Nas\OpenClassroom\Projet 11\Projet 11\coverage\test-result-codecoverage.json'
    txt_file = r'\\192.168.1.38\Nas\OpenClassroom\Projet 11\Projet 11\coverage\test-result.txt'
    html_file = r'\\192.168.1.38\Nas\OpenClassroom\Projet 11\Projet 11\coverage\test-result-report.html'
    pdf_file = r'\\192.168.1.38\Nas\OpenClassroom\Projet 11\Projet 11\coverage\test-result-report.pdf'  # Définir le chemin du PDF

    generate_html_report(json_file, txt_file, html_file, pdf_file)  # Appeler la fonction avec pdf_file
