<?php

declare(strict_types=1);

require_once __DIR__ . '/../../includes/bootstrap.php';

if (!is_logged_in()) {
    redirect_to('/baseball-tms/index.php');
}

$auth = auth_data();
$user = $auth['user'];
$token = (string) ($auth['token'] ?? '');
$userRole = (string) ($user['role'] ?? '');

if ($userRole !== 'admin') {
    $_SESSION['flash_error'] = 'Solo usuarios admin pueden acceder a catálogos.';
    redirect_to('/baseball-tms/index.php');
}

$id = (int) ($_GET['id'] ?? 0);
if ($id <= 0) {
    http_response_code(400);
    echo 'Usuario inválido';
    exit;
}

$userResponse = api_request('GET', '/users/' . $id, $token);
$userData = $userResponse['body']['data'] ?? [];
if (empty($userResponse['ok']) || !is_array($userData)) {
    http_response_code(404);
    echo 'Usuario no encontrado';
    exit;
}

$profileResponse = api_request('GET', '/users/' . $id . '/profile', $token);
$profile = $profileResponse['body']['data'] ?? [];
if (!is_array($profile)) {
    $profile = [];
}

$teamName = 'Sin equipo';
$categoryName = 'Sin categoría';
$teamId = (int) ($profile['team_id'] ?? 0);
if ($teamId > 0) {
    $teamResponse = api_request('GET', '/teams/' . $teamId, $token);
    $team = $teamResponse['body']['data'] ?? [];
    if (is_array($team)) {
        $teamName = (string) ($team['name'] ?? 'Sin equipo');
        $categoryId = (int) ($team['category_id'] ?? 0);
        if ($categoryId > 0) {
            $categoryResponse = api_request('GET', '/categories/' . $categoryId, $token);
            $category = $categoryResponse['body']['data'] ?? [];
            if (is_array($category)) {
                $categoryName = (string) ($category['name'] ?? 'Sin categoría');
            }
        }
    }
}

$firstName = trim((string) ($profile['first_name'] ?? ''));
$paternalSurname = trim((string) ($profile['paternal_surname'] ?? ''));
$maternalSurname = trim((string) ($profile['maternal_surname'] ?? ''));
$fullName = trim($firstName . ' ' . $paternalSurname . ' ' . $maternalSurname);
if ($fullName === '') {
    $fullName = 'N/D';
}
$employeeClass = trim((string) ($profile['employee_class'] ?? ''));
if ($employeeClass === '') {
    $employeeClass = 'N/D';
}

$photoAbsolutePath = __DIR__ . '/../../images/users/' . $id . '.jpg';
$photoRelativePath = '/baseball-tms/images/users/' . $id . '.jpg';
$defaultPhotoRelativePath = '/baseball-tms/images/users/no_image.jpg';
$defaultPhotoAbsolutePath = __DIR__ . '/../../images/users/no_image.jpg';
if (!is_file($defaultPhotoAbsolutePath)) {
    $defaultPhotoRelativePath = '/baseball-tms/images/no_image.jpg';
    $defaultPhotoAbsolutePath = __DIR__ . '/../../images/no_image.jpg';
}
$photoUrl = $defaultPhotoRelativePath;
if (is_file($photoAbsolutePath)) {
    $photoUrl = $photoRelativePath;
} elseif (is_file($defaultPhotoAbsolutePath)) {
    $photoUrl = $defaultPhotoRelativePath;
}

$logoUrl = '/baseball-tms/assets/logo/sindicato.jpg';
$sindicatoUrl = '/baseball-tms/assets/logo/sutspemidbc.jpg';
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Credencial de jugador #<?= $id ?></title>
    <link rel="stylesheet" href="/baseball-tms/catalogs/users/credential.css">
</head>
<body>
<div class="toolbar">
    <button type="button" id="close-credential">Volver</button>
    <button type="button" id="print-credential">Imprimir</button>
</div>
<div class="page">
    <div class="card-wrapper">
        <section class="credential credential-front">
            <img src="<?= htmlspecialchars($photoUrl, ENT_QUOTES, 'UTF-8') ?>" alt="Foto del jugador" class="front-photo">
            <img src="<?= htmlspecialchars($logoUrl, ENT_QUOTES, 'UTF-8') ?>" alt="Logo del sindicato" class="front-logo">
            <div class="front-fields">
                <div class="field"><span class="field-label">EQUIPO</span><span class="field-value"><?= htmlspecialchars($teamName, ENT_QUOTES, 'UTF-8') ?></span></div>
                <div class="field"><span class="field-label">CATEGORÍA</span><span class="field-value"><?= htmlspecialchars($categoryName, ENT_QUOTES, 'UTF-8') ?></span></div>
                <div class="field"><span class="field-label">NOMBRE COMPLETO</span><span class="field-value"><?= htmlspecialchars($fullName, ENT_QUOTES, 'UTF-8') ?></span></div>
                <div class="field"><span class="field-label">CLASE DE EMPLEADO</span><span class="field-value"><?= htmlspecialchars($employeeClass, ENT_QUOTES, 'UTF-8') ?></span></div>
            </div>
        </section>
    </div>

    <div class="card-wrapper">
        <section class="credential credential-back">
            <img src="<?= htmlspecialchars($sindicatoUrl, ENT_QUOTES, 'UTF-8') ?>" alt="Logo del torneo" class="back-logo">
        </section>
    </div>
</div>
<script>
    document.getElementById('close-credential').addEventListener('click', function () {
        window.close();
    });
    document.getElementById('print-credential').addEventListener('click', function () {
        window.print();
    });
</script>
</body>
</html>
