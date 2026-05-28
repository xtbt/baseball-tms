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
        $limit = max(1, min(200, (int) $this->request->query('limit', 100)));
        $offset = max(0, (int) $this->request->query('offset', 0));
        $includeProfile = (int) $this->request->query('include_profile', 0) === 1;

        if (!$includeProfile) {
            $rows = $this->model->all($limit, $offset);
            foreach ($rows as &$row) {
                unset($row['password_hash']);
            }
            $this->ok($rows);
        }

        $query = trim((string) $this->request->query('q', ''));
        $rows = $this->model->listWithProfile($limit, $offset, $query);
        $items = [];
        foreach ($rows as $row) {
            $profile = null;
            if (!empty($row['profile_id'])) {
                $profile = [
                    'id' => (int) $row['profile_id'],
                    'team_id' => isset($row['team_id']) ? (int) $row['team_id'] : null,
                    'first_name' => $row['first_name'] ?? null,
                    'paternal_surname' => $row['paternal_surname'] ?? null,
                    'maternal_surname' => $row['maternal_surname'] ?? null,
                    'birth_date' => $row['birth_date'] ?? null,
                    'curp' => $row['curp'] ?? null,
                    'phone' => $row['phone'] ?? null,
                    'jersey_number' => isset($row['jersey_number']) ? (int) $row['jersey_number'] : null,
                    'position' => $row['position'] ?? null,
                    'employee_class' => $row['employee_class'] ?? null,
                    'employee_number' => $row['employee_number'] ?? null,
                    'employee_area' => $row['employee_area'] ?? null,
                    'isstecali_affiliation' => $row['isstecali_affiliation'] ?? null,
                    'team_name' => $row['team_name'] ?? null,
                ];
            }

            $items[] = [
                'id' => (int) $row['id'],
                'email' => (string) ($row['email'] ?? ''),
                'role' => (string) ($row['role'] ?? ''),
                'is_active' => isset($row['is_active']) ? (int) $row['is_active'] : 0,
                'last_login_at' => $row['last_login_at'] ?? null,
                'profile' => $profile,
            ];
        }

        $total = $this->model->countWithProfile($query);
        $this->ok([
            'items' => $items,
            'meta' => [
                'limit' => $limit,
                'offset' => $offset,
                'total' => $total,
            ],
        ]);
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
