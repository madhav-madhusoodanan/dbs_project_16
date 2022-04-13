create schema add_crs_substi_crs;  
USE add_crs_substi_crs;

create table course (
crsName varchar(30) not null unique,
availSeats int not null, 
crsCreds int not null,
crsID int not null unique,
totSeats int not null,
primary key(crsID)
);
create table student (
totCreds int not null,
availCreds int not null,
stdName varchar(30) not null,
stdID int not null unique, 
primary key(stdID)
);
create table opted ( 
stdID int not null, 
crsID int not null, 
foreign key(crsID) references course(crsID), 
foreign key(stdID) references student(stdID), 
primary key(stdID, crsID)
); 
INSERT INTO
course(crsName, crsID, totSeats, availSeats, crsCreds)
VALUES
("DBS",100, 6, 4, 4),
("Math", 101 , 4 , 2 , 3),
("GC", 102 ,5 , 2, 3),
("TRW",103, 7, 5, 2),
("WP",104, 3, 1, 2);  
INSERT INTO 
student(stdName, stdID, totCreds, availCreds)
VALUES
("A", 001, 10,7), 
("B", 002, 10, 5), 
("C",003, 10, 4), 
("D", 004, 10, 2), 
("E", 005, 10, 1); 
INSERT INTO 
opted(stdID,crsID)
VALUES
(001,101), 
(002,102), 
(002,103), 
(003,101),
(003,102), 
(004,100), 
(004,103),
(004,104),
(005,100),
(005,102), 
(005,104);   
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `substi_crs`(IN tstdID int, IN toldcrsID int, IN tnewcrsID int)
READS SQL DATA
NOT DETERMINISTIC
SQL SECURITY INVOKER
BEGIN 
DECLARE nCrsCreds int default 0;
DECLARE availSeats int default 0;
DECLARE availCreds int default 0;
DECLARE oCrsCreds int default 0;
select crsCreds INTO  oCrsCreds from course where course.crsID = toldcrsID; 
select crsCreds INTO  nCrsCreds from course where course.crsID = tnewcrsID; 
select availSeats INTO availSeats from course where course.crsID = tnewcrsID;
select availCreds INTO availCreds from student where student.stdID = tstdID; 
IF (((tstdID,toldcrsID) IN (select * from ADD_SUB_Window.opted)) AND NOT((tstdID,tnewcrsID) IN (select * from ADD_SUB_Window.opted))) THEN  
IF((availSeats > 0) and (nCrsCreds <= (oCrsCreds + availCreds))) THEN
DELETE from ADD_SUB_Window.opted 
where (opted.stdID = tstdID and opted.crsID = toldcrsID);
UPDATE ADD_SUB_Window.student SET student.availCreds = student.availCreds + oCrsCreds WHERE student.stdID = tstdID; 
UPDATE ADD_SUB_Window.course SET course.availSeats = course.availSeats + 1 WHERE course.crsID = toldcrsID;
call add_crs(tstdID,tnewcrsID);
ELSE 
SIGNAL SQLSTATE '45000' SET message_text = 'substi_crs not Succesful';
END IF;
ELSE 
SIGNAL SQLSTATE '45000' SET message_text = 'substi_crs not Succesful';
END IF;
END$$ 
DELIMITER ;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_crs`(IN tstdID int, IN tcrsID int)
READS SQL DATA
NOT DETERMINISTIC
SQL SECURITY INVOKER
BEGIN
DECLARE availSeats int default 0; 
DECLARE availCreds int default 0; 
DECLARE courseCreds int default 0; 
select availSeats INTO availSeats from course where course.crsID = tcrsID; 
select availCreds INTO availCreds from student where student.stdID = tstdID; 
select crsCreds INTO  courseCreds from course where course.crsID = tcrsID; 
IF (availSeats > 0 AND availCreds >= courseCreds AND NOT((tstdID,tcrsID) IN (select * from ADD_SUB_Window.opted))) THEN 
INSERT INTO ADD_SUB_Window.opted VALUES (tstdID, tcrsID); 
UPDATE ADD_SUB_Window.student SET student.availCreds = student.availCreds - courseCreds WHERE student.stdID = tstdID; 
UPDATE ADD_SUB_Window.course SET course.availSeats = course.availSeats - 1 WHERE course.crsID = tcrsID;
ELSE 
SIGNAL SQLSTATE '45000' SET message_text = 'add_crs ERROR';        
END IF; 
END$$ 
DELIMITER ;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `allCrs`(IN tstdID int)
READS SQL DATA
NOT DETERMINISTIC
SQL SECURITY INVOKER
BEGIN
select opted.crsID from ADD_SUB_Window.opted where opted.stdID = tstdID;  
select * from ADD_SUB_Window.student where student.stdID = tstdID;
END$$ 
DELIMITER ;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CrsDetails`(IN tcrsID int)
READS SQL DATA
NOT DETERMINISTIC
SQL SECURITY INVOKER
BEGIN
select * from ADD_SUB_Window.course where course.crsID = tcrsID;
END$$ 
DELIMITER ; 
select * from opted; 
call substi_crs(001,100,103); 
call substi_crs(002,102,100); 
call add_crs(003,100); 
call substi_crs(004,103,101);
call add_crs(005,103);

-- drop table opted; 
-- drop table course;
-- drop table student; 
-- drop database add_crs_substi_crs;