# 로컬 개발 환경 구성 - MacOS
MacOS 개발 자를 위한 로컬 개발 환경 구성 가이드 입니다.

MacOS 애플리케이션 설치 및 Java, Node, Python, Go, Kubernetes, Terraform, Ansible 등 DevOps 를 위한 최고의 오픈 소스를 구성 할 수 있도록 돕습니다. 

- homebrew 설치
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

- oh-my-zsh 설치
```
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

- git 설치
```
brew install git
```


- sdkman 설치
```
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

- java / maven / gradle 설치 (multiple env 구성 지원)
```
sdk list java 
sdk install java <Version_Identifier>
sdk install maven
sdk install gradle
```

- node / npm / yarn 설치 (nvm 을 통한 multiple node 환경 구성)
```
brew install nvm

# [vi ~/.zshrc]
---
export NVM_DIR="$HOME/.nvm"
. "$(brew --prefix nvm)/nvm.sh"
---

nvm -v

# node & npm 설치 
nvm install node
nvm install --lts
nvm ls
node -v
npm -v

# yarn 설치
npm install -global yarn
yarn -v
```

- python 설치 (multiple version)  
  [pyenv 참고](https://www.daleseo.com/python-pyenv/)
```
brew install pyenv
pyenv install 3.10.0
pyenv install 3.6.9
python3 —version
pyenv versions
pyenv global 3.10.0
python3 —version
# 참고로 python-2 버전은 2020 에 EOS 되었다.
pyenv install 2.7.18
```



- terraform 설치
tfswitch 명령을 통해 multiple 버전 관리 지원
```
brew install warrensbox/tap/tfswitch
tfswitch -l
terraform --version
ln -s /usr/local/bin/terraform /usr/local/bin/tf
```

- EKS Tools 설치
```
# kubectl
https://kubernetes.io/ko/docs/tasks/tools/install-kubectl-macos/

# istoctl
https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/

# helm
brew install helm

# aws-iam-authenticator
brew install aws-iam-authenticator
```

- aws cli v2 설치
```
https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/install-cliv2.html
```

- go-lang 설치
```
brew install go
```
