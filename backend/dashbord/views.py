import requests
import json
import re

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
WEATHERAPI_KEY = "471c160b74ac44e5b8c194712252404"
OPENROUTER_API_KEY = "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"
EURO_TO_DZD = 145
# --- Récupérer l'emplacement de l'utilisateur ---
def get_location():
    ip_info_url = "http://ipinfo.io/json"
    response = requests.get(ip_info_url)
    if response.status_code == 200:
        data = response.json()
        location = data['city']
        return location
    else:
        return None




      

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import requests
import json
latest_soil_data = {}



@csrf_exempt  # À retirer en production ou remplacer par une authentification
def soil_data(request):
    global latest_soil_data  # Pour modifier la variable globale

    if request.method == 'POST':
        try:
            data = json.loads(request.body)

            # Extraction des données
            N = 80
            P = 80
            K = 80
            temperature = 80
            humidity = 80
            ph = 80
            rainfall = 80

            print("Données reçues:", data)

            # Stocker dans la variable globale
            latest_soil_data = data
            print("Données enregistrées dans latest_soil_data:", latest_soil_data)

            # Retourner une réponse JSON de succès
            return JsonResponse({'message': 'Données reçues avec succès', 'receivedData': data})

        except json.JSONDecodeError:
            return JsonResponse({'error': 'JSON invalide'}, status=400)

    else:
        return JsonResponse({'error': 'Méthode non autorisée'}, status=405)




# Fonction fictive à définir ailleurs
def get_location():
    # Implémenter la détection de localisation ici
    return None  # ou une valeur comme "alger"




from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import requests
import json

@csrf_exempt
def get_agriculture_advice(request):
    global latest_soil_data

    # Default values if data is not available
    temperature = latest_soil_data.get('temperature', 34)
    humidity = latest_soil_data.get('humidity', 30)
    N = latest_soil_data.get('N', 50)
    P = latest_soil_data.get('P', 40)
    K = latest_soil_data.get('K', 30)
    ph = latest_soil_data.get('ph', 6.5)
    rainfall = latest_soil_data.get('rainfall', 150.0)
    co2 = latest_soil_data.get('co2', 500)           # ppm
    light = latest_soil_data.get('light', 30000)     # lux

    location = "sidi bel abbès"

    # Get weather data
    try:
        weather_url = f"http://api.weatherapi.com/v1/current.json?key={WEATHERAPI_KEY}&q={location}"
        weather_response = requests.get(weather_url)
        weather_response.raise_for_status()
        weather_data = weather_response.json()
        climate = weather_data['current']['condition']['text'].lower()
    except Exception as e:
        return JsonResponse({"error": f"Weather error: {str(e)}"}, status=500)

    # Prepare message for AI
    user_message = (
        f"🔢 Field Data:\n"
        f"- Temperature: {temperature}°C\n"
        f"- Soil Humidity: {humidity}%\n"
        f"- Nitrogen Level (N): {N}\n"
        f"- Phosphorus Level (P): {P}\n"
        f"- Potassium Level (K): {K}\n"
        f"- Soil pH: {ph}\n"
        f"- Rainfall: {rainfall} mm\n"
        f"- CO2 Level: {co2} ppm\n"
        f"- Light Intensity: {light} lux\n"
        f"- Current Climate: {climate}\n\n"
        "🧠 Answer the following questions in very short answers (maximum 17 words) in English only:\n"
        "1. What is the soil condition?\n"
        "2. Should I irrigate now?\n"
        "3. Is it a good time to plant? Why?\n"
        "4. Should I use chemicals? What type?\n"
        "5. Is the nitrogen level sufficient?\n"
        "6. What should I do if phosphorus is low?\n"
        "7. Is potassium balanced?\n"
        "8. Is the CO2 level appropriate?\n"
        "9. Is the light intensity good for growth?\n"
        "10. Any special advice based on the climate?\n\n"
        "✅ Return the answer in JSON format only like this:\n"
        "{ \"advice\": \"1. ...\\n2. ...\\n...\\n10. ...\" }"
    )

    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
    }

    payload = {
        "model": "mistralai/mistral-7b-instruct",
        "messages": [
            {"role": "system", "content": "You are an intelligent agriculture expert. Answer concisely and clearly without additional explanation."},
            {"role": "user", "content": user_message}
        ]
    }

    try:
        response = requests.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            data=json.dumps(payload)
        )
        response.raise_for_status()
        result = response.json()
        content = result['choices'][0]['message']['content']
    except Exception as e:
        print("AI error:", e)
        if 'response' in locals():
            print("Raw response:", response.text)
        return JsonResponse({"error": "AI error"}, status=500)

    try:
        advice_json = json.loads(content)
        advice_text = advice_json.get("advice", "")
        advice_lines = advice_text.strip().split("\n")
        response_list = [
            line.split(f"{i}.", 1)[1].strip() if line.startswith(f"{i}.") else "undefined"
            for i, line in enumerate(advice_lines, 1)
        ]
    except Exception as e:
        print("Parsing error:", e)
        response_list = [content.strip()] + ["undefined"] * 9

    return JsonResponse({
        "conseils": [
            {"id": 1, "type": "positive", "icon": "🌱", "title_en": "Soil Condition", "subtitle_en": response_list[0], "action": "Soil Details"},
            {"id": 2, "type": "warning", "icon": "💧", "title_en": "Irrigation Advice", "subtitle_en": response_list[1], "action": "Irrigation Plan"},
            {"id": 3, "type": "positive", "icon": "📅", "title_en": "Planting Time", "subtitle_en": response_list[2], "action": "Planting Tips"},
            {"id": 4, "type": "urgent", "icon": "☠️", "title_en": "Chemical Usage", "subtitle_en": response_list[3], "action": "Product Guide"},
            {"id": 5, "type": "info", "icon": "🧪", "title_en": "Nitrogen Level", "subtitle_en": response_list[4], "action": "Fertilizing N"},
            {"id": 6, "type": "info", "icon": "📉", "title_en": "Phosphorus Advice", "subtitle_en": response_list[5], "action": "Fertilizing P"},
            {"id": 7, "type": "info", "icon": "🧂", "title_en": "Potassium Balance", "subtitle_en": response_list[6], "action": "Fertilizing K"},
            {"id": 8, "type": "info", "icon": "🌀", "title_en": "CO2 Level", "subtitle_en": response_list[7], "action": "Ventilation"},
            {"id": 9, "type": "info", "icon": "💡", "title_en": "Light Intensity", "subtitle_en": response_list[8], "action": "Photosynthesis"},
            {"id": 10, "type": "warning", "icon": "🌦️", "title_en": "Weather Advice", "subtitle_en": response_list[9], "action": "Weather Tips"},
        ]
    })











@csrf_exempt
def get_agriculture_recommendations(request):
    WEATHERAPI_KEY = "471c160b74ac44e5b8c194712252404"
    OPENROUTER_API_KEY = "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"

    # Assure-toi que cette fonction existe et retourne un lieu ou None
    location = get_location() or "sidi bel abbès"

    weather_url = f"http://api.weatherapi.com/v1/current.json?key={WEATHERAPI_KEY}&q={location}"
    weather_response = requests.get(weather_url)

    if weather_response.status_code == 200:
        weather_data = weather_response.json()
        climate = weather_data['current']['condition']['text'].lower()
    else:
        return JsonResponse({"error": "Erreur de récupération des données météo."}, status=500)

    global latest_soil_data



    # Valeurs par défaut si latest_soil_data est vide
    temperature = latest_soil_data.get('temperature', 34)
    humidity = latest_soil_data.get('humidity', 30)
    N = latest_soil_data.get('N', 50)
    P = latest_soil_data.get('P', 40)
    K = latest_soil_data.get('K', 30)
    ph = latest_soil_data.get('ph', 6.5)
    rainfall = latest_soil_data.get('rainfall', 150.0)
    

    user_message = (
        f"My field data:\n"
        f"- Temperature: {temperature}°C\n"
        f"- Soil Humidity: {humidity}%\n"
        f"- Climate: {climate}\n"
        f"N Level: {N}\n"
        f"P Level: {P}\n"
        f"K Level: {K}\n"
        f"Soil pH: {ph}\n"
        f"Rainfall: {rainfall} mm\n"
        "Give me 4 best crops to plant now based on this data.\n"
        "Respond ONLY with a JSON array containing objects with keys: id, name, detail, badges.\n"
        "Each badge is an object with keys 'text' and 'type'.\n"
        "Example:\n"
        "[\n"
        "  {\"id\": 1, \"name\": \"Tomatoes\", \"detail\": \"Plant now\", \"badges\": [{\"text\": \"Optimal Time\", \"type\": \"optimal\"}]},\n"
        "  {...}\n"
        "]\n"
        "Do not add any text before or after the JSON.\n"
        "Keep the JSON valid and parsable."
    )

    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
    }

    payload = {
        "model": "mistralai/mistral-7b-instruct",
        "messages": [
            {
                "role": "system",
                "content": "You're an agriculture expert. Return 4 recommended crops as JSON array with name, detail, badges (text and type)."
            },
            {"role": "user", "content": user_message}
        ]
    }

    response = requests.post(
        "https://openrouter.ai/api/v1/chat/completions",
        headers=headers,
        data=json.dumps(payload)
    )

    if response.status_code == 200:
        result = response.json()
        content = result['choices'][0]['message']['content']

        # Essayer de parser le JSON retourné par l'IA
        try:
            crops = json.loads(content)
        except json.JSONDecodeError:
            return JsonResponse({"error": "Erreur dans le format JSON retourné par l'IA."}, status=500)

        return JsonResponse({"recommended_crops": crops})
    else:
        return JsonResponse({"error": "Erreur OpenRouter."}, status=500)
    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
    }

    payload = {
        "model": "mistralai/mistral-7b-instruct",
        "messages": [
            {
                "role": "system",
                "content": "You're an agriculture expert. Return 4 recommended crops as JSON array with name, detail, badges (text and type)."
            },
            {"role": "user", "content": user_message}
        ]
    }

    response = requests.post(
        "https://openrouter.ai/api/v1/chat/completions",
        headers=headers,
        data=json.dumps(payload)
    )

    if response.status_code == 200:
        result = response.json()
        content = result['choices'][0]['message']['content']

        # Essayer de parser le JSON retourné par l'IA
        try:
            crops = json.loads(content)
        except json.JSONDecodeError:
            return JsonResponse({"error": "Erreur dans le format JSON retourné par l'IA."}, status=500)

        return JsonResponse({"recommended_crops": crops})
    else:
        return JsonResponse({"error": "Erreur OpenRouter."}, status=500)

@csrf_exempt
def get_weather_forecast(request):
    WEATHERAPI_KEY = "471c160b74ac44e5b8c194712252404"
    location = get_location()
    if location is None:
        location = "sidi bel abbès"
    
    days = 7  # demander 7 jours
    url = f"http://api.weatherapi.com/v1/forecast.json?key={WEATHERAPI_KEY}&q={location}&days={days}&aqi=no&alerts=no"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        forecast = []
        # la clé 'forecastday' peut contenir moins de jours si API limite
        for day in data['forecast']['forecastday']:
            forecast.append({
                "date": day['date'],
                "condition": day['day']['condition']['text'],
                "avg_temp": day['day']['avgtemp_c'],
                "max_temp": day['day']['maxtemp_c'],
                "min_temp": day['day']['mintemp_c'],
                "humidity": day['day']['avghumidity'],
                "rain": day['day']['totalprecip_mm']
            })
        return JsonResponse({"location": location, "forecast": forecast})
    else:
        return JsonResponse({"error": "Erreur lors de la récupération des données météo."}, status=500)

from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import requests, json

@csrf_exempt
def get_agriculture_evaluation(request):
    global latest_soil_data

    OPENROUTER_API_KEY = "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"
    WEATHERAPI_KEY = "471c160b74ac44e5b8c194712252404"
    location = "sidi bel abbès"

    # Lecture des données avec valeurs par défaut
    temperature = latest_soil_data.get('temperature', 34)
    humidity = latest_soil_data.get('humidity', 30)
    N = latest_soil_data.get('N', 50)
    P = latest_soil_data.get('P', 40)
    K = latest_soil_data.get('K', 30)
    ph = latest_soil_data.get('ph', 6.5)
    rainfall = latest_soil_data.get('rainfall', 150.0)

    # Récupération du climat
    try:
        weather_url = f"http://api.weatherapi.com/v1/current.json?key={WEATHERAPI_KEY}&q={location}"
        weather_response = requests.get(weather_url)
        weather_response.raise_for_status()
        weather_data = weather_response.json()
        climate = weather_data['current']['condition']['text'].lower()
    except Exception as e:
        return JsonResponse({"error": f"Erreur météo : {str(e)}"}, status=500)

    # Message pour OpenRouter
    user_message = (
        f"Temperature: {temperature}°C\n"
        f"Soil Humidity: {humidity}%\n"
        f"Climate: {climate}\n"
        f"N Level: {N}\n"
        f"P Level: {P}\n"
        f"K Level: {K}\n"
        f"Soil pH: {ph}\n"
        f"Rainfall: {rainfall} mm\n"
        "Return JSON with indicators and values from 0 to 100:\n"
        "photosynthetic_activity, soil_moisture_level, crop_yield_estimation, "
        "nutrient_deficiency_risk, chlorophyll_content, evapotranspiration_rate"
    )

    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
    }

    payload = {
        "model": "mistralai/mistral-7b-instruct",
        "messages": [
            {
                "role": "system",
                "content": (
                    "Reply in pure JSON with keys: "
                    "'photosynthetic_activity', 'soil_moisture_level', 'crop_yield_estimation', "
                    "'nutrient_deficiency_risk', 'chlorophyll_content', 'evapotranspiration_rate'"
                )
            },
            {
                "role": "user",
                "content": user_message
            }
        ]
    }

    # Appel à l'API OpenRouter
    try:
        response = requests.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            data=json.dumps(payload)
        )
        response.raise_for_status()
        result = response.json()
        content = result['choices'][0]['message']['content']

        # DEBUG : voir le contenu brut retourné
        print("Contenu brut OpenRouter :", content)

        # Extraction du JSON pur avec expression régulière
        json_match = re.search(r'{.*}', content, re.DOTALL)
        if not json_match:
            return JsonResponse({"error": "JSON non trouvé dans la réponse"}, status=500)

        json_data = json.loads(json_match.group())
        return JsonResponse(json_data)

    except Exception as e:
        print("Erreur dans la requête ou parsing :", str(e))
        return JsonResponse({"error": f"Erreur OpenRouter ou parsing : {str(e)}"}, status=500)
        
@csrf_exempt
def get_agriculture_ev(request):
    global latest_soil_data

    OPENROUTER_API_KEY = "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"
    WEATHERAPI_KEY = "471c160b74ac44e5b8c194712252404"

    # --- Fonction pour récupérer la localisation ---
    def get_location():
        try:
            ip_response = requests.get("https://ipinfo.io/json")
            if ip_response.status_code == 200:
                ip_data = ip_response.json()
                return ip_data.get("city", "sidi bel abbès")
        except:
            pass
        return "sidi bel abbès"

    location = get_location()

    # --- Appel API météo ---
    try:
        weather_url = f"http://api.weatherapi.com/v1/current.json?key={WEATHERAPI_KEY}&q={location}"
        weather_response = requests.get(weather_url)
        weather_response.raise_for_status()
        climate = weather_response.json()['current']['condition']['text'].lower()
    except Exception as e:
        return JsonResponse({"error": f"Erreur de récupération des données météo : {str(e)}"}, status=500)

    # --- Lecture des données du sol ---
    temperature = latest_soil_data.get('temperature', 34)
    humidity = latest_soil_data.get('humidity', 30)
    N = latest_soil_data.get('N', 50)
    P = latest_soil_data.get('P', 40)
    K = latest_soil_data.get('K', 30)
    ph = latest_soil_data.get('ph', 6.5)
    rainfall = latest_soil_data.get('rainfall', 150.0)

    # --- Message envoyé à l'IA ---
    user_message = (
    f"Here is the field data:\n"
    f"- Temperature: {temperature}°C\n"
    f"- Soil Humidity: {humidity}%\n"
    f"- Climate: {climate}\n"
    f"- N Level: {N}\n"
    f"- P Level: {P}\n"
    f"- K Level: {K}\n"
    f"- Soil pH: {ph}\n"
    f"- Rainfall: {rainfall} mm\n\n"
    "Return only a JSON object with these agricultural indicators as numerical values between 0 and 100:\n"
    "{\n"
    "  'ThermalStress': value,\n"
    "  'WaterStress': value,\n"
    "  'IrrigationNeed': value,\n"
    "  'ClimateSuitability': value,\n"
    "  'FungalDiseaseRisk': value,\n"
    "  'SoilHealthIndex': value,\n"
    "  'CropSuitabilityIndex': value,\n"
    "  'PestRiskLevel': value,\n"
    "  'NutrientBalance': value,\n"
    "  'YieldPotential': value,\n"
    "  'FertilizerEfficiency': value,\n"
    "  'ErosionRisk': value\n"
    "}\n"
    "Then add a short percentage-based explanation for each indicator."
     )


    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
    }

    payload = {
        "model": "mistralai/mistral-7b-instruct",
        "messages": [
            {
                "role": "system",
                "content": "You're an agriculture expert. Respond with only the JSON then a short explanation for each indicator."
            },
            {
                "role": "user",
                "content": user_message
            }
        ]
    }

    try:
        response = requests.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            data=json.dumps(payload)
        )
        response.raise_for_status()
        result = response.json()
        ai_content = result['choices'][0]['message']['content']
        return JsonResponse({"evaluation": ai_content})
    except Exception as e:
        return JsonResponse({"error": f"Erreur OpenRouter : {str(e)}"}, status=500)

 






@csrf_exempt
def calculate_agricultural_income(request):
    global latest_soil_data

    if request.method != "POST":
        return JsonResponse({"error": "Only POST requests allowed"}, status=405)

    try:
        body = json.loads(request.body)
        location = body.get("location")
        cultures = body.get("cultures")  # [{"Produit": "blé", "Hectares": 5}, ...]

        if not location or not cultures:
            return JsonResponse(
                {"error": "Missing fields: location and cultures are required"},
                status=400
            )

        # Données simulées
        temperature = latest_soil_data.get('temperature', 34)
        humidity = latest_soil_data.get('humidity', 30)
        N = latest_soil_data.get('N', 50)
        P = latest_soil_data.get('P', 40)
        K = latest_soil_data.get('K', 30)
        ph = latest_soil_data.get('ph', 6.5)
        rainfall = latest_soil_data.get('rainfall', 150.0)

        # Climat
        weather_url = f"http://api.weatherapi.com/v1/current.json?key={WEATHERAPI_KEY}&q={location}"
        weather_response = requests.get(weather_url)
        if weather_response.status_code != 200:
            return JsonResponse({"error": "Weather API error"}, status=500)

        weather_data = weather_response.json()
        climate = weather_data['current']['condition']['text'].lower()

        # Message IA
        user_message = (
            f"Voici les données météo actuelles à {location} :\n"
            f"- Température: {temperature}°C\n"
            f"- Humidité du sol: {humidity}%\n"
            f"- Climat: {climate}\n\n"
            f"N Level: {N}\n"
            f"P Level: {P}\n"
            f"K Level: {K}\n"
            f"Soil pH: {ph}\n"
            f"Rainfall: {rainfall} mm\n"
            "Et voici les cultures sur mon terrain :\n"
        )

        for culture in cultures:
            user_message += f"- {culture['Produit']} : {culture['Hectares']} hectares\n"

        user_message += (
            "\nDonne-moi un tableau JSON contenant :\n"
            "- Produit\n- Rendement (t/ha)\n- Production (t)\n- Prix (€/t)\n- Revenu (€)\n"
            "Format JSON uniquement, sans explication. Mets le tout dans { \"cultures\": [...] }"
        )

        # Requête à OpenRouter
        headers = {
            "Authorization": f"Bearer {OPENROUTER_API_KEY}",
            "Content-Type": "application/json",
        }
        payload = {
            "model": "mistralai/mistral-7b-instruct",
            "messages": [
                {"role": "system", "content": "Tu es un assistant agricole expert."},
                {"role": "user", "content": user_message}
            ]
        }

        response = requests.post("https://openrouter.ai/api/v1/chat/completions", headers=headers, data=json.dumps(payload))
        if response.status_code != 200:
            return JsonResponse({"error": "OpenRouter error", "details": response.text}, status=500)

        # Extraction JSON propre
        content = response.json()["choices"][0]["message"]["content"]
        json_match = re.search(r"\{.*\}", content, re.DOTALL)
        if not json_match:
            return JsonResponse({"error": "No valid JSON found in AI response"}, status=500)

        data = json.loads(json_match.group(0))

        # Conversion prix & revenu en DZD
        for item in data["cultures"]:
            try:
                item["Prix (DZD/t)"] = round(float(item["Prix (€/t)"]) * EURO_TO_DZD)
                item["Revenu (DZD)"] = round(float(item["Revenu (€)"]) * EURO_TO_DZD)
            except Exception:
                item["Prix (DZD/t)"] = "N/A"
                item["Revenu (DZD)"] = "N/A"

        return JsonResponse({
            "climat": climate,
            "resultats": data["cultures"]
        })

    except Exception as e:
        return JsonResponse({"error": "Internal error", "details": str(e)}, status=500)




@csrf_exempt
def market_trends(request):
    OPENROUTER_API_KEY = "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"

    prompt = (
        "Give me a list of 5 important agricultural products with the following info for each:\n"
        "- Crop name\n"
        "- Current market price in €/t\n"
        "- Change percentage compared to last week\n"
        "- Forecast trend (Rising / Falling / Stable)\n"
        "- Action suggestion (just write 'Analyze')\n\n"
        "Format the result as pure JSON list like this:\n"
        '[{"Crop": "Wheat", "Price": "230 €/t", "Change": "+3.2%", "Forecast": "Rising", "Action": "Analyze"}]'
    )

    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
    }

    payload = {
        "model": "mistralai/mistral-7b-instruct",
        "messages": [
            {"role": "system", "content": "You are an assistant specialized in agricultural market data."},
            {"role": "user", "content": prompt}
        ]
    }

    try:
        response = requests.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            data=json.dumps(payload)
        )
        response.raise_for_status()

        content = response.json()["choices"][0]["message"]["content"]

        # Extraire proprement la liste JSON
        start = content.find('[')
        end = content.rfind(']')
        if start == -1 or end == -1 or end <= start:
            return JsonResponse({"error": "No valid JSON found in API response"}, status=500)

        json_str = content[start:end + 1]
        market_data = json.loads(json_str)

        # Convertir les prix en DZD (1 € ≈ 145 DZD)
        for item in market_data:
            try:
                price_eur = float(item["Price"].split()[0])
                price_dzd = round(price_eur * 145)
                item["Price"] = f"{price_dzd} DZD/t"
            except Exception:
                item["Price"] = "N/A"

        return JsonResponse({"market_data": market_data})

    except Exception as e:
        return JsonResponse({"error": "Server error", "details": str(e)}, status=500)







def iot_sensor(request):
    global latest_soil_data

    N = latest_soil_data.get('N', 50)
    P = latest_soil_data.get('P', 40)
    K = latest_soil_data.get('K', 30)
    ph = latest_soil_data.get('ph', 6.5)

    sensors = [
        {
            "id": 1,
            "type": "ph",
            "icon": "🧪",
            "value": f"{ph}",
            "label": "Soil pH",
            "location": "East Plot",
            "status": "optimal" if 6.0 <= ph <= 7.5 else "warning"
        },
        {
            "id": 2,
            "type": "nitrogen",
            "icon": "🧫",
            "value": f"{N} mg/kg",
            "label": "Nitrogen (N)",
            "location": "Central Plot",
            "status": "optimal" if 40 <= N <= 80 else "warning"
        },
        {
            "id": 3,
            "type": "phosphorus",
            "icon": "🔬",
            "value": f"{P} mg/kg",
            "label": "Phosphorus (P)",
            "location": "Central Plot",
            "status": "optimal" if 30 <= P <= 60 else "warning"
        },
        {
            "id": 4,
            "type": "potassium",
            "icon": "⚗️",
            "value": f"{K} mg/kg",
            "label": "Potassium (K)",
            "location": "Central Plot",
            "status": "optimal" if 20 <= K <= 50 else "warning"
        }
    ]

    stats = [
        {"title": "pH du Sol", "value": ph, "color": "#8B5CF6"},
        {"title": "Azote (N)", "value": N, "color": "#F59E0B"},
        {"title": "Phosphore (P)", "value": P, "color": "#10B981"},
        {"title": "Potassium (K)", "value": K, "color": "#3B82F6"},
    ]

    return JsonResponse({"sensors": sensors, "stats": stats})







def iot_sensors(request):
    global latest_soil_data

    temperature = latest_soil_data.get('temperature', 34)
    humidity = latest_soil_data.get('humidity', 30)
    rainfall = latest_soil_data.get('rainfall', 0.0)
    sunlight = latest_soil_data.get('ph', 7)

    sensors = [
        {
            "id": 1,
            "type": "moisture",
            "icon": "💧",
            "value": f"{humidity}%",
            "label": "Soil Moisture",
            "location": "Corn Field - West",
            "status": "warning" if humidity < 40 else "optimal"
        },
        {
            "id": 2,
            "type": "temperature",
            "icon": "🌡️",
            "value": f"{temperature}°C",
            "label": "Temperature",
            "location": "North Greenhouse",
            "status": "optimal" if 15 <= temperature <= 30 else "warning"
        },
        {
            "id": 3,
            "type": "rain",
            "icon": "☔",
            "value": f"{rainfall} mm",
            "label": "Precipitation",
            "location": "Weather Station",
            "status": "optimal" if rainfall < 5 else "warning"
        },
       {
    "id": 4,
    "type": "ph",
    "icon": "🧪",
    "value": f"{latest_soil_data.get('ph', 6.5)}",
    "label": "pH du Sol",
    "location": "East Plot",
    "status": "optimal" if 6.0 <= latest_soil_data.get('ph', 6.5) <= 7.5 else "warning"
}
    ]

    return JsonResponse({"sensors": sensors})

 