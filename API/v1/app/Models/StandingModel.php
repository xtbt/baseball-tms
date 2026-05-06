<?php

declare(strict_types=1);

namespace App\Models;

use App\Core\BaseModel;

final class StandingModel extends BaseModel
{
    protected $table = 'standings';
    protected $fillable = [
        'team_id', 'category_id', 'season_year', 'games_played', 'wins', 'losses',
        'ties', 'runs_scored', 'runs_allowed'
    ];

    public function create(array $data): int
    {
        return $this->insert($data);
    }

    public function edit(int $id, array $data): bool
    {
        return $this->modify($id, $data);
    }

    public function listBy(?int $categoryId, ?int $seasonYear, int $limit, int $offset): array
    {
        $sql = 'SELECT * FROM standings WHERE 1=1';
        $params = [];
        if ($categoryId !== null) {
            $sql .= ' AND category_id = :category_id';
            $params['category_id'] = $categoryId;
        }
        if ($seasonYear !== null) {
            $sql .= ' AND season_year = :season_year';
            $params['season_year'] = $seasonYear;
        }
        $sql .= ' ORDER BY wins DESC, runs_scored DESC LIMIT :limit OFFSET :offset';
        $stmt = $this->pdo->prepare($sql);
        foreach ($params as $k => $v) {
            $stmt->bindValue(':' . $k, $v, \PDO::PARAM_INT);
        }
        $stmt->bindValue(':limit', $limit, \PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, \PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }
}