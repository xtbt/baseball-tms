<?php

declare(strict_types=1);

namespace App\Core;

use PDO;

abstract class BaseModel
{
    protected $pdo;
    protected $table;
    protected $fillable = [];

    public function __construct(array $config)
    {
        $this->pdo = Database::connection($config);
    }

    public function all(int $limit = 100, int $offset = 0): array
    {
        $sql = sprintf('SELECT * FROM %s ORDER BY id DESC LIMIT :limit OFFSET :offset', $this->table);
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public function find(int $id): ?array
    {
        $stmt = $this->pdo->prepare(sprintf('SELECT * FROM %s WHERE id = :id', $this->table));
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->pdo->prepare(sprintf('DELETE FROM %s WHERE id = :id', $this->table));
        return $stmt->execute(['id' => $id]);
    }

    protected function insert(array $data): int
    {
        $payload = $this->filterFillable($data);
        $columns = array_keys($payload);
        $marks = array_map(function ($c) { return ':' . $c; }, $columns);
        $sql = sprintf('INSERT INTO %s (%s) VALUES (%s)', $this->table, implode(',', $columns), implode(',', $marks));
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($payload);
        return (int) $this->pdo->lastInsertId();
    }

    protected function modify(int $id, array $data): bool
    {
        $payload = $this->filterFillable($data);
        if (empty($payload)) {
            return false;
        }
        $sets = array_map(function ($c) { return $c . '=:' . $c; }, array_keys($payload));
        $payload['id'] = $id;
        $sql = sprintf('UPDATE %s SET %s WHERE id=:id', $this->table, implode(',', $sets));
        $stmt = $this->pdo->prepare($sql);
        return $stmt->execute($payload);
    }

    private function filterFillable(array $data): array
    {
        return array_intersect_key($data, array_flip($this->fillable));
    }
}