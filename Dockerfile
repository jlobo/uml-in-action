FROM openjdk:17-alpine

ARG PLANTUML_VERSION=1.2021.9
ARG LANG=en_US.UTF-8

WORKDIR /app
RUN apk add --no-cache bash graphviz ttf-droid ttf-droid-nonlatin \
    && apk add --no-cache --virtual tools curl \
    && curl -L https://sourceforge.net/projects/plantuml/files/plantuml-nodot.${PLANTUML_VERSION}.jar/download -o /app/plantuml.jar \
    && curl -L http://beta.plantuml.net/plantuml-jlatexmath.zip -o /app/jlatex.zip \
    && unzip /app/jlatex.zip -d /app \
    && rm /app/jlatex.zip \
    && apk del tools

COPY "entrypoint.sh" "/app/entrypoint.sh"
ENTRYPOINT ["/app/entrypoint.sh"]
CMD [ "-h" ]
