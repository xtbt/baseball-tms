<?php

declare(strict_types=1);

date_default_timezone_set('America/Tijuana');

spl_autoload_register(function (string $class): void {
    $prefix = 'App\\';
    $baseDir = __DIR__ . '/app/';
    if (strncmp($class, $prefix, strlen($prefix)) !== 0) {
        return;
    }
    $relativeClass = substr($class, strlen($prefix));
    $file = $baseDir . str_replace('\\', '/', $relativeClass) . '.php';
    if (is_file($file)) {
        require $file;
    }
});

$config = require __DIR__ . '/config/app.php';

use App\Core\Request;
use App\Core\Response;
use App\Core\Router;
use App\Controllers\AuthController;
use App\Controllers\CategoryController;
use App\Controllers\GameController;
use App\Controllers\ProfileController;
use App\Controllers\StandingController;
use App\Controllers\TeamController;
use App\Controllers\UserController;
use App\Controllers\VenueController;

set_exception_handler(function (Throwable $e) use ($config): void {
    $status = 500;
    $payload = ['message' => 'Internal server error'];
    if (!empty($config['app']['debug'])) {
        $payload['error'] = $e->getMessage();
    }
    Response::json($payload, $status);
});

$request = new Request();
$router = new Router($request, $config);

$router->get('/health', [AuthController::class, 'health']);
$router->post('/auth/login', [AuthController::class, 'login']);
$router->post('/auth/logout', [AuthController::class, 'logout'], true);
$router->get('/auth/me', [AuthController::class, 'me'], true);
$router->resource('/categories', CategoryController::class, true);
$router->get('/teams', [TeamController::class, 'index']);
$router->post('/teams', [TeamController::class, 'store'], true);
$router->get('/teams/{id}', [TeamController::class, 'show'], true);
$router->put('/teams/{id}', [TeamController::class, 'update'], true);
$router->delete('/teams/{id}', [TeamController::class, 'destroy'], true);
$router->get('/venues', [VenueController::class, 'index']);
$router->post('/venues', [VenueController::class, 'store'], true);
$router->get('/venues/{id}', [VenueController::class, 'show'], true);
$router->put('/venues/{id}', [VenueController::class, 'update'], true);
$router->delete('/venues/{id}', [VenueController::class, 'destroy'], true);
$router->get('/games', [GameController::class, 'index']);
$router->post('/games', [GameController::class, 'store'], true);
$router->get('/games/{id}', [GameController::class, 'show'], true);
$router->put('/games/{id}', [GameController::class, 'update'], true);
$router->delete('/games/{id}', [GameController::class, 'destroy'], true);
$router->resource('/users', UserController::class, true);
$router->get('/users/{id}/profile', [ProfileController::class, 'showByUser'], true);
$router->put('/users/{id}/profile', [ProfileController::class, 'upsertByUser'], true);
$router->get('/standings', [StandingController::class, 'index'], true);
$router->dispatch();