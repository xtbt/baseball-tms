<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\BaseController;
use App\Core\Request;
use App\Services\AuthService;

final class AuthController extends BaseController
{
    private $config;
    private $request;
    private $service;

    public function __construct(array $config, Request $request)
    {
        $this->config = $config;
        $this->request = $request;
        $this->service = new AuthService($config);
    }

    public function health(): void
    {
        $this->ok(['status' => 'ok', 'service' => 'API v1']);
    }

    public function login(): void
    {
        $payload = $this->request->input();
        $email = (string) ($payload['email'] ?? '');
        $password = (string) ($payload['password'] ?? '');
        if ($email === '' || $password === '') {
            $this->fail('Email and password are required', 422);
        }
        try {
            $result = $this->service->login(
                $email,
                $password,
                isset($payload['device_name']) ? (string) $payload['device_name'] : null,
                isset($payload['device_type']) ? (string) $payload['device_type'] : 'web',
                $_SERVER['REMOTE_ADDR'] ?? null
            );
            $this->ok($result);
        } catch (\Throwable $e) {
            if (!empty($this->config['app']['debug'])) {
                $this->fail($e->getMessage(), 401);
            }
            $this->fail('Invalid credentials', 401);
        }
    }

    public function logout(): void
    {
        $token = (string) $this->request->attribute('auth_token', '');
        if ($token !== '') {
            $this->service->logout($token);
        }
        $this->ok(['message' => 'Session closed']);
    }

    public function me(): void
    {
        $this->ok($this->request->attribute('auth_user', []));
    }
}