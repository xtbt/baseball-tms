<?php

declare(strict_types=1);

namespace App\Core;

use App\Middleware\AuthMiddleware;

final class Router
{
    private $request;
    private $config;
    private $routes = [];

    public function __construct(Request $request, array $config)
    {
        $this->request = $request;
        $this->config = $config;
    }

    public function get(string $path, array $handler, bool $auth = false): void { $this->add('GET', $path, $handler, $auth); }
    public function post(string $path, array $handler, bool $auth = false): void { $this->add('POST', $path, $handler, $auth); }
    public function put(string $path, array $handler, bool $auth = false): void { $this->add('PUT', $path, $handler, $auth); }
    public function delete(string $path, array $handler, bool $auth = false): void { $this->add('DELETE', $path, $handler, $auth); }

    public function resource(string $prefix, string $controllerClass, bool $auth = false): void
    {
        $this->get($prefix, [$controllerClass, 'index'], $auth);
        $this->get($prefix . '/{id}', [$controllerClass, 'show'], $auth);
        $this->post($prefix, [$controllerClass, 'store'], $auth);
        $this->put($prefix . '/{id}', [$controllerClass, 'update'], $auth);
        $this->delete($prefix . '/{id}', [$controllerClass, 'destroy'], $auth);
    }

    public function dispatch(): void
    {
        $method = $this->request->method();
        $path = rtrim($this->request->path(), '/') ?: '/';
        foreach ($this->routes as $route) {
            if ($route['method'] !== $method) {
                continue;
            }
            $matches = [];
            if (!preg_match($route['regex'], $path, $matches)) {
                continue;
            }
            foreach ($matches as $k => $v) {
                if (!is_int($k)) {
                    $this->request->setAttribute($k, $v);
                }
            }
            if ($route['auth']) {
                (new AuthMiddleware($this->config))->handle($this->request);
            }
            $class = $route['handler'][0];
            $action = $route['handler'][1];
            $controller = new $class($this->config, $this->request);
            $controller->$action();
            return;
        }
        Response::json(['success' => false, 'message' => 'Route not found'], 404);
    }

    private function add(string $method, string $path, array $handler, bool $auth): void
    {
        $path = rtrim($path, '/') ?: '/';
        $regex = preg_replace('/\{([a-zA-Z_][a-zA-Z0-9_]*)\}/', '(?P<$1>[^/]+)', $path);
        $this->routes[] = [
            'method' => $method,
            'path' => $path,
            'regex' => '#^' . $regex . '$#',
            'handler' => $handler,
            'auth' => $auth,
        ];
    }
}