------------------------------------------------------------------------------
-- GRANT dla funkcji skalar­nych (używamy EXECUTE)
------------------------------------------------------------------------------

GRANT EXECUTE ON OBJECT::dbo.ufnGetOrderTotal
    TO Role_Student, Role_Admin, Role_Employee;
GO

GRANT EXECUTE ON OBJECT::dbo.ufnGetStationaryModuleFreeSlots
    TO Role_Student, Role_Admin, Role_Employee;
GO

GRANT EXECUTE ON OBJECT::dbo.ufnCountActiveCoursesInPeriod
    TO Role_Admin, Role_Employee;
GO

GRANT EXECUTE ON OBJECT::dbo.ufnGetSubjectAverageGrade
    TO Role_Student, Role_Teacher, Role_Admin;
GO

GRANT EXECUTE ON OBJECT::dbo.ufnGetFreeSeatsInBuilding
    TO Role_Admin, Role_Employee;
GO

GRANT EXECUTE ON OBJECT::dbo.ufnConvertActivityPriceToEUR
    TO Role_Admin, Role_Employee;
GO

GRANT EXECUTE ON OBJECT::dbo.ufnGetCourseTotalHours
    TO Role_Admin, Role_Employee, Role_Teacher;
GO

GRANT EXECUTE ON OBJECT::dbo.ufnGetWebinarTotalHours
    TO Role_Admin, Role_Employee;
GO

GRANT EXECUTE ON OBJECT::dbo.ufnGetCourseTotalParticipants
    TO Role_Admin, Role_Employee, Role_Teacher;
GO

------------------------------------------------------------------------------
-- GRANT dla funkcji tabelarycznych (używamy SELECT)
------------------------------------------------------------------------------

GRANT SELECT ON OBJECT::dbo.ufnGetTeachersByLanguage
    TO Role_Admin, Role_Employee, Role_Student;
GO

GRANT SELECT ON OBJECT::dbo.ufnListActivitiesByLanguage
    TO Role_Student, Role_Admin, Role_Employee;
GO

GRANT SELECT ON OBJECT::dbo.ufnGetStudentSchedule
    TO Role_Student, Role_Teacher, Role_Admin;
GO

GRANT SELECT ON OBJECT::dbo.ufnGetStudentGrades
    TO Role_Student, Role_Teacher, Role_Admin;
GO

GRANT SELECT ON OBJECT::dbo.ufnGetCourseAttendanceList
    TO Role_Teacher, Role_Admin;
GO

GRANT SELECT ON OBJECT::dbo.ufnGetStudentAllAttendances
    TO Role_Student, Role_Teacher, Role_Admin;
GO
