import requests

api_key = 'f4d92db8c86f9be4449c95719375b214'
city = "Mesa"
url = "https://api.openweathermap.org/data/2.5/weather?q="+city+"&appid="+api_key+"&units=imperial"

request = requests.get(url)
jsonvar = request.json()
# print(jsonvar) (this is all of it)

description = jsonvar.get("weather")[0].get("description")
print("Today's forecast is", description)
temperature_min = jsonvar.get("main").get("temp_min")
# print(temperature_min)
temperature_max = jsonvar.get("main").get("temp_max")
print("With a High of",temperature_max,"and a Low of",temperature_min)
print()
print(jsonvar)