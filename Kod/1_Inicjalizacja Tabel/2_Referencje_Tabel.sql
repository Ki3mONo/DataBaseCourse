
--------------------------------------------------------------------------------
--  2) Dodawanie wszystkich FOREIGN KEY przez ALTER TABLE ... ADD CONSTRAINT ...
--------------------------------------------------------------------------------

--------------------------------------------
-- 1) Activities -> używane m.in. w Courses
--------------------------------------------
ALTER TABLE Courses
    ADD CONSTRAINT Activities_Courses
    FOREIGN KEY (ActivityID)
    REFERENCES Activities (ActivityID);

ALTER TABLE OrderDetails
    ADD CONSTRAINT Activities_OrderDetails
    FOREIGN KEY (ActivityID)
    REFERENCES Activities (ActivityID);

ALTER TABLE ShoppingCart
    ADD CONSTRAINT Activities_ShoppingCart
    FOREIGN KEY (ActivityID)
    REFERENCES Activities (ActivityID);

ALTER TABLE StudiesClass
    ADD CONSTRAINT Activities_StudiesClass
    FOREIGN KEY (ActivityID)
    REFERENCES Activities (ActivityID);

ALTER TABLE Webinars
    ADD CONSTRAINT Activities_Webinars
    FOREIGN KEY (ActivityID)
    REFERENCES Activities (ActivityID);

ALTER TABLE Studies
    ADD CONSTRAINT Studies_Activities
    FOREIGN KEY (ActivityID)
    REFERENCES Activities (ActivityID);

--------------------------------------------
-- 2) Buildings -> np. StationaryClass, ...
--------------------------------------------
ALTER TABLE StationaryClass
    ADD CONSTRAINT StationaryClass_Buildings
    FOREIGN KEY (ClassID)
    REFERENCES Buildings (ClassID);

ALTER TABLE StationaryModule
    ADD CONSTRAINT Buildings_StationaryModule
    FOREIGN KEY (ClassID)
    REFERENCES Buildings (ClassID);

ALTER TABLE Schedule
    ADD CONSTRAINT Schedule_Buildings
    FOREIGN KEY (ClassID)
    REFERENCES Buildings (ClassID);

--------------------------------------------
-- 3) Cities -> używane przez Students
--------------------------------------------
ALTER TABLE Cities
    ADD CONSTRAINT Cities_Countries
    FOREIGN KEY (CountryID)
    REFERENCES Countries (CountryID);

ALTER TABLE Students
    ADD CONSTRAINT Students_Cities
    FOREIGN KEY (CityID)
    REFERENCES Cities (CityID);

--------------------------------------------
-- 4) Courses <-> CourseModules, CourseParticipants
--------------------------------------------
ALTER TABLE CourseModules
    ADD CONSTRAINT CourseModules_Courses
    FOREIGN KEY (CourseID)
    REFERENCES Courses (CourseID);

ALTER TABLE CourseParticipants
    ADD CONSTRAINT Courses_CourseParticipants
    FOREIGN KEY (CourseID)
    REFERENCES Courses (CourseID);

--------------------------------------------
-- 5) CourseModules <-> CoursesAttendance
--------------------------------------------
ALTER TABLE CoursesAttendance
    ADD CONSTRAINT CourseModules_CoursesAttendance
    FOREIGN KEY (ModuleID)
    REFERENCES CourseModules (ModuleID);

--------------------------------------------
-- 6) Languages -> używane w CourseModules, ...
--------------------------------------------
ALTER TABLE CourseModules
    ADD CONSTRAINT CourseModules_Languages
    FOREIGN KEY (LanguageID)
    REFERENCES Languages (LanguageID);

ALTER TABLE StudiesClass
    ADD CONSTRAINT StudiesClass_Languages
    FOREIGN KEY (LanguageID)
    REFERENCES Languages (LanguageID);

ALTER TABLE Webinars
    ADD CONSTRAINT Webinars_Languages
    FOREIGN KEY (LanguageID)
    REFERENCES Languages (LanguageID);

ALTER TABLE TeacherLanguages
    ADD CONSTRAINT TeacherLanguages_Languages
    FOREIGN KEY (LanguageID)
    REFERENCES Languages (LanguageID);

-- Zmienione (unikalna nazwa):
ALTER TABLE TranslatorsLanguages
    ADD CONSTRAINT TranslatorsLanguages_Languages
    FOREIGN KEY (LanguageID)
    REFERENCES Languages (LanguageID);

--------------------------------------------
-- 7) CourseModules -> OnlineAsyncModule, OnlineSyncModule, ...
--------------------------------------------
ALTER TABLE OnlineAsyncModule
    ADD CONSTRAINT CourseModules_OnlineAsyncModule
    FOREIGN KEY (OnlineAsyncModuleID)
    REFERENCES CourseModules (ModuleID);

ALTER TABLE OnlineSyncModule
    ADD CONSTRAINT CourseModules_OnlineSyncModule
    FOREIGN KEY (OnlineSyncModuleID)
    REFERENCES CourseModules (ModuleID);

ALTER TABLE Schedule
    ADD CONSTRAINT CourseModules_Schedule
    FOREIGN KEY (CourseModuleID)
    REFERENCES CourseModules (ModuleID);

ALTER TABLE StationaryModule
    ADD CONSTRAINT StationaryModule_CourseModules
    FOREIGN KEY (StationaryModuleID)
    REFERENCES CourseModules (ModuleID);

--------------------------------------------
-- 8) Teachers -> używany w CourseModules, ...
--------------------------------------------
ALTER TABLE CourseModules
    ADD CONSTRAINT CourseModules_Teachers
    FOREIGN KEY (TeacherID)
    REFERENCES Teachers (TeacherID);

ALTER TABLE StudiesClass
    ADD CONSTRAINT StudiesClass_Teachers
    FOREIGN KEY (TeacherID)
    REFERENCES Teachers (TeacherID);

ALTER TABLE Webinars
    ADD CONSTRAINT Webinars_Teachers
    FOREIGN KEY (TeacherID)
    REFERENCES Teachers (TeacherID);

ALTER TABLE Subject
    ADD CONSTRAINT Subject_Teachers
    FOREIGN KEY (CoordinatorID)
    REFERENCES Teachers (TeacherID);

ALTER TABLE TeacherLanguages
    ADD CONSTRAINT TeachersLanguages_Teachers
    FOREIGN KEY (TeacherID)
    REFERENCES Teachers (TeacherID);

ALTER TABLE Courses
    ADD CONSTRAINT Teachers_Courses
    FOREIGN KEY (CourseCoordinatorID)
    REFERENCES Teachers (TeacherID);

ALTER TABLE Schedule
    ADD CONSTRAINT Schedule_Teachers
    FOREIGN KEY (TeacherID)
    REFERENCES Teachers (TeacherID);

--------------------------------------------
-- 9) Translators -> używani w CourseModules, ...
--------------------------------------------
ALTER TABLE CourseModules
    ADD CONSTRAINT CourseModules_Translators
    FOREIGN KEY (TranslatorID)
    REFERENCES Translators (TranslatorID);

ALTER TABLE StudiesClass
    ADD CONSTRAINT StudiesClass_Translators
    FOREIGN KEY (TranslatorID)
    REFERENCES Translators (TranslatorID);

ALTER TABLE TranslatorsLanguages
    ADD CONSTRAINT TranslatorsLanguages_Translators
    FOREIGN KEY (TranslatorID)
    REFERENCES Translators (TranslatorID);

ALTER TABLE Schedule
    ADD CONSTRAINT Schedule_Translators
    FOREIGN KEY (TranslatorID)
    REFERENCES Translators (TranslatorID);

--------------------------------------------
-- 10) Students -> używani w CourseParticipants, ...
--------------------------------------------
ALTER TABLE CourseParticipants
    ADD CONSTRAINT CourseParticipants_Students
    FOREIGN KEY (StudentID)
    REFERENCES Students (StudentID);

ALTER TABLE CoursesAttendance
    ADD CONSTRAINT Students_CoursesAttendance
    FOREIGN KEY (StudentID)
    REFERENCES Students (StudentID);

ALTER TABLE Orders
    ADD CONSTRAINT Orders_Students
    FOREIGN KEY (StudentID)
    REFERENCES Students (StudentID);

ALTER TABLE RODO_Table
    ADD CONSTRAINT RODO_Table_Students
    FOREIGN KEY (StudentID)
    REFERENCES Students (StudentID);

ALTER TABLE ShoppingCart
    ADD CONSTRAINT ShoppingCart_Students
    FOREIGN KEY (StudentID)
    REFERENCES Students (StudentID);

ALTER TABLE StudiesClassAttendance
    ADD CONSTRAINT StudiesClassAttendance_Students
    FOREIGN KEY (StudentID)
    REFERENCES Students (StudentID);

ALTER TABLE SubjectGrades
    ADD CONSTRAINT SubjectGrades_Students
    FOREIGN KEY (StudentID)
    REFERENCES Students (StudentID);

ALTER TABLE WebinarDetails
    ADD CONSTRAINT WebinarDetails_Students
    FOREIGN KEY (StudentID)
    REFERENCES Students (StudentID);

ALTER TABLE InternshipAttendance
    ADD CONSTRAINT InternshipAttendance_Students
    FOREIGN KEY (StudentID)
    REFERENCES Students (StudentID);

--------------------------------------------
-- 11) Studies -> używany w Subject, Internship, ...
--------------------------------------------
ALTER TABLE Subject
    ADD CONSTRAINT Subject_Studies
    FOREIGN KEY (StudiesID)
    REFERENCES Studies (StudiesID);

ALTER TABLE Internship
    ADD CONSTRAINT Internship_Studies
    FOREIGN KEY (StudiesID)
    REFERENCES Studies (StudiesID);

--------------------------------------------
-- 12) StudiesClass -> różne relacje
--------------------------------------------
ALTER TABLE StudiesClass
    ADD CONSTRAINT StudiesMeeting_Subject
    FOREIGN KEY (SubjectID)
    REFERENCES Subject (SubjectID);

ALTER TABLE StudiesClassAttendance
    ADD CONSTRAINT StudyMeetingAttendance_StudyMeeting
    FOREIGN KEY (StudyClassID)
    REFERENCES StudiesClass (StudyClassID);

ALTER TABLE StationaryClass
    ADD CONSTRAINT SubjectGradesReference
    FOREIGN KEY (StationaryClassID)
    REFERENCES StudiesClass (StudyClassID);

ALTER TABLE OnlineAsyncClass
    ADD CONSTRAINT OnlineAsyncModule_StudiesMeeting
    FOREIGN KEY (OnlineAsyncClassID)
    REFERENCES StudiesClass (StudyClassID);

ALTER TABLE OnlineSyncClass
    ADD CONSTRAINT OnlineSyncModule_StudiesMeeting
    FOREIGN KEY (OnlineSyncClassID)
    REFERENCES StudiesClass (StudyClassID);

--------------------------------------------
-- 13) StationaryClass -> Buildings
--------------------------------------------
-- Już dodane: StationaryClass_Buildings (w sekcji #2 Buildings)

--------------------------------------------
-- 14) Employees -> używani w Orders, Studies
--------------------------------------------
ALTER TABLE Orders
    ADD CONSTRAINT Orders_Employees
    FOREIGN KEY (EmployeeHandling)
    REFERENCES Employees (EmployeeID);

ALTER TABLE Studies
    ADD CONSTRAINT Studies_Employees
    FOREIGN KEY (StudiesEmployee)
    REFERENCES Employees (EmployeeID);

--------------------------------------------
-- 15) EmployeeTypes -> używany w Employees
--------------------------------------------
ALTER TABLE Employees
    ADD CONSTRAINT Employees_EmployeeTypes
    FOREIGN KEY (EmployeeTypeID)
    REFERENCES EmployeeTypes (EmployeeTypeID);

--------------------------------------------
-- 16) EuroExchangeRate -> używany w Orders
--------------------------------------------
ALTER TABLE Orders
    ADD CONSTRAINT EuroExchangeRate_Orders
    FOREIGN KEY (OrderDate)
    REFERENCES EuroExchangeRate ([Date]);

--------------------------------------------
-- 17) Internship -> używany w InternshipAttendance
--------------------------------------------
ALTER TABLE InternshipAttendance
    ADD CONSTRAINT InternshipAttendance_Internship
    FOREIGN KEY (InternshipID)
    REFERENCES Internship (InternshipID);

--------------------------------------------
-- 18) OrderPaymentStatus -> używany w Orders
--------------------------------------------
ALTER TABLE Orders
    ADD CONSTRAINT OrderPaymentStatus_Orders
    FOREIGN KEY (PaymentURL)
    REFERENCES OrderPaymentStatus (PaymentURL);

--------------------------------------------
-- 19) Orders -> używany w OrderDetails
--------------------------------------------
ALTER TABLE OrderDetails
    ADD CONSTRAINT OrderDetails_Orders
    FOREIGN KEY (OrderID)
    REFERENCES Orders (OrderID);

--------------------------------------------
-- 20) Webinars -> WebinarDetails
--------------------------------------------
ALTER TABLE WebinarDetails
    ADD CONSTRAINT WebinarDetails_Webinars
    FOREIGN KEY (WebinarID)
    REFERENCES Webinars (WebinarID);
