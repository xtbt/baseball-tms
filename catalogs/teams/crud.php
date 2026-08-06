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

$categoriesResponse = api_request('GET', '/categories?limit=500&offset=0', $token);
$categories = $categoriesResponse['body']['data'] ?? [];
$categoryMap = [];
foreach ($categories as $category) {
    $categoryItemId = (int) ($category['id'] ?? 0);
    if ($categoryItemId > 0) {
        $categoryMap[$categoryItemId] = (string) ($category['name'] ?? 'N/D');
    }
}

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
    $url = '/baseball-tms/catalogs/teams/crud.php';
    if (!empty($params)) {
        $url .= '?' . http_build_query($params);
    }
    redirect_to($url);
};

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = (string) ($_POST['action'] ?? '');
    $returnQ = trim((string) ($_POST['return_q'] ?? ''));
    $returnPage = max(1, (int) ($_POST['return_page'] ?? 1));

    if ($action === 'create' || $action === 'update') {
        $id = (int) ($_POST['id'] ?? 0);
        $name = trim((string) ($_POST['name'] ?? ''));
        $categoryId = (int) ($_POST['category_id'] ?? 0);

        if ($name === '') {
            $_SESSION['flash_error'] = 'El nombre es obligatorio.';
            $redirectList($returnQ, $returnPage);
        }
        if ($categoryId <= 0 || !isset($categoryMap[$categoryId])) {
            $_SESSION['flash_error'] = 'La categoría seleccionada no es válida.';
            $redirectList($returnQ, $returnPage);
        }

        $payload = [
            'name' => $name,
            'category_id' => $categoryId,
        ];

        if ($action === 'create') {
            $response = api_request('POST', '/teams', $token, $payload);
            if (!empty($response['ok'])) {
                $_SESSION['flash_success'] = 'Equipo creado correctamente.';
            } else {
                $_SESSION['flash_error'] = (string) ($response['body']['message'] ?? 'No se pudo crear el equipo.');
            }
            $redirectList($returnQ, $returnPage);
        }

        if ($id <= 0) {
            $_SESSION['flash_error'] = 'Equipo inválido.';
            $redirectList($returnQ, $returnPage);
        }

        $response = api_request('PUT', '/teams/' . $id, $token, $payload);
        if (!empty($response['ok'])) {
            $_SESSION['flash_success'] = 'Equipo actualizado correctamente.';
        } else {
            $_SESSION['flash_error'] = (string) ($response['body']['message'] ?? 'No se pudo actualizar el equipo.');
        }
        $redirectList($returnQ, $returnPage);
    }

    if ($action === 'toggle') {
        $id = (int) ($_POST['id'] ?? 0);
        if ($id <= 0) {
            $_SESSION['flash_error'] = 'Equipo inválido.';
            $redirectList($returnQ, $returnPage);
        }

        $currentResponse = api_request('GET', '/teams/' . $id, $token);
        $current = $currentResponse['body']['data'] ?? null;
        if (!is_array($current) || empty($currentResponse['ok'])) {
            $_SESSION['flash_error'] = (string) ($currentResponse['body']['message'] ?? 'No se encontró el equipo.');
            $redirectList($returnQ, $returnPage);
        }

        $newStatus = ((int) ($current['is_active'] ?? 0) === 1) ? 0 : 1;
        $payload = ['is_active' => $newStatus];
        $response = api_request('PUT', '/teams/' . $id, $token, $payload);
        if (!empty($response['ok'])) {
            $_SESSION['flash_success'] = $newStatus === 1 ? 'Equipo reactivado correctamente.' : 'Equipo desactivado correctamente.';
        } else {
            $_SESSION['flash_error'] = (string) ($response['body']['message'] ?? 'No se pudo actualizar el estatus.');
        }
        $redirectList($returnQ, $returnPage);
    }

    $_SESSION['flash_error'] = 'Acción no válida.';
    $redirectList($returnQ, $returnPage);
}

$allTeams = [];
$offset = 0;
$batchSize = 200;
$maxIterations = 50;
$iterations = 0;

while ($iterations < $maxIterations) {
    $response = api_request('GET', '/teams?limit=' . $batchSize . '&offset=' . $offset, $token);
    $chunk = $response['body']['data'] ?? [];
    if (!is_array($chunk) || empty($chunk)) {
        break;
    }

    foreach ($chunk as $row) {
        if (is_array($row)) {
            $allTeams[] = $row;
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
    $allTeams = array_values(array_filter($allTeams, static function (array $item) use ($needle, $categoryMap): bool {
        $name = strtolower(trim((string) ($item['name'] ?? '')));
        $categoryName = strtolower(trim((string) ($categoryMap[(int) ($item['category_id'] ?? 0)] ?? '')));
        return strpos($name, $needle) !== false || strpos($categoryName, $needle) !== false;
    }));
}

usort($allTeams, static function (array $a, array $b): int {
    return ((int) ($b['id'] ?? 0)) <=> ((int) ($a['id'] ?? 0));
});

$totalItems = count($allTeams);
$totalPages = max(1, (int) ceil($totalItems / $perPage));
if ($page > $totalPages) {
    $page = $totalPages;
}
$start = ($page - 1) * $perPage;
$teams = array_slice($allTeams, $start, $perPage);

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
    <title>Catálogo de equipos | Baseball-TMS</title>
    <link rel="stylesheet" href="/baseball-tms/styles/main.css">
    <link rel="stylesheet" href="/baseball-tms/catalogs/teams/crud.css">
</head>
<body>
<header class="topbar">
    <div class="topbar__brand">
        <img src="/baseball-tms/assets/logo/sindicato.jpg" alt="Logo Baseball-TMS" class="topbar__logo">
        <div>
            <h1>Baseball-TMS</h1>
            <p>Catálogo de equipos</p>
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
                <h2>Equipos</h2>
                <p class="text-muted">Usuario: <?= htmlspecialchars($userDisplay, ENT_QUOTES, 'UTF-8') ?> | Equipo: <?= htmlspecialchars($teamName, ENT_QUOTES, 'UTF-8') ?></p>
            </div>
            <button type="button" class="btn btn--primary" data-open-modal="modal-create">Nuevo equipo</button>
        </div>

        <form class="catalog-search" method="get" action="/baseball-tms/catalogs/teams/crud.php">
            <input type="text" name="q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>" placeholder="Buscar por nombre o categoría">
            <button type="submit" class="btn btn--ghost">Buscar</button>
        </form>

        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>Nombre</th>
                        <th>Categoría</th>
                        <th>Estatus</th>
                        <th>Acción</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($teams)): ?>
                        <tr>
                            <td colspan="4">No hay equipos para mostrar.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($teams as $team): ?>
                            <?php
                            $teamRowId = (int) ($team['id'] ?? 0);
                            $isActive = (int) ($team['is_active'] ?? 0) === 1;
                            $teamCategoryId = (int) ($team['category_id'] ?? 0);
                            $teamCategoryName = (string) ($categoryMap[$teamCategoryId] ?? 'N/D');
                            ?>
                            <tr>
                                <td><?= htmlspecialchars((string) ($team['name'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars($teamCategoryName, ENT_QUOTES, 'UTF-8') ?></td>
                                <td>
                                    <span class="status-pill <?= $isActive ? 'status-pill--active' : 'status-pill--inactive' ?>">
                                        <?= $isActive ? 'Activo' : 'Inactivo' ?>
                                    </span>
                                </td>
                                <td>
                                    <button type="button" class="btn btn--ghost" data-open-modal="modal-detail-<?= $teamRowId ?>">Ver</button>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>

        <div class="pagination">
            <?php if ($page > 1): ?>
                <a class="btn btn--ghost" href="/baseball-tms/catalogs/teams/crud.php<?= htmlspecialchars($queryForPage($page - 1, $search), ENT_QUOTES, 'UTF-8') ?>">Anterior</a>
            <?php endif; ?>
            <span class="text-muted">Página <?= $page ?> de <?= $totalPages ?> | Total: <?= $totalItems ?></span>
            <?php if ($page < $totalPages): ?>
                <a class="btn btn--ghost" href="/baseball-tms/catalogs/teams/crud.php<?= htmlspecialchars($queryForPage($page + 1, $search), ENT_QUOTES, 'UTF-8') ?>">Siguiente</a>
            <?php endif; ?>
        </div>
    </section>
</main>

<div class="modal" id="modal-create" hidden>
    <div class="modal__backdrop" data-close-modal></div>
    <div class="modal__content" role="dialog" aria-modal="true" aria-labelledby="modal-create-title">
        <h3 id="modal-create-title">Nuevo equipo</h3>
        <form method="post" action="/baseball-tms/catalogs/teams/crud.php">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="return_q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>">
            <input type="hidden" name="return_page" value="<?= $page ?>">
            <label>Nombre
                <input type="text" name="name" required maxlength="150">
            </label>
            <label>Categoría
                <select name="category_id" required>
                    <option value="">Selecciona una categoría</option>
                    <?php foreach ($categoryMap as $categoryIdOption => $categoryLabel): ?>
                        <option value="<?= (int) $categoryIdOption ?>"><?= htmlspecialchars($categoryLabel, ENT_QUOTES, 'UTF-8') ?></option>
                    <?php endforeach; ?>
                </select>
            </label>
            <div class="modal__actions">
                <button type="button" class="btn btn--ghost" data-close-modal>Cerrar</button>
                <button type="submit" class="btn btn--primary">Guardar</button>
            </div>
        </form>
    </div>
</div>

<?php foreach ($teams as $team): ?>
    <?php
    $teamRowId = (int) ($team['id'] ?? 0);
    $isActive = (int) ($team['is_active'] ?? 0) === 1;
    $teamCategoryId = (int) ($team['category_id'] ?? 0);
    ?>
    <div class="modal" id="modal-detail-<?= $teamRowId ?>" hidden>
        <div class="modal__backdrop" data-close-modal></div>
        <div class="modal__content" role="dialog" aria-modal="true" aria-labelledby="modal-detail-title-<?= $teamRowId ?>">
            <h3 id="modal-detail-title-<?= $teamRowId ?>">Detalle de equipo #<?= $teamRowId ?></h3>
            <form method="post" action="/baseball-tms/catalogs/teams/crud.php">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" value="<?= $teamRowId ?>">
                <input type="hidden" name="return_q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>">
                <input type="hidden" name="return_page" value="<?= $page ?>">
                <label>Nombre
                    <input type="text" name="name" required maxlength="150" value="<?= htmlspecialchars((string) ($team['name'] ?? ''), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Categoría
                    <select name="category_id" required>
                        <?php foreach ($categoryMap as $categoryIdOption => $categoryLabel): ?>
                            <option value="<?= (int) $categoryIdOption ?>" <?= $teamCategoryId === (int) $categoryIdOption ? 'selected' : '' ?>>
                                <?= htmlspecialchars($categoryLabel, ENT_QUOTES, 'UTF-8') ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <div class="modal__actions">
                    <button type="button" class="btn btn--ghost" data-close-modal>Cerrar</button>
                    <a class="btn btn--ghost" href="/baseball-tms/catalogs/teams/credentials.php?id=<?= $teamRowId ?>" target="_blank" rel="noopener">Ver credenciales</a>
                    <a class="btn btn--ghost" href="/baseball-tms/catalogs/teams/playerlist.php?id=<?= $teamRowId ?>">Generar Lista de Jugadores</a>
                    <button type="submit" class="btn btn--primary">Guardar cambios</button>
                </div>
            </form>

            <form method="post" action="/baseball-tms/catalogs/teams/crud.php" class="toggle-form">
                <input type="hidden" name="action" value="toggle">
                <input type="hidden" name="id" value="<?= $teamRowId ?>">
                <input type="hidden" name="return_q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>">
                <input type="hidden" name="return_page" value="<?= $page ?>">
                <button type="submit" class="btn <?= $isActive ? 'btn--danger' : 'btn--primary' ?>">
                    <?= $isActive ? 'Desactivar' : 'Reactivar' ?>
                </button>
            </form>
        </div>
    </div>
<?php endforeach; ?>

<script src="/baseball-tms/scripts/main.js"></script>
<script src="/baseball-tms/catalogs/teams/crud.js"></script>
</body>
</html>
