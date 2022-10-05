# mirrorclock deploy

This repository is an example deployment for the mirrorclock project into AWS ECS.

The mirrorclock repo is pulled in as a subtree for convenience.

# Flask deployment options

There are many deployment options for a Flask app into AWS. Lambdas, beanstalk, containerizing, etc.

Right now we're going for ECR, and within that there are two options: build a python docker image, or
a general image and pulling the config it. For simplicity, it's a python image and the flask app is
running in a standalone mode inside, that's why the image is called -standalone.

The other container option would be a general linux container, pulling in the app from pip, adding
uwsgi and nginx, then configuring the nginx to route /api to the uwsgi daemon. This has the option
to also add a web user interface served by nginx, which is not part of this project.

However, flask is also able to serve files, but I consider that a rather suboptimal solution to go for.
There's a reason why we detach the static content from the APIs.
