# Vapor PHP build

# Make a custom runtime for Vapor

You might want a specific php extension that Vapor does not provide out of the box. This is possible by using your own custom runtime. 

## Step 1: Make changes 

First, make the required changes needed. [This issue](https://github.com/laravel/vapor-php-build/issues/3#issuecomment-541922252) might be a good read to start with: 

## Step 2: How to build a custom runtime

1. Open your terminal and navigate into php folder (eg. php74)
2. Run `make distribution` (This takes a long time to compile)
3. A new file is added to your /exports folder


## Step 3: How to publish your custom runtime

1. Navigate to the root folder
2. Add a `.env` file in the root folder with your AWS credentials

```yml
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```

3. Run `php publish.php`. This will publish your custom runtime to all regions. 

## Step 4: How to use your custom runtime

1. Copy arn name for your region and add it to your `vapor.yml` within your Vapor based project like this:

```yml
environments:
    staging:
        memory: 1024
        layers:
            - 'arn:aws:lambda:xxxxxxxx:xxxxxxx:layer:vapor-php-74:x'
```

6. Deploy to staging to test it out, run `vapor deploy staging --message="Testing Custom Runtime"`
7. Test it out
