<?php

declare(strict_types=1);

namespace App\Models;

use App\Core\BaseModel;

final class UserModel extends BaseModel
{
    protected $table = 'users';
    protected $fillable = ['email', 'password_hash', 'role', 'is_active', 'last_login_at'];

    public function create(array $data): int
    {
        if (isset($data['password'])) {
            $data['password_hash'] = password_hash((string) $data['password'], PASSWORD_BCRYPT);
            unset($data['password']);
        }
        return $this->insert($data);
    }

    public function edit(int $id, array $data): bool
    {
        if (isset($data['password'])) {
            $data['password_hash'] = password_hash((string) $data['password'], PASSWORD_BCRYPT);
            unset($data['password']);
        }
        return $this->modify($id, $data);
    }

    public function findByEmail(string $email): ?array
    {
        $stmt = $this->pdo->prepare('SELECT * FROM users WHERE email = :email LIMIT 1');
        $stmt->execute(['email' => $email]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function markLastLogin(int $id): void
    {
        $stmt = $this->pdo->prepare('UPDATE users SET last_login_at = NOW() WHERE id = :id');
        $stmt->execute(['id' => $id]);
    }
}