FROM python:3.11-alpine AS base

ENV USER=medical
ENV HOMEDIR=/var/${USER}
ENV WORKDIR=/app/src
ENV PATH="${HOMEDIR}/.local/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1

RUN addgroup -S ${USER} \
  && export _ID=$(getent group ${USER} | cut -d: -f3) \
  && adduser -SD -h ${HOMEDIR} -G ${USER} -u $_ID ${USER} \
  && unset _ID

RUN mkdir -p ${WORKDIR} \
  && chown -R ${USER}:${USER} ${WORKDIR}
WORKDIR ${WORKDIR}


COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/ash"]


#####
# Intermediate stage to install build dependencies
#####
FROM base as builder

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
  && apk update \
  && apk add --no-cache gosu

RUN gosu ${USER} sh -c "wget -qO- https://install.python-poetry.org | python -"

COPY --chown=${USER}:${USER} pyproject.toml ${WORKDIR}
COPY --chown=${USER}:${USER} poetry.lock ${WORKDIR}
RUN chmod 644 ${WORKDIR}/pyproject.toml ${WORKDIR}/poetry.lock

RUN gosu ${USER} poetry export --output /tmp/requirements.txt


RUN gosu ${USER} pip install --user --no-compile -r /tmp/requirements.txt


#####
# Stage for local development
#####
FROM builder AS dev

ENV PYTHONPATH="${HOMEDIR}/.local/lib/python3.11/site-packages"
