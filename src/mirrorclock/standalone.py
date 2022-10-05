'''
This submodule is executes the flask framework in a standalone mode
'''

import flask
import mirrorclock.api

app = flask.Flask(__name__)

mirrorclock.api.init(app)

application = app

if __name__ == '__main__':
    app.run(debug = False,
            host = '0.0.0.0',
            port = 80,
            threaded = True)
    pass
