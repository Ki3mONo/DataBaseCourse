-- 1. Automatyczne ustawianie statusu płatności przy dodaniu płatności do zamówienia
CREATE OR ALTER TRIGGER TR_OrderPaymentStatus_AfterInsert
ON dbo.OrderPaymentStatus
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Jeśli wstawiono wiersz bez określonego statusu, ustaw domyślnie "Pending".
    -- Jeśli status = 'Paid', ustaw PaidDate na bieżącą datę/czas.
    UPDATE ops
    SET
        OrderPaymentStatus =
            CASE
                WHEN i.OrderPaymentStatus IS NULL THEN 'Pending'
                ELSE i.OrderPaymentStatus
            END,
        PaidDate =
            CASE
                WHEN i.OrderPaymentStatus = 'Paid' THEN GETDATE()
                ELSE ops.PaidDate
            END
    FROM dbo.OrderPaymentStatus ops
    JOIN inserted i ON ops.PaymentURL = i.PaymentURL;
END;
GO

--2. Automatyczne dodawanie studenta do webinaru/kursu/studiów po udanym opłaceniu zamówienia
CREATE OR ALTER TRIGGER TR_OrderPaymentStatus_AfterUpdate_PaymentSuccess
ON dbo.OrderPaymentStatus
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Uaktualnij PaidDate dla rekordów, których status stał się 'Paid'
    UPDATE ops
    SET PaidDate = GETDATE()
    FROM dbo.OrderPaymentStatus ops
    JOIN inserted i ON ops.PaymentURL = i.PaymentURL
    WHERE i.OrderPaymentStatus = 'Paid';

    -- Zapisz wynik CTE do tymczasowej tabeli #Changed
    ;WITH Changed AS
    (
        SELECT i.PaymentURL
        FROM inserted i
        JOIN deleted d ON i.PaymentURL = d.PaymentURL
        WHERE i.OrderPaymentStatus = 'Paid'
          AND d.OrderPaymentStatus <> 'Paid'
    )
    SELECT PaymentURL
    INTO #Changed
    FROM Changed;

    -- Dodaj studenta do WebinarDetails (przyjmujemy, że dana ActivityID odpowiada webinarowi)
    INSERT INTO WebinarDetails (StudentID, WebinarID, Complete, AvailableDue)
    SELECT
       o.StudentID,
       wb.WebinarID,
       0 AS Complete,
       DATEADD(DAY, 30, GETDATE()) AS AvailableDue
    FROM #Changed ch
    JOIN dbo.Orders o ON o.PaymentURL = ch.PaymentURL
    JOIN dbo.OrderDetails od ON od.OrderID = o.OrderID
    JOIN dbo.Webinars wb ON wb.ActivityID = od.ActivityID;

    -- Dodaj studenta do CourseParticipants
    INSERT INTO CourseParticipants (CourseID, StudentID)
    SELECT
       c.CourseID,
       o.StudentID
    FROM #Changed ch
    JOIN dbo.Orders o ON o.PaymentURL = ch.PaymentURL
    JOIN dbo.OrderDetails od ON od.OrderID = o.OrderID
    JOIN dbo.Courses c ON c.ActivityID = od.ActivityID;

    -- Dodaj studenta do StudiesClassAttendance (rejestracja na zajęciach studiów)
    INSERT INTO StudiesClassAttendance (StudyClassID, StudentID, Attendance)
    SELECT
       sc.StudyClassID,
       o.StudentID,
       0 -- domyślnie brak obecności
    FROM #Changed ch
    JOIN dbo.Orders o ON o.PaymentURL = ch.PaymentURL
    JOIN dbo.OrderDetails od ON od.OrderID = o.OrderID
    JOIN dbo.Studies st ON st.ActivityID = od.ActivityID
    JOIN dbo.StudiesClass sc ON sc.ActivityID = st.ActivityID;

    -- Usunięcie tymczasowej tabeli
    DROP TABLE #Changed;
END;
GO



--4. Automatyczne usuwanie powiązanych uczestników kursu po usunięciu kursu
CREATE OR ALTER TRIGGER TR_Courses_AfterDelete
ON dbo.Courses
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Usuwamy uczestników kursu
    DELETE cp
    FROM dbo.CourseParticipants cp
    JOIN deleted d ON cp.CourseID = d.CourseID;

    -- Usuwamy wpisy frekwencji
    DELETE ca
    FROM dbo.CoursesAttendance ca
    JOIN dbo.CourseModules cm ON ca.ModuleID = cm.ModuleID
    JOIN deleted d ON cm.CourseID = d.CourseID;

    -- Usuwamy moduły kursu
    DELETE cm
    FROM dbo.CourseModules cm
    JOIN deleted d ON cm.CourseID = d.CourseID;

    PRINT 'All related participants, attendance records, and modules removed.';
END;
GO


--5. Zapobieganie dodaniu dwóch takich samych webinarów dla jednego nauczyciela
CREATE OR ALTER TRIGGER TR_Webinars_AfterInsert_UniqueTeacherWebinar
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
CREATE OR ALTER TRIGGER TR_Teachers_InsteadOfDelete_BlockIfActive
ON dbo.Teachers
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Sprawdzenie, czy któremuś z usuwanych nauczycieli przypisane są aktywne kursy
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
    BEGIN
        RAISERROR('Cannot delete teacher: assigned to active classes.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Jeśli nie ma konfliktów – wykonaj usunięcie
    DELETE t
    FROM dbo.Teachers t
    JOIN deleted d ON t.TeacherID = d.TeacherID;
END;
GO


--7. Automatyczne dodawanie nowego miasta do tabeli Cities, jeśli zostało wprowadzone przez nowego studenta
CREATE OR ALTER TRIGGER TR_Students_AfterInsert_AddCity
ON dbo.Students
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Wstaw nowe miasta, które jeszcze nie istnieją
    INSERT INTO dbo.Cities (CityID, CityName, CountryID)
    SELECT DISTINCT
        i.CityID,
        'Unknown',   -- lub i.CityName, jeżeli taka kolumna istnieje w Students
        1            -- domyślny CountryID (np. Polska)
    FROM inserted i
    LEFT JOIN dbo.Cities c ON c.CityID = i.CityID
    WHERE c.CityID IS NULL;
END;
GO


