<?php

declare(strict_types=1);

namespace App\Core;

use RuntimeException;

final class Jwt
{
    public static function encode(array $payload, string $secret): string
    {
        $header = ['alg' => 'HS256', 'typ' => 'JWT'];
        $segments = [self::b64(json_encode($header)), self::b64(json_encode($payload))];
        $signing = implode('.', $segments);
        $segments[] = self::b64(hash_hmac('sha256', $signing, $secret, true));
        return implode('.', $segments);
    }

    public static function decode(string $token, string $secret): array
    {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            throw new RuntimeException('Invalid token format');
        }
        [$h, $p, $s] = $parts;
        $check = self::b64(hash_hmac('sha256', $h . '.' . $p, $secret, true));
        if (!hash_equals($check, $s)) {
            throw new RuntimeException('Invalid token signature');
        }
        $payload = json_decode(self::ub64($p), true);
        if (!is_array($payload)) {
            throw new RuntimeException('Invalid token payload');
        }
        if (isset($payload['exp']) && time() > (int) $payload['exp']) {
            throw new RuntimeException('Token expired');
        }
        return $payload;
    }

    private static function b64(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }

    private static function ub64(string $value): string
    {
        $pad = strlen($value) % 4;
        if ($pad > 0) {
            $value .= str_repeat('=', 4 - $pad);
        }
        return base64_decode(strtr($value, '-_', '+/')) ?: '';
    }
}