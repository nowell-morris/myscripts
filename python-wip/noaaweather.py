import requests
import pyld 
import json

#noaaurl = "https://api.weather.gov/points/38.8894,-77.0352"
noaaurl = "https://api.weather.gov/points/33.4231,-111.5461"
noaaurlforecast = "https://api.weather.gov/gridpoints/PSR/177,53/forecast"
# lat=33.4231&lon=-111.5461
noaarequest = requests.get(noaaurlforecast)
#print(type(noaarequest))
noaajson = noaarequest.content

#print(noaajson)

noaadict = noaarequest.json()
print(json.dumps(noaadict))

