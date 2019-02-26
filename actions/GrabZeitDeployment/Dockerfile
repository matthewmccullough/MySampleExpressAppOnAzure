FROM alpine:latest

LABEL version="1.0.0"
LABEL "name"="GrabZeitDeployment"
LABEL maintainer="Alain Hélaïli <helaili@github.com>"
LABEL com.github.actions.name="Grab Zeit Deployment Id"
LABEL com.github.actions.description="Grab the Zeit Deployment Id from a log file"
LABEL com.github.actions.icon="triangle"
LABEL com.github.actions.color="blue"

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
