<?php

declare(strict_types=1);

namespace App\Core;

use PDO;

final class Database
{
    private static $instance = null;

    public static function connection(array $config): PDO
    {
        if (self::$instance instanceof PDO) {
            return self::$instance;
        }
        $db = $config['database'];
        $dsn = sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s', $db['host'], $db['port'], $db['name'], $db['charset']);
        self::$instance = new PDO($dsn, $db['user'], $db['pass'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
        date_default_timezone_set('America/Tijuana');
        $offset = (new \DateTime('now', new \DateTimeZone('America/Tijuana')))->format('P');
        $stmt = self::$instance->prepare('SET time_zone = :timezone');
        $stmt->execute(['timezone' => $offset]);
        return self::$instance;
    }
}