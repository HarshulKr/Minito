-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: minito_db
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `AdminID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`AdminID`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES (1,'Hansika Admin','hansika.admin@gmail.com'),(2,'System Admin','admin@minito.com'),(3,'Operations Head','ops@minito.com'),(4,'Tech Admin','tech@minito.com'),(5,'Super Admin','superadmin@minito.com');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart`
--

DROP TABLE IF EXISTS `cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart` (
  `CustomerID` int NOT NULL,
  `ProductID` int NOT NULL,
  `Quantity` int DEFAULT NULL,
  PRIMARY KEY (`CustomerID`,`ProductID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `cart_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`CustomerID`),
  CONSTRAINT `cart_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart`
--

LOCK TABLES `cart` WRITE;
/*!40000 ALTER TABLE `cart` DISABLE KEYS */;
INSERT INTO `cart` VALUES (4,15,2),(207,215,1);
/*!40000 ALTER TABLE `cart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `CategoryID` int NOT NULL AUTO_INCREMENT,
  `CategoryName` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`CategoryID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,'Grocery'),(2,'Pharmaceutical'),(3,'Electronics');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comboitems`
--

DROP TABLE IF EXISTS `comboitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comboitems` (
  `ComboID` int NOT NULL,
  `ProductID` int NOT NULL,
  PRIMARY KEY (`ComboID`,`ProductID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `comboitems_ibfk_1` FOREIGN KEY (`ComboID`) REFERENCES `combos` (`ComboID`),
  CONSTRAINT `comboitems_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comboitems`
--

LOCK TABLES `comboitems` WRITE;
/*!40000 ALTER TABLE `comboitems` DISABLE KEYS */;
INSERT INTO `comboitems` VALUES (6,1),(15,2),(9,3),(6,4),(1,8),(12,11),(12,14),(15,21),(15,23),(15,24),(9,27),(9,29),(1,31),(6,35),(2,39),(12,41),(1,46),(2,50),(12,50),(9,51),(16,57),(19,57),(16,58),(23,59),(16,65),(25,67),(25,69),(25,70),(24,71),(24,74),(24,75),(24,76),(4,81),(10,81),(4,84),(10,84),(17,85),(10,87),(23,90),(11,93),(11,94),(11,95),(11,96),(7,107),(7,108),(7,109),(13,112),(14,113),(26,114),(3,118),(26,119),(3,120),(3,122),(13,125),(26,128),(8,132),(8,133),(8,135),(13,139),(23,141),(14,142),(14,150),(22,157),(5,161),(22,166),(21,167),(21,171),(5,174),(21,174),(4,177),(17,180),(17,181),(20,187),(5,191),(18,191),(19,192),(5,193),(18,193),(19,194),(18,195),(20,203),(20,205);
/*!40000 ALTER TABLE `comboitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `combos`
--

DROP TABLE IF EXISTS `combos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `combos` (
  `ComboID` int NOT NULL AUTO_INCREMENT,
  `ComboName` varchar(100) DEFAULT NULL,
  `BasePrice` decimal(10,2) DEFAULT NULL,
  `CategoryID` int DEFAULT NULL,
  PRIMARY KEY (`ComboID`),
  KEY `CategoryID` (`CategoryID`),
  CONSTRAINT `combos_ibfk_1` FOREIGN KEY (`CategoryID`) REFERENCES `category` (`CategoryID`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `combos`
--

LOCK TABLES `combos` WRITE;
/*!40000 ALTER TABLE `combos` DISABLE KEYS */;
INSERT INTO `combos` VALUES (1,'Maggi Party Combo',150.00,1),(2,'Italian Dinner',400.00,1),(3,'Monsoon Care',250.00,2),(4,'Grooming Kit',500.00,1),(5,'Work From Home',1200.00,3),(6,'Morning Breakfast',250.00,1),(7,'Healthy Snacking',900.00,1),(8,'First Aid Kit',200.00,2),(9,'Movie Night',150.00,1),(10,'Hygiene Essentials',250.00,1),(11,'Fresh Veggies',150.00,1),(12,'Essential Groceries',800.00,1),(13,'Cold Relief',200.00,2),(14,'Fever Care',1600.00,2),(15,'Tea Time',120.00,1),(16,'Energy Boost',350.00,1),(17,'Hair Care',2500.00,1),(18,'PC Peripherals',1800.00,3),(19,'Gamer Pack',2000.00,3),(20,'Smart Home Starter',6000.00,3),(21,'Fast Charging',1500.00,3),(22,'Audio Enthusiast',7000.00,3),(23,'Winter Care',400.00,1),(24,'Cleaning Supplies',450.00,1),(25,'Choco Delight',850.00,1),(26,'Special Flash Deal: Gelusil Tablet Bundle',NULL,1);
/*!40000 ALTER TABLE `combos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custombaskets`
--

DROP TABLE IF EXISTS `custombaskets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `custombaskets` (
  `BasketID` int NOT NULL AUTO_INCREMENT,
  `CustomerID` int DEFAULT NULL,
  `BasketName` varchar(100) DEFAULT NULL,
  `ProductIDs` json DEFAULT NULL,
  PRIMARY KEY (`BasketID`),
  KEY `CustomerID` (`CustomerID`),
  CONSTRAINT `custombaskets_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`CustomerID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custombaskets`
--

LOCK TABLES `custombaskets` WRITE;
/*!40000 ALTER TABLE `custombaskets` DISABLE KEYS */;
INSERT INTO `custombaskets` VALUES (2,2,'gulabi','[81, 87, 147]'),(3,2,'meow','[81, 87, 147, 27]'),(4,3,'aanya','[167, 171, 174, 208]');
/*!40000 ALTER TABLE `custombaskets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer` (
  `CustomerID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Address` varchar(100) DEFAULT NULL,
  `PhoneNumber` varchar(15) DEFAULT NULL,
  `WalletBalance` decimal(10,2) DEFAULT '5000.00',
  PRIMARY KEY (`CustomerID`),
  UNIQUE KEY `PhoneNumber` (`PhoneNumber`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB AUTO_INCREMENT=208 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (2,'Harshul','harshul@gmail.com','Delhi','9000000002',2471.00),(3,'Aanya','aanya@gmail.com','Delhi','9000000003',22993.00),(4,'Aarav','aarav4@gmail.com','Delhi','9000000004',5000.00),(6,'Aarav','aarav6@gmail.com','Delhi','9000000006',5000.00),(8,'Aarav','aarav8@gmail.com','Delhi','9000000008',5000.00),(9,'Vivaan','vivaan9@gmail.com','Delhi','9000000009',5000.00),(10,'Vivaan','vivaan10@gmail.com','Delhi','9000000010',5000.00),(11,'Vivaan','vivaan11@gmail.com','Delhi','9000000011',5000.00),(12,'Vivaan','vivaan12@gmail.com','Delhi','9000000012',5000.00),(13,'Vivaan','vivaan13@gmail.com','Delhi','9000000013',5000.00),(14,'Aditya','aditya14@gmail.com','Delhi','9000000014',5000.00),(15,'Aditya','aditya15@gmail.com','Delhi','9000000015',5000.00),(16,'Aditya','aditya16@gmail.com','Delhi','9000000016',5000.00),(17,'Aditya','aditya17@gmail.com','Delhi','9000000017',5000.00),(18,'Aditya','aditya18@gmail.com','Delhi','9000000018',5000.00),(19,'Krishna','krishna19@gmail.com','Delhi','9000000019',5000.00),(20,'Krishna','krishna20@gmail.com','Delhi','9000000020',5000.00),(21,'Krishna','krishna21@gmail.com','Delhi','9000000021',5000.00),(22,'Krishna','krishna22@gmail.com','Delhi','9000000022',5000.00),(23,'Krishna','krishna23@gmail.com','Delhi','9000000023',5000.00),(24,'Ishaan','ishaan24@gmail.com','Delhi','9000000024',5000.00),(25,'Ishaan','ishaan25@gmail.com','Delhi','9000000025',5000.00),(26,'Ishaan','ishaan26@gmail.com','Delhi','9000000026',5000.00),(27,'Ishaan','ishaan27@gmail.com','Delhi','9000000027',5000.00),(28,'Ishaan','ishaan28@gmail.com','Delhi','9000000028',5000.00),(29,'Ananya','ananya29@gmail.com','Delhi','9000000029',5000.00),(30,'Ananya','ananya30@gmail.com','Delhi','9000000030',5000.00),(31,'Ananya','ananya31@gmail.com','Delhi','9000000031',5000.00),(32,'Ananya','ananya32@gmail.com','Delhi','9000000032',5000.00),(33,'Ananya','ananya33@gmail.com','Delhi','9000000033',5000.00),(34,'Diya','diya34@gmail.com','Delhi','9000000034',5000.00),(35,'Diya','diya35@gmail.com','Delhi','9000000035',5000.00),(36,'Diya','diya36@gmail.com','Delhi','9000000036',5000.00),(37,'Diya','diya37@gmail.com','Delhi','9000000037',5000.00),(38,'Diya','diya38@gmail.com','Delhi','9000000038',5000.00),(39,'Myra','myra39@gmail.com','Delhi','9000000039',5000.00),(40,'Myra','myra40@gmail.com','Delhi','9000000040',5000.00),(41,'Myra','myra41@gmail.com','Delhi','9000000041',5000.00),(42,'Myra','myra42@gmail.com','Delhi','9000000042',5000.00),(43,'Myra','myra43@gmail.com','Delhi','9000000043',5000.00),(44,'Riya','riya44@gmail.com','Delhi','9000000044',5000.00),(45,'Riya','riya45@gmail.com','Delhi','9000000045',5000.00),(46,'Riya','riya46@gmail.com','Delhi','9000000046',5000.00),(47,'Riya','riya47@gmail.com','Delhi','9000000047',5000.00),(48,'Riya','riya48@gmail.com','Delhi','9000000048',5000.00),(49,'Sara','sara49@gmail.com','Delhi','9000000049',5000.00),(50,'Sara','sara50@gmail.com','Delhi','9000000050',5000.00),(51,'Sara','sara51@gmail.com','Delhi','9000000051',5000.00),(52,'Sara','sara52@gmail.com','Delhi','9000000052',5000.00),(53,'Sara','sara53@gmail.com','Delhi','9000000053',5000.00),(54,'Arjun','arjun54@gmail.com','Delhi','9000000054',5000.00),(55,'Arjun','arjun55@gmail.com','Delhi','9000000055',5000.00),(56,'Arjun','arjun56@gmail.com','Delhi','9000000056',5000.00),(57,'Arjun','arjun57@gmail.com','Delhi','9000000057',5000.00),(58,'Arjun','arjun58@gmail.com','Delhi','9000000058',5000.00),(59,'Kabir','kabir59@gmail.com','Delhi','9000000059',5000.00),(60,'Kabir','kabir60@gmail.com','Delhi','9000000060',5000.00),(61,'Kabir','kabir61@gmail.com','Delhi','9000000061',5000.00),(62,'Kabir','kabir62@gmail.com','Delhi','9000000062',5000.00),(63,'Kabir','kabir63@gmail.com','Delhi','9000000063',5000.00),(64,'Rohan','rohan64@gmail.com','Delhi','9000000064',5000.00),(65,'Rohan','rohan65@gmail.com','Delhi','9000000065',5000.00),(66,'Rohan','rohan66@gmail.com','Delhi','9000000066',5000.00),(67,'Rohan','rohan67@gmail.com','Delhi','9000000067',5000.00),(68,'Rohan','rohan68@gmail.com','Delhi','9000000068',5000.00),(69,'Kunal','kunal69@gmail.com','Delhi','9000000069',5000.00),(70,'Kunal','kunal70@gmail.com','Delhi','9000000070',5000.00),(71,'Kunal','kunal71@gmail.com','Delhi','9000000071',5000.00),(72,'Kunal','kunal72@gmail.com','Delhi','9000000072',5000.00),(73,'Kunal','kunal73@gmail.com','Delhi','9000000073',5000.00),(74,'Rahul','rahul74@gmail.com','Delhi','9000000074',5000.00),(75,'Rahul','rahul75@gmail.com','Delhi','9000000075',5000.00),(76,'Rahul','rahul76@gmail.com','Delhi','9000000076',5000.00),(77,'Rahul','rahul77@gmail.com','Delhi','9000000077',5000.00),(78,'Rahul','rahul78@gmail.com','Delhi','9000000078',5000.00),(79,'Sneha','sneha79@gmail.com','Delhi','9000000079',5000.00),(80,'Sneha','sneha80@gmail.com','Delhi','9000000080',5000.00),(81,'Sneha','sneha81@gmail.com','Delhi','9000000081',5000.00),(82,'Sneha','sneha82@gmail.com','Delhi','9000000082',5000.00),(83,'Sneha','sneha83@gmail.com','Delhi','9000000083',5000.00),(84,'Pooja','pooja84@gmail.com','Delhi','9000000084',5000.00),(85,'Pooja','pooja85@gmail.com','Delhi','9000000085',5000.00),(86,'Pooja','pooja86@gmail.com','Delhi','9000000086',5000.00),(87,'Pooja','pooja87@gmail.com','Delhi','9000000087',5000.00),(88,'Pooja','pooja88@gmail.com','Delhi','9000000088',5000.00),(89,'Neha','neha89@gmail.com','Delhi','9000000089',5000.00),(90,'Neha','neha90@gmail.com','Delhi','9000000090',5000.00),(91,'Neha','neha91@gmail.com','Delhi','9000000091',5000.00),(92,'Neha','neha92@gmail.com','Delhi','9000000092',5000.00),(93,'Neha','neha93@gmail.com','Delhi','9000000093',5000.00),(94,'Isha','isha94@gmail.com','Delhi','9000000094',5000.00),(95,'Isha','isha95@gmail.com','Delhi','9000000095',5000.00),(96,'Isha','isha96@gmail.com','Delhi','9000000096',5000.00),(97,'Isha','isha97@gmail.com','Delhi','9000000097',5000.00),(98,'Isha','isha98@gmail.com','Delhi','9000000098',5000.00),(99,'Meera','meera99@gmail.com','Delhi','9000000099',5000.00),(100,'Meera','meera100@gmail.com','Delhi','9000000100',5000.00),(101,'Meera','meera101@gmail.com','Delhi','9000000101',5000.00),(102,'Meera','meera102@gmail.com','Delhi','9000000102',5000.00),(103,'Meera','meera103@gmail.com','Delhi','9000000103',5000.00),(104,'Yash','yash104@gmail.com','Delhi','9000000104',5000.00),(105,'Yash','yash105@gmail.com','Delhi','9000000105',5000.00),(106,'Yash','yash106@gmail.com','Delhi','9000000106',5000.00),(107,'Yash','yash107@gmail.com','Delhi','9000000107',5000.00),(108,'Yash','yash108@gmail.com','Delhi','9000000108',5000.00),(109,'Dev','dev109@gmail.com','Delhi','9000000109',5000.00),(110,'Dev','dev110@gmail.com','Delhi','9000000110',5000.00),(111,'Dev','dev111@gmail.com','Delhi','9000000111',5000.00),(112,'Dev','dev112@gmail.com','Delhi','9000000112',5000.00),(113,'Dev','dev113@gmail.com','Delhi','9000000113',5000.00),(114,'Aryan','aryan114@gmail.com','Delhi','9000000114',5000.00),(115,'Aryan','aryan115@gmail.com','Delhi','9000000115',5000.00),(116,'Aryan','aryan116@gmail.com','Delhi','9000000116',5000.00),(117,'Aryan','aryan117@gmail.com','Delhi','9000000117',5000.00),(118,'Aryan','aryan118@gmail.com','Delhi','9000000118',5000.00),(119,'Shiv','shiv119@gmail.com','Delhi','9000000119',5000.00),(120,'Shiv','shiv120@gmail.com','Delhi','9000000120',5000.00),(121,'Shiv','shiv121@gmail.com','Delhi','9000000121',5000.00),(122,'Shiv','shiv122@gmail.com','Delhi','9000000122',5000.00),(123,'Shiv','shiv123@gmail.com','Delhi','9000000123',5000.00),(124,'Om','om124@gmail.com','Delhi','9000000124',5000.00),(125,'Om','om125@gmail.com','Delhi','9000000125',5000.00),(126,'Om','om126@gmail.com','Delhi','9000000126',5000.00),(127,'Om','om127@gmail.com','Delhi','9000000127',5000.00),(128,'Om','om128@gmail.com','Delhi','9000000128',5000.00),(129,'Tanvi','tanvi129@gmail.com','Delhi','9000000129',5000.00),(130,'Tanvi','tanvi130@gmail.com','Delhi','9000000130',5000.00),(131,'Tanvi','tanvi131@gmail.com','Delhi','9000000131',5000.00),(132,'Tanvi','tanvi132@gmail.com','Delhi','9000000132',5000.00),(133,'Tanvi','tanvi133@gmail.com','Delhi','9000000133',5000.00),(134,'Kavya','kavya134@gmail.com','Delhi','9000000134',5000.00),(135,'Kavya','kavya135@gmail.com','Delhi','9000000135',5000.00),(136,'Kavya','kavya136@gmail.com','Delhi','9000000136',5000.00),(137,'Kavya','kavya137@gmail.com','Delhi','9000000137',5000.00),(138,'Kavya','kavya138@gmail.com','Delhi','9000000138',5000.00),(139,'Nisha','nisha139@gmail.com','Delhi','9000000139',5000.00),(140,'Nisha','nisha140@gmail.com','Delhi','9000000140',5000.00),(141,'Nisha','nisha141@gmail.com','Delhi','9000000141',5000.00),(142,'Nisha','nisha142@gmail.com','Delhi','9000000142',5000.00),(143,'Nisha','nisha143@gmail.com','Delhi','9000000143',5000.00),(144,'Aditi','aditi144@gmail.com','Delhi','9000000144',5000.00),(145,'Aditi','aditi145@gmail.com','Delhi','9000000145',5000.00),(146,'Aditi','aditi146@gmail.com','Delhi','9000000146',5000.00),(147,'Aditi','aditi147@gmail.com','Delhi','9000000147',5000.00),(148,'Aditi','aditi148@gmail.com','Delhi','9000000148',5000.00),(149,'Simran','simran149@gmail.com','Delhi','9000000149',5000.00),(150,'Simran','simran150@gmail.com','Delhi','9000000150',5000.00),(151,'Simran','simran151@gmail.com','Delhi','9000000151',5000.00),(152,'Simran','simran152@gmail.com','Delhi','9000000152',5000.00),(153,'Simran','simran153@gmail.com','Delhi','9000000153',5000.00),(154,'Varun','varun154@gmail.com','Delhi','9000000154',5000.00),(155,'Varun','varun155@gmail.com','Delhi','9000000155',5000.00),(156,'Varun','varun156@gmail.com','Delhi','9000000156',5000.00),(157,'Varun','varun157@gmail.com','Delhi','9000000157',5000.00),(158,'Varun','varun158@gmail.com','Delhi','9000000158',5000.00),(159,'Siddharth','siddharth159@gmail.com','Delhi','9000000159',5000.00),(160,'Siddharth','siddharth160@gmail.com','Delhi','9000000160',5000.00),(161,'Siddharth','siddharth161@gmail.com','Delhi','9000000161',5000.00),(162,'Siddharth','siddharth162@gmail.com','Delhi','9000000162',5000.00),(163,'Siddharth','siddharth163@gmail.com','Delhi','9000000163',5000.00),(164,'Aman','aman164@gmail.com','Delhi','9000000164',5000.00),(165,'Aman','aman165@gmail.com','Delhi','9000000165',5000.00),(166,'Aman','aman166@gmail.com','Delhi','9000000166',5000.00),(167,'Aman','aman167@gmail.com','Delhi','9000000167',5000.00),(168,'Aman','aman168@gmail.com','Delhi','9000000168',5000.00),(169,'Nikhil','nikhil169@gmail.com','Delhi','9000000169',5000.00),(170,'Nikhil','nikhil170@gmail.com','Delhi','9000000170',5000.00),(171,'Nikhil','nikhil171@gmail.com','Delhi','9000000171',5000.00),(172,'Nikhil','nikhil172@gmail.com','Delhi','9000000172',5000.00),(173,'Nikhil','nikhil173@gmail.com','Delhi','9000000173',5000.00),(174,'Rajat','rajat174@gmail.com','Delhi','9000000174',5000.00),(175,'Rajat','rajat175@gmail.com','Delhi','9000000175',5000.00),(176,'Rajat','rajat176@gmail.com','Delhi','9000000176',5000.00),(177,'Rajat','rajat177@gmail.com','Delhi','9000000177',5000.00),(178,'Rajat','rajat178@gmail.com','Delhi','9000000178',5000.00),(179,'Priya','priya179@gmail.com','Delhi','9000000179',5000.00),(180,'Priya','priya180@gmail.com','Delhi','9000000180',5000.00),(183,'Priya','priya183@gmail.com','Delhi','9000000183',5000.00),(184,'Sakshi','sakshi184@gmail.com','Delhi','9000000184',5000.00),(185,'Sakshi','sakshi185@gmail.com','Delhi','9000000185',5000.00),(186,'Sakshi','sakshi186@gmail.com','Delhi','9000000186',5000.00),(187,'Sakshi','sakshi187@gmail.com','Delhi','9000000187',5000.00),(188,'Sakshi','sakshi188@gmail.com','Delhi','9000000188',5000.00),(189,'Anjali','anjali189@gmail.com','Delhi','9000000189',5000.00),(190,'Anjali','anjali190@gmail.com','Delhi','9000000190',5000.00),(191,'Anjali','anjali191@gmail.com','Delhi','9000000191',5000.00),(192,'Anjali','anjali192@gmail.com','Delhi','9000000192',5000.00),(193,'Anjali','anjali193@gmail.com','Delhi','9000000193',5000.00),(194,'Shreya','shreya194@gmail.com','Delhi','9000000194',5000.00),(195,'Shreya','shreya195@gmail.com','Delhi','9000000195',5000.00),(196,'Shreya','shreya196@gmail.com','Delhi','9000000196',5000.00),(197,'Shreya','shreya197@gmail.com','Delhi','9000000197',5000.00),(198,'Shreya','shreya198@gmail.com','Delhi','9000000198',5000.00),(199,'Ritika','ritika199@gmail.com','Delhi','9000000199',5000.00),(200,'Ritika','ritika200@gmail.com','Delhi','9000000200',5000.00),(201,'anmol','saluja143@gmail.com','delhi','8287963984',5000.00),(207,'hansika','hansika@gmail.com','delhi','9000000001',4276.00);
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `darkstore`
--

DROP TABLE IF EXISTS `darkstore`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `darkstore` (
  `StoreID` int NOT NULL AUTO_INCREMENT,
  `StoreLocation` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`StoreID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `darkstore`
--

LOCK TABLES `darkstore` WRITE;
/*!40000 ALTER TABLE `darkstore` DISABLE KEYS */;
INSERT INTO `darkstore` VALUES (1,'Delhi North'),(2,'Delhi South'),(3,'Delhi East'),(4,'Delhi West'),(5,'Noida Sector 62'),(6,'Gurgaon Cyber City'),(7,'Dwarka'),(8,'Rohini'),(9,'Saket');
/*!40000 ALTER TABLE `darkstore` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deliverypartner`
--

DROP TABLE IF EXISTS `deliverypartner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deliverypartner` (
  `PartnerID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `PhoneNumber` varchar(15) DEFAULT NULL,
  `VehicleDetails` varchar(50) DEFAULT NULL,
  `storeid` int DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT '1',
  `WalletBalance` decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (`PartnerID`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deliverypartner`
--

LOCK TABLES `deliverypartner` WRITE;
/*!40000 ALTER TABLE `deliverypartner` DISABLE KEYS */;
INSERT INTO `deliverypartner` VALUES (1,'Partner1','p1@gmail.com','9100000001','Bike',1,1,50.00),(2,'Partner2','p2@gmail.com','9100000002','Bike',3,0,0.00),(3,'Partner3','p3@gmail.com','9100000003','Scooter',9,0,0.00),(4,'Partner4','p4@gmail.com','9100000004','Bike',3,0,0.00),(5,'Partner5','p5@gmail.com','9100000005','Bike',4,0,0.00),(6,'Partner6','p6@gmail.com','9100000006','Scooter',7,0,0.00),(7,'Partner7','p7@gmail.com','9100000007','Bike',4,1,0.00),(8,'Partner8','p8@gmail.com','9100000008','Bike',5,0,0.00),(9,'Partner9','p9@gmail.com','9100000009','Scooter',1,0,150.00),(10,'Partner10','p10@gmail.com','9100000010','Bike',9,0,0.00),(11,'Partner11','p11@gmail.com','9100000011','Bike',7,0,0.00),(12,'Partner12','p12@gmail.com','9100000012','Scooter',3,1,0.00),(13,'Partner13','p13@gmail.com','9100000013','Bike',5,1,0.00),(14,'Partner14','p14@gmail.com','9100000014','Bike',7,1,0.00),(15,'Partner15','p15@gmail.com','9100000015','Scooter',5,1,0.00),(16,'Partner16','p16@gmail.com','9100000016','Bike',4,1,0.00),(17,'Partner17','p17@gmail.com','9100000017','Bike',4,1,0.00),(18,'Partner18','p18@gmail.com','9100000018','Scooter',7,1,0.00),(19,'Partner19','p19@gmail.com','9100000019','Bike',6,0,0.00),(20,'Partner20','p20@gmail.com','9100000020','Bike',7,1,0.00),(21,'Partner 21','p21@gmail.com','9100000021','Bike',2,0,0.00),(22,'Partner 22','p22@gmail.com','9100000022','Scooter',2,0,0.00),(23,'Partner 23','p23@gmail.com','9100000023','Bike',2,0,0.00);
/*!40000 ALTER TABLE `deliverypartner` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee` (
  `EmployeeID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) DEFAULT NULL,
  `Role` varchar(50) DEFAULT NULL,
  `StoreID` int DEFAULT NULL,
  PRIMARY KEY (`EmployeeID`),
  KEY `StoreID` (`StoreID`),
  CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`StoreID`) REFERENCES `darkstore` (`StoreID`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee`
--

LOCK TABLES `employee` WRITE;
/*!40000 ALTER TABLE `employee` DISABLE KEYS */;
INSERT INTO `employee` VALUES (2,'Jane Smith','Packer',1),(3,'Alice','Packer',2),(4,'Store 1 Emp 1','Packer',1),(5,'Store 1 Emp 2','Picker',1),(6,'Store 1 Emp 3','Packer',1),(7,'Store 1 Emp 4','Picker',1),(8,'Store 1 Emp 5','Packer',1),(9,'Store 2 Emp 1','Packer',2),(10,'Store 2 Emp 2','Picker',2),(11,'Store 2 Emp 3','Packer',2),(12,'Store 2 Emp 4','Picker',2),(13,'Store 2 Emp 5','Packer',2),(14,'Store 3 Emp 1','Packer',3),(15,'Store 3 Emp 2','Picker',3),(16,'Store 3 Emp 3','Packer',3),(17,'Store 3 Emp 4','Picker',3),(18,'Store 3 Emp 5','Packer',3),(19,'Store 4 Emp 1','Packer',4),(20,'Store 4 Emp 2','Picker',4),(21,'Store 4 Emp 3','Packer',4),(22,'Store 4 Emp 4','Picker',4),(23,'Store 4 Emp 5','Packer',4),(24,'Store 5 Emp 1','Packer',5),(25,'Store 5 Emp 2','Picker',5),(26,'Store 5 Emp 3','Packer',5),(27,'Store 5 Emp 4','Picker',5),(28,'Store 5 Emp 5','Packer',5),(29,'Store 6 Emp 1','Packer',6),(30,'Store 6 Emp 2','Picker',6),(31,'Store 6 Emp 3','Packer',6),(32,'Store 6 Emp 4','Picker',6),(33,'Store 6 Emp 5','Packer',6),(34,'Store 7 Emp 1','Packer',7),(35,'Store 7 Emp 2','Picker',7),(36,'Store 7 Emp 3','Packer',7),(37,'Store 7 Emp 4','Picker',7),(38,'Store 7 Emp 5','Packer',7),(39,'Store 8 Emp 1','Packer',8),(40,'Store 8 Emp 2','Picker',8),(41,'Store 8 Emp 3','Packer',8),(42,'Store 8 Emp 4','Picker',8),(43,'Store 8 Emp 5','Packer',8),(44,'Store 9 Emp 1','Packer',9),(45,'Store 9 Emp 2','Picker',9),(46,'Store 9 Emp 3','Packer',9),(47,'Store 9 Emp 4','Picker',9),(48,'Store 9 Emp 5','Packer',9);
/*!40000 ALTER TABLE `employee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orderitem`
--

DROP TABLE IF EXISTS `orderitem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderitem` (
  `OrderItemID` int NOT NULL AUTO_INCREMENT,
  `OrderID` int DEFAULT NULL,
  `ProductID` int DEFAULT NULL,
  `QuantityOrdered` int DEFAULT NULL,
  PRIMARY KEY (`OrderItemID`),
  KEY `OrderID` (`OrderID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `orderitem_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`),
  CONSTRAINT `orderitem_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ProductID`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderitem`
--

LOCK TABLES `orderitem` WRITE;
/*!40000 ALTER TABLE `orderitem` DISABLE KEYS */;
INSERT INTO `orderitem` VALUES (3,2,10,3),(4,3,20,2),(5,4,30,1),(74,27,2,2),(75,27,26,1),(76,27,27,1),(77,27,32,1),(78,27,81,1),(79,27,87,1),(80,27,147,1),(81,28,39,1),(82,28,50,1),(83,29,9,1),(84,30,13,1),(85,31,9,1),(86,31,32,1),(87,32,32,1),(88,33,210,1),(89,34,161,1),(90,35,166,1),(91,36,174,1),(92,37,191,1),(93,38,193,1),(94,39,10,1),(95,40,10,3),(96,40,167,1),(97,41,171,1),(98,42,174,1),(99,43,208,1),(100,44,32,1),(101,45,211,2),(102,46,1,1),(103,47,215,1);
/*!40000 ALTER TABLE `orderitem` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `OrderID` int NOT NULL AUTO_INCREMENT,
  `OrderDateTime` datetime DEFAULT NULL,
  `OrderStatus` varchar(20) DEFAULT NULL,
  `TotalBillAmount` decimal(10,2) DEFAULT NULL,
  `CustomerID` int DEFAULT NULL,
  `StoreID` int DEFAULT NULL,
  `DeliveryPartnerID` int DEFAULT NULL,
  `CommissionEarned` decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (`OrderID`),
  KEY `CustomerID` (`CustomerID`),
  KEY `StoreID` (`StoreID`),
  KEY `DeliveryPartnerID` (`DeliveryPartnerID`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`CustomerID`),
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`StoreID`) REFERENCES `darkstore` (`StoreID`),
  CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`DeliveryPartnerID`) REFERENCES `deliverypartner` (`PartnerID`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (2,'2026-04-07 01:28:44','Out for Delivery',450.00,2,2,2,0.00),(3,'2026-04-07 01:28:44','Packed',200.00,3,3,3,0.00),(4,'2026-04-07 01:28:44','Packed',600.00,4,4,4,0.00),(27,'2026-04-08 20:13:12','Packed',402.00,2,4,5,0.00),(28,'2026-04-09 01:48:17','Packed',148.00,207,2,21,0.00),(29,'2026-04-09 02:18:28','Delivered',130.00,207,1,1,50.00),(30,'2026-04-09 02:18:28','Packed',240.00,207,2,22,0.00),(31,'2026-04-09 03:01:55','Delivered',142.00,207,1,9,50.00),(32,'2026-04-09 03:02:23','Delivered',12.00,207,1,9,50.00),(33,'2026-04-09 03:37:40','Delivered',20.00,207,1,9,50.00),(34,'2026-04-09 03:37:49','Placed',799.00,2,9,3,0.00),(35,'2026-04-09 03:37:49','Placed',5999.00,2,2,23,0.00),(36,'2026-04-09 03:37:49','Placed',199.00,2,3,2,0.00),(37,'2026-04-09 03:37:49','Placed',799.00,2,8,NULL,0.00),(38,'2026-04-09 03:37:49','Placed',699.00,2,5,8,0.00),(39,'2026-04-09 03:46:37','Placed',70.00,2,7,6,0.00),(40,'2026-04-09 11:50:01','Placed',1209.00,3,7,11,0.00),(41,'2026-04-09 11:50:01','Placed',599.00,3,9,10,0.00),(42,'2026-04-09 11:50:01','Placed',199.00,3,3,4,0.00),(43,'2026-04-09 11:50:02','Placed',80000.00,3,2,NULL,0.00),(44,'2026-04-09 14:27:16','Placed',12.00,207,1,NULL,0.00),(45,'2026-04-09 15:07:16','Placed',20.00,207,1,NULL,0.00),(46,'2026-04-09 15:09:40','Placed',60.00,2,6,19,0.00),(47,'2026-04-09 15:20:42','Picked',2.00,2,1,9,0.00);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment` (
  `PaymentID` int NOT NULL AUTO_INCREMENT,
  `PaymentMethod` varchar(20) DEFAULT NULL,
  `PaymentStatus` varchar(20) DEFAULT NULL,
  `OrderID` int DEFAULT NULL,
  PRIMARY KEY (`PaymentID`),
  KEY `OrderID` (`OrderID`),
  CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment`
--

LOCK TABLES `payment` WRITE;
/*!40000 ALTER TABLE `payment` DISABLE KEYS */;
INSERT INTO `payment` VALUES (2,'Cash',NULL,2),(3,'Card',NULL,3),(4,'UPI',NULL,4);
/*!40000 ALTER TABLE `payment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `ProductID` int NOT NULL AUTO_INCREMENT,
  `ProductName` varchar(100) DEFAULT NULL,
  `Brand` varchar(50) DEFAULT NULL,
  `Price` decimal(10,2) DEFAULT NULL,
  `CategoryID` int DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `is_flash_sale` tinyint(1) DEFAULT '0',
  `original_price` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`ProductID`),
  KEY `CategoryID` (`CategoryID`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`CategoryID`) REFERENCES `category` (`CategoryID`)
) ENGINE=InnoDB AUTO_INCREMENT=216 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'Amul Milk 1L','Amul',60.00,1,'2026-11-05',0,NULL),(2,'Amul Milk 500ml','Amul',30.00,1,'2026-09-26',0,NULL),(3,'Mother Dairy Milk 1L','Mother Dairy',58.00,1,'2026-07-04',0,NULL),(4,'Amul Butter 500g','Amul',250.00,1,'2026-09-17',0,NULL),(5,'Amul Butter 100g','Amul',55.00,1,'2026-10-21',0,NULL),(6,'Amul Paneer 200g','Amul',120.00,1,'2026-07-20',0,NULL),(7,'Amul Cheese Cubes','Amul',140.00,1,'2026-10-17',0,NULL),(8,'Britannia Cheese Slices','Britannia',150.00,1,'2026-08-23',0,NULL),(9,'Nestle Milkmaid','Nestle',130.00,1,'2026-09-30',0,NULL),(10,'Amul Fresh Cream','Amul',70.00,1,'2026-05-27',0,NULL),(11,'Aashirvaad Atta 5kg','ITC',250.00,1,'2026-12-27',0,NULL),(12,'Aashirvaad Atta 1kg','ITC',55.00,1,'2026-05-09',0,NULL),(13,'Fortune Chakki Atta','Fortune',240.00,1,'2026-08-09',0,NULL),(14,'India Gate Basmati Rice 5kg','India Gate',450.00,1,'2026-09-10',0,NULL),(15,'India Gate Rice 1kg','India Gate',90.00,1,'2026-07-04',0,NULL),(16,'Tata Sampann Toor Dal','Tata',180.00,1,'2026-10-25',0,NULL),(17,'Tata Sampann Chana Dal','Tata',140.00,1,'2026-09-30',0,NULL),(18,'Fortune Besan 1kg','Fortune',120.00,1,'2026-11-26',0,NULL),(19,'Rajdhani Poha','Rajdhani',60.00,1,'2026-12-10',0,NULL),(20,'Rajma Red 1kg','Local',160.00,1,'2026-05-31',0,NULL),(21,'Parle-G Biscuits','Parle',10.00,1,'2026-06-11',0,NULL),(22,'Parle Krackjack','Parle',30.00,1,'2026-08-16',0,NULL),(23,'Britannia Good Day','Britannia',35.00,1,'2026-07-10',0,NULL),(24,'Britannia Marie Gold','Britannia',30.00,1,'2026-09-21',0,NULL),(25,'Oreo Biscuits','Cadbury',40.00,1,'2026-10-24',0,NULL),(26,'Hide & Seek','Parle',50.00,1,'2026-05-13',0,NULL),(27,'Lays Classic Chips','Lays',20.00,1,'2026-09-01',0,NULL),(28,'Lays Cream & Onion','Lays',20.00,1,'2026-05-28',0,NULL),(29,'Kurkure Masala','Kurkure',20.00,1,'2026-05-27',0,NULL),(30,'Bingo Mad Angles','ITC',25.00,1,'2026-12-15',0,NULL),(31,'Maggi Noodles','Nestle',14.00,1,'2026-08-27',0,NULL),(32,'Maggi Masala Pack','Nestle',12.00,1,'2026-11-26',0,NULL),(33,'Yippee Noodles','ITC',15.00,1,'2026-05-16',0,NULL),(34,'Top Ramen','Nissin',20.00,1,'2026-12-05',0,NULL),(35,'Kellogg Cornflakes','Kellogg',180.00,1,'2026-09-06',0,NULL),(36,'Kellogg Chocos','Kellogg',190.00,1,'2026-10-28',0,NULL),(37,'Quaker Oats','Quaker',150.00,1,'2026-05-24',0,NULL),(38,'Saffola Oats','Saffola',160.00,1,'2026-11-11',0,NULL),(39,'Pasta Penne','Del Monte',120.00,1,'2026-12-31',0,NULL),(40,'Pasta Fusilli','Del Monte',130.00,1,'2026-06-29',0,NULL),(41,'Fortune Sunflower Oil 1L','Fortune',140.00,1,'2026-11-13',0,NULL),(42,'Fortune Mustard Oil','Fortune',160.00,1,'2027-02-09',0,NULL),(43,'Saffola Gold Oil','Saffola',180.00,1,'2026-05-08',0,NULL),(44,'Dhara Oil','Dhara',150.00,1,'2026-06-04',0,NULL),(45,'Kissan Tomato Ketchup','Kissan',120.00,1,'2026-09-29',0,NULL),(46,'Maggi Hot & Sweet Sauce','Nestle',130.00,1,'2026-09-04',0,NULL),(47,'Veeba Mayonnaise','Veeba',140.00,1,'2026-05-29',0,NULL),(48,'Everest Garam Masala','Everest',60.00,1,'2026-10-31',0,NULL),(49,'MDH Kitchen King','MDH',55.00,1,'2026-10-30',0,NULL),(50,'Tata Salt 1kg','Tata',28.00,1,'2026-09-15',0,NULL),(51,'Coca Cola 1L','Coca Cola',60.00,1,'2026-06-02',0,NULL),(52,'Pepsi 1L','Pepsi',60.00,1,'2026-09-09',0,NULL),(53,'Sprite 1L','Coca Cola',60.00,1,'2026-10-24',0,NULL),(54,'Fanta Orange','Coca Cola',60.00,1,'2026-12-01',0,NULL),(55,'Real Orange Juice','Real',110.00,1,'2026-07-10',0,NULL),(56,'Tropicana Juice','Tropicana',120.00,1,'2026-10-27',0,NULL),(57,'Red Bull Energy Drink','Red Bull',120.00,1,'2026-08-11',0,NULL),(58,'Bournvita Health Drink','Cadbury',250.00,1,'2026-10-29',0,NULL),(59,'Horlicks Classic','Horlicks',260.00,1,'2026-05-20',0,NULL),(60,'Boost Energy Drink','Boost',240.00,1,'2026-08-08',0,NULL),(61,'Dairy Milk','Cadbury',40.00,1,'2026-07-24',0,NULL),(62,'KitKat','Nestle',20.00,1,'2026-11-12',0,NULL),(63,'Perk','Cadbury',10.00,1,'2026-05-09',0,NULL),(64,'Munch','Nestle',10.00,1,'2026-08-12',0,NULL),(65,'Snickers','Mars',50.00,1,'2026-09-07',0,NULL),(66,'5 Star','Cadbury',30.00,1,'2026-10-26',0,NULL),(67,'Ferrero Rocher Pack','Ferrero',500.00,1,'2026-12-04',0,NULL),(68,'Milky Bar','Nestle',25.00,1,'2026-10-13',0,NULL),(69,'Galaxy Chocolate','Mars',60.00,1,'2026-05-26',0,NULL),(70,'Toblerone','Toblerone',300.00,1,'2026-12-26',0,NULL),(71,'Surf Excel 1kg','Surf',200.00,1,'2026-10-24',0,NULL),(72,'Ariel Detergent','Ariel',210.00,1,'2026-10-06',0,NULL),(73,'Rin Detergent Bar','Rin',25.00,1,'2026-06-26',0,NULL),(74,'Vim Dishwash Bar','Vim',30.00,1,'2026-11-11',0,NULL),(75,'Lizol Floor Cleaner','Lizol',37.50,1,'2026-04-13',1,75.00),(76,'Harpic Toilet Cleaner','Harpic',120.00,1,'2026-10-18',0,NULL),(77,'Colin Glass Cleaner','Colin',90.00,1,'2026-08-15',0,NULL),(78,'Dettol Liquid','Dettol',100.00,1,'2026-08-04',0,NULL),(79,'Savlon Handwash','Savlon',120.00,1,'2026-12-05',0,NULL),(80,'Godrej Air Freshener','Godrej',140.00,1,'2026-12-21',0,NULL),(81,'Dove Soap','Dove',50.00,1,'2026-06-25',0,NULL),(82,'Lux Soap','Lux',40.00,1,'2026-08-09',0,NULL),(83,'Pears Soap','Pears',60.00,1,'2026-10-03',0,NULL),(84,'Clinic Plus Shampoo','Clinic Plus',120.00,1,'2026-06-07',0,NULL),(85,'Head & Shoulders Shampoo','H&S',180.00,1,'2026-11-14',0,NULL),(86,'Pantene Shampoo','Pantene',170.00,1,'2026-09-12',0,NULL),(87,'Colgate Toothpaste','Colgate',90.00,1,'2026-08-18',0,NULL),(88,'Closeup Toothpaste','Closeup',85.00,1,'2026-08-11',0,NULL),(89,'Oral B Toothbrush','Oral B',70.00,1,'2026-10-07',0,NULL),(90,'Nivea Cream','Nivea',120.00,1,'2026-07-08',0,NULL),(91,'Apple 1kg Pack','Fresh',150.00,1,'2026-11-25',0,NULL),(92,'Banana 1 Dozen','Fresh',60.00,1,'2026-06-16',0,NULL),(93,'Potato 1kg Pack','Fresh',30.00,1,'2026-05-23',0,NULL),(94,'Onion 1kg Pack','Fresh',40.00,1,'2026-10-17',0,NULL),(95,'Tomato 1kg Pack','Fresh',35.00,1,'2026-08-27',0,NULL),(96,'Carrot 1kg Pack','Fresh',50.00,1,'2026-10-15',0,NULL),(97,'Cabbage 1pc','Fresh',40.00,1,'2026-08-13',0,NULL),(98,'Capsicum 500g','Fresh',60.00,1,'2026-09-20',0,NULL),(99,'Spinach Bundle','Fresh',20.00,1,'2026-09-12',0,NULL),(100,'Green Peas 500g','Fresh',80.00,1,'2026-08-08',0,NULL),(101,'Frozen French Fries','McCain',150.00,1,'2026-10-12',0,NULL),(102,'Frozen Peas','Safal',120.00,1,'2026-09-09',0,NULL),(103,'Frozen Corn','Safal',130.00,1,'2026-07-29',0,NULL),(104,'Frozen Nuggets','Yummiez',200.00,1,'2026-07-22',0,NULL),(105,'Ice Cream Vanilla','Amul',180.00,1,'2026-07-10',0,NULL),(106,'Ice Cream Chocolate','Kwality Walls',200.00,1,'2026-06-01',0,NULL),(107,'Almonds 500g','Happilo',400.00,1,'2026-05-25',0,NULL),(108,'Cashews 500g','Happilo',450.00,1,'2026-09-24',0,NULL),(109,'Raisins 500g','Happilo',300.00,1,'2026-05-21',0,NULL),(110,'Pistachios 250g','Happilo',350.00,1,'2026-12-21',0,NULL),(111,'Dates Pack','Lion',200.00,1,'2026-11-25',0,NULL),(112,'Crocin 500mg Tablet','GSK',20.00,2,'2026-11-05',0,NULL),(113,'Dolo 650 Tablet','Micro Labs',30.00,2,'2026-11-26',0,NULL),(114,'Combiflam Tablet','Sanofi',35.00,2,'2026-07-20',0,NULL),(115,'Calpol 650','GSK',28.00,2,'2026-07-09',0,NULL),(116,'Brufen Tablet','Abbott',25.00,2,'2026-06-24',0,NULL),(117,'Aspirin Tablet','Bayer',15.00,2,'2026-09-13',0,NULL),(118,'Limcee Vitamin C','Abbott',30.00,2,'2026-12-04',0,NULL),(119,'Shelcal Calcium','Torrent',45.00,2,'2026-11-09',0,NULL),(120,'Zincovit Tablet','Apex',50.00,2,'2026-12-27',0,NULL),(121,'Revital Capsules','Ranbaxy',120.00,2,'2026-05-03',0,NULL),(122,'Benadryl Cough Syrup','Johnson & Johnson',120.00,2,'2026-07-28',0,NULL),(123,'Corex Cough Syrup','Pfizer',130.00,2,'2026-07-29',0,NULL),(124,'Ascoril Syrup','Glenmark',110.00,2,'2026-08-23',0,NULL),(125,'Honitus Cough Syrup','Dabur',105.00,2,'2026-09-12',0,NULL),(126,'Zedex Syrup','Dr Reddy',115.00,2,'2026-09-26',0,NULL),(127,'Digene Antacid','Abbott',25.00,2,'2026-08-22',0,NULL),(128,'Gelusil Tablet','Pfizer',30.00,2,'2026-05-02',0,NULL),(129,'ENO Powder','ENO',10.00,2,'2026-10-09',0,NULL),(130,'Pantocid Tablet','Sun Pharma',50.00,2,'2026-07-17',0,NULL),(131,'Rantac Tablet','JB Chemicals',40.00,2,'2026-10-22',0,NULL),(132,'Band Aid Strips','Johnson & Johnson',40.00,2,'2026-08-12',0,NULL),(133,'Dettol Antiseptic Liquid','Dettol',100.00,2,'2026-07-21',0,NULL),(134,'Savlon Antiseptic','Savlon',90.00,2,'2026-08-04',0,NULL),(135,'Cotton Roll','Generic',30.00,2,'2026-06-07',0,NULL),(136,'Crepe Bandage','Generic',80.00,2,'2026-08-15',0,NULL),(137,'Volini Spray','Sun Pharma',180.00,2,'2026-06-12',0,NULL),(138,'Moov Pain Relief','Paras',160.00,2,'2026-05-01',0,NULL),(139,'Vicks Vaporub','Vicks',90.00,2,'2026-08-14',0,NULL),(140,'Burnol Cream','Dr Morepen',70.00,2,'2026-09-06',0,NULL),(141,'Boroline Antiseptic Cream','Boroline',50.00,2,'2026-10-18',0,NULL),(142,'Electral ORS','FDC',20.00,2,'2026-11-12',0,NULL),(143,'ORS Sachet','Dabur',18.00,2,'2026-12-02',0,NULL),(144,'Pudin Hara','Dabur',35.00,2,'2026-09-04',0,NULL),(145,'Hajmola Tablets','Dabur',30.00,2,'2026-12-12',0,NULL),(146,'Gas-O-Fast','ENO',25.00,2,'2026-07-21',0,NULL),(147,'Stayfree Sanitary Pads','Stayfree',120.00,2,'2026-06-24',0,NULL),(148,'Whisper Ultra Pads','Whisper',130.00,2,'2026-05-24',0,NULL),(149,'N95 Mask Pack','Generic',150.00,2,'2026-09-15',0,NULL),(150,'Digital Thermometer','Omron',250.00,2,'2026-06-01',0,NULL),(151,'BP Monitor','Dr Trust',1500.00,2,'2026-08-24',0,NULL),(152,'Horlicks Protein Plus','Horlicks',350.00,2,'2026-08-27',0,NULL),(153,'Ensure Health Drink','Abbott',650.00,2,'2026-09-06',0,NULL),(154,'Protinex Powder','Dabur',500.00,2,'2026-07-06',0,NULL),(155,'HealthKart Multivitamin','HK',400.00,2,'2026-06-10',0,NULL),(156,'MuscleBlaze Protein Bar','MB',120.00,2,'2026-05-06',0,NULL),(157,'Boat Airdopes 141','Boat',1299.00,3,NULL,0,NULL),(158,'Boat Rockerz 255','Boat',1499.00,3,NULL,0,NULL),(159,'Realme Buds Air','Realme',1999.00,3,NULL,0,NULL),(160,'Noise Buds VS104','Noise',1499.00,3,NULL,0,NULL),(161,'JBL C100 Wired Earphones','JBL',799.00,3,NULL,0,NULL),(162,'Sony Headphones ZX110','Sony',1799.00,3,NULL,0,NULL),(163,'OnePlus Nord Buds','OnePlus',2299.00,3,NULL,0,NULL),(164,'Boult Audio Airbass','Boult',1399.00,3,NULL,0,NULL),(165,'boAt Stone Speaker','Boat',1999.00,3,NULL,0,NULL),(166,'JBL Flip Speaker','JBL',5999.00,3,NULL,0,NULL),(167,'Mi Power Bank 10000mAh','Xiaomi',999.00,3,NULL,0,NULL),(168,'Mi Power Bank 20000mAh','Xiaomi',1499.00,3,NULL,0,NULL),(169,'Ambrane Power Bank','Ambrane',899.00,3,NULL,0,NULL),(170,'Boat Charger 18W','Boat',499.00,3,NULL,0,NULL),(171,'Mi Fast Charger','Xiaomi',599.00,3,NULL,0,NULL),(172,'Samsung Charger 25W','Samsung',999.00,3,NULL,0,NULL),(173,'Portronics Power Adapter','Portronics',699.00,3,NULL,0,NULL),(174,'USB Type-C Cable','Generic',199.00,3,NULL,0,NULL),(175,'Lightning Cable','Apple',999.00,3,NULL,0,NULL),(176,'Extension Board','Havells',799.00,3,NULL,0,NULL),(177,'Philips Trimmer','Philips',1999.00,3,NULL,0,NULL),(178,'Nova Trimmer','Nova',999.00,3,NULL,0,NULL),(179,'Mi Beard Trimmer','Xiaomi',1499.00,3,NULL,0,NULL),(180,'Syska Hair Dryer','Syska',1299.00,3,NULL,0,NULL),(181,'Philips Hair Straightener','Philips',2499.00,3,NULL,0,NULL),(182,'Havells Trimmer','Havells',1799.00,3,NULL,0,NULL),(183,'VEGA Hair Dryer','VEGA',999.00,3,NULL,0,NULL),(184,'Nova Hair Straightener','Nova',899.00,3,NULL,0,NULL),(185,'Syska LED Bulb 9W','Syska',150.00,3,NULL,0,NULL),(186,'Philips LED Bulb','Philips',180.00,3,NULL,0,NULL),(187,'Wipro Smart Bulb','Wipro',799.00,3,NULL,0,NULL),(188,'Mi Smart LED Bulb','Xiaomi',899.00,3,NULL,0,NULL),(189,'Emergency Light','Eveready',1200.00,3,NULL,0,NULL),(190,'Table Lamp','Philips',1500.00,3,NULL,0,NULL),(191,'Wireless Mouse','Logitech',799.00,3,NULL,0,NULL),(192,'Gaming Mouse','Redgear',999.00,3,NULL,0,NULL),(193,'Keyboard USB','HP',699.00,3,NULL,0,NULL),(194,'Laptop Cooling Pad','Zebronics',999.00,3,NULL,0,NULL),(195,'Pendrive 32GB','SanDisk',499.00,3,NULL,0,NULL),(196,'Pendrive 64GB','HP',699.00,3,NULL,0,NULL),(197,'External Hard Disk 1TB','Seagate',3999.00,3,NULL,0,NULL),(198,'Memory Card 64GB','SanDisk',799.00,3,NULL,0,NULL),(199,'Mi Smart Band','Xiaomi',1999.00,3,NULL,0,NULL),(200,'Noise Smart Watch','Noise',2499.00,3,NULL,0,NULL),(201,'Boat Smart Watch','Boat',2999.00,3,NULL,0,NULL),(202,'Fire-Boltt Smart Watch','Fireboltt',1999.00,3,NULL,0,NULL),(203,'Amazon Echo Dot','Amazon',4499.00,3,NULL,0,NULL),(204,'Google Nest Mini','Google',4499.00,3,NULL,0,NULL),(205,'Smart Plug','Wipro',999.00,3,NULL,0,NULL),(206,'CCTV Camera','CP Plus',2999.00,3,NULL,0,NULL),(207,'chocolate milkshake','calvin\'s',40.00,1,'2026-05-13',0,NULL),(208,'Iphone 15','apple',80000.00,3,NULL,0,NULL),(209,'Ipad','apple',100000.00,3,NULL,0,NULL),(210,'milk','dairy',20.00,1,NULL,0,NULL),(211,'biscuit','bourbon',10.00,1,NULL,0,NULL),(212,'Expired Milk',NULL,60.00,1,'2026-04-07',0,NULL),(213,'Fresh Yogurt',NULL,45.00,1,'2026-04-19',0,NULL),(214,'Cheddar Cheese',NULL,120.00,1,'2026-05-09',0,NULL),(215,'biscuit','mnh',2.00,1,NULL,0,NULL);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `storeinventory`
--

DROP TABLE IF EXISTS `storeinventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `storeinventory` (
  `StoreID` int NOT NULL,
  `ProductID` int NOT NULL,
  `Quantity` int DEFAULT NULL,
  PRIMARY KEY (`StoreID`,`ProductID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `storeinventory_ibfk_1` FOREIGN KEY (`StoreID`) REFERENCES `darkstore` (`StoreID`),
  CONSTRAINT `storeinventory_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `storeinventory`
--

LOCK TABLES `storeinventory` WRITE;
/*!40000 ALTER TABLE `storeinventory` DISABLE KEYS */;
INSERT INTO `storeinventory` VALUES (1,9,110),(1,32,93),(1,41,64),(1,50,90),(1,59,32),(1,72,96),(1,77,73),(1,81,43),(1,82,62),(1,83,116),(1,89,66),(1,93,111),(1,95,52),(1,104,93),(1,132,71),(1,144,64),(1,145,29),(1,155,71),(1,181,114),(1,192,29),(1,194,81),(1,210,5),(1,211,0),(1,212,50),(1,213,50),(1,214,50),(1,215,0),(2,13,75),(2,16,115),(2,21,20),(2,26,118),(2,28,62),(2,42,60),(2,75,33),(2,114,28),(2,119,82),(2,126,65),(2,128,62),(2,143,112),(2,149,74),(2,150,45),(2,152,53),(2,153,74),(2,166,62),(2,172,53),(2,173,71),(2,180,32),(2,185,116),(2,199,97),(2,208,9),(2,209,20),(3,4,83),(3,14,81),(3,15,80),(3,46,103),(3,51,53),(3,67,64),(3,69,22),(3,85,28),(3,90,98),(3,91,97),(3,92,93),(3,101,97),(3,110,45),(3,118,95),(3,134,32),(3,139,52),(3,146,102),(3,157,109),(3,159,87),(3,162,94),(3,170,72),(3,174,106),(3,179,80),(4,6,116),(4,17,91),(4,24,37),(4,27,105),(4,37,116),(4,63,88),(4,64,110),(4,65,114),(4,71,62),(4,76,39),(4,88,42),(4,96,97),(4,103,103),(4,107,116),(4,121,95),(4,131,42),(4,154,43),(5,5,76),(5,22,45),(5,31,28),(5,48,96),(5,56,22),(5,70,33),(5,79,24),(5,94,91),(5,98,102),(5,106,112),(5,133,92),(5,147,96),(5,148,32),(5,156,91),(5,186,42),(5,193,105),(5,206,98),(6,1,103),(6,2,54),(6,8,55),(6,20,118),(6,29,63),(6,30,62),(6,45,58),(6,47,63),(6,49,75),(6,53,82),(6,60,46),(6,62,22),(6,68,56),(6,86,65),(6,105,59),(6,109,20),(6,111,104),(6,120,21),(6,123,70),(6,125,92),(6,129,65),(6,141,86),(6,160,89),(6,168,26),(6,175,28),(6,182,103),(6,183,51),(6,188,87),(6,197,88),(6,200,64),(6,201,66),(6,205,98),(6,208,10),(6,209,5),(7,10,49),(7,18,111),(7,35,51),(7,36,45),(7,39,60),(7,43,100),(7,54,34),(7,74,102),(7,78,66),(7,84,66),(7,87,105),(7,100,42),(7,112,96),(7,116,36),(7,122,31),(7,130,106),(7,167,108),(7,169,47),(7,202,114),(8,12,66),(8,19,115),(8,38,20),(8,52,117),(8,61,116),(8,66,109),(8,80,86),(8,108,118),(8,142,87),(8,151,107),(8,164,86),(8,176,87),(8,191,84),(8,196,114),(8,203,99),(8,204,77),(9,7,41),(9,11,22),(9,25,117),(9,33,107),(9,34,84),(9,55,21),(9,57,52),(9,73,102),(9,97,97),(9,99,81),(9,113,114),(9,115,24),(9,117,95),(9,124,79),(9,135,111),(9,137,88),(9,158,76),(9,161,34),(9,171,71),(9,187,81),(9,189,50);
/*!40000 ALTER TABLE `storeinventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `storemanager`
--

DROP TABLE IF EXISTS `storemanager`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `storemanager` (
  `ManagerID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `StoreID` int DEFAULT NULL,
  `WalletBalance` decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (`ManagerID`),
  KEY `StoreID` (`StoreID`),
  CONSTRAINT `storemanager_ibfk_1` FOREIGN KEY (`StoreID`) REFERENCES `darkstore` (`StoreID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `storemanager`
--

LOCK TABLES `storemanager` WRITE;
/*!40000 ALTER TABLE `storemanager` DISABLE KEYS */;
INSERT INTO `storemanager` VALUES (1,'Manager1','m1@gmail.com',1,5318.00),(2,'Manager2','m2@gmail.com',2,86887.00),(3,'Manager3','m3@gmail.com',3,3094.00),(4,'Manager4','m4@gmail.com',4,1002.00),(5,'Manager5','m5@gmail.com',5,849.00),(6,'Manager6','m6@gmail.com',6,60.00),(7,'Manager7','m7@gmail.com',7,1279.00),(8,'Manager8','m8@gmail.com',8,799.00),(9,'Manager9','m9@gmail.com',9,1398.00);
/*!40000 ALTER TABLE `storemanager` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_names`
--

DROP TABLE IF EXISTS `temp_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temp_names` (
  `name` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_names`
--

LOCK TABLES `temp_names` WRITE;
/*!40000 ALTER TABLE `temp_names` DISABLE KEYS */;
INSERT INTO `temp_names` VALUES ('Aarav'),('Vivaan'),('Aditya'),('Krishna'),('Ishaan'),('Ananya'),('Diya'),('Myra'),('Riya'),('Sara'),('Arjun'),('Kabir'),('Rohan'),('Kunal'),('Rahul'),('Sneha'),('Pooja'),('Neha'),('Isha'),('Meera'),('Yash'),('Dev'),('Aryan'),('Shiv'),('Om'),('Tanvi'),('Kavya'),('Nisha'),('Aditi'),('Simran'),('Varun'),('Siddharth'),('Aman'),('Nikhil'),('Rajat'),('Priya'),('Sakshi'),('Anjali'),('Shreya'),('Ritika');
/*!40000 ALTER TABLE `temp_names` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userbasketitems`
--

DROP TABLE IF EXISTS `userbasketitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `userbasketitems` (
  `BasketID` int NOT NULL,
  `ProductID` int NOT NULL,
  PRIMARY KEY (`BasketID`,`ProductID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `userbasketitems_ibfk_1` FOREIGN KEY (`BasketID`) REFERENCES `userbaskets` (`BasketID`),
  CONSTRAINT `userbasketitems_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userbasketitems`
--

LOCK TABLES `userbasketitems` WRITE;
/*!40000 ALTER TABLE `userbasketitems` DISABLE KEYS */;
/*!40000 ALTER TABLE `userbasketitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userbaskets`
--

DROP TABLE IF EXISTS `userbaskets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `userbaskets` (
  `BasketID` int NOT NULL AUTO_INCREMENT,
  `CustomerID` int DEFAULT NULL,
  `BasketName` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`BasketID`),
  KEY `CustomerID` (`CustomerID`),
  CONSTRAINT `userbaskets_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`CustomerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userbaskets`
--

LOCK TABLES `userbaskets` WRITE;
/*!40000 ALTER TABLE `userbaskets` DISABLE KEYS */;
/*!40000 ALTER TABLE `userbaskets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wallettransfers`
--

DROP TABLE IF EXISTS `wallettransfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallettransfers` (
  `TransferID` int NOT NULL AUTO_INCREMENT,
  `CustomerID` int DEFAULT NULL,
  `ManagerID` int DEFAULT NULL,
  `Amount` decimal(10,2) DEFAULT NULL,
  `TransferDate` datetime DEFAULT NULL,
  `OrderID` int DEFAULT NULL,
  PRIMARY KEY (`TransferID`),
  KEY `CustomerID` (`CustomerID`),
  KEY `ManagerID` (`ManagerID`),
  KEY `OrderID` (`OrderID`),
  CONSTRAINT `wallettransfers_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`CustomerID`),
  CONSTRAINT `wallettransfers_ibfk_2` FOREIGN KEY (`ManagerID`) REFERENCES `storemanager` (`ManagerID`),
  CONSTRAINT `wallettransfers_ibfk_3` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallettransfers`
--

LOCK TABLES `wallettransfers` WRITE;
/*!40000 ALTER TABLE `wallettransfers` DISABLE KEYS */;
INSERT INTO `wallettransfers` VALUES (5,2,4,402.00,'2026-04-08 20:13:12',27),(6,207,2,148.00,'2026-04-09 01:48:17',28),(7,207,1,130.00,'2026-04-09 02:18:28',29),(8,207,2,240.00,'2026-04-09 02:18:28',30),(9,207,1,142.00,'2026-04-09 03:01:55',31),(10,207,1,12.00,'2026-04-09 03:02:23',32),(11,207,1,20.00,'2026-04-09 03:37:40',33),(12,2,9,799.00,'2026-04-09 03:37:49',34),(13,2,2,5999.00,'2026-04-09 03:37:49',35),(14,2,3,199.00,'2026-04-09 03:37:49',36),(15,2,8,799.00,'2026-04-09 03:37:49',37),(16,2,5,699.00,'2026-04-09 03:37:49',38),(17,2,7,70.00,'2026-04-09 03:46:37',39),(18,3,7,1209.00,'2026-04-09 11:50:01',40),(19,3,9,599.00,'2026-04-09 11:50:01',41),(20,3,3,199.00,'2026-04-09 11:50:01',42),(21,3,2,80000.00,'2026-04-09 11:50:02',43),(22,207,1,12.00,'2026-04-09 14:27:16',44),(23,207,1,20.00,'2026-04-09 15:07:16',45),(24,2,6,60.00,'2026-04-09 15:09:40',46),(25,2,1,2.00,'2026-04-09 15:20:42',47);
/*!40000 ALTER TABLE `wallettransfers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'minito_db'
--

--
-- Dumping routines for database 'minito_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-15 18:26:32
