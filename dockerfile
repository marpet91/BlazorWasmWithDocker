FROM mcr.microsoft.com/dotnet/core/aspnet:3.0-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.0-buster AS build
WORKDIR /src
COPY ["BlazorWasmDocker.csproj", "BlazorWasmDocker/"]
RUN dotnet restore "BlazorWasmDocker/BlazorWasmDocker.csproj"
COPY . ./BlazorWasmDocker
WORKDIR "/src/BlazorWasmDocker"
RUN dotnet build "BlazorWasmDocker.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BlazorWasmDocker.csproj" -c Release -o /app/publish

FROM nginx:alpine AS final
WORKDIR /usr/share/nginx/html
COPY --from=publish /app/publish/BlazorWasmDocker/dist .
COPY nginx.conf /etc/nginx/nginx.conf

# FROM base AS final
# WORKDIR /app
# COPY --from=publish /app/publish .
# ENTRYPOINT ["dotnet", "BlazorWasmDocker.dll"]