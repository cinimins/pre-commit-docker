FROM python:3.12.0a6-alpine3.17 AS base

# git for cloning modules for pre-commit (even needed for just running it on-prem)
RUN apk add --no-cache git && \
    apk add --no-cache pre-commit=3.1.1-r0 --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN pip3 install --no-cache-dir pre-commit==3.1.1

FROM base AS builder

# install libraries for building shellcheck
RUN apk add --no-cache gcc build-base libffi-dev

# make a n empty git repo to trigger downloading the pre-commit repos
WORKDIR /repo
RUN git init
COPY .pre-commit-config.yaml .
# TODO: avoid installing it to /root/.cache/pre-commit since we want to switch user context at the end (Notes: PRE_COMMIT_HOME, USER 1001)
RUN pre-commit install --install-hooks



FROM base

# install bash for running shellcheck
RUN apk add --no-cache bash # go=1.19.7-r0
# dependency for Dockerfile linting
RUN wget -q -O - https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 > /bin/hadolint

WORKDIR /repo

COPY --from=builder /root/.cache/pre-commit /root/.cache/pre-commit

CMD ["/bin/sh"]
