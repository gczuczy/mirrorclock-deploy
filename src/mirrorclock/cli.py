'''
Command line interface for our enterprise business logic
'''

import mirrorclock.bi

def main():
    '''
    Returns the mirrored wallclock, as a formatted string
    '''
    h,m = mirrorclock.bi.mirrorClock()

    print('{h:0>2}:{m:0>2}'.format(h=h, m=m))
    pass
