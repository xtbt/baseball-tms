<?php

declare(strict_types=1);

namespace App\Core;

final class Request
{
    private $attributes = [];

    public function method(): string
    {
        return strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
    }

    public function path(): string
    {
        $uri = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
        $base = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '/')), '/');
        if ($base !== '' && $base !== '/' && strpos($uri, $base) === 0) {
            $uri = substr($uri, strlen($base));
        }
        return $uri === '' ? '/' : $uri;
    }

    public function input(): array
    {
        $raw = file_get_contents('php://input') ?: '';
        if ($raw === '') {
            return [];
        }
        $json = json_decode($raw, true);
        return is_array($json) ? $json : [];
    }

    public function header(string $key): ?string
    {
        $headers = function_exists('getallheaders') ? getallheaders() : [];
        foreach ($headers as $name => $value) {
            if (strcasecmp($name, $key) === 0) {
                return is_array($value) ? null : $value;
            }
        }
        return null;
    }

    public function query(string $key, $default = null)
    {
        return $_GET[$key] ?? $default;
    }

    public function setAttribute(string $key, $value): void
    {
        $this->attributes[$key] = $value;
    }

    public function attribute(string $key, $default = null)
    {
        return $this->attributes[$key] ?? $default;
    }
}