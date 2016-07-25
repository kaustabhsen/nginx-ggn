#!/bin/sh

if [ ! -f ".terraform/terraform.tfstate" ]; then
    terraform get
fi
