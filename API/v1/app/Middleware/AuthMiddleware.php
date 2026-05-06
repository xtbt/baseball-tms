<?php

declare(strict_types=1);

namespace App\Middleware;

use App\Core\Jwt;
use App\Core\Request;
use App\Core\Response;
use App\Models\UserModel;
use App\Models\UserTokenModel;
use RuntimeException;

final class AuthMiddleware
{
    private $config;

    public function __construct(array $config)
    {
        $this->config = $config;
    }

    public function handle(Request $request): void
    {
        $header = $request->header('Authorization') ?: '';
        if (strpos($header, 'Bearer ') !== 0) {
            Response::json(['success' => false, 'message' => 'Unauthorized'], 401);
        }
        $token = trim(substr($header, 7));
        try {
            $payload = Jwt::decode($token, (string) $this->config['jwt']['secret']);
            $tokenModel = new UserTokenModel($this->config);
            $stored = $tokenModel->findActive($token);
            if (!$stored) {
                throw new RuntimeException('Session expired or revoked');
            }
            $userModel = new UserModel($this->config);
            $user = $userModel->find((int) $payload['sub']);
            if (!$user || !(bool) $user['is_active']) {
                throw new RuntimeException('User not available');
            }
            unset($user['password_hash']);
            $tokenModel->touch($token);
            $request->setAttribute('auth_user', $user);
            $request->setAttribute('auth_token', $token);
        } catch (\Throwable $e) {
            Response::json(['success' => false, 'message' => 'Unauthorized'], 401);
        }
    }
}