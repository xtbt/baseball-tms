<?php

declare(strict_types=1);

namespace App\Services;

use App\Core\Jwt;
use App\Models\UserModel;
use App\Models\UserTokenModel;
use RuntimeException;

final class AuthService
{
    private $config;
    private $users;
    private $tokens;

    public function __construct(array $config)
    {
        $this->config = $config;
        $this->users = new UserModel($config);
        $this->tokens = new UserTokenModel($config);
    }

    public function login(string $email, string $password, ?string $deviceName, string $deviceType, ?string $ipAddress): array
    {
        $user = $this->users->findByEmail($email);
        if (!$user || !(bool) $user['is_active']) {
            throw new RuntimeException('Invalid credentials');
        }
        if (!password_verify($password, $user['password_hash'])) {
            throw new RuntimeException('Invalid credentials');
        }
        $ttl = (int) $this->config['jwt']['ttl_minutes'];
        $exp = time() + ($ttl * 60);
        $payload = [
            'sub' => (int) $user['id'],
            'email' => $user['email'],
            'role' => $user['role'],
            'iss' => $this->config['jwt']['issuer'],
            'aud' => $this->config['jwt']['audience'],
            'iat' => time(),
            'exp' => $exp,
        ];
        $token = Jwt::encode($payload, (string) $this->config['jwt']['secret']);
        $this->tokens->create([
            'user_id' => (int) $user['id'],
            'token' => $token,
            'device_name' => $deviceName,
            'device_type' => $deviceType,
            'ip_address' => $ipAddress,
            'expires_at' => date('Y-m-d H:i:s', $exp),
        ]);
        $this->users->markLastLogin((int) $user['id']);
        unset($user['password_hash']);
        return [
            'token_type' => 'Bearer',
            'access_token' => $token,
            'expires_at' => date('c', $exp),
            'user' => $user,
        ];
    }

    public function logout(string $token): void
    {
        $this->tokens->revokeByToken($token);
    }
}