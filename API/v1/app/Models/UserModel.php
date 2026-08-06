<?php

declare(strict_types=1);

namespace App\Models;

use App\Core\BaseModel;
use PDO;

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

    public function listWithProfile(int $limit, int $offset, string $query = '', ?string $role = null, ?int $teamId = null): array
    {
        $sql = 'SELECT u.id, u.email, u.password_hash, u.role, u.is_active, u.last_login_at,
                       up.id AS profile_id, up.team_id, up.first_name, up.paternal_surname, up.maternal_surname,
                       up.birth_date, up.curp, up.phone, up.jersey_number, up.position, up.employee_class,
                       up.employee_number, up.employee_area, up.isstecali_affiliation,
                       up.shirt_size, up.pants_size, up.hat_size,
                       t.name AS team_name
                FROM users u
                LEFT JOIN user_profiles up ON up.user_id = u.id
                LEFT JOIN teams t ON t.id = up.team_id';
        $params = [];
        $whereConditions = [];

        if ($query !== '') {
            $whereConditions[] = '(
                        u.email LIKE :q_email OR
                        u.role LIKE :q_role OR
                        up.first_name LIKE :q_first_name OR
                        up.paternal_surname LIKE :q_paternal_surname OR
                        up.maternal_surname LIKE :q_maternal_surname OR
                        t.name LIKE :q_team_name
                      )';
            $likeValue = '%' . $query . '%';
            $params = [
                'q_email' => $likeValue,
                'q_role' => $likeValue,
                'q_first_name' => $likeValue,
                'q_paternal_surname' => $likeValue,
                'q_maternal_surname' => $likeValue,
                'q_team_name' => $likeValue,
            ];
        }

        if ($role !== null) {
            $whereConditions[] = 'u.role = :filter_role';
            $params['filter_role'] = $role;
        }

        if ($teamId !== null && $teamId > 0) {
            $whereConditions[] = 'up.team_id = :filter_team_id';
            $params['filter_team_id'] = $teamId;
        }

        if (!empty($whereConditions)) {
            $sql .= ' WHERE ' . implode(' AND ', $whereConditions);
        }

        $sql .= ' ORDER BY u.id DESC LIMIT :limit OFFSET :offset';

        $stmt = $this->pdo->prepare($sql);
        foreach ($params as $key => $value) {
            $stmt->bindValue(':' . $key, $value, $value === (int) $value ? PDO::PARAM_INT : PDO::PARAM_STR);
        }
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public function countWithProfile(string $query = '', ?string $role = null, ?int $teamId = null): int
    {
        $sql = 'SELECT COUNT(*)
                FROM users u
                LEFT JOIN user_profiles up ON up.user_id = u.id
                LEFT JOIN teams t ON t.id = up.team_id';
        $params = [];
        $whereConditions = [];

        if ($query !== '') {
            $whereConditions[] = '(
                        u.email LIKE :q_email OR
                        u.role LIKE :q_role OR
                        up.first_name LIKE :q_first_name OR
                        up.paternal_surname LIKE :q_paternal_surname OR
                        up.maternal_surname LIKE :q_maternal_surname OR
                        t.name LIKE :q_team_name
                      )';
            $likeValue = '%' . $query . '%';
            $params = [
                'q_email' => $likeValue,
                'q_role' => $likeValue,
                'q_first_name' => $likeValue,
                'q_paternal_surname' => $likeValue,
                'q_maternal_surname' => $likeValue,
                'q_team_name' => $likeValue,
            ];
        }

        if ($role !== null) {
            $whereConditions[] = 'u.role = :filter_role';
            $params['filter_role'] = $role;
        }

        if ($teamId !== null && $teamId > 0) {
            $whereConditions[] = 'up.team_id = :filter_team_id';
            $params['filter_team_id'] = $teamId;
        }

        if (!empty($whereConditions)) {
            $sql .= ' WHERE ' . implode(' AND ', $whereConditions);
        }

        $stmt = $this->pdo->prepare($sql);
        foreach ($params as $key => $value) {
            $stmt->bindValue(':' . $key, $value, $value === (int) $value ? PDO::PARAM_INT : PDO::PARAM_STR);
        }
        $stmt->execute();
        return (int) $stmt->fetchColumn();
    }
}