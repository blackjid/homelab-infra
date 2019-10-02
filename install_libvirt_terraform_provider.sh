#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  OS=linux
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS=darwin
fi

ARCH=amd64

go get github.com/dmacvicar/terraform-provider-libvirt/

mkdir -p ~/.terraform.d/plugins/${OS}_${ARCH}/
ln -sf "$GOPATH"/bin/terraform-provider-libvirt    ~/.terraform.d/plugins/${OS}_${ARCH}/