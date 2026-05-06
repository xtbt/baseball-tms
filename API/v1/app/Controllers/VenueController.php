<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\CrudController;
use App\Core\Request;
use App\Models\VenueModel;

final class VenueController extends CrudController
{
    public function __construct(array $config, Request $request)
    {
        parent::__construct($config, $request);
        $this->model = new VenueModel($config);
    }
}