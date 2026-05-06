<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\CrudController;
use App\Core\Request;
use App\Models\UserModel;

final class UserController extends CrudController
{
    public function __construct(array $config, Request $request)
    {
        parent::__construct($config, $request);
        $this->model = new UserModel($config);
    }

    public function show(): void
    {
        $id = (int) $this->request->attribute('id');
        $row = $this->model->find($id);
        if (!$row) {
            $this->fail('Record not found', 404);
        }
        unset($row['password_hash']);
        $this->ok($row);
    }

    public function index(): void
    {
        $limit = (int) $this->request->query('limit', 100);
        $offset = (int) $this->request->query('offset', 0);
        $rows = $this->model->all($limit, $offset);
        foreach ($rows as &$row) {
            unset($row['password_hash']);
        }
        $this->ok($rows);
    }
}