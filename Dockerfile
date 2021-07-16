# NuGet restore
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY *.sln .
COPY XUnitTestProject2/*.csproj XUnitTestProject2/
COPY UnitTest_Mock/*.csproj UnitTest_Mock/
RUN dotnet restore
COPY . .

# testing
FROM build AS testing
WORKDIR /src/UnitTest_Mock
RUN dotnet build
WORKDIR /src/XUnitTestProject2
RUN dotnet test

# publish
FROM build AS publish
WORKDIR /src/UnitTest_Mock
RUN dotnet publish -c Release -o /src/publish

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS runtime
WORKDIR /app
COPY --from=publish /src/publish .
# ENTRYPOINT ["dotnet", "Colors.API.dll"]
# heroku uses the following
CMD ASPNETCORE_URLS=http://*:$PORT dotnet UnitTest_Mock.dll
