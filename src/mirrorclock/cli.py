'''
Command line interface for our enterprise business logic
'''

import mirrortime.bi

def main():
    '''
    Returns the mirrored wallclock, as a formatted string
    '''
    h,m = mirrortime.bi.mirrorClock()

    print('{h:0>2}:{m:0>2}'.format(h=h, m=m))
    pass
