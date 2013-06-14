#!/usr/bin/env python
import datetime
import logging

import nacl


def main():
    nacl.setup_file_logging()
    start = datetime.datetime.now()
    try:
        nacl.production_push()
    except:
        logging.exception('Exiting on exception')
    end = datetime.datetime.now()
    duration = (end - start).total_seconds()
    minutes = duration / 60
    seconds = int(duration % 60)
    logging.info('Done in %d minutes %d seconds.' % (minutes, seconds))


if __name__ == '__main__':
    main()
