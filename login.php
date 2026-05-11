<?php

declare(strict_types=1);

require_once __DIR__ . '/includes/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    redirect_to('/baseball-tms/index.php');
}

$email = trim((string) ($_POST['email'] ?? ''));
$password = (string) ($_POST['password'] ?? '');

if ($email === '' || $password === '') {
    $_SESSION['flash_error'] = 'Debes ingresar correo y contraseña.';
    redirect_to('/baseball-tms/index.php');
}

$loginResponse = api_request('POST', '/auth/login', null, [
    'email' => $email,
    'password' => $password,
    'device_name' => 'Web Frontend',
    'device_type' => 'web',
]);

if (!$loginResponse['ok']) {
    $_SESSION['flash_error'] = 'Credenciales inválidas.';
    redirect_to('/baseball-tms/index.php');
}

set_auth($loginResponse['body']['data'] ?? []);
$_SESSION['flash_success'] = 'Has iniciado sesión correctamente.';
redirect_to('/baseball-tms/index.php');
