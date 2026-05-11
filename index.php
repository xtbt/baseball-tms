<?php

declare(strict_types=1);

require_once __DIR__ . '/includes/bootstrap.php';

$flashError = (string) ($_SESSION['flash_error'] ?? '');
$flashSuccess = (string) ($_SESSION['flash_success'] ?? '');
unset($_SESSION['flash_error'], $_SESSION['flash_success']);

$gamesResponse = api_request('GET', '/games?limit=100&offset=0');
$games = $gamesResponse['body']['data'] ?? [];
$teamsMap = fetch_public_map('/teams?limit=300&offset=0', 'name');
$venuesMap = fetch_public_map('/venues?limit=300&offset=0', 'name');

usort($games, static function (array $a, array $b): int {
    $dateA = strtotime((string) ($a['game_date'] ?? '') . ' ' . (string) ($a['game_time'] ?? '00:00:00')) ?: 0;
    $dateB = strtotime((string) ($b['game_date'] ?? '') . ' ' . (string) ($b['game_time'] ?? '00:00:00')) ?: 0;
    return $dateB <=> $dateA;
});

$isLogged = is_logged_in();
$auth = auth_data();
$user = $auth['user'] ?? [];
$token = (string) ($auth['token'] ?? '');
$userRole = (string) ($user['role'] ?? '');
$userDisplay = (string) ($user['email'] ?? 'Usuario');
$teamName = 'Sin equipo';
$teamId = 0;

if ($isLogged) {
    $profileResponse = api_request('GET', '/users/' . (int) ($user['id'] ?? 0) . '/profile', $token);
    $profile = $profileResponse['body']['data'] ?? [];
    $teamId = (int) ($profile['team_id'] ?? 0);
    if ($teamId > 0) {
        $teamResponse = api_request('GET', '/teams/' . $teamId, $token);
        $teamName = (string) ($teamResponse['body']['data']['name'] ?? 'Sin equipo');
    }
}
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard | Baseball-TMS</title>
    <link rel="stylesheet" href="/baseball-tms/styles/main.css">
</head>
<body>
<header class="topbar">
    <div class="topbar__brand">
        <img src="/baseball-tms/assets/logo/sindicato.jpg" alt="Logo Baseball-TMS" class="topbar__logo">
        <div>
            <h1>Baseball-TMS</h1>
            <p>Dashboard principal</p>
        </div>
    </div>
    <nav class="topbar__actions">
        <?php if ($isLogged): ?>
            <div class="menu" data-menu>
                <button class="btn btn--ghost" type="button" data-menu-toggle><?= htmlspecialchars($userDisplay, ENT_QUOTES, 'UTF-8') ?></button>
                <div class="menu-panel" data-menu-panel>
                    <a href="/baseball-tms/user/profile.php">Mi perfil</a>
                </div>
            </div>
            <?php if ($userRole === 'manager'): ?>
                <div class="menu" data-menu>
                    <button class="btn btn--ghost" type="button" data-menu-toggle><?= htmlspecialchars($teamName, ENT_QUOTES, 'UTF-8') ?></button>
                    <div class="menu-panel" data-menu-panel>
                        <a href="/baseball-tms/team/manage.php">Mi equipo</a>
                    </div>
                </div>
            <?php endif; ?>
            <?php if ($userRole === 'admin'): ?>
                <div class="menu" data-menu>
                    <button class="btn btn--primary" type="button" data-menu-toggle>Catálogos</button>
                    <div class="menu-panel" data-menu-panel>
                        <a href="/baseball-tms/catalogs/categories/crud.php">Categorías</a>
                        <a href="/baseball-tms/catalogs/teams/crud.php">Equipos</a>
                        <a href="/baseball-tms/catalogs/users/crud.php">Usuarios</a>
                        <a href="/baseball-tms/catalogs/venues/crud.php">Campos</a>
                        <a href="/baseball-tms/catalogs/games/crud.php">Juegos</a>
                    </div>
                </div>
            <?php endif; ?>
            <a class="btn btn--danger" href="/baseball-tms/logout.php">Cerrar sesión</a>
        <?php else: ?>
            <a class="btn btn--primary" href="#login-card">Iniciar sesión</a>
        <?php endif; ?>
    </nav>
</header>
<main class="container">
    <?php if ($flashSuccess !== ''): ?>
        <div class="flash flash--ok"><?= htmlspecialchars($flashSuccess, ENT_QUOTES, 'UTF-8') ?></div>
    <?php endif; ?>
    <?php if ($flashError !== ''): ?>
        <div class="flash flash--error"><?= htmlspecialchars($flashError, ENT_QUOTES, 'UTF-8') ?></div>
    <?php endif; ?>

    <?php if ($isLogged): ?>
        <section class="card">
            <strong>Usuario:</strong> <?= htmlspecialchars($userDisplay, ENT_QUOTES, 'UTF-8') ?>
            <span class="text-muted"> | </span>
            <strong>Equipo:</strong> <?= htmlspecialchars($teamName, ENT_QUOTES, 'UTF-8') ?>
            <span class="text-muted"> | </span>
            <strong>Rol:</strong> <?= htmlspecialchars($userRole, ENT_QUOTES, 'UTF-8') ?>
        </section>
    <?php endif; ?>

    <div class="grid">
        <section class="card">
            <h2>Calendario de juegos</h2>
            <p class="text-muted">Mostrando del más reciente al más antiguo.</p>
            <div class="game-list">
                <?php if (empty($games)): ?>
                    <article class="game-item">
                        <div class="game-item__line">
                            <strong>No hay juegos registrados.</strong>
                        </div>
                    </article>
                <?php else: ?>
                    <?php foreach ($games as $game): ?>
                        <?php
                        $homeName = $teamsMap[(int) ($game['home_team_id'] ?? 0)] ?? 'Equipo local';
                        $awayName = $teamsMap[(int) ($game['away_team_id'] ?? 0)] ?? 'Equipo visitante';
                        $venueName = $venuesMap[(int) ($game['venue_id'] ?? 0)] ?? 'Campo no definido';
                        $gameDate = (string) ($game['game_date'] ?? '');
                        $gameTime = (string) ($game['game_time'] ?? '');
                        $status = (string) ($game['status'] ?? 'scheduled');
                        $homeScore = $game['home_score'] !== null ? (string) $game['home_score'] : '-';
                        $awayScore = $game['away_score'] !== null ? (string) $game['away_score'] : '-';
                        ?>
                        <article class="game-item">
                            <div class="game-item__line">
                                <strong><?= htmlspecialchars($awayName, ENT_QUOTES, 'UTF-8') ?> vs <?= htmlspecialchars($homeName, ENT_QUOTES, 'UTF-8') ?></strong>
                                <span class="badge"><?= htmlspecialchars($status, ENT_QUOTES, 'UTF-8') ?></span>
                            </div>
                            <div class="game-item__line">
                                <span><?= htmlspecialchars($gameDate . ' ' . substr($gameTime, 0, 5), ENT_QUOTES, 'UTF-8') ?></span>
                                <span><?= htmlspecialchars($venueName, ENT_QUOTES, 'UTF-8') ?></span>
                            </div>
                            <div class="game-item__line">
                                <span>Marcador: <?= htmlspecialchars($awayScore, ENT_QUOTES, 'UTF-8') ?> - <?= htmlspecialchars($homeScore, ENT_QUOTES, 'UTF-8') ?></span>
                                <span>Entradas: <?= htmlspecialchars((string) ($game['innings_played'] ?? 'N/D'), ENT_QUOTES, 'UTF-8') ?></span>
                            </div>
                        </article>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>
        </section>

        <?php if (!$isLogged): ?>
            <aside class="card" id="login-card">
                <h2>Acceso al sistema</h2>
                <p class="text-muted">Ingresa con tu cuenta para ver opciones según tu rol.</p>
                <form method="post" action="/baseball-tms/login.php" class="form-stack">
                    <label for="email">Correo</label>
                    <input id="email" name="email" type="email" required>
                    <label for="password">Contraseña</label>
                    <input id="password" name="password" type="password" required>
                    <button type="submit" class="btn btn--primary">Entrar</button>
                </form>
            </aside>
        <?php else: ?>
            <aside class="card">
                <h2>Accesos rápidos</h2>
                <?php if ($userRole === 'player'): ?>
                    <p><a class="btn btn--ghost" href="/baseball-tms/user/profile.php">Mi perfil</a></p>
                <?php elseif ($userRole === 'manager'): ?>
                    <p><a class="btn btn--ghost" href="/baseball-tms/team/manage.php">Mi equipo</a></p>
                    <p><a class="btn btn--ghost" href="/baseball-tms/user/profile.php">Mi perfil</a></p>
                <?php elseif ($userRole === 'admin'): ?>
                    <p><a class="btn btn--ghost" href="/baseball-tms/user/profile.php">Mi perfil</a></p>
                    <p class="text-muted">El menú de Catálogos está disponible en la barra superior.</p>
                <?php else: ?>
                    <p class="text-muted">No hay accesos definidos para este rol.</p>
                <?php endif; ?>
            </aside>
        <?php endif; ?>
    </div>
</main>
<script src="/baseball-tms/scripts/main.js"></script>
</body>
</html>
