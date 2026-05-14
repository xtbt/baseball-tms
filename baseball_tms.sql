-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: May 13, 2026 at 11:15 PM
-- Server version: 5.7.32
-- PHP Version: 8.0.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `baseball_tms`
--
DROP DATABASE IF EXISTS `baseball_tms`;
CREATE DATABASE IF NOT EXISTS `baseball_tms` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `baseball_tms`;

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
CREATE TABLE `audit_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `record_id` int(10) UNSIGNED DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Audit trail for critical data changes';

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tournament categories (e.g. Libre, Veteranos, Sub-23)';

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Categoria A', 'Los pros', 1, '2026-05-13 14:05:12', '2026-05-13 14:05:12'),
(2, 'Categoria B', 'Los regulares', 1, '2026-05-13 14:05:27', '2026-05-13 16:03:53'),
(3, 'Categoria C', 'Los malos', 1, '2026-05-13 14:05:40', '2026-05-13 16:03:30');

-- --------------------------------------------------------

--
-- Table structure for table `games`
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
  `status` enum('scheduled','in_progress','completed','cancelled','postponed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'scheduled',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `game_innings`
--

DROP TABLE IF EXISTS `game_innings`;
CREATE TABLE `game_innings` (
  `id` int(10) UNSIGNED NOT NULL,
  `game_id` int(10) UNSIGNED NOT NULL,
  `inning` tinyint(3) UNSIGNED NOT NULL,
  `home_runs` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `away_runs` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Run scoring per inning';

-- --------------------------------------------------------

--
-- Table structure for table `player_game_stats`
--

DROP TABLE IF EXISTS `player_game_stats`;
CREATE TABLE `player_game_stats` (
  `id` int(10) UNSIGNED NOT NULL,
  `game_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `team_id` int(10) UNSIGNED NOT NULL,
  `at_bats` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `hits` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `runs` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `rbi` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `home_runs` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `strikeouts` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `walks` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `errors` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `innings_pitched` decimal(4,1) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Individual player statistics per game';

-- --------------------------------------------------------

--
-- Table structure for table `standings`
--

DROP TABLE IF EXISTS `standings`;
CREATE TABLE `standings` (
  `id` int(10) UNSIGNED NOT NULL,
  `team_id` int(10) UNSIGNED NOT NULL,
  `category_id` int(10) UNSIGNED NOT NULL,
  `season_year` year(4) NOT NULL,
  `games_played` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `wins` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `losses` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `ties` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `runs_scored` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `runs_allowed` smallint(5) UNSIGNED NOT NULL DEFAULT '0',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Cached standings table per category and season';

-- --------------------------------------------------------

--
-- Table structure for table `teams`
--

DROP TABLE IF EXISTS `teams`;
CREATE TABLE `teams` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` int(10) UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registered teams per category';

--
-- Dumping data for table `teams`
--

INSERT INTO `teams` (`id`, `name`, `category_id`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Dodgers', 1, 1, '2026-05-13 14:07:01', '2026-05-13 14:07:01'),
(2, 'Padres', 2, 1, '2026-05-13 14:07:14', '2026-05-13 14:07:14'),
(3, 'Yanquis', 3, 1, '2026-05-13 14:07:23', '2026-05-13 14:07:23');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','manager','player') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'player',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System authentication and authorization';

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password_hash`, `role`, `is_active`, `last_login_at`, `created_at`, `updated_at`) VALUES
(1, 'jsanchez.1983@gmail.com', '$2y$10$d1attNAU9pIjq6MizhBRNOar8EzL1UOueFJUK3TNdgXWEH/hc0UQW', 'admin', 1, '2026-05-13 15:01:44', '2026-05-06 15:34:00', '2026-05-13 15:01:44'),
(2, 'manager@sindicato.com', '$2y$10$4Swp15LcL32IHS/Qx5Wj6.RekBm8LWezMlNjnaatEx9VNi.cIkBnC', 'manager', 1, '2026-05-13 14:49:00', '2026-05-13 13:40:36', '2026-05-13 14:49:00'),
(3, 'player@sindicato.com', '$2y$10$.3Bj7eyfSPA21HuFB.XAze3GrzgR99PS4VajUUTzYnw5d4AL9G7QC', 'player', 1, '2026-05-13 14:48:42', '2026-05-13 14:16:07', '2026-05-13 14:48:42');

-- --------------------------------------------------------

--
-- Table structure for table `user_profiles`
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
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Extended player/manager profile data';

--
-- Dumping data for table `user_profiles`
--

INSERT INTO `user_profiles` (`id`, `user_id`, `team_id`, `first_name`, `paternal_surname`, `maternal_surname`, `birth_date`, `curp`, `phone`, `jersey_number`, `position`, `employee_class`, `employee_number`, `isstecali_affiliation`, `created_at`, `updated_at`) VALUES
(1, 1, NULL, 'JONATHAN', 'SANCHEZ', NULL, '1983-05-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-13 13:36:14', '2026-05-13 13:36:14'),
(2, 2, 3, 'FULANO', 'DE TAL', NULL, '1990-01-01', NULL, NULL, NULL, NULL, 'BASE', NULL, NULL, '2026-05-13 14:10:01', '2026-05-13 15:01:00'),
(3, 3, 3, 'PLAYER', 'TEST', NULL, '2001-05-01', NULL, NULL, 1, 'PITCHER', NULL, NULL, NULL, '2026-05-13 14:19:13', '2026-05-13 14:19:13');

-- --------------------------------------------------------

--
-- Table structure for table `user_tokens`
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
  `is_revoked` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Active session tokens per user device';

--
-- Dumping data for table `user_tokens`
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
(14, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6Ijc2NTMxYTEwZDkzZmE4YmU0NjIyMjg5ODgzZTdjNjgzIiwiZW1haWwiOiJqc2FuY2hlei4xOTgzQGdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImlzcyI6ImJhc2ViYWxsLXRtcyIsImF1ZCI6ImJhc2ViYWxsLXRtcy1jbGllbnRzIiwiaWF0IjoxNzc4NzA5NzA0LCJleHAiOjE3Nzg3MTY5MDR9.smRsojAfsDA7GwayLypPUGVTgQCInklW0wCDv025ZC4', 'Web Frontend', 'web', '::1', '2026-05-13 17:01:44', '2026-05-13 16:13:00', 0, '2026-05-13 15:01:44');

-- --------------------------------------------------------

--
-- Table structure for table `venues`
--

DROP TABLE IF EXISTS `venues`;
CREATE TABLE `venues` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Baseball fields / venues';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_user` (`user_id`),
  ADD KEY `idx_audit_table_record` (`table_name`,`record_id`),
  ADD KEY `idx_audit_created_at` (`created_at`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_categories_name` (`name`);

--
-- Indexes for table `games`
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
-- Indexes for table `game_innings`
--
ALTER TABLE `game_innings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_game_innings` (`game_id`,`inning`);

--
-- Indexes for table `player_game_stats`
--
ALTER TABLE `player_game_stats`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_player_game_stats` (`game_id`,`user_id`),
  ADD KEY `idx_pgs_user_id` (`user_id`),
  ADD KEY `idx_pgs_team_id` (`team_id`);

--
-- Indexes for table `standings`
--
ALTER TABLE `standings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_standings` (`team_id`,`category_id`,`season_year`),
  ADD KEY `idx_standings_category_season` (`category_id`,`season_year`);

--
-- Indexes for table `teams`
--
ALTER TABLE `teams`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_teams_name_category` (`name`,`category_id`),
  ADD KEY `idx_teams_category_id` (`category_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_email` (`email`),
  ADD KEY `idx_users_role` (`role`);

--
-- Indexes for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_profiles_user_id` (`user_id`),
  ADD UNIQUE KEY `uq_user_profiles_curp` (`curp`),
  ADD KEY `idx_user_profiles_team_id` (`team_id`),
  ADD KEY `idx_user_profiles_jersey` (`team_id`,`jersey_number`);

--
-- Indexes for table `user_tokens`
--
ALTER TABLE `user_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_tokens_token` (`token`(191)),
  ADD KEY `idx_user_tokens_user_id` (`user_id`),
  ADD KEY `idx_user_tokens_expires_at` (`expires_at`),
  ADD KEY `idx_user_tokens_is_revoked` (`is_revoked`);

--
-- Indexes for table `venues`
--
ALTER TABLE `venues`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_venues_name` (`name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `games`
--
ALTER TABLE `games`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `game_innings`
--
ALTER TABLE `game_innings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `player_game_stats`
--
ALTER TABLE `player_game_stats`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `standings`
--
ALTER TABLE `standings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `teams`
--
ALTER TABLE `teams`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user_tokens`
--
ALTER TABLE `user_tokens`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `venues`
--
ALTER TABLE `venues`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `games`
--
ALTER TABLE `games`
  ADD CONSTRAINT `fk_games_away_team` FOREIGN KEY (`away_team_id`) REFERENCES `teams` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_games_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_games_home_team` FOREIGN KEY (`home_team_id`) REFERENCES `teams` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_games_venue` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `game_innings`
--
ALTER TABLE `game_innings`
  ADD CONSTRAINT `fk_game_innings_game` FOREIGN KEY (`game_id`) REFERENCES `games` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `player_game_stats`
--
ALTER TABLE `player_game_stats`
  ADD CONSTRAINT `fk_pgs_game` FOREIGN KEY (`game_id`) REFERENCES `games` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pgs_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pgs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `standings`
--
ALTER TABLE `standings`
  ADD CONSTRAINT `fk_standings_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_standings_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `teams`
--
ALTER TABLE `teams`
  ADD CONSTRAINT `fk_teams_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `fk_user_profiles_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `user_tokens`
--
ALTER TABLE `user_tokens`
  ADD CONSTRAINT `fk_user_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
