USE Proj_INFO_430_A8

-- Look Up Tables--
CREATE TABLE [Place_Type] (
	[Place_TypeID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[Place_Type_Name] [varchar](50) NOT NULL,
	[Description] [varchar](50) NOT NULL)

INSERT INTO Place_Type(Place_Type_Name, Description) 
VALUES('Building with classrooms', 'Different halls with classrooms'),
('Libraries', 'Different libraries across the campus'),
('Residential Buildings', 'Halls in west and north campus'),
('Gathering Areas', 'Areas like Red Square and Quad etc'),
('Administrative Buildings', 'Buildings like HUB and Schmitz')

CREATE TABLE [dbo].[Event_Type](
	[Event_TypeID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[Event_Desc] [varchar](50) NOT NULL,
	[EventTypeName] [varchar](50) NOT NULL)

INSERT INTO dbo.Event_Type(Event_Desc, EventTypeName)
VALUES ('Working out/physical activity at facility', 'Going to the Gym (IMA)'), 
('Studying at the libraries provided on campus', 'Studying at Library'),
('Eating out in the dining hall(s) provided at UW', 'Eating at North/West Campus'), 
('Partaking in rec activities at the HUB', 'HUB Recreational Activity'),
('Attending lecture(s) on campus', 'Attending Lecture Halls'),
('Tested Positive for COVID-19', 'Positive Result'),
('Tested Negative for COVID-19', 'Negative Result'),
('Need to get tested for COVID-19', 'Covid Test')

CREATE TABLE [Severity] (
  [SeverityID] INT IDENTITY(1, 1) PRIMARY KEY,
  [Severity_Desc] varchar(50) NOT NULL,
  [Severity_Name] varchar(50) NOT NULL,
  [Severity_Number] INT NOT NULL
)

INSERT INTO Severity(Severity_Desc, Severity_Name, Severity_Number)
VALUES ('No Severity - Covid Negative', 'Severity 0', 0),
('No existant severity - Covid Positive', 'Severity 1', 1),
('Mild severity - Covid Positive', 'Severity 2', 2),
('Medium severity - Covid Positive', 'Severity 3', 3),
('Close to high severity - Covid Positive', 'Severity 4', 4),
('High severity - Covid Positive', 'Severity 5', 5)

CREATE TABLE [Symptom] (
  [SymptomID] INT IDENTITY(1, 1) PRIMARY KEY,
  [Symptom_Name] varchar(50) NOT NULL,
  [Symptom_Description] varchar(100) NOT NULL,
)

INSERT INTO Symptom(Symptom_Name, Symptom_Description)
VALUES('Cough', 'irritates your throat or airways'),
('Shortness of breath', 'a tight sensation in your chest'),
('Fever', 'A fever is a body temperature that is higher than normal'),
('Fatigue', 'Fatigue is when the tiredness is often overwhelming and is not relieved by sleep and rest'),
('No taste', 'No flavor being sensed through food and drinks')

CREATE TABLE [Condition] (
  [ConditionID] INT IDENTITY(1, 1) PRIMARY KEY,
  [Condition_Name] varchar(50) NOT NULL,
  [Condition_Abbrv] varchar(50) NOT NULL,
  [Description] varchar(50) NOT NULL,
)

INSERT INTO dbo.Condition(Condition_name, Condition_Abbrv, Description)
VALUES('Cancer','CANC', 'Abnormal Cell division'),
('Diabetes','DIAB', 'Abnormally high blood glucose'),
('Obesity','OBES', 'Dangerous excess body fat'),
('Influenza','FLU', 'Common viral infection'),
('High blood pressure','HBP', 'Abnormally high blood flow'),
('NONE','NONE', 'No Underlying Condition')

CREATE TABLE [User_Type] (
  [User_TypeID] INT IDENTITY(1, 1) PRIMARY KEY,
  [User_Type_Name] varchar(50) NOT NULL,
)

INSERT INTO dbo.User_Type(User_Type_Name)
VALUES ('Student')
INSERT INTO dbo.User_Type(User_Type_Name)
VALUES ('Faculty')
INSERT INTO dbo.User_Type(User_Type_Name)
VALUES ('Professor')
INSERT INTO dbo.User_Type(User_Type_Name)
VALUES ('Official')
INSERT INTO dbo.User_Type(User_Type_Name)
VALUES ('Security')

-- Transactional Tables and Associative Entities
CREATE TABLE [Users] (
  [UserID] INT IDENTITY(1, 1) PRIMARY KEY,
  [User_Fname] varchar(50) NOT NULL,
  [User_Lname] varchar(50) NOT NULL,
  [DOB] DATE NOT NULL,
  [Contact_Num] VARCHAR(50)  NULL,
  [User_TypeID] int FOREIGN KEY REFERENCES User_Type(User_TypeID) not null
)

CREATE TABLE [Place] (
  [Place_ID] int IDENTITY(1,1) PRIMARY KEY NOT NULL,
  [Place_TypeID] int,
  [Place_Name] varchar(50),
  FOREIGN KEY ([Place_TypeID]) REFERENCES Place_Type(Place_TypeID)
)

CREATE TABLE User_Condition
(
    User_ConditionID INT IDENTITY(1,1) primary key,
UserID INT FOREIGN KEY REFERENCES Users(UserID) not null,
ConditionID INT FOREIGN KEY REFERENCES Condition(ConditionID) not null
)

CREATE TABLE Event(
 EventID int IDENTITY(1,1) PRIMARY KEY,
 PlaceID int FOREIGN KEY REFERENCES Place(Place_ID) not null,
 Event_TypeID int FOREIGN KEY REFERENCES Event_Type(Event_TypeID) not null,
 Event_Name varchar(50) not null
)
 
CREATE TABLE User_Event(
 User_EventID int IDENTITY(1,1) PRIMARY KEY,
 UserID int FOREIGN KEY REFERENCES Users(UserID) not null, 
 EventID int FOREIGN KEY REFERENCES Event(EventID) not null, 
 Scan datetime not null
)

CREATE TABLE [User_Symptom] (
  [User_SymptomID] int IDENTITY(1,1) PRIMARY KEY,
  [UserID] int FOREIGN KEY REFERENCES Users (UserID) not null,
  [SeverityID] int FOREIGN KEY REFERENCES Severity (SeverityID) not null,
  [SymptomID] int FOREIGN KEY REFERENCES Symptom (SymptomID) not null,
  [SymptomDate] DATETIME not null
)
GO 
    
-- Populating the Users Table    
DECLARE @Rand INT, @UT varchar(20)
SET @Rand = (SELECT floor(rand() * (10-5)+1))
 
SET @UT = (CASE
 WHEN @Rand = 1
 THEN 1
 WHEN @Rand = 2
 THEN 2
 WHEN @Rand = 3
 THEN 3
 WHEN @Rand = 4
 THEN 4
 ELSE 5
END)

INSERT INTO Users (User_Fname, User_Lname, DOB, Contact_Num, User_TypeID)
SELECT TOP 100000 CustomerFname, CustomerLname, DateOfBirth, PhoneNum, @UT
FROM Peeps.dbo.tblCUSTOMER
 
UPDATE Users
SET User_TypeID = 1
WHERE UserID LIKE '%1%'
GO

-- GET ID STORED PROCEDURES

-- SPROC TO GET THE EVENT_TYPE_ID
CREATE PROCEDURE GetEventTypeID
@event_type_name varchar(50),
@ET_ID int output 
AS 
BEGIN 
 SET @ET_ID = (SELECT Event_TypeID FROM Event_Type WHERE EventTypeName = @event_type_name)
END
GO

-- SPROC TO GET THE USER_ID
CREATE PROCEDURE GetUserID
@user_firstname varchar(50),
@user_lastname varchar(50),
@user_birthdate date,
@user_phone varchar(50),
@U_ID int output
AS
BEGIN 
 SET @U_ID = (SELECT UserID FROM Users WHERE User_Fname = @user_firstname AND User_Lname = @user_lastname AND DOB = @user_birthdate AND Contact_Num = @user_phone)
END
GO

-- SPROC TO GET THE PLACE_ID 
CREATE PROCEDURE GetPlaceID
@place_name varchar(50),
@P_ID int OUTPUT
AS
BEGIN 
 SET @P_ID = (Select TOP 1 Place_ID FROM Place WHERE Place_Name = @place_name)
END
GO

--SPROC TO GET PLACE_TYPE_ID
GO
CREATE PROCEDURE GetPlace_Type_ID
@place_type varchar(50),
@PT_ID INT OUTPUT
AS
BEGIN
  SET @PT_ID = (SELECT Place_TypeID FROM Place_Type WHERE Place_Type_Name = @place_type)
END
GO

-- SPROC TO GET THE USER_TYPE_ID
CREATE PROCEDURE GetUser_Type_ID
@user_type varchar(50),
@UT_ID INT OUTPUT
AS
BEGIN
  SET @UT_ID = (SELECT User_TypeID FROM User_Type WHERE User_Type_Name = @user_type)
END
GO

--SPROC TO GET Condition_ID
CREATE PROCEDURE GetConditionID_eshetn
@ConditionName varchar(50),
@CondtionAbbrv varchar(50),
@Description varchar(50),
@COND_ID INT OUTPUT
AS
BEGIN
    SET @COND_ID = (SELECT ConditionID FROM Condition WHERE Condition_Name = @ConditionName AND Condition_Abbrv = Condition_Abbrv AND Description = @Description)
END
GO

--SPROC TO GET SEVERITY_ID
CREATE PROCEDURE GetSeverityId_eshetn
@SeverityNum INT,
@SeverityName varchar(50),
@SeverityDesc varchar(50),
@SEVERITY_ID INT OUTPUT
AS
BEGIN
    SET @SEVERITY_ID = (SELECT SeverityID FROM Severity WHERE Severity_Desc = @SeverityDesc AND Severity_Name = @SeverityName AND Severity_Number = @SeverityNum)
END
GO

--SPROC TO GET SYMPTOM_ID
CREATE PROCEDURE GetSymptomId_eshetn
@SymptomName varchar(50),
@SymptomDesc varchar(120),
@SYMPTOM_ID INT OUTPUT
AS
BEGIN
    SET @SYMPTOM_ID = (SELECT SymptomID FROM Symptom WHERE Symptom_Description = @SymptomDesc AND Symptom_Name = @SymptomName)
END 
GO

-- Stored Procedures

-- YASH --

-- SPROC TO POPULATE THE PLACE TABLE
CREATE PROCEDURE Insert_to_Place
@place_name varchar(50),
@placeType varchar(50)
AS
DECLARE @ptID INT

EXECUTE GetPlace_Type_ID
@place_type = @placeType,
@PT_ID = @ptID OUTPUT
IF @PTID IS NULL
	BEGIN
		PRINT '@ptID IS NULL';
		THROW 54667, 'THE STATEMENT IS INVALID BECAUSE @ptID IS NULL', 1;
	END
BEGIN TRAN T1
INSERT INTO Place(Place_TypeID, Place_Name)
VALUES(@ptID, @place_name)
IF @@ERROR <> 0
	ROLLBACK TRAN T1
ELSE
	COMMIT TRAN T1
GO

-- EXECUTING THE PLACE SPROC
EXECUTE Insert_to_Place
@place_name = 'Mary Gates Hall',
@placeType = 'Building with classrooms'
GO

-- SPROC TO INSERT A NEW USER
CREATE PROCEDURE insert_new_user
@FName VARCHAR(50),
@LName VARCHAR(50),
@DB DATE,
@phone VARCHAR(50),
@Utype VARCHAR(50)
AS
DECLARE @utID INT

EXECUTE GetUser_Type_ID
@user_type = @Utype,
@UT_ID = @utID OUTPUT
IF @utID IS NULL
	BEGIN
		PRINT '@utID IS NULL';
		THROW 54667, 'THE STATEMENT IS INVALID BECAUSE @utID IS NULL', 1;
	END
BEGIN TRAN G1
INSERT INTO Users(User_Fname, User_Lname, DOB, Contact_Num, User_TypeID)
VALUES(@FName, @LName, @DB, @phone, @utID)
IF @@ERROR <> 0
	ROLLBACK TRAN G1
ELSE
	COMMIT TRAN G1
GO

-- EXECUTE STATEMENT
EXECUTE insert_new_user
@FName = 'Saurav',
@LName = 'Sawansukha',
@DB = '1999-03-12',
@phone = '123-321',
@Utype = 'Student'
GO

-- Wrapper to populate the Place Table
CREATE PROCEDURE WRAPPER_Insert_Place
@RUN INT
AS
DECLARE
@pn varchar(50),
@pt varchar(50)

DECLARE @ptCount INT = (SELECT COUNT(*) from Place_Type)
DECLARE @ptPK INT = (SELECT CEILING(RAND() * @ptCount + 1))
DECLARE @RAND INT

WHILE @RUN > 0
    BEGIN
        SET @RAND = (SELECT RAND() * 10)

        SET @ptPK = (CASE 
						WHEN @RAND < 2
							THEN 1
						WHEN @RAND BETWEEN 3 AND 4
							THEN 2
						WHEN @RAND BETWEEN 5 AND 6
							THEN 3
						WHEN @RAND BETWEEN 7 AND 8
							THEN 4
						ELSE
							5
						END)

        SET @pt = (SELECT Place_Type_Name FROM Place_Type WHERE Place_TypeID = @ptPK)

        SET @pn = (CASE 
						WHEN @ptPK = 1
							THEN 'Mary Gates Hall'
						WHEN @ptPK = 2
							THEN 'Odegaard Undergraduate Library'
						WHEN @ptPK = 3
							THEN 'Elm Hall'
						WHEN @ptPK = 4
							THEN 'The Quad'
						ELSE
							'Husky Union Building'
						END)

        EXECUTE Insert_to_Place
        @place_name = @pn,
        @placeType = @pt

        SET @RUN = @RUN - 1
    END
    GO

-- EXECUTE STATEMENT
EXECUTE WRAPPER_Insert_Place
@RUN = 1000
GO

-- SEAN --

-- INSERT USER EVENT SPROC --
CREATE PROCEDURE insert_user_event
@ev_type_name varchar(50),
@ev_name varchar(50),
@user_fname varchar(50),
@user_lname varchar(50),
@user_DOB date, 
@user_number varchar(50),
@p_name varchar(50)
AS
DECLARE @Event_Type_ID INT, @Users_ID INT, @Place_ID INT, @Event_ID INT, @timestamp datetime
SET @timestamp = (SELECT CURRENT_TIMESTAMP - (RAND() * 300))
 
EXECUTE GetEventTypeID
@event_type_name = @ev_type_name,
@ET_ID = @Event_Type_ID output
 
IF @Event_Type_ID IS NULL 
 BEGIN 
 PRINT 'Event_TypeID is missing... Cannot find the event you are looking for, check for spelling errors...'
 RAISERROR('@Event_Type_ID is null...', 11, 1)
 RETURN
 END
 
EXECUTE GetUserID
@user_firstname = @user_fname,
@user_lastname = @user_lname,
@user_birthdate = @user_DOB,
@user_phone = @user_number,
@U_ID = @Users_ID output
 
IF @Users_ID IS NULL 
 BEGIN 
 PRINT 'User ID is missing... Cannot find the user you are looking for, check for spelling errors...'
 RAISERROR('@Users_ID is null...', 11, 1)
 RETURN
 END
 
EXECUTE GetPlaceID
@place_name = @p_name,
@P_ID = @Place_ID output 
 
IF @Place_ID IS NULL 
 BEGIN 
 PRINT 'Place_ID is missing... Cannot find the user you are looking for, check for spelling errors...'
 RAISERROR('@Place_ID is null...', 11, 1)
 RETURN
 END
 
BEGIN TRANSACTION T1
 INSERT INTO Event(PlaceID, Event_TypeID, Event_Name)
 VALUES(@Place_ID, @Event_Type_ID, @ev_name)
 
 SET @Event_ID = (SELECT SCOPE_IDENTITY())
 
 INSERT INTO User_Event(UserID, Scan, EventID)
 VALUES (@Users_ID, @timestamp, @Event_ID)
 
 IF @@TRANCOUNT <> 1
 BEGIN
 PRINT 'There is an error'
 ROLLBACK TRANSACTION T1
 END
 ELSE
 COMMIT TRANSACTION T1
GO

-- EXECUTE STATEMENT
EXECUTE insert_user_event
@ev_type_name = 'Studying at Library',
@ev_name = 'Late Night Study @ Ode',
@user_fname = 'Barabara',
@user_lname = 'Vy',
@user_DOB = '1993-04-22', 
@user_number = '483-1487',
@p_name = 'Mary Gates Hall'
GO

-- USER_EVENT WRAPPER SPROC --
CREATE PROCEDURE WRAPPER_insert_user_event
@Run INT
AS
DECLARE 
@EVTNA varchar(50), 
@EVNA varchar(50), 
@USFN varchar(50),
@USLN varchar(50),
@USDOB date,
@USPN varchar(50), 
@PLNA varchar(50)
 
DECLARE @PlaceCount INT = (SELECT COUNT(*) FROM Place)
DECLARE @EventTypeCount INT = (SELECT COUNT(*) FROM Event_Type)
DECLARE @UserCount INT = (SELECT COUNT(*) FROM USERS)
 
DECLARE @PlacePK INT 
DECLARE @EventTypePK INT
DECLARE @UserPK INT
 
DECLARE @RAND INT
 
WHILE @Run > 0
BEGIN
SET @UserPK = (SELECT CEILING(RAND() * @UserCount + 1)) 
SET @USFN = (SELECT User_Fname FROM Users WHERE UserID = @UserPK)
SET @USLN = (SELECT User_Lname FROM Users WHERE UserID = @UserPK)
SET @USDOB = (SELECT DOB FROM Users WHERE UserID = @UserPK)
SET @USPN = (SELECT Contact_Num FROM Users WHERE UserID = @UserPK)
 
SET @PlacePK = (SELECT CEILING(RAND() * @PlaceCount + 1))
SET @PLNA = (SELECT Place_Name FROM Place WHERE Place_ID = @PlacePK)
 
SET @RAND = (SELECT RAND() * 14)
 
SET @EventTypePK = (CASE 
 WHEN @RAND < 2
 THEN 1
 WHEN @RAND BETWEEN 3 AND 4
 THEN 2
 WHEN @RAND BETWEEN 5 AND 6
 THEN 3
 WHEN @RAND BETWEEN 7 AND 8
 THEN 4
 WHEN @RAND BETWEEN 9 AND 10
 THEN 5
 WHEN @RAND BETWEEN 11 AND 12
 THEN 6
 WHEN @RAND BETWEEN 13 AND 14
 THEN 7
 ELSE 8
 END)
SET @EVTNA = (SELECT EventTypeName FROM Event_Type WHERE Event_TypeID = @EventTypePK)
 
SET @EVNA = (CASE 
 WHEN @EventTypePK = 1
 THEN 'IMA Workout/Activities'
 WHEN @EventTypePK = 2 
 THEN 'Studying at Suz & Allen/Ode Library'
 WHEN @EventTypePK = 3
 THEN 'Grubbing at UW HFS'
 WHEN @EventTypePK = 4
 THEN 'Bowling @ the HUB'
 WHEN @EventTypePK = 5 
 THEN 'Going to lecture/lab'
 WHEN @EventTypePK = 6
 THEN 'Tested positive'
 WHEN @EventTypePK = 7 
 THEN 'Tested negative'
 WHEN @EventTypePK = 8
 THEN 'Need to get tested for COVID-19'
 END)
 
EXECUTE insert_user_event
@ev_type_name = @EVTNA,
@ev_name = @EVNA, 
@user_fname = @USFN,
@user_lname = @USLN,
@user_DOB = @USDOB, 
@user_number = @USPN, 
@p_name = @PLNA
 
SET @Run = @Run -1
END
GO

-- EXECUTE STATEMENT
EXECUTE WRAPPER_insert_user_event
@RUN = 1000
GO

--SAURAV--

-- SPROC TO INSERT USER SYMPTOM
CREATE PROCEDURE InsertUserSymptom_eshetn
@F varchar(20),
@L varchar(20),
@Bday DATE,
@Phone varchar(50),
@SevNum INT,
@SevName varchar(50),
@SevDesc varchar(50),
@SympName varchar(50),
@SympDesc varchar(120),
@SymptomDate DATETIME
AS 
DECLARE @U_ID INT
DECLARE @SEV_ID INT
DECLARE @SYMP_ID INT

EXECUTE GetUserId
@User_FirstName = @F,
@User_LastName = @L,
@User_BirthDate = @Bday,
@User_Phone = @Phone, 
@U_ID = @U_ID OUTPUT

IF @U_ID IS NULL
    BEGIN
        PRINT '@U_ID IS NULL';
        THROW 54667, 'THE STATEMENT IS INVALID BECAUSE @U_ID IS NULL', 1;
    END
EXECUTE GetSeverityId_eshetn
@SeverityNum = @SevNum,
@SeverityName = @SevName,
@SeverityDesc = @SevDesc,
@SEVERITY_ID = @SEV_ID OUTPUT
IF @SEV_ID IS NULL
    BEGIN
        PRINT '@SEV_ID IS NULL';
        THROW 54667, 'THE STATEMENT IS INVALID BECAUSE @SEV_ID IS NULL', 1;
    END
EXECUTE GetSymptomId_eshetn
@SymptomName = @SympName,
@SymptomDesc = @SympDesc,
@SYMPTOM_ID = @SYMP_ID OUTPUT
IF @SYMP_ID IS NULL
    BEGIN
        PRINT '@SYMP_ID IS NULL';
        THROW 54667, 'THE STATEMENT IS INVALID BECAUSE @SYMP_ID IS NULL', 1;
    END

--EXPLICIT TRANSACTION
BEGIN TRAN G1
INSERT INTO User_Symptom(UserID, SeverityID, SymptomID, SymptomDate)
VALUES(@U_ID, @SEV_ID, @SYMP_ID, @SymptomDate)
IF @@ERROR <> 0
    ROLLBACK TRAN G1
ELSE
    COMMIT TRAN G1
GO

-- EXECUTE STATEMENT
EXEC InsertUserSymptom_eshetn
@F = 'Dayle',
@L = 'Stubbolo',
@Bday = '1990-05-18',
@Phone = '368-0866',
@SevNum = 5,
@SevName = 'Severity 5',
@SevDesc = 'High severity - Covid Positive',
@SympName = 'Cough',
@SympDesc = 'irritates your throat or airways',
@SymptomDate = '2020-12-10 16:44:54.497'
GO

-- WRAPPER FOR USER CONDITION
CREATE PROCEDURE synthethic_tran_user_condition
@Run INT
AS
DECLARE @Condition_Name varchar(50),
@Condition_abbrev varchar(50),
@Description varchar(50),
@First_name varchar(20),
@Last_Name varchar(20),
@Birthday DATE,
@Number varchar(50)
DECLARE @C_Count INT
SET @C_Count = (Select COUNT(*) From Condition)
DECLARE @U_Count INT
SET @U_Count = (Select COUNT(*) From Users)
DECLARE @C_ID INT
DECLARE @U_ID INT
WHILE @Run > 0
BEGIN
    SET @C_ID = (SELECT floor(rand() * @C_Count + 1))
    SET @U_ID = (SELECT floor(rand() * @U_Count + 1))
    SET @Condition_Name = (Select Condition_Name FROM Condition WHERE ConditionID = @C_ID)
    SET @Condition_abbrev = (Select Condition_Abbrv FROM Condition WHERE ConditionID = @C_ID)
    SET @Description = (Select Description FROM Condition WHERE ConditionID = @C_ID)
    SET @First_name = (Select User_Fname FROM Users WHERE userID = @U_ID)
    SET @Last_name = (Select User_Lname FROM Users WHERE userID = @U_ID)
    SET @Birthday = (Select DOB FROM Users WHERE userID = @U_ID)
    SET @Number = (Select Contact_Num FROM Users WHERE userID = @U_ID)
    EXEC InsertUserCondition_eshetn
    @CN = @Condition_Name,
    @CA = @Condition_abbrev,
    @DESC = @Description,
    @F = @First_name,
    @L = @Last_name,
    @Bday = @Birthday,
    @Phone = @Number
    SET @Run = @Run - 1
END
GO

-- EXECUTE STATEMENT
EXECUTE synthethic_tran_user_condition
@RUN = 1000
GO

--NATNAEL--

-- SPROC TO INSERT USER CONDITION
CREATE PROCEDURE InsertUserCondition_eshetn
@CN varchar(50),
@CA varchar(50),
@DESC varchar(50),
@F varchar(20),
@L varchar(20),
@Bday DATE,
@Phone varchar(50)
AS
DECLARE @C_ID INT
DECLARE @U_ID INT
EXECUTE GetConditionID_eshetn
@ConditionName = @CN,
@CondtionAbbrv = @CA,
@Description = @DESC,
@COND_ID = @C_ID OUTPUT
IF @C_ID IS NULL
    BEGIN
        PRINT '@C_ID IS NULL';
        THROW 54667, 'THE STATEMENT IS INVALID BECAUSE @C_ID IS NULL', 1;
    END

EXECUTE GetUserId
@User_FirstName = @F,
@User_LastName = @L,
@User_BirthDate = @Bday,
@User_Phone = @Phone, 
@U_ID = @U_ID OUTPUT

IF @U_ID IS NULL
    BEGIN
        PRINT '@U_ID IS NULL';
        THROW 54667, 'THE STATEMENT IS INVALID BECAUSE @U_ID IS NULL', 1;
    END
--EXPLICIT TRANSACTION PART OF SPROC
BEGIN TRAN G1
INSERT INTO User_Condition(UserID, ConditionID)
VALUES(@U_ID, @C_ID)
IF @@ERROR <> 0
    ROLLBACK TRAN G1
ELSE
    COMMIT TRAN G1
GO

--EXECUTION--
EXEC InsertUserCondition_eshetn
@CN = 'Obesity',
@CA = 'OBES',
@DESC = 'Dangerous excess body fat',
@F = 'Dayle',
@L = 'Stubbolo',
@Bday = '1990-05-18',
@Phone = '368-0866'
GO

-- USER SYMPTOM WRAPPER
CREATE PROCEDURE WRAPPER_eshetn_INSERT_USERSYMPTOM
@RUN INT
AS
DECLARE @FN VARCHAR(20),
        @LN VARCHAR(20), 
        @BD DATE, 
        @PN VARCHAR(50), 
        @SEVNU INT, 
        @SEVNA VARCHAR(50), 
        @SEVD VARCHAR(50), 
        @SYMNA VARCHAR(50), 
        @SYMDESC VARCHAR(120), 
        @SYMDA DATETIME
DECLARE @UserCount INT = (SELECT COUNT(*) FROM Users)
DECLARE @SeverityCount INT = (SELECT COUNT(*) FROM Severity)
DECLARE @SymptomCount INT = (SELECT COUNT(*) FROM Symptom)
DECLARE @UserPK INT
DECLARE @SeverityPK INT
DECLARE @SymptomPK INT
DECLARE @RAND INT
WHILE @RUN > 0
    BEGIN
        SET @UserPK = (SELECT CEILING(RAND() * @UserCount + 1))
        SET @FN = (SELECT User_Fname FROM Users WHERE UserID = @UserPK)
        SET @LN = (SELECT User_Lname FROM Users WHERE UserID = @UserPK)
        SET @BD = (SELECT DOB FROM Users WHERE UserID = @UserPK)
        SET @PN = (SELECT Contact_Num FROM Users WHERE UserID = @UserPK)
        SET @RAND = (SELECT RAND() * 10)
        SET @SeverityPK = (CASE 
                                WHEN @RAND < 1
                                    THEN 1
                                WHEN @RAND BETWEEN 2 AND 3
                                    THEN 2
                                WHEN @RAND BETWEEN 4 AND 5
                                    THEN 3
                                WHEN @RAND BETWEEN 6 AND 7
                                    THEN 4
                                WHEN @RAND BETWEEN 8 AND 9 
                                    THEN 5
                                ELSE
                                    6
                                END)
        SET @SEVNA = (SELECT Severity_Name FROM Severity WHERE SeverityID = @SeverityPK)
        SET @SEVNU = (SELECT Severity_Number FROM Severity WHERE SeverityID = @SeverityPK)
        SET @SEVD = (SELECT Severity_Desc FROM Severity WHERE SeverityID = @SeverityPK)
        SET @RAND = (SELECT RAND() * 10)
        
        SET @SymptomPK = (CASE 
                                WHEN @RAND < 2
                                    THEN 1
                                WHEN @RAND BETWEEN 3 AND 4
                                    THEN 2
                                WHEN @RAND BETWEEN 5 AND 6
                                    THEN 3
                                WHEN @RAND BETWEEN 7 AND 8
                                    THEN 4
                                ELSE
                                    5
                                END)
        SET @SYMNA = (SELECT Symptom_Name FROM Symptom WHERE SymptomID = @SymptomPK)
        SET @SYMDESC = (SELECT Symptom_Description FROM Symptom WHERE SymptomID = @SymptomPK)
        
        SET @RAND = (SELECT RAND() * 1000)
        SET @SYMDA = (SELECT CURRENT_TIMESTAMP - @RAND)
        EXECUTE InsertUserSymptom_eshetn
        @F = @FN,
        @L = @LN,
        @Bday = @BD,
        @Phone = @PN,
        @SevNum = @SEVNU,
        @SevName = @SEVNA,
        @SevDesc = @SEVD,
        @SympName = @SYMNA,
        @SympDesc = @SYMDESC,
        @SymptomDate = @SYMDA
        SET @RUN = @RUN - 1
        END
        GO

-- EXECUTE STATEMENT
EXECUTE WRAPPER_eshetn_INSERT_USERSYMPTOM
@RUN = 1000

-- CHECK CONSTRAINTS

--YASH--

--A person cannot have a scan at Odegaard after 9pm
GO
CREATE FUNCTION fn_gathering_after9()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
IF EXISTS (SELECT * 
            FROM Users U
            JOIN User_Event UE ON U.UserID = UE.UserID
            JOIN Event E on UE.EventID = E.EventID
            JOIN Place P ON E.PlaceID = P.Place_ID
            WHERE (SELECT DATEPART(HOUR, Scan) FROM User_Event) > 21 AND
            P.Place_Name = 'Odegaard Undergraduate Library')
SET @RET = 1
RETURN @RET
END
GO

ALTER TABLE User_Event WITH NOCHECK
ADD CONSTRAINT CK_noScanAfter9
CHECK (dbo.fn_gathering_after9() = 0)

--A person cannot get tested within the 14 days of testing positive
GO
CREATE FUNCTION fn_test_after14()
RETURNS INTEGER
AS 
BEGIN
DECLARE @RET INTEGER = 0
IF EXISTS(SELECT *
		FROM User_Symptom US 
		JOIN User_Event UE on US.UserID = UE.UserID
		JOIN Severity S on US.SeverityID = S.SeverityID
		JOIN Event E ON UE.EventID = E.EventID
        WHERE GETDATE() < (SELECT DATEADD(DAY, 14, UE.Scan)) AND S.Severity_Number >= 1)
SET @RET = 1
RETURN @RET
END
GO

ALTER TABLE User_Event WITH NOCHECK
ADD CONSTRAINT CK_testafter14
CHECK (dbo.fn_test_after14() = 0)
GO

--SEAN--

-- Ensuring HFS buildings ('Residential Buildings') can only be accessed through scan by 'Students' and 'Security' --
CREATE FUNCTION fn_HFS_Access_To_Students_Security_Only()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
IF EXISTS (SELECT * 
 FROM User_Type UT
 JOIN Users U On UT.User_TypeID = U.User_TypeID
 JOIN User_Event UE on U.UserID = UE.UserID
 JOIN Event E on UE.EventID = E.EventID
 JOIN Place P on E.PlaceID = P.Place_ID 
 WHERE E.Event_TypeID = 3 AND U.User_TypeID BETWEEN 2 AND 4)
SET @RET = 1
RETURN @RET
END
GO
 
ALTER TABLE User_Event WITH CHECK
ADD CONSTRAINT CK_HFS_ACCESS
CHECK (dbo.fn_HFS_Access_To_Students_Security_Only() = 0)
GO
 
--- Severity Number must be greater than 0 for a User to have an Event registered --
CREATE FUNCTION fn_No_Event_With_Zero_Severity()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
IF EXISTS (SELECT * 
 FROM User_Event UE
 JOIN Users U On UE.UserID = U.UserID
 JOIN User_Symptom US on U.UserID = US.UserID 
 WHERE US.SeverityID = 1)
SET @RET = 1
RETURN @RET
END
GO
 
ALTER TABLE USER_EVENT WITH CHECK 
ADD CONSTRAINT CK_SeverityGreaterThanZero
CHECK (dbo.fn_No_Event_With_Zero_Severity() = 0)
GO

--SAURAV--

-- If a user has cough or fever and so the droplets can spread to other people are not allowed to be in gathering areas--
CREATE FUNCTION FN_no_gather()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
IF EXISTS(
    SELECT * 
    FROM USERS u
    JOIN User_Symptom us ON us.UserID = u.UserID
    JOIN Symptom s ON s.SymptomID = us.SymptomID
    JOIN User_Event ue ON ue.UserID = u.UserID
    JOIN Event e ON e.EventID = ue.EventID
    JOIN Place p ON p.Place_ID = e.PlaceID
    JOIN Place_Type pt ON pt.Place_TypeID = p.Place_TypeID
    WHERE s.Symptom_Name = 'Cough' AND Place_Type_Name = 'Gathering Areas'
)
SET @RET = 1
RETURN @RET
END
GO

ALTER TABLE Place WITH NOCHECK
ADD CONSTRAINT CK_noGatherIfSpread
CHECK (dbo.FN_no_gather() = 0)
GO

--If a person has a condition and a symptom and a severity level of greater than 4 then you cannot add a event--
CREATE FUNCTION FN_condition_symptom()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
IF EXISTS(
    SELECT u.UserID
    FROM Users u
    JOIN User_Symptom us ON us.UserID = u.UserID
    JOIN Symptom s ON s.SymptomID = us.SymptomID
    JOIN Severity se ON se.SeverityID = us.SeverityID
    JOIN User_Condition uc ON uc.UserID = u.UserID
    JOIN Condition c ON c.ConditionID = uc.ConditionID
    WHERE c.Condition_Name != 'NONE' AND s.Symptom_Name IS NOT NULL AND se.Severity_Number > 4
)
SET @RET = 1
RETURN @RET
END
GO

ALTER TABLE Event WITH NOCHECK
ADD CONSTRAINT CK_noEventIFSeverityHigh
CHECK (dbo.FN_condition_symptom() = 0)
GO

--NATNAEL--

--Kids with age less than 18 canot have a severity greater than 3--
CREATE FUNCTION fn_SeverityLessThan3_18years()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
IF EXISTS (SELECT * 
            FROM Users U
            JOIN User_Symptom US On U.UserID = US.UserID
            JOIN Severity S on US.SeverityID = S.SeverityID 
            WHERE u.DOB > DateAdd(Year, -18, GetDate()) AND
            S.Severity_Number > 3)
SET @RET = 1
RETURN @RET
END
GO

ALTER TABLE User_Symptom WITH NoCheck
ADD CONSTRAINT CK_NoSeverityGreaterThan3_YoungerThan18
CHECK (dbo.fn_SeverityLessThan3_18years() = 0)
GO

---If the event of your covid test is positive, you cannot enter an Admin building--
CREATE FUNCTION fnCovidPositiveBeforeCurrent()
RETURNS INTEGER
AS 
BEGIN
DECLARE @RET INTEGER = 0
IF EXISTS (
        SELECT *
        FROM User_Symptom US 
        JOIN User_Event UE on US.UserID = UE.UserID
        JOIN Severity S on US.SeverityID = S.SeverityID
        JOIN Event E ON UE.EventID = E.EventID
        JOIN Place P ON E.PlaceID = P.Place_ID
        JOIN Place_Type PT ON P.Place_TypeID = PT.Place_TypeID
        WHERE PT.Place_TypeID = 5 AND UE.Scan >= GETDATE() AND UE.Scan < (SELECT DATEADD(DAY, 1, GETDATE())) AND S.Severity_Number >=1
)
SET @RET = 1
RETURN @RET
END
GO

ALTER TABLE User_Event
ADD CONSTRAINT CK_PositiveCovid_NoAdminEntry
CHECK (dbo.fnCovidPositiveBeforeCurrent() = 0)
GO

--VIEWS

--YASH--

--List of all professors who visited Mary Gates Hall with a severity level of greater than or equal to 3 and shortness of breath as a symptom

CREATE VIEW professor_MGH_severity3_breath
 AS 
SELECT DISTINCT CONCAT('Professor ', User_Fname, ' ', User_Lname) AS Name, Contact_Num 
FROM Users U
JOIN User_Symptom US ON U.UserID = US.UserID
JOIN Severity Se ON US.SeverityID = Se.SeverityID
JOIN Symptom S ON US.SymptomID = S.SymptomID
JOIN User_Event UE ON U.UserID = U.UserID
JOIN Event E ON UE.EventID = E.EventID
JOIN Place P ON E.PlaceID = P.Place_ID
WHERE User_TypeID = 3 
AND Place_Name = 'Mary Gates Hall'
AND Severity_Number >= 3
AND Symptom_Name = 'Shortness of Breath'
GO

SELECT * FROM professor_MGH_severity3_breath
GO

--List of all security people who have been working in gathering areas tested positive, and have influenza
ALTER VIEW positive_security_gathering_influenza
 AS 
SELECT DISTINCT CONCAT(User_Fname, ' ', User_Lname) AS Name, Contact_Num 
FROM Users U
JOIN User_Condition UC ON U.UserID = UC.UserID
JOIN Condition C ON UC.ConditionID = C.ConditionID
JOIN User_Symptom US ON U.UserID = US.UserID
JOIN Severity Se ON US.SeverityID = Se.SeverityID
JOIN User_Event UE ON U.UserID = U.UserID
JOIN Event E ON UE.EventID = E.EventID
JOIN Place P ON E.PlaceID = P.Place_ID
JOIN Place_Type PT ON P.Place_TypeID = PT.Place_TypeID
WHERE User_TypeID = 4 
AND Place_Type_Name = 'Gathering Areas'
AND Severity_Number >= 1
AND Condition_Name = 'Influenza'
GO

SELECT * FROM positive_security_gathering_influenza
GO

--SEAN--

-- A view of a ranking of days since reporting for symptoms from those who have tested positive in the past year alone, 
-- with the most severe cases only (Severity level = 5)
CREATE VIEW rank_days_since_reporting_symptoms_for_positive_cases
AS
WITH RANK_SCAN_CTE
AS(
 SELECT U.UserID, User_Fname, User_Lname, DATEDIFF(day, US.SymptomDate, CURRENT_TIMESTAMP) DaysSinceReportingSymptoms,
 RANK() OVER (ORDER BY DATEDIFF(day, US.SymptomDate, CURRENT_TIMESTAMP) ASC) RankNumOfDays
 FROM Users U
 JOIN User_Symptom US ON U.UserID = US.UserID
 JOIN Severity S ON US.SeverityID = S.SeverityID
 WHERE S.Severity_Number = 5
 GROUP BY U.UserID, U.User_Fname, U.User_Lname, US.SymptomDate
 HAVING US.SymptomDate BETWEEN '2020-01-01' AND '2020-12-31')
 
SELECT * FROM RANK_SCAN_CTE 
GO
 
SELECT * FROM [rank_days_since_reporting_symptoms_for_positive_cases]
GO

-- A view of a ranking of places based on visits of those who tested positive for COVID-19 --
CREATE VIEW rank_places_visited_by_those_positive_more_than_three_months_ago
AS
WITH RANK_PLACE_CTE
AS(
 SELECT TOP 5 PT.Place_TypeID, PT.Place_Type_Name, (COUNT(P.Place_TypeID)) AS [COUNT],
 RANK() OVER(ORDER BY COUNT(P.Place_TypeID) DESC) RankPlacesVisited
 FROM Place_Type PT
 JOIN Place P ON PT.Place_TypeID = P.Place_TypeID
 JOIN Event E ON P.Place_ID = E.PlaceID
 JOIN User_Event UE ON E.EventID = UE.EventID
WHERE E.Event_TypeID = 6 AND DATEDIFF(MONTH, UE.Scan, CURRENT_TIMESTAMP) > 3
GROUP BY PT.Place_TypeID, PT.Place_Type_Name)
 
SELECT * FROM RANK_PLACE_CTE
GO
 
SELECT * FROM [rank_places_visited_by_those_positive_more_than_three_months_ago]
GO

--NATNAEL--

-- Number of users associated with a Severity 4 or Higher during the 2019-2020 school year, partitioned by  WASHINGTON AREA CODE
CREATE VIEW [1920WashingtonHighSeverity] AS
SELECT  
    CASE
        WHEN Contact_Num LIKE '206%'
            THEN 'SEATTLE'
        WHEN Contact_Num LIKE '253%'
            THEN 'TACOMA'
        WHEN Contact_Num LIKE '360%'
            THEN 'WESTERN WASHINGTON'
        WHEN Contact_Num LIKE '425%'
            THEN 'EVERETT / EASTSIDE'
        WHEN Contact_Num LIKE '509%'
            THEN 'EASTERN WASHINGTON'
        WHEN Contact_Num LIKE '564%'
            THEN 'FURTHER WEST WASHINGTON'
    END AS CITY, COUNT(*) AS USER_COUNT
FROM  Users U
JOIN User_Symptom US ON U.UserID = US.UserID
WHERE (Contact_Num LIKE '206%') OR (Contact_Num LIKE '253%') OR (Contact_Num LIKE '360%') OR (Contact_Num LIKE '425%') OR (Contact_Num LIKE '509%') OR (Contact_Num LIKE '564%') 
      AND US.SeverityID >=5 AND US.SymptomDate BETWEEN '9-1-2019' AND '6-9-2020'
GROUP BY 
    CASE
        WHEN Contact_Num LIKE '206%'
            THEN 'SEATTLE'
        WHEN Contact_Num LIKE '253%'
            THEN 'TACOMA'
        WHEN Contact_Num LIKE '360%'
            THEN 'WESTERN WASHINGTON'
        WHEN Contact_Num LIKE '425%'
            THEN 'EVERETT / EASTSIDE'
        WHEN Contact_Num LIKE '509%'
            THEN 'EASTERN WASHINGTON'
        WHEN Contact_Num LIKE '564%'
            THEN 'FURTHER WEST WASHINGTON'
    END
ORDER BY USER_COUNT DESC OFFSET 0 ROWS
GO

Select * From [1920WashingtonHighSeverity]
GO
-- Most common SYMPTOMS associated with Users who have a negative test for covid but have a pre-existing condition
CREATE VIEW [CommonSympNegTestPreexistingCondition] AS 
SELECT SY.Symptom_Name AS SymptomName, C.Condition_name AS PreExistingCondition, RANK() OVER (PARTITION BY SY.Symptom_Name ORDER BY COUNT(U.UserID)) AS SymptomCount
FROM Users u
JOIN User_Condition UC ON U.UserID = UC.UserID
JOIN Condition C ON UC.ConditionID = C.ConditionID
JOIN User_Symptom US ON U.UserID = US.UserID
JOIN Severity S ON US.SeverityID = S.SeverityID
JOIN Symptom SY ON US.SymptomID = SY.SymptomID
WHERE S.SeverityID = 1 AND UC.ConditionID <> 6
GROUP BY SY.Symptom_Name, C.Condition_Name
ORDER BY SymptomCount DESC OFFSET 0 ROWS
GO

Select * From CommonSympNegTestPreexistingCondition
GO

--SAURAV--

--The first scan in February for each student where the place_type_name has Building and their latest severity is 0 - Saurav

CREATE VIEW first_scan_in_february
 AS 
WITH severity_0_user as(
    Select us.SymptomDate, u.UserID, s.Severity_Number, RANK() OVER(PARTITION BY u.UserID ORDER BY us.SymptomDate DESC) as rankings
    From Users u
    JOIN User_Symptom us ON u.UserID = us.UserID
    JOIN Severity s ON us.SeverityID = s.SeverityID
),
latest_ranking as (
    Select *
    From severity_0_user
    Where rankings = 1 AND Severity_Number = 0
),
first_scan_feb as(
    Select ue.Scan, u.userID, RANK() OVER(PARTITION BY u.UserID ORDER BY ue.Scan ASC) as scan_rankings, pt.place_type_name
    FROM Users u
    JOIN User_Event ue ON ue.UserID = u.UserID
    JOIN Event e ON e.EventID = ue.EventID
    JOIN Place p ON p.Place_ID = e.PlaceID
    JOIN Place_Type pt ON pt.Place_TypeID = p.Place_TypeID
    WHERE MONTH(ue.Scan) = 2
    --AND pt.Place_Type_Name LIKE '%Building%'
)
Select Scan, f.UserID, place_type_name, SymptomDate, Severity_Number
From first_scan_feb f
INNER JOIN latest_ranking l ON f.userID = l.userID
WHERE f.Place_Type_Name LIKE '%Building%'
GO

SELECT * FROM first_scan_in_february
GO

----Users who had a condition abbrev of NONE and their latest severity is greater than 0 but still tested positve for the covid test event
CREATE VIEW condition_none_test_positive
 AS 
WITH user_with_no_condition as (
    Select u.UserID, c.Condition_Abbrv
    From Users u
    JOIN User_Condition uc ON uc.UserID = u.UserID
    JOIN Condition c ON c.ConditionID = uc.ConditionID
    WHERE c.Condition_Abbrv = 'NONE'
),
latest_symptom as (
    Select us.SymptomDate, u.UserID, s.Severity_Number, RANK() OVER(PARTITION BY u.UserID ORDER BY us.SymptomDate DESC) as rankings
    From Users u
    JOIN User_Symptom us ON u.UserID = us.UserID
    JOIN Severity s ON us.SeverityID = s.SeverityID
),
severity_greater_0 as(
    Select *
    From latest_symptom
    WHERE rankings = 1 AND Severity_Number > 0
),
tested_users as(
 Select u.UserID, et.EventTypeName
 From Users u
 JOIN User_Event ue ON ue.UserID = u.UserID
 JOIN Event e ON e.EventID = ue.EventID
 JOIN Event_Type et ON et.Event_TypeID = e.Event_TypeID
 WHERE et.EventTypeName = 'Positive Result'
)
Select u.UserID, Condition_Abbrv, EventTypeName
From user_with_no_condition u
INNER JOIN tested_users t ON t.UserID = u.UserID
GO

SELECT * FROM condition_none_test_positive
GO

-- COMPUTED COLUMNS

--YASH--

--Adds a message column to the Users table depending on the age and condition of the user--
CREATE FUNCTION age65_and_condition(@UserID INT)
RETURNS VARCHAR(100)
AS
BEGIN
DECLARE @condition VARCHAR(100)
Select @condition = (SELECT CASE 
                    WHEN DATEDIFF(yy, U.DOB, GETDATE()) > 65
                    THEN 'You must stay inside because you suffer from ' + C.Condition_Name
                    ELSE 
                    'Stay Safe'
                    END
                    from Users U
                    JOIN User_Condition UC ON U.UserID = UC.UserID
                    JOIN Condition C ON UC.ConditionID = C.ConditionID
                    WHERE U.UserID = @UserID) 
RETURN @condition
END
GO

ALTER TABLE Users
ADD MESSAGE AS dbo.age65_and_condition(UserID)
GO

--Adds a antibodies column to users table depending on whether the person has tested positive or not--
CREATE FUNCTION antibodies(@UserID INT)
RETURNS VARCHAR(100)
AS
BEGIN
DECLARE @antibodies VARCHAR(100)
SELECT @antibodies = (SELECT CASE
                    WHEN S.Severity_Number >= 2 AND E.Event_Name = 'Tested Positive' AND MONTH(UE.Scan) = 'May'
                    THEN 'You have antibodies'
                    WHEN S.Severity_Number < 2 AND E.Event_Name = 'Tested Negative'
                    THEN 'Cases are increasing, stay home'
                    ELSE 
                    'Stay Safe'
                    END
                    from Users U 
                    JOIN User_Symptom US ON U.UserID = US.UserID
                    JOIN Severity S ON US.SeverityID = S.SeverityID
                    JOIN User_Event UE ON U.UserID = UE.UserID
                    JOIN Event E on UE.EventID = E.EventID
                    WHERE U.UserID = @UserID)
RETURN @antibodies
END
GO

ALTER TABLE Users
ADD Antibodies_Message AS dbo.antibodies(UserID)
GO
--SEAN--

-- Calculate Age of Users --
CREATE FUNCTION fn_calculate_age(@users_id INT)
RETURNS INT
AS
 BEGIN
 DECLARE @age INT;
 SELECT @age = DATEDIFF(year, DOB, GETDATE())
 FROM [dbo].[Users]
 WHERE UserID = @users_id;
 RETURN @age;
 END;
GO
 
ALTER TABLE Users
ADD [Age] AS dbo.fn_calculate_age([UserID])
GO

 
-- Return a building notice on whether or not a building can be accessed by those on campus -- 
CREATE FUNCTION fn_place_type_notice(@PK INT)
RETURNS VARCHAR(100)
AS
 BEGIN 
 DECLARE @place_type_notice varchar(100) 
 SELECT @place_type_notice = (Select CASE
 WHEN COUNT(*) = 0
 THEN 'Open (entry permitted to those wearing a mask)'
 WHEN COUNT(*) <= 10
 THEN CONCAT('Facility has been cleaned, however...', ' ', COUNT(*), ' ', 'student(s) that has/have tested positive has/have been to this building in the past two weeks')
 ELSE 
 'Open (entry permitted to those wearing a mask)'
 END
 FROM Place_Type PT
 JOIN Place P ON PT.Place_TypeID = P.Place_TypeID
 JOIN Event E ON P.Place_ID = E.PlaceID
 JOIN User_Event UE ON E.EventID = UE.UserID
 WHERE P.Place_TypeID = @PK 
 AND DATEDIFF(DAY, UE.Scan, CURRENT_TIMESTAMP) <= 14
 AND E.Event_Name = 'Tested Positive')
 RETURN @place_type_notice;
 END;
GO
 
ALTER TABLE Place_Type
ADD MESSAGE AS dbo.fn_place_type_notice(Place_TypeID)
SELECT * FROM Place_Type
GO
--SAURAV--

-- Insert each users most common symptom if they have logged in a symptom 
CREATE FUNCTION fn_common_symptoms(@User_PK INTEGER)
RETURNS VARCHAR(500)
WITH SCHEMABINDING
 
AS
BEGIN
 
        DECLARE @RET VARCHAR(500)
 
        SELECT @RET = (
                SELECT TOP 1 S.Symptom_Name
                FROM dbo.Users u
                JOIN dbo.User_Symptom us ON us.UserID = u.UserID
                JOIN dbo.Symptom s ON s.SymptomID = us.SymptomID
                JOIN (SELECT User_SymptomID, UserID FROM dbo.User_Symptom WHERE UserID = @User_PK) subq ON us.UserID = subq.UserID
                GROUP BY s.Symptom_Name
                ORDER BY COUNT(s.Symptom_Name) DESC
                )
 
        RETURN @RET
END
GO
 
ALTER TABLE Users
ADD [common_symptom_per_user] AS dbo.fn_common_symptoms(UserID)
GO
-- Print out precaution to take for each symptom in the user_symptom table - Saurav
ALTER FUNCTION fn_determine_precaution_for_symptom(@PK INT)
RETURNS VARCHAR(500)
AS
    BEGIN
        DECLARE @precaution VARCHAR(500);
        SELECT @precaution = (
                SELECT case
                 when us.SymptomID = 1 THEN 'Fluids and Honey/Ginger Tea'
                 when us.SymptomID = 2 THEN 'Check with doctor for more oxygen'
                 when us.SymptomID = 3 THEN 'Give acetaminophen or ibuprofen as directed on the label'
                 when us.SymptomID = 4 THEN 'Get some sleep'
                 when us.SymptomID = 5 THEN 'Visit doctor for medication'
                 ELSE 'Nothing to worry'
                END
                FROM User_Symptom us
                JOIN Symptom s ON s.SymptomID = us.SymptomID
                WHERE us.User_SymptomID = @PK
        
        )
            RETURN @precaution
 
    END
GO
ALTER TABLE [dbo].[User_Symptom]
ADD Precaution AS dbo.fn_determine_precaution_for_symptom([User_SymptomID])
GO


--NATNAEL--

--Full Description of User_Event
CREATE FUNCTION fn_full_UE_desc(@ueID INT)
RETURNS VARCHAR(500)
WITH SCHEMABINDING
AS
    BEGIN
        DECLARE @desc VARCHAR(500);
        SELECT @desc = (SELECT U.User_Fname + ' ' + U.User_Lname + ' scanned in at ' + P.Place_Name + ' to ' + ET.Event_Desc + ' @' + CONVERT(varchar(20), UE.Scan, 20) AS full_desc
                        FROM dbo.User_Event UE
                        JOIN dbo.Users U ON  UE.UserID = U.UserID
                        JOIN dbo.Event E ON UE.EventID = E.EventID
                        JOIN dbo.Event_Type ET ON E.Event_TypeID = ET.Event_TypeID
                        JOIN dbo.Place P ON E.PlaceID = P.Place_ID
                        WHERE UE.User_EventID = @ueID)
        RETURN @desc
    END
GO
ALTER TABLE [dbo].[User_Event]
ADD [Description] AS dbo.fn_full_UE_desc([User_EventID])
GO

--Using age and condition to determine the risk for severity 0
CREATE FUNCTION fn_determine_risk_sev0(@usID INT)
RETURNS VARCHAR(50)
WITH SCHEMABINDING
AS
    BEGIN
        DECLARE @risk VARCHAR(50);
        SELECT @risk = (SELECT CASE
                                    WHEN S.SeverityID = 1 AND UC.ConditionID = 6 AND calcAge <25
                                        THEN 'No Risk'
                                    WHEN S.SeverityID = 1 AND calcAge < 35 AND UC.ConditionID = 1 or UC.ConditionID = 2 
                                        THEN 'High Risk'
                                    WHEN S.SeverityID = 1 AND calcAge  BETWEEN 36 AND 200 AND  UC.ConditionID = 1 or UC.ConditionID = 2 
                                        THEN 'Extreme Risk'
                                    WHEN S.SeverityID = 1 AND calcAge < 25 AND UC.ConditionID = 3 or UC.ConditionID = 5 
                                        THEN 'Low Risk'
                                    WHEN S.SeverityID = 1 AND calcAge  BETWEEN 26 AND 45 AND UC.ConditionID = 3 or UC.ConditionID = 5 
                                        THEN 'Medium Risk'
                                    WHEN S.SeverityID = 1 AND calcAge  BETWEEN 46 AND 65 AND UC.ConditionID = 3 or UC.ConditionID = 5 
                                        THEN 'High Risk'
                                    WHEN S.SeverityID = 1 AND calcAge  BETWEEN 66 AND 200 AND UC.ConditionID = 3 or UC.ConditionID = 5 
                                        THEN 'Extreme Risk'
                                    WHEN S.SeverityID = 1 AND calcAge < 20 AND UC.ConditionID = 4 
                                        THEN 'Low Risk'
                                    WHEN S.SeverityID = 1 AND calcAge BETWEEN 21 AND 35 AND UC.ConditionID = 4 
                                        THEN 'Medium Risk'
                                    WHEN S.SeverityID = 1 AND calcAge BETWEEN 36 AND 50 AND UC.ConditionID = 4 
                                        THEN 'High Risk'
                                    WHEN S.SeverityID = 1 AND calcAge BETWEEN 51 AND 200 AND UC.ConditionID = 4 
                                        THEN 'Extreme Risk'
                                    WHEN UC.ConditionID IS NULL 
                                        THEN 'No Condition Reported Yet'
                                    ELSE
                                        'Already exposed, monitor symptoms'
                               END AS Risk
                        FROM dbo.User_Symptom US
                        JOIN dbo.Users U ON US.UserID = U.UserID
                        JOIN dbo.Severity S ON US.SeverityID = S.SeverityID
                        JOIN dbo.User_Condition UC on U.UserID = UC.UserID
                        JOIN (SELECT UserID, DATEDIFF(YEAR, Users.DOB, GETDATE()) AS calcAge FROM dbo.Users) CALC ON U.UserID = CALC.UserID
                        WHERE US.User_SymptomID = @usID)
            RETURN @risk
    END
GO

ALTER TABLE [dbo].[User_Symptom]
ADD [Risk] AS dbo.fn_determine_risk_sev0([User_SymptomID])
GO



