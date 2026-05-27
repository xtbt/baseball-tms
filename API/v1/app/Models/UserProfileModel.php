<?php

declare(strict_types=1);

namespace App\Models;

use App\Core\BaseModel;

final class UserProfileModel extends BaseModel
{
    protected $table = 'user_profiles';
    protected $fillable = [
        'user_id', 'team_id', 'first_name', 'paternal_surname', 'maternal_surname',
        'birth_date', 'curp', 'phone', 'jersey_number', 'position', 'employee_class',
        'employee_number', 'employee_area', 'isstecali_affiliation'
    ];

    public function create(array $data): int
    {
        return $this->insert($data);
    }

    public function edit(int $id, array $data): bool
    {
        return $this->modify($id, $data);
    }

    public function findByUserId(int $userId): ?array
    {
        $stmt = $this->pdo->prepare('SELECT * FROM user_profiles WHERE user_id = :user_id LIMIT 1');
        $stmt->execute(['user_id' => $userId]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function upsertByUserId(int $userId, array $data): int
    {
        $existing = $this->findByUserId($userId);
        $data['user_id'] = $userId;
        if ($existing) {
            $this->modify((int) $existing['id'], $data);
            return (int) $existing['id'];
        }
        return $this->insert($data);
    }
}