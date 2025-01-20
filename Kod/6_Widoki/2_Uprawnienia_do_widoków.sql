-------------------------------------------------------------------------------
-- Widok 1: v_StudentCourses
-- Dostęp: Admin, Employee
-------------------------------------------------------------------------------
GRANT SELECT ON OBJECT::dbo.v_StudentCourses 
    TO Role_Admin, Role_Employee;
GO

-------------------------------------------------------------------------------
-- Widok 2: v_CourseModulesDetailed
-- Dostęp: Admin, Employee, Student, Teacher, Translator
-------------------------------------------------------------------------------
GRANT SELECT ON OBJECT::dbo.v_CourseModulesDetailed
    TO Role_Admin, Role_Employee, Role_Student, Role_Teacher, Role_Translator;
GO

-------------------------------------------------------------------------------
-- Widok 3: v_OrdersFull
-- Dostęp: Admin, Employee, Student
-------------------------------------------------------------------------------
GRANT SELECT ON OBJECT::dbo.v_OrdersFull
    TO Role_Admin, Role_Employee, Role_Student;
GO

-------------------------------------------------------------------------------
-- Widok 4: v_ScheduleDetailed
-- Dostęp: Admin, Employee, Student, Teacher, Translator
-------------------------------------------------------------------------------
GRANT SELECT ON OBJECT::dbo.v_ScheduleDetailed
    TO Role_Admin, Role_Employee, Role_Student, Role_Teacher, Role_Translator;
GO

-------------------------------------------------------------------------------
-- Widok 5: v_StudentGrades
-- Dostęp: Admin, Employee, Teacher
-------------------------------------------------------------------------------
GRANT SELECT ON OBJECT::dbo.v_StudentGrades
    TO Role_Admin, Role_Employee, Role_Teacher;
GO
