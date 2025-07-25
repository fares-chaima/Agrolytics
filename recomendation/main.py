import requests

# Coordonnées
latitude = 35.2153459
longitude = -0.6492949

# Ton prompt pour le modèle
prompt = f"""
Je veux que tu simules les indices satellites pour cette localisation :
- Latitude: {latitude}
- Longitude: {longitude}

Donne-moi un JSON avec les champs suivants :
- NDVI
- NDWI
- SAVI
- EVI
- BSI
- LST
"""

# Requête à OpenRouter (vers GPT-4 par exemple)
url = "https://openrouter.ai/api/v1/chat/completions"
headers = {
    "Authorization": "Bearer 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",
    "Content-Type": "application/json"
}

data = {
    "model": "gpt-3.5-turbo",  # tu peux changer vers claude-3, mistral, etc.
    "messages": [
        {"role": "user", "content": prompt}
    ]
}

response = requests.post(url, headers=headers, json=data)

if response.status_code == 200:
    message = response.json()['choices'][0]['message']['content']
    print("\n✅ Réponse de l'IA :")
    print(message)
else:
    print("❌ Erreur:", response.status_code)
    print("Message:", response.text)
