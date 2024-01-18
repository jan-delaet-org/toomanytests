FROM python:3.12.1-alpine3.18 AS build

RUN apk update && apk upgrade
RUN addgroup --gid 1001 app \
    && adduser -S -G app --uid 1001 app
USER 1001
WORKDIR /app
COPY --chown=app:app requirements.txt .
ENV PATH="/home/app/.local/bin:${PATH}"
RUN python -m venv .venv
RUN pip install --no-cache-dir --upgrade -r requirements.txt
RUN rm -rf requirements.txt

FROM python:3.12.1-alpine3.18

RUN apk update && apk upgrade
RUN addgroup --gid 1001 app \
    && adduser -S -G app --uid 1001 app
USER 1001
WORKDIR /app
COPY --chown=app:app . .
COPY --from=build --chown=app:app /app/.venv .
ENV PATH=".venv/bin:$PATH"
EXPOSE 6980
CMD ["main.py"]