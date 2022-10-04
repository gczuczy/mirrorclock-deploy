'''
This module implements a REST-like API for our Enterprise Logic
'''

from flask_restful import Resource, Api
from flask import request
import mirrorclock.bi

def init(app):
    api = Api(app)
    api.add_resource(MirrorTime, '/api/v1/mirrortime')
    pass

class MirrorTime(Resource):
    '''
    This class implements the mirrortime endpoint.
    GET returns the mirrored current wallclock time
    POST mirrors a custom time
    '''

    def get(self):
        '''
        GET returns the mirrored current wallclock time
        '''
        h,m = mirrorclock.bi.mirrorClock()
        s = '{h:0>2}:{m:0>2}'.format(h=h, m=m)
        return {'status': 'success',
                'string': s,
                'hour': h,
                'minute': m}, 200

    def post(self):
        '''
        Submit a time as a hour and minute fields in a json structure
        to be converted. Value ranges: 1<=hour<13, 0<=minute<60
        '''

        data = request.get_json()

        if 'hour' not in data or 'minute' not in data:
            return {'status': 'error',
                    'message': 'Invalid input'}, 400

        try:
            h,m = mirrorclock.bi.mirrorTime(data['hour'], data['minute'])
        except Exception as e:
            return {'status': 'error',
                    'message': str(e)}, 400
        s = '{h:0>2}:{m:0>2}'.format(h=h, m=m)
        return {'status': 'success',
                'string': s,
                'hour': h,
                'minute': m}, 200
    pass
