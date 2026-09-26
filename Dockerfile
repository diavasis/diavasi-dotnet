FROM mcr.microsoft.com/dotnet/sdk:8.0
RUN apt-get update \
    && apt-get install -y --no-install-recommends protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY . /src
# The protoc binary shipped in Grpc.Tools segfaults on linux/arm64 (exit 139).
RUN dotnet build samples/Consume/Consume.csproj -c Release -p:Protobuf_ProtocFullPath=/usr/bin/protoc
RUN chmod +x /src/wait-ca.sh
CMD ["/bin/sh", "-c", "/src/wait-ca.sh && dotnet run --project samples/Consume/Consume.csproj -c Release --no-build -- --addr \"$DIAVASI_DATA_ADDR\" --ca \"$DIAVASI_CA\" --token \"$DIAVASI_API_TOKEN\" --group demo --consumer csharp --total 8"]
