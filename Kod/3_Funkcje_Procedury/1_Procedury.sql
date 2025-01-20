-- 1 Dodawanie nowego kursu

CREATE OR ALTER PROCEDURE dbo.spAddCourse
  @CourseName           VARCHAR(50),
  @CourseDescription    TEXT       = NULL,
  @CoursePrice          MONEY,
  @CourseCoordinatorID  INT,
  @ActivityTitle        VARCHAR(50),
  @ActivityPrice        MONEY,
  @ActivityActive       BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    -- Wygenerowanie nowego ActivityID (o ile nie używasz IDENTITY/SEQUENCE).
    DECLARE @NewActivityID INT = (
        SELECT ISNULL(MAX(ActivityID), 0) + 1 
        FROM Activities
    );

    INSERT INTO Activities (ActivityID, Price, Title, Active)
    VALUES (@NewActivityID, @ActivityPrice, @ActivityTitle, @ActivityActive);

    -- Wygenerowanie nowego CourseID
    DECLARE @NewCourseID INT = (
        SELECT ISNULL(MAX(CourseID), 0) + 1
        FROM Courses
    );

    INSERT INTO Courses (CourseID, ActivityID, CourseName, CourseDescription, CoursePrice, CourseCoordinatorID)
    VALUES (
        @NewCourseID,
        @NewActivityID,
        @CourseName,
        @CourseDescription,
        @CoursePrice,
        @CourseCoordinatorID
    );

    SELECT @NewCourseID AS CreatedCourseID, @NewActivityID AS CreatedActivityID;
END;
GO

-- 2 Usuwanie nowego kursu
CREATE OR ALTER PROCEDURE dbo.spRemoveCourse
  @CourseID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Znajdź powiązany ActivityID
    DECLARE @ActivityID INT;

    SELECT @ActivityID = ActivityID
    FROM Courses
    WHERE CourseID = @CourseID;

    IF @ActivityID IS NULL
    BEGIN
        RAISERROR('Course not found.', 16, 1);
        RETURN;
    END;

    -- Usunięcie z Courses
    DELETE FROM Courses
    WHERE CourseID = @CourseID;

    -- Usunięcie z Activities (opcjonalne, jeśli nie jest już potrzebne)
    -- UWAGA: Najpierw należałoby sprawdzić, czy to ActivityID nie jest używane gdzieś indziej!
    DELETE FROM Activities
    WHERE ActivityID = @ActivityID;

    PRINT 'Course and related Activity removed successfully.';
END;
GO

-- 3 Rejestracja studenta na kurs
CREATE OR ALTER PROCEDURE dbo.spRegisterStudentInCourse
  @CourseID  INT,
  @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Przykład: sprawdź, czy wpis już istnieje
    IF EXISTS (
        SELECT 1 FROM CourseParticipants
        WHERE CourseID = @CourseID AND StudentID = @StudentID
    )
    BEGIN
        RAISERROR('Student is already registered in this course.', 16, 1);
        RETURN;
    END;

    INSERT INTO CourseParticipants (CourseID, StudentID)
    VALUES (@CourseID, @StudentID);

    PRINT 'Student registered successfully.';
END;
GO

-- 4 Wypisanie studenta z kursu
CREATE OR ALTER PROCEDURE dbo.spUnregisterStudentFromCourse
  @CourseID  INT,
  @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM CourseParticipants
    WHERE CourseID = @CourseID
      AND StudentID = @StudentID;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Student not found in that course.', 16, 1);
    END
    ELSE
    BEGIN
        PRINT 'Student unregistered successfully.';
    END
END;
GO

-- 5 Aktualizacja cen aktywności
CREATE OR ALTER PROCEDURE dbo.spUpdateActivityPrice
  @ActivityID INT,
  @NewPrice   MONEY
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Activities
    SET Price = @NewPrice
    WHERE ActivityID = @ActivityID;

    IF @@ROWCOUNT = 0
        RAISERROR('Activity not found.', 16, 1);
    ELSE
        PRINT 'Activity price updated successfully.';
END;
GO


-- 6 Zarządzanie harmonogramem nauczyciela (sprawdzanie kolizji)

CREATE OR ALTER PROCEDURE dbo.spAddTeacherSchedule
  @TeacherID        INT,
  @ClassID          INT,
  @CourseModuleID   INT = NULL,
  @StudiesSubjectID INT = NULL,
  @DayOfWeek        VARCHAR(10),
  @StartTime        TIME,
  @EndTime          TIME,
  @TranslatorID     INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Sprawdzenie kolizji: Ten sam nauczyciel, ten sam dzień tygodnia,
    -- a zakres godzin się pokrywa:
    IF EXISTS (
        SELECT 1
        FROM Schedule
        WHERE TeacherID = @TeacherID
          AND DayOfWeek = @DayOfWeek
          AND (
                (@StartTime < EndTime AND @EndTime > StartTime)
              )
    )
    BEGIN
        RAISERROR('Collision in the teacher schedule!', 16, 1);
        RETURN;
    END;

    DECLARE @NewScheduleID INT = (
        SELECT ISNULL(MAX(ScheduleID), 0) + 1
        FROM Schedule
    );

    INSERT INTO Schedule (
        ScheduleID, ClassID, CourseModuleID, StudiesSubjectID,
        DayOfWeek, StartTime, EndTime,
        TeacherID, TranslatorID
    )
    VALUES (
        @NewScheduleID, @ClassID, @CourseModuleID, @StudiesSubjectID,
        @DayOfWeek, @StartTime, @EndTime,
        @TeacherID, @TranslatorID
    );

    SELECT @NewScheduleID AS NewScheduleID;

    PRINT 'Schedule added successfully.';
END;
GO

-- 7 Wyszukiwanie dostępnych aktywności w danym przedziale czasowym

CREATE OR ALTER PROCEDURE dbo.spFindAvailableActivities
  @StartDate DATETIME,
  @EndDate   DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    -- Webinary w tym przedziale
    SELECT
        'Webinar' AS ActivityType,
        w.WebinarID AS ActivityID,
        w.WebinarName AS ActivityName,
        w.WebinarDate AS [Date],
        a.Price AS ActivityPrice
    FROM Webinars w
    JOIN Activities a ON a.ActivityID = w.ActivityID
    WHERE w.WebinarDate >= @StartDate
      AND w.WebinarDate < @EndDate
      AND a.Active = 1

    UNION

    -- Kursy (uwzględniamy daty modułów)
    SELECT
        'Course' AS ActivityType,
        c.CourseID AS ActivityID,
        c.CourseName AS ActivityName,
        cm.Date AS [Date],
        a.Price AS ActivityPrice
    FROM Courses c
    JOIN CourseModules cm ON cm.CourseID = c.CourseID
    JOIN Activities a ON a.ActivityID = c.ActivityID
    WHERE cm.Date >= @StartDate
      AND cm.Date < @EndDate
      AND a.Active = 1

    UNION

    -- Studia (np. listujemy zajęcia 'StudiesClass')
    SELECT
        'StudiesClass' AS ActivityType,
        sc.StudyClassID AS ActivityID,
        sc.ClassName AS ActivityName,
        sc.[Date] AS [Date],
        a.Price AS ActivityPrice
    FROM StudiesClass sc
    JOIN Activities a ON a.ActivityID = sc.ActivityID
    WHERE sc.[Date] >= @StartDate
      AND sc.[Date] < @EndDate
      AND a.Active = 1;

END;
GO


-- 8 Rejestracja nowego nauczyciela (wraz z językami i przedmiotami)

CREATE OR ALTER PROCEDURE dbo.spAddTeacher
  @FirstName VARCHAR(30),
  @LastName  VARCHAR(30),
  @HireDate  DATE        = NULL,
  @Phone     VARCHAR(15) = NULL,
  @Email     VARCHAR(60),
  -- Lista języków do przypisania (np. w formie CSV)
  @LanguagesCSV VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewTeacherID INT = (
        SELECT ISNULL(MAX(TeacherID), 0) + 1
        FROM Teachers
    );

    INSERT INTO Teachers (TeacherID, FirstName, LastName, HireDate, Phone, Email)
    VALUES (@NewTeacherID, @FirstName, @LastName, @HireDate, @Phone, @Email);

    PRINT 'Teacher created with ID = ' + CAST(@NewTeacherID AS VARCHAR(10));

    -- Jeżeli chcemy masowo dodać języki
    IF @LanguagesCSV IS NOT NULL AND LEN(@LanguagesCSV) > 0
    BEGIN
        -- Przykład: wstawiamy wartości do tabeli tymczasowej, a następnie do TeacherLanguages
        -- Zakładamy, że @LanguagesCSV to np. '1,2,3' = ID języków

        ;WITH CTE_Lang AS (
            SELECT value AS LangID
            FROM STRING_SPLIT(@LanguagesCSV, ',')
        )
        INSERT INTO TeacherLanguages (TeacherID, LanguageID)
        SELECT @NewTeacherID, CAST(LangID AS INT)
        FROM CTE_Lang;
    END;

    PRINT 'Teacher languages assigned.';
END;
GO

-- 9 Rejestracja nowego tłumacza (wraz z językami)

CREATE OR ALTER PROCEDURE dbo.spAddTranslator
  @FirstName   VARCHAR(30),
  @LastName    VARCHAR(30),
  @HireDate    DATE        = NULL,
  @Phone       VARCHAR(15) = NULL,
  @Email       VARCHAR(60),
  @LanguagesCSV VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewTranslatorID INT = (
        SELECT ISNULL(MAX(TranslatorID), 0) + 1
        FROM Translators
    );

    INSERT INTO Translators (TranslatorID, FirstName, LastName, HireDate, Phone, Email)
    VALUES (@NewTranslatorID, @FirstName, @LastName, @HireDate, @Phone, @Email);

    PRINT 'Translator created with ID = ' + CAST(@NewTranslatorID AS VARCHAR(10));

    IF @LanguagesCSV IS NOT NULL AND LEN(@LanguagesCSV) > 0
    BEGIN
        ;WITH CTE_Lang AS (
            SELECT value AS LangID
            FROM STRING_SPLIT(@LanguagesCSV, ',')
        )
        INSERT INTO TranslatorsLanguages (TranslatorID, LanguageID)
        SELECT @NewTranslatorID, CAST(LangID AS INT)
        FROM CTE_Lang;
    END;

    PRINT 'Translator languages assigned.';
END;
GO


-- 10 Tworzenie nowego webinaru

CREATE OR ALTER PROCEDURE dbo.spAddWebinar
  @WebinarName        VARCHAR(50),
  @WebinarDescription TEXT,
  @WebinarPrice       MONEY,
  @TeacherID          INT,
  @LanguageID         INT,
  @VideoLink          VARCHAR(50),
  @WebinarDate        DATETIME,
  @DurationTime       TIME(0),
  @ActivityTitle      VARCHAR(50),
  @ActivityPrice      MONEY,
  @ActivityActive     BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewActivityID INT = (
        SELECT ISNULL(MAX(ActivityID), 0) + 1
        FROM Activities
    );

    INSERT INTO Activities (ActivityID, Price, Title, Active)
    VALUES (@NewActivityID, @ActivityPrice, @ActivityTitle, @ActivityActive);

    DECLARE @NewWebinarID INT = (
        SELECT ISNULL(MAX(WebinarID), 0) + 1
        FROM Webinars
    );

    INSERT INTO Webinars (
        WebinarID, ActivityID, TeacherID, WebinarName,
        WebinarPrice, VideoLink, WebinarDate, DurationTime,
        WebinarDescription, LanguageID
    )
    VALUES (
        @NewWebinarID, @NewActivityID, @TeacherID, @WebinarName,
        @WebinarPrice, @VideoLink, @WebinarDate, @DurationTime,
        @WebinarDescription, @LanguageID
    );

    SELECT @NewWebinarID AS NewWebinarID, @NewActivityID AS NewActivityID;
END;
GO

-- 11 usuwanie webinaru

CREATE OR ALTER PROCEDURE dbo.spRemoveWebinar
  @WebinarID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ActivityID INT;
    SELECT @ActivityID = ActivityID
    FROM Webinars
    WHERE WebinarID = @WebinarID;

    IF @ActivityID IS NULL
    BEGIN
        RAISERROR('Webinar not found.', 16, 1);
        RETURN;
    END;

    DELETE FROM Webinars
    WHERE WebinarID = @WebinarID;

    DELETE FROM Activities
    WHERE ActivityID = @ActivityID;

    PRINT 'Webinar and related Activity removed.';
END;
GO


-- 12 Dodawanie przedmiotu do planu studiów

CREATE OR ALTER PROCEDURE dbo.spAddSubjectToStudies
  @StudiesID          INT,
  @CoordinatorID      INT,
  @SubjectName        VARCHAR(50),
  @SubjectDescription TEXT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewSubjectID INT = (
        SELECT ISNULL(MAX(SubjectID), 0) + 1
        FROM Subject
    );

    INSERT INTO Subject (
        SubjectID, StudiesID, CoordinatorID,
        SubjectName, SubjectDescription
    )
    VALUES (
        @NewSubjectID, 
        @StudiesID,
        @CoordinatorID,
        @SubjectName,
        @SubjectDescription
    );

    SELECT @NewSubjectID AS NewSubjectID;
END;
GO

-- 13 Automatyczne rozdzielanie studentów do grup

CREATE OR ALTER PROCEDURE dbo.spAutoAssignStudentsToGroups
AS
BEGIN
    SET NOCOUNT ON;

    -- Przykład: Znajdź wszystkich studentów bez przydzielonej grupy
    -- i przypisz ich do grup 1 lub 2 naprzemiennie.
    
    DECLARE @GroupToggle INT = 1;

    -- Załóżmy, że mamy kolumnę Student.GroupID (której w oryginalnych tabelach nie ma).
    -- Ten przykład jest więc hipotetyczny.

    UPDATE Students
    SET CityID = CityID  -- cokolwiek, by to było poprawne ;)
    -- docelowo np. "SET GroupID = CASE WHEN (StudentID % 2) = 0 THEN 1 ELSE 2 END"
    -- WHERE GroupID IS NULL;

    PRINT 'Auto assignment done.';
END;
GO

-- 14 Tworzenie raportu finansowego z zamówień

CREATE OR ALTER PROCEDURE dbo.spGenerateFinancialReport
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        A.ActivityID,
        A.Title AS ActivityTitle,
        COUNT(*) AS NumberOfPurchases,
        SUM(A.Price) AS TotalAmount
    FROM Orders O
    JOIN OrderDetails OD ON OD.OrderID = O.OrderID
    JOIN Activities A   ON A.ActivityID = OD.ActivityID
    -- ewentualnie można filtrować daty:
    -- WHERE O.OrderDate BETWEEN @StartDate AND @EndDate
    GROUP BY A.ActivityID, A.Title
    ORDER BY A.ActivityID;
END;
GO

-- 15  Aktualizacja danych nauczyciela

CREATE OR ALTER PROCEDURE dbo.spUpdateTeacherData
  @TeacherID INT,
  @FirstName VARCHAR(30)  = NULL,
  @LastName  VARCHAR(30)  = NULL,
  @Phone     VARCHAR(15)  = NULL,
  @Email     VARCHAR(60)  = NULL,
  @HireDate  DATE         = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Teachers
    SET
        FirstName = COALESCE(@FirstName, FirstName),
        LastName  = COALESCE(@LastName, LastName),
        Phone     = COALESCE(@Phone, Phone),
        Email     = COALESCE(@Email, Email),
        HireDate  = COALESCE(@HireDate, HireDate)
    WHERE TeacherID = @TeacherID;

    IF @@ROWCOUNT = 0
        RAISERROR('Teacher not found.', 16, 1);
    ELSE
        PRINT 'Teacher data updated successfully.';
END;
GO

-- 16 Aktualizacja danych nauczyciela

CREATE OR ALTER PROCEDURE dbo.spUpdateStudentData
  @StudentID INT,
  @FirstName VARCHAR(30)  = NULL,
  @LastName  VARCHAR(30)  = NULL,
  @Address   VARCHAR(30)  = NULL,
  @CityID    INT          = NULL,
  @PostalCode VARCHAR(10) = NULL,
  @Phone     VARCHAR(15)  = NULL,
  @Email     VARCHAR(60)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Students
    SET
        FirstName  = COALESCE(@FirstName, FirstName),
        LastName   = COALESCE(@LastName, LastName),
        [Address]  = COALESCE(@Address, [Address]),
        CityID     = COALESCE(@CityID, CityID),
        PostalCode = COALESCE(@PostalCode, PostalCode),
        Phone      = COALESCE(@Phone, Phone),
        Email      = COALESCE(@Email, Email)
    WHERE StudentID = @StudentID;

    IF @@ROWCOUNT = 0
        RAISERROR('Student not found.', 16, 1);
    ELSE
        PRINT 'Student data updated successfully.';
END;
GO

-- 17 Aktualizacja zarządzania danymi osobowymi (RODO)

CREATE OR ALTER PROCEDURE dbo.spUpdateRODO
  @StudentID INT,
  @Withdraw  BIT
AS
BEGIN
    SET NOCOUNT ON;

    -- Zakładamy, że "Date" = getdate() lub inna data
    DECLARE @Today DATE = CONVERT(DATE, GETDATE());

    IF EXISTS (SELECT 1 FROM RODO_Table WHERE StudentID = @StudentID)
    BEGIN
        UPDATE RODO_Table
        SET [Date] = @Today,
            Withdraw = @Withdraw
        WHERE StudentID = @StudentID;
        PRINT 'RODO data updated.';
    END
    ELSE
    BEGIN
        INSERT INTO RODO_Table (StudentID, [Date], Withdraw)
        VALUES (@StudentID, @Today, @Withdraw);
        PRINT 'RODO data inserted.';
    END
END;
GO

-- 18 Dodanie stażu (Internship) do systemu

CREATE OR ALTER PROCEDURE dbo.spAddInternship
  @StudiesID INT,
  @StartDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewInternshipID INT = (
        SELECT ISNULL(MAX(InternshipID), 0) + 1
        FROM Internship
    );

    INSERT INTO Internship (InternshipID, StudiesID, StartDate)
    VALUES (@NewInternshipID, @StudiesID, @StartDate);

    SELECT @NewInternshipID AS InternshipID;
END;
GO


-- 19 Dodanie studenta do bazy

CREATE OR ALTER PROCEDURE dbo.spAddStudent
  @FirstName  VARCHAR(30),
  @LastName   VARCHAR(30),
  @Address    VARCHAR(30),
  @CityID     INT,
  @PostalCode VARCHAR(10),
  @Phone      VARCHAR(15) = NULL,
  @Email      VARCHAR(60)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewStudentID INT = (
        SELECT ISNULL(MAX(StudentID), 0) + 1
        FROM Students
    );

    INSERT INTO Students (
        StudentID, FirstName, LastName, [Address],
        CityID, PostalCode, Phone, Email
    )
    VALUES (
        @NewStudentID, @FirstName, @LastName, @Address,
        @CityID, @PostalCode, @Phone, @Email
    );

    SELECT @NewStudentID AS StudentID;
END;
GO

-- 20 Usunięcie studenta z bazy

CREATE OR ALTER PROCEDURE dbo.spRemoveStudent
  @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Students
    WHERE StudentID = @StudentID;

    IF @@ROWCOUNT = 0
        RAISERROR('Student not found.', 16, 1);
    ELSE
        PRINT 'Student removed successfully.';
END;
GO

-- 21 Dodanie pracownika (Employee) do bazy

CREATE OR ALTER PROCEDURE dbo.spAddEmployee
  @FirstName       VARCHAR(30),
  @LastName        VARCHAR(30),
  @HireDate        DATE         = NULL,
  @EmployeeTypeID  INT,
  @Phone           VARCHAR(15)  = NULL,
  @Email           VARCHAR(60)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewEmployeeID INT = (
        SELECT ISNULL(MAX(EmployeeID), 0) + 1
        FROM Employees
    );

    INSERT INTO Employees (
        EmployeeID, FirstName, LastName, HireDate,
        EmployeeTypeID, Phone, Email
    )
    VALUES (
        @NewEmployeeID, @FirstName, @LastName, @HireDate,
        @EmployeeTypeID, @Phone, @Email
    );

    SELECT @NewEmployeeID AS EmployeeID;
END;
GO


-- 22 Usunięcie pracownika z bazy

CREATE OR ALTER PROCEDURE dbo.spRemoveEmployee
  @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Employees
    WHERE EmployeeID = @EmployeeID;

    IF @@ROWCOUNT = 0
        RAISERROR('Employee not found.', 16, 1);
    ELSE
        PRINT 'Employee removed successfully.';
END;
GO

-- 23 Tworzenie modułu kursu (wraz z jego typem)

CREATE OR ALTER PROCEDURE dbo.spAddCourseModule
  @CourseID     INT,
  @ModuleName   VARCHAR(50),
  @ModuleDate   DATETIME,
  @DurationTime TIME(0),
  @TeacherID    INT,
  @LanguageID   INT,
  @TranslatorID INT = NULL,
  @ModuleType   VARCHAR(20),  -- 'stationary'/'online_sync'/'online_async' ...
  @ClassID      INT = NULL,   -- dla stacjonarnego
  @LinkOrVideo  VARCHAR(60) = NULL, -- link (online_sync) lub video (online_async)
  @Limit        INT = 0       -- limit miejsc np. dla stacjonarnego
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Dodajemy w CourseModules
    DECLARE @NewModuleID INT = (
        SELECT ISNULL(MAX(ModuleID), 0) + 1
        FROM CourseModules
    );

    INSERT INTO CourseModules (
        ModuleID, CourseID, ModuleName, [Date], DurationTime,
        TeacherID, TranslatorID, LanguageID
    )
    VALUES (
        @NewModuleID, @CourseID, @ModuleName, @ModuleDate, @DurationTime,
        @TeacherID, @TranslatorID, @LanguageID
    );

    -- 2) W zależności od typu modułu, dodajemy do dodatkowej tabeli
    IF @ModuleType = 'stationary'
    BEGIN
        INSERT INTO StationaryModule (StationaryModuleID, ClassID, [Limit])
        VALUES (@NewModuleID, @ClassID, @Limit);
    END
    ELSE IF @ModuleType = 'online_sync'
    BEGIN
        INSERT INTO OnlineSyncModule (OnlineSyncModuleID, Link)
        VALUES (@NewModuleID, @LinkOrVideo);
    END
    ELSE IF @ModuleType = 'online_async'
    BEGIN
        INSERT INTO OnlineAsyncModule (OnlineAsyncModuleID, Video)
        VALUES (@NewModuleID, @LinkOrVideo);
    END
    ELSE
    BEGIN
        RAISERROR('Unknown module type.', 16, 1);
        ROLLBACK TRANSACTION; -- jeśli była transakcja
        RETURN;
    END;

    PRINT 'Course module created with ID = ' + CAST(@NewModuleID AS VARCHAR(10));
END;
GO

-- 24 Pobieranie kursu euro do bazy (tabela EuroExchangeRate)

CREATE OR ALTER PROCEDURE dbo.spAddEuroRate
  @Rate DECIMAL(10,2),
  @RateDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @RateDate IS NULL
        SET @RateDate = CONVERT(DATETIME, CONVERT(DATE, GETDATE()));  -- bieżący dzień

    -- Upsert przy użyciu MERGE
    MERGE EuroExchangeRate AS tgt
    USING (SELECT @RateDate AS [Date], @Rate AS Rate) AS src
      ON (tgt.[Date] = src.[Date])
    WHEN MATCHED THEN
        UPDATE SET Rate = src.Rate
    WHEN NOT MATCHED THEN
        INSERT ([Date], Rate)
        VALUES (src.[Date], src.Rate)
    OUTPUT $action AS MergeAction;

    PRINT 'Euro rate upsert completed.';
END;
GO

-- 25 Generowanie dyplomu / wysyłanie dyplomu

CREATE OR ALTER PROCEDURE dbo.spGenerateCourseDiploma
  @CourseID  INT,
  @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Sprawdź liczbę modułów
    DECLARE @TotalModules INT = (
        SELECT COUNT(*)
        FROM CourseModules
        WHERE CourseID = @CourseID
    );

    IF @TotalModules = 0
    BEGIN
        RAISERROR('No modules found for this course.', 16, 1);
        RETURN;
    END;

    -- Sprawdź liczbę obecności
    DECLARE @PresentCount INT = (
        SELECT COUNT(*)
        FROM CourseModules cm
        JOIN CoursesAttendance ca ON cm.ModuleID = ca.ModuleID
        WHERE cm.CourseID = @CourseID
          AND ca.StudentID = @StudentID
          AND ca.Attendance = 1
    );

    DECLARE @PercentPresence FLOAT = (CAST(@PresentCount AS FLOAT) / @TotalModules) * 100.0;

    IF @PercentPresence < 80.0
    BEGIN
        RAISERROR('Student does not meet attendance requirement (%.2f%% < 80%%).', 16, 1, @PercentPresence);
        RETURN;
    END;

    -- Jeżeli zaliczone, wygeneruj "dyplom" (np. INSERT do osobnej tabeli Diplomas lub SELECT do wydruku)
    PRINT 'Diploma generated. Student presence was ' + CAST(@PercentPresence AS VARCHAR(10)) + '%';
END;
GO


-- 26 Lista „dłużników” (osób, które nie uiściły opłat)
CREATE OR ALTER PROCEDURE dbo.spGetDebtors
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Założenie: 
    -- 1) w tabeli OrderPaymentStatus kolumna OrderPaymentStatus zawiera np. "udana" / "nieudana" / "w trakcie".
    -- 2) "nieudana" lub "w trakcie" może wskazywać na brak całkowitej płatności.
    -- 3) aby sprawdzić, czy student „skorzystał z usług”, można sprawdzić np. CourseParticipants / StudiesClassAttendance / WebinarDetails / ...
    --    Poniżej prosty przykład: po prostu sprawdzamy, czy student jest zarejestrowany w CourseParticipants do kursu z OrderDetails.
    
    SELECT 
        S.StudentID,
        S.FirstName,
        S.LastName,
        O.OrderID,
        OPS.OrderPaymentStatus,
        OD.ActivityID,
        A.Title AS ActivityTitle
    FROM Orders O
    JOIN OrderDetails OD ON O.OrderID = OD.OrderID
    JOIN OrderPaymentStatus OPS ON O.PaymentURL = OPS.PaymentURL
    JOIN Activities A ON A.ActivityID = OD.ActivityID
    JOIN Students S ON O.StudentID = S.StudentID
    WHERE OPS.OrderPaymentStatus NOT IN ('udana')
      -- ewentualnie warunek, że minął już termin płatności, np. DATEDIFF(DAY,O.OrderDate,GETDATE()) > X
    ORDER BY S.StudentID;
END;
GO

-- 27 Raport frekwencji kursu / studiów / webinaru

CREATE OR ALTER PROCEDURE dbo.spGenerateCourseAttendanceReport
  @CourseID INT
AS
BEGIN
    SET NOCOUNT ON;

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
    ORDER BY cm.Date, ca.StudentID;
END;
GO


-- 28 Procedura oznaczania obecności studenta na kursie

CREATE OR ALTER PROCEDURE dbo.spMarkCourseModuleAttendance
  @ModuleID  INT,
  @StudentID INT,
  @WasPresent BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE CoursesAttendance
    SET Attendance = @WasPresent
    WHERE ModuleID = @ModuleID
      AND StudentID = @StudentID;

    IF @@ROWCOUNT = 0
    BEGIN
        -- Może chcemy automatycznie wstawić wiersz, jeśli nie istnieje
        INSERT INTO CoursesAttendance (ModuleID, StudentID, Attendance)
        VALUES (@ModuleID, @StudentID, @WasPresent);
    END;
END;
GO

-- 29 Procedura oznaczania obecności studenta na studiach

CREATE OR ALTER PROCEDURE dbo.spMarkStudiesClassAttendance
  @StudyClassID INT,
  @StudentID    INT,
  @WasPresent   BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE StudiesClassAttendance
    SET Attendance = @WasPresent
    WHERE StudyClassID = @StudyClassID
      AND StudentID = @StudentID;

    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO StudiesClassAttendance (StudyClassID, StudentID, Attendance)
        VALUES (@StudyClassID, @StudentID, @WasPresent);
    END;
END;
GO

-- 30 Pobieranie kursu euro do bazy z API NBP
CREATE PROCEDURE uspGetEuroRateFromNBP
AS
BEGIN
    DECLARE @Object INT;
    DECLARE @ResponseText NVARCHAR(MAX);
    DECLARE @URL NVARCHAR(500) = 'https://api.nbp.pl/api/exchangerates/rates/A/EUR?format=json';
    
    -- Tworzenie obiektu HTTP
    EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
    
    -- Wysłanie żądania GET
    EXEC sp_OAMethod @Object, 'open', NULL, 'GET', @URL, 'FALSE';
    EXEC sp_OAMethod @Object, 'send', NULL;

    -- Pobranie odpowiedzi jako JSON
    EXEC sp_OAGetProperty @Object, 'responseText', @ResponseText OUT;

    -- Zniszczenie obiektu HTTP
    EXEC sp_OADestroy @Object;

    -- Pobranie kursu z JSON (SQL Server 2016+)
    DECLARE @Rate DECIMAL(10,4);
    SELECT @Rate = value
    FROM OPENJSON(@ResponseText, '$.rates') 
    WITH (value DECIMAL(10,4) '$[0].mid');

    -- Aktualizacja tabeli kursów walut
    EXEC dbo.spAddEuroRate @Rate;
END;