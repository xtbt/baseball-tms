<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\BaseController;
use App\Core\Request;
use App\Models\UserProfileModel;

final class ProfileController extends BaseController
{
    private $request;
    private $model;

    public function __construct(array $config, Request $request)
    {
        $this->request = $request;
        $this->model = new UserProfileModel($config);
    }

    public function showByUser(): void
    {
        $userId = (int) $this->request->attribute('id');
        $row = $this->model->findByUserId($userId);
        if (!$row) {
            $this->fail('Profile not found', 404);
        }
        $this->ok($row);
    }

    public function upsertByUser(): void
    {
        $userId = (int) $this->request->attribute('id');
        $id = $this->model->upsertByUserId($userId, $this->request->input());
        $this->ok(['id' => $id]);
    }
}