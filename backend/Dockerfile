# Stage 1: Build .NET app
FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine AS build
WORKDIR /source

# Copy solution and project files
COPY Balenthiran.EarnYourBeers.slnx .
COPY Balenthiran.EarnYourBeers.WebApi/*.csproj ./Balenthiran.EarnYourBeers.WebApi/
COPY Balenthiran.EarnYourBeers.Abstractions/*.csproj ./Balenthiran.EarnYourBeers.Abstractions/
COPY Balenthiran.EarnYourBeers.DataModels/*.csproj ./Balenthiran.EarnYourBeers.DataModels/
COPY Balenthiran.EarnYourBeers.DomainModels/*.csproj ./Balenthiran.EarnYourBeers.DomainModels/
COPY Balenthiran.EarnYourBeers.Services/*.csproj ./Balenthiran.EarnYourBeers.Services/
COPY Balenthiran.EarnYourBeers.EntityModels/*.csproj ./Balenthiran.EarnYourBeers.EntityModels/ 
COPY Balenthiran.EarnYourBeers.Database/*.csproj ./Balenthiran.EarnYourBeers.Database/
COPY Balenthiran.EarnYourBeers.Tests/*.csproj ./Balenthiran.EarnYourBeers.Tests/
COPY Balenthiran.EarnYourBeers.SourceGenerators/*.csproj ./Balenthiran.EarnYourBeers.SourceGenerators/
# Restore dependencies
# NOTE: `dotnet restore` with no argument restores Balenthiran.EarnYourBeers.slnx, so EVERY project
# listed there must have its .csproj copied above — including test projects, which are
# not published. Adding a project to the solution without a COPY line here breaks the
# image build only, and only on a push to main, long after CI has gone green.
RUN dotnet restore

# Copy all source files
COPY . .

# Build and publish
RUN dotnet publish Balenthiran.EarnYourBeers.WebApi/Balenthiran.EarnYourBeers.WebApi.csproj -c Release -o /app/publish

# Stage 2: Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:10.0-alpine
WORKDIR /app
COPY --from=build /app/publish .

# Expose port (default ASP.NET Core port is 8080 in .NET 8+)
EXPOSE 8080

ENTRYPOINT ["dotnet", "Balenthiran.EarnYourBeers.WebApi.dll"]
