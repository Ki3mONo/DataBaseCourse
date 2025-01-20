-- 1 Obliczanie całkowitej kwoty zamówienia
CREATE OR ALTER FUNCTION dbo.ufnGetOrderTotal
(
    @OrderID INT
)
RETURNS MONEY
AS
BEGIN
    DECLARE @Total MONEY;

    SELECT @Total = SUM(A.Price)
    FROM OrderDetails OD
    JOIN Activities A ON A.ActivityID = OD.ActivityID
    WHERE OD.OrderID = @OrderID;

    IF @Total IS NULL
        SET @Total = 0;

    RETURN @Total;
END;
GO

-- Przykładowe wywołanie
-- SELECT dbo.ufnGetOrderTotal(11) AS OrderTotal;

-- 2 Sprawdzanie dostępności miejsca w grupie kursowej
CREATE OR ALTER FUNCTION dbo.ufnGetStationaryModuleFreeSlots
(
    @ModuleID INT  -- odnosi się do StationaryModule.StationaryModuleID = CourseModules.ModuleID
)
RETURNS INT
AS
BEGIN
    DECLARE @Limit INT, @Count INT, @FreeSlots INT;

    SELECT @Limit = SM.[Limit]
    FROM StationaryModule SM
    WHERE SM.StationaryModuleID = @ModuleID;

    IF @Limit IS NULL
    BEGIN
        -- Brak takiego modułu -> np. zwracamy -1
        RETURN -1;
    END;

    -- Policz ilu uczestników przypisanych (tu przykład: CoursesAttendance)
    SELECT @Count = COUNT(*)
    FROM CoursesAttendance CA
    WHERE CA.ModuleID = @ModuleID
      AND CA.Attendance = 1; -- jeśli liczymy tylko obecnych
      -- lub po prostu: CA.ModuleID = @ModuleID (zarejestrowanych)

    SET @FreeSlots = @Limit - ISNULL(@Count,0);

    RETURN @FreeSlots;
END;
GO

-- Przykładowe wywołanie
-- SELECT dbo.ufnGetStationaryModuleFreeSlots(10) AS FreeSlots;

-- 3 Zliczanie aktywnych kursów w danym okresie
CREATE OR ALTER FUNCTION dbo.ufnCountActiveCoursesInPeriod
(
    @StartDate DATETIME,
    @EndDate   DATETIME
)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;

    WITH ActiveCourses AS
    (
      SELECT DISTINCT c.CourseID
      FROM Courses c
      JOIN Activities a ON a.ActivityID = c.ActivityID
      JOIN CourseModules cm ON cm.CourseID = c.CourseID
      WHERE a.Active = 1
        AND cm.Date >= @StartDate
        AND cm.Date <  @EndDate
    )
    SELECT @Count = COUNT(*)
    FROM ActiveCourses;

    RETURN @Count;
END;
GO

-- Przykładowe wywołanie
-- SELECT dbo.ufnCountActiveCoursesInPeriod('2025-01-01','2025-12-31') AS TotalActiveCourses;


-- 4 Pobieranie średniej ocen z przedmiotu
CREATE OR ALTER FUNCTION dbo.ufnGetSubjectAverageGrade
(
    @SubjectID INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Average DECIMAL(5,2);

    SELECT @Average = AVG(CAST(SubjectGrade AS DECIMAL(5,2)))
    FROM SubjectGrades
    WHERE SubjectID = @SubjectID;

    IF @Average IS NULL
        SET @Average = 0;

    RETURN @Average;
END;
GO

-- 5 Obliczanie wolnych miejsc w budynku
CREATE OR ALTER FUNCTION dbo.ufnGetFreeSeatsInBuilding
(
    @ClassID INT  -- klucz główny w Buildings
)
RETURNS INT
AS
BEGIN
    DECLARE @FreeSeats INT;

    ;WITH BuildingRooms AS
    (
        SELECT SC.StationaryClassID, SC.[Limit]
        FROM StationaryClass SC
        WHERE SC.ClassID = @ClassID
    ),
    Occupancy AS
    (
        -- Zliczamy wszystkich uczestników z danej StationaryClass (jeśli istnieje odwzorowanie)
        SELECT
            br.StationaryClassID,
            COUNT(*) AS Occupied
        FROM BuildingRooms br
        JOIN StudiesClass sc ON sc.StudyClassID = br.StationaryClassID  -- lub inny związek
        JOIN StudiesClassAttendance sca ON sca.StudyClassID = sc.StudyClassID
        GROUP BY br.StationaryClassID
    )
    SELECT @FreeSeats = SUM(br.[Limit] - ISNULL(o.Occupied, 0))
    FROM BuildingRooms br
    LEFT JOIN Occupancy o ON o.StationaryClassID = br.StationaryClassID;

    RETURN ISNULL(@FreeSeats, 0);
END;
GO

-- 6 Konwersja walut w cenach aktywności (EUR/PLN)
CREATE OR ALTER FUNCTION dbo.ufnConvertActivityPriceToEUR
(
    @ActivityID INT,
    @RateDate   DATETIME
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @PLN MONEY, @Rate DECIMAL(10,2), @EUR DECIMAL(10,2);

    SELECT @PLN = Price 
    FROM Activities
    WHERE ActivityID = @ActivityID;

    IF @PLN IS NULL
        RETURN 0;

    SELECT TOP(1) @Rate = Rate
    FROM EuroExchangeRate
    WHERE [Date] <= @RateDate
    ORDER BY [Date] DESC;  -- szukamy ostatniego znanego kursu przed/na dany dzień

    IF @Rate IS NULL
        RETURN 0;

    SET @EUR = CAST(@PLN AS DECIMAL(10,2)) / @Rate;

    RETURN @EUR;
END;
GO
-- Przykładowe wywołanie
-- SELECT dbo.ufnConvertActivityPriceToEUR(101, '2025-01-10') AS PriceInEUR;

-- 7 Pobieranie listy nauczycieli dla danego języka
CREATE OR ALTER FUNCTION dbo.ufnGetTeachersByLanguage
(
    @LanguageID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT t.TeacherID,
           t.FirstName,
           t.LastName,
           t.Email
    FROM Teachers t
    JOIN TeacherLanguages tl ON tl.TeacherID = t.TeacherID
    WHERE tl.LanguageID = @LanguageID
);
GO
-- Przykładowe wywołanie
-- SELECT * FROM dbo.ufnGetTeachersByLanguage(2);

-- 8 Obliczanie liczby zajęc w kursie 
CREATE OR ALTER FUNCTION dbo.ufnGetCourseTotalHours
(
    @CourseID INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @TotalMinutes INT;

    SELECT @TotalMinutes = SUM(DATEDIFF(MINUTE, 0, DurationTime))
    FROM CourseModules
    WHERE CourseID = @CourseID;

    IF @TotalMinutes IS NULL
        SET @TotalMinutes = 0;

    -- godziny dziesiętne (np. 90 minut -> 1.50 h)
    RETURN CAST(@TotalMinutes AS DECIMAL(5,2)) / 60;
END;
GO


--9 Wyświetlanie listy aktywności dostępnych dla danego języka
CREATE OR ALTER FUNCTION dbo.ufnListActivitiesByLanguage
(
    @LanguageID INT
)
RETURNS @Result TABLE
(
    ActivityType VARCHAR(20),
    ActivityName VARCHAR(50),
    ActivityDate DATETIME,
    LanguageID   INT,
    Price        MONEY
)
AS
BEGIN
    -- Webinary
    INSERT INTO @Result
    SELECT 
        'Webinar' AS ActivityType,
        w.WebinarName AS ActivityName,
        w.WebinarDate AS ActivityDate,
        w.LanguageID,
        a.Price
    FROM Webinars w
    JOIN Activities a ON a.ActivityID = w.ActivityID
    WHERE w.LanguageID = @LanguageID
      AND a.Active = 1;

    -- Kursy (wyświetlamy wg modułów -> bo tam jest LanguageID)
    INSERT INTO @Result
    SELECT 
        'CourseModule' AS ActivityType,
        c.CourseName + ' - ' + cm.ModuleName AS ActivityName,
        cm.Date AS ActivityDate,
        cm.LanguageID,
        a.Price
    FROM CourseModules cm
    JOIN Courses c ON c.CourseID = cm.CourseID
    JOIN Activities a ON a.ActivityID = c.ActivityID
    WHERE cm.LanguageID = @LanguageID
      AND a.Active = 1;

    -- Studia (zajęcia w StudiesClass)
    INSERT INTO @Result
    SELECT 
        'StudiesClass' AS ActivityType,
        sc.ClassName AS ActivityName,
        sc.[Date] AS ActivityDate,
        sc.LanguageID,
        a.Price
    FROM StudiesClass sc
    JOIN Activities a ON a.ActivityID = sc.ActivityID
    WHERE sc.LanguageID = @LanguageID
      AND a.Active = 1;

    RETURN;
END;
GO

-- Przykładowe wywołanie
-- SELECT *
-- FROM dbo.ufnListActivitiesByLanguage(3)
-- ORDER BY ActivityDate;

-- 10 Obliczanie sumarycznego czasu trwania webinaru
CREATE OR ALTER FUNCTION dbo.ufnGetWebinarTotalHours
(
    @WebinarID INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Minutes INT;

    SELECT @Minutes = DATEDIFF(MINUTE, 0, DurationTime)
    FROM Webinars
    WHERE WebinarID = @WebinarID;

    IF @Minutes IS NULL
        SET @Minutes = 0;

    RETURN CAST(@Minutes AS DECIMAL(5,2)) / 60;
END;
GO

-- 11 Obliczanie liczby uczestników w kursie
CREATE OR ALTER FUNCTION dbo.ufnGetCourseTotalParticipants
(
    @CourseID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @TotalParticipants INT;

    SELECT @TotalParticipants = COUNT(*)
    FROM CoursesAttendance
    WHERE ModuleID = @CourseID
      AND Attendance = 1;  -- tylko obecni

    RETURN @TotalParticipants;
END;
GO

-- 11 Harmonogram zajęć dla studenta
CREATE OR ALTER FUNCTION dbo.ufnGetStudentSchedule
(
    @StudentID INT
)
RETURNS @Schedule TABLE
(
    ActivityType  VARCHAR(20),
    ActivityName  VARCHAR(50),
    StartDate     DATETIME,
    EndDate       DATETIME
)
AS
BEGIN
    -- 1) Kursy (moduły), jeśli student jest zapisany
    INSERT INTO @Schedule
    SELECT 
        'Course' AS ActivityType,
        c.CourseName + ' - ' + cm.ModuleName AS ActivityName,
        cm.Date AS StartDate,
        DATEADD(MINUTE, DATEDIFF(MINUTE, 0, cm.DurationTime), cm.Date) AS EndDate
    FROM CourseParticipants cp
    JOIN Courses c ON c.CourseID = cp.CourseID
    JOIN CourseModules cm ON cm.CourseID = c.CourseID
    WHERE cp.StudentID = @StudentID;

    -- 2) Webinary
    INSERT INTO @Schedule
    SELECT
        'Webinar' AS ActivityType,
        w.WebinarName AS ActivityName,
        w.WebinarDate AS StartDate,
        DATEADD(MINUTE, DATEDIFF(MINUTE, 0, w.DurationTime), w.WebinarDate) AS EndDate
    FROM WebinarDetails wd
    JOIN Webinars w ON w.WebinarID = wd.WebinarID
    WHERE wd.StudentID = @StudentID;

    -- 3) Studia - zajęcia
    INSERT INTO @Schedule
    SELECT
        'StudiesClass' AS ActivityType,
        sc.ClassName AS ActivityName,
        sc.[Date] AS StartDate,
        DATEADD(MINUTE, DATEDIFF(MINUTE, 0, sc.DurationTime), sc.[Date]) AS EndDate
    FROM StudiesClassAttendance sca
    JOIN StudiesClass sc ON sc.StudyClassID = sca.StudyClassID
    WHERE sca.StudentID = @StudentID;

    RETURN;
END;
GO

-- 12 Generowanie raportu ocen dla danego studenta
CREATE OR ALTER FUNCTION dbo.ufnGetStudentGrades
(
    @StudentID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        sg.SubjectID,
        s.SubjectName,
        sg.SubjectGrade
    FROM SubjectGrades sg
    JOIN Subject s ON s.SubjectID = sg.SubjectID
    WHERE sg.StudentID = @StudentID
);
GO

-- 13 Generowanie listy obecności dla danego kursu
CREATE OR ALTER FUNCTION dbo.ufnGetCourseAttendanceList
(
    @CourseID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ca.ModuleID,
        cm.ModuleName,
        ca.StudentID,
        s.FirstName,
        s.LastName,
        ca.Attendance AS WasPresent
    FROM CoursesAttendance ca
    JOIN CourseModules cm ON cm.ModuleID = ca.ModuleID
    JOIN Students s ON s.StudentID = ca.StudentID
    WHERE cm.CourseID = @CourseID
);
GO

-- 14 Generowanie listy obecności dla danego studenta
CREATE OR ALTER FUNCTION dbo.ufnGetStudentAllAttendances
(
    @StudentID INT
)
RETURNS @Attendances TABLE
(
    ActivityType  VARCHAR(20),
    ActivityName  VARCHAR(50),
    DateOfEvent   DATETIME,
    WasPresent    BIT
)
AS
BEGIN
    -- 1) Kursy
    INSERT INTO @Attendances
    SELECT 
        'Course' AS ActivityType,
        c.CourseName + ' - ' + cm.ModuleName,
        cm.Date,
        ca.Attendance
    FROM CoursesAttendance ca
    JOIN CourseModules cm ON cm.ModuleID = ca.ModuleID
    JOIN Courses c ON c.CourseID = cm.CourseID
    WHERE ca.StudentID = @StudentID;

    -- 2) Studia
    INSERT INTO @Attendances
    SELECT
        'StudiesClass',
        sc.ClassName,
        sc.[Date],
        sca.Attendance
    FROM StudiesClassAttendance sca
    JOIN StudiesClass sc ON sc.StudyClassID = sca.StudyClassID
    WHERE sca.StudentID = @StudentID;

    -- 3) Webinary
    -- "Attendance" w WebinarDetails to pole "Complete"? lub "AvailableDue"? 
    -- Zakładamy, że "Complete" = 1 oznacza "obejrzany/ukończony".
    INSERT INTO @Attendances
    SELECT
        'Webinar',
        w.WebinarName,
        w.WebinarDate,
        wd.Complete
    FROM WebinarDetails wd
    JOIN Webinars w ON w.WebinarID = wd.WebinarID
    WHERE wd.StudentID = @StudentID;

    RETURN;
END;
GO
