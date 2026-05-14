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

    public function uploadPhoto(): void
    {
        $id = (int) $this->request->attribute('id');
        if ($id <= 0) {
            $this->fail('Invalid user id', 422);
        }

        $user = $this->model->find($id);
        if (!$user) {
            $this->fail('Record not found', 404);
        }

        $file = $_FILES['photo'] ?? null;
        if (!is_array($file) || !isset($file['error'])) {
            $this->fail('Photo file is required', 422);
        }

        if ((int) $file['error'] !== UPLOAD_ERR_OK) {
            $this->fail('Invalid upload', 422);
        }

        $size = (int) ($file['size'] ?? 0);
        if ($size <= 0 || $size > 2097152) {
            $this->fail('Photo must be <= 2MB', 422);
        }

        $name = (string) ($file['name'] ?? '');
        $extension = strtolower((string) pathinfo($name, PATHINFO_EXTENSION));
        if ($extension !== 'jpg' && $extension !== 'jpeg') {
            $this->fail('Photo must be JPG', 422);
        }

        $tmpName = (string) ($file['tmp_name'] ?? '');
        $imageInfo = @getimagesize($tmpName);
        if (!is_array($imageInfo)) {
            $this->fail('Invalid image', 422);
        }

        $mimeType = strtolower((string) ($imageInfo['mime'] ?? ''));
        if ($mimeType !== 'image/jpeg') {
            $this->fail('Photo must be JPG', 422);
        }

        $width = (int) ($imageInfo[0] ?? 0);
        $height = (int) ($imageInfo[1] ?? 0);
        if ($width <= 0 || $height <= 0 || $width > 1600 || $height > 1600) {
            $this->fail('Photo dimensions must be up to 1600x1600', 422);
        }

        $targetDir = __DIR__ . '/../../../../images/users';
        if (!is_dir($targetDir) && !mkdir($targetDir, 0775, true) && !is_dir($targetDir)) {
            $this->fail('Could not prepare destination folder', 500);
        }

        $targetPath = $targetDir . '/' . $id . '.jpg';
        if (!move_uploaded_file($tmpName, $targetPath)) {
            $this->fail('Could not save photo', 500);
        }

        $this->ok(['user_id' => $id, 'path' => '/images/users/' . $id . '.jpg', 'fingerprint' => (string) filemtime($targetPath)]);
    }
}
