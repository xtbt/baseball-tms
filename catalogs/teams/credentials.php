<?php
declare(strict_types=1);
require_once __DIR__ . '/../../includes/bootstrap.php';

if (!is_logged_in()) {
    redirect_to('/baseball-tms/index.php');
}

$auth = auth_data();
$user = $auth['user'];
$token = (string) ($auth['token'] ?? '');

if ((string) ($user['role'] ?? '') !== 'admin') {
    $_SESSION['flash_error'] = 'Solo usuarios admin pueden acceder a catálogos.';
    redirect_to('/baseball-tms/index.php');
}

$teamId = (int) ($_GET['id'] ?? 0);
if ($teamId <= 0) {
    http_response_code(400);
    echo 'Equipo inválido';
    exit;
}

$teamResponse = api_request('GET', '/teams/' . $teamId, $token);
$team = $teamResponse['body']['data'] ?? [];
if (empty($teamResponse['ok']) || !is_array($team)) {
    http_response_code(404);
    echo 'Equipo no encontrado';
    exit;
}

$teamName = (string) ($team['name'] ?? 'Sin equipo');
$categoryName = 'Sin categoría';
$categoryId = (int) ($team['category_id'] ?? 0);
if ($categoryId > 0) {
    $categoryResponse = api_request('GET', '/categories/' . $categoryId, $token);
    $category = $categoryResponse['body']['data'] ?? [];
    if (is_array($category)) {
        $categoryName = (string) ($category['name'] ?? 'Sin categoría');
    }
}

$photoByUser = static function (int $id): string {
    $rel = '/baseball-tms/images/users/' . $id . '.jpg';
    $abs = __DIR__ . '/../../images/users/' . $id . '.jpg';
    $defRel = '/baseball-tms/images/users/no_image.jpg';
    $defAbs = __DIR__ . '/../../images/users/no_image.jpg';
    if (!is_file($defAbs)) {
        $defRel = '/baseball-tms/images/no_image.jpg';
        $defAbs = __DIR__ . '/../../images/no_image.jpg';
    }
    if (is_file($abs)) {
        return $rel;
    }
    return is_file($defAbs) ? $defRel : '/baseball-tms/images/no_image.jpg';
};

$players = [];
$offset = 0;
$limit = 200;

for ($i = 0; $i < 50; $i++) {
    $usersResponse = api_request('GET', '/users?limit=' . $limit . '&offset=' . $offset, $token);
    $chunk = $usersResponse['body']['data'] ?? [];
    if (!is_array($chunk) || empty($chunk)) {
        break;
    }
    foreach ($chunk as $u) {
        if (!is_array($u) || (string) ($u['role'] ?? '') !== 'player') {
            continue;
        }
        $id = (int) ($u['id'] ?? 0);
        if ($id <= 0) {
            continue;
        }
        $profileResponse = api_request('GET', '/users/' . $id . '/profile', $token);
        $profile = $profileResponse['body']['data'] ?? [];
        if (!is_array($profile) || (int) ($profile['team_id'] ?? 0) !== $teamId) {
            continue;
        }
        $firstName = trim((string) ($profile['first_name'] ?? ''));
        $paternalSurname = trim((string) ($profile['paternal_surname'] ?? ''));
        $maternalSurname = trim((string) ($profile['maternal_surname'] ?? ''));
        $fullName = trim($firstName . ' ' . $paternalSurname . ' ' . $maternalSurname);
        $employeeClass = trim((string) ($profile['employee_class'] ?? ''));
        $players[] = [
            'id' => $id,
            'full_name' => $fullName !== '' ? $fullName : 'N/D',
            'employee_class' => $employeeClass !== '' ? $employeeClass : 'N/D',
            'photo_url' => $photoByUser($id),
        ];
    }
    if (count($chunk) < $limit) {
        break;
    }
    $offset += $limit;
}

usort($players, static function (array $a, array $b): int {
    return $a['id'] <=> $b['id'];
});
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Credenciales de equipo #<?= $teamId ?></title>
    <link rel="stylesheet" href="/baseball-tms/catalogs/teams/credentials.css">
</head>
<body>
<div class="toolbar">
    <button type="button" id="close-credentials">Volver</button>
    <button type="button" id="print-credentials">Imprimir</button>
</div>
<div class="sheet">
    <section class="grid">
        <?php foreach ($players as $player): ?>
            <section class="credential credential-front">
                <img src="<?= htmlspecialchars((string) $player['photo_url'], ENT_QUOTES, 'UTF-8') ?>" alt="Foto del jugador" class="front-photo">
                <div class="team-name"><?= htmlspecialchars($teamName, ENT_QUOTES, 'UTF-8') ?></div>
                <div class="category-name"><?= htmlspecialchars($categoryName, ENT_QUOTES, 'UTF-8') ?></div>
                <div class="full-name"><?= htmlspecialchars((string) $player['full_name'], ENT_QUOTES, 'UTF-8') ?></div>
                <div class="employee-class"><?= htmlspecialchars((string) $player['employee_class'], ENT_QUOTES, 'UTF-8') ?></div>
                <div class="folio-number"><?= htmlspecialchars((string) $player['id'], ENT_QUOTES, 'UTF-8') ?></div>
            </section>
        <?php endforeach; ?>
    </section>
</div>
<script>
    document.getElementById('close-credentials').addEventListener('click', function () {
        window.close();
    });
    document.getElementById('print-credentials').addEventListener('click', function () {
        window.print();
    });
</script>
</body>
</html>