# syntax=docker/dockerfile:1

FROM python:3.8-slim-bullseye
# be sure to enable BuildKit, DOCKER_BUILDKIT=1

WORKDIR /app

# install the application from pip
#COPY requirements.txt requirements.txt
#RUN pip3 install -r requirements.txt

# we directly use the python package
RUN pip3 install mirrorclock-gczuczy==0.3

CMD ["python3", "-m", "mirrorclock.standalone"]
