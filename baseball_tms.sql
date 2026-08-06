-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost
-- Tiempo de generación: 06-08-2026 a las 14:17:12
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
DROP DATABASE IF EXISTS `baseball_tms`;
CREATE DATABASE IF NOT EXISTS `baseball_tms` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
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
(1, 'Categoria A', 'PRIMER FUERZA', 1, '2026-05-13 14:05:12', '2026-05-18 13:10:30'),
(2, 'Categoria B', 'INTERMEDIA', 1, '2026-05-13 14:05:27', '2026-05-18 13:11:03'),
(3, 'Categoria C', 'SEGUNDA FUERZA', 1, '2026-05-13 14:05:40', '2026-05-18 13:10:46');

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
  `status` enum('PROGRAMADO','FINALIZADO','CANCELADO','POSPUESTO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PROGRAMADO',
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Games table';

--
-- Volcado de datos para la tabla `games`
--

INSERT INTO `games` (`id`, `game_date`, `game_time`, `venue_id`, `home_team_id`, `away_team_id`, `home_score`, `away_score`, `innings_played`, `status`, `notes`, `created_by`, `created_at`, `updated_at`) VALUES
(1, '2026-05-18', '16:00:00', 2, 17, 29, 13, 10, 9, 'FINALIZADO', NULL, 1, '2026-05-14 10:37:33', '2026-05-19 08:36:44'),
(2, '2026-05-18', '16:00:00', 3, 25, 20, 13, 14, 9, 'FINALIZADO', NULL, 6, '2026-05-18 13:46:58', '2026-05-19 08:36:04'),
(3, '2026-05-18', '16:00:00', 4, 18, 27, 9, 12, 9, 'FINALIZADO', NULL, 6, '2026-05-18 13:48:39', '2026-05-21 10:14:10'),
(4, '2026-05-18', '16:00:00', 6, 30, 28, 28, 28, 8, 'FINALIZADO', 'PARTIDO EMPATADO', 6, '2026-05-18 13:49:32', '2026-05-21 10:15:19'),
(5, '2026-05-18', '16:00:00', 7, 21, 24, NULL, NULL, NULL, 'POSPUESTO', NULL, 6, '2026-05-18 13:50:50', '2026-05-18 13:50:50'),
(6, '2026-05-19', '16:00:00', 2, 10, 11, 3, 7, 9, 'FINALIZADO', NULL, 6, '2026-05-21 10:17:43', '2026-05-21 10:17:43'),
(7, '2026-05-19', '16:00:00', 3, 9, 12, 9, 17, 9, 'FINALIZADO', NULL, 6, '2026-05-21 10:18:54', '2026-05-21 10:18:54'),
(8, '2026-05-19', '16:00:00', 4, 8, 13, 3, 5, 9, 'FINALIZADO', NULL, 6, '2026-05-21 10:20:07', '2026-05-21 10:20:07'),
(9, '2026-05-19', '16:00:00', 6, 15, 7, 8, 12, 9, 'FINALIZADO', 'PICHER GANADOR OSCAR HERNANDEZ DURAN', 6, '2026-05-21 10:21:25', '2026-05-21 10:45:49'),
(10, '2026-05-19', '16:00:00', 7, 16, 14, 12, 12, 9, 'PROGRAMADO', 'JUEGO EMPATADO', 6, '2026-05-21 10:22:31', '2026-05-21 10:22:43');

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
(1, 'FUERZA ESTATAL', 1, 1, '2026-05-13 14:07:01', '2026-05-18 12:35:18'),
(2, 'BOSTON', 1, 1, '2026-05-13 14:07:14', '2026-05-18 12:35:04'),
(3, 'TESORERIA (A)', 1, 1, '2026-05-13 14:07:23', '2026-05-18 12:37:58'),
(4, 'JUZGADOS', 1, 1, '2026-05-13 16:22:49', '2026-05-18 12:34:18'),
(5, 'INDIVI', 1, 1, '2026-05-13 16:23:28', '2026-05-18 12:33:58'),
(6, 'CORAS', 1, 1, '2026-05-18 11:32:21', '2026-05-18 11:32:21'),
(7, 'INDEPENDENCIA', 2, 1, '2026-05-18 12:38:22', '2026-05-18 12:38:22'),
(8, 'TESORERIA (B)', 2, 1, '2026-05-18 12:38:48', '2026-05-18 12:38:48'),
(9, 'JUBILADOS', 2, 1, '2026-05-18 12:40:02', '2026-05-18 12:40:02'),
(10, 'MARINEROS', 2, 1, '2026-05-18 12:40:21', '2026-05-18 12:40:21'),
(11, 'TALLERES', 2, 1, '2026-05-18 12:40:33', '2026-05-18 12:40:33'),
(12, 'BOSTON OTAY', 2, 1, '2026-05-18 12:40:57', '2026-05-18 12:40:57'),
(13, 'GORILAS', 2, 1, '2026-05-18 12:41:10', '2026-05-18 12:41:10'),
(14, 'EBRIOS', 2, 1, '2026-05-18 12:41:25', '2026-05-18 12:41:25'),
(15, 'ORIOLES', 2, 1, '2026-05-18 12:41:38', '2026-05-18 12:41:38'),
(16, 'EXPOS', 2, 1, '2026-05-18 12:41:51', '2026-05-18 12:41:51'),
(17, 'FORAJIDOS', 3, 1, '2026-05-18 12:43:16', '2026-05-18 12:43:16'),
(18, 'YANKEES MATAMOROS', 3, 1, '2026-05-18 12:43:31', '2026-05-18 13:09:40'),
(19, 'PALETEROS', 3, 1, '2026-05-18 12:43:46', '2026-05-18 12:43:46'),
(20, 'DISTRITO 3', 3, 1, '2026-05-18 12:43:58', '2026-05-18 12:43:58'),
(21, 'BARRANQUITAS', 3, 1, '2026-05-18 12:44:16', '2026-05-18 12:44:16'),
(22, 'BOMBEROS TIJUANA', 3, 1, '2026-05-18 12:44:30', '2026-05-18 12:44:30'),
(23, 'DIABLOS', 3, 1, '2026-05-18 12:44:42', '2026-05-18 12:44:42'),
(24, 'BOMBEROS FORESTALES', 3, 1, '2026-05-18 12:44:57', '2026-05-18 12:44:57'),
(25, 'TORONTO', 3, 1, '2026-05-18 12:45:09', '2026-05-18 12:45:09'),
(26, 'BUROCRATAS', 3, 1, '2026-05-18 12:45:24', '2026-05-18 12:45:24'),
(27, 'DODGERS', 3, 1, '2026-05-18 12:45:43', '2026-05-18 12:45:43'),
(28, 'PANTEONES', 3, 1, '2026-05-18 12:52:25', '2026-05-18 12:52:25'),
(29, 'SEMAFOROS', 3, 1, '2026-05-18 12:52:41', '2026-05-18 12:52:41'),
(30, 'JUAN OJEDA', 3, 1, '2026-05-18 12:53:19', '2026-05-18 12:53:19');

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
(1, 'JMG@gmail.com', '$2y$10$d1attNAU9pIjq6MizhBRNOar8EzL1UOueFJUK3TNdgXWEH/hc0UQW', 'player', 1, '2026-05-17 23:54:46', '2026-05-06 15:34:00', '2026-05-18 13:30:00'),
(2, 'manager@sindicato.com', '$2y$10$4Swp15LcL32IHS/Qx5Wj6.RekBm8LWezMlNjnaatEx9VNi.cIkBnC', 'player', 1, '2026-05-17 23:55:33', '2026-05-13 13:40:36', '2026-05-18 13:26:54'),
(3, 'player@sindicato.com', '$2y$10$.3Bj7eyfSPA21HuFB.XAze3GrzgR99PS4VajUUTzYnw5d4AL9G7QC', 'player', 1, '2026-05-14 10:32:58', '2026-05-13 14:16:07', '2026-05-14 10:32:58'),
(4, 'player2@sindicato.com', '$2y$10$JqXebQ7h/Or83SaQiTf1pOmoS9Rl6avfiN0qQEZ.D1anotevTtJLC', 'manager', 1, '2026-05-28 14:10:53', '2026-05-13 22:08:46', '2026-05-28 14:10:53'),
(5, 'villar@sindicato.com', '$2y$10$e6Lp8uUwz3IjCTTcQZnaAOea9tiMuJdyXgSx4WeukXYoo5/Mf9A/2', 'player', 1, NULL, '2026-05-14 14:05:46', '2026-05-18 13:05:18'),
(6, 'deportes@sindicato.com', '$2y$10$8lIBclcl0X5M.oadri5kMODeqSG5HqIEDjC6oLgFFVPg2rLcbnGaW', 'admin', 1, '2026-08-05 13:38:59', '2026-05-14 15:34:55', '2026-08-05 13:38:59'),
(7, 'JMR@sindicato.com', '$2y$10$iASzpWMEw34Q7bI.F9PlN.tpiQOeJyrplNkQvu3btNrBd8tWcYYJu', 'player', 1, NULL, '2026-05-18 13:33:42', '2026-05-18 13:33:42'),
(9, 'NERC@sindicato.com', '$2y$10$z5D9CHLxYoIaml5n5XAuX./am5jrLrBzaM.nvKdh.HCPIdDPAzXcC', 'player', 1, NULL, '2026-05-18 13:38:43', '2026-05-18 13:38:43'),
(10, 'LCT@sindicato.com', '$2y$10$Rs7BNFVPyZ/3Fvyo/aXx..jqbF2FHZXU3ds6Euiac7VWsQNnNKOLK', 'player', 1, NULL, '2026-05-18 13:41:58', '2026-05-18 13:41:58'),
(11, 'JPM@sindicato.com', '$2y$10$mspdynXZW5lBWBJ/vxFaJeJmEnrU5.18ckNpqsqSZybuF9Pb6DKZq', 'player', 1, NULL, '2026-05-19 08:40:40', '2026-05-19 08:40:40'),
(12, 'JAR@sindicato.com', '$2y$10$lcbZ.1GPbdBRnAxCEDUirukAToT9MBXiTrRoWiL2qHDUGy80Q7Jre', 'player', 1, NULL, '2026-05-19 08:43:54', '2026-05-19 08:43:54'),
(13, 'LJR@sindicato.com', '$2y$10$c3TExdwPhk52XYzeOTO9A.U995CYew1AzTZcYAwTcdeHR9dP136zC', 'player', 1, NULL, '2026-05-19 08:45:58', '2026-05-19 08:45:58'),
(14, 'FJRP@sindicato.com', '$2y$10$CuL1AZ9yoaOhCLD0rXvWv.p6YFkCQUkzSGQPRzKbN4.O5f.MOeHja', 'player', 1, NULL, '2026-05-19 08:56:59', '2026-05-19 08:56:59'),
(15, 'lagm@sindicato.com', '$2y$10$9BS9KBhtlmBzkH0r.ggc9.iGpdERnAa8lmw9tI2aeN13/j200L9oC', 'player', 1, NULL, '2026-05-19 09:06:02', '2026-05-19 09:06:02'),
(16, 'oioc@sindicato.com', '$2y$10$BDugmIkGvF0snk7o.tid1.qvTbiXsIftCleVhBnrNvriLCcYC/SGq', 'player', 1, NULL, '2026-05-19 09:20:27', '2026-05-19 09:20:27'),
(17, 'FSA@sindicato.com', '$2y$10$YgLbUxHO6DUH2CltUSgAUOwYb.z335YMzahkEQE9ycKLzMmj.0GSu', 'player', 1, NULL, '2026-05-19 09:27:52', '2026-05-19 09:27:52'),
(18, 'MAMR@sindicato.com', '$2y$10$/k1cTP6aiftLVvKi2nGKDenuwo7gBtnJ8oT0CtLkvlzWvit8Fgn4C', 'player', 1, NULL, '2026-05-19 09:39:45', '2026-05-19 09:39:45'),
(19, 'LADM@sindicato.com', '$2y$10$4OrFnjoWyNaMQK509v.J/.M1K3WFnbUYaJ4IOLtf6JfVpUpkLcFoi', 'player', 1, NULL, '2026-05-19 09:52:23', '2026-05-19 09:52:23'),
(21, 'MACG@sindicato.com', '$2y$10$tJKkWJyHq3c794mwbBkOoOE6dCUIy8fVaBBiks0ds2zHsVfQhG59.', 'player', 1, NULL, '2026-05-19 10:01:27', '2026-05-19 10:01:27'),
(22, 'ORQ@sindicato.com', '$2y$10$gJkAHJ/lI9RCsCtdURX0teTQj8XL2vfkFO/oQo/xlVKhJrpjhF4zG', 'player', 1, NULL, '2026-05-19 10:10:23', '2026-05-19 10:10:23'),
(23, 'MAAM@sindicato.com', '$2y$10$IJCeiKK03QyZXRLsAYAx0OSZ3LyOpu21faP.98LMiIj2KLoqfrswK', 'player', 1, NULL, '2026-05-19 11:47:57', '2026-05-19 11:47:57'),
(24, 'JJCF@sindicato.com', '$2y$10$KvfQ8AoAYR3xRkSGF0cfB.ozE6mWS2zvusbCjwK4x5hTMXqe18Xnu', 'player', 1, NULL, '2026-05-19 12:20:18', '2026-05-19 12:20:18'),
(25, 'JJGC@sindicato.com', '$2y$10$Bd1As63LyYwhEZwNJ/lVg.Sa3rilFc5vs2o0Fb17hONqMjsHIZ7Mi', 'player', 1, NULL, '2026-05-19 12:22:45', '2026-05-19 12:22:45'),
(26, 'MAJS@sindicato.com', '$2y$10$arNhm805bpUe3COo15Y/ju6q4vTrk1oLdqq2reTHOjR4VGl2ot01q', 'player', 1, NULL, '2026-05-19 13:06:13', '2026-05-19 13:06:13'),
(27, 'JLRB@sindicato.com', '$2y$10$yDU6RjKbMlKYVmrciqYg0OWuaPITsn3srACjNI2RLOYArFjz.WRpy', 'player', 1, NULL, '2026-05-19 13:20:22', '2026-05-19 13:20:22'),
(28, 'JMDH@sindicato.com', '$2y$10$swcKyAtyQt7H2qDyDiABFOgqv7SNawna/ib4fBABZypkRnqAJK0Ve', 'player', 1, NULL, '2026-05-19 13:33:35', '2026-05-19 13:33:35'),
(29, 'IGR@sindicato.com', '$2y$10$FS2.DcCDoYmRGBOpd9ssKefrr0klZ6Xcz.LFES4XyH.NxcQaJSTMy', 'player', 1, NULL, '2026-05-19 13:41:35', '2026-05-19 13:41:35'),
(30, 'EIBQ@sindicato.com', '$2y$10$3xvWDX5NWcVWRxqlCj873eMigR.RAhezbBJJlhcziCz3G2FKKeblK', 'player', 1, NULL, '2026-05-19 13:55:57', '2026-05-19 13:55:57'),
(31, 'mbm@sindicato.com', '$2y$10$aRR5QdIuFcaQ8gu7xserJekEpOwbsQX5U7jywKX2iaq/Upp16Kq2C', 'player', 1, NULL, '2026-05-20 09:58:36', '2026-05-20 09:58:36'),
(32, 'SL@sindicato.com', '$2y$10$W04aEM0AZe5Vc4kmGFPeo.L1g3.iPnJPUQrxDbKLKbgBe51a.VPWm', 'player', 1, NULL, '2026-05-20 10:05:25', '2026-05-20 10:05:25'),
(33, 'ROJ@sindicato.com', '$2y$10$2D.B1iDZQEfiToiUT/aU9OSpNGQBJrQYV5IL3YDIvremA1ee1ByLK', 'player', 1, NULL, '2026-05-20 10:16:26', '2026-05-20 10:16:26'),
(34, 'SHERMAN@sindicato.com', '$2y$10$/J1ZzEEvKk.WwPe2HUn1BuhJY9SBkDE18K/2hyv8dJFMpCnirtnbO', 'player', 1, NULL, '2026-05-20 10:40:16', '2026-05-20 10:40:16'),
(36, 'AVENA@sindicato.com', '$2y$10$9bfsnuX0dg49KBRCVErMJeMPEMXHXJ/wo3V3Wum41fOQ/XAj8FDCC', 'player', 1, NULL, '2026-05-20 10:48:23', '2026-05-20 10:48:23'),
(37, 'ATF@sindicato.com', '$2y$10$naMaSXuvckY8GOQ1Tiu7x.USc7HPZnQ25gDPc.5XdEmsTUaeu4nb6', 'player', 1, NULL, '2026-05-20 11:07:24', '2026-05-20 11:07:24'),
(38, 'hhj@sindicato.com', '$2y$10$Bvmj0QzE/2gTSZDWi9zOJeuFfos.j6W.nMxOkf.3C1PNadIR3JPR.', 'player', 1, NULL, '2026-05-20 11:20:01', '2026-05-20 11:20:01'),
(39, 'HJR@sindicato.com', '$2y$10$1YFojI0BHpvWzD4PJKbMS.wwmNxN3AaWlPBWMmvUFB/JrV6McYwDu', 'player', 1, NULL, '2026-05-20 11:29:30', '2026-05-20 11:29:30'),
(40, 'CGR@sindicato.com', '$2y$10$wE6YBjRn/sbAHZBHTTcny.D8IJxtNOe1rM4xLwn1zXt7Xl0Tduywi', 'player', 1, NULL, '2026-05-20 11:40:46', '2026-05-20 11:40:46'),
(41, 'MIIM@sindicato.com', '$2y$10$bA1eQZIHY/dGA2nl.goHtOcfzGE9dtwVlfNFzeG7p2lIA5gqpbpIq', 'player', 1, NULL, '2026-05-20 11:59:32', '2026-05-20 11:59:32'),
(42, 'ROS@sindicato.com', '$2y$10$CQth9M8yU/SNZ41fjjlYcOOa6zDpDxyxY.XXGOgO0t1y29QM2Lnc6', 'player', 1, NULL, '2026-05-20 12:15:09', '2026-05-20 12:15:09'),
(43, 'RVF@sindicato.com', '$2y$10$FJmWYR2R7jVMkKabPXITOuIJUJVqAc1qlE.nwcA9K7lOV8Hb4DVFi', 'player', 1, NULL, '2026-05-20 12:19:50', '2026-05-20 12:19:50'),
(44, 'SOV@sindicato.com', '$2y$10$CUnPLXigJFdNuqJ3KcVazu0ULH32c0Bo6ssZIrFw4RXTPh5ZbqyPa', 'player', 1, NULL, '2026-05-20 12:56:34', '2026-05-20 12:56:34'),
(45, 'prno@sindicato.com', '$2y$10$sCloQ0pbXKxfOmbMfCaqFO6CDMNqM6IfgXsGf6hzzjOSRMPrOkwTi', 'player', 1, NULL, '2026-05-21 08:54:54', '2026-05-21 08:54:54'),
(46, 'JACL@sindicato.com', '$2y$10$zNu2HCY.pjrXnmSNProgJO1/2lTjmJn/LE4lMwE9b9gXBU73USbTS', 'player', 1, NULL, '2026-05-21 09:00:55', '2026-05-21 09:00:55'),
(47, 'RBNL@sindicato.com', '$2y$10$VELOaCe8BT0z.W7wDCy.quQ3XeQkSBL94hi343pPHzZvs/h9Feffu', 'player', 1, NULL, '2026-05-21 09:20:32', '2026-05-21 09:20:32'),
(48, 'JRAC@sindicato.com', '$2y$10$6Gr8nnW46HUfADBSMOTrzOCbDKk20827j0smHz1SpQ0eqkh4.Bm2m', 'player', 1, NULL, '2026-05-21 09:32:59', '2026-05-21 09:32:59'),
(49, 'AZI@sindicato.com', '$2y$10$fj558coWZNV/59x1IuZeWeXR6wpChciPj4Niyuq8cnATL18bJTxqS', 'player', 1, NULL, '2026-05-21 09:37:39', '2026-05-21 09:37:39'),
(50, 'oacl@sindicato.com', '$2y$10$1mCrV.7z34mFbncj3RkRjuG78wJn4/uhJHwpYFm4eWdahaH4HjBqa', 'player', 1, NULL, '2026-05-21 09:50:24', '2026-05-21 09:50:24'),
(51, 'FALL@sindicato.com', '$2y$10$a0L77q0y.Ic/y7VhaS8hOuuNH8Lc.QmEaGLUjxeX4.b5//Hn/UTty', 'player', 1, NULL, '2026-05-21 10:02:06', '2026-05-21 10:02:06'),
(52, 'LAOS@sindicato.com', '$2y$10$uYlW/GkxjgNmfZsjcDQr8O68qdL0kgJuENYiFYMOaC4zBhtonQ2ai', 'player', 1, NULL, '2026-05-21 10:31:14', '2026-05-21 10:31:14'),
(53, 'JATD@sindicato.com', '$2y$10$MS8aq2GaCqBT9wFQq61asucSuVMugF.O0jUTjKmwPRj.71XIylypq', 'player', 1, NULL, '2026-05-21 10:37:27', '2026-05-21 10:37:27'),
(54, 'BHS@sindicato.com', '$2y$10$WoSJ0roEXS6WyOL6hz72j..SlmMPmX8HZ9K0ax3yhd7HaNknSKQce', 'player', 1, NULL, '2026-05-22 08:31:30', '2026-05-22 08:31:30'),
(55, 'FMJ@sindicato.com', '$2y$10$AsCrK1W.t660I4PJkb8iy.haxF1MiaNK5r7pOfRkBJ8WwTAUcC4UG', 'player', 1, NULL, '2026-05-22 08:35:49', '2026-05-22 08:35:49'),
(56, 'HELO@sindicato.com', '$2y$10$cRQ5HxWXduP.mJCfLGNJK.1MCkZpcVxD4g2TXVDBj7DG3A7w3gr9O', 'player', 1, NULL, '2026-05-22 08:38:48', '2026-05-22 08:38:48'),
(57, 'LCVO@sindicato.com', '$2y$10$3J2/i9eV2fi5pdmF36R9AOKe2bC18r/C0YhW4ZbZ2LSj65YEsxF6.', 'player', 1, NULL, '2026-05-22 08:40:57', '2026-05-22 08:40:57'),
(58, 'JREO@sindicato.com', '$2y$10$IWOiEI0KQ7BXuuvPZSlKbuisfcq645vsZtyYqBRyLo4t1EHT1V60q', 'player', 1, NULL, '2026-05-22 08:42:45', '2026-05-22 08:42:45'),
(59, 'MDO@sindicato.com', '$2y$10$msJ/7W2bGg0ODksqLNvsGeULtKdSBSQDt2o4dLK9VuwXy1E/z6sfe', 'player', 1, NULL, '2026-05-22 08:44:39', '2026-05-22 08:44:39'),
(60, 'JMCL@sindicato.com', '$2y$10$r/wHFjiDYvIGDRl8VloTGejFUaT4vi0xYl1W8xywPRl93In9NHDsy', 'player', 1, NULL, '2026-05-22 08:46:45', '2026-05-22 08:46:45'),
(61, 'VJCP@sindicato.com', '$2y$10$qMyemBPnFB00yQWpNran6eXmpkoG1U.xW97cTyWZ7dGDo4RKEl7vm', 'player', 1, NULL, '2026-05-22 08:49:14', '2026-05-22 08:49:14'),
(62, 'JABP@sindicato.com', '$2y$10$B.c4E/qM3q16kHCBNY6I3.P37PZPkGHFNWa1iY8ewHUD9yyAArc/m', 'player', 1, NULL, '2026-05-22 08:55:53', '2026-05-22 08:55:53'),
(63, 'HDCG@sindicato.com', '$2y$10$21h9Z5p.iUeIw8NCdxLsV.YMArrchh/BszACkoB8JW6CZn/xKewqy', 'player', 1, NULL, '2026-05-22 08:58:36', '2026-05-22 08:58:36'),
(64, 'GDRS@sindicato.com', '$2y$10$llH/h9QDCjhqUbkg.XuK3Of13iWhB2NGIIIpnhxcJ08HgG2/iMN3W', 'player', 1, NULL, '2026-05-22 09:02:16', '2026-05-22 09:02:16'),
(65, 'ASS@sindicato.com', '$2y$10$fkA4XTp7AxFmhT.p8cgqEeRcrXDNuUS/7RbBNTEsx/XCdL2sWWsDi', 'player', 1, NULL, '2026-05-22 09:06:31', '2026-05-22 09:06:31'),
(66, 'JDAA@sindicato.com', '$2y$10$Y/cttB3MoBbS2uRjCqbuuuGbqh9JoXV9249tEVsWIyImN7baBubie', 'player', 1, NULL, '2026-05-22 09:18:03', '2026-05-22 09:18:03'),
(67, 'JAAA@sindicato.com', '$2y$10$bUzEoq9MpgK07SEt55UdoORtr3TXKJD79dOSaC50ycmWI0M5EY9qy', 'player', 1, NULL, '2026-05-22 09:20:33', '2026-05-22 09:20:33'),
(68, 'OVG@sindicato.com', '$2y$10$e4d5Q3KQRZQawBCYzg4F7.Q7xliOSORYtopOj2xqpucytP1bO6N0u', 'player', 1, NULL, '2026-05-22 09:23:12', '2026-05-22 09:23:12'),
(69, 'MAPC@sindicato.com', '$2y$10$cOX6IrG6Iqet4W/QwNqJ8.AhzBNXElw2kKWo.N4/bNZXn1NzG119G', 'player', 1, NULL, '2026-05-22 09:30:03', '2026-05-22 09:30:03'),
(70, 'JFPA@sindicato.com', '$2y$10$HgPDUCeTAIUiS7tOuLTth.7SFfTz14U7GIv0.Ek9pxempsljiZzim', 'player', 1, NULL, '2026-05-22 10:43:03', '2026-05-22 10:43:03'),
(71, 'COSH@sindicato.com', '$2y$10$zg5BrkrQ58AkykldoSGc7O2jR9ykldd0kn/4.xNFlniSZWuuDWsfC', 'player', 1, NULL, '2026-05-22 10:58:49', '2026-05-22 10:58:49'),
(72, 'ASO@sindicato.com', '$2y$10$Qp8s4SpmgazxcTYHTc4OLeUpIyN75uvqyYL6.pUI3Y7nOX3s6cXWu', 'player', 1, NULL, '2026-05-22 11:01:31', '2026-05-22 11:01:31'),
(73, 'LAAR@sindicato.com', '$2y$10$t.lwCvduk4jRwy9ur4IGnuq1Ps.ekOqwwVXYBxkSGcPw08vc4LKTS', 'player', 1, NULL, '2026-05-22 11:09:52', '2026-05-22 11:09:52'),
(74, 'DAVM@sindicato.com', '$2y$10$NlHkhaKC4OGSmcllBBll0.cCT1Sx35WQotI0n43Rovox3h0QuOhHG', 'player', 1, NULL, '2026-05-22 11:12:37', '2026-05-22 11:12:37'),
(75, 'VSJA@sindicato.com', '$2y$10$1QPl/8ZXeBl2ww4YfgPae.6zzp9N8FXkXx6ZdwiNlzjPRhJWXWEd6', 'player', 1, NULL, '2026-05-22 11:15:36', '2026-05-22 11:15:36'),
(76, 'OET@sindicato.com', '$2y$10$3kHTzJZzQix6VHFtw9oDxOD7BOMGEiF1CIfBZ5S.SZUpK1k3oJwnm', 'player', 1, NULL, '2026-05-22 11:19:03', '2026-05-22 11:19:03'),
(77, 'SAVM@sindicato.com', '$2y$10$/26Hmw2M87.0U2tgLxN4MOjCkbNDcn.3eh2Km9yjvL/zcsdxRNN.C', 'player', 1, NULL, '2026-05-22 11:28:47', '2026-05-22 11:28:47'),
(78, 'HILC@sindicato.com', '$2y$10$JvbGyQUELKjgvyZ.bmb33OhqV0XhuG.X5J0o6gTJ1E/bATyN2YAuy', 'player', 1, NULL, '2026-05-22 11:31:55', '2026-05-22 11:31:55'),
(79, 'JLVE@sindicato.com', '$2y$10$JVYip3y5ylndIL1Gzcss2ejl4H3g9RE4Jt6iXr.wUeFM7e9Serdaq', 'player', 1, NULL, '2026-05-22 11:36:49', '2026-05-22 11:36:49'),
(80, 'FRRP@sindicato.com', '$2y$10$OKZ1l5lFt3bTQTgKA/W3t.ArR111Pek6OO5UQWfCfKYD51zef2kkm', 'player', 1, NULL, '2026-05-22 11:39:34', '2026-05-22 11:39:34'),
(81, 'APH@sindicato.com', '$2y$10$wwSUFyAvGUgZ25h3jAOYxOgwFlmiKwDBm6cxnzRP0AyOVK9DTGA1u', 'player', 1, NULL, '2026-05-22 11:42:23', '2026-05-22 11:42:23'),
(82, 'OFAG@sindicato.com', '$2y$10$rGbAq2OmpRldPKgsWAxFEu6GDhfAyLVRr9N8MWHTSqAjmWFORkn6i', 'player', 1, NULL, '2026-05-22 11:44:20', '2026-05-22 11:44:20'),
(83, 'JEPV@sindicato.com', '$2y$10$9Vza40xGpaVkBSafOeB4R.L2fXDdygpO1VnHUPvcjZ9ybOqvMJcwu', 'player', 1, NULL, '2026-05-22 11:47:23', '2026-05-22 11:47:23'),
(84, 'LEPV@sindicato.com', '$2y$10$LEJfXqwLn1JBfvr9EPW.DuFQwgR3C6ASIrDFLuNuIzrB439sjA5TK', 'player', 1, NULL, '2026-05-22 11:50:35', '2026-05-22 11:50:35'),
(85, 'ARHG@sindicato.com', '$2y$10$DowPBalfWjD8CDRvxHAAT.VXXO/1H1UJq/dZjqAfBXIDnRZNIW0A6', 'player', 1, NULL, '2026-05-22 11:55:19', '2026-05-22 11:56:16'),
(86, 'RCV@sindicato.com', '$2y$10$k9pcgek7jbh3E9RR0TfDm.6uJbVkGRAzZD466rUxrioQPOweg42/q', 'player', 1, NULL, '2026-05-22 11:59:54', '2026-05-22 11:59:54'),
(87, 'epz@sindicato.com', '$2y$10$iEyv0DJ18kkzetqn3LC9CuM.xCRhOEmd1kxQ2H0ue2Yr0MFj.Bt7G', 'player', 1, NULL, '2026-05-22 12:31:03', '2026-05-22 12:31:03'),
(88, 'FSDRB@sindicato.com', '$2y$10$EhvloZ7lwb3JfVnYrrSc2.3EisNeJV58yXN79r.3.F2qrRKffTZa6', 'player', 1, NULL, '2026-05-22 12:32:58', '2026-05-22 12:32:58'),
(89, 'IRDRU@sindicato.com', '$2y$10$eP1cJgmOrhxbebLSM86AOeMpHQy2KPamElwx/b/erAmJPaaaIvXyy', 'player', 1, NULL, '2026-05-22 12:35:14', '2026-05-22 12:35:14'),
(90, 'RGH@sindicato.com', '$2y$10$EAf3OeHQhATMzpWkflHG8O8lS5DhZN4ar7zV99KaImvZny7QJdvBW', 'player', 1, NULL, '2026-05-22 12:38:25', '2026-05-22 12:38:25'),
(91, 'JEZ@sindicato.com', '$2y$10$ZZIFNIbo62IQoz9X6smBm.LPF6bdsMXPW6B/VxLctwl8mU2iaWhTW', 'player', 1, NULL, '2026-05-22 13:01:48', '2026-05-22 13:01:48'),
(92, 'AIMA@sindicato.com', '$2y$10$/gaRxr/RZPYEvNk3dWrSTeCxhzOwBsBnG7MrQBrJrxnjR118YQHwi', 'player', 1, NULL, '2026-05-22 13:08:53', '2026-05-22 13:08:53'),
(93, 'ARMG@sindicato.com', '$2y$10$dy2XpKdrfjLgPvBkl7H4uey6YaitImtNsjWeUAqox27NB9RT99Niq', 'player', 1, NULL, '2026-05-22 13:20:15', '2026-05-22 13:20:15'),
(94, 'AM@sindicato.com', '$2y$10$PozngvMe6xXJVjXfEVK2o.5dO.Fsu4zli1I6SHBNynP7W8w/yNkUa', 'player', 1, NULL, '2026-05-22 13:25:41', '2026-05-22 13:25:41'),
(95, 'rr@sindicato.com', '$2y$10$L5SEzh0bg9hohhhCJRShxu9KoCYx8tl2WUjLd3pOsU3NzjmxPYn0C', 'player', 1, NULL, '2026-05-25 08:47:11', '2026-05-25 08:47:11'),
(96, 'GO@sindicato.com', '$2y$10$1sdFpIx1SG2.COYE1d/Kt.d5QxtJPoUcLW5E1zJYuItOA56UEdZ3i', 'player', 1, NULL, '2026-05-25 08:53:28', '2026-05-25 08:53:28'),
(98, 'AC@sindicato.com', '$2y$10$pnaILyOKj98cfmj8P9iz9eBkC84AvkGs/MTIbqt2DD0k7TRpIUlbK', 'player', 1, NULL, '2026-05-25 09:17:30', '2026-05-25 09:17:30'),
(99, 'AG@sindicato.com', '$2y$10$lYwRYLTkP6WKVrTT1AfWeeOmNjPlwJBiMWfxXd0H15kX4pItWlUlG', 'admin', 1, NULL, '2026-05-25 09:21:16', '2026-05-25 09:21:16'),
(100, 'CA@sindicato.com', '$2y$10$/Qr47UYbw7d8vtPTTmfS9es/ORlX5s4KidmJ2ZvIe2jYMcBxGVfqq', 'player', 1, NULL, '2026-05-25 09:23:39', '2026-05-25 09:23:39'),
(102, 'LA@sindicato.com', '$2y$10$5YEEygvOMGq8w3ba16KTdO4eigSx.Sot4NfkeYcjRbOwD7enaMw5W', 'player', 1, NULL, '2026-05-25 09:26:27', '2026-05-25 09:26:27'),
(104, 'JLR@sindicato.com', '$2y$10$N6PsuG7mR1Xe2Sdqijas3OVG6tWTpTTCu3RhWQS6oPaJLQYgYFlS2', 'player', 1, NULL, '2026-05-25 09:30:47', '2026-05-25 09:30:47'),
(105, 'OR@sindicato.com', '$2y$10$LKA3e2J1..ufak3g28gt1.y3303Tek5JJG6qbfOnztk6Wp29HXQ62', 'player', 1, NULL, '2026-05-25 09:37:32', '2026-05-25 09:37:32'),
(106, 'JMMG@sindicato.com', '$2y$10$7sDmNmTK2f27v641EPvfVefpw9Bz6jCv5qGeE6yTBcHBZCUeTVsw2', 'player', 1, NULL, '2026-05-25 09:51:11', '2026-05-25 09:51:11'),
(107, 'AMV@sindicato.com', '$2y$10$2Exyqz4buhBlqkbX5mHv6OGJja3cBqQwOCW4dxtk1zXnnQF.OhVNm', 'player', 1, NULL, '2026-05-25 11:27:31', '2026-05-25 11:27:31'),
(108, 'MM@sindicato.com', '$2y$10$HWrGN1Bld./A/rlR1Eiep.BId1dderJNcv.0nAiAaTUmz3.dq/flW', 'player', 1, NULL, '2026-05-25 11:29:12', '2026-05-25 11:29:12'),
(109, 'MC@sindicato.com', '$2y$10$8vJUBPbfWO1VCD0V6Ub64OzVGYieMTcwNj0y8b4j5GS7sngmV.Pzu', 'player', 1, NULL, '2026-05-25 11:30:58', '2026-05-25 11:30:58'),
(110, 'OM@sindicato.com', '$2y$10$wxGbbw3.lJppbuQ6wCFjg.7EN8lQkUcqWgSeoJ9kJ9XdJAiswVakG', 'player', 1, NULL, '2026-05-25 11:32:44', '2026-05-25 11:32:44'),
(111, 'JBR@sindicato.com', '$2y$10$02r.dYpS8WR4FaBEv5lsZuE5enDaB.gMvTrUJIeeaclF4Xe5HS7wy', 'player', 1, NULL, '2026-05-25 11:37:16', '2026-05-25 11:37:16'),
(112, 'MAMS@sindicato.com', '$2y$10$0juiDzedmbo5/qwddL7vMOtfEBkF05jgP8uYwhLqe7eDcO0dnB1AO', 'player', 1, NULL, '2026-05-25 11:47:33', '2026-05-25 11:56:15'),
(113, 'RAGR@sindicato.com', '$2y$10$g7sOEJQ3m1tsQnoCAIMDQuy30gwBqvrfWSk4jB4lpmJNLUUoc8CFC', 'player', 1, NULL, '2026-05-25 11:54:40', '2026-05-25 11:54:40'),
(114, 'ESO@sindicato.com', '$2y$10$sLIeCRVd1P/5Hx77jQH5.usDtqID8b4dqLfiI0h5qcscLHmnvQ8bK', 'player', 1, NULL, '2026-05-25 12:02:49', '2026-05-25 12:02:49'),
(115, 'AF@sindicato.com', '$2y$10$PsjY2sZCtKCxMm5vBBQpoeb6wVmzNZwoFhmYBb3R9DAK3E0FqeVmK', 'player', 1, NULL, '2026-05-25 12:09:41', '2026-05-25 12:09:41'),
(116, 'ALP@sindicato.com', '$2y$10$JQLl.M5CVHw4/XOG056H/eduBCdcNH/PVk5IvY4OmLF8u4GGq/4Oe', 'player', 1, NULL, '2026-05-25 12:12:37', '2026-05-25 12:12:37'),
(117, 'JEGH@sindicato.com', '$2y$10$SWYrkzQxoemfzMn0kEE03.2AhXNQkcu2ZuG/nrHPbFwfG9ts2wTWa', 'player', 1, NULL, '2026-05-25 12:16:54', '2026-05-25 12:16:54'),
(118, 'ABO@sindicato.com', '$2y$10$T4rB5BemxJBTa3S8/57Xzu4ZpH3c8CimHo/cOy3icAmBdXkUUHAMm', 'player', 1, NULL, '2026-05-25 12:25:27', '2026-05-25 12:25:27'),
(119, 'GG@sindicato.com', '$2y$10$Iwj7cMG5gcSgzGSBJnXqW.RKaM1NJoLaBmK9JF76/Yu.j5/vZVEvm', 'player', 1, NULL, '2026-05-25 12:31:14', '2026-05-25 12:31:14'),
(120, 'MFS@sindicato.com', '$2y$10$3fQUY4LPhxN620VlBX/7QedBO/2wSmuEco26Ic.mR5/dpFfQaUrZm', 'player', 1, NULL, '2026-05-25 12:36:34', '2026-05-25 12:36:34'),
(121, 'vc@sindicato.com', '$2y$10$U.6VxKtxep/bIfVSvRooVOl/otrsT/Gmxm92yOTK919ZECDmB61v2', 'player', 1, NULL, '2026-05-26 10:07:20', '2026-05-26 10:07:20'),
(122, 'AA@sindicato.com', '$2y$10$ufOe4OiwNb0OZW0i2lzrVu3KjSFBjvofuvMZDMIT1/qQ9SJErsJRG', 'player', 1, NULL, '2026-05-26 10:08:36', '2026-05-26 10:08:36'),
(123, 'RVRJ@sindicato.com', '$2y$10$EmM/foY9px7oY/r.Z6qyAeCl4Ze2aN/gdioWf6l9w5LtXD0Gbg7yC', 'player', 1, NULL, '2026-05-26 10:12:46', '2026-05-26 10:12:46'),
(124, 'DDRA@sindicato.com', '$2y$10$r5FMsYOqOKfSS56F7t8OW.Pa8UjsIQnGBv5FXy5Yk0ZfOLwx3d/42', 'player', 1, NULL, '2026-05-26 10:16:17', '2026-05-26 10:16:17'),
(125, 'JAAC@sindicato.com', '$2y$10$Ez05svSLzfehFrlv1gpI1ex0C3acfLL73h4hQPSFerv2SsaIfpBES', 'player', 1, NULL, '2026-05-26 10:20:03', '2026-05-26 10:20:03'),
(126, 'CDTG@sindicato.com', '$2y$10$mh2ke7g7ONF7P8CqXbdBBuHfCi/UpNjV/ldYIYFJA1J.yYTMyOI2y', 'player', 1, NULL, '2026-05-26 10:25:46', '2026-05-26 10:25:46'),
(127, 'JTL@sindicato.com', '$2y$10$78TV6lJWYINqNYVP0u7IoevV6pVeZRDTG/fFOIW.8H5Qb0CYBfvem', 'player', 1, NULL, '2026-05-26 10:28:32', '2026-05-26 10:28:32'),
(128, 'JCTL@sindicato.com', '$2y$10$dkXpsAmNm/NxG5FBJSJrOu2VJxdmjuTUsZx5r8FNdVjApv.mzWtjW', 'player', 1, NULL, '2026-05-26 10:33:15', '2026-05-26 10:33:15'),
(129, 'LGM@sindicato.com', '$2y$10$3lREDRU5.qi6I5GI.bb38eGDQDtHJ1pT/aAOV3URYjWINdqU6H0ce', 'player', 1, NULL, '2026-05-26 10:38:05', '2026-05-26 10:38:05'),
(130, 'AAGR@sindicato.com', '$2y$10$xOe0ef8KdR.68W.HRQOnqOqzmt.Gst6hoitpVvXMKooufo6rTvhjm', 'player', 1, NULL, '2026-05-26 10:41:59', '2026-05-26 10:41:59'),
(131, 'JMTE@sindicato.com', '$2y$10$Qr/Yvv13D/202e2SwONjVOq9Jq3qpgyuCn//eFlPwUzPTmSiCnMZO', 'player', 1, NULL, '2026-05-26 11:51:12', '2026-05-26 11:53:06'),
(132, 'YAA@sindicato.com', '$2y$10$cUj7rqEfg/qlhNg4d/tUieiyCyYgfD9DExYu.NuI1faO7YayfN7.O', 'player', 1, NULL, '2026-05-26 11:54:24', '2026-05-26 11:54:24'),
(133, 'CMAA@sindicato.com', '$2y$10$A3e9KCQMnRxRk2dhM5simeo6vr/p.3xDqRSF6LXBxBhGytMV3UKrW', 'player', 1, NULL, '2026-05-26 12:20:25', '2026-05-26 12:20:25'),
(134, 'ATG@sindicato.com', '$2y$10$iP7wDstx5ynHQ46kO85u8.1R7Bj36He.WxiukytuGpegM0ER..z.e', 'player', 1, NULL, '2026-05-26 12:27:24', '2026-05-26 12:27:24'),
(135, 'JGGP@sindicato.com', '$2y$10$cOn9Knubizcl2NFBc2BrMeE41rvRHBG73XzbdMSTeOijkyec8Y.uu', 'player', 1, NULL, '2026-05-26 12:32:26', '2026-05-26 12:32:26'),
(137, 'FAM@sindicato.com', '$2y$10$WIXMVUbARu3tkpGEzHt2QuUGa8YQygoFwTfbX8kIThMZ2IKUsIpZi', 'player', 1, NULL, '2026-05-26 12:41:10', '2026-05-26 12:41:10'),
(138, 'FJAV@sindicato.com', '$2y$10$cpHyH4UJBg6R4gxBeka2SOhY0Snn9TYczfE6yrkZGWMjZlfmDAwU.', 'player', 1, NULL, '2026-05-26 12:43:42', '2026-05-26 12:43:42'),
(139, 'GAPJ@sindicato.com', '$2y$10$HcI4gLfxSzCV6ZSDNLfibelOgoUw9ryFqcuwHMfKF2fPdeZXL6CcK', 'player', 1, NULL, '2026-05-26 12:47:21', '2026-05-26 12:47:21'),
(140, 'EGBR@sindicato.com', '$2y$10$b3aNLTBJFU2ILkRgWTekiOnp7xl6EGb1ymurV6hgcYKDirbq5iugO', 'player', 1, NULL, '2026-05-26 12:50:24', '2026-05-26 12:50:24'),
(141, 'ANH@sindicato.com', '$2y$10$pT3rKb0iRjts9ZFEv8yXRujwdxkN50VUREOznLOHdETUwqp/6vvJO', 'player', 1, NULL, '2026-05-26 12:55:35', '2026-05-26 12:55:35'),
(142, 'JJPV@sindicato.com', '$2y$10$pMaH8gN2JzubhSTH8FGaLuukANri9xNol3D8CShkWwfg1YokHch9C', 'player', 1, NULL, '2026-05-26 13:00:40', '2026-05-26 13:00:40'),
(143, 'SAOV@sindicato.com', '$2y$10$NXEFQZBhXBG40mDo1EOVXOlvP/iuTpUmiUvGvZxe/NziANRgBvpXS', 'player', 1, NULL, '2026-05-26 13:05:38', '2026-05-26 13:05:38'),
(144, 'JOSG@sindicato.com', '$2y$10$n3jkeCb3FVoR4vpSnWc3QOqICvGfp61bnbKN4pbvHqBMCaVKkgWnW', 'player', 1, NULL, '2026-05-26 13:09:38', '2026-05-26 13:09:38'),
(145, 'JGAC@sindicato.com', '$2y$10$NWp/Vg4p1ie6xNXbnO71e.yT7xiDkUcmLo.6vh1md8KeikJueW4fK', 'player', 1, NULL, '2026-05-26 13:50:08', '2026-05-26 13:50:08'),
(146, 'JMPD@sindicato.com', '$2y$10$N1On75/UIwjX8o0W70vuZONanL/aEO.pyWg5TNHPzb3pMHYK0h3PW', 'player', 1, NULL, '2026-05-27 09:03:56', '2026-05-27 09:03:56'),
(147, 'AAVA@sindicato.com', '$2y$10$hTtgd9qrP/y3X7kzP0odDux9jGkgvn.Wubp0Oprsko.g7N1g0zgcq', 'player', 1, NULL, '2026-05-27 09:11:00', '2026-05-27 09:11:00'),
(148, 'AIDA@sindicato.com', '$2y$10$JlrLSOs7VSr31.L3q1LySOxquHGxHSTbNAOayAUFPa2EbZI.HMg4m', 'player', 1, NULL, '2026-05-27 09:13:02', '2026-05-27 09:13:02'),
(149, 'GVD@sindicato.com', '$2y$10$.xnu28HXEo1lLsrBKZ1Ive89096wxv57Uu8GWS7Dv/UgjGgFzEcle', 'player', 1, NULL, '2026-05-27 09:17:12', '2026-05-27 09:17:12'),
(150, 'CL@sindicato.com', '$2y$10$VUfgVhiiOf7nUgk1/S1tdOd9iIEZ3xpe633kwhFBlbiYh.sOPLIey', 'player', 1, NULL, '2026-05-27 09:24:33', '2026-05-27 09:24:33'),
(151, 'PE@sindicato.com', '$2y$10$8O.MTGUUbc6tY5AC0wkk0.0fjiH6n/K9SUvv5o.QMJQOciQNh26Ra', 'player', 1, NULL, '2026-05-27 09:26:14', '2026-05-27 09:26:14'),
(152, 'ARO@sindicato.com', '$2y$10$bozVGbwjpZWta0ItNGvtNePXKrVzOfB0ZQWs8CWKxG8GK1tNuMnzi', 'player', 1, NULL, '2026-05-27 09:31:12', '2026-05-27 09:31:12'),
(153, 'OHD@sindicato.com', '$2y$10$fIj33HQrHrWv1PZ5edDY9uzAgHpnSfizp1GoAiuN/Cq5d13s5shIK', 'player', 1, NULL, '2026-05-27 09:34:03', '2026-05-27 09:34:03'),
(154, 'JMHC@sindicato.com', '$2y$10$BneL/8ieTkBqTrZr4c7dGumgnjE0xJnkvh4FX5C/0MWONzfwOkpoy', 'player', 1, NULL, '2026-05-27 09:37:08', '2026-05-27 09:37:08'),
(155, 'EAGR@sindicato.com', '$2y$10$y9Aq2Gxap8U6i/8MQ.m6RuFJN24GQ4YQZVNNXpgDRzb15h56AG5OC', 'admin', 1, NULL, '2026-05-27 09:39:18', '2026-05-27 09:39:18'),
(156, 'CGCP@sindicato.com', '$2y$10$1wlpLdYt64ltNdhdDfzvkuncz0xjdFGqw8RuRfHCp.QHDXbAN6b2e', 'player', 1, NULL, '2026-05-27 09:40:54', '2026-05-27 09:40:54'),
(157, 'SCV@sindicato.com', '$2y$10$g9aj6OIXGgqW5KfH38pGdui9od6xjYbQHyuNUdE5Vlhp8HKZgmg/e', 'player', 1, NULL, '2026-05-27 11:20:43', '2026-05-27 11:20:43'),
(158, 'LAI@sindicato.com', '$2y$10$HuFBI6eRNkQlyNKOfHtWk.KQwo5GYXgbZYq/yaQN.NTiBTf2Yrc6S', 'player', 1, NULL, '2026-05-27 11:22:19', '2026-05-27 11:22:19'),
(159, 'FALC@sindicato.com', '$2y$10$1tFnsPqmTJY0tDPg1TNGnuUD.cHo5cPGuSxbJaOcUkrjD3ekxvETC', 'player', 1, NULL, '2026-05-27 11:24:05', '2026-05-27 11:24:05'),
(160, 'SACB@sindicato.com', '$2y$10$36YWy8bDNxRYJkWn5Hm/Uu/msImNB9uT21NCmDJBjwaBu8LR64/TK', 'player', 1, NULL, '2026-05-27 11:25:34', '2026-05-27 11:25:34'),
(161, 'CALR@sindicato.com', '$2y$10$MXhLJzXT.mYeRkBa/l3x7eJgIgXvJyfIqv9fqmsemeN1Mc/q5/8vm', 'player', 1, NULL, '2026-05-27 11:41:14', '2026-05-27 11:41:14'),
(162, 'ETG@sindicato.com', '$2y$10$fouG6P8xehnpS8dpevwo8uum3z2s7Xwh2K8d54n78u0nkIm/LHX7S', 'player', 1, NULL, '2026-05-27 12:17:26', '2026-05-27 12:17:26'),
(163, 'HNVH@sindicato.com', '$2y$10$w7ZlsBA4JllUHU3z0HjnD.0N7Pbm1UhUZydfpWxWLUMy9OQLEdHV2', 'player', 1, NULL, '2026-05-27 12:42:12', '2026-05-27 12:42:12'),
(164, 'MFVP@sindicato.com', '$2y$10$iktzBDggTuKUkMnU3ARy4.YaUyBWlawYqtrI7lM9gC.Va/kF69Kqu', 'player', 1, NULL, '2026-05-27 13:25:50', '2026-05-27 13:25:50'),
(165, 'JLGF@sindicato.com', '$2y$10$PzRJH3ZpZLxj/LIu3NV2ZOkFpr8Oq7EgtkUUfboKgueN97upfZlxW', 'player', 1, NULL, '2026-05-28 09:26:01', '2026-05-28 09:26:01'),
(166, 'JANF@sindicato.com', '$2y$10$UiOwpQ5WVAFsXV1VQMYzlOl5/Y0NbayO3MoZ9NaCtR6CCKZFvWEfa', 'player', 1, NULL, '2026-05-28 09:35:07', '2026-05-28 09:35:07'),
(167, 'JEZS@sindicato.com', '$2y$10$VO9WiMSTo3q92kFueH.7wOOnestN2aImx5NX.27A0rbx25J0Ycp0.', 'player', 1, NULL, '2026-05-28 09:42:42', '2026-05-28 09:42:42'),
(168, 'AAPR@sindicato.com', '$2y$10$Zb4mPXvvUltspBMN8.z1ru4ceza6JVsHRdZ9u.joKzWJlGInajmQy', 'player', 1, NULL, '2026-05-28 09:59:42', '2026-05-28 09:59:42'),
(169, 'BADZ@sindicato.com', '$2y$10$TviHl9XBij1YwXIJB28sRekIi8rVQPHHQKxiqtMatRIdPmOujKvuC', 'player', 1, NULL, '2026-05-28 10:10:44', '2026-05-28 10:10:44'),
(170, 'JCMI@sindicato.com', '$2y$10$IOsBkcTxyM.6Atv.pFCqxuTr57x7M3YloHSzPzmZko6PAmmr4SB9m', 'player', 1, NULL, '2026-05-28 11:43:54', '2026-05-28 11:43:54'),
(171, 'JPMI@sindicato.com', '$2y$10$WNQhGldT4O0AzXBOsfFNleSOyHV.TCegLKgOOgM17ZCldnLL5xMIS', 'player', 1, NULL, '2026-05-28 11:46:58', '2026-05-28 11:46:58'),
(172, 'JLBM@sindicato.com', '$2y$10$ak2y8hvtTE1DeMqlUUtH0enIgiWaVKyWKHtmn1R6llqouLXSXXf6a', 'player', 1, NULL, '2026-05-28 11:50:30', '2026-05-28 11:50:30'),
(175, 'IJMH@sindicato.com', '$2y$10$Z7AMBUMymZUT57Lut1HXB.tE.Mh0RBK6rsCfEnIYShCQvzY8BeYFm', 'player', 1, NULL, '2026-05-28 12:01:42', '2026-05-28 12:01:42'),
(176, 'AMMQ@sindicato.com', '$2y$10$O7.BYRgVuJM7NbKmtI8LZuiZPoqya1zSBZwKuqYW7vM2QJC/E.F46', 'player', 1, NULL, '2026-05-28 12:06:55', '2026-05-28 12:06:55'),
(177, 'JACG@sindicato.com', '$2y$10$xwlfgIDkEBfs59TmoM0BTeC/ioVvDW0lucweonmhgazb8a4Pzunh.', 'player', 1, NULL, '2026-05-28 12:13:45', '2026-05-28 12:13:45'),
(178, 'REPV@sindicato.com', '$2y$10$rvcwIC987ncWmUesemtBbuiTyNaWCz0yveQzwv.MYrNLtwT5MF4QW', 'player', 1, NULL, '2026-05-28 12:20:58', '2026-05-28 12:20:58');

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
  `shirt_size` enum('XS','S','M','L','XL','XXL','XXXL') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pants_size` tinyint(2) UNSIGNED DEFAULT NULL,
  `hat_size` varchar(6) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jersey_number` tinyint(3) UNSIGNED DEFAULT NULL,
  `position` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'P, C, 1B, 2B, 3B, SS, LF, CF, RF, DH, UT',
  `employee_class` enum('BASE','CONFIANZA','CONTRATO','HIJO','INVITADO') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `employee_number` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isstecali_affiliation` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `employee_area` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Extended player/manager profile data';

--
-- Volcado de datos para la tabla `user_profiles`
--

INSERT INTO `user_profiles` (`id`, `user_id`, `team_id`, `first_name`, `paternal_surname`, `maternal_surname`, `birth_date`, `curp`, `phone`, `shirt_size`, `pants_size`, `hat_size`, `jersey_number`, `position`, `employee_class`, `employee_number`, `isstecali_affiliation`, `employee_area`, `created_at`, `updated_at`) VALUES
(1, 1, 18, 'JUAN', 'MARTINEZ', 'GODINEZ', '1991-06-24', 'GOUJ910624HMNDRN01', NULL, NULL, NULL, NULL, NULL, NULL, 'BASE', '6311', NULL, NULL, '2026-05-13 13:36:14', '2026-05-18 13:30:00'),
(2, 2, 18, 'SAMUEL', 'RIOS', 'PEREZ', '1975-01-19', 'RIPS750119HGTSRM03', NULL, NULL, NULL, NULL, NULL, 'INFIELDER', 'CONFIANZA', '5113', NULL, NULL, '2026-05-13 14:10:01', '2026-05-18 13:26:54'),
(3, 3, 18, 'SERGIO', 'VALENZUELA', 'LEPE', '1980-05-10', 'VALS800510HBCLPR08', NULL, NULL, NULL, NULL, 10, 'PITCHER', 'BASE', '5123', NULL, NULL, '2026-05-13 14:19:13', '2026-05-18 13:20:43'),
(4, 4, 18, 'SALVADOR', 'ESCOTO', 'BATISTA', '1969-11-13', 'EOBS691113HBCSTL08', '664 533 25 64', NULL, NULL, NULL, 99, 'MANAGER', 'BASE', '4906', NULL, NULL, '2026-05-13 22:08:46', '2026-05-18 12:58:53'),
(5, 5, 18, 'FABIAN', 'VILLAR', 'FLORES', '1982-06-02', 'VIFF820602HJCLLB08', NULL, NULL, NULL, NULL, 14, 'INFIELDER', 'BASE', '5069', NULL, NULL, '2026-05-14 14:05:46', '2026-05-18 13:05:18'),
(6, 6, NULL, 'Secretaría', 'Deportes', NULL, '1980-01-01', NULL, NULL, 'L', 36, 'XL', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-14 15:34:55', '2026-08-05 13:41:58'),
(7, 7, 18, 'JOSE MANUEL', 'RAMOS', 'GALLEGOS', '1995-01-18', 'RAGM950118HBCMLN08', NULL, NULL, NULL, NULL, NULL, 'INFIELDER', 'BASE', '6096', NULL, NULL, '2026-05-18 13:33:42', '2026-05-18 13:33:42'),
(8, 9, 18, 'NESTOR EFRAIN', 'ROMO', 'CASTRO', '1987-10-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '6399', NULL, NULL, '2026-05-18 13:38:43', '2026-05-18 13:39:13'),
(9, 10, 18, 'LUIS CARLOS', 'TERRAZAS', 'ARROYO', '1970-10-14', NULL, NULL, NULL, NULL, NULL, NULL, 'INFIELDER', 'CONFIANZA', '4796', NULL, NULL, '2026-05-18 13:41:58', '2026-05-18 13:41:58'),
(10, 11, 18, 'JUAN PABLO', 'MORENO', 'MARTINEZ', '1993-05-19', 'MOMJ930519HBCRRN05', NULL, NULL, NULL, NULL, NULL, NULL, 'BASE', '6558', NULL, NULL, '2026-05-19 08:40:40', '2026-05-19 08:40:40'),
(11, 12, 18, 'JESUS ALFREDO', 'RAMOS', 'ALVAREZ', '1980-12-26', 'RAAJ801226HBCMLS05', NULL, NULL, NULL, NULL, NULL, NULL, 'BASE', '5073', NULL, NULL, '2026-05-19 08:43:54', '2026-05-19 08:43:54'),
(12, 13, 18, 'LEONARDO JOSUEN', 'RAMOS', 'CRESPO', '1990-06-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'HIJO', NULL, NULL, NULL, '2026-05-19 08:45:58', '2026-05-19 08:45:58'),
(13, 14, 18, 'FRANCISCO JAVIER', 'ROJAS', 'PACHECO', '1980-03-11', 'ROPF800311HBCJCR04', NULL, NULL, NULL, NULL, NULL, NULL, 'BASE', '5140', NULL, NULL, '2026-05-19 08:56:59', '2026-05-19 08:56:59'),
(14, 15, 18, 'LUIS ALEJANDRO', 'GUERRERO', 'MADERA', '1993-10-21', 'GUML931021HBCRDS08', NULL, NULL, NULL, NULL, NULL, NULL, 'BASE', '6687', NULL, NULL, '2026-05-19 09:06:02', '2026-05-19 09:06:02'),
(15, 16, 18, 'OSCAR IVAN', 'ORTEGA', 'CARMONA', '1992-08-04', 'OECO920804HVZRRS04', NULL, NULL, NULL, NULL, NULL, NULL, 'BASE', '5922', NULL, NULL, '2026-05-19 09:20:27', '2026-05-19 09:20:27'),
(16, 17, 18, 'FILIBERTO', 'DEL SID', 'AGUILAR', '1972-09-12', 'CIAF720912HBCDGL05', NULL, NULL, NULL, NULL, NULL, NULL, 'BASE', '5009', NULL, NULL, '2026-05-19 09:27:52', '2026-05-19 09:27:52'),
(17, 18, 18, 'MIGUEL ANGEL', 'MORALES', 'RAYGOZA', '1993-10-20', 'MORM931020HBCRYG01', NULL, NULL, NULL, NULL, NULL, NULL, 'BASE', '6059', NULL, NULL, '2026-05-19 09:39:45', '2026-05-19 09:39:45'),
(18, 19, 18, 'LUIS ALBERTO', 'DIAZ', 'MORAN', '1997-11-24', 'DIML971124HBCZRS03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-19 09:52:23', '2026-05-19 09:52:23'),
(19, 21, 18, 'MARIO ALBERTO', 'CASTRO', 'GARCIA', '1985-02-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '6003', NULL, NULL, '2026-05-19 10:01:27', '2026-05-19 10:01:27'),
(20, 22, 18, 'OMAR', 'RUIZ', 'QUIROZ BARRIOS', '1988-04-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '6397', NULL, NULL, '2026-05-19 10:10:23', '2026-05-19 10:10:23'),
(21, 23, 18, 'MARCO ANTONIO', 'ALMANZA', 'MORALES', '1974-11-19', 'AAMM741119HBCLRR08', NULL, NULL, NULL, NULL, NULL, NULL, 'BASE', '4954', NULL, NULL, '2026-05-19 11:47:57', '2026-05-19 11:47:57'),
(22, 24, 18, 'JUAN JAHIR', 'CASTILLO', 'FLORES', '1974-11-19', 'CAFJ950108HBCSLN02', NULL, NULL, NULL, NULL, NULL, NULL, 'BASE', '5857', NULL, NULL, '2026-05-19 12:20:18', '2026-05-19 12:20:18'),
(23, 25, 18, 'JOSE JULIO', 'GONZALEZ', 'CASTILLO', '1995-01-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'BASE', '4901', NULL, NULL, '2026-05-19 12:22:45', '2026-05-19 12:22:45'),
(24, 26, 20, 'MARTIN ADOLFO', 'JAUREGUI', 'SALDIVAR', '1997-09-27', 'JASM970927HBCRLR02', NULL, NULL, NULL, NULL, 27, 'OUTFILDER', 'CONTRATO', NULL, NULL, NULL, '2026-05-19 13:06:13', '2026-05-19 13:06:13'),
(25, 27, 20, 'JOSE LUIS', 'ROCHIN', 'BAUTISTA', '1983-10-29', 'ROBJ831029HBCPVS03', NULL, NULL, NULL, NULL, 48, 'INFIELDER', 'BASE', '6104', NULL, NULL, '2026-05-19 13:20:22', '2026-05-19 13:20:22'),
(26, 28, 20, 'JOSE MANUEL', 'DOLORES', 'HERNANDEZ', '1993-03-31', 'DOHM930331HBCLRN01', NULL, NULL, NULL, NULL, 20, 'OUTFILDER', 'BASE', '6674', NULL, NULL, '2026-05-19 13:33:35', '2026-05-19 13:33:35'),
(27, 29, 20, 'ISMAEL', 'GONZALEZ', 'ROBLES', '1975-05-02', 'GORI750502HBCNBS02', NULL, NULL, NULL, NULL, 75, 'PITCHER', 'BASE', '5346', NULL, NULL, '2026-05-19 13:41:35', '2026-05-19 13:41:35'),
(28, 30, 20, 'EDGAR IVAN', 'BUSTAMANTE', 'QUINTERO', '2001-02-09', 'BUQE010209HSLSNDA6', NULL, NULL, NULL, NULL, NULL, 'INFIELDER', 'INVITADO', NULL, NULL, NULL, '2026-05-19 13:55:57', '2026-05-19 13:55:57'),
(29, 31, 20, 'MAXIMILIANO', 'MENDOZA', 'BELTRAN', '1996-01-16', 'MEBM960116HBCNLX05', NULL, NULL, NULL, NULL, 13, 'INFIELDER', 'BASE', NULL, NULL, NULL, '2026-05-20 09:58:36', '2026-05-20 09:58:36'),
(30, 32, 20, 'SEVERIANO', 'LOPEZ', 'ADAME', '1979-07-02', 'LOAS790702HBCPDV09', NULL, NULL, NULL, NULL, 68, 'INFIELDER', 'BASE', NULL, NULL, 'CESPT', '2026-05-20 10:05:25', '2026-05-28 09:04:37'),
(31, 33, 20, 'RIGOBERTO', 'ORTEGA', 'OSORIO', '1972-08-19', 'OEOR720819HVZRSG09', NULL, NULL, NULL, NULL, 6, 'PITCHER', 'BASE', NULL, NULL, NULL, '2026-05-20 10:16:26', '2026-05-20 10:16:26'),
(32, 34, 20, 'FRANCISCO MARTIN', 'HUERTA', 'MARQUEZ', '1971-01-27', 'HUMF710127HJCRRR08', NULL, NULL, NULL, NULL, NULL, 'INFIELDER', 'BASE', NULL, NULL, NULL, '2026-05-20 10:40:17', '2026-05-20 10:40:17'),
(33, 36, 20, 'CARLOS', 'AVENA', 'LOPEZ', '2001-11-15', 'AELC011115HBCVPRA2', NULL, NULL, NULL, NULL, 17, 'OUTFILDER', 'INVITADO', NULL, NULL, NULL, '2026-05-20 10:48:23', '2026-05-20 10:48:23'),
(34, 37, 20, 'ARTURO', 'TORRES', 'FLORES', '1972-10-05', 'TOFA721005HBCRLR01', NULL, NULL, NULL, NULL, 10, 'INFIELDER', NULL, NULL, NULL, NULL, '2026-05-20 11:07:24', '2026-05-20 11:07:24'),
(35, 38, 20, 'JOSE', 'HUERTA', 'HERNANDEZ', '2001-05-29', 'HUHJ010529HVZRRSA6', NULL, NULL, NULL, NULL, 39, 'INFIELDER', NULL, NULL, NULL, NULL, '2026-05-20 11:20:01', '2026-05-20 11:20:01'),
(36, 39, 20, 'ROBERTO', 'HERNANDEZ', 'JARAMILLO', '1990-06-09', 'HEJR900609HBCRRB09', NULL, NULL, NULL, NULL, 4, NULL, 'BASE', NULL, NULL, NULL, '2026-05-20 11:29:30', '2026-05-20 11:29:30'),
(37, 40, 20, 'CHRISTIAN', 'GUTIERREZ', 'RAMIREZ', '1983-04-22', 'GURC830422HBCTMH00', NULL, NULL, NULL, NULL, 19, 'INFIELDER', 'BASE', '5670', NULL, 'CESPT', '2026-05-20 11:40:46', '2026-05-28 09:01:36'),
(38, 41, 20, 'IKER MONIR', 'MIRANDA', 'IBARRA', '1974-05-04', 'MIII740504HBCRBK00', NULL, NULL, NULL, NULL, 23, 'OUTFILDER', NULL, NULL, NULL, NULL, '2026-05-20 11:59:32', '2026-05-20 11:59:32'),
(39, 42, 20, 'RICARDO', 'ORTEGA', 'SANDOVAL', '1970-04-03', 'OESR700403HJCRNC00', NULL, NULL, NULL, NULL, NULL, 'INFIELDER', 'BASE', NULL, NULL, 'CESPT', '2026-05-20 12:15:09', '2026-05-27 12:29:12'),
(40, 43, 20, 'RAMON', 'VILLALOBOS', 'FLORES', '1988-07-13', 'VIFR880713HBCLLM08', NULL, NULL, NULL, NULL, 54, 'OUTFILDER', NULL, NULL, NULL, NULL, '2026-05-20 12:19:50', '2026-05-20 12:19:50'),
(41, 44, 20, 'SERGIO', 'OCHOA', 'VARGAS', '1965-02-27', 'OOVS650227HJCCRR07', NULL, NULL, NULL, NULL, 98, 'INFIELDER', 'BASE', NULL, NULL, 'CESPT', '2026-05-20 12:56:35', '2026-05-27 12:27:54'),
(42, 45, 7, 'PEDRO ROBERTO', 'NAVARRETE', 'ORTIZ', '1984-04-12', NULL, NULL, NULL, NULL, NULL, 13, 'INFIELDER', 'BASE', '5681', NULL, NULL, '2026-05-21 08:54:54', '2026-05-21 08:54:54'),
(43, 46, 7, 'JULIO ARNOLDO', 'CASTRO', 'LOPEZ', '1969-11-18', 'CALJ691118HSLSPL00', NULL, NULL, NULL, NULL, 19, 'PITCHER', 'BASE', NULL, NULL, NULL, '2026-05-21 09:00:55', '2026-05-21 09:18:15'),
(44, 47, 7, 'ROBERTO BENJAMIN', 'NAVARRETE', 'LOPEZ', '2001-02-18', 'NALR100218HBCVPBA0', NULL, NULL, NULL, NULL, 18, 'INFIELDER', 'HIJO', NULL, NULL, NULL, '2026-05-21 09:20:32', '2026-05-21 09:20:32'),
(45, 48, 7, 'JOSEPH RODOLFO', 'ALVAREZ', 'CARDENAS', '2002-06-19', 'AACJ020619HSLLRSA1', NULL, NULL, NULL, NULL, 8, 'INFIELDER', 'CONTRATO', NULL, NULL, NULL, '2026-05-21 09:32:59', '2026-05-21 09:32:59'),
(46, 49, 7, 'ADOLFO', 'ZAVALA', 'IBARRA', '1971-03-01', 'ZAIA710301HBCVBD03', NULL, NULL, NULL, NULL, 10, 'INFIELDER', 'BASE', '4752', NULL, NULL, '2026-05-21 09:37:39', '2026-05-21 09:37:39'),
(47, 50, 7, 'OMAR ARNOLDO', 'CASTRO', 'CABRERA', '1995-07-01', 'CXCO950701HBCSBM02', NULL, NULL, NULL, NULL, 4, 'INFIELDER', 'BASE', NULL, NULL, NULL, '2026-05-21 09:50:24', '2026-05-21 09:50:24'),
(48, 51, 7, 'FRANKLIN ARMANDO', 'LOPEZ', 'LOPEZ', '1970-07-10', 'LOLF700710HSLPPR08', NULL, NULL, NULL, NULL, 24, 'PITCHER', 'BASE', NULL, NULL, NULL, '2026-05-21 10:02:06', '2026-05-21 10:02:06'),
(49, 52, 7, 'LUIS ALBERTO', 'OCHOA', 'SANCHEZ', '1979-08-19', 'OOSL790819HBCCNS08', NULL, NULL, NULL, NULL, NULL, NULL, 'BASE', NULL, NULL, NULL, '2026-05-21 10:31:14', '2026-05-21 10:31:14'),
(50, 53, 7, 'JOSE ANGEL', 'TORRES', 'DUARTE', '1968-02-05', 'TODA680205HSRRRN04', NULL, NULL, NULL, NULL, 23, 'INFIELDER', 'BASE', '4255', NULL, 'CESPT', '2026-05-21 10:37:27', '2026-05-28 10:03:45'),
(51, 54, 22, 'BRAULIO', 'HUERTA', 'SANDOVAL', '1975-01-10', 'HUSB750110HBCRNR03', NULL, NULL, NULL, NULL, 29, 'INFIELDER', 'BASE', '14010163', NULL, NULL, '2026-05-22 08:31:30', '2026-05-22 08:31:30'),
(52, 55, 22, 'JULIAN', 'FRIAS', 'MANRIQUE', '1971-03-18', NULL, NULL, NULL, NULL, NULL, 15, NULL, 'INVITADO', NULL, NULL, NULL, '2026-05-22 08:35:49', '2026-05-22 08:35:49'),
(53, 56, 22, 'HECTOR ENRIQUE', 'LOPEZ', 'OSUNA', '2001-01-01', NULL, NULL, NULL, NULL, NULL, 255, 'OUTFILDER', 'BASE', NULL, '96734', NULL, '2026-05-22 08:38:48', '2026-05-22 08:38:48'),
(54, 57, 22, 'LUIS CESAR', 'VERJAN', 'OBEZO', '1999-01-01', NULL, NULL, NULL, NULL, NULL, 25, NULL, 'BASE', NULL, '53391', NULL, '2026-05-22 08:40:57', '2026-05-22 08:40:57'),
(55, 58, 22, 'JUAN RAMON', 'ESPINOZA', 'OCHOA', '1976-12-26', NULL, NULL, NULL, NULL, NULL, 12, 'INFIELDER', NULL, NULL, NULL, NULL, '2026-05-22 08:42:45', '2026-05-22 08:42:45'),
(56, 59, 22, 'MANUEL', 'DELGADO', 'ORTIZ', '1971-06-06', NULL, NULL, NULL, NULL, NULL, 36, 'INFIELDER', NULL, NULL, NULL, NULL, '2026-05-22 08:44:39', '2026-05-22 08:44:39'),
(57, 60, 22, 'JUAN MOISES', 'CARBALLO', 'LUCERO', '1990-01-01', NULL, NULL, NULL, NULL, NULL, 182, NULL, 'BASE', NULL, '52126', NULL, '2026-05-22 08:46:45', '2026-05-22 08:46:45'),
(58, 61, 22, 'VICTOR JAVIER', 'CAMPOS', 'PLANILLAS', '1975-06-21', 'CAPV750621HBCMLC05', NULL, NULL, NULL, NULL, 19, NULL, 'BASE', NULL, NULL, NULL, '2026-05-22 08:49:14', '2026-05-22 08:49:14'),
(59, 62, 22, 'JESUS ANDRES', 'BERUMEN', 'PEREZ', '1997-11-22', NULL, NULL, NULL, NULL, NULL, 32, 'OUTFILDER', 'CONFIANZA', NULL, NULL, NULL, '2026-05-22 08:55:53', '2026-05-22 08:55:53'),
(60, 63, 22, 'HANSEL DAMIAN', 'CAMPOS', 'GALARZA', '2013-04-24', 'CAGH130424HBCMLNA2', NULL, NULL, NULL, NULL, 22, 'OUTFILDER', 'HIJO', NULL, '41050163', NULL, '2026-05-22 08:58:36', '2026-05-22 08:58:36'),
(61, 64, 22, 'GUSTAVO DAVID', 'RIVERA', 'SMITH', '1975-09-11', NULL, NULL, NULL, NULL, NULL, 3, NULL, 'BASE', NULL, '060627', NULL, '2026-05-22 09:02:16', '2026-05-22 09:02:16'),
(62, 65, 22, 'ADRIAN', 'SALAZAR', 'SANCHEZ', '1985-10-07', 'SASA851007HBCLND01', NULL, NULL, NULL, NULL, 7, NULL, NULL, NULL, NULL, NULL, '2026-05-22 09:06:31', '2026-05-22 09:06:31'),
(63, 66, 22, 'JUAN DIEGO', 'ARMENTA', 'AVALOS', '1992-11-13', 'AEAJ921113HSLRVN03', NULL, NULL, NULL, NULL, 16, 'INFIELDER', NULL, NULL, NULL, NULL, '2026-05-22 09:18:03', '2026-05-22 09:18:03'),
(64, 67, 22, 'JOSE ANGEL', 'ARMENTA', 'AVALOS', '2002-04-17', 'AEAA020417HSLRVNA7', NULL, NULL, NULL, NULL, 8, NULL, NULL, NULL, NULL, NULL, '2026-05-22 09:20:33', '2026-05-22 09:20:33'),
(65, 68, 22, 'OLIVER', 'VILLALOBOS', 'GONZALEZ', '1979-12-24', 'VIGO791224HBCLNL07', NULL, NULL, NULL, NULL, 68, NULL, NULL, NULL, NULL, NULL, '2026-05-22 09:23:12', '2026-05-22 09:23:12'),
(66, 69, 22, 'MANUEL ALBERTO', 'PACHECO', 'CASTRO', '1995-09-20', 'PACM950920HBCCSN00', NULL, NULL, NULL, NULL, 26, NULL, 'BASE', '04010603', '150387', NULL, '2026-05-22 09:30:03', '2026-05-22 09:30:03'),
(67, 70, 22, 'JOSE FELIX', 'PACHECO', 'AGUIAR', '1972-02-14', 'PAAF740214HNTCGL05', NULL, NULL, NULL, NULL, 25, NULL, NULL, NULL, NULL, NULL, '2026-05-22 10:43:03', '2026-05-22 10:43:03'),
(68, 71, 17, 'CRISTHIAN OCTAVIO', 'SARABIA', 'HERNANDEZ', '1976-03-20', 'SAHC760320HSLRRR06', NULL, NULL, NULL, NULL, 15, NULL, 'BASE', NULL, NULL, NULL, '2026-05-22 10:58:49', '2026-05-22 10:58:49'),
(69, 72, 17, 'ALEXIS', 'SARABIA', 'OROZCO', '1999-08-16', 'SAOA990816HBCRRL03', NULL, NULL, NULL, NULL, 15, 'INFIELDER', 'CONFIANZA', '14050272', NULL, NULL, '2026-05-22 11:01:32', '2026-05-22 11:01:32'),
(70, 73, 17, 'LUIS ALBERTO', 'ARCE', 'RAMIREZ', '1990-12-15', 'AERL901215HBCRMS04', NULL, NULL, NULL, NULL, NULL, '25', 'BASE', '1401074', NULL, NULL, '2026-05-22 11:09:52', '2026-05-22 11:09:52'),
(71, 74, 17, 'DANIEL ALEJANDRO', 'VIDAL', 'MENCHACA', '1970-10-30', 'VIMD071030HNEDNNA1', NULL, NULL, NULL, NULL, 31, NULL, NULL, NULL, NULL, NULL, '2026-05-22 11:12:37', '2026-05-22 11:12:37'),
(72, 75, 17, 'JORGE ARMANDO', 'VERONICA', 'SALAS', '1985-04-30', 'VESJ850430HBCRLR03', NULL, NULL, NULL, NULL, 42, 'OUTFILDER', 'CONFIANZA', '14020128', NULL, NULL, '2026-05-22 11:15:36', '2026-05-22 11:15:36'),
(73, 76, 17, 'OMAR', 'ESTRADA', 'DEL TORO', '1999-07-03', 'EATO990703HBCSRM08', NULL, NULL, NULL, NULL, 9, 'INFIELDER', 'INVITADO', NULL, NULL, NULL, '2026-05-22 11:19:03', '2026-05-22 11:19:03'),
(74, 77, 17, 'SERGIO ARTURO', 'VIDAL', 'MARQUEZ', '1976-07-28', 'VIMS760728HBCDRR00', NULL, NULL, NULL, NULL, 65, NULL, 'INVITADO', NULL, NULL, NULL, '2026-05-22 11:28:47', '2026-05-22 11:28:47'),
(75, 78, 17, 'HECTOR ISRAEL', 'LOPEZ', 'CASTILLO', '1975-02-16', 'LOCH750216HDFPSC02', NULL, NULL, NULL, NULL, 5, NULL, 'BASE', NULL, NULL, NULL, '2026-05-22 11:31:55', '2026-05-22 11:31:55'),
(76, 79, 17, 'JORGE LUIS', 'VALVERDE', 'ESCARCEGA', '1976-11-14', 'VAEJ761114HBCLSR00', NULL, NULL, NULL, NULL, 3, NULL, 'CONFIANZA', '14010698', NULL, NULL, '2026-05-22 11:36:49', '2026-05-22 11:36:49'),
(77, 80, 17, 'FELIX RODOLFO', 'RAMIREZ', 'PEREZ', '1970-01-01', NULL, NULL, NULL, NULL, NULL, 6, NULL, NULL, NULL, '23398', NULL, '2026-05-22 11:39:34', '2026-05-22 11:39:34'),
(78, 81, 17, 'AGUSTIN', 'PELAYO', 'HERNANDEZ', '1975-10-25', 'PEHA751025HBCLRG02', NULL, NULL, NULL, NULL, 68, NULL, 'BASE', NULL, NULL, NULL, '2026-05-22 11:42:23', '2026-05-22 11:42:23'),
(79, 82, 17, 'OMAR FIDENCIO', 'ALANIZ', 'GONZALEZ', '1982-06-16', 'AAGO820616HBCLNM03', NULL, NULL, NULL, NULL, 2, NULL, 'CONTRATO', NULL, NULL, NULL, '2026-05-22 11:44:20', '2026-05-22 11:44:20'),
(80, 83, 17, 'JOSE ENRIQUE', 'PEREZ', 'VALDEZ', '1970-01-01', NULL, NULL, NULL, NULL, NULL, 10, NULL, NULL, NULL, NULL, NULL, '2026-05-22 11:47:23', '2026-05-22 11:47:23'),
(81, 84, 17, 'LUIS ENRIQUE', 'PEREZ', 'VITELA', '1994-11-04', 'PEVL941104HBCRTS08', NULL, NULL, NULL, NULL, 10, NULL, 'CONFIANZA', '14050266', '150382', NULL, '2026-05-22 11:50:35', '2026-05-22 11:51:12'),
(82, 85, 17, 'ANGEL RICARDO', 'HERNANDEZ', 'GARCIA', '1986-12-27', 'HEGA861227HBCRRN07', NULL, NULL, NULL, NULL, 5, NULL, NULL, NULL, NULL, NULL, '2026-05-22 11:55:19', '2026-05-22 11:55:19'),
(83, 86, 17, 'RAFAEL', 'CARRILLO', 'VENEGAS', '1974-10-24', 'CAVR741024HBCRNF02', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, '2026-05-22 11:59:54', '2026-05-22 12:00:07'),
(84, 87, 17, 'EFRAIN', 'PEÑA', 'ZAMORA', '1998-11-24', 'PEZE981124HBCXMF01', NULL, NULL, NULL, NULL, 35, NULL, 'CONFIANZA', NULL, NULL, NULL, '2026-05-22 12:31:03', '2026-05-22 12:31:03'),
(85, 88, 17, 'FRANCISCO SERVANDO', 'DEL REAL', 'BAUTISTA', '1970-01-01', NULL, NULL, NULL, NULL, NULL, 76, NULL, NULL, NULL, '93038', NULL, '2026-05-22 12:32:58', '2026-05-22 12:32:58'),
(86, 89, 17, 'IAN REY', 'DEL REAL', 'URZUA', '2010-01-02', 'REUI100102HBCLRNA8', NULL, NULL, NULL, NULL, 14, NULL, 'HIJO', NULL, '40093038', NULL, '2026-05-22 12:35:14', '2026-05-22 12:35:14'),
(87, 90, 17, 'RAMON', 'GONZALEZ', 'HERNANDEZ', '1972-02-11', 'GOHR720211HBCNRM02', NULL, NULL, NULL, NULL, 8, NULL, 'BASE', '14010643', NULL, NULL, '2026-05-22 12:38:25', '2026-05-22 12:38:25'),
(88, 91, 25, 'JORGE EDUARDO', 'ZENDEJAS', 'BURGUEÑO', '2000-01-01', NULL, NULL, NULL, NULL, NULL, 14, 'INFIELDER', 'BASE', '161205', NULL, NULL, '2026-05-22 13:01:48', '2026-05-22 13:01:48'),
(89, 92, 25, 'ANTONIO ISRAEL', 'MARTINEZ', 'ACOSTA', '2003-10-04', 'MAAA031004HBCRCNA5', NULL, NULL, NULL, NULL, 4, 'INFIELDER', 'BASE', '23010070', NULL, NULL, '2026-05-22 13:08:53', '2026-05-22 13:08:53'),
(90, 93, 25, 'ANTONIO RAFAEL', 'MARTINEZ', 'GARCIA', '1983-10-26', 'MAGA831026HBCRRN05', NULL, NULL, NULL, NULL, 0, NULL, 'BASE', '16050246', NULL, NULL, '2026-05-22 13:20:15', '2026-05-22 13:20:15'),
(91, 94, 25, 'ANTONIO', 'MORENO', NULL, '1995-12-22', 'MODA951222HBCRRN02', NULL, NULL, NULL, NULL, 17, NULL, NULL, NULL, NULL, NULL, '2026-05-22 13:25:41', '2026-05-22 13:25:41'),
(92, 95, 25, 'RODRIGO', 'RIVERA', NULL, '2001-01-01', NULL, NULL, NULL, NULL, NULL, 99, NULL, NULL, NULL, NULL, NULL, '2026-05-25 08:47:11', '2026-05-25 08:47:11'),
(93, 96, 25, 'GERARDO', 'OLIVARES', NULL, '2001-01-01', NULL, NULL, NULL, NULL, NULL, 10, NULL, NULL, NULL, NULL, NULL, '2026-05-25 08:53:29', '2026-05-25 08:53:29'),
(94, 98, 25, 'ALFREDO', 'CEJA', NULL, '2001-01-01', NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, '2026-05-25 09:17:30', '2026-05-25 09:17:30'),
(95, 99, 25, 'ALEJANDRO', 'GARCIA', NULL, '2000-01-01', NULL, NULL, NULL, NULL, NULL, 19, NULL, NULL, NULL, NULL, NULL, '2026-05-25 09:21:16', '2026-05-25 09:21:16'),
(96, 100, 25, 'CESAR', 'ACOSTA', NULL, '2000-01-01', NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, NULL, NULL, NULL, '2026-05-25 09:23:39', '2026-05-25 09:23:39'),
(97, 102, 25, 'LUIS', 'AGUIRRE', NULL, '2001-01-01', NULL, NULL, NULL, NULL, NULL, 13, NULL, NULL, NULL, NULL, NULL, '2026-05-25 09:26:27', '2026-05-25 09:26:27'),
(98, 104, 25, 'JOSE LUIS', 'RUVALCABA', 'AGUNDEZ', '2001-01-01', NULL, NULL, NULL, NULL, NULL, 88, NULL, 'BASE', '16120789', NULL, NULL, '2026-05-25 09:30:47', '2026-05-25 09:30:47'),
(99, 105, 25, 'OLIVER', 'RUVALCABA', NULL, '2001-01-01', NULL, NULL, NULL, NULL, NULL, 77, NULL, NULL, NULL, NULL, NULL, '2026-05-25 09:37:32', '2026-05-25 09:37:32'),
(100, 106, 25, 'JESUS MIGUEL', 'MARTINEZ', 'GARCIA', '2001-01-01', NULL, NULL, NULL, NULL, NULL, 27, NULL, NULL, NULL, NULL, NULL, '2026-05-25 09:51:11', '2026-05-25 09:51:11'),
(101, 107, 25, 'ANTONIO', 'MARTINEZ', 'VALADEZ', '2001-01-01', NULL, NULL, NULL, NULL, NULL, 27, NULL, NULL, NULL, NULL, NULL, '2026-05-25 11:27:31', '2026-05-25 11:27:31'),
(102, 108, 25, 'MARTIN', 'MORA', NULL, '2001-01-01', NULL, NULL, NULL, NULL, NULL, 100, NULL, NULL, NULL, NULL, NULL, '2026-05-25 11:29:12', '2026-05-25 11:29:12'),
(103, 109, 25, 'MIGUEL', 'CONTRERAS', NULL, '2001-01-01', NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, NULL, NULL, NULL, '2026-05-25 11:30:58', '2026-05-25 11:30:58'),
(104, 110, 25, 'OMAR', 'MORENO', NULL, '2002-01-01', NULL, NULL, NULL, NULL, NULL, 99, NULL, NULL, NULL, NULL, NULL, '2026-05-25 11:32:45', '2026-05-25 11:32:45'),
(105, 111, 25, 'JESUS', 'BANUELOS', 'RIVA', '2001-01-01', NULL, NULL, NULL, NULL, NULL, 80, NULL, NULL, NULL, NULL, NULL, '2026-05-25 11:37:16', '2026-05-25 11:37:16'),
(106, 112, 28, 'MARIO ALBERTO', 'MONTOYA', 'SMITH', '1969-06-22', 'MOSM690622HBCNMR08', NULL, NULL, NULL, NULL, 17, NULL, 'BASE', '2201340', NULL, NULL, '2026-05-25 11:47:33', '2026-05-25 11:56:15'),
(107, 113, 28, 'RAMON ALBERTO', 'GARCIA', 'RODRIGUEZ', '1992-07-17', 'GARR920717HBCRDM09', NULL, NULL, NULL, NULL, 16, NULL, 'BASE', '23010011', NULL, NULL, '2026-05-25 11:54:41', '2026-05-25 11:54:41'),
(108, 114, 28, 'ERNESTO', 'SANCHEZ', 'ONTIVEROS', '1979-04-03', 'SAOE790403HBCNNR06', NULL, NULL, NULL, NULL, 26, NULL, 'BASE', '2301165', '65597', NULL, '2026-05-25 12:02:49', '2026-05-25 12:02:49'),
(109, 115, 28, 'ALEXANDER', 'FREGOZO', NULL, '1988-05-07', 'VEFA880507HBCRRN00', NULL, NULL, NULL, NULL, 13, NULL, 'BASE', '23010043', NULL, NULL, '2026-05-25 12:09:41', '2026-05-25 12:09:41'),
(110, 116, 28, 'ALEJANDRO', 'PEÑA', 'HERNANDEZ', '2001-01-01', NULL, NULL, NULL, NULL, NULL, 0, NULL, 'INVITADO', NULL, NULL, NULL, '2026-05-25 12:12:38', '2026-05-25 12:12:38'),
(111, 117, 28, 'JOSE EDUARDO', 'GUZMAN', 'HERNANDEZ', '1993-08-16', 'GUHE930816HBCZRD00', NULL, NULL, NULL, NULL, 51, NULL, 'BASE', '23010030', NULL, NULL, '2026-05-25 12:16:54', '2026-05-25 12:16:54'),
(112, 118, 28, 'ARTURO', 'BALTAZAR', 'ONTIVEROS', '2000-11-11', 'BAOA001111HBCLNRA0', NULL, NULL, NULL, NULL, 54, NULL, 'BASE', '01071047', NULL, NULL, '2026-05-25 12:25:27', '2026-05-25 12:25:27'),
(113, 119, 28, 'GUSTAVO', 'GUZMAN', NULL, '2000-01-01', NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, '2026-05-25 12:31:14', '2026-05-25 12:31:14'),
(114, 120, 28, 'MARCELO', 'FRANCO', 'SANCHEZ', '1975-10-30', 'FASM751030HBCRNR00', NULL, NULL, NULL, NULL, 11, NULL, 'BASE', '23010207', NULL, NULL, '2026-05-25 12:36:35', '2026-05-25 12:36:35'),
(115, 121, 28, 'VICTOR', 'CERVANTES', NULL, '1993-08-09', 'CEMV930809HBCRRC07', NULL, NULL, NULL, NULL, 9, NULL, 'BASE', '23010077', NULL, NULL, '2026-05-26 10:07:20', '2026-05-26 10:07:20'),
(116, 122, 28, 'AARON', 'AGUILAR', NULL, '2001-01-01', NULL, NULL, NULL, NULL, NULL, 23, NULL, 'HIJO', NULL, NULL, NULL, '2026-05-26 10:08:36', '2026-05-26 10:09:02'),
(117, 123, 28, 'RAUL VICENTE', 'ROMERO', 'JIMENEZ', '1957-07-19', 'ROJR570719HSRMML00', NULL, NULL, NULL, NULL, 6, NULL, 'BASE', '22010341', NULL, NULL, '2026-05-26 10:12:46', '2026-05-26 10:12:46'),
(118, 124, 28, 'DIKEMBE DANIEL', 'ROMERO', 'AYALA', '2000-01-10', 'ROAD000110HBCMYRA0', NULL, NULL, NULL, NULL, 19, NULL, 'BASE', '23010060', NULL, NULL, '2026-05-26 10:16:17', '2026-05-26 10:16:17'),
(119, 125, 28, 'JOSE ARTURO', 'AGUILAR', 'CELAYA', '1993-06-03', 'AUCA930603HBCGLR00', NULL, NULL, NULL, NULL, 25, NULL, 'BASE', '22010002', NULL, NULL, '2026-05-26 10:20:03', '2026-05-26 10:20:03'),
(120, 126, 28, 'CARLOS DANIEL', 'TELLEZ', 'GODINEZ', '2006-11-28', 'TEGC061128HBCLBRA7', NULL, NULL, NULL, NULL, 28, NULL, 'BASE', '22141379', NULL, NULL, '2026-05-26 10:25:46', '2026-05-26 10:25:46'),
(121, 127, 28, 'JAVIER', 'TELLEZ', 'LINARES', '1977-09-03', 'TELJ770903HBCLMN05', NULL, NULL, NULL, NULL, 20, NULL, 'BASE', '2301160', NULL, NULL, '2026-05-26 10:28:32', '2026-05-26 10:28:32'),
(122, 128, 28, 'JUAN CARLOS', 'TELLEZ', 'LINARES', '2001-01-01', NULL, NULL, NULL, NULL, NULL, 30, NULL, NULL, NULL, NULL, NULL, '2026-05-26 10:33:15', '2026-05-26 10:33:15'),
(123, 129, 28, 'LUIS GABRIEL', 'MENDOZA', NULL, '1986-10-08', 'MEHL861025HGPNRS01', NULL, NULL, NULL, NULL, 14, NULL, 'CONTRATO', NULL, NULL, NULL, '2026-05-26 10:38:05', '2026-05-26 10:38:05'),
(124, 130, 28, 'ALEXIS ARATH', 'GARCIA', 'RODRIGUEZ', '1997-10-06', 'GARA971006HBCRDL01', NULL, NULL, NULL, NULL, NULL, NULL, 'HIJO', NULL, NULL, NULL, '2026-05-26 10:41:59', '2026-05-26 10:41:59'),
(125, 131, 28, 'JUAN MARTIN', 'TORRES', 'ESPINOZA', '2000-01-01', NULL, NULL, NULL, NULL, NULL, 10, NULL, NULL, NULL, NULL, NULL, '2026-05-26 11:51:12', '2026-05-26 11:53:06'),
(126, 132, 28, 'YEIDEN ARTURO', 'AGUILAR', NULL, '2000-01-01', NULL, NULL, NULL, NULL, NULL, 255, NULL, NULL, NULL, NULL, NULL, '2026-05-26 11:54:24', '2026-05-26 11:54:24'),
(127, 133, 15, 'CARLOS MANUEL', 'ARCE', 'ARROYO', '1977-04-02', 'AEAC770402HBCRRR00', NULL, NULL, NULL, NULL, 19, NULL, 'BASE', '040488', NULL, NULL, '2026-05-26 12:20:25', '2026-05-26 12:20:25'),
(128, 134, 15, 'ALBERTO', 'TELLO', 'GARCIA', '1974-04-17', 'TEGA740417HNTLRL02', NULL, NULL, NULL, NULL, 16, NULL, 'BASE', '0404368', NULL, NULL, '2026-05-26 12:27:24', '2026-05-26 12:27:24'),
(129, 135, 15, 'JOSE GUADALUPE', 'GUTIERREZ', 'PALOMARES', '1960-12-12', 'GUPG601212HSLTLD05', NULL, NULL, NULL, NULL, 12, NULL, 'BASE', '2201219', NULL, NULL, '2026-05-26 12:32:26', '2026-05-26 12:32:26'),
(130, 137, 15, 'FREDDY', 'AVIÑA', 'MURGUIA', '1993-09-22', 'AIMF930922HBCVRR04', NULL, NULL, NULL, NULL, 6, NULL, 'BASE', '46130953', NULL, NULL, '2026-05-26 12:41:10', '2026-05-26 12:41:10'),
(131, 138, 15, 'FELIPE DE JESUS', 'AVIÑA', 'VALDIVIA', '1962-08-04', 'AIVF620804HJCVLL21', NULL, NULL, NULL, NULL, 7, NULL, 'BASE', '04010594', NULL, NULL, '2026-05-26 12:43:42', '2026-05-26 12:43:42'),
(132, 139, 15, 'GUILLERMO ALONSO', 'PULIDO', 'JARA', '1968-03-31', 'PUJG680331HBCLRL06', NULL, NULL, NULL, NULL, 2, NULL, 'BASE', '13022069', NULL, NULL, '2026-05-26 12:47:21', '2026-05-26 12:47:21'),
(133, 140, 15, 'EMMANUEL GUADALUPE', 'BUENO', 'ROJO', '2000-01-01', NULL, NULL, NULL, NULL, NULL, 10, NULL, 'BASE', NULL, '80600', NULL, '2026-05-26 12:50:25', '2026-05-26 12:50:25'),
(134, 141, 15, 'ARTEMIO', 'NAVARRO', 'HERNANDEZ', '1965-11-17', 'NAHA651117HGTVRR05', NULL, NULL, NULL, NULL, 4, NULL, 'BASE', '04050275', NULL, NULL, '2026-05-26 12:55:36', '2026-05-26 12:55:36'),
(135, 142, 15, 'JOSE JUAN', 'PEREZ', 'VARGAS', '1975-10-21', 'PEVJ751021HGTRRN04', NULL, NULL, NULL, NULL, 8, NULL, 'BASE', '0404118', NULL, NULL, '2026-05-26 13:00:40', '2026-05-26 13:00:40'),
(136, 143, 15, 'SALVADOR AGUSTIN', 'OJEDA', 'VARELA', '1991-08-26', 'OEVS910826HBCJRL09', NULL, NULL, NULL, NULL, 12, NULL, 'BASE', '04040201', NULL, NULL, '2026-05-26 13:05:38', '2026-05-26 13:05:38'),
(137, 144, 15, 'JOSE OSCAR', 'SANDOVAL', 'GUTIERREZ', '1971-06-06', 'SAGO710606HBCNTS09', NULL, NULL, NULL, NULL, 22, NULL, 'INVITADO', NULL, NULL, NULL, '2026-05-26 13:09:38', '2026-05-26 13:09:38'),
(138, 145, 15, 'JOSE GIOVANNI', 'ARIAS', 'CARRASCO', '1999-11-02', 'AICG991102HBCRRV05', NULL, NULL, NULL, NULL, 19, NULL, 'BASE', '04040034', NULL, NULL, '2026-05-26 13:50:08', '2026-05-26 13:50:08'),
(139, 146, 15, 'JUAN MANUEL', 'PARDO', 'DIAZ', '1974-02-21', 'PADJ740221HBCRZN00', NULL, NULL, NULL, NULL, 14, NULL, 'INVITADO', NULL, NULL, NULL, '2026-05-27 09:03:56', '2026-05-27 09:03:56'),
(140, 147, 15, 'VICTOR ANTONIO', 'ARCE', 'ARROYO', '1980-03-30', 'AEAV800330HBCRRC04', NULL, NULL, NULL, NULL, 30, NULL, 'BASE', '04040028', NULL, NULL, '2026-05-27 09:11:00', '2026-05-27 09:11:00'),
(141, 148, 15, 'DIEGO ALEXANDER', 'ARCE', 'ICEDO', '2006-10-12', 'AEID061012HBCRCGA0', NULL, NULL, NULL, NULL, 21, NULL, 'HIJO', NULL, NULL, NULL, '2026-05-27 09:13:02', '2026-05-27 09:13:02'),
(142, 149, 15, 'GUSTAVO', 'VARGAS', 'DELGADO', '1975-11-17', 'VADG751117HDFRLS09', NULL, NULL, NULL, NULL, 24, NULL, 'BASE', '02010558', NULL, NULL, '2026-05-27 09:17:12', '2026-05-27 09:17:12'),
(143, 150, 15, 'CARLOS', 'LIZARRAGA', NULL, '2001-01-01', NULL, NULL, NULL, NULL, NULL, 31, NULL, 'BASE', '0405347', NULL, NULL, '2026-05-27 09:24:33', '2026-05-27 09:24:33'),
(144, 151, 15, 'PLACIDO', 'ESTOLANO', NULL, '2000-01-01', NULL, NULL, NULL, NULL, NULL, 3, NULL, 'BASE', '06010219', NULL, NULL, '2026-05-27 09:26:14', '2026-05-27 09:26:14'),
(145, 152, 7, 'ANDRES', 'RODRIGUEZ', 'OJEDA', '1974-08-20', 'ROOA740820HBCDJN08', NULL, NULL, NULL, NULL, 28, 'INFIELDER', 'BASE', NULL, NULL, 'CESPT', '2026-05-27 09:31:12', '2026-05-27 13:28:45'),
(146, 153, 7, 'OSCAR', 'HERNANDEZ', 'DURAN', '2000-01-01', NULL, NULL, NULL, NULL, NULL, 2, 'PITCHER', 'BASE', NULL, NULL, NULL, '2026-05-27 09:34:03', '2026-05-27 09:34:03'),
(147, 154, 7, 'JOSE MANUEL', 'HERNANDEZ', 'CASTRO', '2000-01-01', NULL, NULL, NULL, NULL, NULL, 17, NULL, NULL, NULL, NULL, NULL, '2026-05-27 09:37:08', '2026-05-27 09:37:08'),
(148, 155, 7, 'ELISEO ALBERTO', 'GARCIA', 'RAMIREZ', '2000-01-01', NULL, NULL, NULL, NULL, NULL, 76, NULL, NULL, NULL, NULL, NULL, '2026-05-27 09:39:18', '2026-05-27 09:39:18'),
(149, 156, 7, 'CARLOS GENARO', 'CHAVEZ', 'PEREZ', '2000-01-01', NULL, NULL, NULL, NULL, NULL, 20, NULL, NULL, NULL, NULL, NULL, '2026-05-27 09:40:54', '2026-05-27 09:40:54'),
(150, 157, 7, 'SEVERIANO', 'CARRAZCO', 'VIZCARRA', '2000-01-01', NULL, NULL, NULL, NULL, NULL, 3, 'INFIELDER', 'BASE', NULL, NULL, NULL, '2026-05-27 11:20:43', '2026-05-27 11:20:43'),
(151, 158, 7, 'LUIS', 'AYALA', 'INFANTE', '2000-01-01', NULL, NULL, NULL, NULL, NULL, NULL, '8', NULL, NULL, NULL, NULL, '2026-05-27 11:22:19', '2026-05-27 11:22:19'),
(152, 159, 7, 'FRANKLIN ARMANDO', 'LOPEZ', 'CASTRO', '2000-01-01', NULL, NULL, NULL, NULL, NULL, 21, NULL, 'HIJO', NULL, NULL, NULL, '2026-05-27 11:24:05', '2026-05-27 11:24:05'),
(153, 160, 7, 'SERGIO  ALBERTO', 'CASTRO', 'BELTRAN', '2000-01-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-27 11:25:34', '2026-05-27 11:25:34'),
(154, 161, 1, 'CHRISTIAN ANTONIO', 'LUGO', 'RODRIGUEZ', '1982-11-09', 'LURC821109HSRGOH05', NULL, NULL, NULL, NULL, 9, NULL, 'BASE', '32425', NULL, NULL, '2026-05-27 11:41:14', '2026-05-27 11:41:14'),
(155, 162, 1, 'ENRIQUE', 'TISNADO', 'GONZALEZ', '1994-04-17', NULL, NULL, NULL, NULL, NULL, 27, NULL, NULL, NULL, NULL, NULL, '2026-05-27 12:17:26', '2026-05-27 12:17:26'),
(156, 163, 1, 'HUGO NOE', 'VILLANUEVA', 'HIGUERA', '1997-02-11', 'VAPH970211HSLLCN03', NULL, NULL, NULL, NULL, 12, NULL, 'BASE', NULL, NULL, 'FISCALIA EDO', '2026-05-27 12:42:12', '2026-05-27 12:42:12'),
(157, 164, 1, 'MANUEL FERNANDO', 'VALDEZ', 'PACHECO', '2000-10-12', 'VIHH001012HBCLGG49', NULL, NULL, NULL, NULL, 12, NULL, 'BASE', '26509', NULL, NULL, '2026-05-27 13:25:50', '2026-05-27 13:25:50'),
(158, 165, 1, 'JESUS LUIS', 'GONZALEZ', 'FIGUEROA', '1983-08-04', NULL, NULL, NULL, NULL, NULL, 88, NULL, 'BASE', NULL, NULL, 'SECRETARIA DE SEGURIDAD CIUDADANA', '2026-05-28 09:26:02', '2026-05-28 09:26:02'),
(159, 166, 1, 'JOSE ALEJANDRO', 'NERY', 'FIGUEROA', '1983-05-09', 'NEFA830509HBCRGL09', NULL, NULL, NULL, NULL, 21, NULL, 'BASE', NULL, '088601', 'SECRETARIA DE SEGURIDAD CIUDADANA', '2026-05-28 09:35:07', '2026-05-28 09:38:49'),
(160, 167, 1, 'JOSE EDUARDO', 'ZARAGOZA', 'SAAVEDRA', '1995-06-21', NULL, NULL, NULL, NULL, NULL, 21, NULL, NULL, NULL, NULL, NULL, '2026-05-28 09:42:42', '2026-05-28 09:42:42'),
(161, 168, 1, 'ANGEL AXEL', 'PIÑA', 'RINCON', '2003-01-04', 'PIRA030104HBCXNNA6', NULL, NULL, NULL, NULL, 3, NULL, 'CONTRATO', NULL, NULL, 'POLICIA MUNICIPAL', '2026-05-28 09:59:42', '2026-05-28 09:59:42'),
(162, 169, 1, 'BRAYAN ALEXIS', 'DIAZ', 'ZAMARRIPA', '2003-05-20', 'DIZB030520HBCZMRA8', NULL, NULL, NULL, NULL, 20, NULL, 'HIJO', NULL, NULL, NULL, '2026-05-28 10:10:45', '2026-05-28 10:10:45'),
(163, 170, 1, 'JUAN CARLOS', 'MARTIN', 'IBARRA', '2004-10-13', NULL, NULL, NULL, NULL, NULL, 22, NULL, 'HIJO', NULL, NULL, NULL, '2026-05-28 11:43:54', '2026-05-28 11:43:54'),
(164, 171, 1, 'JUAN PEDRO', 'MARTIN', 'IBARRA', '2004-10-13', 'MAIJ041013HBCRBNB0', NULL, NULL, NULL, NULL, 99, NULL, 'HIJO', NULL, NULL, NULL, '2026-05-28 11:46:59', '2026-05-28 11:46:59'),
(165, 172, 1, 'JUAN LUIS', 'BASTIDA', 'MEZA', '2004-12-19', 'BAMJ041219HBCSZNA5', NULL, NULL, NULL, NULL, 32, NULL, NULL, NULL, NULL, NULL, '2026-05-28 11:50:30', '2026-05-28 11:50:30'),
(166, 175, 1, 'ISAAC JUNIOR', 'MENDEZ', 'HUERTA', '1998-06-16', 'MEHI980616HBCNRS05', NULL, NULL, NULL, NULL, 11, NULL, 'HIJO', NULL, NULL, NULL, '2026-05-28 12:01:42', '2026-05-28 12:01:42'),
(167, 176, 1, 'ARTURO MIGUEL', 'MEJIA', 'QUINTANA', '1990-06-27', NULL, NULL, NULL, NULL, NULL, 14, NULL, 'HIJO', NULL, NULL, NULL, '2026-05-28 12:06:55', '2026-05-28 12:06:55'),
(168, 177, 1, 'JESUS ALBERTO', 'CASTAÑEDA', 'GOMEZ', '2003-12-30', 'CAGJ031230HBCSMSA5', NULL, NULL, NULL, NULL, 6, NULL, 'INVITADO', NULL, NULL, NULL, '2026-05-28 12:13:45', '2026-05-28 12:13:45'),
(169, 178, 1, 'RAMON ERNESTO', 'PIÑA', 'VIDACA', '1989-04-14', NULL, NULL, 'L', 33, 'L', 30, NULL, 'INVITADO', NULL, NULL, NULL, '2026-05-28 12:20:58', '2026-08-05 13:40:28');

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
(29, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjQ2YWM3ZDU3Njc4ZWQ4MGMzMmEzYWRiYjllMWNjMmE3IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzg3OTgxNDQsImV4cCI6MTc3ODgwNTM0NH0._YyY7MvqbPRtGTe6XpgZSkSiDs7b48ae3glJYnrwPAQ', 'Web Frontend', 'web', '::1', '2026-05-14 17:35:44', '2026-05-14 15:36:20', 1, '2026-05-14 15:35:44'),
(30, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjI3ODA4ZWMzMDRiNjU2YzUzY2MxNDJkNDljMjdmNzNiIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzg3OTk5NTEsImV4cCI6MTc3ODgwNzE1MX0.dJw8yji8lHclOfFTL-ai8WHAL-6pxA5tcajJAgwdQy4', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-14 18:05:51', NULL, 0, '2026-05-14 23:05:51'),
(31, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6IjYyNmZjMzIyZDkyOGYzMjg4YjExNmRlZjNiOGQ3MjVkIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4ODAwMDI3LCJleHAiOjE3Nzg4MDcyMjd9.DIUdRRSXduQFRwYkO2YTkcQ2O2Q082HzRu5y8hJFgKM', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-14 18:07:07', NULL, 0, '2026-05-14 23:07:07'),
(32, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjBlNjE5N2MwNDFmMTkxMTEyMDljMjcwMzBmYTcyMjA2IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzg4MDAxNzcsImV4cCI6MTc3ODgwNzM3N30.2909HhorA3wFGzV08BPhVGxbnUnG0ojdin4c4lkMmJM', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-14 18:09:37', NULL, 0, '2026-05-14 23:09:37'),
(33, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImJmMGM5Yzg4ZTFiN2Q2OWVlMjUxODdkODkwNDMzZDdmIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzg4MDEwNTIsImV4cCI6MTc3ODgwODI1Mn0.Lm7wPtqcHhJMhxzRGil9YRc84ySCMlU-hkLPawa_UuY', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-14 18:24:12', NULL, 0, '2026-05-14 23:24:12'),
(34, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6Ijc3MzFkZGI4YjFlMDQxYjZjMGUxYzgzMzgwYjc2NDIwIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzg4MDI4NDksImV4cCI6MTc3ODgxMDA0OX0.WUmdbJZQUTT4SeFc1JIBC8r8KrumH7_gqXB1u7P13Q0', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-14 18:54:09', NULL, 0, '2026-05-14 23:54:09'),
(35, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6IjZhZGRmYWZhZWI5NjgxOThhZjMyN2Y2ODNlYTI3ZWNhIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc5MDc5MDgxLCJleHAiOjE3NzkwODYyODF9.KRn5B61Qs4naAvoZ98zkO-pLOV0TQ3h19ddnt9BVGhQ', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-17 23:38:01', NULL, 0, '2026-05-18 04:38:01'),
(36, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6ImQxNGVjMGJkODM5OTExOWNiOWZjYzkxOTM5M2IyNjE1IiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc5MDc5NzkzLCJleHAiOjE3NzkwODY5OTN9.M8498rXLmHVVMUUf1uOXtlaRF2r_LjoIRw40FHcnlic', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-17 23:49:53', NULL, 0, '2026-05-18 04:49:53'),
(37, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsImp0aSI6ImQ0NmQxZjAxZDYxMjljNTc5NmVlMWZkYTU3NmYxOTZlIiwiZW1haWwiOiJtYW5hZ2VyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoibWFuYWdlciIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc5MDgwMjEyLCJleHAiOjE3NzkwODc0MTJ9.vS_l7Dzv5PPI2RdkWdDGkVV-Q9sTpdLh3kKGFYvwfBw', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-17 23:56:52', NULL, 0, '2026-05-18 04:56:52'),
(38, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6IjllMjI2MWEyMWI5NmU3ZTljNDg4NTVmNzU4MzVjMDA2IiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc5MDgwMzcyLCJleHAiOjE3NzkwODc1NzJ9.bjjJPvkZHZ0dYOxOHOSrlc73buJFfrAaotYF050x_sU', NULL, 'web', '177.239.38.240', '2026-05-17 23:59:32', NULL, 0, '2026-05-18 04:59:32'),
(39, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6ImYzMTI2YjVkYmQ1NTEyNGE5NjdjZWQ2M2M2MTY3ZTY5IiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc5MDgzOTkwLCJleHAiOjE3NzkwOTExOTB9.SCYRsYJOxlERkwD26ffXmjJJZF2iJQVMCQrYX9eif_Y', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-18 00:59:50', NULL, 0, '2026-05-18 05:59:50'),
(40, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6IjE1MGFiOWQ2M2Q4NzlkYTJiNzA0MDkyOWFjNDg1ZjlkIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc5MDg0MTg4LCJleHAiOjE3NzkwOTEzODh9.RpLalHAJAtcZXc7aeybqU9cuz3lzPfhEPcZPPm2m1eI', NULL, 'web', '177.239.38.240', '2026-05-18 01:03:08', NULL, 0, '2026-05-18 06:03:08'),
(41, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6ImEzNzZhZWQyNGYwZTE1OWJkOGU0ZGJkODY4ZGYxMzZiIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc5MDg1MTc3LCJleHAiOjE3NzkwOTIzNzd9.Hfy9Wfhxq4ODQeAPZcmrJr0qnRlKDoJDuBX4Zhrz2UY', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-18 01:19:37', '2026-05-17 23:53:46', 1, '2026-05-18 06:19:37'),
(42, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6Ijc0MDg3MDNiZThmMTRmNjBmMWVhZjY1ZDVlYjdlZjlhIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc5MDg2NDY2LCJleHAiOjE3NzkwOTM2NjZ9.AaR1PUYdSV9oxeDDIcqS6jCQLmMdV684iX5f-T7eoUI', NULL, 'web', '177.239.38.240', '2026-05-18 07:41:06', '2026-05-18 06:43:39', 0, '2026-05-18 06:41:06'),
(43, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6IjRiNDY5ZWM4ODA2OGIwNzU0OWYzNzY3YTY4MzNiNmY0IiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc5MDg3Mjg2LCJleHAiOjE3NzkwOTQ0ODZ9.n6j6D6gwuYV8-cC9omvDat6Ew0thN2YMyeXg8g8UjYc', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-18 01:54:46', '2026-05-17 23:55:27', 1, '2026-05-17 23:54:46'),
(44, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsImp0aSI6IjdlYzVkMGVkOTY1YjNlMmU3MTIzNGY4ZTJjNTQ0Yzk4IiwiZW1haWwiOiJtYW5hZ2VyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoibWFuYWdlciIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc5MDg3MzMzLCJleHAiOjE3NzkwOTQ1MzN9.cqvOAuVPZZqDZ7va_RfVKpSFP1J5x9gSooUiBPPrpKE', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-18 01:55:33', '2026-05-17 23:56:14', 1, '2026-05-17 23:55:33'),
(45, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjkxYzQ1YjE1N2Y4NGUzZThjMDVkNGRmOGQ1MTlkZTdiIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkwODczOTcsImV4cCI6MTc3OTA5NDU5N30.qlzPoMy8psZiQxrmVP36iayY5LAql49_ejSC8XuvKE8', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-18 01:56:37', '2026-05-17 23:57:19', 1, '2026-05-17 23:56:37'),
(46, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjAwYzVjMTc3NGYxM2EwMGUzZGU0ZTYyYzE3ZTg5ZTlhIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkwODc1MzcsImV4cCI6MTc3OTA5NDczN30.dCgDXZXb3xYpKaySvlhu30--niYtG4JB7pPKQWPySjY', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-18 01:58:57', '2026-05-17 23:59:56', 1, '2026-05-17 23:58:57'),
(47, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6Ijk4OGZjMzk4MDVkZTVlZmEzNTQ1MDhiMTRlNThmMmRmIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkxMjkwNjksImV4cCI6MTc3OTEzNjI2OX0.HJ5YE-3SeaPoZpXSEJQMHSBORMpLzu6Jj3fu_Q1Kkbk', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-18 13:31:09', '2026-05-18 11:34:35', 1, '2026-05-18 11:31:09'),
(48, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjE0MjYwYTY1YjFmOTExNTFjMWUxNTVhOGIyNTc1OTAzIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkxMzI2MzMsImV4cCI6MTc3OTEzOTgzM30.NqR1em9_AGjNMzKfNBcZbmeioQZE4FONpcpULBSVHpA', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-18 14:30:33', '2026-05-18 13:11:16', 0, '2026-05-18 12:30:33'),
(49, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjljYzQyY2MwYTBkZGJhMjQ4ZGRhNGMxMzUwZTJkZjQwIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkxMzU0MzYsImV4cCI6MTc3OTE0MjYzNn0.iux-GEpol9Y_WHs9qBaNKoInSVnN5WudXOJNGcT3KPM', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-18 15:17:16', '2026-05-18 13:58:38', 1, '2026-05-18 13:17:16'),
(50, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjIyMjE4N2RkMGVmMDg4YTVmOGE0Mjg3Mjg5MzdmNzQwIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkxMzc5MjIsImV4cCI6MTc3OTE0NTEyMn0.Pgs6Zjy-TPkfUmaM6fWCDHOgNsl7BA9_uwPA8n165z4', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-18 15:58:42', '2026-05-18 13:59:27', 1, '2026-05-18 13:58:42'),
(51, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImY1YmMzMGY5NTdiMjVmOTIwOGJmNjJiOWUxZGVjYjU0IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkxNDI2NTksImV4cCI6MTc3OTE0OTg1OX0.jmoxZpgSZNQ8L_BbZexaJK_F7RDKw3gzVvyQB6G_gus', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-18 17:17:39', '2026-05-18 15:18:33', 1, '2026-05-18 15:17:39'),
(52, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjU3MzFiOGM3MDI2N2UyNzg2ODc5NWNhNWE1MDBkOTc5IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkxNTMxMTAsImV4cCI6MTc3OTE2MDMxMH0.N8pFPQiKtgN_nLmYwVpTmOzKzcQySLaUbokoMJ8quk4', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-18 20:11:50', '2026-05-18 18:13:39', 1, '2026-05-18 18:11:50'),
(53, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6Ijc5NjRjNzQ0NDMxZGVjM2IyYzZiMTc4MDlkMDU5MDk1IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkyMDQ5MDcsImV4cCI6MTc3OTIxMjEwN30.CnqHoUO8H1ocO5DC6ifYTAVcSceZFzJZhYeaaX19PUg', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-19 10:35:07', '2026-05-19 10:25:22', 0, '2026-05-19 08:35:07'),
(54, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImY5MTZlZmY2OGJhNTZlNTdhNGUyMmE5NjBkODU0ZjgxIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkyMTYzNjcsImV4cCI6MTc3OTIyMzU2N30.wyv3u32GvbCdUEy2z1brF_ZuOCzQw52tMkB5NPfESkI', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-19 13:46:07', '2026-05-19 13:43:11', 0, '2026-05-19 11:46:07'),
(55, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6Ijg1Nzc4ZTdhOTg4ODZjYzQzNTZmMDFmODY0OGU5MDM5IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkyMjQwMTcsImV4cCI6MTc3OTIzMTIxN30.lyXTjnZK4w2bOphyC0RBnoflcuhykCUBfaL-QUaDM8E', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-19 15:53:37', '2026-05-19 13:58:29', 1, '2026-05-19 13:53:37'),
(56, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImViODZlNmYwYzkzNmYwZDIzZDQ5MjM3OGY3Y2EyYzlhIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkyOTA4MjUsImV4cCI6MTc3OTI5ODAyNX0.wa_7GmUIv7bMXiFnQUi3iAUJi57eO3FDREQYkASykto', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-20 10:27:05', '2026-05-20 08:27:05', 0, '2026-05-20 08:27:05'),
(57, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImFjZTcwNTJlMjU4ZjNjMzYzMzdlYmJlOGVkZDdlOGVhIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkyOTYwNjIsImV4cCI6MTc3OTMwMzI2Mn0.kvMjfWCuzdtFMrPsMB2ZsJGqt6XOwkE-b0Y6pL3aGoI', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-20 11:54:22', '2026-05-20 11:40:47', 0, '2026-05-20 09:54:22'),
(58, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImQzM2FiNjk3MjA3OWMzMDc0YTFjZDk0YTY2ODVjMTE2IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkzMDM0NzMsImV4cCI6MTc3OTMxMDY3M30.cyTf5rarATzOZUZTRryNONiMgAG5yBjiWaEd9a3LBvw', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-20 13:57:53', '2026-05-20 12:58:32', 1, '2026-05-20 11:57:53'),
(59, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6Ijc3Y2RmYzk2MTQwODY3MWNiNjUzMmJhMDNiZmJkMjE4IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkzNzg3MTQsImV4cCI6MTc3OTM4NTkxNH0.A1coBC6Ok4cA2_GOPC9xCxwz17Ob0_dQ2ghIA-Jj4w4', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-21 10:51:54', '2026-05-21 10:47:46', 1, '2026-05-21 08:51:54'),
(60, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjkwZTJiZjJlNDIyOTkzM2E5ZGE3NTI0NGNiY2IzYWE0IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkzODc0NzksImV4cCI6MTc3OTM5NDY3OX0.k2ijGSmP6ut91j9XCkXakKrmI9xOlJ7Y_9LzXnpYyuQ', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-21 13:17:59', '2026-05-21 11:18:08', 1, '2026-05-21 11:17:59'),
(61, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjRlNTNkYWMzYWNhNmFhMmNhY2EzY2M5MjE2ZjdjYzBiIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3NzkzODc0OTAsImV4cCI6MTc3OTM5NDY5MH0.Jc2i_qYmKRSKXuz2CIVEEfyUEPBs4x3_-HCQIDnRklk', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-21 13:18:10', '2026-05-21 11:34:23', 1, '2026-05-21 11:18:10'),
(62, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6Ijg2Nzk1YzBhYTk1ZTExNDBmZDQ4MzdkOTdiZGM5ZGY0IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk0NjM2MTMsImV4cCI6MTc3OTQ3MDgxM30.YL0nG__pDKNlprbYIJccNRE53HWuA8gkmAhYoRqYl3c', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-22 10:26:53', '2026-05-22 09:30:39', 1, '2026-05-22 08:26:53'),
(63, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImIxNTA5MDg5YmE0NWY4MWQwOGE3MTI1MWE1ZGM4OGU1IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk0NzE2MjcsImV4cCI6MTc3OTQ3ODgyN30.H2i5Rukxm9hQLB2vhJZ5aurkzr1bt0UJXuQnDLcDnKI', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-22 12:40:27', '2026-05-22 12:06:23', 1, '2026-05-22 10:40:27'),
(64, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjY3ZDQzOTQ3OGVhNzI1OTgyYzcxODkwMDlmYzkyMDVjIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk0NzgwNjEsImV4cCI6MTc3OTQ4NTI2MX0.WTrS62Ff7uVdivoR9yxyoQF5hj9hruqEsHFI4IA5Z9E', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-22 14:27:41', '2026-05-22 13:25:52', 1, '2026-05-22 12:27:41'),
(65, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjA0YmYwYzE5ODQyNzgxZDEwYTQ2ZTIwODgyMjBlMzBlIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk3MjM3NjEsImV4cCI6MTc3OTczMDk2MX0.6kLqqz95cr4HsTuQ01mOgtMSc-SyuZ__oMiQWxjqJpU', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-25 10:42:41', '2026-05-25 08:44:44', 1, '2026-05-25 08:42:41'),
(66, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImY2OWIxZWNlNzc4OWU3NjAzMGFkMDE0OGIzZDE4ZmM5IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk3MjM4ODcsImV4cCI6MTc3OTczMTA4N30.9WaGDRobNTO4YLsCHQY7gNFrux9mfBqWyk_3PZA5xNs', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-25 10:44:47', '2026-05-25 09:51:14', 0, '2026-05-25 08:44:47'),
(67, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjY3NWNiYWY0NTRhMDU4ZjljZGM1M2I5ZDZmMWU3OWY0IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk3MzM1MTYsImV4cCI6MTc3OTc0MDcxNn0.Q14axeF0PDvsdn2pH0An1LLaPjr4nTqEN1pdmCnA8KI', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-25 13:25:16', '2026-05-25 12:46:29', 0, '2026-05-25 11:25:16'),
(68, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImQxMzIxOGI1YTRkNDBmYmZhNDQ0NmQzMjVkYjc5YjIzIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk4MTUwMTAsImV4cCI6MTc3OTgyMjIxMH0.COkyCSK7sfMTILrhv08D2nF46erwxl6CctuI6dw_rZs', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-26 12:03:30', '2026-05-26 11:13:32', 1, '2026-05-26 10:03:30'),
(69, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6Ijk1NGEyZjM5NDQ3YzEyN2ZkMDdiZWM5Y2E2NDY1ODg4IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk4MjE0MTUsImV4cCI6MTc3OTgyODYxNX0.uzLjwWYlFMri_liSjBfRS7lwyvdxR_MQs1-6rckS9uM', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-26 13:50:15', '2026-05-26 13:50:12', 0, '2026-05-26 11:50:15'),
(70, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjllODAzN2RkZmI3YzkzY2ZkODA0YjhjMGYzNDA1YmNkIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk4OTc2NTUsImV4cCI6MTc3OTkwNDg1NX0.sgPlqVqI8w5rpBW5DY9M7ORDhN3s_KxxZxxLupWU0ts', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-27 11:00:55', '2026-05-27 09:41:08', 1, '2026-05-27 09:00:55'),
(71, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImFmYjI1YjdjYTViYWNkYjhkNTc3ZGRhYjlmMGRiM2FhIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk5MDU4MTYsImV4cCI6MTc3OTkxMzAxNn0.GTZFaW5UJABlQy9FVkXpfsZze3vlnGfiJx1BjwUklGs', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-27 13:16:56', '2026-05-27 11:43:51', 1, '2026-05-27 11:16:56'),
(72, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjMzZTMwYWZhMTc2NDk0YTllYTc4YTI0MDc5OTc4MGE3IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk5MDkxNjEsImV4cCI6MTc3OTkxNjM2MX0._b9kNMqki8-wZxEtGSmICJa-otvqSYeNkx9YQzAcLDM', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-27 14:12:41', '2026-05-27 12:29:21', 1, '2026-05-27 12:12:41'),
(73, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjE0YzZmZjQzMmRmZDhjNDNkMjljOTA1ODhkN2E4M2U1IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk5MTAxNTIsImV4cCI6MTc3OTkxNzM1Mn0.v6QiwJ7l5yCF7NxsdrrNnQQiuaBBpdD7sdMPrSZgMvk', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-27 14:29:12', '2026-05-27 12:30:51', 1, '2026-05-27 12:29:12'),
(74, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjRkZGI4ZWJmNTU4NzMwMjk5MzViMWQyNDUyNmMyZjU1IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk5MTAxNzgsImV4cCI6MTc3OTkxNzM3OH0.rSxgL1rAd1BrKFOTNh6cLoC3pMFQwgnPuPXwZmJAr9E', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-27 14:29:38', '2026-05-27 13:22:39', 1, '2026-05-27 12:29:38'),
(75, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjQzZmQ3NGNiMDQxMGM5NGU1ODY3MWY1MWVkZDlhYTJkIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk5MTMzNjIsImV4cCI6MTc3OTkyMDU2Mn0.hbHVsjfKeqDvN2w08-cSctzx5vFgl7rWjaOZU9eCjkg', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-27 15:22:42', '2026-05-27 13:28:56', 1, '2026-05-27 13:22:42'),
(76, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImNlYzRiZjdiOWIzZWFmNWY3NjY1MGRkNTMzYTgwNWExIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk5MTk0NDksImV4cCI6MTc3OTkyNjY0OX0.phDDDzq6KDm4UV2ZLrj2r_6kLqPdUfLx8HfppwatsHk', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-27 17:04:09', '2026-05-27 15:06:15', 0, '2026-05-27 15:04:09'),
(77, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImRlYzMzYzAxYWNmMjI0MmYwNGFlMDgyMGY1NmRkM2QxIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk5ODE2OTUsImV4cCI6MTc3OTk4ODg5NX0.s422khOEdZKsr6MuZs3eS5EZKLOisjS-phAxqX-IAog', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-28 10:21:35', '2026-05-28 10:20:47', 1, '2026-05-28 08:21:35'),
(78, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjY2N2IyNGE5ZGQzMjU1ZGZkMjk5NTMwYjM0OGQzMTJkIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk5OTI2OTMsImV4cCI6MTc3OTk5OTg5M30.voQqFlukxXVCMmI-oy69gQD9EZe8u-nqCXYPwZtb83A', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-28 13:24:53', '2026-05-28 12:21:18', 1, '2026-05-28 11:24:53'),
(79, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImM2MjZhNjJjYWM4YmVkOGJkYTBkYjg3YWY4MTIxOTViIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk5OTc2MzcsImV4cCI6MTc4MDAwNDgzN30.BFL4OZoA2LchWOyK_gG3BIPIx-UdlB-5zm52GVZZt7E', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-28 14:47:17', '2026-05-28 13:02:28', 0, '2026-05-28 12:47:17'),
(80, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjAzYmM5ZGZmNTNjNzE4NmY1NzZkMWMwZWIyYjA4Njg0IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk5OTgyODksImV4cCI6MTc4MDAwNTQ4OX0.rsVMsfwWhfIdRHm34qp3Uygd7LaSzVDbRJFm33AGW_Y', 'Web Frontend', 'web', '2a02:4780:1:1244:0:348b:1ab2:1', '2026-05-28 14:58:09', '2026-05-28 13:07:17', 0, '2026-05-28 12:58:09'),
(81, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjgyZjZmZGY1NWZkZWMyYjllYTY3Y2YxZTAzZmJiOWIyIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3Nzk5OTkyNTcsImV4cCI6MTc4MDAwNjQ1N30.R3ToMimDohC_jbZnBEE6qyhNPYQBTmyvuUFDrarDi3w', 'Web Frontend', 'web', '::1', '2026-05-28 15:14:17', '2026-05-28 14:05:59', 1, '2026-05-28 13:14:17'),
(82, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImY5ZDViMTRkN2JmNjgyNzg1YTllMjMzZDQxYzQ2YzBjIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3ODAwMDIzNjUsImV4cCI6MTc4MDAwOTU2NX0.8XkNpGftrB5vxQghnmbx7syRouSwjJNzM4UG7v9gAe8', 'Web Frontend', 'web', '::1', '2026-05-28 16:06:05', '2026-05-28 14:08:30', 1, '2026-05-28 14:06:05'),
(83, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImNmYzZlZGY0ZDlhYzgxZDJjZWZhOGVjYTk5MzE4MmVkIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3ODAwMDI1MjcsImV4cCI6MTc4MDAwOTcyN30.i-hvmKT611TZWub0mewTMojE4oEOVFuynT9qKdK0Oxs', 'Web Frontend', 'web', '::1', '2026-05-28 16:08:47', '2026-05-28 14:10:46', 1, '2026-05-28 14:08:47'),
(84, 4, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjQsImp0aSI6IjVkYmQ2MGM3MjQzYmVhM2RkZTlkYjAyMGEzOTczNTYzIiwiZW1haWwiOiJwbGF5ZXIyQHNpbmRpY2F0by5jb20iLCJyb2xlIjoibWFuYWdlciIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzgwMDAyNjUzLCJleHAiOjE3ODAwMDk4NTN9.RuGlTg-SU-2BfYZISJUY38EAzZdij5CMYNdx8uUN5aA', 'Web Frontend', 'web', '::1', '2026-05-28 16:10:53', '2026-05-28 14:20:32', 1, '2026-05-28 14:10:53'),
(85, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjFhNmE4OTgxZThhZWU0MGQzZmFjNjA2NDNhNWZhNDlkIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3ODAwMDMyMzcsImV4cCI6MTc4MDAxMDQzN30.qeK70B_dyVx_x5VHmdvsoAA9g5bBFUx54BT61nJPuW4', 'Web Frontend', 'web', '::1', '2026-05-28 16:20:37', '2026-05-28 14:51:41', 0, '2026-05-28 14:20:37'),
(86, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImJlNWVmM2I2YjRiOGY3NDhiNjYxNTA3NWI4ZWQ3MDc4IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3ODA1OTM1MjEsImV4cCI6MTc4MDYwMDcyMX0.PTj80VrOQNMUGlAh53WziyYbaXTcw6Z-kg38anzEzDs', 'Web Frontend', 'web', '::1', '2026-06-04 12:18:41', '2026-06-04 11:59:06', 0, '2026-06-04 10:18:41'),
(87, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjgwODJiZmZlOTFkZTQ4NDM1YmY4YWFjN2EzMjk3MDE2IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3ODI0MTQxNTUsImV4cCI6MTc4MjQyMTM1NX0.SOkO_qOh5nvmOcoSmpyecoWCvnAW37jyrxT6yOubRss', 'Web Frontend', 'web', '::1', '2026-06-25 14:02:35', '2026-06-25 12:10:54', 0, '2026-06-25 12:02:35'),
(88, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjUzOTA2MWQ1YjEyN2Q1M2Y1ZmQyMzI4MGM4Y2NhYWY5IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3ODI0MjM3MzAsImV4cCI6MTc4MjQzMDkzMH0.6Cn2P0Sb8IpGHG6jfcfFXIHz8N6k_hLDykH9YVRF3oA', 'Web Frontend', 'web', '::1', '2026-06-25 16:42:10', '2026-06-25 15:40:34', 1, '2026-06-25 14:42:10'),
(89, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImEzODZhMzlmMmQxZmIxN2I4ZTgwY2IxODBjMjkzYjk3IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3ODI4NTIzMDMsImV4cCI6MTc4Mjg1OTUwM30.4PXgZiroJZRoivF_1hTNvLK8JV4joFquqC0Y7Lc-Xrc', 'Web Frontend', 'web', '::1', '2026-06-30 15:45:03', '2026-06-30 15:14:52', 0, '2026-06-30 13:45:03'),
(90, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImQ2NWQ2ZDM1MDZmNjA5NmIwMmMzY2Q0MWYwNjNjNDQ0IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3ODI5MjE1OTksImV4cCI6MTc4MjkyODc5OX0.lV6R-f_QwzUN_SSTHvgdtJxvSIQSAXt4L8EMFnWEwuQ', 'Web Frontend', 'web', '::1', '2026-07-01 10:59:59', '2026-07-01 10:37:01', 0, '2026-07-01 08:59:59'),
(91, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6IjRlYjk5OWQ4NGQ4ZWZjNDM3MTlhNTZjMDAzM2EzNDBjIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3ODI5MjkxNDIsImV4cCI6MTc4MjkzNjM0Mn0.YJojjUh3n-FRLFr4WOxUN4ZGf0L4xCN5wWmnDSbkPUo', 'Web Frontend', 'web', '::1', '2026-07-01 13:05:42', '2026-07-01 11:56:04', 0, '2026-07-01 11:05:42'),
(92, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImJkMGVlZWE5ZTIxNTE5ZGE0ZTJkZDQ2MDAyOWIzMTNkIiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3ODU0Mzg5MjksImV4cCI6MTc4NTQ0NjEyOX0.eL12D_eASbDC-GzLG7tEsxG89bgP1scUeRygXrOpCa4', 'Web Frontend', 'web', '::1', '2026-07-30 14:15:29', '2026-07-30 12:15:36', 0, '2026-07-30 12:15:29'),
(93, 6, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsImp0aSI6ImRhMjcwOWRiNGZhNWE3NzI2OTQ1Y2EzNmJjZjU1M2Y5IiwiZW1haWwiOiJkZXBvcnRlc0BzaW5kaWNhdG8uY29tIiwicm9sZSI6ImFkbWluIiwiaXNzIjoiYmFzZWJhbGwtdG1zIiwiYXVkIjoiYmFzZWJhbGwtdG1zLWNsaWVudHMiLCJpYXQiOjE3ODU5NjIzMzksImV4cCI6MTc4NTk2OTUzOX0.MhJS-veHPZFV-IPtOwi8ZfuQ7HILDO6b1I-zkON8tbM', 'Web Frontend', 'web', '::1', '2026-08-05 15:38:59', '2026-08-05 13:42:18', 0, '2026-08-05 13:38:59');

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
(1, 'VIEJITO GARCIA', 'OTAY AMATEUR', 1, '2026-05-14 10:37:05', '2026-05-18 13:07:46'),
(2, 'SIERRA VERA', 'OTAY MUNICIPAL', 1, '2026-05-18 13:06:35', '2026-05-18 13:07:27'),
(3, 'NIEVES', 'OTAY MUNICIPAL', 1, '2026-05-18 13:06:55', '2026-05-18 13:07:37'),
(4, 'CACAHUATE', 'OTAY MUNICIPAL', 1, '2026-05-18 13:08:01', '2026-05-18 13:08:01'),
(5, 'CAMARENA', 'OTAY AMATEUR', 1, '2026-05-18 13:08:18', '2026-05-18 13:08:18'),
(6, 'VERDUGO', 'AMATEUR', 1, '2026-05-18 13:08:30', '2026-05-18 13:08:30'),
(7, 'DIRECTIVOS', 'OTAY MUNICIPAL', 1, '2026-05-18 13:08:46', '2026-05-18 13:08:46');

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=179;

--
-- AUTO_INCREMENT de la tabla `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=170;

--
-- AUTO_INCREMENT de la tabla `user_tokens`
--
ALTER TABLE `user_tokens`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- AUTO_INCREMENT de la tabla `venues`
--
ALTER TABLE `venues`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

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
