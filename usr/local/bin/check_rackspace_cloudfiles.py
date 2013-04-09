#!/usr/bin/env python
from argparse import ArgumentParser
from time import time
import os
import logging
import urllib2

from nagiosplugin import Check, guarded, Metric, Resource, ScalarContext


class CloudFileStats(Resource):
    def __init__(
            self, username, api_key, container, timeout):
        self.username = username
        self.api_key = api_key
        self.container = container
        self.timeout = timeout

    def probe(self):
        logging.info('Getting API key')
        start_time = ident_start_time = time()
        ident_request = urllib2.Request(
            'https://identity.api.rackspacecloud.com/v1.0',
            headers={'X-Auth-Key': self.api_key,
                     'X-Auth-User': self.username})
        ident_response = urllib2.urlopen(ident_request, timeout=self.timeout)
        ident_headers = ident_response.info()
        auth_key = ident_headers.getheader('X-Auth-Token')
        storage_url = ident_headers.getheader('X-Storage-Url')
        ident_end_time = time()
        ident_time = ident_end_time - ident_start_time

        logging.info('Getting Container Size')
        cont_start_time = time()
        cont_request = urllib2.Request(
            storage_url + '/' + self.container,
            headers={'X-Auth-Token': auth_key})
        cont_request.get_method = lambda: 'HEAD'
        cont_response = urllib2.urlopen(cont_request, timeout=self.timeout)
        cont_headers = cont_response.info()
        obj_count = cont_headers.getheader('X-Container-Object-Count')
        bytes_used = cont_headers.getheader('X-Container-Bytes-Used')
        cont_end_time = end_time = time()
        cont_time = cont_end_time - cont_start_time
        total_time = end_time - start_time
        return (
            Metric('total_time', total_time, context='time'),
            Metric('item_count', obj_count, context='count'),
            Metric('bytes_used', bytes_used, context='count'),
            Metric('ident_time', ident_time, context='time'),
            Metric('container_time', cont_time, context='time'),
        )


def parse_args():
    argp = ArgumentParser()
    argp.add_argument(
        '-u', '--username', default=os.environ.get('RCLOUD_USER'),
        required=True)
    argp.add_argument(
        '-k', '--api-key', default=os.environ.get('RCLOUD_KEY'),
        required=True)
    argp.add_argument('--container', required=True)
    argp.add_argument('-t', '--timeout', default=120)
    argp.add_argument('-w', '--warn', default='30')
    argp.add_argument('-c', '--critical', default='60')
    return argp.parse_args()


@guarded
def main():
    args = parse_args()
    check = Check(
        CloudFileStats(
            args.username, args.api_key, args.container,
            float(args.timeout)))
    check.add(ScalarContext('time', args.warn, args.critical))
    check.add(ScalarContext('count', '', ''))
    check.main(timeout=args.timeout)


if __name__ == '__main__':
    main()
