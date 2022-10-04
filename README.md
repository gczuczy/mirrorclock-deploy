# mirrorclock

This is an example repository for flask-restful usage, and packaging it for pypi. The logic used is the mirrored wallclock. Apart from the REST endpoint, there is a command line tool which uses the same logic to test the functionality.

The mirrorclock.wsgi:app entrypoint can be supplied to uwsgi for publication over HTTP.

# Installation

You can build it from the repo, or simply get it from pypi:

``
pip install mirrorclock-gczuczy
``

# Usage

Using the command line client:
``
$ date
Tue Oct  4 09:35:10 UTC 2022
$ mirrorclock
02:25
``

From python:
``
$ python3
Python 3.8.13 (default, Jul 22 2022, 15:16:53)
[Clang 14.0.3 (https://github.com/llvm/llvm-project.git llvmorg-14.0.3-0-g1f914 on freebsd13
Type "help", "copyright", "credits" or "license" for more information.
>>> import mirrorclock.bi
>>> mirrorclock.bi.mirrorClock()
(2, 24)
>>> mirrorclock.bi.mirrorTime(4, 20)
(7, 40)
>>> mirrorclock.bi.mirrorTime(5, 25)
(6, 35)
>>> mirrorclock.bi.mirrorTime(11, 58)
(12, 2)
>>> print(mirrorclock.bi.mirrorTime.__doc__)

    Mirrors the time visually as it would seen on a wallclock.
        Returns a tuple as (hour, minute).

    Parameters are hour and minute, 1<=hour<13, 0<=minute<60
``

Over the REST API, there is a single endpoint. Using GET, it mirrors the current system clock, using POST,
a supplied time will be mirrored (set the host envvar accordingly):
``
$ curl -XGET http://$host/api/v1/mirrortime
{"status": "success", "string": "02:22", "hour": 2, "minute": 22}
$ curl -XPOST -H 'Content-type: application/json' -d '{"hour": 4, "minute": 20}' http://$host/api/v1/mirrortime
{"status": "success", "string": "07:40", "hour": 7, "minute": 40}
``

# TODO

Add unit tests
