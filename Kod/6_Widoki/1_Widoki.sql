-- WIDOK 1: v_StudentCourses
--Zestawienie: którzy studenci biorą udział w jakich kursach, z wyświetleniem nazwy kursu, ceny, informacji o studencie.\
CREATE OR ALTER VIEW dbo.v_StudentCourses
AS
SELECT
    s.StudentID,
    s.FirstName AS StudentFirstName,
    s.LastName  AS StudentLastName,
    s.Email     AS StudentEmail,
    c.CourseID,
    c.CourseName,
    c.CoursePrice
FROM dbo.Students s
JOIN dbo.CourseParticipants cp ON s.StudentID = cp.StudentID
JOIN dbo.Courses c ON cp.CourseID = c.CourseID;
GO

--WIDOK 2: v_CourseModulesDetailed
--Lista modułów kursów wraz z informacjami o nauczycielu, tłumaczu, języku i dacie modułu. Przydatne do przeglądania szczegółów kursu.
CREATE OR ALTER VIEW dbo.v_CourseModulesDetailed
AS
SELECT
    cm.ModuleID,
    cm.ModuleName,
    cm.[Date] AS ModuleDate,
    cm.DurationTime,
    t.TeacherID,
    t.FirstName    AS TeacherFirstName,
    t.LastName     AS TeacherLastName,
    tr.TranslatorID,
    tr.FirstName   AS TranslatorFirstName,
    tr.LastName    AS TranslatorLastName,
    l.LanguageName AS ModuleLanguage,
    c.CourseID,
    c.CourseName
FROM dbo.CourseModules cm
JOIN dbo.Teachers t 
    ON cm.TeacherID = t.TeacherID
LEFT JOIN dbo.Translators tr 
    ON cm.TranslatorID = tr.TranslatorID
JOIN dbo.Languages l 
    ON cm.LanguageID = l.LanguageID
JOIN dbo.Courses c 
    ON cm.CourseID = c.CourseID;
GO

--WIDOK 3: v_OrdersFull
--Pełne informacje o zamówieniach: dane zamówienia, status płatności, suma cen wszystkich aktywności (z OrderDetails), dane studenta.
CREATE OR ALTER VIEW dbo.v_OrdersFull
AS
SELECT
    o.OrderID,
    o.OrderDate,
    ops.OrderPaymentStatus,
    ops.PaidDate,
    s.StudentID,
    s.FirstName AS StudentFirstName,
    s.LastName  AS StudentLastName,
    e.EmployeeID,
    e.FirstName AS EmployeeFirstName,
    e.LastName  AS EmployeeLastName,
    SUM(a.Price) AS TotalOrderPrice
FROM dbo.Orders o
JOIN dbo.OrderPaymentStatus ops 
    ON o.PaymentURL = ops.PaymentURL
JOIN dbo.Students s 
    ON o.StudentID = s.StudentID
JOIN dbo.Employees e 
    ON o.EmployeeHandling = e.EmployeeID
JOIN dbo.OrderDetails od 
    ON o.OrderID = od.OrderID
JOIN dbo.Activities a 
    ON od.ActivityID = a.ActivityID
GROUP BY
    o.OrderID,
    o.OrderDate,
    ops.OrderPaymentStatus,
    ops.PaidDate,
    s.StudentID,
    s.FirstName,
    s.LastName,
    e.EmployeeID,
    e.FirstName,
    e.LastName;
GO

--WIDOK 4: v_ScheduleDetailed
--Widok zharmonizowany: pokazuje wpisy planu (Schedule) wraz z informacjami o sali (Buildings), nauczycielu, tłumaczu i ewentualnym module kursu albo przedmiocie studiów.
CREATE OR ALTER VIEW dbo.v_ScheduleDetailed
AS
SELECT
    sch.ScheduleID,
    sch.DayOfWeek,
    sch.StartTime,
    sch.EndTime,
    t.TeacherID,
    t.FirstName AS TeacherFirstName,
    t.LastName  AS TeacherLastName,
    tr.TranslatorID,
    tr.FirstName AS TranslatorFirstName,
    tr.LastName  AS TranslatorLastName,
    b.BuildingName,
    b.RoomNumber,
    cm.ModuleID,
    cm.ModuleName,
    sb.SubjectID,
    sb.SubjectName
FROM dbo.Schedule sch
JOIN dbo.Buildings b 
    ON sch.ClassID = b.ClassID
JOIN dbo.Teachers t 
    ON sch.TeacherID = t.TeacherID
LEFT JOIN dbo.Translators tr 
    ON sch.TranslatorID = tr.TranslatorID
LEFT JOIN dbo.CourseModules cm 
    ON sch.CourseModuleID = cm.ModuleID
LEFT JOIN dbo.Subject sb 
    ON sch.StudiesSubjectID = sb.SubjectID;
GO

--WIDOK 5: v_StudentGrades
--Zestawienie ocen studentów z poszczególnych przedmiotów (Subject), wraz z informacją o koordynatorze przedmiotu i nazwą studiów.
CREATE OR ALTER VIEW dbo.v_StudentGrades
AS
SELECT
    sg.StudentID,
    st.FirstName AS StudentFirstName,
    st.LastName  AS StudentLastName,
    sb.SubjectID,
    sb.SubjectName,
    sb.CoordinatorID,
    tch.FirstName AS CoordinatorFirstName,
    tch.LastName  AS CoordinatorLastName,
    s.StudiesID,
    s.StudiesName,
    sg.SubjectGrade
FROM dbo.SubjectGrades sg
JOIN dbo.Students st 
    ON sg.StudentID = st.StudentID
JOIN dbo.Subject sb 
    ON sg.SubjectID = sb.SubjectID
JOIN dbo.Teachers tch 
    ON sb.CoordinatorID = tch.TeacherID
JOIN dbo.Studies s 
    ON sb.StudiesID = s.StudiesID;
GO
