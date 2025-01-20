------------------------------------------------------------------------------
-- PRZEŁĄCZENIE SIĘ NA ODPOWIEDNIĄ BAZĘ DANYCH
------------------------------------------------------------------------------
USE [NazwaTwojejBazy];
GO

------------------------------------------------------------------------------
-- 1) Procedury: spAddCourse, spRemoveCourse 
--    Dostęp: Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spAddCourse    TO Role_Admin, Role_Employee;
GRANT EXECUTE ON OBJECT::dbo.spRemoveCourse TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 2) Procedury: spRegisterStudentInCourse, spUnregisterStudentFromCourse
--    Dostęp: Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spRegisterStudentInCourse     TO Role_Admin, Role_Employee;
GRANT EXECUTE ON OBJECT::dbo.spUnregisterStudentFromCourse TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 3) Procedura: spUpdateActivityPrice
--    Dostęp: Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spUpdateActivityPrice TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 4) Procedura: spAddTeacherSchedule (zarządzanie harmonogramem)
--    Dostęp: Admin, Teacher
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spAddTeacherSchedule TO Role_Admin, Role_Teacher;
GO

------------------------------------------------------------------------------
-- 5) Procedura: spFindAvailableActivities (wyszukiwanie aktywności w przedziale)
--    Dostęp: Student, Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spFindAvailableActivities TO Role_Student, Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 6) Procedura: spAddTeacher (rejestracja nauczyciela)
--    Dostęp: Admin
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spAddTeacher TO Role_Admin;
GO

------------------------------------------------------------------------------
-- 7) Procedura: spAddTranslator (rejestracja tłumacza)
--    Dostęp: Admin
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spAddTranslator TO Role_Admin;
GO

------------------------------------------------------------------------------
-- 8) Procedury: spAddWebinar, spRemoveWebinar 
--    Dostęp: Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spAddWebinar    TO Role_Admin, Role_Employee;
GRANT EXECUTE ON OBJECT::dbo.spRemoveWebinar TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 9) Procedura: spAddSubjectToStudies (dodawanie przedmiotu do planu studiów)
--    Dostęp: Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spAddSubjectToStudies TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 10) Procedura: spAutoAssignStudentsToGroups (rozdzielanie studentów do grup)
--     Dostęp: Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spAutoAssignStudentsToGroups TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 11) Procedura: spGenerateFinancialReport (raport finansowy)
--     Dostęp: Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spGenerateFinancialReport TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 12) Procedury: spUpdateTeacherData, spUpdateStudentData 
--     Dostęp: Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spUpdateTeacherData TO Role_Admin, Role_Employee;
GRANT EXECUTE ON OBJECT::dbo.spUpdateStudentData TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 13) Procedura: spUpdateRODO (zarządzanie danymi osobowymi)
--     Dostęp: Admin
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spUpdateRODO TO Role_Admin;
GO

------------------------------------------------------------------------------
-- 14) Procedura: spAddInternship (dodanie stażu)
--     Dostęp: Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spAddInternship TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 15) Procedury: spAddStudent, spRemoveStudent
--     Dostęp: Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spAddStudent    TO Role_Admin, Role_Employee;
GRANT EXECUTE ON OBJECT::dbo.spRemoveStudent TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 16) Procedury: spAddEmployee, spRemoveEmployee
--     Dostęp: Admin
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spAddEmployee    TO Role_Admin;
GRANT EXECUTE ON OBJECT::dbo.spRemoveEmployee TO Role_Admin;
GO

------------------------------------------------------------------------------
-- 17) Procedura: spAddCourseModule (tworzenie modułu kursu)
--     Dostęp: Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spAddCourseModule TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 18) Procedura: spAddEuroRate (pobieranie kursu euro)
--     Dostęp: Admin
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spAddEuroRate TO Role_Admin;
GO

------------------------------------------------------------------------------
-- 19) Procedura: spGenerateCourseDiploma (generowanie dyplomu)
--     Nie była w głównej liście – przyjmijmy: Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spGenerateCourseDiploma TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 20) Procedura: spGetDebtors (lista dłużników)
--     Też nie w głównej 18-tce, ale przydatne. Przyjmijmy: Admin, Employee
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spGetDebtors TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 21) Procedura: spGenerateCourseAttendanceReport
--     (raport frekwencji – załóżmy: Teacher, Admin)
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spGenerateCourseAttendanceReport TO Role_Teacher, Role_Admin;
GO

------------------------------------------------------------------------------
-- 22) Procedura: spMarkCourseModuleAttendance (oznaczanie obecności w kursie)
--     Załóżmy: Teacher, Admin
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spMarkCourseModuleAttendance TO Role_Teacher, Role_Admin;
GO

------------------------------------------------------------------------------
-- 23) Procedura: spMarkStudiesClassAttendance (oznaczanie obecności w studiach)
--     Załóżmy: Teacher, Admin
------------------------------------------------------------------------------
GRANT EXECUTE ON OBJECT::dbo.spMarkStudiesClassAttendance TO Role_Teacher, Role_Admin;
GO


-------------------------------------------------------------------------------
-- Poniżej uprawnienia do FUNKCJI
-- (skalarne: zazwyczaj GRANT EXECUTE, SELECT; tabelaryczne: GRANT SELECT)
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- 1) ufnGetOrderTotal: dostęp: Student, Admin, Employee
--    (Funkcja skalarna)
------------------------------------------------------------------------------
GRANT EXECUTE, SELECT ON OBJECT::dbo.ufnGetOrderTotal 
    TO Role_Student, Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 2) ufnGetStationaryModuleFreeSlots: dostęp: Student, Admin, Employee
--    (Funkcja skalarna)
------------------------------------------------------------------------------
GRANT EXECUTE, SELECT ON OBJECT::dbo.ufnGetStationaryModuleFreeSlots
    TO Role_Student, Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 3) ufnCountActiveCoursesInPeriod: dostęp: Admin, Employee
--    (Funkcja skalarna)
------------------------------------------------------------------------------
GRANT EXECUTE, SELECT ON OBJECT::dbo.ufnCountActiveCoursesInPeriod
    TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 4) ufnGetSubjectAverageGrade: dostęp: Student, Teacher, Admin
--    (Funkcja skalarna)
------------------------------------------------------------------------------
GRANT EXECUTE, SELECT ON OBJECT::dbo.ufnGetSubjectAverageGrade
    TO Role_Student, Role_Teacher, Role_Admin;
GO

------------------------------------------------------------------------------
-- 5) ufnGetFreeSeatsInBuilding: dostęp: Admin, Employee
--    (Funkcja skalarna)
------------------------------------------------------------------------------
GRANT EXECUTE, SELECT ON OBJECT::dbo.ufnGetFreeSeatsInBuilding
    TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 6) ufnConvertActivityPriceToEUR: dostęp: Admin, Employee
--    (Funkcja skalarna)
------------------------------------------------------------------------------
GRANT EXECUTE, SELECT ON OBJECT::dbo.ufnConvertActivityPriceToEUR
    TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 7) ufnGetTeachersByLanguage: dostęp: Admin, Employee, Student
--    (Funkcja TABELARYCZNA → wystarczy SELECT)
------------------------------------------------------------------------------
GRANT SELECT ON OBJECT::dbo.ufnGetTeachersByLanguage
    TO Role_Admin, Role_Employee, Role_Student;
GO

------------------------------------------------------------------------------
-- 8) ufnGetCourseTotalHours: dostęp: Admin, Employee, Teacher
--    (Funkcja skalarna)
------------------------------------------------------------------------------
GRANT EXECUTE, SELECT ON OBJECT::dbo.ufnGetCourseTotalHours
    TO Role_Admin, Role_Employee, Role_Teacher;
GO

------------------------------------------------------------------------------
-- 9) ufnListActivitiesByLanguage: dostęp: Student, Admin, Employee
--    (Funkcja TABELARYCZNA → wystarczy SELECT)
------------------------------------------------------------------------------
GRANT SELECT ON OBJECT::dbo.ufnListActivitiesByLanguage
    TO Role_Student, Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- 10) ufnGetWebinarTotalHours: dostęp: Admin, Employee
--     (Funkcja skalarna)
------------------------------------------------------------------------------
GRANT EXECUTE, SELECT ON OBJECT::dbo.ufnGetWebinarTotalHours
    TO Role_Admin, Role_Employee;
GO

------------------------------------------------------------------------------
-- (Dodatkowa) ufnGetCourseTotalParticipants 
--  - W kodzie się pojawiła, ale w pytaniu nie było
--  - Załóżmy: Admin, Employee, Teacher?
------------------------------------------------------------------------------
GRANT EXECUTE, SELECT ON OBJECT::dbo.ufnGetCourseTotalParticipants
    TO Role_Admin, Role_Employee, Role_Teacher;
GO

------------------------------------------------------------------------------
-- 11) ufnGetStudentSchedule: dostęp: Student, Teacher, Admin
--     (Funkcja TABELARYCZNA → SELECT)
------------------------------------------------------------------------------
GRANT SELECT ON OBJECT::dbo.ufnGetStudentSchedule
    TO Role_Student, Role_Teacher, Role_Admin;
GO

------------------------------------------------------------------------------
-- 12) ufnGetStudentGrades: dostęp: Student, Teacher, Admin
--     (Funkcja TABELARYCZNA → SELECT)
------------------------------------------------------------------------------
GRANT SELECT ON OBJECT::dbo.ufnGetStudentGrades
    TO Role_Student, Role_Teacher, Role_Admin;
GO

------------------------------------------------------------------------------
-- 13) ufnGetCourseAttendanceList: dostęp: Teacher, Admin
--     (Funkcja TABELARYCZNA → SELECT)
------------------------------------------------------------------------------
GRANT SELECT ON OBJECT::dbo.ufnGetCourseAttendanceList
    TO Role_Teacher, Role_Admin;
GO

------------------------------------------------------------------------------
-- 14) ufnGetStudentAllAttendances: dostęp: Student, Teacher, Admin
--     (Funkcja TABELARYCZNA → SELECT)
------------------------------------------------------------------------------
GRANT SELECT ON OBJECT::dbo.ufnGetStudentAllAttendances
    TO Role_Student, Role_Teacher, Role_Admin;
GO

------------------------------------------------------------------------------
-- KONIEC SKRYPTU
------------------------------------------------------------------------------

