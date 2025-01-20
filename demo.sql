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
  (1, 'Polska'),
  (2, 'Niemcy');

INSERT INTO dbo.Cities (CityID, CityName, CountryID)
VALUES
  (10, 'Kraków', 1),
  (20, 'Warszawa', 1),
  (30, 'Berlin', 2);

-------------------------------------------------------------------------------
-- 3) Wstawiamy przykładowego studenta
-------------------------------------------------------------------------------
INSERT INTO dbo.Students (StudentID, FirstName, LastName, [Address], CityID, PostalCode, Phone, Email)
VALUES
 (1000, 'Jan', 'Kowalski', 'ul. Długa 10', 10, '30-000', '500123456', 'jan.kowalski@example.com');

INSERT INTO dbo.Students (StudentID, FirstName, LastName, [Address], CityID, PostalCode, Phone, Email)
VALUES
 (1001, 'Maria', 'Nowak', 'ul. Krótka 3', 20, '00-123', '501234567', 'maria.nowak@example.com');

-------------------------------------------------------------------------------
-- 4) Wstawiamy przykładowego nauczyciela i tłumacza
-------------------------------------------------------------------------------
INSERT INTO dbo.Teachers (TeacherID, FirstName, LastName, HireDate, Phone, Email)
VALUES
 (200, 'Adam', 'Nauczyciel', '2020-01-15', '123-456-789', 'adam.nauczyciel@example.com');

INSERT INTO dbo.Translators (TranslatorID, FirstName, LastName, HireDate, Phone, Email)
VALUES
 (300, 'Tomasz', 'Tlumacz', '2021-03-10', '444-999-333', 'tomasz.tlumacz@example.com');

-------------------------------------------------------------------------------
-- 5) Dodajemy przykładowe języki i przypisujemy do nauczyciela/tłumacza
-------------------------------------------------------------------------------
INSERT INTO dbo.Languages (LanguageID, LanguageName)
VALUES
 (1, 'Polski'),
 (2, 'Angielski'),
 (3, 'Niemiecki');

-- Nauczyciel umie język polski i angielski
INSERT INTO dbo.TeacherLanguages (TeacherID, LanguageID)
VALUES
 (200, 1),
 (200, 2);

-- Tłumacz obsługuje angielski i niemiecki
INSERT INTO dbo.TranslatorsLanguages (TranslatorID, LanguageID)
VALUES
 (300, 2),
 (300, 3);

-------------------------------------------------------------------------------
-- 6) Wstawiamy coś do tabeli Activities, aby zaprezentować np. tworzenie kursu
-------------------------------------------------------------------------------
-- Z reguły spAddCourse sama tworzy Activities,
-- ale możemy pokazać tez manualnie np. dla testu webinaru:
INSERT INTO dbo.Activities (ActivityID, Price, Title, Active)
VALUES
 (900, 99.00, 'TestActivity Manual', 1);

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

-- Załóżmy, że procedura zwróci nam CreatedCourseID = np. 100

-- 7.2 Rejestracja studenta na kurs (CourseID=100, StudentID=1000)
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
     @ActivityID = 900,
     @NewPrice   = 149.99;
GO

-- 7.5 Dodanie webinaru (spAddWebinar)
EXEC dbo.spAddWebinar
     @WebinarName        = 'Nowy Webinar',
     @WebinarDescription = 'Opis webinaru o bazach danych',
     @WebinarPrice       = 300,
     @TeacherID          = 200,       -- Adam Nauczyciel
     @LanguageID         = 2,         -- angielski
     @VideoLink          = 'https://example.com/webinarLive',
     @WebinarDate        = '2025-01-15 18:00',
     @DurationTime       = '02:00',
     @ActivityTitle      = 'Webinar SQL Activity',
     @ActivityPrice      = 300,
     @ActivityActive     = 1;
GO

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
-- 10) Przykład generowania raportu
-------------------------------------------------------------------------------
-- spGenerateFinancialReport - zlicza przychody z Activities
EXEC dbo.spGenerateFinancialReport;
GO

-- spGetDebtors - lista dłużników (brak płatności)
EXEC dbo.spGetDebtors;
GO

-------------------------------------------------------------------------------
-- 11) Sprawdzamy, czy triggery działają
-------------------------------------------------------------------------------
-- a) Usunięcie kursu powinno wywołać TR_Courses_AfterDelete (o ile jest w DB).
--    Najpierw sprawdzimy co mamy:
SELECT * FROM dbo.Courses WHERE CourseID = 100;

--  O ile chcemy zademonstrować usunięcie:
-- DELETE FROM dbo.Courses WHERE CourseID = 100;

-------------------------------------------------------------------------------
-- KONIEC Skryptu Demonstracyjnego
-------------------------------------------------------------------------------
