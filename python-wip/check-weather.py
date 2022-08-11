import requests
import pyld 
import json
import googlemaps
from datetime import datetime

 
gmaps = googlemaps.Client(key='AIzaSyCWfCDJjyo2r4L6AP4qffhC2h3Qy9EVOe0')

# Geocoding an address
# geocode_result = gmaps.geocode('1600 Amphitheatre Parkway, Mountain View, CA')


def getthelocation():
    print()
    print("Please enter your street address. No Zip needed:")
    addresstosearch = input("e.g. 123 N Center Street, Centerville, AL: ")
    # variable geocode_result is the returned object from Google's API
    geocode_result = gmaps.geocode(addresstosearch)
    # now I turn the object into json
    geocode_result_json = json.dumps(geocode_result)
    youraddress = geocode_result_json("formatted_address")


    # print(geocode_result)
    print("Your address is:", )

    #ourrequest = requests.get(currenturl)
    #owmjsonoutput = ourrequest.json()
    #description = owmjsonoutput.get("weather")[0].get("description")
    # get current temp
    #feelsliketemp = owmjsonoutput.get("main").get("feels_like")


def gettheweather(lat_var, lon_var):
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


getthelocation()