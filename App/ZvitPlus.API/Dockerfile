FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY ZvitPlus.API/ZvitPlus.API.csproj ZvitPlus.API/
COPY ZvitPlus.BLL/ZvitPlus.BLL.csproj ZvitPlus.BLL/
COPY ZvitPlus.DAL/ZvitPlus.DAL.csproj ZvitPlus.DAL/
RUN dotnet restore ZvitPlus.API/ZvitPlus.API.csproj

COPY ZvitPlus.API/ ZvitPlus.API/
COPY ZvitPlus.BLL/ ZvitPlus.BLL/
COPY ZvitPlus.DAL/ ZvitPlus.DAL/
RUN dotnet publish ZvitPlus.API/ZvitPlus.API.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app/publish .
RUN mkdir -p /app/storage

ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "ZvitPlus.API.dll"]