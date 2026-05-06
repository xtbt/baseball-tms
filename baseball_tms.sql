-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost
-- Tiempo de generación: 06-05-2026 a las 15:36:31
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
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
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
  `status` enum('scheduled','in_progress','completed','cancelled','postponed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'scheduled',
  `notes` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

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
  `logo_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registered teams per category';

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
(1, 'jsanchez.1983@gmail.com', '$2y$10$d1attNAU9pIjq6MizhBRNOar8EzL1UOueFJUK3TNdgXWEH/hc0UQW', 'admin', 1, '2026-05-06 15:34:18', '2026-05-06 15:34:00', '2026-05-06 15:34:18');

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
  `employee_class` enum('base_employee','trust_employee','contract_employee','employee_child') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `employee_number` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `isstecali_affiliation` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_photo_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Extended player/manager profile data';

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
(1, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImVtYWlsIjoianNhbmNoZXouMTk4M0BnbWFpbC5jb20iLCJyb2xlIjoiYWRtaW4iLCJpc3MiOiJiYXNlYmFsbC10bXMiLCJhdWQiOiJiYXNlYmFsbC10bXMtY2xpZW50cyIsImlhdCI6MTc3ODEwNjg1OCwiZXhwIjoxNzc4MTE0MDU4fQ.zXNBwdo9rL06jdpVfBZsjcHqCOj6I1BRubMZ1VgStcw', 'Local API Test', 'web', '::1', '2026-05-06 17:34:18', NULL, 0, '2026-05-06 15:34:18');

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `games`
--
ALTER TABLE `games`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `user_tokens`
--
ALTER TABLE `user_tokens`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `venues`
--
ALTER TABLE `venues`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

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
