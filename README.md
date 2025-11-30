1. install ubuntu 24.04 in WSL2 in windows11
2. install docker inside WSL2 ubuntu 24.04
   fix network expose by /etc/docker/daemon.json, /etc/wsl.conf, /etc/resolve.conf
3. install awscli
4. install terraform
5. install act for locally GitHub Actions
   eg.
   act -W .github/workflows/ci.yml -j test
   act -W .github/workflows/ci.yml -j lint
   act -W .github/workflows/ci.yml -j security \
    --eventpath ./local-event.json \
    -s GITHUB_TOKEN=ghp_yourgithubaccesstokenhere \
    -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest \
    --no-skip-checkout

