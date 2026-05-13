<?php

declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';

if (!is_logged_in()) {
    redirect_to('/baseball-tms/index.php');
}

// Main block: Resolve authenticated context and target user.
$auth = auth_data();
$user = $auth['user'];
$token = (string) $auth['token'];
$sessionUserId = (int) ($user['id'] ?? 0);
$requestedUserId = (int) ($_GET['user_id'] ?? $sessionUserId);
$userId = $requestedUserId > 0 ? $requestedUserId : $sessionUserId;
$userRole = (string) ($user['role'] ?? '');
$isAdmin = $userRole === 'admin';
$isManager = $userRole === 'manager';
$canEditProfile = $isAdmin || ($isManager && $userId === $sessionUserId);

$flashError = (string) ($_SESSION['flash_error'] ?? '');
$flashSuccess = (string) ($_SESSION['flash_success'] ?? '');
unset($_SESSION['flash_error'], $_SESSION['flash_success']);

$requiredProfileFields = [
    'first_name' => 'Nombre',
    'paternal_surname' => 'Apellido paterno',
    'birth_date' => 'Fecha de nacimiento',
];
$employeeClassOptions = ['BASE', 'CONFIANZA', 'CONTRATO', 'HIJO', 'INVITADO'];

if ($userRole !== 'player' && $userRole !== 'manager' && $userRole !== 'admin') {
    clear_auth();
    $_SESSION['flash_error'] = 'La sesión no tiene permisos válidos.';
    redirect_to('/baseball-tms/index.php');
}

if ($userRole === 'player' && $requestedUserId !== $sessionUserId) {
    redirect_to('/baseball-tms/user/profile.php');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!$canEditProfile) {
        $_SESSION['flash_error'] = 'No tienes permisos para editar este perfil.';
        redirect_to('/baseball-tms/user/profile.php?user_id=' . $userId);
    }

    $stringOrNull = static function (string $key): ?string {
        $value = trim((string) ($_POST[$key] ?? ''));
        return $value !== '' ? $value : null;
    };

    $firstName = $stringOrNull('first_name');
    $paternalSurname = $stringOrNull('paternal_surname');
    $maternalSurname = $stringOrNull('maternal_surname');
    $birthDate = $stringOrNull('birth_date');
    $curp = $stringOrNull('curp');
    $phone = $stringOrNull('phone');
    $position = $stringOrNull('position');
    $employeeClass = $stringOrNull('employee_class');
    $employeeNumber = $stringOrNull('employee_number');
    $isstecaliAffiliation = $stringOrNull('isstecali_affiliation');

    $teamIdRaw = trim((string) ($_POST['team_id'] ?? ''));
    $teamId = null;
    if ($teamIdRaw !== '') {
        if (ctype_digit($teamIdRaw) && (int) $teamIdRaw > 0) {
            $teamId = (int) $teamIdRaw;
        } else {
            $_SESSION['flash_error'] = 'El equipo seleccionado no es válido.';
            redirect_to('/baseball-tms/user/profile.php?user_id=' . $userId);
        }
    }

    $jerseyRaw = trim((string) ($_POST['jersey_number'] ?? ''));
    $jerseyNumber = null;
    if ($jerseyRaw !== '') {
        if (ctype_digit($jerseyRaw)) {
            $jerseyNumber = (int) $jerseyRaw;
        } else {
            $_SESSION['flash_error'] = 'El número de jersey debe ser numérico.';
            redirect_to('/baseball-tms/user/profile.php?user_id=' . $userId);
        }
    }

    $errors = [];
    foreach ($requiredProfileFields as $fieldKey => $fieldLabel) {
        if (trim((string) ($_POST[$fieldKey] ?? '')) === '') {
            $errors[] = 'El campo ' . $fieldLabel . ' es obligatorio.';
        }
    }

    if ($birthDate !== null) {
        $birthDateValid = date_create_from_format('Y-m-d', $birthDate);
        if (!$birthDateValid || $birthDateValid->format('Y-m-d') !== $birthDate) {
            $errors[] = 'La fecha de nacimiento debe estar en formato válido.';
        }
    }

    if ($curp !== null && !preg_match('/^[A-Z]{4}[0-9]{6}[A-Z]{6}[A-Z0-9]{2}$/i', $curp)) {
        $errors[] = 'La CURP debe tener un formato válido de 18 caracteres.';
    }

    if ($phone !== null && !preg_match('/^[0-9+()\-\s]{7,20}$/', $phone)) {
        $errors[] = 'El teléfono debe contener únicamente números y símbolos válidos.';
    }

    if ($employeeClass !== null && !in_array($employeeClass, $employeeClassOptions, true)) {
        $errors[] = 'La clase de empleado seleccionada no es válida.';
    }

    if ($employeeNumber !== null && !preg_match('/^[A-Za-z0-9\-]{1,30}$/', $employeeNumber)) {
        $errors[] = 'El número de empleado tiene formato inválido.';
    }

    if (!empty($errors)) {
        $_SESSION['flash_error'] = implode(' ', $errors);
        redirect_to('/baseball-tms/user/profile.php?user_id=' . $userId);
    }

    $payload = [
        'team_id' => $teamId,
        'first_name' => $firstName,
        'paternal_surname' => $paternalSurname,
        'maternal_surname' => $maternalSurname,
        'birth_date' => $birthDate,
        'curp' => $curp,
        'phone' => $phone,
        'jersey_number' => $jerseyNumber,
        'position' => $position,
        'employee_class' => $employeeClass,
        'employee_number' => $employeeNumber,
        'isstecali_affiliation' => $isstecaliAffiliation,
    ];

    $saveResponse = api_request('PUT', '/users/' . $userId . '/profile', $token, $payload);
    if (!empty($saveResponse['ok'])) {
        $_SESSION['flash_success'] = 'Perfil guardado correctamente.';
    } else {
        $message = (string) ($saveResponse['body']['message'] ?? 'No se pudo guardar el perfil.');
        $_SESSION['flash_error'] = $message;
    }

    redirect_to('/baseball-tms/user/profile.php?user_id=' . $userId);
}

// Main block: Fetch linked records from users and user_profiles via user_id.
$userInfoResponse = api_request('GET', '/users/' . $userId, $token);
$profileUser = $userInfoResponse['body']['data'] ?? [];

$profileResponse = api_request('GET', '/users/' . $userId . '/profile', $token);
$profile = $profileResponse['body']['data'] ?? [];

$teamsResponse = api_request('GET', '/teams', $token);
$teams = $teamsResponse['body']['data'] ?? [];
$teamsMap = [];
foreach ($teams as $teamItem) {
    $teamItemId = (int) ($teamItem['id'] ?? 0);
    if ($teamItemId > 0) {
        $teamsMap[$teamItemId] = (string) ($teamItem['name'] ?? 'N/D');
    }
}

$teamName = 'Sin equipo';
$profileTeamId = (int) ($profile['team_id'] ?? 0);
if ($profileTeamId > 0 && isset($teamsMap[$profileTeamId])) {
    $teamName = $teamsMap[$profileTeamId];
}

// Main block: Prepare safe display values for read-only fields.
$displayValue = static function ($value): string {
    if ($value === null) {
        return 'N/D';
    }
    $text = trim((string) $value);
    return $text !== '' ? $text : 'N/D';
};

$formValue = static function ($value): string {
    if ($value === null) {
        return '';
    }
    return trim((string) $value);
};

$isActiveText = ((int) ($profileUser['is_active'] ?? 0) === 1) ? 'Activo' : 'Inactivo';
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
        <?php if ($flashSuccess !== ''): ?>
            <div class="flash flash--ok"><?= htmlspecialchars($flashSuccess, ENT_QUOTES, 'UTF-8') ?></div>
        <?php endif; ?>
        <?php if ($flashError !== ''): ?>
            <div class="flash flash--error"><?= htmlspecialchars($flashError, ENT_QUOTES, 'UTF-8') ?></div>
        <?php endif; ?>
        <p class="form-note">Los campos marcados con * son obligatorios.</p>
        <form class="readonly-form" method="post" action="/baseball-tms/user/profile.php?user_id=<?= (int) $userId ?>">
            <fieldset>
                <legend>Datos de usuario</legend>
                <label>ID de usuario
                    <input type="text" readonly value="<?= htmlspecialchars($displayValue($profileUser['id'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Correo
                    <input type="text" readonly value="<?= htmlspecialchars($displayValue($profileUser['email'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Rol
                    <input type="text" readonly value="<?= htmlspecialchars($displayValue($profileUser['role'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Estado
                    <input type="text" readonly value="<?= htmlspecialchars($isActiveText, ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Último acceso
                    <input type="text" readonly value="<?= htmlspecialchars($displayValue($profileUser['last_login_at'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
            </fieldset>
            <fieldset>
                <legend>Datos de perfil</legend>
                <label>Equipo
                    <?php if ($isAdmin): ?>
                        <select name="team_id">
                            <option value="">Sin equipo</option>
                            <?php foreach ($teamsMap as $teamIdOption => $teamLabel): ?>
                                <option value="<?= (int) $teamIdOption ?>" <?= $profileTeamId === (int) $teamIdOption ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($teamLabel, ENT_QUOTES, 'UTF-8') ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    <?php else: ?>
                        <input type="text" readonly value="<?= htmlspecialchars($displayValue($teamName), ENT_QUOTES, 'UTF-8') ?>">
                        <?php if ($canEditProfile): ?>
                            <input type="hidden" name="team_id" value="<?= $profileTeamId > 0 ? (int) $profileTeamId : '' ?>">
                        <?php endif; ?>
                    <?php endif; ?>
                </label>
                <label>Nombre *
                    <input type="text" name="first_name" <?= $canEditProfile ? 'required minlength="2" maxlength="100"' : 'readonly' ?> value="<?= htmlspecialchars($canEditProfile ? $formValue($profile['first_name'] ?? null) : $displayValue($profile['first_name'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Apellido paterno *
                    <input type="text" name="paternal_surname" <?= $canEditProfile ? 'required minlength="2" maxlength="100"' : 'readonly' ?> value="<?= htmlspecialchars($canEditProfile ? $formValue($profile['paternal_surname'] ?? null) : $displayValue($profile['paternal_surname'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Apellido materno
                    <input type="text" name="maternal_surname" <?= $canEditProfile ? 'maxlength="100"' : 'readonly' ?> value="<?= htmlspecialchars($canEditProfile ? $formValue($profile['maternal_surname'] ?? null) : $displayValue($profile['maternal_surname'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Fecha de nacimiento *
                    <input type="date" name="birth_date" <?= $canEditProfile ? 'required max="' . date('Y-m-d') . '"' : 'readonly' ?> value="<?= htmlspecialchars($formValue($profile['birth_date'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>CURP
                    <input type="text" name="curp" <?= $canEditProfile ? 'maxlength="18" pattern="[A-Za-z]{4}[0-9]{6}[A-Za-z]{6}[A-Za-z0-9]{2}"' : 'readonly' ?> value="<?= htmlspecialchars($canEditProfile ? $formValue($profile['curp'] ?? null) : $displayValue($profile['curp'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Teléfono
                    <input type="tel" name="phone" <?= $canEditProfile ? 'maxlength="20" pattern="[0-9+()\-\s]{7,20}"' : 'readonly' ?> value="<?= htmlspecialchars($canEditProfile ? $formValue($profile['phone'] ?? null) : $displayValue($profile['phone'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Número de jersey
                    <input type="number" name="jersey_number" <?= $canEditProfile ? 'min="0" max="999" step="1"' : 'readonly' ?> value="<?= htmlspecialchars($formValue($profile['jersey_number'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Posición
                    <input type="text" name="position" <?= $canEditProfile ? 'maxlength="50"' : 'readonly' ?> value="<?= htmlspecialchars($canEditProfile ? $formValue($profile['position'] ?? null) : $displayValue($profile['position'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Clase de empleado
                    <?php if ($canEditProfile): ?>
                        <select name="employee_class">
                            <option value="" <?= $formValue($profile['employee_class'] ?? null) === '' ? 'selected' : '' ?>>No especificado</option>
                            <?php foreach ($employeeClassOptions as $employeeClassOption): ?>
                                <option value="<?= htmlspecialchars($employeeClassOption, ENT_QUOTES, 'UTF-8') ?>" <?= $formValue($profile['employee_class'] ?? null) === $employeeClassOption ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($employeeClassOption, ENT_QUOTES, 'UTF-8') ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    <?php else: ?>
                        <input type="text" readonly value="<?= htmlspecialchars($displayValue($profile['employee_class'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                    <?php endif; ?>
                </label>
                <label>Número de empleado
                    <input type="text" name="employee_number" <?= $canEditProfile ? 'maxlength="30" pattern="[A-Za-z0-9\-]{1,30}"' : 'readonly' ?> value="<?= htmlspecialchars($canEditProfile ? $formValue($profile['employee_number'] ?? null) : $displayValue($profile['employee_number'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
                <label>Afiliación ISSSTECALI
                    <input type="text" name="isstecali_affiliation" <?= $canEditProfile ? 'maxlength="100"' : 'readonly' ?> value="<?= htmlspecialchars($canEditProfile ? $formValue($profile['isstecali_affiliation'] ?? null) : $displayValue($profile['isstecali_affiliation'] ?? null), ENT_QUOTES, 'UTF-8') ?>">
                </label>
            </fieldset>
            <?php if ($canEditProfile): ?>
                <div>
                    <button type="submit" class="btn btn--primary">Guardar perfil</button>
                </div>
            <?php endif; ?>
        </form>
    </section>
</main>
<script src="/baseball-tms/user/profile.js"></script>
</body>
</html>