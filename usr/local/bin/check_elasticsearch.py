#!/usr/bin/env python
import sys
import traceback
import base64
import urllib2
import json


def main(*args):
    try:
        failed = False
        msg = base64.b64encode('{"search":"","fields":[],"offset":0,"timeframe":30,"graphmode":"count"}')
        r = urllib2.urlopen('http://log.iso:5601/api/graph/count/30/{}/?'.format(msg))
        s = r.read()
        d = json.JSONDecoder()
        j = d.decode(s)
        total = sum([e['count'] for e in j['facets']['count']['entries']])
        failed = (total == 0)
    except:
        print traceback.format_exc()
        # script failed
        sys.exit(2)
    else:
        if failed:
            # probably no logs. ver bad.  check.
            sys.exit(1)


if __name__ == '__main__':
    # does nothing with args right now
    args = sys.argv
    main(args)
