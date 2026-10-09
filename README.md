# Vapor Images

This repository contains the Docker templates to build images for Vapor native runtimes.

Each supported runtime has its own directory where the Dockerfiles are located. A publish.php script is also provided to publish the
exported images to AWS Lambda.

## Building images

On the Laravel organization on Forge, there are two build servers for ARM and x86 architectures:

- [Vapor ARM]([https://forge.laravel.com/servers/100](https://forge.laravel.com/laravel/vapor-runtime-build-arm))
- [Vapor x86]([https://forge.laravel.com/servers/101](https://forge.laravel.com/laravel/vapor-runtime-build-x86))

On each server, we build the images that match the archtecture of the server.

### Building an image

On the build server, `cd` into the directory of the runtime you want to build and run:

```
$ make distribution
````

This command will build the image and export the Lambda layer to the `./export` directory.

### Publishing an image

After all images are exported, run the `publish.php` script to publish the images to AWS Lambda:

```
php publish.php php-85al2023-arm
```

This command will publish the exported PHP8.5 layer to the `php-85al2023-arm` runtime. The output may look like this:

```
[us-east-1]: arn:aws:lambda:us-east-1:959512994844:layer:vapor-php-85al2023-arm:10
[us-east-2]: arn:aws:lambda:us-east-2:959512994844:layer:vapor-php-85al2023-arm:10
[us-west-1]: arn:aws:lambda:us-west-1:959512994844:layer:vapor-php-85al2023-arm:10
...
```

A layer is pushed to each region where Vapor is available and an ARN is printed.

Copy the output of all publish.php commands and update the `$images` variable in https://github.com/laravel/vapor/blob/master/UpdateLayerVersions.php.

Once all ARNs are updated, run `php UpdateLayerVersions.php`. This will update the layer versions for all runtimes in the https://github.com/laravel/vapor/blob/master/app/Jobs/UpdateFunctionConfigurations.php job.

### Deploying the changes

Open a PR with the changes to the UpdateFunctionConfigurations.php job and merge it. You can see a similar PR here: https://github.com/laravel/vapor/pull/810

The final step is to deploy Vapor by tagging the release.

## Testing locally

To test images locally, you may use Docker on your local machine to build every runtime and bash into the container. You may then verify the PHP version and extensions installed. 