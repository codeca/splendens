<?php
$ip = @$_GET['ip'];
if (preg_match('@^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$@', $ip))
	file_put_contents('ip.txt', $ip);
