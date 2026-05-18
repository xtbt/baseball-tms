<?php

declare(strict_types=1);

return [
    'app' => [
        'name' => getenv('APP_NAME') ?: 'Baseball TMS API',
        'env' => getenv('APP_ENV') ?: 'local',
        'debug' => (bool) (getenv('APP_DEBUG') ?: true),
        'timezone' => 'America/Tijuana',
    ],
    'database' => [
        'host' => getenv('DB_HOST') ?: '127.0.0.1',
        'port' => (int) (getenv('DB_PORT') ?: 3306),
        'name' => getenv('DB_NAME') ?: 'baseball_tms',
        'user' => getenv('DB_USER') ?: 'sindicato',
        'pass' => getenv('DB_PASS') ?: 'AdmSindicato26!',
        'charset' => getenv('DB_CHARSET') ?: 'utf8mb4',
    ],
    'jwt' => [
        'secret' => getenv('JWT_SECRET') ?: 'por_un_estado_al_servicio_del_pueblo',
        'issuer' => getenv('JWT_ISSUER') ?: 'baseball-tms',
        'audience' => getenv('JWT_AUDIENCE') ?: 'baseball-tms-clients',
        'ttl_minutes' => (int) (getenv('JWT_TTL_MINUTES') ?: 120),
    ],
];