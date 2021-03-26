FROM microsoft/dotnet:5.0-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443
FROM node:10-alpine as build-node
WORKDIR /ClientApp
COPY BoomBuy.Identity/ClientApp/package.json .
COPY BoomBuy.Identity/ClientApp/package-lock.json .
RUN npm install
COPY BoomBuy.Identity/ClientApp/ . 
RUN npm run build  
FROM microsoft/dotnet:5.0-sdk AS build
ENV BuildingDocker true
WORKDIR /src
COPY ["BoomBuy.Identity.csproj", "testspa/"]
RUN dotnet restore "BoomBuy.Identity.csproj"
COPY . .
WORKDIR "."
RUN dotnet build "BoomBuy.Identity" -c Release -o /app
FROM build AS publish
RUN dotnet publish "BoomBuy.Identity" -c Release -o /app
FROM base AS final
WORKDIR /app
COPY --from=publish /app .
COPY --from=build-node /ClientApp/build ./ClientApp/build
ENTRYPOINT ["dotnet", "BoomBuy.Identity"]
