-- 1. Automatyczne ustawianie statusu płatności przy dodaniu płatności do zamówienia
CREATE TRIGGER TR_OrderPaymentStatus_AfterInsert
ON dbo.OrderPaymentStatus
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Przykład: Jeżeli wstawiono wiersz bez statusu, ustaw "w trakcie"
    -- Jeżeli status to 'udana', ustaw PaidDate na bieżącą datę/czas
    UPDATE ops
    SET 
        OrderPaymentStatus = 
            CASE 
                WHEN i.OrderPaymentStatus IS NULL THEN 'w trakcie'
                ELSE i.OrderPaymentStatus 
            END,
        PaidDate =
            CASE
                WHEN i.OrderPaymentStatus = 'udana' THEN GETDATE()
                ELSE ops.PaidDate
            END
    FROM dbo.OrderPaymentStatus ops
    JOIN inserted i ON ops.PaymentURL = i.PaymentURL;
END;
GO

--2. Automatyczne dodawanie studenta do webinaru/kursu/studiów po udanym opłaceniu zamówienia
CREATE TRIGGER TR_OrderPaymentStatus_AfterUpdate_PaymentSuccess
ON dbo.OrderPaymentStatus
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Bierzemy tylko te rekordy, w których status stał się 'udana'
    -- (lub jest 'udana' po update)
    UPDATE ops
    SET PaidDate = GETDATE()
    FROM dbo.OrderPaymentStatus ops
    JOIN inserted i ON ops.PaymentURL = i.PaymentURL
    WHERE i.OrderPaymentStatus = 'udana';  -- np. automatycznie ustalamy PaidDate

    -- Teraz automatyczne dodanie studenta do kupionych aktywności
    ;WITH Changed AS
    (
      SELECT i.PaymentURL
      FROM inserted i
      JOIN deleted d ON i.PaymentURL = d.PaymentURL
      WHERE i.OrderPaymentStatus = 'udana'
        AND d.OrderPaymentStatus <> 'udana'
    )
    SELECT 1;  -- CTE do wyłapania TYLKO tych wierszy, gdzie doszło do zmiany

    -- Wstawianie do docelowych tabel w zależności od rodzaju Activity
    -- 1) Znajdź zamówienia, w których PaymentURL = changed
    -- 2) Dla każdego OrderID, pobierz StudentID
    -- 3) Przejrzyj OrderDetails -> sprawdź, czy to webinar, kurs czy studia 
    --    i wstaw do odpowiednich tabel

    INSERT INTO WebinarDetails (StudentID, WebinarID, Complete, AvailableDue)
    SELECT 
       o.StudentID,
       wb.WebinarID,
       0 AS Complete,
       DATEADD(DAY, 30, GETDATE()) AS AvailableDue
    FROM Changed ch
    JOIN dbo.Orders o 
        ON o.PaymentURL = ch.PaymentURL
    JOIN dbo.OrderDetails od 
        ON od.OrderID = o.OrderID
    JOIN dbo.Webinars wb 
        ON wb.ActivityID = od.ActivityID
    -- Zakładamy, że to jest webinar -> if matched, dodaj

    -- Kursy
    INSERT INTO CourseParticipants (CourseID, StudentID)
    SELECT 
       cr.CourseID,
       o.StudentID
    FROM Changed ch
    JOIN dbo.Orders o 
        ON o.PaymentURL = ch.PaymentURL
    JOIN dbo.OrderDetails od 
        ON od.OrderID = o.OrderID
    JOIN dbo.Courses cr
        ON cr.ActivityID = od.ActivityID;

    -- Studia -> Tabela Studies(StudiesID, ActivityID)
    --          i ewentualnie dodanie do "Studies participants"? (o ile taka istnieje)
    INSERT INTO [StudiesParticipants] (StudiesID, StudentID)
    SELECT 
       st.StudiesID,
       o.StudentID
    FROM Changed ch
    JOIN dbo.Orders o 
        ON o.PaymentURL = ch.PaymentURL
    JOIN dbo.OrderDetails od 
        ON od.OrderID = o.OrderID
    JOIN dbo.Studies st
        ON st.ActivityID = od.ActivityID;

    -- Dodatkowo można automatycznie dodać uczestnika do spotkań studyjnych
    -- (StudiesClassAttendance) -> wstaw pętlę lub SELECT/INSERT z listą spotkań
    INSERT INTO StudiesClassAttendance (StudyClassID, StudentID, Attendance)
    SELECT 
       sc.StudyClassID,
       o.StudentID,
       0 -- domyślnie brak obecności
    FROM Changed ch
    JOIN dbo.Orders o 
        ON o.PaymentURL = ch.PaymentURL
    JOIN dbo.OrderDetails od 
        ON od.OrderID = o.OrderID
    JOIN dbo.Studies st
        ON st.ActivityID = od.ActivityID
    JOIN dbo.StudiesClass sc
        ON sc.ActivityID = st.ActivityID; -- lub inne powiązanie

END;
GO

--3. Automatyczne uaktualnianie kursu walutowego co 24 godziny
-- Tworzenie zadania w SQL Server Agent
EXEC msdb.dbo.sp_add_job 
    @job_name = N'Job_UpdateEuroRate',
    @enabled = 1,
    @description = N'Automatyczne aktualizowanie kursu euro co 24 godz';

-- Dodanie kroku z dynamicznym pobieraniem kursu
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Job_UpdateEuroRate',
    @step_name = N'Step_UpdateEuroRate',
    @subsystem = N'TSQL',
    @command = N'EXEC dbo.uspGetEuroRateFromNBP;',
    @database_name = N'TwojaBaza';

-- Dodanie harmonogramu (co 24h)
EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'Job_UpdateEuroRate',
    @name = N'Daily',
    @freq_type=4, -- codziennie
    @freq_interval=1,
    @active_start_time=090000; -- start o 09:00

-- Dodanie zadania do serwera SQL
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Job_UpdateEuroRate',
    @server_name = N'(LOCAL)';


--4. Automatyczne usuwanie powiązanych uczestników kursu po usunięciu kursu
CREATE TRIGGER TR_Courses_AfterDelete
ON dbo.Courses
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Najpierw usuwamy powiązanych uczestników
    DELETE cp
    FROM dbo.CourseParticipants cp
    JOIN deleted d ON cp.CourseID = d.CourseID;

    -- Ewentualnie usuwamy powiązane wpisy frekwencji
    DELETE ca
    FROM dbo.CoursesAttendance ca
    JOIN dbo.CourseModules cm ON ca.ModuleID = cm.ModuleID
    JOIN deleted d ON cm.CourseID = d.CourseID;

    -- Ewentualnie usuwamy CourseModules (jeśli chcemy automatycznie usuwać także moduły)
    DELETE cm
    FROM dbo.CourseModules cm
    JOIN deleted d ON cm.CourseID = d.CourseID;

    PRINT 'All related participants, attendance records, and modules removed.';
END;
GO

--5. Zapobieganie dodaniu dwóch takich samych webinarów dla jednego nauczyciela
CREATE TRIGGER TR_Webinars_AfterInsert_UniqueTeacherWebinar
ON dbo.Webinars
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM dbo.Webinars w
        JOIN inserted i ON 
             w.TeacherID = i.TeacherID
             AND w.WebinarName = i.WebinarName
             AND w.WebinarID <> i.WebinarID
    )
    BEGIN
        RAISERROR('Cannot add duplicate webinar for the same teacher.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO


--6. Automatyczne zablokowanie usunięcia nauczyciela, jeśli jest przypisany do aktywnych zajęć
CREATE TRIGGER TR_Teachers_InsteadOfDelete_BlockIfActive
ON dbo.Teachers
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Sprawdzamy, czy w 'deleted' są nauczyciele przypisani do
    -- wciąż aktywnych kursów / webinarów / studiów...
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN CourseModules cm ON cm.TeacherID = d.TeacherID
        JOIN Courses c ON c.CourseID = cm.CourseID
        JOIN Activities a ON a.ActivityID = c.ActivityID
        WHERE a.Active = 1
    )
    OR EXISTS (
        SELECT 1
        FROM deleted d
        JOIN Webinars w ON w.TeacherID = d.TeacherID
        JOIN Activities a ON a.ActivityID = w.ActivityID
        WHERE a.Active = 1
    )
    -- Dodać analogicznie sprawdzenie dla StudiesClass, jeżeli to aktywne
    BEGIN
        RAISERROR('Cannot delete teacher: assigned to active classes.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Jeśli nie jest przypisany do niczego aktywnego, wykonaj właściwe DELETE
    DELETE t
    FROM dbo.Teachers t
    JOIN deleted d ON t.TeacherID = d.TeacherID;
END;
GO


--7. Automatyczne dodawanie nowego miasta do tabeli Cities, jeśli zostało wprowadzone przez nowego studenta
CREATE TRIGGER TR_Students_AfterInsert_AddCity
ON dbo.Students
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Wstaw miasta, których jeszcze nie ma w Cities
    INSERT INTO dbo.Cities (CityID, CityName, CountryID)
    SELECT DISTINCT 
        i.CityID,
        'Unknown',   -- lub i.CityName, jeśli w tabeli Students istniałoby takie pole
        1            -- domyślny CountryID
    FROM inserted i
    LEFT JOIN dbo.Cities c ON c.CityID = i.CityID
    WHERE c.CityID IS NULL;  -- nie ma jeszcze takiego miasta
END;
GO

