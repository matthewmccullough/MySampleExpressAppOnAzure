FROM debian:stable-slim

LABEL "name"="DeployStatusUpdate"
LABEL "maintainer"="Alain Hélaïli <helaili@github.com>"
LABEL "version"="1.0.0"

LABEL "com.github.actions.name"="Update Deploy Status"
LABEL "com.github.actions.description"="Update the status of the GitHub deployment request"
LABEL "com.github.actions.icon"="code"
LABEL "com.github.actions.color"="yellow"

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        jq curl && \
	apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
