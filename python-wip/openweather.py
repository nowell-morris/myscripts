import requests
import pyld 

api_key = 'f4d92db8c86f9be4449c95719375b214'
city = "Mesa"
ourunits = "&units=imperial"

# URL and requests for current conditions
currenturl = "https://api.openweathermap.org/data/2.5/weather?q="+city+"&appid="+api_key+ourunits 
ourrequest = requests.get(currenturl)
owmjsonoutput = ourrequest.json()


## get current conditions
# get current sky
description = owmjsonoutput.get("weather")[0].get("description")
# get current temp
feelsliketemp = owmjsonoutput.get("main").get("feels_like")


## get forecast
# get temperature range
temperature_min = owmjsonoutput.get("main").get("temp_min")
# print(temperature_min)
temperature_max = owmjsonoutput.get("main").get("temp_max")

print()
# print current conditions 
print("Today's current conditions are", description, "and a Feels Like temperature of", feelsliketemp)

# print forecast
print("With a High of",temperature_max,"and a Low of",temperature_min)
print()
