<?php

declare(strict_types=1);

namespace App\Models;

use App\Core\BaseModel;

final class CategoryModel extends BaseModel
{
    protected $table = 'categories';
    protected $fillable = ['name', 'description', 'is_active'];

    public function create(array $data): int
    {
        return $this->insert($data);
    }

    public function edit(int $id, array $data): bool
    {
        return $this->modify($id, $data);
    }
}