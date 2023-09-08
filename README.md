# Multiple outposts issue

## Description
This README provides instructions on how to replicate the issue when we have several Authentik outposts replicas with NGINX.

## How to replicate the issue
Follow the steps below to replicate the issue:

## Requirements
To replicate the issue, you need to have the following tools installed:

- `k3d`
- `helmfile`
- `kubectl`
- `terraform`

I recommend using `asdf` and `direnv` to configure the environment and CLI.

### Step 1 - Validation with Traefik

> [!NOTE] TLDR; `make traefik`

1. Create a Kubernetes cluster using `k3d` by running the command `k3d cluster create --config k3d.yaml`.
2. Install all required Helm charts by running the command `helmfile apply --wait --file traefik/helmfile.yaml`
3. Install Authentik by running the command `helmfile apply --wait`.
4. Fix internal Authentik URL redirection
    1. Add `127.0.0.1 authentik.authentik.svc.cluster.local` to `/etc/hosts`.
    2. Redirect `authentik.authentik.svc.cluster.local` to `authentik.127-0-0-1.nip.io` by running the command `kubectl create --filename traefik/localhost.fix.yaml`. This fix is required because the outposts uses the internal Authentik URL.
6. Configure Authentik by running the command `terraform apply`.
7. Take a break and enjoy your coffee.
8. Go to https://debug.127-0-0-1.nip.io/ and enjoy.

### Step 2 - Validation with Nginx

> [!NOTE] TLDR; `make nginx`

1. Create a Kubernetes cluster using `k3d` by running the command `k3d cluster create --config k3d.yaml`.
2. Install all required Helm charts by running the command `helmfile apply --wait --file nginx/helmfile.yaml`
3. Install Authentik by running the command `helmfile apply --wait`.
4. Fix internal Authentik URL redirection
    1. Add `127.0.0.1 authentik.authentik.svc.cluster.local` to `/etc/hosts`.
    2. Redirect `authentik.authentik.svc.cluster.local` to `authentik.127-0-0-1.nip.io` by running the command `kubectl create --filename nginx/localhost.fix.yaml`. This fix is required because the outposts uses the internal Authentik URL.
6. Configure Authentik by running the command `terraform apply`.
7. Take a break and enjoy your coffee.
8. Go to https://debug.127-0-0-1.nip.io/ and notice the issue with sticky sessions.

***For people who don't want to use helmfile, all charts have been compiled in each directory***
