<?php

declare(strict_types=1);

namespace App\Models;

use App\Core\BaseModel;

final class GameModel extends BaseModel
{
    protected $table = 'games';
    protected $fillable = [
        'game_date', 'game_time', 'venue_id', 'home_team_id', 'away_team_id',
        'home_score', 'away_score', 'innings_played', 'status', 'notes', 'created_by'
    ];

    public function create(array $data): int
    {
        return $this->insert($data);
    }

    public function edit(int $id, array $data): bool
    {
        return $this->modify($id, $data);
    }
}