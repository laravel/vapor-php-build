# Vapor Images

This repository contains the Docker templates to build images for Vapor native runtimes.

Each supported runtime has its own directory where the Dockerfiles are located. A publish.php script is also provided to publish the
exported images to AWS Lambda.

## Building images

On the Laravel organization on Forge, there are two build servers for ARM and x86 architectures:

- [Vapor ARM]([https://forge.laravel.com/servers/100](https://forge.laravel.com/laravel/vapor-runtime-build-arm))
- [Vapor x86]([https://forge.laravel.com/servers/101](https://forge.laravel.com/laravel/vapor-runtime-build-x86))

On each server, we build the images that match the archtecture of the server.
