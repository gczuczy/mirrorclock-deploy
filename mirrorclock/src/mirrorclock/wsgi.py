'''
WSGI interface for our Enterprise Logic's REST-like API
'''

import flask
import mirrorclock.api

app = flask.Flask(__name__)

mirrorclock.api.init(app)

application = app

def main():
    '''
    Manually runs the API
    '''

    app.run(debug = True,
            host = '0.0.0.0',
            port = 40080,
            threaded = False)
    pass
