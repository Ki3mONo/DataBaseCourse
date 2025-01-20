-------------------------------------------------------------------------------
-- 1) Ustawiamy bazę danych, np.:
-------------------------------------------------------------------------------
USE u_kmak;
GO

-------------------------------------------------------------------------------
-- 2) Wstawiamy przykładowe dane w tabelach referencyjnych (kraje, miasta)
-------------------------------------------------------------------------------
INSERT INTO dbo.Countries (CountryID, CountryName)
VALUES
  (21, 'Zimbabwe'),
  (22, 'Brasil');

SELECT * FROM dbo.Countries
    WHERE CountryID IN (21, 22);

DELETE from dbo.Countries where CountryID = 21;
DELETE from dbo.Countries where CountryID = 22;

INSERT INTO dbo.Cities (CityID, CityName, CountryID)
VALUES
  (101, 'Jasło', 1),
  (102, 'Zgorzelec', 1),
  (103, 'Berlin', 3);

SELECT * FROM dbo.Cities
    WHERE CityID IN (101, 102, 103);

DELETE from dbo.Cities where CityID = 101;
DELETE from dbo.Cities where CityID = 102;
DELETE from dbo.Cities where CityID = 103;
-------------------------------------------------------------------------------
-- 3) Wstawiamy przykładowego studenta
-------------------------------------------------------------------------------
INSERT INTO dbo.Students (StudentID, FirstName, LastName, [Address], CityID, PostalCode, Phone, Email)
VALUES
 (1501, 'Jan', 'Kowalski', 'ul. Długa 10', 10, '30-000', '500123456', 'jan.kowalski@example.com');

INSERT INTO dbo.Students (StudentID, FirstName, LastName, [Address], CityID, PostalCode, Phone, Email)
VALUES
 (1502, 'Maria', 'Nowak', 'ul. Krótka 3', 20, '00-123', '501234567', 'maria.nowak@example.com');

SELECT * FROM dbo.Students
    WHERE StudentID IN (1501, 1502);

DELETE from dbo.Students where StudentID = 1501;
DELETE from dbo.Students where StudentID = 1502;
-------------------------------------------------------------------------------
-- 4) Wstawiamy przykładowego nauczyciela i tłumacza
-------------------------------------------------------------------------------
INSERT INTO dbo.Teachers (TeacherID, FirstName, LastName, HireDate, Phone, Email)
VALUES
 (200, 'Adam', 'Nauczyciel', '2020-01-15', '123-456-789', 'adam.nauczyciel@example.com');

INSERT INTO dbo.Translators (TranslatorID, FirstName, LastName, HireDate, Phone, Email)
VALUES
 (300, 'Tomasz', 'Tlumacz', '2021-03-10', '444-999-333', 'tomasz.tlumacz@example.com');

SELECT * FROM dbo.Teachers
    WHERE TeacherID = 200;
SELECT * FROM dbo.Translators
    WHERE TranslatorID = 300;

-------------------------------------------------------------------------------
-- 5) Dodajemy przykładowe języki i przypisujemy do nauczyciela/tłumacza
-------------------------------------------------------------------------------
INSERT INTO dbo.Languages (LanguageID, LanguageName)
VALUES
 (16, 'Sith'),
 (17, 'Klingon');

INSERT INTO dbo.TeacherLanguages (TeacherID, LanguageID)
VALUES
 (200, 1),
 (200, 2);

INSERT INTO dbo.TranslatorsLanguages (TranslatorID, LanguageID)
VALUES
 (300, 2),
 (300, 3);

SELECT * FROM dbo.Languages
    WHERE LanguageID IN (16, 17);

SELECT * FROM dbo.TeacherLanguages
    WHERE TeacherID = 200
    ORDER BY LanguageID;

SELECT * FROM dbo.TranslatorsLanguages
    WHERE TranslatorID = 300
    ORDER BY LanguageID;

DELETE from dbo.Languages where LanguageID = 16;
DELETE from dbo.Languages where LanguageID = 17;

DELETE from dbo.TeacherLanguages where TeacherID = 200;
DELETE from dbo.TranslatorsLanguages where TranslatorID = 300;


-------------------------------------------------------------------------------
-- 6) Wstawiamy coś do tabeli Activities, aby zaprezentować np. tworzenie kursu
-------------------------------------------------------------------------------
-- Z reguły spAddCourse sama tworzy Activities,
-- ale możemy pokazać tez manualnie np. dla testu webinaru:
INSERT INTO dbo.Activities (ActivityID, Price, Title, Active)
VALUES
 (900, 99.00, 'TestActivity Manual', 1);

SELECT * FROM dbo.Activities
    WHERE ActivityID = 900;

DELETE from dbo.Activities where ActivityID = 900;

-------------------------------------------------------------------------------
-- 7) Prezentacja wywołania PROCEDUR
-------------------------------------------------------------------------------

-- 7.1 Dodawanie nowego kursu
EXEC dbo.spAddCourse
    @CourseName         = 'Kurs Programowania w C#',
    @CourseDescription  = 'Podstawy języka C# + praktyczne projekty',
    @CoursePrice        = 1200,
    @CourseCoordinatorID= 200,    -- TeacherID = 200
    @ActivityTitle      = 'Kurs C# Activity',
    @ActivityPrice      = 1200,
    @ActivityActive     = 1;
GO

SELECT * FROM dbo.Courses
    WHERE CourseName = 'Kurs Programowania w C#';

DELETE from dbo.Courses where CourseName = 'Kurs Programowania w C#';
-- Załóżmy, że procedura zwróci nam CreatedCourseID = np. 100

-- 7.2 Rejestracja studenta na kurs (CourseID=100, StudentID=1000)

--TUTAJ UPEWNIJ SIE ZE TAKI KURS ISTNIEJE
SELECT * FROM dbo.Courses
    WHERE CourseID = 100;

EXEC dbo.spRegisterStudentInCourse
     @CourseID  = 100,
     @StudentID = 1000;
GO

-- Możemy sprawdzić w tabeli CourseParticipants:
SELECT * FROM dbo.CourseParticipants;
GO

-- 7.3 Wypisanie studenta z kursu
-- (np. zakomentuj to, jeżeli chcesz dalej testować jego obecność)
-- EXEC dbo.spUnregisterStudentFromCourse
--     @CourseID  = 100,
--     @StudentID = 1000;
-- GO

-- 7.4 Aktualizacja ceny aktywności (np. bo zmieniamy ofertę)
EXEC dbo.spUpdateActivityPrice
     @ActivityID = 2137,
     @NewPrice   = 149.99;
GO

-- 7.5 Dodanie webinaru (spAddWebinar)
EXEC dbo.spAddWebinar
     @WebinarName        = 'Nowy Webinar',
     @WebinarDescription = 'Opis webinaru o bazach danych',
     @WebinarPrice       = 300,
     @TeacherID          = 200,
     @LanguageID         = 2,
     @VideoLink          = 'https://example.com/webinarLive',
     @WebinarDate        = '2025-01-15 18:00',
     @DurationTime       = '02:00',
     @ActivityTitle      = 'Webinar SQL Activity',
     @ActivityPrice      = 300,
     @ActivityActive     = 1;
GO

DELETE from dbo.Webinars where WebinarName = 'Nowy Webinar';

SELECT * FROM dbo.Webinars
    WHERE WebinarName = 'Nowy Webinar';
-------------------------------------------------------------------------------
-- 8) Przykład użycia widoku
-------------------------------------------------------------------------------
-- a) v_StudentCourses -> pokazuje, który student jest zapisany na które kursy
SELECT *
FROM dbo.v_StudentCourses;
GO

-- b) v_OrdersFull -> prezentuje dane o zamówieniach i sumę cen (na razie puste?)
SELECT *
FROM dbo.v_OrdersFull;
GO

-- c) v_ScheduleDetailed -> jeśli mamy jakieś wpisy w Schedule
SELECT *
FROM dbo.v_ScheduleDetailed;
GO

-------------------------------------------------------------------------------
-- 9) Przykład użycia funkcji
-------------------------------------------------------------------------------

-- 9.1 Obliczanie całkowitej kwoty zamówienia (ufnGetOrderTotal)
-- Załóżmy, że mamy OrderID=100 i w OrderDetails dołączone jakieś ActivityID
SELECT dbo.ufnGetOrderTotal(100) AS TotalOrderValue;
GO

-- 9.2 Sprawdzenie dostępności miejsca w module stacjonarnym
SELECT dbo.ufnGetStationaryModuleFreeSlots(10) AS FreeSlots;
GO

-- 9.3 Liczenie liczby kursów aktywnych w pewnym przedziale
SELECT dbo.ufnCountActiveCoursesInPeriod('2024-01-01','2025-01-01') AS ActiveCoursesIn2024;
GO

-------------------------------------------------------------------------------
-- spGetDebtors - lista dłużników (brak płatności)
EXEC dbo.spGetDebtors;
GO

-------------------------------------------------------------------------------
-- 11) Sprawdzamy, czy triggery działają
-------------------------------------------------------------------------------
-- a) Usunięcie kursu powinno wywołać TR_Courses_AfterDelete (o ile jest w DB).
--    Najpierw sprawdzimy co mamy:
INSERT INTO dbo.Courses (CourseID,ActivityID, CourseName, CourseDescription, CoursePrice, CourseCoordinatorID)
VALUES
 (100, 2137,'Kurs Testowy', 'Opis kursu testowego', 1000, 2);
SELECT * FROM dbo.Courses WHERE CourseID = 100;

--  O ile chcemy zademonstrować usunięcie:
DELETE FROM dbo.Courses WHERE CourseID = 100;

-------------------------------------------------------------------------------
-- KONIEC Skryptu Demonstracyjnego
-------------------------------------------------------------------------------
