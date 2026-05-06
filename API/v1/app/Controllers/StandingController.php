<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\BaseController;
use App\Core\Request;
use App\Models\StandingModel;

final class StandingController extends BaseController
{
    private $request;
    private $model;

    public function __construct(array $config, Request $request)
    {
        $this->request = $request;
        $this->model = new StandingModel($config);
    }

    public function index(): void
    {
        $categoryId = $this->request->query('category_id');
        $seasonYear = $this->request->query('season_year');
        $limit = (int) $this->request->query('limit', 100);
        $offset = (int) $this->request->query('offset', 0);
        $rows = $this->model->listBy(
            $categoryId !== null ? (int) $categoryId : null,
            $seasonYear !== null ? (int) $seasonYear : null,
            $limit,
            $offset
        );
        $this->ok($rows);
    }
}