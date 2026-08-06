<?php

declare(strict_types=1);

require_once __DIR__ . '/../../includes/bootstrap.php';
require_once __DIR__ . '/../../vendor/autoload.php';

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Worksheet\Drawing;
use PhpOffice\PhpSpreadsheet\Worksheet\PageSetup;

if (!is_logged_in()) {
    redirect_to('/baseball-tms/index.php');
}

$auth = auth_data();
$user = $auth['user'];
$token = (string) ($auth['token'] ?? '');

if ((string) ($user['role'] ?? '') !== 'admin') {
    http_response_code(403);
    echo 'Acceso no autorizado.';
    exit;
}

$teamId = (int) ($_GET['id'] ?? 0);
if ($teamId <= 0) {
    http_response_code(400);
    echo 'Equipo inválido.';
    exit;
}

// --- Obtener equipo ---
$teamResponse = api_request('GET', '/teams/' . $teamId, $token);
$team = $teamResponse['body']['data'] ?? [];
if (empty($teamResponse['ok']) || !is_array($team)) {
    http_response_code(404);
    echo 'Equipo no encontrado.';
    exit;
}
$teamName = (string) ($team['name'] ?? 'Sin equipo');

// --- Obtener categoría ---
$categoryName = 'Sin categoría';
$categoryId = (int) ($team['category_id'] ?? 0);
if ($categoryId > 0) {
    $categoryResponse = api_request('GET', '/categories/' . $categoryId, $token);
    $category = $categoryResponse['body']['data'] ?? [];
    if (is_array($category)) {
        $categoryName = (string) ($category['name'] ?? 'Sin categoría');
    }
}

// --- Obtener manager (representante del equipo) ---
$managerName = '';
$managerPhone = '';
$managerResponse = api_request('GET', '/users?include_profile=1&limit=10&offset=0&role=manager&team_id=' . $teamId, $token);
$managerBody = $managerResponse['body']['data'] ?? [];
$managerItems = $managerBody['items'] ?? [];
if (is_array($managerItems) && !empty($managerItems)) {
    $mgr = $managerItems[0];
    $mgrProfile = $mgr['profile'] ?? [];
    if (is_array($mgrProfile)) {
        $mgrFirst  = trim((string) ($mgrProfile['first_name'] ?? ''));
        $mgrPat    = trim((string) ($mgrProfile['paternal_surname'] ?? ''));
        $mgrMat    = trim((string) ($mgrProfile['maternal_surname'] ?? ''));
        $managerName  = trim($mgrFirst . ' ' . $mgrPat . ' ' . $mgrMat);
        $managerPhone = trim((string) ($mgrProfile['phone'] ?? ''));
    }
}

// --- Obtener jugadores del equipo ---
$players = [];
$offset  = 0;
$limit   = 200;

for ($i = 0; $i < 50; $i++) {
    $usersResponse = api_request('GET', '/users?include_profile=1&limit=' . $limit . '&offset=' . $offset . '&role=player&team_id=' . $teamId, $token);
    $responseBody  = $usersResponse['body']['data'] ?? [];
    $chunk         = $responseBody['items'] ?? [];
    if (!is_array($chunk) || empty($chunk)) {
        break;
    }
    foreach ($chunk as $u) {
        if (!is_array($u)) {
            continue;
        }
        $profile = $u['profile'] ?? [];
        if (!is_array($profile)) {
            continue;
        }
        $firstName  = trim((string) ($profile['first_name'] ?? ''));
        $patSurname = trim((string) ($profile['paternal_surname'] ?? ''));
        $matSurname = trim((string) ($profile['maternal_surname'] ?? ''));
        $fullName   = trim($firstName . ' ' . $patSurname . ' ' . $matSurname);
        $jerseyNum  = $profile['jersey_number'] ?? null;
        $players[] = [
            'full_name'     => $fullName !== '' ? $fullName : 'N/D',
            'jersey_number' => $jerseyNum !== null ? (string) $jerseyNum : '',
            'shirt_size'    => (string) ($profile['shirt_size'] ?? ''),
            'hat_size'      => (string) ($profile['hat_size'] ?? ''),
            'pants_size'    => (string) ($profile['pants_size'] ?? ''),
        ];
    }
    $meta = $responseBody['meta'] ?? [];
    if ((int) ($meta['total'] ?? 0) <= $offset + $limit) {
        break;
    }
    $offset += $limit;
}

// Ordenar por número de jersey
usort($players, static function (array $a, array $b): int {
    $aNum = $a['jersey_number'] !== '' ? (int) $a['jersey_number'] : PHP_INT_MAX;
    $bNum = $b['jersey_number'] !== '' ? (int) $b['jersey_number'] : PHP_INT_MAX;
    return $aNum <=> $bNum;
});

// --- Construir el libro de Excel ---
$spreadsheet = new Spreadsheet();
$sheet = $spreadsheet->getActiveSheet();
$sheet->setTitle('Lista de Jugadores');

// Configuración de página
$sheet->getPageSetup()->setPaperSize(PageSetup::PAPERSIZE_LETTER);
$sheet->getPageSetup()->setOrientation(PageSetup::ORIENTATION_PORTRAIT);
$sheet->getPageSetup()->setFitToPage(true);
$sheet->getPageSetup()->setFitToWidth(1);
$sheet->getPageSetup()->setFitToHeight(0);
$sheet->getPageMargins()->setTop(0.4);
$sheet->getPageMargins()->setBottom(0.4);
$sheet->getPageMargins()->setLeft(0.5);
$sheet->getPageMargins()->setRight(0.5);

// Anchos de columna
$sheet->getColumnDimension('A')->setWidth(6);
$sheet->getColumnDimension('B')->setWidth(44);
$sheet->getColumnDimension('C')->setWidth(10);
$sheet->getColumnDimension('D')->setWidth(10);
$sheet->getColumnDimension('E')->setWidth(10);
$sheet->getColumnDimension('F')->setWidth(12);

// -------------------------------------------------------------------------
// ÁREA DE ENCABEZADO (filas 1-4): logos + título
// -------------------------------------------------------------------------
for ($r = 1; $r <= 4; $r++) {
    $sheet->getRowDimension($r)->setRowHeight(22);
}

// Título central separado en 3 renglones (B2:E2, B3:E3, B4:E4)
$sheet->mergeCells('B2:E2');
$sheet->setCellValue('B2', 'LISTA DE UNIFORMES');
$sheet->getStyle('B2:E2')->applyFromArray([
    'font' => ['bold' => true, 'size' => 12, 'name' => 'Arial'],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
]);

$sheet->mergeCells('B3:E3');
$sheet->setCellValue('B3', 'TORNEO DE BÉISBOL BURÓCRATA 2026');
$sheet->getStyle('B3:E3')->applyFromArray([
    'font' => ['bold' => true, 'size' => 12, 'name' => 'Arial'],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
]);

$sheet->mergeCells('B4:E4');
$sheet->setCellValue('B4', 'COMITÉ EJECUTIVO SECCIONAL 2026 - 2029');
$sheet->getStyle('B4:E4')->applyFromArray([
    'font' => ['bold' => true, 'size' => 10, 'name' => 'Arial'],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
]);

// Fila 5: "SECCIÓN TIJUANA" bajo el logo derecho
$sheet->getRowDimension(5)->setRowHeight(14);
$sheet->setCellValue('F5', 'SECCIÓN TIJUANA');
$sheet->getStyle('F5')->applyFromArray([
    'font' => [
        'bold' => true,
        'size' => 9,
        'name' => 'Arial',
    ],
    'alignment' => [
        'horizontal' => Alignment::HORIZONTAL_CENTER,
        'vertical'   => Alignment::VERTICAL_CENTER,
    ],
]);

// Fila 6: separador
$sheet->getRowDimension(6)->setRowHeight(6);

// -------------------------------------------------------------------------
// DATOS DEL EQUIPO (filas 7-9)
// -------------------------------------------------------------------------

// Fila 7: Nombre del equipo
$sheet->getRowDimension(7)->setRowHeight(18);
$sheet->mergeCells('A7:F7');
$sheet->setCellValue('A7', 'NOMBRE DEL EQUIPO: ' . $teamName);
$sheet->getStyle('A7')->applyFromArray([
    'font' => ['bold' => true, 'size' => 10, 'name' => 'Arial'],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_LEFT, 'vertical' => Alignment::VERTICAL_CENTER],
]);

// Fila 8: Representante + Celular
$sheet->getRowDimension(8)->setRowHeight(18);
$sheet->mergeCells('A8:C8');
$sheet->setCellValue('A8', 'REPRESENTANTE DEL EQUIPO: ' . $managerName);
$sheet->getStyle('A8')->applyFromArray([
    'font' => ['bold' => true, 'size' => 10, 'name' => 'Arial'],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_LEFT, 'vertical' => Alignment::VERTICAL_CENTER],
]);
$sheet->mergeCells('D8:F8');
$sheet->setCellValue('D8', 'CELULAR: ' . $managerPhone);
$sheet->getStyle('D8')->applyFromArray([
    'font' => ['bold' => true, 'size' => 10, 'name' => 'Arial'],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_LEFT, 'vertical' => Alignment::VERTICAL_CENTER],
]);

// Fila 9: Categoría
$sheet->getRowDimension(9)->setRowHeight(18);
$sheet->mergeCells('A9:F9');
$sheet->setCellValue('A9', 'CATEGORIA: ' . $categoryName);
$sheet->getStyle('A9')->applyFromArray([
    'font' => ['bold' => true, 'size' => 10, 'name' => 'Arial'],
    'alignment' => ['horizontal' => Alignment::HORIZONTAL_LEFT, 'vertical' => Alignment::VERTICAL_CENTER],
]);

// Fila 10: separador
$sheet->getRowDimension(10)->setRowHeight(8);

// -------------------------------------------------------------------------
// ENCABEZADOS DE LA TABLA (fila 11)
// -------------------------------------------------------------------------
$sheet->getRowDimension(11)->setRowHeight(20);
$tableHeaders = [
    'A11' => 'No',
    'B11' => 'NOMBRE DEL JUGADOR',
    'C11' => 'NUMERO',
    'D11' => 'CAMISA',
    'E11' => 'GORRA',
    'F11' => 'PANTALON',
];
foreach ($tableHeaders as $cell => $label) {
    $sheet->setCellValue($cell, $label);
}
$sheet->getStyle('A11:F11')->applyFromArray([
    'font' => [
        'bold' => true,
        'size' => 10,
        'name' => 'Arial',
    ],
    'alignment' => [
        'horizontal' => Alignment::HORIZONTAL_CENTER,
        'vertical'   => Alignment::VERTICAL_CENTER,
    ],
    'borders' => [
        'allBorders' => [
            'borderStyle' => Border::BORDER_THIN,
            'color'       => ['argb' => 'FF000000'],
        ],
    ],
]);

// -------------------------------------------------------------------------
// FILAS DE JUGADORES (desde fila 12)
// -------------------------------------------------------------------------
$startRow = 12;

foreach ($players as $idx => $player) {
    $row = $startRow + $idx;
    $sheet->getRowDimension($row)->setRowHeight(28);

    $sheet->setCellValue('A' . $row, $idx + 1);
    $sheet->setCellValue('B' . $row, $player['full_name']);
    $sheet->setCellValue('C' . $row, $player['jersey_number']);
    $sheet->setCellValue('D' . $row, $player['shirt_size']);
    $sheet->setCellValue('E' . $row, $player['hat_size']);
    $sheet->setCellValue('F' . $row, $player['pants_size']);

    $sheet->getStyle('A' . $row . ':F' . $row)->applyFromArray([
        'font' => ['size' => 10, 'name' => 'Arial'],
        'alignment' => [
            'horizontal' => Alignment::HORIZONTAL_CENTER,
            'vertical'   => Alignment::VERTICAL_BOTTOM,
        ],
        'borders' => [
            'allBorders' => [
                'borderStyle' => Border::BORDER_THIN,
                'color'       => ['argb' => 'FF000000'],
            ],
        ],
    ]);
    $sheet->getStyle('A' . $row)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);
    $sheet->getStyle('B' . $row)->getAlignment()->setHorizontal(Alignment::HORIZONTAL_LEFT);
}

// Si no hay jugadores, mostrar al menos 18 filas vacías
if (empty($players)) {
    for ($idx = 0; $idx < 18; $idx++) {
        $row = $startRow + $idx;
        $sheet->getRowDimension($row)->setRowHeight(28);
        $sheet->setCellValue('A' . $row, $idx + 1);
        $sheet->getStyle('A' . $row . ':F' . $row)->applyFromArray([
            'font' => ['size' => 10, 'name' => 'Arial'],
            'alignment' => [
                'horizontal' => Alignment::HORIZONTAL_LEFT,
                'vertical'   => Alignment::VERTICAL_BOTTOM,
            ],
            'borders' => [
                'allBorders' => [
                    'borderStyle' => Border::BORDER_THIN,
                    'color'       => ['argb' => 'FF000000'],
                ],
            ],
        ]);
    }
}

// -------------------------------------------------------------------------
// LOGOS (como objetos Drawing flotantes)
// -------------------------------------------------------------------------
$logoLeftPath  = __DIR__ . '/../../assets/logo/sindicato.jpg';
$logoRightPath = __DIR__ . '/../../assets/logo/sutspemidbc.jpg';

if (is_file($logoLeftPath)) {
    $drawingLeft = new Drawing();
    $drawingLeft->setName('Logo Liga Béisbol');
    $drawingLeft->setDescription('Liga de Béisbol Burócrata');
    $drawingLeft->setPath($logoLeftPath);
    $drawingLeft->setHeight(85);
    $drawingLeft->setCoordinates('A1');
    $drawingLeft->setOffsetX(4);
    $drawingLeft->setOffsetY(2);
    $drawingLeft->setWorksheet($sheet);
}

if (is_file($logoRightPath)) {
    $drawingRight = new Drawing();
    $drawingRight->setName('Logo Sindicato');
    $drawingRight->setDescription('SUTSPEMIDBC Sección Tijuana');
    $drawingRight->setPath($logoRightPath);
    $drawingRight->setHeight(85);
    $drawingRight->setCoordinates('F1');
    $drawingRight->setOffsetX(10);
    $drawingRight->setOffsetY(2);
    $drawingRight->setWorksheet($sheet);
}

// -------------------------------------------------------------------------
// ENVIAR ARCHIVO AL NAVEGADOR
// -------------------------------------------------------------------------
$safeTeamName = (string) preg_replace('/[^a-zA-Z0-9_\-]/u', '_', $teamName);
$filename = 'lista_jugadores_' . $safeTeamName . '.xlsx';

header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
header('Content-Disposition: attachment; filename="' . $filename . '"');
header('Cache-Control: max-age=0');
header('Pragma: public');

$writer = new Xlsx($spreadsheet);
$writer->save('php://output');
exit;
