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
    $url = '/baseball-tms/catalogs/categories/crud.php';
    if (!empty($params)) {
        $url .= '?' . http_build_query($params);
    }
    redirect_to($url);
};

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = (string) ($_POST['action'] ?? '');
    $returnQ = trim((string) ($_POST['return_q'] ?? ''));
    $returnPage = max(1, (int) ($_POST['return_page'] ?? 1));

    if ($action === 'create') {
        $name = trim((string) ($_POST['name'] ?? ''));
        $descriptionRaw = trim((string) ($_POST['description'] ?? ''));
        $description = $descriptionRaw !== '' ? $descriptionRaw : null;

        if ($name === '') {
            $_SESSION['flash_error'] = 'El nombre es obligatorio.';
            $redirectList($returnQ, $returnPage);
        }

        $payload = [
            'name' => $name,
            'description' => $description,
        ];
        $response = api_request('POST', '/categories', $token, $payload);
        if (!empty($response['ok'])) {
            $_SESSION['flash_success'] = 'Categoría creada correctamente.';
        } else {
            $_SESSION['flash_error'] = (string) ($response['body']['message'] ?? 'No se pudo crear la categoría.');
        }
        $redirectList($returnQ, $returnPage);
    }

    if ($action === 'update') {
        $id = (int) ($_POST['id'] ?? 0);
        $name = trim((string) ($_POST['name'] ?? ''));
        $descriptionRaw = trim((string) ($_POST['description'] ?? ''));
        $description = $descriptionRaw !== '' ? $descriptionRaw : null;

        if ($id <= 0) {
            $_SESSION['flash_error'] = 'Categoría inválida.';
            $redirectList($returnQ, $returnPage);
        }
        if ($name === '') {
            $_SESSION['flash_error'] = 'El nombre es obligatorio.';
            $redirectList($returnQ, $returnPage);
        }

        $payload = [
            'name' => $name,
            'description' => $description,
        ];
        $response = api_request('PUT', '/categories/' . $id, $token, $payload);
        if (!empty($response['ok'])) {
            $_SESSION['flash_success'] = 'Categoría actualizada correctamente.';
        } else {
            $_SESSION['flash_error'] = (string) ($response['body']['message'] ?? 'No se pudo actualizar la categoría.');
        }
        $redirectList($returnQ, $returnPage);
    }

    if ($action === 'toggle') {
        $id = (int) ($_POST['id'] ?? 0);
        if ($id <= 0) {
            $_SESSION['flash_error'] = 'Categoría inválida.';
            $redirectList($returnQ, $returnPage);
        }

        $currentResponse = api_request('GET', '/categories/' . $id, $token);
        $current = $currentResponse['body']['data'] ?? null;
        if (!is_array($current) || empty($currentResponse['ok'])) {
            $_SESSION['flash_error'] = (string) ($currentResponse['body']['message'] ?? 'No se encontró la categoría.');
            $redirectList($returnQ, $returnPage);
        }

        $newStatus = ((int) ($current['is_active'] ?? 0) === 1) ? 0 : 1;
        $payload = ['is_active' => $newStatus];
        $response = api_request('PUT', '/categories/' . $id, $token, $payload);
        if (!empty($response['ok'])) {
            $_SESSION['flash_success'] = $newStatus === 1 ? 'Categoría reactivada correctamente.' : 'Categoría desactivada correctamente.';
        } else {
            $_SESSION['flash_error'] = (string) ($response['body']['message'] ?? 'No se pudo actualizar el estatus.');
        }
        $redirectList($returnQ, $returnPage);
    }

    $_SESSION['flash_error'] = 'Acción no válida.';
    $redirectList($returnQ, $returnPage);
}

$allCategories = [];
$offset = 0;
$batchSize = 200;
$maxIterations = 50;
$iterations = 0;

while ($iterations < $maxIterations) {
    $response = api_request('GET', '/categories?limit=' . $batchSize . '&offset=' . $offset, $token);
    $chunk = $response['body']['data'] ?? [];
    if (!is_array($chunk) || empty($chunk)) {
        break;
    }

    foreach ($chunk as $row) {
        if (is_array($row)) {
            $allCategories[] = $row;
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
    $allCategories = array_values(array_filter($allCategories, static function (array $item) use ($needle): bool {
        $name = strtolower(trim((string) ($item['name'] ?? '')));
        $description = strtolower(trim((string) ($item['description'] ?? '')));
        return strpos($name, $needle) !== false || strpos($description, $needle) !== false;
    }));
}

usort($allCategories, static function (array $a, array $b): int {
    return ((int) ($b['id'] ?? 0)) <=> ((int) ($a['id'] ?? 0));
});

$totalItems = count($allCategories);
$totalPages = max(1, (int) ceil($totalItems / $perPage));
if ($page > $totalPages) {
    $page = $totalPages;
}
$start = ($page - 1) * $perPage;
$categories = array_slice($allCategories, $start, $perPage);

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
    <title>Catálogo de categorías | Baseball-TMS</title>
    <link rel="stylesheet" href="/baseball-tms/styles/main.css">
    <link rel="stylesheet" href="/baseball-tms/catalogs/categories/crud.css">
</head>
<body>
<header class="topbar">
    <div class="topbar__brand">
        <img src="/baseball-tms/assets/logo/sindicato.jpg" alt="Logo Baseball-TMS" class="topbar__logo">
        <div>
            <h1>Baseball-TMS</h1>
            <p>Catálogo de categorías</p>
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
                <h2>Categorías</h2>
                <p class="text-muted">Usuario: <?= htmlspecialchars($userDisplay, ENT_QUOTES, 'UTF-8') ?> | Equipo: <?= htmlspecialchars($teamName, ENT_QUOTES, 'UTF-8') ?></p>
            </div>
            <button type="button" class="btn btn--primary" data-open-modal="modal-create">Nueva categoría</button>
        </div>

        <form class="catalog-search" method="get" action="/baseball-tms/catalogs/categories/crud.php">
            <input type="text" name="q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>" placeholder="Buscar por nombre o descripción">
            <button type="submit" class="btn btn--ghost">Buscar</button>
        </form>

        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>Nombre</th>
                        <th>Descripción</th>
                        <th>Estatus</th>
                        <th>Acción</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($categories)): ?>
                        <tr>
                            <td colspan="4">No hay categorías para mostrar.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($categories as $category): ?>
                            <?php
                            $categoryId = (int) ($category['id'] ?? 0);
                            $isActive = (int) ($category['is_active'] ?? 0) === 1;
                            ?>
                            <tr>
                                <td><?= htmlspecialchars((string) ($category['name'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars((string) ($category['description'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td>
                                <td>
                                    <span class="status-pill <?= $isActive ? 'status-pill--active' : 'status-pill--inactive' ?>">
                                        <?= $isActive ? 'Activo' : 'Inactivo' ?>
                                    </span>
                                </td>
                                <td>
                                    <button type="button" class="btn btn--ghost" data-open-modal="modal-detail-<?= $categoryId ?>">Ver</button>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>

        <div class="pagination">
            <?php if ($page > 1): ?>
                <a class="btn btn--ghost" href="/baseball-tms/catalogs/categories/crud.php<?= htmlspecialchars($queryForPage($page - 1, $search), ENT_QUOTES, 'UTF-8') ?>">Anterior</a>
            <?php endif; ?>
            <span class="text-muted">Página <?= $page ?> de <?= $totalPages ?> | Total: <?= $totalItems ?></span>
            <?php if ($page < $totalPages): ?>
                <a class="btn btn--ghost" href="/baseball-tms/catalogs/categories/crud.php<?= htmlspecialchars($queryForPage($page + 1, $search), ENT_QUOTES, 'UTF-8') ?>">Siguiente</a>
            <?php endif; ?>
        </div>
    </section>
</main>

<div class="modal" id="modal-create" hidden>
    <div class="modal__backdrop" data-close-modal></div>
    <div class="modal__content" role="dialog" aria-modal="true" aria-labelledby="modal-create-title">
        <h3 id="modal-create-title">Nueva categoría</h3>
        <form method="post" action="/baseball-tms/catalogs/categories/crud.php">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="return_q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>">
            <input type="hidden" name="return_page" value="<?= $page ?>">
            <label>Nombre
                <input type="text" name="name" required maxlength="100">
            </label>
            <label>Descripción
                <textarea name="description" rows="4"></textarea>
            </label>
            <div class="modal__actions">
                <button type="button" class="btn btn--ghost" data-close-modal>Cerrar</button>
                <button type="submit" class="btn btn--primary">Guardar</button>
            </div>
        </form>
    </div>
</div>

<?php foreach ($categories as $category): ?>
    <?php
    $categoryId = (int) ($category['id'] ?? 0);
    $isActive = (int) ($category['is_active'] ?? 0) === 1;
    ?>
    <div class="modal" id="modal-detail-<?= $categoryId ?>" hidden>
        <div class="modal__backdrop" data-close-modal></div>
        <div class="modal__content" role="dialog" aria-modal="true" aria-labelledby="modal-detail-title-<?= $categoryId ?>">
            <h3 id="modal-detail-title-<?= $categoryId ?>">Detalle de categoría #<?= $categoryId ?></h3>
            <form method="post" action="/baseball-tms/catalogs/categories/crud.php">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" value="<?= $categoryId ?>">
                <input type="hidden" name="return_q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>">
                <input type="hidden" name="return_page" value="<?= $page ?>">
                <label>Nombre
                    <input type="text" name="name" required maxlength="100" value="<?= htmlspecialchars((string) ($category['name'] ?? ''), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Descripción
                    <textarea name="description" rows="4"><?= htmlspecialchars((string) ($category['description'] ?? ''), ENT_QUOTES, 'UTF-8') ?></textarea>
                </label>
                <div class="modal__actions">
                    <button type="button" class="btn btn--ghost" data-close-modal>Cerrar</button>
                    <button type="submit" class="btn btn--primary">Guardar cambios</button>
                </div>
            </form>

            <form method="post" action="/baseball-tms/catalogs/categories/crud.php" class="toggle-form">
                <input type="hidden" name="action" value="toggle">
                <input type="hidden" name="id" value="<?= $categoryId ?>">
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
<script src="/baseball-tms/catalogs/categories/crud.js"></script>
</body>
</html>
