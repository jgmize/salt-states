#!/usr/bin/env python
import datetime
import functools
import logging
import logging.handlers
import os.path

_caller = None
_client = None
_logging_setup = None


def setup_logging_once(name):
    def decorator(f):
        @functools.wraps(f)
        def wrapper(*args, **kwargs):
            global _logging_setup
            if _logging_setup:
                return
            else:
                _logging_setup = name
                return f(*args, **kwargs)
        return wrapper
    return decorator


@setup_logging_once('file_logging')
def setup_file_logging():
    my_dir = os.path.split(__file__)[0]
    log_dir = os.path.abspath(os.path.join(my_dir, '..', 'log'))
    log_file = os.path.join(log_dir, 'production_push.log')
    log_exists = os.path.exists(log_file)
    logging.basicConfig(
        format='%(levelname)s:%(message)s', level=logging.DEBUG)
    logger = logging.getLogger()
    logger.info('Logging production push to %s', log_file)
    handler = logging.handlers.RotatingFileHandler(log_file, backupCount=50)
    formatter = logging.Formatter(
        fmt='%(asctime)s:%(levelname)s:%(message)s')
    handler.setFormatter(formatter)
    if log_exists:
        handler.doRollover()
    logger.addHandler(handler)


@setup_logging_once('console_logging')
def setup_console_logging():
    logging.basicConfig(
        format='%(levelname)s:%(message)s', level=logging.DEBUG)
    logger = logging.getLogger()
    if not logger.isEnabledFor(logging.DEBUG):
        logger.setLevel(logging.DEBUG)


@setup_logging_once('no_logging')
def no_logging():
    pass


def caller():
    global _caller, _logging_setup
    if not _logging_setup:
        print (
            "Turning on console logging."
            "  Call no_logging() first if you didn't want it.")
        setup_console_logging()
    if not _caller:
        # Importing salt.client adds a NullHandler
        # This is OK, as long as logging.basicConfig was called first
        import salt.client
        _caller = salt.client.Caller()
    return _caller


def client():
    global _client, _logging_setup
    if not _logging_setup:
        print (
            "Turning on console logging."
            "  Call no_logging() first if you didn't want it.")
        setup_console_logging()
    if not _client:
        # Importing salt.client adds a NullHandler
        # This is OK, as long as logging.basicConfig was called first
        import salt.client
        _client = salt.client.LocalClient()
    return _client


def log_time(name):
    def decorator(func):
        def wrapped(target, *args, **kwargs):
            start = datetime.datetime.now()
            ret = func(target, *args, **kwargs)
            end = datetime.datetime.now()
            duration = (end - start).total_seconds()
            minutes = duration / 60
            seconds = int(duration % 60)
            logging.debug(
                'TIMING: %d min %d sec for %s:%s args:%s kwargs:%s' % (
                    minutes, seconds, target, name, args, kwargs))
            return ret
        return wrapped
    return decorator


class RunCmdException(Exception):
    pass


@log_time('state.highstate')
def highstate(target, *args, **kwargs):
    kwargs.setdefault('timeout', 30 * 60)
    logging.info('%s:state.highstate args:%s kwargs:%s', target, args, kwargs)
    result = client().cmd(target, 'state.highstate', *args, **kwargs)
    for k, d in result.iteritems():
        logging.info(k)
        if isinstance(d, dict):
            for key, value in d.iteritems():
                logging.info(key)
                logging.info('%s', value)
        else:
            logging.info('%s', d)


@log_time('cmd.run_all')
def run_cmd(target, *args, **kwargs):
    kwargs.setdefault('timeout', 30 * 60)
    result_required = kwargs.pop('result_required', True)
    logging.info('%s:cmd.run_all args:%s kwargs%s', target, args, kwargs)
    result = client().cmd(target, 'cmd.run_all', *args, **kwargs)
    if result_required and not result:
        raise RunCmdException('TIMEOUT: %s:cmd.run_all args:%s kwargs%s' %
                              (target, args, kwargs))
    for k, d in result.iteritems():
        logging.info(k)
        try:
            stderr = d.get('stderr', '<not in result>')
        except:
            raise RunCmdException(d)  # d is a traceback, not a dict
        else:
            logging.info('stderr:%s', stderr)
            logging.info('stdout:%s', d.get('stdout', '<not in result>'))
            retcode = d.get('retcode', '<not in result>')
            if retcode != 0:
                raise RunCmdException('nonzero retcode %s' % retcode)


def pillar_get(key):
    return caller().function('pillar.get', key)


def hg_pull(target, cwd=None, source=None, user=None):
    cwd = cwd or pillar_get('consumeraffairs_path')
    user = user or pillar_get('consumeraffairs_user')
    cmd = 'hg pull'
    if source:
        cmd += ' ' + source
    return run_cmd(target, [cmd], kwarg=dict(cwd=cwd, runas=user))


def hg_heads(target, cwd=None, branch=None, user=None):
    cwd = cwd or pillar_get('consumeraffairs_path')
    user = user or pillar_get('consumeraffairs_user')
    cmd = 'hg heads'
    if branch:
        cmd += ' ' + branch
    return run_cmd(target, [cmd], kwarg=dict(cwd=cwd, runas=user))


def update_pip(target):
    pip_install = '%s install -r %s/requirements.txt' % (
        pillar_get('consumeraffairs_pip'), pillar_get('consumeraffairs_path'))
    user = pillar_get('consumeraffairs_user')
    return run_cmd(target, [pip_install], kwarg={'runas': user})


def run_manage(target, command):
    cwd = pillar_get('consumeraffairs_path')
    full_cmd = '%s %s/manage.py %s' % (
        pillar_get('consumeraffairs_python'), cwd, command)
    user = pillar_get('consumeraffairs_user')
    return run_cmd(
        target, [full_cmd],
        kwarg={'runas': user, 'cwd': cwd})


def run_unit_tests(target):
    return run_manage(target, 'test -x')


def restart_gunicorn(target):
    return run_cmd(target, ['supervisorctl restart gunicorn'])


def restart_gunicorn_org(target):
    return run_cmd(target, ['supervisorctl restart gunicorn_org'])


def celery_maintenance_mode(target, mode=1):
    target = target or pillar_get('consumeraffairs_celery_servers')
    return client().cmd(
        target, 'grains.setval', ['celery_maintenance_mode', mode])


def celery_production_mode(target=None):
    target = target or pillar_get('consumeraffairs_celery_servers')
    return celery_maintenance_mode(target, mode=0)


def inspect_celery(target=None):
    target = target or pillar_get('consumeraffairs_celery_servers')
    return run_manage(target, 'celery inspect active -t 5')


def kill_celery(target):
    run_cmd(
        target,
        [pillar_get('consumeraffairs_path') + '/bin/kill_celery.py'],
        kwarg={'runas': pillar_get('consumeraffairs_user')},
        result_required=False)


def stop_celery(target):
    try:
        run_cmd(target, ['service celeryd stop'])
    except:
        kill_celery(target)


def start_celery(target):
    return run_cmd(target, ['service celeryd start'])


def start_celerybeat(target):
    return run_cmd(target, ['service celerybeat start'])


def stop_celerybeat(target):
    return run_cmd(target, ['service celerybeat stop'])


def hg_push(target, push_to, branch='default'):
    return run_cmd(
        target, ['hg push %s -b %s' % (push_to, branch)],
        kwarg={'runas': pillar_get('consumeraffairs_user'),
               'cwd': pillar_get('consumeraffairs_path')})


def hg_update(target, cwd=None, rev='default', user=None):
    cwd = cwd or pillar_get('consumeraffairs_path') + '/styleguide/frontend'
    user = user or pillar_get('consumeraffairs_user')
    return run_cmd(
        target, ['hg up %s' % rev],
        kwarg={'runas': user, 'cwd': cwd})


def migrate(target):
    return run_manage(target, 'migrate --noinput')


def npm_install(target):
    cwd = pillar_get('consumeraffairs_path') + '/styleguide/frontend'
    user = pillar_get('consumeraffairs_user')
    return run_cmd(
        target, ['npm install'],
        kwarg={'runas': user, 'cwd': cwd})


def brunch_build(target):
    cwd = pillar_get('consumeraffairs_path') + '/styleguide/frontend'
    user = pillar_get('consumeraffairs_user')
    return run_cmd(
        target, ['brunch build -m'],
        kwarg={'runas': user, 'cwd': cwd})


def collectstatic(target):
    return run_manage(target, 'collectstatic --noinput')


def syncstatic(target, max_retries=10):
    count = 0
    while count < max_retries:
        try:
            return run_manage(target, 'syncstatic')
        except RunCmdException, e:
            logging.info('syncstatic %d: %s', count, e)
            count += 1
    raise e


def ping_statsd(target, key):
    return run_manage(target, 'statsd_ping --key %s' % key)


def calling_user():
    import os
    user = os.environ.get('USER')
    sudo_user = os.environ.get('SUDO_USER')
    return sudo_user or user


def clearpyc(target):
    cwd = pillar_get('consumeraffairs_path')
    return run_cmd(target, [cwd + '/bin/clearpyc'], kwarg={'cwd': cwd})


def push_web_servers(web_servers):
    hg_pull(web_servers)
    hg_heads(web_servers, branch='default')
    hg_update(web_servers)
    highstate(web_servers)
    update_pip(web_servers)
    npm_install(web_servers)
    brunch_build(web_servers)
    collectstatic(web_servers)
    clearpyc(web_servers)


def staging_push():
    celery_servers = pillar_get('consumeraffairs_celery_servers')
    web_servers = pillar_get('consumeraffairs_web_servers')
    primary_server = pillar_get('consumeraffairs_primary_web_server')
    inspect_celery(celery_servers)
    stop_celery(celery_servers)
    push_web_servers(web_servers)
    syncstatic(primary_server)
    migrate(primary_server)
    restart_gunicorn(web_servers)
    restart_gunicorn_org(web_servers)
    start_celery(celery_servers)


def production_push():
    mgmt = pillar_get('consumeraffairs_mgmt')
    web_servers = pillar_get('consumeraffairs_web_servers')
    celery_servers = pillar_get('consumeraffairs_celery_servers')
    celerybeat_server = pillar_get('consumeraffairs_celerybeat_server')

    logging.info('Starting production push for %s' % calling_user())
    ping_statsd(mgmt, 'event.deploy.full.start')

    push_web_servers(mgmt)

    run_unit_tests(mgmt)
    syncstatic(mgmt)
    if celerybeat_server:
        stop_celerybeat(celerybeat_server)
    inspect_celery(celery_servers)
    stop_celery(celery_servers)
    celery_maintenance_mode(celery_servers)
    migrate(mgmt)

    push_web_servers(web_servers)
    restart_gunicorn(web_servers)
    restart_gunicorn_org(web_servers)

    celery_production_mode(web_servers)
    start_celery(celery_servers)
    if celerybeat_server:
        start_celerybeat(celerybeat_server)
    ping_statsd(mgmt, 'event.deploy.full.complete')
    logging.info('Production push complete.')
