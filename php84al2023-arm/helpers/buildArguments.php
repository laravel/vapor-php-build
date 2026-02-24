#!/usr/bin/env php
<?php

$versions = parse_ini_file(realpath(__DIR__."/../versions.ini"), true);

$buildArguments = '';

foreach ($versions[$argv[1]] as $key => $value){
    $buildArguments .= "--build-arg $key=$value ";
}

print $buildArguments;
