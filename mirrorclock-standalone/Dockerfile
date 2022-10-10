# syntax=docker/dockerfile:1

FROM python:3.8-slim-bullseye
# be sure to enable BuildKit, DOCKER_BUILDKIT=1

WORKDIR /app
ARG VERSION

# install the application from pip
#COPY requirements.txt requirements.txt
#RUN pip3 install -r requirements.txt

# we directly use the python package, easiest to pass VERSION
RUN pip3 install mirrorclock-gczuczy==${VERSION} gunicorn==20.1.0 requests

COPY healthcheck /app/
HEALTHCHECK --start-period=5s --interval=50s CMD /app/healthcheck

# to run using the builtin standalone mode:
#CMD ["python3", "-m", "mirrorclock.standalone"]

# probably gunicorn is better:
# gunicorn -w 1 --bind=0.0.0.0:8001 mirrorclock.wsgi:app -D
CMD ["gunicorn", "-w", "2", "--bind=0.0.0.0:80", "mirrorclock.wsgi:app"]
