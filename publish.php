<?php

use Aws\Lambda\LambdaClient;
use Symfony\Component\Process\Process;

require_once __DIR__ . '/vendor/autoload.php';

$dotenv = Dotenv\Dotenv::create(__DIR__);
$dotenv->load();

$layers = [
    'php-74' => 'Laravel Vapor PHP 7.4',
];

$regions = [
    'us-east-1' => 'US East (N. Virginia) (us-east-1)',
    'us-east-2' => 'US East (Ohio) (us-east-2)',
    'us-west-1' => 'US West (N. California) (us-west-1)',
    'us-west-2' => 'US West (Oregon) (us-west-2)',
    'ap-east-1' => 'Asia Pacific (Hong Kong) (ap-east-1)',
    'ap-south-1' => 'Asia Pacific (Mumbai) (ap-south-1)',
    // 'ap-northeast-3' => 'Asia Pacific (Osaka-Local) (ap-northeast-3)',
    'ap-northeast-2' => 'Asia Pacific (Seoul) (ap-northeast-2)',
    'ap-southeast-1' => 'Asia Pacific (Singapore) (ap-southeast-1)',
    'ap-southeast-2' => 'Asia Pacific (Sydney) (ap-southeast-2)',
    'ap-northeast-1' => 'Asia Pacific (Tokyo) (ap-northeast-1)',
    'ca-central-1' => 'Canada (Central) (ca-central-1)',
    // 'cn-north-1' => 'China (Beijing) (cn-north-1)',
    // 'cn-northwest-1' => 'China (Ningxia) (cn-northwest-1)',
    'eu-central-1' => 'EU (Frankfurt) (eu-central-1)',
    'eu-west-1' => 'EU (Ireland) (eu-west-1)',
    'eu-west-2' => 'EU (London) (eu-west-2)',
    'eu-west-3' => 'EU (Paris) (eu-west-3)',
    'eu-north-1' => 'EU (Stockholm) (eu-north-1)',
    'sa-east-1' => 'South America (São Paulo) (sa-east-1)',
];

foreach (array_keys($regions) as $region) {
    $lambda = new LambdaClient([
        'region' => $region,
        'version' => 'latest',
    ]);

    foreach ($layers as $layer => $description) {
        $publishResponse = $lambda->publishLayerVersion([
            'LayerName' => 'vapor-php-74',
            'Description' => $description,
            'Content' => [
                'ZipFile' => file_get_contents(__DIR__."/export/{$layer}.zip"),
            ],
        ]);

        $lambda->addLayerVersionPermission([
            'Action' => 'lambda:GetLayerVersion',
            'LayerName' => 'vapor-php-74',
            'Principal' => '*',
            'StatementId' => (string) time(),
            'VersionNumber' => (string) $publishResponse['Version'],
        ]);

        echo '['.$region.']: '.$publishResponse['LayerVersionArn'].PHP_EOL;
    }
}
