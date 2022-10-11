# mirrorclock deploy

This repository is an example deployment for the mirrorclock project into AWS ECS.

The mirrorclock repo is pulled in as a subtree for convenience.

# Flask deployment options

There are many deployment options for a Flask app into AWS. Lambdas, beanstalk, containerizing, etc.

Right now we're going for ECR, and within that there are two options: build a python docker image, or
a general image and pulling the config it. For simplicity, it's a python image and the flask app is
running in a standalone mode inside, that's why the image is called -standalone. The standalone mode
is being implemented with gunicorn right now, to avoid using flask's development mode.

The other container option would be a general linux container, pulling in the app from pip, adding
uwsgi and nginx, then configuring the nginx to route /api to the uwsgi daemon. This has the option
to also add a web user interface served by nginx, which is not part of this project.

However, flask is also able to serve files, but I consider that a rather suboptimal solution to go for.
There's a reason why we detach the static content from the APIs.

# Build

Due to not having CI/CD service configured to handle the build, the (p)makefile helps with that.

The following make variables can be set to configure a few things:
 - VERSION: Version to deploy, default is 0.4 as of now
 - AWSPROFILE: the profile to use for AWS (as in ~/.aws/credentials), by default, none is given so the default is used
 - AWSREGION: region to deploy to
 - REPONAME: ECR repository name to push to, defaults to the image's name

Example:

    $ make push
    aws  ecr get-login-password | docker login --username AWS --password-stdin  560899595692.dkr.ecr.eu-central-1.amazonaws.com 2> /dev/null
    Login Succeeded
    docker build --tag gczuczy/mirrorclock-standalone:0.4  --build-arg VERSION=0.4 mirrorclock-standalone/
    [+] Building 21.5s (11/11) FINISHED
     => [internal] load build definition from Dockerfile                                                               0.0s
     => => transferring dockerfile: 38B                                                                                0.0s
     => [internal] load .dockerignore                                                                                  0.0s
     => => transferring context: 2B                                                                                    0.0s
     => resolve image config for docker.io/docker/dockerfile:1                                                         4.2s
     => CACHED docker-image://docker.io/docker/dockerfile:1@sha256:9ba7531bd80fb0a858632727cf7a112fbfd19b17e94c4e84ce  0.0s
     => [internal] load .dockerignore                                                                                  0.0s
     => [internal] load build definition from Dockerfile                                                               0.0s
     => [internal] load metadata for docker.io/library/python:3.8-slim-bullseye                                        4.6s
     => [1/3] FROM docker.io/library/python:3.8-slim-bullseye@sha256:c8d94ad93743b388e9b1e938d7fc6b6cb973b40ac6d0449c  4.4s
     => => resolve docker.io/library/python:3.8-slim-bullseye@sha256:c8d94ad93743b388e9b1e938d7fc6b6cb973b40ac6d0449c  0.0s
     => => sha256:c8d94ad93743b388e9b1e938d7fc6b6cb973b40ac6d0449c3718e418d27d324a 1.86kB / 1.86kB                     0.0s
     => => sha256:9caef02be4d28ccf60f16c4e4931eecd2307f68dad9be100e6c5dcf7673e7154 1.37kB / 1.37kB                     0.0s
     => => sha256:fd882d84244954b0b4c237011d2ae45be344c2dda810d7fcff90493156513c05 7.53kB / 7.53kB                     0.0s
     => => sha256:bd159e379b3b1bc0134341e4ffdeab5f966ec422ae04818bb69ecef08a823b05 31.42MB / 31.42MB                   1.5s
     => => sha256:de08aeb7fd50562d57cef1a49d6197d619df0b4ce52e4caeba2402c27c6e536b 1.08MB / 1.08MB                     0.5s
     => => sha256:ad171690c8d42a75092ed65232a825d1123154fe6c27db780568d631dd98544e 11.34MB / 11.34MB                   1.2s
     => => sha256:6117759e862e484badac55217d03f6b79531a87d6f90c37ecfb6d2bfc4819020 234B / 234B                         0.7s
     => => sha256:d3e8b18387e268aba476319de3db177ff80686124f6f7103fb3edc7f7a1db3fe 3.18MB / 3.18MB                     3.6s
     => => extracting sha256:bd159e379b3b1bc0134341e4ffdeab5f966ec422ae04818bb69ecef08a823b05                          1.4s
     => => extracting sha256:de08aeb7fd50562d57cef1a49d6197d619df0b4ce52e4caeba2402c27c6e536b                          0.1s
     => => extracting sha256:ad171690c8d42a75092ed65232a825d1123154fe6c27db780568d631dd98544e                          0.6s
     => => extracting sha256:6117759e862e484badac55217d03f6b79531a87d6f90c37ecfb6d2bfc4819020                          0.0s
     => => extracting sha256:d3e8b18387e268aba476319de3db177ff80686124f6f7103fb3edc7f7a1db3fe                          0.4s
     => [2/3] WORKDIR /app                                                                                             0.3s
     => [3/3] RUN pip3 install mirrorclock-gczuczy==0.4                                                                7.1s
     => exporting to image                                                                                             0.3s
     => => exporting layers                                                                                            0.3s
     => => writing image sha256:5645c56135a9bcf7938eb9b6d39c0a2ae899648a7eca40ed641685278dd57a14                       0.0s
     => => naming to docker.io/gczuczy/mirrorclock-standalone:0.4                                                      0.0s
    docker tag gczuczy/mirrorclock-standalone:0.4 560899595692.dkr.ecr.eu-central-1.amazonaws.com/mirrorclock-standalone:0.4
    docker push 560899595692.dkr.ecr.eu-central-1.amazonaws.com/mirrorclock-standalone:0.4
    The push refers to repository [560899595692.dkr.ecr.eu-central-1.amazonaws.com/mirrorclock-standalone]
    770d15ab4902: Pushed
    3f49ae40ee0e: Pushed
    5c805d10aa4a: Pushed
    23694d503f85: Pushed
    2d21612cfa96: Pushed
    1169b1563e05: Pushed
    fe7b1e9bf792: Pushed
    0.4: digest: sha256:f177b161b3539a62d8ca5685e70ddae108605716659b7025510ead99a016ac46 size: 1788
    
# Terraform deployment

Terraform is used as a deployment. The script provisions a bit more that what is strictly required for the container to run, as an example.
Apart from the required public subnet, there's a pair of them, and there's also a pair of private subnets, and a comment out example of a natgw
for the private subnets. Also, there's a load balancer and ASG, to automatically scale an application.

The container is being run in an ECS cluster, and - since the changes in the 1.4 - ECS is granted access to ECR sing VPC Endpoints. Since ECR is using
S3 under the hood, an S3 endpoint is required as well, and S3 access is controlled on this endpoint's policy. By the configuration only the S3 bucket belonging
to the ECR service can be accessed using this method. Therefore in an application is to access S3 buckets from within his VPC, it the policy has to be adjusted
accordingly.

The terraform module outputs the loadbalancer's DNS hostname, which can be used to use the example service.

In a production environment this should be split into multiple parts. Right now all the ECR creation, policies and actual deployment unit are in the same terraform root module. In the real world you create one repository per region, and if needed give access to other other accounts. Create the policies once per region and account pair. This means, the complete thing should be split into 3 terraform stares, and the deployment root module should query the ECR and policy states as remote states, and use those values for the deployment.

Also, in a real world scenario, local state shouldn't be used, but some kind of a remote storage like S3, that can be accessed by multiple users and multiple other modules.
