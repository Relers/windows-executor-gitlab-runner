# Dotnet + npm builder on windows containers
Configuration for building windows projects, no vs studio or other bloatware.
 - Windows Server 2022-ltsc
 - Install latest! VMware-tools via [url](https://packages.vmware.com/tools/releases/latest/windows/x64/) if vmware vms, or pipeline fails on random time

<details>
    <summary>Why?</summary>
Building wpf or winforms on linux host/docker leeds to error:  
[Stackoverflow](https://stackoverflow.com/questions/58116849/can-i-compile-net-core-3-wpf-application-in-linux)  
[Github-issue](https://github.com/dotnet/wpf/issues/48)  
  and better isolation from runner vm
</details>

# Installing Docker
You cannot install docker-desktop.exe on windows-server, use commands below
```
## No Hyper-V required!
# Open elevated admin Powershell and execute
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy unrestricted 
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name DockerMsftProvider -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force
# Reboot
Restart-Computer -Force
docker pull mcr.microsoft.com/windows/servercore:ltsc2022-amd64
```

# Installing Gitlab-Runner
```
mkdir C:\GitLab-Runner
cd C:\Gitlab-Runner
wget https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-windows-amd64.exe -O ./gitlab-runner.exe
./gitlab-runner.exe install
./gitlab-runner.exe start
./gitlab-runner.exe status ## gitlab-runner: Service is running
## edit config.toml concurrent to run multiple pipelines at the same time

# Registring runner to gitlab
.\gitlab-runner.exe register --non-interactive --url "https://gitlab.example.com" --registration-token "TOKEN_KEY" --executor "docker-windows" --docker-image mcr.microsoft.com/windows/servercore:ltsc2022-amd64 --description "docker_win_builder" --tag-list "docker_win_builder" --locked="true"
# Get token-key registration see below
## For a shared runner, have an administrator go to the GitLab Admin Area and click Overview > Runners
## For a group runner, go to Settings > CI/CD and expand the Runners section
## For a project-specific runner, go to Settings > CI/CD and expand the Runners section
```

# Ready
```
docker build -t gitlab.example.com/library/builder:0.1 .
docker login -u "USER" -p "PASSWORD" gitlab.example.com
docker push gitlab.example.com/library/builder:0.1
```
# Runner pulling images from private repo
For pulling images without 'docker login' use DOCKER_AUTH_CONFIG variable inside config.toml on runner
```
  shell = "powershell"
  environment = ["DOCKER_AUTH_CONFIG={\"auths\":{\"gitlab.example.com\":{\"auth\":\"YXBpOlByb2dldF9hcGlfa2\"}}}"]
  [runners.custom_build_dir]
```
Bash:
```
# Encode
echo -n "USER:PASSWORD" | base64
# Decode
echo -n "YXBpOlByb2dldF9hcGlfa2" | base64 -d
```
Powershell:
```
# Encode
[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('USER:PASSWORD'))
# Decode
[Text.Encoding]::Utf8.GetString([Convert]::FromBase64String('YXBpOlByb2dldF9hcGlfa2'))
```
