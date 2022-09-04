#!/bin/python3

import pytz
from datetime import datetime
from astral import LocationInfo
from astral.sun import sun

loc = LocationInfo(name='HAJ', region='NDS, DE', timezone='Europe/Berlin', latitude=52.13, longitude=-8.7)
print(loc)
print(loc.observer)

now=datetime.now().strftime('%Y-%m-%d %H:%M:%S')
print(f"It's      : {now}")

s = sun(loc.observer, date=now, tzinfo=loc.timezone)
for key in ['dawn', 'dusk', 'noon', 'sunrise', 'sunset']:
    #print(f'{key:10s}:', s[key])
    if key == 'dawn':
        dawn=s[key]
    if key == 'dusk':
        dusk=s[key]

print(dusk)
print(dawn)

#if now > dusk and now < dawn:
    #print("use light theme")
#else:
    #print("use dark  theme")
