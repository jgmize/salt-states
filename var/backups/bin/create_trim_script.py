#!/usr/bin/env python

import datetime
import glob
import re

verbose = False
today = datetime.datetime.today()

years = dict()
for y in xrange(2010, today.year):
    years[y+1] = (today, None)

months = dict()
for m in xrange(0, 12):
    first_day = datetime.date(year=today.year, month=m+1, day=1)
    if first_day > today.date():
        first_day = datetime.date(year=today.year-1, month=m+1, day=1)
    if first_day >= datetime.date(year=2011, month=1, day=1):
        months[(first_day.year, first_day.month)] = (today, None)

weeks = dict()
friday = today
while friday.weekday() != 4:
    friday -= datetime.timedelta(days=1)
for w in xrange(4):
    last_friday = friday - datetime.timedelta(days=(w * 7))
    weeks[(last_friday.year, last_friday.month, last_friday.day)] = (today, None)

days = dict()
for d in xrange(7):
    day = today - datetime.timedelta(days=d)
    days[(day.year, day.month, day.day)] = (today, None)

off_hour=[]
no_match=[]

backups = glob.glob("/var/backups/database/*.sql.gz")
backups.sort()
date_re = re.compile(r"""(?x)    # Be verbose
   ^/var/backups/database/       # File path
   (?P<host>[^_]*)_              # Hostname
   (?P<year>\d{4})-              # The year
   (?P<month>\d{2})-             # The month
   (?P<day>\d{2})-               # The day
   (?P<hour>\d{2})-              # The hour
   (?P<minute>\d{2})             # The minute
   \.sql\.gz$                    # The file extension
""")
for b in backups:
    x = date_re.match(b)
    if x:
        y = int(x.group('year'))
        m = int(x.group('month'))
        d = int(x.group('day'))
        h = int(x.group('hour'))
        minute = int(x.group('minute'))
        date = datetime.datetime(year=y, month=m, day=d, hour=h, minute=minute)
        
        # If the backup wasn't done on the hour, it might be special 
        if int(minute) != 0:
            off_hour.append(b)

        # Use the earliest date in that year     
        if (y in years) and years[y][0] > date:
            years[y] = (date, b)

        # Use the earliest date in that month
        month = (y,m)
        if month in months and months[month][0] > date:
            months[month] = (date, b)

        weekday = date
        while (weekday.weekday() != 4):
            weekday -= datetime.timedelta(days=1)
        wd = (weekday.year, weekday.month, weekday.day)
        if wd in weeks and weeks[wd][0] > date:
            weeks[wd] = (date, b)

        day = (y,m,d)
        if day in days and days[day][0] > date:
            days[day] = (date, b)
    else:
       no_match.append(b)

keeps = dict()

def add_sets_from_items(group, name):
    global keeps
    for k,v in group.items():
        if v[1] is None:
            raise Exception('No entry for %s %s!' % (name, k))
        else:
            sets = keeps.setdefault(v[1],set())
            assert(name not in sets)
            sets.add(name)
            keeps[v[1]] == sets

def add_sets_from_list(l, name):
    global keeps
    for path in l:
        sets = keeps.setdefault(path, set())
        assert(name not in sets)
        sets.add(name)
        keeps[path] = sets

add_sets_from_items(years, 'year')
add_sets_from_items(months, 'month')
add_sets_from_items(days, 'day')
add_sets_from_items(weeks, 'week')
add_sets_from_list(off_hour, 'off-hour')
add_sets_from_list(no_match, 'unknown')

deletes = set(backups)
deletes -= set(keeps.keys())

print "#!/bin/sh"
for b in backups:
   if b in deletes:
       log=b.replace('.sql.gz','.log')
       print "rm", b, log
   else:
       print "echo Keeping %s, in sets %s" % (b, ",".join(keeps[b]))

