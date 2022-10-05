'''
This module contains the Business Intelligance of the logic.
'''

import time

def mirrorTime(hour: int, minute: int):
    '''
    Mirrors the time visually as it would seen on a wallclock.
    Returns a tuple as (hour, minute).

    Parameters are hour and minute, 1<=hour<13, 0<=minute<60
    '''

    if hour < 1 or hour > 12:
        raise ValueError('Invalid value for hour({v})'.format(v=hour))

    if minute <0 or minute >=60:
        raise ValueError('Invalid value for minute({v})'.format(v=minute))

    h = 12-(hour+1)
    m = 60-minute

    if h == 0: h = 12
    if h == -1: h = 11

    return (h, m)

def mirrorClock():
    '''
    Mirrors the current time using mirrorTime
    '''

    tm = time.localtime()
    hour = tm.tm_hour if tm.tm_hour <= 12 else tm.tm_hour - 12
    return mirrorTime(hour, tm.tm_min)
