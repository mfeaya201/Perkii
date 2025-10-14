

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


CREATE DATABASE IF NOT EXISTS `perkii_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `perkii_db`;



CREATE TABLE `admintb` (
  `adminID` int(10) UNSIGNED NOT NULL,
  `fullName` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



INSERT INTO `admintb` (`adminID`, `fullName`, `email`, `password`) VALUES
(1, 'Admin', 'admin@gmail.com', 'admin123');

-- --------------------------------------------------------



CREATE TABLE `businesstb` (
  `businessID` int(10) UNSIGNED NOT NULL,
  `businessName` varchar(255) NOT NULL,
  `category` varchar(255) DEFAULT NULL,
  `logoURL` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



INSERT INTO `businesstb` (`businessID`, `businessName`, `category`, `logoURL`) VALUES
(1, 'Campus Cafe', 'Coffee Shop', 'https://example.com/logos/campus-cafe.png'),
(2, 'Fit & Fresh', 'Health Store', 'https://example.com/logos/fit-fresh.png');



CREATE TABLE `customertb` (
  `customerID` int(10) UNSIGNED NOT NULL,
  `customerName` varchar(255) NOT NULL,
  `customerSurname` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


INSERT INTO `customertb` (`customerID`, `customerName`, `customerSurname`, `phone`, `email`) VALUES
(1, 'Alice', 'Moyo', '0712345678', 'alice@gmail.com'),
(2, 'Brian', 'Naidoo', '0723456789', 'brian@gmail.com'),
(3, 'Chantel', 'Peters', '0734567890', 'chantel@gmail.com');



CREATE TABLE `membershiptb` (
  `membershipID` int(10) UNSIGNED NOT NULL,
  `customerID` int(10) UNSIGNED NOT NULL,
  `programID` int(10) UNSIGNED NOT NULL,
  `pointsBalance` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



INSERT INTO `membershiptb` (`membershipID`, `customerID`, `programID`, `pointsBalance`) VALUES
(1, 1, 1, 20),
(2, 1, 3, 40),
(3, 2, 1, 90),
(4, 2, 2, 50),
(5, 3, 3, 85);



CREATE TABLE `programtb` (
  `programID` int(10) UNSIGNED NOT NULL,
  `businessID` int(10) UNSIGNED NOT NULL,
  `programTitle` varchar(255) NOT NULL,
  `pointsPerCurrency` decimal(10,2) NOT NULL,
  `active` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


INSERT INTO `programtb` (`programID`, `businessID`, `programTitle`, `pointsPerCurrency`, `active`) VALUES
(1, 1, 'Cafe Points', 1.00, 1),
(2, 1, 'Cafe VIP (Double Points)', 2.00, 1),
(3, 2, 'Fit Rewards', 0.50, 1);



CREATE TABLE `rewardtb` (
  `rewardID` int(10) UNSIGNED NOT NULL,
  `programID` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `pointsCost` int(10) UNSIGNED NOT NULL,
  `expiryDays` int(11) DEFAULT NULL,
  `active` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



INSERT INTO `rewardtb` (`rewardID`, `programID`, `name`, `description`, `pointsCost`, `expiryDays`, `active`) VALUES
(1, 1, 'Free Small Coffee', 'Any small coffee', 100, 90, 1),
(2, 1, 'Muffin Combo', 'Small coffee + muffin', 180, 90, 1),
(3, 2, 'Large Coffee', 'Any large coffee', 150, 60, 1),
(4, 3, 'Protein Bar', 'Any flavour protein bar', 80, 60, 1),
(5, 3, 'R50 Voucher', 'R50 off next purchase', 250, 30, 1);



CREATE TABLE `transactiontb` (
  `transactionID` int(10) UNSIGNED NOT NULL,
  `membershipID` int(10) UNSIGNED NOT NULL,
  `rewardID` int(10) UNSIGNED DEFAULT NULL,
  `transactionType` varchar(255) NOT NULL,
  `pointChanges` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



INSERT INTO `transactiontb` (`transactionID`, `membershipID`, `rewardID`, `transactionType`, `pointChanges`) VALUES
(1, 1, NULL, 'EARN', 120),
(2, 2, NULL, 'EARN', 40),
(3, 3, NULL, 'EARN', 90),
(4, 4, NULL, 'EARN', 200),
(5, 5, NULL, 'EARN', 85),
(6, 1, 1, 'SPEND', -100),
(7, 4, 3, 'SPEND', -150);


ALTER TABLE `admintb`
ADD PRIMARY KEY (`adminID`);

ALTER TABLE `businesstb`
ADD PRIMARY KEY (`businessID`);


ALTER TABLE `customertb`
ADD PRIMARY KEY (`customerID`);

ALTER TABLE `membershiptb`
ADD PRIMARY KEY (`membershipID`),
ADD UNIQUE KEY `uq_customer_program` (`customerID`,`programID`),
ADD KEY `fk_membership_program` (`programID`);


ALTER TABLE `programtb`
ADD PRIMARY KEY (`programID`),
ADD KEY `fk_program_business` (`businessID`);

ALTER TABLE `rewardtb`
ADD PRIMARY KEY (`rewardID`),
ADD KEY `fk_reward_program` (`programID`);

ALTER TABLE `transactiontb`
ADD PRIMARY KEY (`transactionID`),
ADD KEY `fk_txn_membership` (`membershipID`),
ADD KEY `fk_txn_reward` (`rewardID`);


ALTER TABLE `admintb`
MODIFY `adminID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

ALTER TABLE `businesstb`
MODIFY `businessID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;


ALTER TABLE `customertb`
MODIFY `customerID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

ALTER TABLE `membershiptb`
MODIFY `membershipID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

ALTER TABLE `programtb`
MODIFY `programID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

ALTER TABLE `rewardtb`
MODIFY `rewardID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

ALTER TABLE `transactiontb`
MODIFY `transactionID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

ALTER TABLE `membershiptb`
ADD CONSTRAINT `fk_membership_customer` FOREIGN KEY (`customerID`) REFERENCES `customertb` (`customerID`) ON DELETE CASCADE,
ADD CONSTRAINT `fk_membership_program` FOREIGN KEY (`programID`) REFERENCES `programtb` (`programID`) ON DELETE CASCADE;


ALTER TABLE `programtb`
ADD CONSTRAINT `fk_program_business` FOREIGN KEY (`businessID`) REFERENCES `businesstb` (`businessID`) ON DELETE CASCADE;


ALTER TABLE `rewardtb`
ADD CONSTRAINT `fk_reward_program` FOREIGN KEY (`programID`) REFERENCES `programtb` (`programID`) ON DELETE CASCADE;


ALTER TABLE `transactiontb`
ADD CONSTRAINT `fk_txn_membership` FOREIGN KEY (`membershipID`) REFERENCES `membershiptb` (`membershipID`) ON DELETE CASCADE,
ADD CONSTRAINT `fk_txn_reward` FOREIGN KEY (`rewardID`) REFERENCES `rewardtb` (`rewardID`) ON DELETE SET NULL;
COMMIT;

