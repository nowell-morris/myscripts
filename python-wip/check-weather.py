from abc import get_cache_token
import requests
import json
import googlemaps
from datetime import datetime
import urwid

 
gmaps = googlemaps.Client(key='AIzaSyCWfCDJjyo2r4L6AP4qffhC2h3Qy9EVOe0')

# Geocoding an address
# geocode_result = gmaps.geocode('1600 Amphitheatre Parkway, Mountain View, CA')


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
    
def exit_on_q(key):
    if key in ('q', 'Q'):
        raise urwid.ExitMainLoop()


xandy = getthelocation()
lati_var = xandy['lat']
long_var = xandy['lng']
gettheweather(lati_var, long_var)

palette = [
    ('banner', 'black', 'light gray'),
    ('streak', 'black', 'dark red'),
    ('bg', 'black', 'dark blue'),]

txt = urwid.Text(('banner', u" Hello World "), align='center')
map1 = urwid.AttrMap(txt, 'streak')
fill = urwid.Filler(map1)
map2 = urwid.AttrMap(fill, 'bg')
loop = urwid.MainLoop(map2, palette, unhandled_input=exit_on_q)
loop.run()