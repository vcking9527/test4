ARG APP_VERSION=1.0.0

# https://hub.docker.com/_/microsoft-dotnet
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
LABEL stage=intermediate
ARG APP_VERSION

# install npm && nuxt
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y libpng-dev libjpeg-dev curl libxi6 build-essential libgl1-mesa-glx
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

WORKDIR /source
  
# copy csproj and restore as distinct layers
COPY *.sln .
COPY src/common/TYMC.Logging/*.csproj ./src/common/TYMC.Logging/
COPY src/common/TYMC.Domain/*.csproj ./src/common/TYMC.Domain/
COPY src/common/TYMC.Application/*.csproj ./src/common/TYMC.Application/
COPY src/common/TYMC.Infrastructure/*.csproj ./src/common/TYMC.Infrastructure/
COPY src/common/TYMC.WebApi/*.csproj ./src/common/TYMC.WebApi/
COPY src/TYMC.CCTV.Domain/*.csproj ./src/TYMC.CCTV.Domain/
COPY src/TYMC.CCTV.Application/*.csproj ./src/TYMC.CCTV.Application/
COPY src/TYMC.CCTV.Infrastructure/*.csproj ./src/TYMC.CCTV.Infrastructure/ 
COPY src/TYMC.CCTV.WebApi/*.csproj ./src/TYMC.CCTV.WebApi/

# execute nuget dll restore, avoid testing
RUN dotnet restore src/TYMC.CCTV.WebApi/TYMC.CCTV.WebApi.csproj
  
# can't not include folder obj/**, use the .dockerignore or it will cause error
COPY src/common/tymc-client-shared/. ./src/common/tymc-client-shared/
COPY src/common/TYMC.Logging/. ./src/common/TYMC.Logging/
COPY src/common/TYMC.Domain/. ./src/common/TYMC.Domain/
COPY src/common/TYMC.Application/. ./src/common/TYMC.Application/
COPY src/common/TYMC.Infrastructure/. ./src/common/TYMC.Infrastructure/
COPY src/common/TYMC.WebApi/. ./src/common/TYMC.WebApi/
COPY src/client-app/. ./src/client-app/
COPY src/TYMC.CCTV.Domain/. ./src/TYMC.CCTV.Domain/
COPY src/TYMC.CCTV.Application/. ./src/TYMC.CCTV.Application/
COPY src/TYMC.CCTV.Infrastructure/. ./src/TYMC.CCTV.Infrastructure/
COPY src/TYMC.CCTV.WebApi/. ./src/TYMC.CCTV.WebApi/

# 設定npm套件的使用權限，否則preinstall、postinstall會失敗
RUN npm config set unsafe-perm true

# -c: Configuration
# -o: output file
# --no-restore: no use dotnet restore
RUN dotnet publish src/TYMC.CCTV.WebApi/TYMC.CCTV.WebApi.csproj -c release -o /app -p:Version=${APP_VERSION} -p:OpenApiCli=false --no-restore -nowarn:CS8618

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
ARG APP_VERSION
ARG PORT=7001

ENV ASPNETCORE_URLS=http://*:${PORT}
LABEL AppVersion=${APP_VERSION}

# install System.Drawing.Common
RUN apt-get update && apt-get install -y libgdiplus libc6-dev && ln -s /usr/lib/libgdiplus.so /usr/lib/gdiplus.dll

WORKDIR /app
COPY --from=build /app ./
 
EXPOSE ${PORT}
ENTRYPOINT ["dotnet", "TYMC.CCTV.WebApi.dll"]