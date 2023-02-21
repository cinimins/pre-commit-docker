FROM python:3.12.0a5-alpine3.17 AS builder

RUN apk add git # for cloning
RUN pip3 install pre-commit
RUN wget -O - https://github.com/pre-commit/pre-commit/releases/download/v3.0.4/pre-commit-3.0.4.pyz > /bin/pre-commit.pyz

WORKDIR /repo

# Make a n empty git repo to trigger downloading the pre-commit repos
RUN git init
COPY .pre-commit-config.yaml .
RUN python3 /bin/pre-commit.pyz install
RUN python3 /bin/pre-commit.pyz run --all-files

FROM python:3.12.0a5-alpine3.17

RUN pip3 install pre-commit
COPY --from=builder /bin/pre-commit.pyz /bin/pre-commit.pyz
COPY --from=builder /root/.cache /root/.cache

WORKDIR /repo

USER 1001
