-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost
-- Tiempo de generación: 14-05-2026 a las 15:36:41
-- Versión del servidor: 10.4.20-MariaDB
-- Versión de PHP: 8.0.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `baseball_tms`
--
CREATE DATABASE IF NOT EXISTS `baseball_tms` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `baseball_tms`;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
CREATE TABLE `audit_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `record_id` int(10) UNSIGNED DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Audit trail for critical data changes';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tournament categories (e.g. Libre, Veteranos, Sub-23)';

--
-- Volcado de datos para la tabla `categories`
--

INSERT INTO `categories` (`id`, `name`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Categoria A', 'Los pros', 1, '2026-05-13 14:05:12', '2026-05-13 14:05:12'),
(2, 'Categoria B', 'Los regulares', 1, '2026-05-13 14:05:27', '2026-05-13 16:03:53'),
(3, 'Categoria C', 'Los malos', 1, '2026-05-13 14:05:40', '2026-05-13 16:03:30');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `games`
--

DROP TABLE IF EXISTS `games`;
CREATE TABLE `games` (
  `id` int(10) UNSIGNED NOT NULL,
  `game_date` date NOT NULL,
  `game_time` time NOT NULL,
  `venue_id` int(10) UNSIGNED NOT NULL,
  `home_team_id` int(10) UNSIGNED NOT NULL,
  `away_team_id` int(10) UNSIGNED NOT NULL,
  `home_score` tinyint(3) UNSIGNED DEFAULT NULL,
  `away_score` tinyint(3) UNSIGNED DEFAULT NULL,
  `innings_played` tinyint(3) UNSIGNED DEFAULT NULL,
  `status` enum('PROGRAMADO','FINALIZADO','CANCELADO','POSPUESTO') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PROGRAMADO',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `games`
--

INSERT INTO `games` (`id`, `game_date`, `game_time`, `venue_id`, `home_team_id`, `away_team_id`, `home_score`, `away_score`, `innings_played`, `status`, `notes`, `created_by`, `created_at`, `updated_at`) VALUES
(1, '2026-05-15', '15:30:00', 1, 5, 1, NULL, NULL, NULL, 'PROGRAMADO', NULL, 1, '2026-05-14 10:37:33', '2026-05-14 10:37:33');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `game_innings`
--

DROP TABLE IF EXISTS `game_innings`;
CREATE TABLE `game_innings` (
  `id` int(10) UNSIGNED NOT NULL,
  `game_id` int(10) UNSIGNED NOT NULL,
  `inning` tinyint(3) UNSIGNED NOT NULL,
  `home_runs` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `away_runs` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Run scoring per inning';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `player_game_stats`
--

DROP TABLE IF EXISTS `player_game_stats`;
CREATE TABLE `player_game_stats` (
  `id` int(10) UNSIGNED NOT NULL,
  `game_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `team_id` int(10) UNSIGNED NOT NULL,
  `at_bats` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `hits` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `runs` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `rbi` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `home_runs` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `strikeouts` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `walks` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `errors` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `innings_pitched` decimal(4,1) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Individual player statistics per game';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `standings`
--

DROP TABLE IF EXISTS `standings`;
CREATE TABLE `standings` (
  `id` int(10) UNSIGNED NOT NULL,
  `team_id` int(10) UNSIGNED NOT NULL,
  `category_id` int(10) UNSIGNED NOT NULL,
  `season_year` year(4) NOT NULL,
  `games_played` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `wins` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `losses` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `ties` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `runs_scored` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `runs_allowed` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Cached standings table per category and season';

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `teams`
--

DROP TABLE IF EXISTS `teams`;
CREATE TABLE `teams` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` int(10) UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registered teams per category';

--
-- Volcado de datos para la tabla `teams`
--

INSERT INTO `teams` (`id`, `name`, `category_id`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Dodgers', 1, 1, '2026-05-13 14:07:01', '2026-05-13 14:07:01'),
(2, 'Padres', 2, 1, '2026-05-13 14:07:14', '2026-05-13 14:07:14'),
(3, 'Gigantes', 3, 1, '2026-05-13 14:07:23', '2026-05-13 16:22:39'),
(4, 'Yanquis', 1, 1, '2026-05-13 16:22:49', '2026-05-13 16:22:49'),
(5, 'Toros', 2, 1, '2026-05-13 16:23:28', '2026-05-13 16:23:28');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','manager','player') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'player',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System authentication and authorization';

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`id`, `email`, `password_hash`, `role`, `is_active`, `last_login_at`, `created_at`, `updated_at`) VALUES
(1, 'jsanchez.1983@gmail.com', '$2y$10$d1attNAU9pIjq6MizhBRNOar8EzL1UOueFJUK3TNdgXWEH/hc0UQW', 'admin', 1, '2026-05-14 15:33:47', '2026-05-06 15:34:00', '2026-05-14 15:33:47'),
(2, 'manager@sindicato.com', '$2y$10$4Swp15LcL32IHS/Qx5Wj6.RekBm8LWezMlNjnaatEx9VNi.cIkBnC', 'manager', 1, '2026-05-14 15:10:47', '2026-05-13 13:40:36', '2026-05-14 15:10:47'),
(3, 'player@sindicato.com', '$2y$10$.3Bj7eyfSPA21HuFB.XAze3GrzgR99PS4VajUUTzYnw5d4AL9G7QC', 'player', 1, '2026-05-14 10:32:58', '2026-05-13 14:16:07', '2026-05-14 10:32:58'),
(4, 'player2@sindicato.com', '$2y$10$6VUz7TmqQRXrQdMfX6PlFePsE/lNB2auNNkQieNQMPocaXm/b0eMu', 'player', 1, '2026-05-13 22:10:27', '2026-05-13 22:08:46', '2026-05-13 22:11:03'),
(5, 'player3@sindicato.com', '$2y$10$e6Lp8uUwz3IjCTTcQZnaAOea9tiMuJdyXgSx4WeukXYoo5/Mf9A/2', 'player', 1, NULL, '2026-05-14 14:05:46', '2026-05-14 14:05:46'),
(6, 'deportes@sindicato.com', '$2y$10$8lIBclcl0X5M.oadri5kMODeqSG5HqIEDjC6oLgFFVPg2rLcbnGaW', 'admin', 1, '2026-05-14 15:35:44', '2026-05-14 15:34:55', '2026-05-14 15:35:44');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_profiles`
--

DROP TABLE IF EXISTS `user_profiles`;
CREATE TABLE `user_profiles` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `team_id` int(10) UNSIGNED DEFAULT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `paternal_surname` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `maternal_surname` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `birth_date` date NOT NULL,
  `curp` char(18) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jersey_number` tinyint(3) UNSIGNED DEFAULT NULL,
  `position` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'P, C, 1B, 2B, 3B, SS, LF, CF, RF, DH, UT',
  `employee_class` enum('BASE','CONFIANZA','CONTRATO','HIJO','INVITADO') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `employee_number` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isstecali_affiliation` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Extended player/manager profile data';

--
-- Volcado de datos para la tabla `user_profiles`
--

INSERT INTO `user_profiles` (`id`, `user_id`, `team_id`, `first_name`, `paternal_surname`, `maternal_surname`, `birth_date`, `curp`, `phone`, `jersey_number`, `position`, `employee_class`, `employee_number`, `isstecali_affiliation`, `created_at`, `updated_at`) VALUES
(1, 1, NULL, 'JONATHAN', 'SANCHEZ', NULL, '1983-05-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-13 13:36:14', '2026-05-13 13:36:14'),
(2, 2, 3, 'FULANO', 'DE TAL', NULL, '1990-01-01', NULL, NULL, NULL, NULL, 'BASE', NULL, NULL, '2026-05-13 14:10:01', '2026-05-13 15:01:00'),
(3, 3, 3, 'PLAYER', 'TEST', NULL, '2001-05-01', NULL, NULL, 1, 'PITCHER', NULL, NULL, NULL, '2026-05-13 14:19:13', '2026-05-13 14:19:13'),
(4, 4, NULL, 'JUGADOR', 'DOS', NULL, '2000-01-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-13 22:08:46', '2026-05-13 22:08:46'),
(5, 5, 3, 'TEST', 'DE FOTO', 'PRIMERO1', '2000-05-01', NULL, NULL, NULL, NULL, 'INVITADO', NULL, NULL, '2026-05-14 14:05:46', '2026-05-14 14:30:47'),
(6, 6, NULL, 'Secretaría', 'Deportes', NULL, '1980-01-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-14 15:34:55', '2026-05-14 15:34:55');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_tokens`
--

DROP TABLE IF EXISTS `user_tokens`;
CREATE TABLE `user_tokens` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `token` varchar(512) COLLATE utf8mb4_unicode_ci NOT NULL,
  `device_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'e.g. Chrome/Windows, Safari/iPhone',
  `device_type` enum('web','mobile','tablet','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'web',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `last_used_at` datetime DEFAULT NULL,
  `is_revoked` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Active session tokens per user device';

--
-- Volcado de datos para la tabla `user_tokens`
--

INSERT INTO `user_tokens` (`id`, `user_id`, `token`, `device_name`, `device_type`, `ip_address`, `expires_at`, `last_used_at`, `is_revoked`, `created_at`) VALUES
(1, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImVtYWlsIjoianNhbmNoZXouMTk4M0BnbWFpbC5jb20iLCJyb2xlIjoiYWRtaW4iLCJpc3MiOiJiYXNlYmFsbC10bXMiLCJhdWQiOiJiYXNlYmFsbC10bXMtY2xpZW50cyIsImlhdCI6MTc3ODEwNjg1OCwiZXhwIjoxNzc4MTE0MDU4fQ.zXNBwdo9rL06jdpVfBZsjcHqCOj6I1BRubMZ1VgStcw', 'Local API Test', 'web', '::1', '2026-05-06 17:34:18', NULL, 0, '2026-05-06 15:34:18'),
(2, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6IjlkYzViOTczYzAyZDYzMzcxYTE3ZTRhYjhiNWY5YjBlIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzA0MzQ4LCJleHAiOjE3Nzg3MTE1NDh9.TkU-YiA55JdY8w4G39sx4mSxWb100T4ES-XFsyDfUvQ', NULL, 'web', '127.0.0.1', '2026-05-13 15:32:28', '2026-05-13 14:16:07', 0, '2026-05-13 13:32:28'),
(3, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6IjU4MDUxZjNkZTc0NzcwOGI0NjU3Y2E1M2I0NjMzNzYwIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzA0NTA5LCJleHAiOjE3Nzg3MTE3MDl9.V5RuyYFl4sxhQNYruWqTm_dhy4Ccf7ahRZ04revvve4', 'Web Frontend', 'web', '::1', '2026-05-13 15:35:09', '2026-05-13 13:40:44', 1, '2026-05-13 13:35:09'),
(4, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsImp0aSI6IjIzODk3OGE4NjU3MWUzYTY2Nzg1ZGMwZTY3YmNhNGRkIiwiZW1haWwiOiJtYW5hZ2VyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoibWFuYWdlciIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzA0ODU4LCJleHAiOjE3Nzg3MTIwNTh9.VFfFJH78KHL2jk6KxTI9GjqGbbWbYHtvCc99LcLu8rE', 'Web Frontend', 'web', '::1', '2026-05-13 15:40:58', '2026-05-13 14:08:14', 1, '2026-05-13 13:40:58'),
(5, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsImp0aSI6IjA4N2VlMGY5ZWY0NWU0YzE1OGQ4ZTk0ZTEwNTc2ZDhhIiwiZW1haWwiOiJtYW5hZ2VyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoibWFuYWdlciIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzA2NTUwLCJleHAiOjE3Nzg3MTM3NTB9.7vhq7BJe-oMdMtN4QkHTjxils-zQSO-OQEWttO9kH78', 'Web Frontend', 'web', '::1', '2026-05-13 16:09:10', '2026-05-13 14:12:44', 1, '2026-05-13 14:09:10'),
(6, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6ImFjODNiZmI4OWY2MWM2OGNlYjE0MmFmZDM1ODNlN2VkIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzA2Nzc0LCJleHAiOjE3Nzg3MTM5NzR9.HkljVWwf1J9f4aWkGTeEn3sprnGdk103pt8fC8q82h8', 'Web Frontend', 'web', '::1', '2026-05-13 16:12:54', '2026-05-13 14:13:03', 1, '2026-05-13 14:12:54'),
(7, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsImp0aSI6IjBkNDMyYmI1MjFlOWU5M2EyZDQyNzRhNDc5OTE2Mjc3IiwiZW1haWwiOiJtYW5hZ2VyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoibWFuYWdlciIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzA2Nzg5LCJleHAiOjE3Nzg3MTM5ODl9.Tnea2YGdYbhBio-aMEZ66b6dqO7fbBOm18aT96vg7Eg', 'Web Frontend', 'web', '::1', '2026-05-13 16:13:09', '2026-05-13 14:20:36', 1, '2026-05-13 14:13:09'),
(8, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6ImY2NzU4MmM0YjQwNDg1NDNkNzYzNmE2YWMyOWU0ZGUyIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzA3MjQzLCJleHAiOjE3Nzg3MTQ0NDN9.MZPNLplxAr-fi7ecXumy2NjJdTGbwu77lC6xtUPCj0c', 'Web Frontend', 'web', '::1', '2026-05-13 16:20:43', '2026-05-13 14:21:31', 1, '2026-05-13 14:20:43'),
(9, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjMsImp0aSI6IjVhZjQxMDZhNWEzZTFlM2M3NmJhYjZkZmRjODhkZWI2IiwiZW1haWwiOiJwbGF5ZXJAc2luZGljYXRvLmNvbSIsInJvbGUiOiJwbGF5ZXIiLCJpc3MiOiJiYXNlYmFsbC10bXMiLCJhdWQiOiJiYXNlYmFsbC10bXMtY2xpZW50cyIsImlhdCI6MTc3ODcwNzM0MSwiZXhwIjoxNzc4NzE0NTQxfQ.hGuTUqwjNe6q1Odph6nxbH12pmuQg_ulSN6y6J8VfEM', 'Web Frontend', 'web', '::1', '2026-05-13 16:22:21', '2026-05-13 14:22:40', 1, '2026-05-13 14:22:21'),
(10, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsImp0aSI6IjA2OTFlZTJkY2U5ZDhhZmFhMGRmYTJmZDRkMmUwMjBhIiwiZW1haWwiOiJtYW5hZ2VyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoibWFuYWdlciIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzA3MzY2LCJleHAiOjE3Nzg3MTQ1NjZ9.WWB1KeXLrNYS18JAHyVSXTi55Yzw79GGHmGIpJl5VKI', 'Web Frontend', 'web', '::1', '2026-05-13 16:22:46', '2026-05-13 14:45:47', 1, '2026-05-13 14:22:46'),
(11, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsImp0aSI6IjU2Mzk0ODNmZmRlMjg3Mjg1ZjkxYmU1Mzc5NDJmMGFmIiwiZW1haWwiOiJtYW5hZ2VyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoibWFuYWdlciIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzA4NzUyLCJleHAiOjE3Nzg3MTU5NTJ9.VaVil0waeQjcTyRfSd6a7LPGMe1MJHq4FUv2jg9uCs8', 'Web Frontend', 'web', '::1', '2026-05-13 16:45:52', '2026-05-13 14:48:37', 1, '2026-05-13 14:45:52'),
(12, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjMsImp0aSI6IjUyYzE3YjNkYTRmYjQ3NzU4ZTE3ZDYzMDMyMGUzYjFlIiwiZW1haWwiOiJwbGF5ZXJAc2luZGljYXRvLmNvbSIsInJvbGUiOiJwbGF5ZXIiLCJpc3MiOiJiYXNlYmFsbC10bXMiLCJhdWQiOiJiYXNlYmFsbC10bXMtY2xpZW50cyIsImlhdCI6MTc3ODcwODkyMiwiZXhwIjoxNzc4NzE2MTIyfQ.jZh9i7gJyusy5pn9SFE37oAjAEXEB87nFB2zNeUaQvA', 'Web Frontend', 'web', '::1', '2026-05-13 16:48:42', '2026-05-13 14:48:50', 1, '2026-05-13 14:48:42'),
(13, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsImp0aSI6ImE4NmNjMTdkM2EwMDdiYjUzNTIwNzc2Njc2NGEwY2QwIiwiZW1haWwiOiJtYW5hZ2VyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoibWFuYWdlciIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzA4OTQwLCJleHAiOjE3Nzg3MTYxNDB9.n2OFe54funOJNBqFIVqfp4OjJnwavXKdNtjnLusn7BI', 'Web Frontend', 'web', '::1', '2026-05-13 16:49:00', '2026-05-13 15:01:39', 1, '2026-05-13 14:49:00'),
(14, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6Ijc2NTMxYTEwZDkzZmE4YmU0NjIyMjg5ODgzZTdjNjgzIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzA5NzA0LCJleHAiOjE3Nzg3MTY5MDR9.smRsojAfsDA7GwayLypPUGVTgQCInklW0wCDv025ZC4', 'Web Frontend', 'web', '::1', '2026-05-13 17:01:44', '2026-05-13 16:45:36', 0, '2026-05-13 15:01:44'),
(15, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6IjBiNGQ5NDdjYzkzMDVmYjczYmE4YjdmMzVlNTk3NjliIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzM1MTkxLCJleHAiOjE3Nzg3NDIzOTF9.UQDeaHfO7BsUquFLhuPHEHcuv08DbemYqKIdncItkkA', 'Web Frontend', 'web', '::1', '2026-05-14 00:06:31', '2026-05-13 22:08:59', 1, '2026-05-13 22:06:31'),
(16, 4, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjQsImp0aSI6ImNhNzFlNzhlOGQxNDExYTg3ZTNjMGJiZTE0ZTQyM2FlIiwiZW1haWwiOiJwbGF5ZXIyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoicGxheWVyIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzg3MzUzNTAsImV4cCI6MTc3ODc0MjU1MH0.ftShYVHunw37RB1U2DWPPEgnMLJECNQJzjjZ6530O8o', 'Web Frontend', 'web', '::1', '2026-05-14 00:09:10', '2026-05-13 22:09:49', 1, '2026-05-13 22:09:10'),
(17, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6ImM2MDcyMGZmYTFmYjlmMWJmNTcxZGVhZDAxMzE2MWFjIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzM1Mzk5LCJleHAiOjE3Nzg3NDI1OTl9.2rT-sb4fsej-vqRiOY2OmoKtSklE_4JFobsue98EMUU', 'Web Frontend', 'web', '::1', '2026-05-14 00:09:59', '2026-05-13 22:10:14', 1, '2026-05-13 22:09:59'),
(18, 4, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjQsImp0aSI6ImQ3OTc4OWU2NzRlNDIzNjNlYzJjYTBjOWIxMDA3MDZiIiwiZW1haWwiOiJwbGF5ZXIyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoicGxheWVyIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzg3MzU0MjcsImV4cCI6MTc3ODc0MjYyN30.OcjX75ogIDU1NW7l8Z_0ApwtUPBCKHMyR43GFIFK9e8', 'Web Frontend', 'web', '::1', '2026-05-14 00:10:27', '2026-05-13 22:10:30', 1, '2026-05-13 22:10:27'),
(19, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6ImQ4ODhhZGIwZjAzYjUwYWQyYTEwY2NmMDM0ZWJlMmY1IiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzM1NDM2LCJleHAiOjE3Nzg3NDI2MzZ9.BwyGiFzuOcoRxIIhkHshGzfg3qUEVoUrzNJLjg_AQLU', 'Web Frontend', 'web', '::1', '2026-05-14 00:10:36', '2026-05-13 22:26:05', 0, '2026-05-13 22:10:36'),
(20, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjMsImp0aSI6IjMxMzE2MTRmYTNhYWNhZmFmOWIwMmZhZmI0NWU0ODZmIiwiZW1haWwiOiJwbGF5ZXJAc2luZGljYXRvLmNvbSIsInJvbGUiOiJwbGF5ZXIiLCJpc3MiOiJiYXNlYmFsbC10bXMiLCJhdWQiOiJiYXNlYmFsbC10bXMtY2xpZW50cyIsImlhdCI6MTc3ODc3OTk3OCwiZXhwIjoxNzc4Nzg3MTc4fQ.pko7SyLt62mdHiDxNUfFssQkCKNSIPOGvWsEFLubVzk', 'Web Frontend', 'web', '::1', '2026-05-14 12:32:58', '2026-05-14 10:33:19', 1, '2026-05-14 10:32:58'),
(21, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsImp0aSI6IjU5ZTg1ZWUxYjMzYzNhNWFiMDU2MGM2ODhiMzA0MGU2IiwiZW1haWwiOiJtYW5hZ2VyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoibWFuYWdlciIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzgwMDA4LCJleHAiOjE3Nzg3ODcyMDh9.v6C7_I-YmCWNiv22qiXe2C9T6laBtB43gGH64aF4QHo', 'Web Frontend', 'web', '::1', '2026-05-14 12:33:28', '2026-05-14 10:36:21', 1, '2026-05-14 10:33:28'),
(22, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6IjYzMWU4YTgwMDA4MjA0NTk0ZTU0NjFhNGFlMTNhYzhkIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzgwMTg3LCJleHAiOjE3Nzg3ODczODd9.KpOcr0mNadzYKUvX-3z9jHuhTyxDeU_6OgC8-tdQyIg', 'Web Frontend', 'web', '::1', '2026-05-14 12:36:27', '2026-05-14 11:33:46', 1, '2026-05-14 10:36:27'),
(23, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6Ijg3MDI2OTczNDZiNGE1ZGU2OTY2M2UzM2RmNDQ0NmYwIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzgzNjQ5LCJleHAiOjE3Nzg3OTA4NDl9.ECmNGotC5pRXk8Owjo_qG0M1UV6dJtgFzLJFWr12DM4', 'Web Frontend', 'web', '::1', '2026-05-14 13:34:09', '2026-05-14 12:19:22', 1, '2026-05-14 11:34:09'),
(24, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsImp0aSI6IjE3Y2VkODkwODc1OGY1NTkxZDg2YWVjYzdlMzAyMTQwIiwiZW1haWwiOiJtYW5hZ2VyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoibWFuYWdlciIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4Nzg2MzcxLCJleHAiOjE3Nzg3OTM1NzF9.xnBYfJgns-m2oaPCEaomEXhe1ftVU5-tMLBEUKEMKrs', 'Web Frontend', 'web', '::1', '2026-05-14 14:19:31', '2026-05-14 12:26:45', 1, '2026-05-14 12:19:31'),
(25, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6IjZhMjlmNDA4OWNlNzlmNjUzYzY4ZWRiYzYyMzYzYzA4IiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4Nzg2ODExLCJleHAiOjE3Nzg3OTQwMTF9.iJ0siDYK1m8EIWX38mkPUzq8qQYWNneyH2ofwW64_Os', 'Web Frontend', 'web', '::1', '2026-05-14 14:26:51', '2026-05-14 14:26:45', 0, '2026-05-14 12:26:51'),
(26, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6ImUyMDljYzA5ODFiODI0YTY2ZjE4MWMwYzhlNmEyY2I4IiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4Nzk0MDYwLCJleHAiOjE3Nzg4MDEyNjB9.-KLPEPkBlzIWSFeWC7ikCa2aMmV3RZCZrwgJIUBXJt0', 'Web Frontend', 'web', '::1', '2026-05-14 16:27:40', '2026-05-14 15:10:39', 1, '2026-05-14 14:27:40'),
(27, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsImp0aSI6IjU2ZTA0ZDVkY2JlYTY3YTMxMzY2OTQ5Y2Y2YTYyOTk4IiwiZW1haWwiOiJtYW5hZ2VyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoibWFuYWdlciIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4Nzk2NjQ3LCJleHAiOjE3Nzg4MDM4NDd9.kfX8U75jS86TZIBm-z_f9ewpESk82MzZU4GGtggkMvY', 'Web Frontend', 'web', '::1', '2026-05-14 17:10:47', '2026-05-14 15:33:40', 1, '2026-05-14 15:10:47'),
(28, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6ImVmMTE0NDJmMjQwZGMzZWEyYzAyMWRjM2E1MTM5ZjJiIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4Nzk4MDI3LCJleHAiOjE3Nzg4MDUyMjd9.5vwrkUCpn2i14vT-bYpUchOIRmfLp4RhqY3o1jp9kbU', 'Web Frontend', 'web', '::1', '2026-05-14 17:33:47', '2026-05-14 15:35:38', 1, '2026-05-14 15:33:47'),
(29, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjQ2YWM3ZDU3Njc4ZWQ4MGMzMmEzYWRiYjllMWNjMmE3IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzg3OTgxNDQsImV4cCI6MTc3ODgwNTM0NH0._YyY7MvqbPRtGTe6XpgZSkSiDs7b48ae3glJYnrwPAQ', 'Web Frontend', 'web', '::1', '2026-05-14 17:35:44', '2026-05-14 15:36:20', 1, '2026-05-14 15:35:44');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venues`
--

DROP TABLE IF EXISTS `venues`;
CREATE TABLE `venues` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Baseball fields / venues';

--
-- Volcado de datos para la tabla `venues`
--

INSERT INTO `venues` (`id`, `name`, `address`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Viejito García', 'Otay 1234', 1, '2026-05-14 10:37:05', '2026-05-14 10:37:05');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_user` (`user_id`),
  ADD KEY `idx_audit_table_record` (`table_name`,`record_id`),
  ADD KEY `idx_audit_created_at` (`created_at`);

--
-- Indices de la tabla `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_categories_name` (`name`);

--
-- Indices de la tabla `games`
--
ALTER TABLE `games`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_games_date` (`game_date`),
  ADD KEY `idx_games_status` (`status`),
  ADD KEY `idx_games_home_team` (`home_team_id`),
  ADD KEY `idx_games_away_team` (`away_team_id`),
  ADD KEY `idx_games_venue` (`venue_id`),
  ADD KEY `fk_games_created_by` (`created_by`);

--
-- Indices de la tabla `game_innings`
--
ALTER TABLE `game_innings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_game_innings` (`game_id`,`inning`);

--
-- Indices de la tabla `player_game_stats`
--
ALTER TABLE `player_game_stats`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_player_game_stats` (`game_id`,`user_id`),
  ADD KEY `idx_pgs_user_id` (`user_id`),
  ADD KEY `idx_pgs_team_id` (`team_id`);

--
-- Indices de la tabla `standings`
--
ALTER TABLE `standings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_standings` (`team_id`,`category_id`,`season_year`),
  ADD KEY `idx_standings_category_season` (`category_id`,`season_year`);

--
-- Indices de la tabla `teams`
--
ALTER TABLE `teams`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_teams_name_category` (`name`,`category_id`),
  ADD KEY `idx_teams_category_id` (`category_id`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_email` (`email`),
  ADD KEY `idx_users_role` (`role`);

--
-- Indices de la tabla `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_profiles_user_id` (`user_id`),
  ADD UNIQUE KEY `uq_user_profiles_curp` (`curp`),
  ADD KEY `idx_user_profiles_team_id` (`team_id`),
  ADD KEY `idx_user_profiles_jersey` (`team_id`,`jersey_number`);

--
-- Indices de la tabla `user_tokens`
--
ALTER TABLE `user_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_tokens_token` (`token`(191)),
  ADD KEY `idx_user_tokens_user_id` (`user_id`),
  ADD KEY `idx_user_tokens_expires_at` (`expires_at`),
  ADD KEY `idx_user_tokens_is_revoked` (`is_revoked`);

--
-- Indices de la tabla `venues`
--
ALTER TABLE `venues`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_venues_name` (`name`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `games`
--
ALTER TABLE `games`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `game_innings`
--
ALTER TABLE `game_innings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `player_game_stats`
--
ALTER TABLE `player_game_stats`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `standings`
--
ALTER TABLE `standings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `teams`
--
ALTER TABLE `teams`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `user_tokens`
--
ALTER TABLE `user_tokens`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `venues`
--
ALTER TABLE `venues`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `audit_log`
--
ALTER TABLE `audit_log`
  ADD CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `games`
--
ALTER TABLE `games`
  ADD CONSTRAINT `fk_games_away_team` FOREIGN KEY (`away_team_id`) REFERENCES `teams` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_games_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_games_home_team` FOREIGN KEY (`home_team_id`) REFERENCES `teams` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_games_venue` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `game_innings`
--
ALTER TABLE `game_innings`
  ADD CONSTRAINT `fk_game_innings_game` FOREIGN KEY (`game_id`) REFERENCES `games` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `player_game_stats`
--
ALTER TABLE `player_game_stats`
  ADD CONSTRAINT `fk_pgs_game` FOREIGN KEY (`game_id`) REFERENCES `games` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pgs_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pgs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `standings`
--
ALTER TABLE `standings`
  ADD CONSTRAINT `fk_standings_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_standings_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `teams`
--
ALTER TABLE `teams`
  ADD CONSTRAINT `fk_teams_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `fk_user_profiles_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `user_tokens`
--
ALTER TABLE `user_tokens`
  ADD CONSTRAINT `fk_user_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
