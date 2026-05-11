<?php

declare(strict_types=1);

if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start();
}

$scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$host = $_SERVER['HTTP_HOST'] ?? 'localhost';
if (!defined('API_BASE_URL')) {
    define('API_BASE_URL', $scheme . '://' . $host . '/baseball-tms/API/v1');
}

function api_request(string $method, string $path, ?string $token = null, ?array $payload = null): array
{
    $headers = [
        'Accept: application/json',
        'Content-Type: application/json',
    ];
    if ($token !== null && $token !== '') {
        $headers[] = 'Authorization: Bearer ' . $token;
    }

    $options = [
        'http' => [
            'method' => strtoupper($method),
            'ignore_errors' => true,
            'header' => implode("\r\n", $headers),
            'timeout' => 20,
        ],
    ];

    if ($payload !== null) {
        $options['http']['content'] = json_encode($payload, JSON_UNESCAPED_UNICODE);
    }

    $url = API_BASE_URL . $path;
    $context = stream_context_create($options);
    $responseBody = @file_get_contents($url, false, $context);
    $status = 0;

    if (isset($http_response_header[0]) && preg_match('/\s(\d{3})\s/', $http_response_header[0], $matches)) {
        $status = (int) $matches[1];
    }

    $decoded = json_decode($responseBody ?: '', true);

    return [
        'status' => $status,
        'body' => $decoded,
        'ok' => is_array($decoded) && !empty($decoded['success']),
    ];
}

function auth_data(): array
{
    return $_SESSION['auth'] ?? [];
}

function is_logged_in(): bool
{
    $auth = auth_data();
    return !empty($auth['token']) && !empty($auth['user']);
}

function set_auth(array $authPayload): void
{
    $_SESSION['auth'] = [
        'token' => (string) ($authPayload['access_token'] ?? ''),
        'user' => $authPayload['user'] ?? [],
        'expires_at' => (string) ($authPayload['expires_at'] ?? ''),
    ];
}

function clear_auth(): void
{
    unset($_SESSION['auth']);
}

function redirect_to(string $path): void
{
    header('Location: ' . $path);
    exit;
}

function fetch_public_map(string $path, string $labelField): array
{
    $response = api_request('GET', $path);
    $items = $response['body']['data'] ?? [];
    $map = [];
    foreach ($items as $item) {
        $map[(int) $item['id']] = (string) ($item[$labelField] ?? 'N/D');
    }
    return $map;
}
