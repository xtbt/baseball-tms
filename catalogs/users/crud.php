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

$employeeClassOptions = ['BASE', 'CONFIANZA', 'CONTRATO', 'HIJO', 'INVITADO'];
$shirtSizeOptions = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];
$roleOptions = ['admin', 'manager', 'player'];

$teamsResponse = api_request('GET', '/teams?limit=500&offset=0', $token);
$teams = $teamsResponse['body']['data'] ?? [];
$teamsMap = [];
foreach ($teams as $teamItem) {
    $teamItemId = (int) ($teamItem['id'] ?? 0);
    if ($teamItemId > 0) {
        $teamsMap[$teamItemId] = (string) ($teamItem['name'] ?? 'N/D');
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
    $url = '/baseball-tms/catalogs/users/crud.php';
    if (!empty($params)) {
        $url .= '?' . http_build_query($params);
    }
    redirect_to($url);
};

$hasPhotoUpload = static function (): bool {
    if (!isset($_FILES['photo']) || !is_array($_FILES['photo'])) {
        return false;
    }
    return (int) ($_FILES['photo']['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_NO_FILE;
};

$uploadPhotoForUser = static function (int $targetUserId, string $token): array {
    if (!isset($_FILES['photo']) || !is_array($_FILES['photo'])) {
        return ['ok' => false, 'message' => 'No se recibió imagen.'];
    }

    if (!function_exists('curl_file_create')) {
        return ['ok' => false, 'message' => 'La carga de imagen no está disponible en este servidor.'];
    }

    $tmpPath = (string) ($_FILES['photo']['tmp_name'] ?? '');
    $originalName = (string) ($_FILES['photo']['name'] ?? ('user_' . $targetUserId . '.jpg'));
    if ($tmpPath === '' || !is_uploaded_file($tmpPath)) {
        return ['ok' => false, 'message' => 'Archivo de imagen inválido.'];
    }

    $mimeType = function_exists('mime_content_type') ? (string) mime_content_type($tmpPath) : 'image/jpeg';
    if ($mimeType === '') {
        $mimeType = 'image/jpeg';
    }

    $filePayload = ['photo' => curl_file_create($tmpPath, $mimeType, $originalName)];
    $uploadResponse = api_request_multipart('POST', '/users/' . $targetUserId . '/photo', $token, $filePayload);

    if (!empty($uploadResponse['ok'])) {
        return ['ok' => true, 'message' => ''];
    }

    return [
        'ok' => false,
        'message' => (string) ($uploadResponse['body']['message'] ?? 'No se pudo guardar la imagen del usuario.'),
    ];
};

$stringOrNull = static function (string $key): ?string {
    $value = trim((string) ($_POST[$key] ?? ''));
    return $value !== '' ? $value : null;
};

$buildProfilePayload = static function (array $teamsMap, array $employeeClassOptions, array $shirtSizeOptions): array {
    $firstName = trim((string) ($_POST['first_name'] ?? ''));
    $paternalSurname = trim((string) ($_POST['paternal_surname'] ?? ''));
    $maternalSurnameRaw = trim((string) ($_POST['maternal_surname'] ?? ''));
    $birthDate = trim((string) ($_POST['birth_date'] ?? ''));
    $curpRaw = trim((string) ($_POST['curp'] ?? ''));
    $phoneRaw = trim((string) ($_POST['phone'] ?? ''));
    $positionRaw = trim((string) ($_POST['position'] ?? ''));
    $employeeClassRaw = trim((string) ($_POST['employee_class'] ?? ''));
    $employeeNumberRaw = trim((string) ($_POST['employee_number'] ?? ''));
    $employeeAreaRaw = trim((string) ($_POST['employee_area'] ?? ''));
    $isstecaliAffiliationRaw = trim((string) ($_POST['isstecali_affiliation'] ?? ''));
    $shirtSizeRaw = trim((string) ($_POST['shirt_size'] ?? ''));
    $pantsSizeRaw = trim((string) ($_POST['pants_size'] ?? ''));
    $hatSizeRaw = trim((string) ($_POST['hat_size'] ?? ''));

    $teamIdRaw = trim((string) ($_POST['team_id'] ?? ''));
    $teamId = null;
    if ($teamIdRaw !== '') {
        if (!ctype_digit($teamIdRaw) || (int) $teamIdRaw <= 0 || !isset($teamsMap[(int) $teamIdRaw])) {
            throw new RuntimeException('El equipo seleccionado no es válido.');
        }
        $teamId = (int) $teamIdRaw;
    }

    if ($firstName === '' || $paternalSurname === '' || $birthDate === '') {
        throw new RuntimeException('Nombre, apellido paterno y fecha de nacimiento son obligatorios.');
    }

    $birthDateValid = date_create_from_format('Y-m-d', $birthDate);
    if (!$birthDateValid || $birthDateValid->format('Y-m-d') !== $birthDate) {
        throw new RuntimeException('La fecha de nacimiento debe tener formato válido.');
    }

    if ($curpRaw !== '' && !preg_match('/^[A-Z]{4}[0-9]{6}[A-Z]{6}[A-Z0-9]{2}$/i', $curpRaw)) {
        throw new RuntimeException('La CURP debe tener formato válido de 18 caracteres.');
    }

    if ($phoneRaw !== '' && !preg_match('/^[0-9+()\-\s]{7,20}$/', $phoneRaw)) {
        throw new RuntimeException('El teléfono debe contener únicamente números y símbolos válidos.');
    }

    if ($employeeClassRaw !== '' && !in_array($employeeClassRaw, $employeeClassOptions, true)) {
        throw new RuntimeException('La clase de empleado seleccionada no es válida.');
    }

    if ($shirtSizeRaw !== '' && !in_array($shirtSizeRaw, $shirtSizeOptions, true)) {
        throw new RuntimeException('La talla de playera seleccionada no es válida.');
    }

    $jerseyRaw = trim((string) ($_POST['jersey_number'] ?? ''));
    $jerseyNumber = null;
    if ($jerseyRaw !== '') {
        if (!ctype_digit($jerseyRaw)) {
            throw new RuntimeException('El número de jersey debe ser numérico.');
        }
        $jerseyNumber = (int) $jerseyRaw;
    }

    $pantsSizeNumber = null;
    if ($pantsSizeRaw !== '') {
        if (!ctype_digit($pantsSizeRaw) || (int) $pantsSizeRaw > 99) {
            throw new RuntimeException('La talla de pantalón debe ser un número de hasta 2 dígitos.');
        }
        $pantsSizeNumber = (int) $pantsSizeRaw;
    }

    return [
        'team_id' => $teamId,
        'first_name' => $firstName,
        'paternal_surname' => $paternalSurname,
        'maternal_surname' => $maternalSurnameRaw !== '' ? $maternalSurnameRaw : null,
        'birth_date' => $birthDate,
        'curp' => $curpRaw !== '' ? $curpRaw : null,
        'phone' => $phoneRaw !== '' ? $phoneRaw : null,
        'jersey_number' => $jerseyNumber,
        'position' => $positionRaw !== '' ? $positionRaw : null,
        'employee_class' => $employeeClassRaw !== '' ? $employeeClassRaw : null,
        'employee_number' => $employeeNumberRaw !== '' ? $employeeNumberRaw : null,
        'employee_area' => $employeeAreaRaw !== '' ? $employeeAreaRaw : null,
        'isstecali_affiliation' => $isstecaliAffiliationRaw !== '' ? $isstecaliAffiliationRaw : null,
        'shirt_size' => $shirtSizeRaw !== '' ? $shirtSizeRaw : null,
        'pants_size' => $pantsSizeNumber,
        'hat_size' => $hatSizeRaw !== '' ? $hatSizeRaw : null,
    ];
};

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = (string) ($_POST['action'] ?? '');
    $returnQ = trim((string) ($_POST['return_q'] ?? ''));
    $returnPage = max(1, (int) ($_POST['return_page'] ?? 1));

    if ($action === 'create') {
        $email = trim((string) ($_POST['email'] ?? ''));
        $role = trim((string) ($_POST['role'] ?? 'player'));
        $password = (string) ($_POST['password'] ?? '');

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $_SESSION['flash_error'] = 'Correo inválido.';
            $redirectList($returnQ, $returnPage);
        }
        if (!in_array($role, $roleOptions, true)) {
            $_SESSION['flash_error'] = 'Rol inválido.';
            $redirectList($returnQ, $returnPage);
        }
        if (trim($password) === '') {
            $_SESSION['flash_error'] = 'La contraseña es obligatoria al crear usuario.';
            $redirectList($returnQ, $returnPage);
        }

        try {
            $profilePayload = $buildProfilePayload($teamsMap, $employeeClassOptions, $shirtSizeOptions);
        } catch (RuntimeException $e) {
            $_SESSION['flash_error'] = $e->getMessage();
            $redirectList($returnQ, $returnPage);
        }

        $createResponse = api_request('POST', '/users', $token, ['email' => $email, 'role' => $role, 'password' => $password]);
        if (empty($createResponse['ok'])) {
            $_SESSION['flash_error'] = (string) ($createResponse['body']['message'] ?? 'No se pudo crear el usuario.');
            $redirectList($returnQ, $returnPage);
        }

        $newUserId = (int) ($createResponse['body']['data']['id'] ?? 0);
        if ($newUserId <= 0) {
            $_SESSION['flash_error'] = 'Usuario creado sin identificador válido.';
            $redirectList($returnQ, $returnPage);
        }

        $profileSaveResponse = api_request('PUT', '/users/' . $newUserId . '/profile', $token, $profilePayload);
        if (empty($profileSaveResponse['ok'])) {
            $_SESSION['flash_error'] = 'Usuario creado pero no se pudo guardar el perfil.';
            $redirectList($returnQ, $returnPage);
        }

        if ($hasPhotoUpload()) {
            $uploadResult = $uploadPhotoForUser($newUserId, $token);
            if (empty($uploadResult['ok'])) {
                $_SESSION['flash_error'] = 'Usuario creado pero no se pudo guardar la imagen: ' . (string) ($uploadResult['message'] ?? 'Error desconocido.');
                $redirectList($returnQ, $returnPage);
            }
        }

        $_SESSION['flash_success'] = 'Usuario creado correctamente.';
        $redirectList($returnQ, $returnPage);
    }

    if ($action === 'update') {
        $targetId = (int) ($_POST['id'] ?? 0);
        $email = trim((string) ($_POST['email'] ?? ''));
        $role = trim((string) ($_POST['role'] ?? 'player'));

        if ($targetId <= 0) {
            $_SESSION['flash_error'] = 'Usuario inválido.';
            $redirectList($returnQ, $returnPage);
        }
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $_SESSION['flash_error'] = 'Correo inválido.';
            $redirectList($returnQ, $returnPage);
        }
        if (!in_array($role, $roleOptions, true)) {
            $_SESSION['flash_error'] = 'Rol inválido.';
            $redirectList($returnQ, $returnPage);
        }

        try {
            $profilePayload = $buildProfilePayload($teamsMap, $employeeClassOptions, $shirtSizeOptions);
        } catch (RuntimeException $e) {
            $_SESSION['flash_error'] = $e->getMessage();
            $redirectList($returnQ, $returnPage);
        }

        $updateResponse = api_request('PUT', '/users/' . $targetId, $token, ['email' => $email, 'role' => $role]);
        if (empty($updateResponse['ok'])) {
            $_SESSION['flash_error'] = (string) ($updateResponse['body']['message'] ?? 'No se pudo actualizar el usuario.');
            $redirectList($returnQ, $returnPage);
        }

        $profileSaveResponse = api_request('PUT', '/users/' . $targetId . '/profile', $token, $profilePayload);
        if (empty($profileSaveResponse['ok'])) {
            $_SESSION['flash_error'] = 'Usuario actualizado pero no se pudo guardar el perfil.';
            $redirectList($returnQ, $returnPage);
        }

        if ($hasPhotoUpload()) {
            $uploadResult = $uploadPhotoForUser($targetId, $token);
            if (empty($uploadResult['ok'])) {
                $_SESSION['flash_error'] = 'Usuario actualizado pero no se pudo guardar la imagen: ' . (string) ($uploadResult['message'] ?? 'Error desconocido.');
                $redirectList($returnQ, $returnPage);
            }
        }

        $_SESSION['flash_success'] = 'Usuario actualizado correctamente.';
        $redirectList($returnQ, $returnPage);
    }

    if ($action === 'toggle') {
        $targetId = (int) ($_POST['id'] ?? 0);
        if ($targetId <= 0) {
            $_SESSION['flash_error'] = 'Usuario inválido.';
            $redirectList($returnQ, $returnPage);
        }

        $currentResponse = api_request('GET', '/users/' . $targetId, $token);
        $current = $currentResponse['body']['data'] ?? null;
        if (!is_array($current) || empty($currentResponse['ok'])) {
            $_SESSION['flash_error'] = (string) ($currentResponse['body']['message'] ?? 'No se encontró el usuario.');
            $redirectList($returnQ, $returnPage);
        }

        $newStatus = ((int) ($current['is_active'] ?? 0) === 1) ? 0 : 1;
        $payload = ['is_active' => $newStatus];
        $response = api_request('PUT', '/users/' . $targetId, $token, $payload);
        if (!empty($response['ok'])) {
            $_SESSION['flash_success'] = $newStatus === 1 ? 'Usuario reactivado correctamente.' : 'Usuario desactivado correctamente.';
        } else {
            $_SESSION['flash_error'] = (string) ($response['body']['message'] ?? 'No se pudo actualizar el estatus.');
        }
        $redirectList($returnQ, $returnPage);
    }

    if ($action === 'change_password') {
        $targetId = (int) ($_POST['id'] ?? 0);
        $newPassword = (string) ($_POST['new_password'] ?? '');
        if ($targetId <= 0) {
            $_SESSION['flash_error'] = 'Usuario inválido.';
            $redirectList($returnQ, $returnPage);
        }
        if (trim($newPassword) === '') {
            $_SESSION['flash_error'] = 'La nueva contraseña es obligatoria.';
            $redirectList($returnQ, $returnPage);
        }

        $response = api_request('PUT', '/users/' . $targetId, $token, ['password' => $newPassword]);
        if (!empty($response['ok'])) {
            $_SESSION['flash_success'] = 'Contraseña actualizada correctamente.';
        } else {
            $_SESSION['flash_error'] = (string) ($response['body']['message'] ?? 'No se pudo cambiar la contraseña.');
        }
        $redirectList($returnQ, $returnPage);
    }

    $_SESSION['flash_error'] = 'Acción no válida.';
    $redirectList($returnQ, $returnPage);
}

$photoAbsolutePathByUserId = static function (int $targetUserId): string {
    return __DIR__ . '/../../images/users/' . $targetUserId . '.jpg';
};
$defaultPhotoRelativePath = '/baseball-tms/images/users/no_image.jpg';
$defaultPhotoAbsolutePath = __DIR__ . '/../../images/users/no_image.jpg';
if (!is_file($defaultPhotoAbsolutePath)) {
    $defaultPhotoRelativePath = '/baseball-tms/images/no_image.jpg';
    $defaultPhotoAbsolutePath = __DIR__ . '/../../images/no_image.jpg';
}
$photoFingerprint = static function (string $absolutePath): string {
    if (!is_file($absolutePath)) {
        return '';
    }
    $hash = @sha1_file($absolutePath);
    if ($hash !== false && $hash !== '') {
        return $hash;
    }
    return (string) @filemtime($absolutePath);
};
$defaultPhotoUrl = $defaultPhotoRelativePath;
if (is_file($defaultPhotoAbsolutePath)) {
    $defaultPhotoUrl .= '?v=' . $photoFingerprint($defaultPhotoAbsolutePath);
}
$photoUrlByUserId = static function (int $targetUserId) use ($photoAbsolutePathByUserId, $defaultPhotoRelativePath, $defaultPhotoAbsolutePath, $photoFingerprint): string {
    $relativePath = '/baseball-tms/images/users/' . $targetUserId . '.jpg';
    $absolutePath = $photoAbsolutePathByUserId($targetUserId);
    if (is_file($absolutePath)) {
        return $relativePath . '?v=' . $photoFingerprint($absolutePath);
    }
    if (is_file($defaultPhotoAbsolutePath)) {
        return $defaultPhotoRelativePath . '?v=' . $photoFingerprint($defaultPhotoAbsolutePath);
    }
    return $defaultPhotoRelativePath;
};

$fetchUsersPage = static function (int $currentPage, int $perPageValue, string $searchValue, string $authToken): array {
    $params = [
        'include_profile' => 1,
        'limit' => $perPageValue,
        'offset' => max(0, ($currentPage - 1) * $perPageValue),
    ];
    if ($searchValue !== '') {
        $params['q'] = $searchValue;
    }

    $response = api_request('GET', '/users?' . http_build_query($params), $authToken);
    $data = $response['body']['data'] ?? [];
    $items = is_array($data['items'] ?? null) ? $data['items'] : [];
    $meta = is_array($data['meta'] ?? null) ? $data['meta'] : [];

    return [
        'items' => $items,
        'total' => max(0, (int) ($meta['total'] ?? 0)),
    ];
};

$pageData = $fetchUsersPage($page, $perPage, $search, $token);
$totalItems = $pageData['total'];
$totalPages = max(1, (int) ceil($totalItems / $perPage));
if ($page > $totalPages) {
    $page = $totalPages;
    $pageData = $fetchUsersPage($page, $perPage, $search, $token);
}

$usersPage = [];
foreach ($pageData['items'] as $row) {
    if (!is_array($row)) {
        continue;
    }
    $rowId = (int) ($row['id'] ?? 0);
    $row['profile'] = is_array($row['profile'] ?? null) ? $row['profile'] : [];
    $row['photo_url'] = $photoUrlByUserId($rowId);
    $usersPage[] = $row;
}

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

$formValue = static function ($value): string {
    if ($value === null) {
        return '';
    }
    return trim((string) $value);
};
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Catálogo de usuarios | Baseball-TMS</title>
    <link rel="stylesheet" href="/baseball-tms/styles/main.css">
    <link rel="stylesheet" href="/baseball-tms/catalogs/users/crud.css">
</head>
<body>
<header class="topbar">
    <div class="topbar__brand">
        <img src="/baseball-tms/assets/logo/sindicato.jpg" alt="Logo Baseball-TMS" class="topbar__logo">
        <div>
            <h1>Baseball-TMS</h1>
            <p>Catálogo de usuarios</p>
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
                <h2>Usuarios</h2>
                <p class="text-muted">Usuario: <?= htmlspecialchars($userDisplay, ENT_QUOTES, 'UTF-8') ?> | Equipo: <?= htmlspecialchars($teamName, ENT_QUOTES, 'UTF-8') ?></p>
            </div>
            <button type="button" class="btn btn--primary" data-open-modal="modal-create">Nuevo usuario</button>
        </div>

        <form class="catalog-search" method="get" action="/baseball-tms/catalogs/users/crud.php">
            <input type="text" name="q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>" placeholder="Buscar por correo, rol, nombre o equipo">
            <button type="submit" class="btn btn--ghost">Buscar</button>
        </form>

        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>Foto</th>
                        <th>Correo</th>
                        <th>Nombre</th>
                        <th>Rol</th>
                        <th>Equipo</th>
                        <th>Estatus</th>
                        <th>Acción</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($usersPage)): ?>
                        <tr>
                            <td colspan="7">No hay usuarios para mostrar.</td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($usersPage as $row): ?>
                            <?php
                            $rowId = (int) ($row['id'] ?? 0);
                            $rowProfile = is_array($row['profile'] ?? null) ? $row['profile'] : [];
                            $isActive = (int) ($row['is_active'] ?? 0) === 1;
                            $fullName = trim((string) ($rowProfile['first_name'] ?? '') . ' ' . (string) ($rowProfile['paternal_surname'] ?? '') . ' ' . (string) ($rowProfile['maternal_surname'] ?? ''));
                            $teamLabel = (string) ($teamsMap[(int) ($rowProfile['team_id'] ?? 0)] ?? 'Sin equipo');
                            $rowPhotoUrl = (string) ($row['photo_url'] ?? $defaultPhotoRelativePath);
                            ?>
                            <tr>
                                <td><img src="<?= htmlspecialchars($rowPhotoUrl, ENT_QUOTES, 'UTF-8') ?>" alt="Foto de usuario" class="user-photo user-photo--table"></td>
                                <td><?= htmlspecialchars((string) ($row['email'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars($fullName !== '' ? $fullName : 'N/D', ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars((string) ($row['role'] ?? ''), ENT_QUOTES, 'UTF-8') ?></td>
                                <td><?= htmlspecialchars($teamLabel, ENT_QUOTES, 'UTF-8') ?></td>
                                <td>
                                    <span class="status-pill <?= $isActive ? 'status-pill--active' : 'status-pill--inactive' ?>">
                                        <?= $isActive ? 'Activo' : 'Inactivo' ?>
                                    </span>
                                </td>
                                <td>
                                    <div class="table-actions">
                                        <button type="button" class="btn btn--ghost" data-open-modal="modal-detail-<?= $rowId ?>">Ver</button>
                                        <button type="button" class="btn btn--ghost" data-open-modal="modal-password-<?= $rowId ?>">Cambiar contraseña</button>
                                    </div>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>

        <div class="pagination">
            <?php if ($page > 1): ?>
                <a class="btn btn--ghost" href="/baseball-tms/catalogs/users/crud.php<?= htmlspecialchars($queryForPage($page - 1, $search), ENT_QUOTES, 'UTF-8') ?>">Anterior</a>
            <?php endif; ?>
            <span class="text-muted">Página <?= $page ?> de <?= $totalPages ?> | Total: <?= $totalItems ?></span>
            <?php if ($page < $totalPages): ?>
                <a class="btn btn--ghost" href="/baseball-tms/catalogs/users/crud.php<?= htmlspecialchars($queryForPage($page + 1, $search), ENT_QUOTES, 'UTF-8') ?>">Siguiente</a>
            <?php endif; ?>
        </div>
    </section>
</main>

<div class="modal" id="modal-create" hidden>
    <div class="modal__backdrop" data-close-modal></div>
    <div class="modal__content" role="dialog" aria-modal="true" aria-labelledby="modal-create-title">
        <h3 id="modal-create-title">Nuevo usuario</h3>
        <form method="post" action="/baseball-tms/catalogs/users/crud.php" enctype="multipart/form-data">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="return_q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>">
            <input type="hidden" name="return_page" value="<?= $page ?>">
            <fieldset>
                <legend>Datos de usuario</legend>
                <label>Correo
                    <input type="email" name="email" required maxlength="255">
                </label>
                <label>Rol
                    <select name="role" required>
                        <?php foreach ($roleOptions as $roleOption): ?>
                            <option value="<?= htmlspecialchars($roleOption, ENT_QUOTES, 'UTF-8') ?>"><?= htmlspecialchars($roleOption, ENT_QUOTES, 'UTF-8') ?></option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label>Contraseña
                    <input type="password" name="password" required>
                </label>
            </fieldset>
            <div class="user-photo-panel">
                <img src="<?= htmlspecialchars($defaultPhotoUrl, ENT_QUOTES, 'UTF-8') ?>" alt="Foto de usuario" class="user-photo user-photo--modal">
                <label>Foto de usuario (.jpg, máximo 1600x1600 píxeles, 2MB)
                    <input type="file" name="photo" accept=".jpg,.jpeg,image/jpeg">
                </label>
            </div>
            <fieldset>
                <legend>Datos de perfil</legend>
                <label>Equipo
                    <select name="team_id">
                        <option value="">Sin equipo</option>
                        <?php foreach ($teamsMap as $teamIdOption => $teamLabel): ?>
                            <option value="<?= (int) $teamIdOption ?>"><?= htmlspecialchars($teamLabel, ENT_QUOTES, 'UTF-8') ?></option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label>Nombre
                    <input type="text" name="first_name" required maxlength="100">
                </label>
                <label>Apellido paterno
                    <input type="text" name="paternal_surname" required maxlength="100">
                </label>
                <label>Apellido materno
                    <input type="text" name="maternal_surname" maxlength="100">
                </label>
                <label>Fecha de nacimiento
                    <input type="date" name="birth_date" required max="<?= date('Y-m-d') ?>">
                </label>
                <label>CURP
                    <input type="text" name="curp" maxlength="18">
                </label>
                <label>Teléfono
                    <input type="tel" name="phone" maxlength="20">
                </label>
                <label>Número de jersey
                    <input type="number" name="jersey_number" min="0" max="999" step="1">
                </label>
                <label>Posición
                    <input type="text" name="position" maxlength="50">
                </label>
                <label>Clase de empleado
                    <select name="employee_class">
                        <option value="">No especificado</option>
                        <?php foreach ($employeeClassOptions as $employeeClassOption): ?>
                            <option value="<?= htmlspecialchars($employeeClassOption, ENT_QUOTES, 'UTF-8') ?>"><?= htmlspecialchars($employeeClassOption, ENT_QUOTES, 'UTF-8') ?></option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label>Número de empleado
                    <input type="text" name="employee_number" maxlength="30">
                </label>
                <label>Área de trabajo
                    <input type="text" name="employee_area" maxlength="60">
                </label>
                <label>Afiliación ISSSTECALI
                    <input type="text" name="isstecali_affiliation" maxlength="100">
                </label>
                <label>Talla de playera
                    <select name="shirt_size">
                        <option value="">No especificado</option>
                        <?php foreach ($shirtSizeOptions as $shirtSizeOption): ?>
                            <option value="<?= htmlspecialchars($shirtSizeOption, ENT_QUOTES, 'UTF-8') ?>"><?= htmlspecialchars($shirtSizeOption, ENT_QUOTES, 'UTF-8') ?></option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label>Talla de pantalón
                    <input type="number" name="pants_size" min="0" max="99" step="1">
                </label>
                <label>Talla de gorra
                    <input type="text" name="hat_size" maxlength="6">
                </label>
            </fieldset>
            <div class="modal__actions">
                <button type="button" class="btn btn--ghost" data-close-modal>Cerrar</button>
                <button type="submit" class="btn btn--primary">Guardar</button>
            </div>
        </form>
    </div>
</div>

<?php foreach ($usersPage as $row): ?>
    <?php
    $rowId = (int) ($row['id'] ?? 0);
    $rowProfile = is_array($row['profile'] ?? null) ? $row['profile'] : [];
    $isActive = (int) ($row['is_active'] ?? 0) === 1;
    $rowPhotoUrl = (string) ($row['photo_url'] ?? $defaultPhotoRelativePath);
    ?>
    <div class="modal" id="modal-detail-<?= $rowId ?>" hidden>
        <div class="modal__backdrop" data-close-modal></div>
        <div class="modal__content" role="dialog" aria-modal="true" aria-labelledby="modal-detail-title-<?= $rowId ?>">
            <h3 id="modal-detail-title-<?= $rowId ?>">Detalle de usuario #<?= $rowId ?></h3>
            <form method="post" action="/baseball-tms/catalogs/users/crud.php" enctype="multipart/form-data">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" value="<?= $rowId ?>">
                <input type="hidden" name="return_q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>">
                <input type="hidden" name="return_page" value="<?= $page ?>">
                <fieldset>
                    <legend>Datos de usuario</legend>
                    <label>Correo
                        <input type="email" name="email" required maxlength="255" value="<?= htmlspecialchars((string) ($row['email'] ?? ''), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                    <label>Rol
                        <select name="role" required>
                            <?php foreach ($roleOptions as $roleOption): ?>
                                <option value="<?= htmlspecialchars($roleOption, ENT_QUOTES, 'UTF-8') ?>" <?= (string) ($row['role'] ?? '') === $roleOption ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($roleOption, ENT_QUOTES, 'UTF-8') ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </label>
                </fieldset>
                <div class="user-photo-panel">
                    <img src="<?= htmlspecialchars($rowPhotoUrl, ENT_QUOTES, 'UTF-8') ?>" alt="Foto de usuario" class="user-photo user-photo--modal">
                    <label>Foto de usuario (.jpg, máximo 1600x1600 píxeles, 2MB)
                        <input type="file" name="photo" accept=".jpg,.jpeg,image/jpeg">
                    </label>
                </div>
                <fieldset>
                    <legend>Datos de perfil</legend>
                    <label>Equipo
                        <select name="team_id">
                            <option value="">Sin equipo</option>
                            <?php foreach ($teamsMap as $teamIdOption => $teamLabel): ?>
                                <option value="<?= (int) $teamIdOption ?>" <?= (int) ($rowProfile['team_id'] ?? 0) === (int) $teamIdOption ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($teamLabel, ENT_QUOTES, 'UTF-8') ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </label>
                    <label>Nombre
                        <input type="text" name="first_name" required maxlength="100" value="<?= htmlspecialchars($formValue($rowProfile['first_name'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                    <label>Apellido paterno
                        <input type="text" name="paternal_surname" required maxlength="100" value="<?= htmlspecialchars($formValue($rowProfile['paternal_surname'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                    <label>Apellido materno
                        <input type="text" name="maternal_surname" maxlength="100" value="<?= htmlspecialchars($formValue($rowProfile['maternal_surname'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                    <label>Fecha de nacimiento
                        <input type="date" name="birth_date" required max="<?= date('Y-m-d') ?>" value="<?= htmlspecialchars($formValue($rowProfile['birth_date'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                    <label>CURP
                        <input type="text" name="curp" maxlength="18" value="<?= htmlspecialchars($formValue($rowProfile['curp'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                    <label>Teléfono
                        <input type="tel" name="phone" maxlength="20" value="<?= htmlspecialchars($formValue($rowProfile['phone'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                    <label>Número de jersey
                        <input type="number" name="jersey_number" min="0" max="999" step="1" value="<?= htmlspecialchars($formValue($rowProfile['jersey_number'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                    <label>Posición
                        <input type="text" name="position" maxlength="50" value="<?= htmlspecialchars($formValue($rowProfile['position'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                    <label>Clase de empleado
                        <select name="employee_class">
                            <option value="">No especificado</option>
                            <?php foreach ($employeeClassOptions as $employeeClassOption): ?>
                                <option value="<?= htmlspecialchars($employeeClassOption, ENT_QUOTES, 'UTF-8') ?>" <?= $formValue($rowProfile['employee_class'] ?? null) === $employeeClassOption ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($employeeClassOption, ENT_QUOTES, 'UTF-8') ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </label>
                    <label>Número de empleado
                        <input type="text" name="employee_number" maxlength="30" value="<?= htmlspecialchars($formValue($rowProfile['employee_number'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                    <label>Área de trabajo
                        <input type="text" name="employee_area" maxlength="60" value="<?= htmlspecialchars($formValue($rowProfile['employee_area'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                    <label>Afiliación ISSSTECALI
                        <input type="text" name="isstecali_affiliation" maxlength="100" value="<?= htmlspecialchars($formValue($rowProfile['isstecali_affiliation'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                    <label>Talla de playera
                        <select name="shirt_size">
                            <option value="" <?= $formValue($rowProfile['shirt_size'] ?? null) === '' ? 'selected' : '' ?>>No especificado</option>
                            <?php foreach ($shirtSizeOptions as $shirtSizeOption): ?>
                                <option value="<?= htmlspecialchars($shirtSizeOption, ENT_QUOTES, 'UTF-8') ?>" <?= $formValue($rowProfile['shirt_size'] ?? null) === $shirtSizeOption ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($shirtSizeOption, ENT_QUOTES, 'UTF-8') ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </label>
                    <label>Talla de pantalón
                        <input type="number" name="pants_size" min="0" max="99" step="1" value="<?= htmlspecialchars($formValue($rowProfile['pants_size'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                    <label>Talla de gorra
                        <input type="text" name="hat_size" maxlength="6" value="<?= htmlspecialchars($formValue($rowProfile['hat_size'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    </label>
                </fieldset>
                <div class="modal__actions">
                    <button type="button" class="btn btn--ghost" data-close-modal>Cerrar</button>
                    <a class="btn btn--ghost" href="/baseball-tms/catalogs/users/credential.php?id=<?= $rowId ?>" target="_blank" rel="noopener">Ver Credencial</a>
                    <button type="submit" class="btn btn--primary">Guardar cambios</button>
                </div>
            </form>
            <form method="post" action="/baseball-tms/catalogs/users/crud.php" class="modal__actions">
                <input type="hidden" name="action" value="toggle">
                <input type="hidden" name="id" value="<?= $rowId ?>">
                <input type="hidden" name="return_q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>">
                <input type="hidden" name="return_page" value="<?= $page ?>">
                <button type="submit" class="btn <?= $isActive ? 'btn--danger' : 'btn--primary' ?>">
                    <?= $isActive ? 'Desactivar' : 'Reactivar' ?>
                </button>
            </form>
        </div>
    </div>

    <div class="modal" id="modal-password-<?= $rowId ?>" hidden>
        <div class="modal__backdrop" data-close-modal></div>
        <div class="modal__content" role="dialog" aria-modal="true" aria-labelledby="modal-password-title-<?= $rowId ?>">
            <h3 id="modal-password-title-<?= $rowId ?>">Cambiar contraseña de usuario #<?= $rowId ?></h3>
            <form method="post" action="/baseball-tms/catalogs/users/crud.php">
                <input type="hidden" name="action" value="change_password">
                <input type="hidden" name="id" value="<?= $rowId ?>">
                <input type="hidden" name="return_q" value="<?= htmlspecialchars($search, ENT_QUOTES, 'UTF-8') ?>">
                <input type="hidden" name="return_page" value="<?= $page ?>">
                <label>Nueva Contraseña
                    <input type="password" name="new_password" required>
                </label>
                <div class="modal__actions">
                    <button type="button" class="btn btn--ghost" data-close-modal>Cerrar</button>
                    <button type="submit" class="btn btn--primary">Guardar contraseña</button>
                </div>
            </form>
        </div>
    </div>
<?php endforeach; ?>

<script src="/baseball-tms/scripts/main.js"></script>
<script src="/baseball-tms/catalogs/users/crud.js"></script>
</body>
</html>
                                                                                                                                                                                                                                                                                                                                                                                                                            