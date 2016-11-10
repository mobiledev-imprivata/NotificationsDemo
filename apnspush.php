<?php

$options = getopt('sd:');
// var_dump($options);

if (!(array_key_exists('d', $options))) {
	exit('Missing deviceToken; use the -d option' . PHP_EOL);
}

// private key's passphrase
$passphrase = 'pass';

$context = stream_context_create();
stream_context_set_option($context, 'ssl', 'local_cert', 'NotificationsDemo.pem');
stream_context_set_option($context, 'ssl', 'passphrase', $passphrase);

// open a connection to the APNS server
$fp = stream_socket_client(
	'ssl://gateway.sandbox.push.apple.com:2195',
	$err,
	$errstr,
	60,
	STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT,
	$context);

if (!$fp) {
	exit("Failed to connect: $err $errstr" . PHP_EOL);
}

echo 'Connected to APNS' . PHP_EOL;

// get device token, remove all non-digits
$deviceToken = $options['d'];
$deviceToken = str_replace(' ', '', $deviceToken);
// echo 'deviceToken ' . $deviceToken . PHP_EOL;

$isSilent = array_key_exists('s', $options);
echo 'isSilent ' . ($isSilent ? 'true' : 'false') . PHP_EOL;

// create the payload body
$aps = array(
	'category' => 'notificationsDemo'
	);

if ($isSilent) {
	$aps = $aps + array(
		'content-available' => 1
		);
} else {
	$alert = array(
		'title' => 'Hello from server',
		'body' => 'Here\'s a remote challenge'
		);
	$aps['alert'] = $alert;
}

$body['aps'] = $aps;

print_r($body);

// encode the payload as JSON
$payload = json_encode($body);

// build the binary notification
$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

// send it to the server
$result = fwrite($fp, $msg, strlen($msg));

if (!$result) {
	echo 'Message not delivered' . PHP_EOL;
} else {
	echo 'Message successfully delivered' . PHP_EOL;
}

// close the connection to the server
fclose($fp);
