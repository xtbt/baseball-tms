<?php

declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';

if (!is_logged_in()) {
    redirect_to('/baseball-tms/index.php');
}

$auth = auth_data();
$user = $auth['user'];
$token = (string) $auth['token'];
$sessionUserId = (int) ($user['id'] ?? 0);
$requestedUserId = (int) ($_GET['user_id'] ?? $sessionUserId);
$userId = $requestedUserId > 0 ? $requestedUserId : $sessionUserId;
$userRole = (string) ($user['role'] ?? '');

if ($userRole !== 'player' && $userRole !== 'manager' && $userRole !== 'admin') {
    clear_auth();
    $_SESSION['flash_error'] = 'La sesión no tiene permisos válidos.';
    redirect_to('/baseball-tms/index.php');
}

if ($userRole === 'player' && $requestedUserId !== $sessionUserId) {
    redirect_to('/baseball-tms/user/profile.php');
}

$profileResponse = api_request('GET', '/users/' . $userId . '/profile', $token);
$profile = $profileResponse['body']['data'] ?? [];

$userInfoResponse = api_request('GET', '/users/' . $userId, $token);
$profileUser = $userInfoResponse['body']['data'] ?? [];
$profileEmail = (string) ($profileUser['email'] ?? $user['email'] ?? '');
$profileRole = (string) ($profileUser['role'] ?? $userRole);
$teamName = 'Sin equipo';
if (!empty($profile['team_id'])) {
    $teamResponse = api_request('GET', '/teams/' . (int) $profile['team_id'], $token);
    if (!empty($teamResponse['body']['data']['name'])) {
        $teamName = (string) $teamResponse['body']['data']['name'];
    }
}

$fullName = trim(implode(' ', [
    (string) ($profile['first_name'] ?? ''),
    (string) ($profile['paternal_surname'] ?? ''),
    (string) ($profile['maternal_surname'] ?? ''),
]));
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mi perfil | Baseball-TMS</title>
    <link rel="stylesheet" href="/baseball-tms/styles/main.css">
</head>
<body>
<header class="topbar">
    <div class="topbar__brand">
        <img src="/baseball-tms/assets/logo/sindicato.jpg" alt="Logo Baseball-TMS" class="topbar__logo">
        <div>
            <h1>Baseball-TMS</h1>
            <p>Perfil de usuario</p>
        </div>
    </div>
    <nav class="topbar__actions">
        <a class="btn btn--ghost" href="/baseball-tms/index.php">Dashboard</a>
        <a class="btn btn--danger" href="/baseball-tms/logout.php">Cerrar sesión</a>
    </nav>
</header>
<main class="container">
    <section class="card">
        <h2>Mi perfil</h2>
        <form class="readonly-form">
            <label>Correo
                <input type="text" readonly value="<?= htmlspecialchars($profileEmail, ENT_QUOTES, 'UTF-8') ?>">
            </label>
            <label>Rol
                <input type="text" readonly value="<?= htmlspecialchars($profileRole, ENT_QUOTES, 'UTF-8') ?>">
            </label>
            <label>Nombre completo
                <input type="text" readonly value="<?= htmlspecialchars($fullName !== '' ? $fullName : 'N/D', ENT_QUOTES, 'UTF-8') ?>">
            </label>
            <label>Equipo
                <input type="text" readonly value="<?= htmlspecialchars($teamName, ENT_QUOTES, 'UTF-8') ?>">
            </label>
            <label>Fecha de nacimiento
                <input type="text" readonly value="<?= htmlspecialchars((string) ($profile['birth_date'] ?? 'N/D'), ENT_QUOTES, 'UTF-8') ?>">
            </label>
            <label>Teléfono
                <input type="text" readonly value="<?= htmlspecialchars((string) ($profile['phone'] ?? 'N/D'), ENT_QUOTES, 'UTF-8') ?>">
            </label>
            <label>Número de jersey
                <input type="text" readonly value="<?= htmlspecialchars((string) ($profile['jersey_number'] ?? 'N/D'), ENT_QUOTES, 'UTF-8') ?>">
            </label>
            <label>Posición
                <input type="text" readonly value="<?= htmlspecialchars((string) ($profile['position'] ?? 'N/D'), ENT_QUOTES, 'UTF-8') ?>">
            </label>
        </form>
    </section>
</main>
</body>
</html>
