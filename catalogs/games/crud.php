<?php

declare(strict_types=1);

require_once __DIR__ . '/../../includes/bootstrap.php';

if (!is_logged_in()) {
    redirect_to('/baseball-tms/index.php');
}

$auth = auth_data();
$user = $auth['user'];
$token = (string) ($auth['token'] ?? '');
$userId = (int) ($user['id'] ?? 0);
$userRole = (string) ($user['role'] ?? '');
$userDisplay = (string) ($user['email'] ?? 'Usuario');

if ($userRole !== 'admin') {
    $_SESSION['flash_error'] = 'Solo usuarios admin pueden acceder a catálogos.';
    redirect_to('/baseball-tms/index.php');
}

$flashError = (string) ($_SESSION['flash_error'] ?? '');
$flashSuccess = (string) ($_SESSION['flash_success'] ?? '');
unset($_SESSION['flash_error'], $_SESSION['flash_success']);

$teamName = 'Sin equipo';
$profileResponse = api_request('GET', '/users/' . $userId . '/profile', $token);
$profile = $profileResponse['body']['data'] ?? [];
$teamId = (int) ($profile['team_id'] ?? 0);
if ($teamId > 0) {
    $teamResponse = api_request('GET', '/teams/' . $teamId, $token);
    $teamName = (string) ($teamResponse['body']['data']['name'] ?? 'Sin equipo');
}

$teamsResponse = api_request('GET', '/teams?limit=500&offset=0', $token);
$teams = $teamsResponse['body']['data'] ?? [];
$teamsMap = [];
foreach ($teams as $teamItem) {
    $teamItemId = (int) ($teamItem['id'] ?? 0);
    if ($teamItemId > 0) {
        $teamsMap[$teamItemId] = (string) ($teamItem['name'] ?? 'N/D');
    }
}

$venuesResponse = api_request('GET', '/venues?limit=500&offset=0', $token);
$venues = $venuesResponse['body']['data'] ?? [];
$venuesMap = [];
foreach ($venues as $venueItem) {
    $venueItemId = (int) ($venueItem['id'] ?? 0);
    if ($venueItemId > 0) {
        $venuesMap[$venueItemId] = (string) ($venueItem['name'] ?? 'N/D');
    }
}

$statusOptions = ['PROGRAMADO', 'FINALIZADO', 'CANCELADO', 'POSPUESTO'];
$search = trim((string) ($_GET['q'] ?? ''));
$page = max(1, (int) ($_GET['page'] ?? 1));
$perPage = 20;

$redirectList = static function (string $q, int $targetPage): void {
    $params = [];
    if ($q !== '') {
        $params['q'] = $q;
    }
    if ($targetPage > 1) {
        $params['page'] = $targetPage;
    }
    $url = '/baseball-tms/catalogs/games/crud.php';
    if (!empty($params)) {
        $url .= '?' . http_build_query($params);
    }
    redirect_to($url);
};

$parseUnsignedTinyIntOrNull = static function (string $value, string $label): ?int {
    $value = trim($value);
    if ($value === '') {
        return null;
    }
    if (!ctype_digit($value)) {
        throw new RuntimeException('El campo ' . $label . ' debe ser numérico.');
    }
    $number = (int) $value;
    if ($number < 0 || $number > 255) {
        throw new RuntimeException('El campo ' . $label . ' debe estar entre 0 y 255.');
    }
    return $number;
};

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = (string) ($_POST['action'] ?? '');
    $returnQ = trim((string) ($_POST['return_q'] ?? ''));
    $returnPage = max(1, (int) ($_POST['return_page'] ?? 1));

    if ($action === 'create' || $action === 'update') {
        $id = (int) ($_POST['id'] ?? 0);
        $gameDate = trim((string) ($_POST['game_date'] ?? ''));
        $gameTime = trim((string) ($_POST['game_time'] ?? ''));
        $venueId = (int) ($_POST['venue_id'] ?? 0);
        $homeTeamId = (int) ($_POST['home_team_id'] ?? 0);
        $awayTeamId = (int) ($_POST['away_team_id'] ?? 0);
        $status = trim((string) ($_POST['status'] ?? 'PROGRAMADO'));
        $notesRaw = trim((string) ($_POST['notes'] ?? ''));
        $notes = $notesRaw !== '' ? $notesRaw : null;

        try {
            $homeScore = $parseUnsignedTinyIntOrNull((string) ($_POST['home_score'] ?? ''), 'Marcador local');
            $awayScore = $parseUnsignedTinyIntOrNull((string) ($_POST['away_score'] ?? ''), 'Marcador visitante');
            $inningsPlayed = $parseUnsignedTinyIntOrNull((string) ($_POST['innings_played'] ?? ''), 'Entradas jugadas');
        } catch (RuntimeException $exception) {
            $_SESSION['flash_error'] = $exception->getMessage();
            $redirectList($returnQ, $returnPage);
        }

        $dateValid = date_create_from_format('Y-m-d', $gameDate);
        if (!$dateValid || $dateValid->format('Y-m-d') !== $gameDate) {
            $_SESSION['flash_error'] = 'La fecha del juego no es válida.';
            $redirectList($returnQ, $returnPage);
        }

        if (!preg_match('/^([01][0-9]|2[0-3]):[0-5][0-9]$/', $gameTime)) {
            $_SESSION['flash_error'] = 'La hora del juego no es válida.';
            $redirectList($returnQ, $returnPage);
        }

        if ($venueId <= 0 || !isset($venuesMap[$venueId])) {
            $_SESSION['flash_error'] = 'El campo seleccionado no es válido.';
            $redirectList($returnQ, $returnPage);
        }

        if ($homeTeamId <= 0 || !isset($teamsMap[$homeTeamId])) {
            $_SESSION['flash_error'] = 'El equipo local seleccionado no es válido.';
            $redirectList($returnQ, $returnPage);
        }

        if ($awayTeamId <= 0 || !isset($teamsMap[$awayTeamId])) {
            $_SESSION['flash_error'] = 'El equipo visitante seleccionado no es válido.';
            $redirectList($returnQ, $returnPage);
        }

        if ($homeTeamId === $awayTeamId) {
            $_SESSION['flash_error'] = 'El equipo local y visitante deben ser diferentes.';
            $redirectList($returnQ, $returnPage);
        }

        if (!in_array($status, $statusOptions, true)) {
            $_SESSION['flash_error'] = 'El estatus seleccionado no es válido.';
            $redirectList($returnQ, $returnPage);
        }

        $payload = [
            'game_date' => $gameDate,
            'game_time' => $gameTime,
            'venue_id' => $venueId,
            'home_team_id' => $homeTeamId,
            'away_team_id' => $awayTeamId,
            'home_score' => $homeScore,
            'away_score' => $awayScore,
            'innings_played' => $inningsPlayed,
            'status' => $status,
            'notes' => $notes,
        ];

        if ($action === 'create') {
            $response = api_request('POST', '/games', $token, $payload);
            if (!empty($response['ok'])) {
                $_SESSION['flash_success'] = 'Juego creado correctamente.';
            } else {
                $_SESSION['flash_error'] = (string) ($response['body']['message'] ?? 'No se pudo crear el juego.');
            }
            $redirectList($returnQ, $returnPage);
        }

        if ($id <= 0) {
            $_SESSION['flash_error'] = 'Juego inválido.';
            $redirectList($returnQ, $returnPage);
        }

        $response = api_request('PUT', '/games/' . $id, $token, $payload);
        if (!empty($response['ok'])) {
            $_SESSION['flash_success'] = 'Juego actualizado correctamente.';
        } else {
            $_SESSION['flash_error'] = (string) ($response['body']['message'] ?? 'No se pudo actualizar el juego.');
        }
        $redirectList($returnQ, $returnPage);
    }

    $_SESSION['flash_error'] = 'Acción no válida.';
    $redirectList($returnQ, $returnPage);
}

$allGames = [];
$offset = 0;
$batchSize = 200;
$maxIterations = 50;
$iterations = 0;

while ($iterations < $maxIterations) {
    $response = api_request('GET', '/games?limit=' . $batchSize . '&offset=' . $offset, $token);
    $chunk = $response['body']['data'] ?? [];
    if (!is_array($chunk) || empty($chunk)) {
        break;
    }

    foreach ($chunk as $row) {
        if (is_array($row)) {
            $allGames[] = $row;
        }
    }

    if (count($chunk) < $batchSize) {
        break;
    }

    $offset += $batchSize;
    $iterations++;
}

if ($search !== '') {
    $needle = strtolower($search);
    $allGames = array_values(array_filter($allGames, static function (array $item) use ($needle, $teamsMap, $venuesMap): bool {
        $gameDate = strtolower(trim((string) ($item['game_date'] ?? '')));
        $gameTime = strtolower(trim((string) ($item['game_time'] ?? '')));
        $status = strtolower(trim((string) ($item['status'] ?? '')));
        $notes = strtolower(trim((string) ($item['notes'] ?? '')));
        $home = strtolower(trim((string) ($teamsMap[(int) ($item['home_team_id'] ?? 0)] ?? '')));
        $away = strtolower(trim((string) ($teamsMap[(int) ($item['away_team_id'] ?? 0)] ?? '')));
        $venue = strtolower(trim((string) ($venuesMap[(int) ($item['venue_id'] ?? 0)] ?? '')));
        return strpos($gameDate, $needle) !== false
            || strpos($gameTime, $needle) !== false
            || strpos($status, $needle) !== false
            || strpos($notes, $needle) !== false
            || strpos($home, $needle) !== false
            || strpos($away, $needle) !== false
            || strpos($venue, $needle) !== false;
    }));
}

usort($allGames, static function (array $a, array $b): int {
    $dateTimeA = (string) ($a['game_date'] ?? '') . ' ' . (string) ($a['game_time'] ?? '00:00:00');
    $dateTimeB = (string) ($b['game_date'] ?? '') . ' ' . (string) ($b['game_time'] ?? '00:00:00');
    return strtotime($dateTimeB) <=> strtotime($dateTimeA);
});

$totalItems = count($allGames);
$totalPages = max(1, (int) ceil($totalItems / $perPage));
if ($page > $totalPages) {
    $page = $totalPages;
}
$start = ($page - 1) * $perPage;
$games = array_slice($allGames, $start, $perPage);

$queryForPage = static function (int $targetPage, string $q): string {
    $params = [];
    if ($q !== '') {
        $params['q'] = $q;
    }
    if ($targetPage > 1) {
        $params['page'] = $targetPage;
    }
    return empty($params) ? '' : '?' . http_build_query($params);
};
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Catálogo de juegos | Baseball-TMS</title>
    <link rel="stylesheet" href="/baseball-tms/styles/main.css">
    <link rel="stylesheet" href="/baseball-tms/catalogs/games/crud.css">
</head>
<body>
<header class="topbar">
    <div class="topbar__brand">
        <img src="/baseball-tms/assets/logo/sindicato.jpg" alt="Logo Baseball-TMS" class="topbar__logo">
        <div>
            <h1>Baseball-TMS</h1>
            <p>Catálogo de juegos</p>
        </div>
    </div>
    <nav class="topbar__actions">
        <a class="btn btn--ghost" href="/baseball-tms/index.php">Dashboard</a>
        <div class="menu" data-menu>
            <button class="btn btn--ghost" type="button" data-menu-toggle><?= htmlspecialchars($userDisplay, ENT_QUOTES, 'UTF-8') ?></button>
            <div class="menu-panel" data-menu-panel>
                <a href="/baseball-tms/user/profile.php">Mi perfil</a>
            </div>
        </div>
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
        <a class="btn btn--danger" href="/baseball-tms/logout.php">Cerrar sesión</a>
    </nav>
</header>
<main class="container">
    <?php if ($flashSuccess !== ''): ?>
        <div class="flash flash--ok"><?= htmlspecialchars($flashSuccess, ENT_QUOTES, 'UTF-8') ?></div>
    <?php endif; ?>
    <?php if ($flashError !== ''): ?>
        <div class="flash flash--error"><?= htmlspecialchars($flashError, ENT_QUOTES, 'UTF-8') ?></div>
    <?php endif; ?>

    <section class="card">
        <div class="catalog-head">
            <div>
                <h2>Juegos</h2>
                <p class="text-muted">Usuario: <?= htmlspecialchars($userDisplay, ENT_QUOTES, 'UTF-8') ?> | Equipo: <?= htmlspecialchars($teamName, ENT_QUOTES, 'UTF-8') ?></p>
            </div>
            <button type="button" class="btn btn--primary" data-open-modal="modal-create">Nuevo juego</button>
        </div>

        <form class="catalog-search" method="get" action="/baseball-tms/catalogs/games/crud.php">
            <input type="text" name="q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>" placeholder="Buscar por fecha, equipos, campo o estatus">
            <button type="submit" class="btn btn--ghost">Buscar</button>
        </form>

        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>Fecha</th>
                        <th>Hora</th>
                        <th>Local</th>
                        <th>Visitante</th>
                        <th>Campo</th>
                        <th>Resultado</th>
                        <th>Estatus</th>
                        <th>Acción</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($games)): ?>
                        <tr>
                            <td colspan="8">No hay juegos para mostrar.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($games as $game): ?>
                            <?php
                            $gameRowId = (int) ($game['id'] ?? 0);
                            $homeTeamName = (string) ($teamsMap[(int) ($game['home_team_id'] ?? 0)] ?? 'N/D');
                            $awayTeamName = (string) ($teamsMap[(int) ($game['away_team_id'] ?? 0)] ?? 'N/D');
                            $venueName = (string) ($venuesMap[(int) ($game['venue_id'] ?? 0)] ?? 'N/D');
                            $homeScoreView = $game['home_score'] === null ? '-' : (string) ((int) $game['home_score']);
                            $awayScoreView = $game['away_score'] === null ? '-' : (string) ((int) $game['away_score']);
                            $statusValue = (string) ($game['status'] ?? 'PROGRAMADO');
                            ?>
                            <tr>
                                <td><?= htmlspecialchars((string) ($game['game_date'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars(substr((string) ($game['game_time'] ?? ''), 0, 5), ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars($homeTeamName, ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars($awayTeamName, ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars($venueName, ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars($homeScoreView . ' - ' . $awayScoreView, ENT_QUOTES, 'UTF-8') ?></td>
                                <td><span class="status-pill"><?= htmlspecialchars($statusValue, ENT_QUOTES, 'UTF-8') ?></span></td>
                                <td>
                                    <button type="button" class="btn btn--ghost" data-open-modal="modal-detail-<?= $gameRowId ?>">Ver</button>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>

        <div class="pagination">
            <?php if ($page > 1): ?>
                <a class="btn btn--ghost" href="/baseball-tms/catalogs/games/crud.php<?= htmlspecialchars($queryForPage($page - 1, $search), ENT_QUOTES, 'UTF-8') ?>">Anterior</a>
            <?php endif; ?>
            <span class="text-muted">Página <?= $page ?> de <?= $totalPages ?> | Total: <?= $totalItems ?></span>
            <?php if ($page < $totalPages): ?>
                <a class="btn btn--ghost" href="/baseball-tms/catalogs/games/crud.php<?= htmlspecialchars($queryForPage($page + 1, $search), ENT_QUOTES, 'UTF-8') ?>">Siguiente</a>
            <?php endif; ?>
        </div>
    </section>
</main>

<div class="modal" id="modal-create" hidden>
    <div class="modal__backdrop" data-close-modal></div>
    <div class="modal__content" role="dialog" aria-modal="true" aria-labelledby="modal-create-title">
        <h3 id="modal-create-title">Nuevo juego</h3>
        <form method="post" action="/baseball-tms/catalogs/games/crud.php">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="return_q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>">
            <input type="hidden" name="return_page" value="<?= $page ?>">
            <label>Fecha
                <input type="date" name="game_date" required>
            </label>
            <label>Hora
                <input type="time" name="game_time" required>
            </label>
            <label>Campo
                <select name="venue_id" required>
                    <option value="">Selecciona un campo</option>
                    <?php foreach ($venuesMap as $venueIdOption => $venueLabel): ?>
                        <option value="<?= (int) $venueIdOption ?>"><?= htmlspecialchars($venueLabel, ENT_QUOTES, 'UTF-8') ?></option>
                    <?php endforeach; ?>
                </select>
            </label>
            <label>Equipo local
                <select name="home_team_id" required>
                    <option value="">Selecciona un equipo</option>
                    <?php foreach ($teamsMap as $teamIdOption => $teamLabel): ?>
                        <option value="<?= (int) $teamIdOption ?>"><?= htmlspecialchars($teamLabel, ENT_QUOTES, 'UTF-8') ?></option>
                    <?php endforeach; ?>
                </select>
            </label>
            <label>Equipo visitante
                <select name="away_team_id" required>
                    <option value="">Selecciona un equipo</option>
                    <?php foreach ($teamsMap as $teamIdOption => $teamLabel): ?>
                        <option value="<?= (int) $teamIdOption ?>"><?= htmlspecialchars($teamLabel, ENT_QUOTES, 'UTF-8') ?></option>
                    <?php endforeach; ?>
                </select>
            </label>
            <label>Marcador local
                <input type="number" name="home_score" min="0" max="255" step="1">
            </label>
            <label>Marcador visitante
                <input type="number" name="away_score" min="0" max="255" step="1">
            </label>
            <label>Entradas jugadas
                <input type="number" name="innings_played" min="0" max="255" step="1">
            </label>
            <label>Estatus
                <select name="status" required>
                    <?php foreach ($statusOptions as $statusOption): ?>
                        <option value="<?= htmlspecialchars($statusOption, ENT_QUOTES, 'UTF-8') ?>" <?= $statusOption === 'PROGRAMADO' ? 'selected' : '' ?>>
                            <?= htmlspecialchars($statusOption, ENT_QUOTES, 'UTF-8') ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </label>
            <label>Notas
                <textarea name="notes" rows="3"></textarea>
            </label>
            <div class="modal__actions">
                <button type="button" class="btn btn--ghost" data-close-modal>Cerrar</button>
                <button type="submit" class="btn btn--primary">Guardar</button>
            </div>
        </form>
    </div>
</div>

<?php foreach ($games as $game): ?>
    <?php
    $gameRowId = (int) ($game['id'] ?? 0);
    $statusValue = (string) ($game['status'] ?? 'PROGRAMADO');
    $selectedVenueId = (int) ($game['venue_id'] ?? 0);
    $selectedHomeTeamId = (int) ($game['home_team_id'] ?? 0);
    $selectedAwayTeamId = (int) ($game['away_team_id'] ?? 0);
    ?>
    <div class="modal" id="modal-detail-<?= $gameRowId ?>" hidden>
        <div class="modal__backdrop" data-close-modal></div>
        <div class="modal__content" role="dialog" aria-modal="true" aria-labelledby="modal-detail-title-<?= $gameRowId ?>">
            <h3 id="modal-detail-title-<?= $gameRowId ?>">Detalle de juego #<?= $gameRowId ?></h3>
            <form method="post" action="/baseball-tms/catalogs/games/crud.php">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" value="<?= $gameRowId ?>">
                <input type="hidden" name="return_q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>">
                <input type="hidden" name="return_page" value="<?= $page ?>">
                <label>Fecha
                    <input type="date" name="game_date" required value="<?= htmlspecialchars((string) ($game['game_date'] ?? ''), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Hora
                    <input type="time" name="game_time" required value="<?= htmlspecialchars(substr((string) ($game['game_time'] ?? ''), 0, 5), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Campo
                    <select name="venue_id" required>
                        <?php foreach ($venuesMap as $venueIdOption => $venueLabel): ?>
                            <option value="<?= (int) $venueIdOption ?>" <?= $selectedVenueId === (int) $venueIdOption ? 'selected' : '' ?>>
                                <?= htmlspecialchars($venueLabel, ENT_QUOTES, 'UTF-8') ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label>Equipo local
                    <select name="home_team_id" required>
                        <?php foreach ($teamsMap as $teamIdOption => $teamLabel): ?>
                            <option value="<?= (int) $teamIdOption ?>" <?= $selectedHomeTeamId === (int) $teamIdOption ? 'selected' : '' ?>>
                                <?= htmlspecialchars($teamLabel, ENT_QUOTES, 'UTF-8') ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label>Equipo visitante
                    <select name="away_team_id" required>
                        <?php foreach ($teamsMap as $teamIdOption => $teamLabel): ?>
                            <option value="<?= (int) $teamIdOption ?>" <?= $selectedAwayTeamId === (int) $teamIdOption ? 'selected' : '' ?>>
                                <?= htmlspecialchars($teamLabel, ENT_QUOTES, 'UTF-8') ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label>Marcador local
                    <input type="number" name="home_score" min="0" max="255" step="1" value="<?= htmlspecialchars($game['home_score'] === null ? '' : (string) ((int) $game['home_score']), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Marcador visitante
                    <input type="number" name="away_score" min="0" max="255" step="1" value="<?= htmlspecialchars($game['away_score'] === null ? '' : (string) ((int) $game['away_score']), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Entradas jugadas
                    <input type="number" name="innings_played" min="0" max="255" step="1" value="<?= htmlspecialchars($game['innings_played'] === null ? '' : (string) ((int) $game['innings_played']), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Estatus
                    <select name="status" required>
                        <?php foreach ($statusOptions as $statusOption): ?>
                            <option value="<?= htmlspecialchars($statusOption, ENT_QUOTES, 'UTF-8') ?>" <?= $statusValue === $statusOption ? 'selected' : '' ?>>
                                <?= htmlspecialchars($statusOption, ENT_QUOTES, 'UTF-8') ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label>Notas
                    <textarea name="notes" rows="3"><?= htmlspecialchars((string) ($game['notes'] ?? ''), ENT_QUOTES, 'UTF-8') ?></textarea>
                </label>
                <div class="modal__actions">
                    <button type="button" class="btn btn--ghost" data-close-modal>Cerrar</button>
                    <button type="submit" class="btn btn--primary">Guardar cambios</button>
                </div>
            </form>
        </div>
    </div>
<?php endforeach; ?>

<script src="/baseball-tms/scripts/main.js"></script>
<script src="/baseball-tms/catalogs/games/crud.js"></script>
</body>
</html>
