FROM docker.io/ubuntu:22.04
WORKDIR /workspace
COPY . .
ENTRYPOINT [ "bash", "./generate_game_assemblies.sh" ]
