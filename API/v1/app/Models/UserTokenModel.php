<?php

declare(strict_types=1);

namespace App\Models;

use App\Core\BaseModel;

final class UserTokenModel extends BaseModel
{
    protected $table = 'user_tokens';
    protected $fillable = ['user_id', 'token', 'device_name', 'device_type', 'ip_address', 'expires_at'];

    public function create(array $data): int
    {
        return $this->insert($data);
    }

    public function findActive(string $token): ?array
    {
        $sql = 'SELECT * FROM user_tokens WHERE token=:token AND is_revoked=0 AND expires_at > NOW() LIMIT 1';
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['token' => $token]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function revokeByToken(string $token): bool
    {
        $stmt = $this->pdo->prepare('UPDATE user_tokens SET is_revoked=1 WHERE token=:token');
        return $stmt->execute(['token' => $token]);
    }

    public function touch(string $token): void
    {
        $stmt = $this->pdo->prepare('UPDATE user_tokens SET last_used_at=NOW() WHERE token=:token');
        $stmt->execute(['token' => $token]);
    }
}