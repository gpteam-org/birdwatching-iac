# Birdwatching IaC

This repository contains IaC for the [Birdwatching App](https://github.com/gpteam-org/birdwatching-app).

## Setup Guide

Clone and open this repository in your terminal:

```
git clone git@github.com:gpteam-org/birdwatching-iac.git
cd birdwatching-iac
```

Install base Vagrant box (if missing):


```
vagrant box add debian/bookworm64
```

Build Packer template and add golden images to Vagrant:

```
packer build .

vagrant box add web-server-image images/web-server/package.box
vagrant box add load-balancer-image images/load-balancer/package.box
vagrant box add database-image images/database/package.box
```

Run infrastructure setup:

```
vagrant up
```

## Manual Testing

1. Follow setup quide instructions
2. Open http://192.168.56.104 in local broswer (It should serve Birdwatching App from web-server-1)
3. Update page (It should serve Birdwatching App from web-server-2)
