<?php

declare(strict_types=1);

namespace App\Models;

use App\Core\BaseModel;

final class VenueModel extends BaseModel
{
    protected $table = 'venues';
    protected $fillable = ['name', 'address', 'is_active'];

    public function create(array $data): int
    {
        return $this->insert($data);
    }

    public function edit(int $id, array $data): bool
    {
        return $this->modify($id, $data);
    }
}