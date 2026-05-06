<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\CrudController;
use App\Core\Request;
use App\Models\GameModel;

final class GameController extends CrudController
{
    public function __construct(array $config, Request $request)
    {
        parent::__construct($config, $request);
        $this->model = new GameModel($config);
    }

    public function store(): void
    {
        $payload = $this->request->input();
        $authUser = $this->request->attribute('auth_user', []);
        if (!isset($payload['created_by']) && isset($authUser['id'])) {
            $payload['created_by'] = (int) $authUser['id'];
        }
        $id = $this->model->create($payload);
        $this->ok(['id' => $id], 201);
    }
}