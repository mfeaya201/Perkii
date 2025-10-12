-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 12, 2025 at 03:20 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `perkii_db`
--
CREATE DATABASE IF NOT EXISTS `perkii_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `perkii_db`;

-- --------------------------------------------------------

--
-- Table structure for table `admintb`
--

CREATE TABLE `admintb` (
  `adminID` int(10) UNSIGNED NOT NULL,
  `fullName` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admintb`
--

INSERT INTO `admintb` (`adminID`, `fullName`, `email`, `password`) VALUES
(1, 'Admin', 'admin@gmail.com', 'admin123');

-- --------------------------------------------------------

--
-- Table structure for table `businesstb`
--

CREATE TABLE `businesstb` (
  `businessID` int(10) UNSIGNED NOT NULL,
  `businessName` varchar(255) NOT NULL,
  `category` varchar(255) DEFAULT NULL,
  `logoURL` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `businesstb`
--

INSERT INTO `businesstb` (`businessID`, `businessName`, `category`, `logoURL`) VALUES
(1, 'Campus Cafe', 'Coffee Shop', 'https://example.com/logos/campus-cafe.png'),
(2, 'Fit & Fresh', 'Health Store', 'https://example.com/logos/fit-fresh.png');

-- --------------------------------------------------------

--
-- Table structure for table `customertb`
--

CREATE TABLE `customertb` (
  `customerID` int(10) UNSIGNED NOT NULL,
  `customerName` varchar(255) NOT NULL,
  `customerSurname` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customertb`
--

INSERT INTO `customertb` (`customerID`, `customerName`, `customerSurname`, `phone`, `email`) VALUES
(1, 'Alice', 'Moyo', '0712345678', 'alice@gmail.com'),
(2, 'Brian', 'Naidoo', '0723456789', 'brian@gmail.com'),
(3, 'Chantel', 'Peters', '0734567890', 'chantel@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `membershiptb`
--

CREATE TABLE `membershiptb` (
  `membershipID` int(10) UNSIGNED NOT NULL,
  `customerID` int(10) UNSIGNED NOT NULL,
  `programID` int(10) UNSIGNED NOT NULL,
  `pointsBalance` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `membershiptb`
--

INSERT INTO `membershiptb` (`membershipID`, `customerID`, `programID`, `pointsBalance`) VALUES
(1, 1, 1, 20),
(2, 1, 3, 40),
(3, 2, 1, 90),
(4, 2, 2, 50),
(5, 3, 3, 85);

-- --------------------------------------------------------

--
-- Table structure for table `programtb`
--

CREATE TABLE `programtb` (
  `programID` int(10) UNSIGNED NOT NULL,
  `businessID` int(10) UNSIGNED NOT NULL,
  `programTitle` varchar(255) NOT NULL,
  `pointsPerCurrency` decimal(10,2) NOT NULL,
  `active` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `programtb`
--

INSERT INTO `programtb` (`programID`, `businessID`, `programTitle`, `pointsPerCurrency`, `active`) VALUES
(1, 1, 'Cafe Points', 1.00, 1),
(2, 1, 'Cafe VIP (Double Points)', 2.00, 1),
(3, 2, 'Fit Rewards', 0.50, 1);

-- --------------------------------------------------------

--
-- Table structure for table `rewardtb`
--

CREATE TABLE `rewardtb` (
  `rewardID` int(10) UNSIGNED NOT NULL,
  `programID` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `pointsCost` int(10) UNSIGNED NOT NULL,
  `expiryDays` int(11) DEFAULT NULL,
  `active` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rewardtb`
--

INSERT INTO `rewardtb` (`rewardID`, `programID`, `name`, `description`, `pointsCost`, `expiryDays`, `active`) VALUES
(1, 1, 'Free Small Coffee', 'Any small coffee', 100, 90, 1),
(2, 1, 'Muffin Combo', 'Small coffee + muffin', 180, 90, 1),
(3, 2, 'Large Coffee', 'Any large coffee', 150, 60, 1),
(4, 3, 'Protein Bar', 'Any flavour protein bar', 80, 60, 1),
(5, 3, 'R50 Voucher', 'R50 off next purchase', 250, 30, 1);

-- --------------------------------------------------------

--
-- Table structure for table `transactiontb`
--

CREATE TABLE `transactiontb` (
  `transactionID` int(10) UNSIGNED NOT NULL,
  `membershipID` int(10) UNSIGNED NOT NULL,
  `rewardID` int(10) UNSIGNED DEFAULT NULL,
  `transactionType` varchar(255) NOT NULL,
  `pointChanges` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transactiontb`
--

INSERT INTO `transactiontb` (`transactionID`, `membershipID`, `rewardID`, `transactionType`, `pointChanges`) VALUES
(1, 1, NULL, 'EARN', 120),
(2, 2, NULL, 'EARN', 40),
(3, 3, NULL, 'EARN', 90),
(4, 4, NULL, 'EARN', 200),
(5, 5, NULL, 'EARN', 85),
(6, 1, 1, 'SPEND', -100),
(7, 4, 3, 'SPEND', -150);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admintb`
--
ALTER TABLE `admintb`
  ADD PRIMARY KEY (`adminID`);

--
-- Indexes for table `businesstb`
--
ALTER TABLE `businesstb`
  ADD PRIMARY KEY (`businessID`);

--
-- Indexes for table `customertb`
--
ALTER TABLE `customertb`
  ADD PRIMARY KEY (`customerID`);

--
-- Indexes for table `membershiptb`
--
ALTER TABLE `membershiptb`
  ADD PRIMARY KEY (`membershipID`),
  ADD UNIQUE KEY `uq_customer_program` (`customerID`,`programID`),
  ADD KEY `fk_membership_program` (`programID`);

--
-- Indexes for table `programtb`
--
ALTER TABLE `programtb`
  ADD PRIMARY KEY (`programID`),
  ADD KEY `fk_program_business` (`businessID`);

--
-- Indexes for table `rewardtb`
--
ALTER TABLE `rewardtb`
  ADD PRIMARY KEY (`rewardID`),
  ADD KEY `fk_reward_program` (`programID`);

--
-- Indexes for table `transactiontb`
--
ALTER TABLE `transactiontb`
  ADD PRIMARY KEY (`transactionID`),
  ADD KEY `fk_txn_membership` (`membershipID`),
  ADD KEY `fk_txn_reward` (`rewardID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admintb`
--
ALTER TABLE `admintb`
  MODIFY `adminID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `businesstb`
--
ALTER TABLE `businesstb`
  MODIFY `businessID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `customertb`
--
ALTER TABLE `customertb`
  MODIFY `customerID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `membershiptb`
--
ALTER TABLE `membershiptb`
  MODIFY `membershipID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `programtb`
--
ALTER TABLE `programtb`
  MODIFY `programID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `rewardtb`
--
ALTER TABLE `rewardtb`
  MODIFY `rewardID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `transactiontb`
--
ALTER TABLE `transactiontb`
  MODIFY `transactionID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `membershiptb`
--
ALTER TABLE `membershiptb`
  ADD CONSTRAINT `fk_membership_customer` FOREIGN KEY (`customerID`) REFERENCES `customertb` (`customerID`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_membership_program` FOREIGN KEY (`programID`) REFERENCES `programtb` (`programID`) ON DELETE CASCADE;

--
-- Constraints for table `programtb`
--
ALTER TABLE `programtb`
  ADD CONSTRAINT `fk_program_business` FOREIGN KEY (`businessID`) REFERENCES `businesstb` (`businessID`) ON DELETE CASCADE;

--
-- Constraints for table `rewardtb`
--
ALTER TABLE `rewardtb`
  ADD CONSTRAINT `fk_reward_program` FOREIGN KEY (`programID`) REFERENCES `programtb` (`programID`) ON DELETE CASCADE;

--
-- Constraints for table `transactiontb`
--
ALTER TABLE `transactiontb`
  ADD CONSTRAINT `fk_txn_membership` FOREIGN KEY (`membershipID`) REFERENCES `membershiptb` (`membershipID`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_txn_reward` FOREIGN KEY (`rewardID`) REFERENCES `rewardtb` (`rewardID`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
