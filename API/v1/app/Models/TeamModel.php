<?php

declare(strict_types=1);

namespace App\Models;

use App\Core\BaseModel;

final class TeamModel extends BaseModel
{
    protected $table = 'teams';
    protected $fillable = ['name', 'category_id', 'logo_url', 'is_active'];

    public function create(array $data): int
    {
        return $this->insert($data);
    }

    public function edit(int $id, array $data): bool
    {
        return $this->modify($id, $data);
    }
}