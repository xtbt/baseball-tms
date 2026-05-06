<?php

declare(strict_types=1);

namespace App\Core;

abstract class BaseController
{
    protected function ok(array $data = [], int $status = 200): void
    {
        Response::json(['success' => true, 'data' => $data], $status);
    }

    protected function fail(string $message, int $status = 400, array $errors = []): void
    {
        Response::json(['success' => false, 'message' => $message, 'errors' => $errors], $status);
    }
}