<?php

declare(strict_types=1);

namespace App\Core;

abstract class CrudController extends BaseController
{
    protected $config;
    protected $request;
    protected $model;

    public function __construct(array $config, Request $request)
    {
        $this->config = $config;
        $this->request = $request;
    }

    public function index(): void
    {
        $limit = (int) $this->request->query('limit', 100);
        $offset = (int) $this->request->query('offset', 0);
        $this->ok($this->model->all($limit, $offset));
    }

    public function show(): void
    {
        $id = (int) $this->request->attribute('id');
        $row = $this->model->find($id);
        if (!$row) {
            $this->fail('Record not found', 404);
        }
        $this->ok($row);
    }

    public function store(): void
    {
        $id = $this->model->create($this->request->input());
        $this->ok(['id' => $id], 201);
    }

    public function update(): void
    {
        $id = (int) $this->request->attribute('id');
        $ok = $this->model->edit($id, $this->request->input());
        if (!$ok) {
            $this->fail('Update failed', 422);
        }
        $this->ok(['id' => $id]);
    }

    public function destroy(): void
    {
        $id = (int) $this->request->attribute('id');
        $this->model->delete($id);
        $this->ok(['id' => $id]);
    }
}