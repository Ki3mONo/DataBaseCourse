
--------------------------------------------------------------------------------
-- Indeksy dla studentów
--------------------------------------------------------------------------------

-- 1. Indeks na e-mail studenta
CREATE NONCLUSTERED INDEX IX_Students_Email
    ON dbo.Students(Email);
GO

-- 2. Indeks na nazwisko studenta
CREATE NONCLUSTERED INDEX IX_Students_LastName
    ON dbo.Students(LastName);
GO

-- 3. Indeks na numer telefonu studenta
CREATE NONCLUSTERED INDEX IX_Students_Phone
    ON dbo.Students(Phone);
GO

-- 4. Indeks na kod pocztowy
CREATE NONCLUSTERED INDEX IX_Students_PostalCode
    ON dbo.Students(PostalCode);
GO

--------------------------------------------------------------------------------
-- Indeksy dla kursów
--------------------------------------------------------------------------------

-- 5. Indeks na nazwę kursu
CREATE NONCLUSTERED INDEX IX_Courses_CourseName
    ON dbo.Courses(CourseName);
GO

-- 6. Indeks na cenę kursu
CREATE NONCLUSTERED INDEX IX_Courses_CoursePrice
    ON dbo.Courses(CoursePrice);
GO

-- 7. Indeks na koordynatora kursu
CREATE NONCLUSTERED INDEX IX_Courses_Coordinator
    ON dbo.Courses(CourseCoordinatorID);
GO

--------------------------------------------------------------------------------
-- Indeksy dla zamówień
--------------------------------------------------------------------------------

-- 8. Indeks na datę zamówienia
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate
    ON dbo.Orders(OrderDate);
GO

-- 9. Indeks na status płatności
--  W tabeli Orders nie ma bezpośrednio kolumny "status płatności".
--  Mamy powiązanie z OrderPaymentStatus(OrderPaymentStatus).
--  Jeżeli często szukasz w Orders wg statusu,
--  możesz dodać indeks w OrderPaymentStatus(OrderPaymentStatus).
CREATE NONCLUSTERED INDEX IX_OrderPaymentStatus_Status
    ON dbo.OrderPaymentStatus(OrderPaymentStatus);
GO

-- 10. Indeks na pracownika obsługującego zamówienie (Orders.EmployeeHandling)
CREATE NONCLUSTERED INDEX IX_Orders_EmployeeHandling
    ON dbo.Orders(EmployeeHandling);
GO

--------------------------------------------------------------------------------
-- Indeksy dla nauczycieli (Teachers) i tłumaczy (Translators)
--------------------------------------------------------------------------------

-- 11. Indeks na język tłumacza (TranslatorsLanguages.LanguageID)
CREATE NONCLUSTERED INDEX IX_TranslatorsLanguages_LanguageID
    ON dbo.TranslatorsLanguages(LanguageID);
GO

-- 12. Indeks na język wykładowy nauczyciela (TeacherLanguages.LanguageID)
CREATE NONCLUSTERED INDEX IX_TeacherLanguages_LanguageID
    ON dbo.TeacherLanguages(LanguageID);
GO

--------------------------------------------------------------------------------
-- Indeksy dla webinarów i harmonogramu
--------------------------------------------------------------------------------

-- 13. Indeks na datę webinaru (Webinars.WebinarDate)
CREATE NONCLUSTERED INDEX IX_Webinars_WebinarDate
    ON dbo.Webinars(WebinarDate);
GO
