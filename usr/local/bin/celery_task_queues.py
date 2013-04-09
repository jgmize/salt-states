#!/usr/bin/env python
from redis import Redis
import sys
import traceback


def main(host, db, password, queues):
    try:
        redis = Redis(host=host, db=db, password=password)
        queue_length = {}
        exceeds_max_len = False
        for queue, max_len in queues.items():
            queue_length[queue] = redis.llen(queue)
            if queue_length[queue] > max_len:
                exceeds_max_len = True
        print queue_length
    except:
        print traceback.format_exc()
        sys.exit(2)
    else:
        if exceeds_max_len:
            sys.exit(1)


if __name__ == '__main__':
    _, host, db, password, queues_raw = sys.argv
    db = int(db)
    queues = {}
    for pair in queues_raw.split(','):
        name, raw_count = pair.split(':')
        count = int(raw_count)
        queues[name] = count
    main(host, db, password, queues)
