from abc import get_cache_token
import requests
import json
import googlemaps
from datetime import datetime


# Geocoding an address
# let's move this key out of the code and out of GH.  I can add it at the commandline as a switch
# or I should make use of KMS 
gmaps = googlemaps.Client(key='')


def getthelocation():
    print()
    print("Please enter your street address. No Zip needed:")
    addresstosearch = input("e.g. 123 N Center Street, Centerville, AL: ")
    # variable geocode_result is the returned object from Google's API
    geocode_result = gmaps.geocode(addresstosearch)

    print("Your address is:", geocode_result[0]['formatted_address'] )
    print("Your Latitude and Longitude are:", geocode_result[0]['geometry']['location'])

    return geocode_result[0]['geometry']['location']
    #    "geometry":{
        #   "location":{
            #  "lat":33.37973,
            #  "lng":-111.624673
        #   },


def gettheweather(lat_var, lon_var):
    latitudevar = format(lat_var, '.4f')
    longitudevar = format(lon_var, '.4f')
    # noaaurl = "https://api.weather.gov/points/33.4231,-111.5461"
    noaaurl = "https://api.weather.gov/points/"+latitudevar+','+longitudevar
    getforecasturl = requests.get(noaaurl) # this gets the object into memory
    noaajson = getforecasturl.content # here I am taking the object and turning it into a string  
    obtainurl = json.loads(noaajson) # here I am taking the string and turning it into json
    noaaurlforecast = obtainurl['properties']['forecast']  # this parses the json and  gets the URL for the actual forecast
    
    getobject = requests.get(noaaurlforecast)  # this gets the object into memory
    forecastcontent = getobject.content        # here I am taking the object and turning it into a string
    forecastjson = json.loads(forecastcontent) # here I am taking the string and turning it into json
    # this is the json object: forecastjson
    # print(json.dumps(forecastjson, indent=2)) # by using the json.dumps(x, indent=2) it formats the json to be readable
    # print(json.dumps(forecastjson['properties']['periods'][0], indent=2))
    howmanydays = int(input("How many days forecast do you want? (1-7): "))
    doubleup = howmanydays * 2  # this is because the json has two entries per day. one for day, one for night
    for i in range(doubleup):
        print(json.dumps(forecastjson['properties']['periods'][i], indent=2))

    # make a UI with https://rich.readthedocs.io/en/latest/console.html  

# def exit_on_q(key):
    # if key in ('q', 'Q'):
        # raise urwid.ExitMainLoop()   # this might be useful to create anyway. would have to import urwid


xandy = getthelocation()
lati_var = xandy['lat']
long_var = xandy['lng']
gettheweather(lati_var, long_var)

