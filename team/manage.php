<?php

declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';

if (!is_logged_in()) {
    redirect_to('/baseball-tms/index.php');
}

$auth = auth_data();
$user = $auth['user'];
$token = (string) $auth['token'];
$userRole = (string) ($user['role'] ?? '');

if ($userRole !== 'manager' && $userRole !== 'admin') {
    $_SESSION['flash_error'] = 'No tienes acceso a la gestión de equipos.';
    redirect_to('/baseball-tms/index.php');
}

$myProfileResponse = api_request('GET', '/users/' . (int) $user['id'] . '/profile', $token);
$myProfile = $myProfileResponse['body']['data'] ?? [];
$teamId = (int) ($_GET['team_id'] ?? ($myProfile['team_id'] ?? 0));

if ($teamId <= 0) {
    $_SESSION['flash_error'] = 'No hay equipo asociado para mostrar.';
    redirect_to('/baseball-tms/index.php');
}

$teamResponse = api_request('GET', '/teams/' . $teamId, $token);
$team = $teamResponse['body']['data'] ?? [];

$profilesResponse = api_request('GET', '/users?limit=500&offset=0', $token);
$users = $profilesResponse['body']['data'] ?? [];

$players = [];
foreach ($users as $candidateUser) {
    $candidateId = (int) ($candidateUser['id'] ?? 0);
    if ($candidateId <= 0 || (string) ($candidateUser['role'] ?? '') !== 'player') {
        continue;
    }
    $candidateProfileResponse = api_request('GET', '/users/' . $candidateId . '/profile', $token);
    $candidateProfile = $candidateProfileResponse['body']['data'] ?? [];
    if ((int) ($candidateProfile['team_id'] ?? 0) !== $teamId) {
        continue;
    }
    $name = trim(implode(' ', [
        (string) ($candidateProfile['first_name'] ?? ''),
        (string) ($candidateProfile['paternal_surname'] ?? ''),
        (string) ($candidateProfile['maternal_surname'] ?? ''),
    ]));
    $players[] = [
        'id' => $candidateId,
        'email' => (string) ($candidateUser['email'] ?? ''),
        'role' => (string) ($candidateUser['role'] ?? ''),
        'name' => $name !== '' ? $name : 'N/D',
        'position' => (string) ($candidateProfile['position'] ?? 'N/D'),
        'jersey' => (string) ($candidateProfile['jersey_number'] ?? 'N/D'),
    ];
}
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mi equipo | Baseball-TMS</title>
    <link rel="stylesheet" href="/baseball-tms/styles/main.css">
</head>
<body>
<header class="topbar">
    <div class="topbar__brand">
        <img src="/baseball-tms/assets/logo/sindicato.jpg" alt="Logo Baseball-TMS" class="topbar__logo">
        <div>
            <h1>Baseball-TMS</h1>
            <p>Gestión del equipo</p>
        </div>
    </div>
    <nav class="topbar__actions">
        <a class="btn btn--ghost" href="/baseball-tms/index.php">Dashboard</a>
        <a class="btn btn--danger" href="/baseball-tms/logout.php">Cerrar sesión</a>
    </nav>
</header>
<main class="container">
    <section class="card">
        <h2>Mi equipo: <?= htmlspecialchars((string) ($team['name'] ?? 'N/D'), ENT_QUOTES, 'UTF-8') ?></h2>
        <p class="text-muted">Lista de jugadores y acceso a sus datos personales en modo lectura.</p>
        <div style="overflow:auto;">
            <table class="table">
                <thead>
                    <tr>
                        <th>Nombre</th>
                        <th>Correo</th>
                        <th>Rol</th>
                        <th>Posición</th>
                        <th>Jersey</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($players)): ?>
                        <tr>
                            <td colspan="6" class="text-muted">No hay jugadores registrados para este equipo.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($players as $player): ?>
                            <tr>
                                <td><?= htmlspecialchars($player['name'], ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars($player['email'], ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars($player['role'], ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars($player['position'], ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars($player['jersey'], ENT_QUOTES, 'UTF-8') ?></td>
                                <td>
                                    <a class="btn btn--ghost" href="/baseball-tms/user/profile.php?user_id=<?= (int) $player['id'] ?>">Ver perfil</a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>
</main>
</body>
</html>
