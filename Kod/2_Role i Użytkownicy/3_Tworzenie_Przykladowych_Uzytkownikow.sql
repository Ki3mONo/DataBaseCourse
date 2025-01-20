USE dbo;
GO

--------------------------------------------
-- 1) Administrator
--------------------------------------------
CREATE LOGIN testAdmin 
WITH PASSWORD = 'TestAdmin123!';  -- silne hasło

CREATE USER testAdminUser
FOR LOGIN testAdmin
WITH DEFAULT_SCHEMA = dbo;

-- Przypisanie do roli
EXEC sp_addrolemember 'Role_Admin', 'TestAdminUser';
GO

--------------------------------------------
-- 2) Employee
--------------------------------------------
CREATE LOGIN testEmployee
WITH PASSWORD = 'TestEmp123!';

CREATE USER testEmployeeUser
FOR LOGIN testEmployee
WITH DEFAULT_SCHEMA = dbo;

EXEC sp_addrolemember 'Role_Employee', 'TestEmployeeUser';
GO

--------------------------------------------
-- 3) Student
--------------------------------------------
CREATE LOGIN testStudent
WITH PASSWORD = 'TestStudent123!';

CREATE USER testStudentUser
FOR LOGIN testStudent
WITH DEFAULT_SCHEMA = dbo;

EXEC sp_addrolemember 'Role_Student', 'TestStudentUser';
GO

--------------------------------------------
-- 4) Teacher
--------------------------------------------
CREATE LOGIN testTeacher
WITH PASSWORD = 'TestTeacher123!';

CREATE USER testTeacherUser
FOR LOGIN testTeacher
WITH DEFAULT_SCHEMA = dbo;

EXEC sp_addrolemember 'Role_Teacher', 'TestTeacherUser';
GO

--------------------------------------------
-- 5) Translator
--------------------------------------------
CREATE LOGIN testTranslator
WITH PASSWORD = 'TestTranslator123!';

CREATE USER testTranslatorUser
FOR LOGIN testTranslator
WITH DEFAULT_SCHEMA = dbo;

EXEC sp_addrolemember 'Role_Translator', 'TestTranslatorUser';
GO
