--------------------------------------------------------------------------------
--  1) Administrator
--------------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER, REFERENCES ON SCHEMA::dbo TO Role_Admin;
GO

--------------------------------------------------------------------------------
--  2) Employee
--------------------------------------------------------------------------------

GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Orders TO Role_Employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.OrderDetails TO Role_Employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Studies TO Role_Employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Students TO Role_Employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Courses TO Role_Employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Teachers TO Role_Employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Translator TO Role_Employee;
GRANT SELECT,UPDATE ON dbo.OrderPaymentStatus TO Role_Employee;
GRANT SELECT,UPDATE ON dbo.RODO_Table TO Role_Employee;
GO


--------------------------------------------------------------------------------
--  3) Student
--------------------------------------------------------------------------------

GRANT SELECT ON dbo.Activities TO Role_Student;
GRANT SELECT ON dbo.Courses TO Role_Student;
GRANT SELECT ON dbo.Webinars TO Role_Student;
GRANT SELECT ON dbo.Studies TO Role_Student;

-- Dostęp do koszyka
GRANT SELECT, INSERT, DELETE ON dbo.ShoppingCart TO Role_Student;

-- Dostęp do zamówień - tylko tworzenie nowych i przeglądanie swoich
GRANT SELECT, INSERT ON dbo.Orders TO Role_Student;
GRANT SELECT, INSERT ON dbo.OrderDetails TO Role_Student;
GO


--------------------------------------------------------------------------------
--  4) Teacher
--------------------------------------------------------------------------------
GRANT SELECT, UPDATE ON dbo.CoursesAttendance TO Role_Teacher;
GRANT SELECT, UPDATE ON dbo.StudiesClassAttendance TO Role_Teacher;

GRANT SELECT ON dbo.Students TO Role_Teacher;
GRANT SELECT ON dbo.Courses TO Role_Teacher;
GRANT SELECT ON dbo.Studies TO Role_Teacher;
GRANT SELECT ON dbo.Translators TO Role_Teacher;

GRANT SELECT, INSERT, UPDATE ON dbo.SubjectGrades TO Role_Teacher;
GO
--------------------------------------------------------------------------------
--  5) Translator
--------------------------------------------------------------------------------
GRANT SELECT ON dbo.Webinars TO Role_Translator;
GRANT SELECT ON dbo.CourseModules TO Role_Translator;
GRANT SELECT ON dbo.Translators TO Role_Translator;
GRANT SELECT ON dbo.TranslatorsLanguages TO Role_Translator;
GRANT UPDATE ON dbo.TranslatorsLanguages TO Role_Translator;
GO
