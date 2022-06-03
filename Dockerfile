ARG BASE_IMAGE=mcr.microsoft.com/windows/servercore:ltsc2022-amd64
FROM $BASE_IMAGE

# Install Chocolatey
RUN powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

RUN choco install -y powershell-core && \
    choco install -y 7zip.install && \
    choco install -y git && \
    choco install -y nodejs-lts && \
    choco install -y dotnet-sdk --version=5.0.401 && \
    choco install -y nuget.commandline && \
    choco install -y python --version=3.9.6 && \
    choco install -y dotnetcore-sdk --version=3.1.413 && \
    choco install -y netfx-4.7.2-devpack && \
    choco install -y dotnetcore-2.2-sdk-3xx && \
    choco install -y dotnet-runtime && \
    choco install -y dotnet-6.0-sdk
    
# Example adding to path, copy file to image
# RUN setx /M PATH "%PATH%;C:\some_software"
# COPY .secret ./Users/ContainerAdministrator

RUN npm install -g node-gyp

# Example adding tools
# RUN nuget install test
# RUN dotnet tool install -g roslynator.dotnet.cli --version 0.3.2

CMD [ "powershell" ]
