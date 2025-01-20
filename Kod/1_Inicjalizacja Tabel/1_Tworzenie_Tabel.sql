--------------------------------------------------------------------------------
--  (Opcjonalnie) Ustawienia sesji dla MS SQL Server – ułatwiają poprawne działanie
--  w trybie zgodnym ze standardami ANSI.
--------------------------------------------------------------------------------
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET QUOTED_IDENTIFIER ON;

--------------------------------------------------------------------------------
--  1) Tworzenie wszystkich tabel z PRIMARY KEY, ale bez FOREIGN KEY.
--------------------------------------------------------------------------------

------------------------------------
-- Table: Activities
------------------------------------
CREATE TABLE Activities (
    ActivityID     INT           NOT NULL,
    Price          MONEY         NOT NULL,
    Title          VARCHAR(50)   NOT NULL,
    Active         BIT           NOT NULL,
    CONSTRAINT PK_Activities PRIMARY KEY (ActivityID)
);

------------------------------------
-- Table: Buildings
------------------------------------
CREATE TABLE Buildings (
    ClassID        INT           NOT NULL,
    BuildingName   VARCHAR(30)   NOT NULL,
    RoomNumber     VARCHAR(30)   NOT NULL,
    CONSTRAINT PK_Buildings PRIMARY KEY (ClassID)
);

------------------------------------
-- Table: Cities
------------------------------------
CREATE TABLE Cities (
    CityID    INT          NOT NULL,
    CityName  VARCHAR(40)  NOT NULL,
    CountryID INT          NOT NULL,  -- FK do Countries (dodamy potem)
    CONSTRAINT PK_Cities PRIMARY KEY (CityID)
);

------------------------------------
-- Table: Countries
------------------------------------
CREATE TABLE Countries (
    CountryID    INT           NOT NULL,
    CountryName  VARCHAR(40)   NOT NULL,
    CONSTRAINT PK_Countries PRIMARY KEY (CountryID)
);

------------------------------------
-- Table: CourseModules
------------------------------------
CREATE TABLE CourseModules (
    ModuleID       INT          NOT NULL,
    CourseID       INT          NOT NULL,  -- FK do Courses
    ModuleName     VARCHAR(50)  NOT NULL,
    Date           DATETIME     NOT NULL,
    DurationTime   TIME(0)      NOT NULL,
    TeacherID      INT          NOT NULL,  -- FK do Teachers
    TranslatorID   INT          NULL,      -- FK do Translators
    LanguageID     INT          NOT NULL,  -- FK do Languages
    CONSTRAINT PK_CourseModules PRIMARY KEY (ModuleID)
);

------------------------------------
-- Table: CourseParticipants
------------------------------------
CREATE TABLE CourseParticipants (
    CourseID  INT NOT NULL,  -- FK do Courses
    StudentID INT NOT NULL,  -- FK do Students
    CONSTRAINT PK_CourseParticipants PRIMARY KEY (CourseID, StudentID)
);

------------------------------------
-- Table: Courses
------------------------------------
CREATE TABLE Courses (
    CourseID             INT           NOT NULL,
    ActivityID           INT           NOT NULL,  -- FK do Activities
    CourseName           VARCHAR(50)   NOT NULL,
    CourseDescription    TEXT          NULL,
    CoursePrice          MONEY         NOT NULL,
    CourseCoordinatorID  INT           NOT NULL,  -- FK do Teachers
    CONSTRAINT PK_Courses PRIMARY KEY (CourseID)
);

------------------------------------
-- Table: CoursesAttendance
------------------------------------
CREATE TABLE CoursesAttendance (
    ModuleID   INT NOT NULL,  -- FK do CourseModules
    StudentID  INT NOT NULL,  -- FK do Students
    Attendance BIT NOT NULL,
    CONSTRAINT PK_CoursesAttendance PRIMARY KEY (ModuleID, StudentID)
);

------------------------------------
-- Table: EmployeeTypes
------------------------------------
CREATE TABLE EmployeeTypes (
    EmployeeTypeID   INT          NOT NULL,
    EmployeeTypeName VARCHAR(30)  NOT NULL,
    CONSTRAINT PK_EmployeeTypes PRIMARY KEY (EmployeeTypeID)
);

------------------------------------
-- Table: Employees
------------------------------------
CREATE TABLE Employees (
    EmployeeID      INT          NOT NULL,
    FirstName       VARCHAR(30)  NOT NULL,
    LastName        VARCHAR(30)  NOT NULL,
    HireDate        DATE         NULL,
    EmployeeTypeID  INT          NOT NULL,   -- FK do EmployeeTypes
    Phone           VARCHAR(15)  NULL,
    Email           VARCHAR(60)  NOT NULL,
    CONSTRAINT PK_Employees PRIMARY KEY (EmployeeID)
);

------------------------------------
-- Table: EuroExchangeRate
------------------------------------
CREATE TABLE EuroExchangeRate (
    [Date] DATETIME      NOT NULL,
    Rate   DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_EuroExchangeRate PRIMARY KEY ([Date])
);

------------------------------------
-- Table: Internship
------------------------------------
CREATE TABLE Internship (
    InternshipID INT        NOT NULL,
    StudiesID    INT        NOT NULL,  -- FK do Studies
    StartDate    DATETIME   NOT NULL,
    CONSTRAINT PK_Internship PRIMARY KEY (InternshipID)
);

------------------------------------
-- Table: InternshipAttendance
------------------------------------
CREATE TABLE InternshipAttendance (
    InternshipID INT NOT NULL,  -- FK do Internship
    StudentID    INT NOT NULL,  -- FK do Students
    Attendance   BIT NOT NULL,
    CONSTRAINT PK_InternshipAttendance PRIMARY KEY (InternshipID, StudentID)
);

------------------------------------
-- Table: Languages
------------------------------------
CREATE TABLE Languages (
    LanguageID    INT           NOT NULL,
    LanguageName  VARCHAR(40)   NOT NULL,
    CONSTRAINT PK_Languages PRIMARY KEY (LanguageID)
);

------------------------------------
-- Table: OnlineAsyncClass
------------------------------------
CREATE TABLE OnlineAsyncClass (
    OnlineAsyncClassID INT          NOT NULL,
    Video              VARCHAR(50)  NOT NULL,
    -- FK do StudiesClass (StudyClassID) dodamy potem
    CONSTRAINT PK_OnlineAsyncClass PRIMARY KEY (OnlineAsyncClassID)
);

------------------------------------
-- Table: OnlineAsyncModule
------------------------------------
CREATE TABLE OnlineAsyncModule (
    OnlineAsyncModuleID INT          NOT NULL,
    Video               VARCHAR(60)  NOT NULL,
    -- FK do CourseModules (ModuleID) w drugiej części
    CONSTRAINT PK_OnlineAsyncModule PRIMARY KEY (OnlineAsyncModuleID)
);

------------------------------------
-- Table: OnlineSyncClass
------------------------------------
CREATE TABLE OnlineSyncClass (
    OnlineSyncClassID INT          NOT NULL,
    Link              VARCHAR(50)  NOT NULL,
    -- FK do StudiesClass (StudyClassID) w drugiej części
    CONSTRAINT PK_OnlineSyncClass PRIMARY KEY (OnlineSyncClassID)
);

------------------------------------
-- Table: OnlineSyncModule
------------------------------------
CREATE TABLE OnlineSyncModule (
    OnlineSyncModuleID INT          NOT NULL,
    Link               VARCHAR(60)  NOT NULL,
    -- FK do CourseModules (ModuleID) w drugiej części
    CONSTRAINT PK_OnlineSyncModule PRIMARY KEY (OnlineSyncModuleID)
);

------------------------------------
-- Table: OrderDetails
------------------------------------
CREATE TABLE OrderDetails (
    OrderID    INT NOT NULL,  -- FK do Orders
    ActivityID INT NOT NULL,  -- FK do Activities
    CONSTRAINT PK_OrderDetails PRIMARY KEY (OrderID, ActivityID)
);

------------------------------------
-- Table: OrderPaymentStatus
------------------------------------
CREATE TABLE OrderPaymentStatus (
    PaymentURL          INT           NOT NULL,
    OrderPaymentStatus  VARCHAR(20)   NOT NULL,
    PaidDate            DATETIME      NULL,
    CONSTRAINT PK_OrderPaymentStatus PRIMARY KEY (PaymentURL)
);

------------------------------------
-- Table: Orders
------------------------------------
CREATE TABLE Orders (
    OrderID          INT       NOT NULL,
    StudentID        INT       NOT NULL,  -- FK do Students
    OrderDate        DATETIME  NOT NULL,  -- FK do EuroExchangeRate (Date)
    PaymentURL       INT       NOT NULL,  -- FK do OrderPaymentStatus
    EmployeeHandling INT       NOT NULL,  -- FK do Employees
    CONSTRAINT PK_Orders PRIMARY KEY (OrderID)
);

------------------------------------
-- Table: RODO_Table
------------------------------------
CREATE TABLE RODO_Table (
    StudentID INT   NOT NULL,  -- FK do Students
    [Date]    DATE  NOT NULL,
    Withdraw  BIT   NOT NULL,
    CONSTRAINT PK_RODO_Table PRIMARY KEY (StudentID)
);

------------------------------------
-- Table: Schedule
------------------------------------
CREATE TABLE Schedule (
    ScheduleID        INT         NOT NULL,
    ClassID           INT         NOT NULL,  -- FK do Buildings
    CourseModuleID    INT         NULL,      -- FK do CourseModules
    StudiesSubjectID  INT         NULL,      -- FK do Subject
    DayOfWeek         VARCHAR(10) NOT NULL,
    StartTime         TIME        NOT NULL,
    EndTime           TIME        NOT NULL,
    TeacherID         INT         NOT NULL,  -- FK do Teachers
    TranslatorID      INT         NULL,      -- FK do Translators
    CONSTRAINT PK_Schedule PRIMARY KEY (ScheduleID)
);

------------------------------------
-- Table: ShoppingCart
------------------------------------
CREATE TABLE ShoppingCart (
    StudentID   INT NOT NULL,  -- FK do Students
    ActivityID  INT NOT NULL,  -- FK do Activities
    CONSTRAINT PK_ShoppingCart PRIMARY KEY (StudentID, ActivityID)
);

------------------------------------
-- Table: StationaryClass
------------------------------------
CREATE TABLE StationaryClass (
    StationaryClassID INT NOT NULL,
    ClassID           INT NOT NULL,  -- FK do Buildings
    [Limit]           INT NOT NULL,
    CONSTRAINT PK_StationaryClass PRIMARY KEY (StationaryClassID)
);

------------------------------------
-- Table: StationaryModule
------------------------------------
CREATE TABLE StationaryModule (
    StationaryModuleID INT NOT NULL,  -- FK do CourseModules (ModuleID)
    ClassID            INT NOT NULL,  -- FK do Buildings
    [Limit]            INT NOT NULL,
    CONSTRAINT PK_StationaryModule PRIMARY KEY (StationaryModuleID)
);

------------------------------------
-- Table: Students
------------------------------------
CREATE TABLE Students (
    StudentID   INT         NOT NULL,
    FirstName   VARCHAR(30) NOT NULL,
    LastName    VARCHAR(30) NOT NULL,
    [Address]   VARCHAR(30) NOT NULL,
    CityID      INT         NOT NULL,  -- FK do Cities
    PostalCode  VARCHAR(10) NOT NULL,
    Phone       VARCHAR(15) NULL,
    Email       VARCHAR(60) NOT NULL,
    CONSTRAINT PK_Students PRIMARY KEY (StudentID)
);

------------------------------------
-- Table: Studies
------------------------------------
CREATE TABLE Studies (
    StudiesID             INT         NOT NULL,
    ActivityID            INT         NOT NULL,   -- FK do Activities
    StudiesName           VARCHAR(50) NOT NULL,
    StudiesDescription    TEXT        NULL,
    StudiesEntryFeePrice  MONEY       NOT NULL,
    Syllabus              TEXT        NOT NULL,
    StudiesEmployee       INT         NOT NULL,   -- FK do Employees
    [Limit]               INT         NOT NULL,
    CONSTRAINT PK_Studies PRIMARY KEY (StudiesID)
);

------------------------------------
-- Table: StudiesClass
------------------------------------
CREATE TABLE StudiesClass (
    StudyClassID  INT          NOT NULL,
    SubjectID     INT          NOT NULL,  -- FK do Subject
    ActivityID    INT          NOT NULL,  -- FK do Activities
    TeacherID     INT          NOT NULL,  -- FK do Teachers
    ClassName     VARCHAR(50)  NOT NULL,
    ClassPrice    MONEY        NOT NULL,
    [Date]        DATETIME     NOT NULL,
    DurationTime  TIME(0)      NULL,
    LanguageID    INT          NULL,      -- FK do Languages
    TranslatorID  INT          NULL,      -- FK do Translators
    LimitClass    INT          NOT NULL,
    CONSTRAINT PK_StudiesClass PRIMARY KEY (StudyClassID)
);

------------------------------------
-- Table: StudiesClassAttendance
------------------------------------
CREATE TABLE StudiesClassAttendance (
    StudyClassID INT NOT NULL,  -- FK do StudiesClass
    StudentID    INT NOT NULL,  -- FK do Students
    Attendance   BIT NOT NULL,
    CONSTRAINT PK_StudiesClassAttendance PRIMARY KEY (StudentID, StudyClassID)
);

------------------------------------
-- Table: Subject
------------------------------------
CREATE TABLE Subject (
    SubjectID          INT          NOT NULL,
    StudiesID          INT          NOT NULL,  -- FK do Studies
    CoordinatorID      INT          NOT NULL,  -- FK do Teachers
    SubjectName        VARCHAR(50)  NOT NULL,
    SubjectDescription TEXT         NULL,
    CONSTRAINT PK_Subject PRIMARY KEY (SubjectID)
);

------------------------------------
-- Table: SubjectGrades
------------------------------------
CREATE TABLE SubjectGrades (
    SubjectID    INT NOT NULL,  -- FK do Subject
    StudentID    INT NOT NULL,  -- FK do Students
    SubjectGrade INT NOT NULL,
    CONSTRAINT PK_SubjectGrades PRIMARY KEY (StudentID, SubjectID)
);

------------------------------------
-- Table: TeacherLanguages
------------------------------------
CREATE TABLE TeacherLanguages (
    TeacherID  INT NOT NULL,  -- FK do Teachers
    LanguageID INT NOT NULL,  -- FK do Languages
    CONSTRAINT PK_TeacherLanguages PRIMARY KEY (TeacherID, LanguageID)
);

------------------------------------
-- Table: Teachers
------------------------------------
CREATE TABLE Teachers (
    TeacherID   INT          NOT NULL,
    FirstName   VARCHAR(30)  NOT NULL,
    LastName    VARCHAR(30)  NOT NULL,
    HireDate    DATE         NULL,
    Phone       VARCHAR(15)  NULL,
    Email       VARCHAR(60)  NOT NULL,
    CONSTRAINT PK_Teachers PRIMARY KEY (TeacherID)
);

------------------------------------
-- Table: Translators
------------------------------------
CREATE TABLE Translators (
    TranslatorID INT          NOT NULL,
    FirstName    VARCHAR(30)  NOT NULL,
    LastName     VARCHAR(30)  NOT NULL,
    HireDate     DATE         NULL,
    Phone        VARCHAR(15)  NULL,
    Email        VARCHAR(60)  NOT NULL,
    CONSTRAINT PK_Translators PRIMARY KEY (TranslatorID)
);

------------------------------------
-- Table: TranslatorsLanguages
------------------------------------
CREATE TABLE TranslatorsLanguages (
    TranslatorID INT NOT NULL,  -- FK do Translators
    LanguageID   INT NOT NULL,  -- FK do Languages
    CONSTRAINT PK_TranslatorsLanguages PRIMARY KEY (TranslatorID, LanguageID)
);

------------------------------------
-- Table: WebinarDetails
------------------------------------
CREATE TABLE WebinarDetails (
    StudentID    INT      NOT NULL,  -- FK do Students
    WebinarID    INT      NOT NULL,  -- FK do Webinars
    Complete     BIT      NOT NULL,
    AvailableDue DATE     NOT NULL,
    CONSTRAINT PK_WebinarDetails PRIMARY KEY (StudentID, WebinarID)
);

------------------------------------
-- Table: Webinars
------------------------------------
CREATE TABLE Webinars (
    WebinarID           INT          NOT NULL,
    ActivityID          INT          NOT NULL,  -- FK do Activities
    TeacherID           INT          NOT NULL,  -- FK do Teachers
    WebinarName         VARCHAR(50)  NOT NULL,
    WebinarPrice        MONEY        NOT NULL,
    VideoLink           VARCHAR(50)  NOT NULL,
    WebinarDate         DATETIME     NOT NULL,
    DurationTime        TIME(0)      NOT NULL,
    WebinarDescription  TEXT         NOT NULL,
    LanguageID          INT          NOT NULL,  -- FK do Languages
    CONSTRAINT PK_Webinars PRIMARY KEY (WebinarID)
);
