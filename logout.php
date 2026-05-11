<?php

declare(strict_types=1);

require_once __DIR__ . '/includes/bootstrap.php';

$auth = auth_data();
$token = (string) ($auth['token'] ?? '');

if ($token !== '') {
    api_request('POST', '/auth/logout', $token);
}

clear_auth();
$_SESSION['flash_success'] = 'Sesión cerrada correctamente.';
redirect_to('/baseball-tms/index.php');
