import random
from faker import Faker
from datetime import datetime, timedelta

faker = Faker()
Faker.seed(2137)
faker.language = 'pl_PL'
# ============================================================================
#                USTAWIENIA ILOŚCI REKORDÓW DO WYGENEROWANIA
# ============================================================================
# 1) TYPY PRACOWNIKÓW, KRAJE, MIASTA, WALUTA
NUM_EMPLOYEETYPES      = 10      # Rozszerzone role w dużej szkole językowej
NUM_EURO_EXCHANGE      = 365     # Rok kursów walut
NUM_COUNTRIES          = 20      # Więcej krajów pochodzenia studentów
NUM_CITIES             = 100     # ~5 miast na kraj
NUM_LANGUAGES          = 15      # Więcej języków obcych

# 2) ACTIVITIES + STUDIES/SUBJECTS
NUM_ACTIVITIES         = 200     # Szeroka oferta edukacyjna
NUM_STUDIES           = 30      # Więcej programów nauczania
NUM_SUBJECTS          = 150     # ~5 przedmiotów na studia
NUM_SUBJECTGRADES     = 3000    # ~20 ocen na przedmiot

# 3) PRACOWNICY, STUDENCI, NAUCZYCIELE, TŁUMACZE
NUM_EMPLOYEES         = 100     # Rozbudowana administracja
NUM_STUDENTS         = 1500    # Duża szkoła językowa
NUM_TEACHERS         = 80      # Duża kadra nauczycielska
NUM_TRANSLATORS      = 25      # Więcej tłumaczy
NUM_TEACHER_LANGS    = 160     # ~2 języki na nauczyciela
NUM_TRANSLATOR_LANGS = 75      # ~3 języki na tłumacza

# 4) BUDYNKI, ZAJĘCIA, HARMONOGRAM
NUM_BUILDINGS         = 8       # Kilka lokalizacji
NUM_SCHEDULE         = 400     # 50 zajęć na budynek
NUM_STATIONARY_CLASS = 100     # Więcej zajęć stacjonarnych
NUM_STATIONARY_MODULE = 120    # Więcej modułów stacjonarnych
NUM_ONLINEASYNC_CLASS = 80     # Rozbudowana oferta online
NUM_ONLINESYNC_CLASS  = 80     # Rozbudowana oferta online
NUM_ONLINEASYNC_MODULE = 100   # Więcej modułów online
NUM_ONLINESYNC_MODULE = 100    # Więcej modułów online

# 5) KURSY (COURSES), MODUŁY, UCZESTNICY
NUM_COURSES          = 90      # Szeroki wybór kursów
NUM_COURSE_MODULES   = 270     # ~3 moduły na kurs
NUM_COURSE_PARTICIP  = 1800    # ~20 uczestników na kurs
NUM_COURSES_ATTEND   = 5400    # ~3 obecności na uczestnika

# 6) ZAMÓWIENIA, KOSZYK, PŁATNOŚCI
NUM_ORDERS           = 3000    # ~2 zamówienia na studenta
NUM_ORDER_DETAILS    = 4500    # ~1.5 pozycji na zamówienie
NUM_ORDERPAYMENTSTAT = 3000    # Status dla każdego zamówienia
NUM_SHOPPINGCART     = 300     # Aktywne koszyki

# 7) RODO, PRAKTYKI (INTERNSHIP), WEBINARY
NUM_RODO            = 1350    # 90% studentów z zgodami RODO
NUM_INTERNSHIP      = 40      # Więcej grup praktyk
NUM_INTERNSHIP_ATT  = 400     # ~10 uczestników na praktykę
NUM_WEBINARS        = 50      # ~4 webinary miesięcznie
NUM_WEBINAR_DETAILS = 1000    # ~20 uczestników na webinar

# 8) DODATKOWE
NUM_STUDIES_CLASS    = 200     # Więcej zajęć w ramach studiów
NUM_STUDIES_CLASS_ATT = 3000   # ~15 uczestników na zajęcia

# ============================================================================
#                FUNKCJE POMOCNICZE DO FORMATOWANIA
# ============================================================================
def quote_str(s: str) -> str:
    """Zamiana pojedynczych apostrofów na podwójne dla poprawnego INSERT-a."""
    if s is None:
        return ""
    return s.replace("'", "''")

def format_date(d) -> str:
    """Format daty jako 'YYYY-MM-DD'."""
    if not d:
        return "NULL"
    return f"'{d.strftime('%Y-%m-%d')}'"

def format_datetime(dt) -> str:
    """Format daty i czasu jako 'YYYY-MM-DD HH:MM:SS'."""
    if not dt:
        return "NULL"
    return f"'{dt.strftime('%Y-%m-%d %H:%M:%S')}'"

def format_money(val) -> str:
    """Proste formatowanie kwoty."""
    return f"{val:.2f}"

# ============================================================================
#  1) EMPLOYEETYPES
# ============================================================================
employee_types_data = []
et_names = ["Manager", "Sales", "Finance", "IT", "HR", "Support"]
for i in range(1, NUM_EMPLOYEETYPES+1):
    name = et_names[i-1] if i-1 < len(et_names) else f"Type_{i}"
    employee_types_data.append({
        'EmployeeTypeID': i,
        'EmployeeTypeName': name[:30]
    })

# ============================================================================
#  2) EUROEXCHANGERATE
# ============================================================================
# PK = [Date]
euro_rate_data = []
base_date = datetime.now() - timedelta(days=NUM_EURO_EXCHANGE)
for i in range(NUM_EURO_EXCHANGE):
    d = base_date + timedelta(days=i)
    euro_rate_data.append({
        'Date': d,
        'Rate': round(random.uniform(4.0, 5.0), 2)
    })

# ============================================================================
#  3) COUNTRIES
# ============================================================================
countries_data = []
for i in range(1, NUM_COUNTRIES+1):
    countries_data.append({
        'CountryID': i,
        'CountryName': faker.country()[:40]
    })

# ============================================================================
#  4) CITIES
# ============================================================================
cities_data = []
for i in range(1, NUM_CITIES+1):
    c = random.choice(countries_data)
    cities_data.append({
        'CityID': i,
        'CityName': faker.city()[:40],
        'CountryID': c['CountryID']   # FK -> Countries
    })

# ============================================================================
#  5) LANGUAGES
# ============================================================================
languages_data = []
for i in range(1, NUM_LANGUAGES + 1):
    languages_data.append({
        'LanguageID': i,
        'LanguageName': faker.language_name()[:40]
    })

# ============================================================================
#  6) EMPLOYEES
# ============================================================================
employees_data = []
for i in range(1, NUM_EMPLOYEES + 1):
    et = random.choice(employee_types_data)
    hd = faker.date_between(start_date='-5y', end_date='now')
    employees_data.append({
        'EmployeeID': i,
        'FirstName': faker.first_name()[:30],
        'LastName':  faker.last_name()[:30],
        'HireDate':  hd,
        'EmployeeTypeID': et['EmployeeTypeID'],
        'Phone': faker.phone_number()[:15],
        'Email': (f"emp_{i}_" + faker.email())[:60]
    })

# ============================================================================
#  7) TEACHERS
# ============================================================================
teachers_data = []
for i in range(1, NUM_TEACHERS + 1):
    hd = faker.date_between(start_date='-6y', end_date='-1y')
    teachers_data.append({
        'TeacherID': i,
        'FirstName': faker.first_name()[:30],
        'LastName': faker.last_name()[:30],
        'HireDate': hd,
        'Phone': faker.phone_number()[:15],
        'Email': (f"teacher_{i}_" + faker.email())[:60]
    })

# ============================================================================
#  8) TRANSLATORS
# ============================================================================
translators_data = []
for i in range(1, NUM_TRANSLATORS + 1):
    hd = faker.date_between(start_date='-4y', end_date='-1y')
    translators_data.append({
        'TranslatorID': i,
        'FirstName': faker.first_name()[:30],
        'LastName': faker.last_name()[:30],
        'HireDate': hd,
        'Phone': faker.phone_number()[:15],
        'Email': (f"translator_{i}_" + faker.email())[:60]
    })

# ============================================================================
#  9) TEACHERLANGUAGES  (TeacherID, LanguageID)
# ============================================================================
teacher_lang_data = []
all_tch_ids = [t['TeacherID'] for t in teachers_data]
all_lang_ids = [l['LanguageID'] for l in languages_data]

for _ in range(NUM_TEACHER_LANGS):
    tch = random.choice(all_tch_ids)
    lng = random.choice(all_lang_ids)
    # sprawdź duplikaty
    if not any(x for x in teacher_lang_data if x['TeacherID']==tch and x['LanguageID']==lng):
        teacher_lang_data.append({
            'TeacherID': tch,
            'LanguageID': lng
        })

# ============================================================================
# 10) TRANSLATORSLANGUAGES (TranslatorID, LanguageID)
# ============================================================================
translator_lang_data = []
all_tr_ids = [t['TranslatorID'] for t in translators_data]

for _ in range(NUM_TRANSLATOR_LANGS):
    trn = random.choice(all_tr_ids)
    lng = random.choice(all_lang_ids)
    if not any(x for x in translator_lang_data if x['TranslatorID']==trn and x['LanguageID']==lng):
        translator_lang_data.append({
            'TranslatorID': trn,
            'LanguageID': lng
        })

# ============================================================================
# 11) ACTIVITIES
# ============================================================================
activities_data = []
for i in range(1, NUM_ACTIVITIES+1):
    price_val = random.uniform(50, 500)
    activities_data.append({
        'ActivityID': i,
        'Price': price_val,
        'Title': f"Activity_{i}_{faker.word()[:15]}",
        'Active': random.choice([0,1])
    })

# ============================================================================
# 12) STUDIES
# ----------------------------------------------------------------------------
studies_data = []
for i in range(1, NUM_STUDIES+1):
    act = random.choice(activities_data)
    emp = random.choice(employees_data)
    studies_data.append({
        'StudiesID': i,
        'ActivityID': act['ActivityID'],
        'StudiesName': f"Studies_{i}",
        'StudiesDescription': faker.sentence(nb_words=5)[:200] if random.random()>0.3 else None,
        'StudiesEntryFeePrice': random.uniform(100, 800),
        'Syllabus': faker.sentence(nb_words=10)[:200],
        'StudiesEmployee': emp['EmployeeID'],
        'Limit': random.randint(10,40)
    })

# ============================================================================
# 13) SUBJECT (SubjectID, StudiesID, CoordinatorID, SubjectName, SubjectDescription)
# ============================================================================
subject_data = []
for i in range(1, NUM_SUBJECTS+1):
    st = random.choice(studies_data)
    tch = random.choice(teachers_data)
    subject_data.append({
        'SubjectID': i,
        'StudiesID': st['StudiesID'],
        'CoordinatorID': tch['TeacherID'],
        'SubjectName': f"Subject_{i}",
        'SubjectDescription': faker.sentence(nb_words=4)[:200] if random.random()>0.2 else None
    })

# ============================================================================
# 14) BUILDINGS
# ============================================================================
buildings_data = []
for i in range(1, NUM_BUILDINGS+1):
    buildings_data.append({
        'ClassID': i,
        'BuildingName': (faker.company()[:10] + f"_B{i}")[:30],
        'RoomNumber': f"R{random.randint(100,999)}"
    })

# ============================================================================
# 15) SCHEDULE
# ----------------------------------------------------------------------------
schedule_data = []
days_of_week = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
for i in range(1, NUM_SCHEDULE+1):
    bld = random.choice(buildings_data)
    tch = random.choice(teachers_data)
    trn = random.choice(translators_data + [None]*2)  # translator czasem null
    cm = random.choice([None]*3 + subject_data)       # czasem podpinamy subject
    # a czasem CourseModule
    # Reprezentuje: (ScheduleID, ClassID, CourseModuleID, StudiesSubjectID, DayOfWeek, StartTime, EndTime, TeacherID, TranslatorID)
    start_t = datetime(2023,1,1, random.randint(7,18), random.choice([0,30]))
    end_t   = start_t + timedelta(minutes=45*random.randint(2,4))
    dayname = random.choice(days_of_week)
    schedule_data.append({
        'ScheduleID': i,
        'ClassID': bld['ClassID'],
        'CourseModuleID': None,  # w uproszczeniu
        'StudiesSubjectID': cm['SubjectID'] if cm and 'SubjectID' in cm else None,
        'DayOfWeek': dayname[:10],
        'StartTime': start_t.strftime("%H:%M:%S"),
        'EndTime':   end_t.strftime("%H:%M:%S"),
        'TeacherID': tch['TeacherID'],
        'TranslatorID': trn['TranslatorID'] if trn else None
    })

# ============================================================================
# 16) STATIONARYCLASS
# ============================================================================
stationaryclass_data = []
for i in range(1, NUM_STATIONARY_CLASS+1):
    b = random.choice(buildings_data)
    stationaryclass_data.append({
        'StationaryClassID': i,
        'ClassID': b['ClassID'],
        'Limit': random.randint(5,30)
    })

# ============================================================================
# 17) ONLINEASYNCCLASS
# ============================================================================
onlineasyncclass_data = []
for i in range(1, NUM_ONLINEASYNC_CLASS+1):
    onlineasyncclass_data.append({
        'OnlineAsyncClassID': i,
        'Video': f"video_async_{i}.mp4"
    })

# ============================================================================
# 18) ONLINESYNCCLASS
# ============================================================================
onlinesyncclass_data = []
for i in range(1, NUM_ONLINESYNC_CLASS+1):
    onlinesyncclass_data.append({
        'OnlineSyncClassID': i,
        'Link': f"https://sync.example.com/room/{i}"
    })

# ============================================================================
# 19) STATIONARYMODULE
# ============================================================================
stationarymodule_data = []
for i in range(1, NUM_STATIONARY_MODULE+1):
    cm_id = i  # W uproszczeniu => StationaryModuleID = i => PK
    b = random.choice(buildings_data)
    stationarymodule_data.append({
        'StationaryModuleID': cm_id,
        'ClassID': b['ClassID'],
        'Limit': random.randint(5,30)
    })

# ============================================================================
# 20) ONLINEASYNCMODULE
# ============================================================================
onlineasyncmodule_data = []
for i in range(1, NUM_ONLINEASYNC_MODULE+1):
    onlineasyncmodule_data.append({
        'OnlineAsyncModuleID': i,
        'Video': f"video_mod_async_{i}.mp4"
    })

# ============================================================================
# 21) ONLINESYNCMODULE
# ============================================================================
onlinesyncmodule_data = []
for i in range(1, NUM_ONLINESYNC_MODULE+1):
    onlinesyncmodule_data.append({
        'OnlineSyncModuleID': i,
        'Link': f"https://sync-module.example.com/{i}"
    })

# ============================================================================
# 22) STUDENTS
# ============================================================================
students_data = []
for i in range(1, NUM_STUDENTS+1):
    city = random.choice(cities_data)
    students_data.append({
        'StudentID': i,
        'FirstName': faker.first_name()[:30],
        'LastName': faker.last_name()[:30],
        'Address': faker.street_address()[:30],
        'CityID': city['CityID'],
        'PostalCode': faker.postcode()[:10],
        'Phone': faker.phone_number()[:15],
        'Email': (f"stud_{i}_" + faker.email())[:60]
    })

# ============================================================================
# 23) RODO_Table
# ============================================================================
rodo_data = []
for i in range(1, NUM_RODO+1):
    st = random.choice(students_data)
    # PK = StudentID, ale w definicji jest PRIMARY KEY (StudentID) => 1:1?
    # Wygenerujemy unikatowe
    if not any(r['StudentID']==st['StudentID'] for r in rodo_data):
        rodo_data.append({
            'StudentID': st['StudentID'],
            'Date': faker.date_between(start_date='-2y', end_date='now'),
            'Withdraw': random.choice([0,1])
        })

# ============================================================================
# 24) WEBINARS
# ============================================================================
webinars_data = []
for i in range(1, NUM_WEBINARS+1):
    act = random.choice(activities_data)
    tch = random.choice(teachers_data)
    dtw = faker.date_time_between(start_date='-1y', end_date='+30d')
    dd  = random.randint(30,180)
    hours = dd // 60
    mins  = dd % 60
    dur_str = f"{hours:02d}:{mins:02d}:00"
    lang = random.choice(languages_data)
    webinars_data.append({
        'WebinarID': i,
        'ActivityID': act['ActivityID'],
        'TeacherID': tch['TeacherID'],
        'WebinarName': f"Web_{i}",
        'WebinarPrice': random.uniform(50,500),
        'VideoLink': f"https://video.example.com/web_{i}",
        'WebinarDate': dtw,
        'DurationTime': dur_str,
        'WebinarDescription': faker.text(max_nb_chars=100).replace('\n',' '),
        'LanguageID': lang['LanguageID']
    })

# ============================================================================
# 25) WEBINARDETAILS
# ============================================================================
webinardetails_data = []
all_web_studs = set()
for _ in range(NUM_WEBINAR_DETAILS):
    w = random.choice(webinars_data)
    st = random.choice(students_data)
    if (w['WebinarID'], st['StudentID']) not in all_web_studs:
        all_web_studs.add((w['WebinarID'], st['StudentID']))
        # PK (StudentID, WebinarID)
        webinardetails_data.append({
            'StudentID': st['StudentID'],
            'WebinarID': w['WebinarID'],
            'Complete': random.choice([0,1]),
            'AvailableDue': faker.date_between(start_date=w['WebinarDate'], end_date='+30d')
        })

# ============================================================================
# 26) COURSES
# ============================================================================
courses_data = []
for i in range(1, NUM_COURSES+1):
    act = random.choice(activities_data)
    tch = random.choice(teachers_data)
    courses_data.append({
        'CourseID': i,
        'ActivityID': act['ActivityID'],
        'CourseName': f"Course_{i}",
        'CourseDescription': faker.text(max_nb_chars=200).replace('\n',' ') if random.random()>0.3 else None,
        'CoursePrice': random.uniform(100,1000),
        'CourseCoordinatorID': tch['TeacherID']
    })

# ============================================================================
# 27) COURSEMODULES
# ============================================================================
course_modules_data = []
for i in range(1, NUM_COURSE_MODULES+1):
    c = random.choice(courses_data)
    tch = random.choice(teachers_data)
    trn = random.choice(translators_data + [None]*2)
    lang = random.choice(languages_data)
    dt_mod = faker.date_time_between(start_date='-90d', end_date='+90d')
    hh = random.randint(1,3)
    course_modules_data.append({
        'ModuleID': i,
        'CourseID': c['CourseID'],
        'ModuleName': f"Mod_{i}",
        'Date': dt_mod,
        'DurationTime': f"{hh:02d}:00:00",
        'TeacherID': tch['TeacherID'],
        'TranslatorID': trn['TranslatorID'] if trn else None,
        'LanguageID': lang['LanguageID']
    })

# ============================================================================
# 28) COURSEPARTICIPANTS (PK: CourseID, StudentID)
# ============================================================================
course_participants_data = []
all_cp = set()
for _ in range(NUM_COURSE_PARTICIP):
    c = random.choice(courses_data)
    st = random.choice(students_data)
    if (c['CourseID'], st['StudentID']) not in all_cp:
        all_cp.add((c['CourseID'], st['StudentID']))
        course_participants_data.append({
            'CourseID': c['CourseID'],
            'StudentID': st['StudentID']
        })

# ============================================================================
# 29) COURSESATTENDANCE (PK: ModuleID, StudentID)
# ============================================================================
courses_attendance_data = []
all_ca = set()
for _ in range(NUM_COURSES_ATTEND):
    cm = random.choice(course_modules_data)
    st = random.choice(students_data)
    if (cm['ModuleID'], st['StudentID']) not in all_ca:
        all_ca.add((cm['ModuleID'], st['StudentID']))
        courses_attendance_data.append({
            'ModuleID': cm['ModuleID'],
            'StudentID': st['StudentID'],
            'Attendance': random.choice([0,1])
        })

# ============================================================================
# 30) ORDERS
# ============================================================================
orders_data = []
for i in range(1, NUM_ORDERS+1):
    st = random.choice(students_data)
    dt_o = faker.date_time_between(start_date='-60d', end_date='now')
    # PaymentURL -> INT, do powiązania z OrderPaymentStatus
    pay_id = i + 100  # w uproszczeniu
    emp = random.choice(employees_data)
    orders_data.append({
        'OrderID': i,
        'StudentID': st['StudentID'],
        'OrderDate': dt_o,
        'PaymentURL': pay_id,
        'EmployeeHandling': emp['EmployeeID']
    })

# ============================================================================
# 31) ORDERPAYMENTSTATUS (PK: PaymentURL)
# ============================================================================
orderpaymentstatus_data = []
used_payurls = set(o['PaymentURL'] for o in orders_data)
possible_stats = ["New","Pending","Paid","Cancelled"]
for pay_id in used_payurls:
    paid_dt = None
    stat = random.choice(possible_stats)
    if stat=="Paid":
        # Sugerujemy paid_dt
        paid_dt = faker.date_time_between(start_date='-15d', end_date='now')
    orderpaymentstatus_data.append({
        'PaymentURL': pay_id,
        'OrderPaymentStatus': stat,
        'PaidDate': paid_dt
    })

# ============================================================================
# 32) ORDERDETAILS (PK: OrderID, ActivityID)
# ============================================================================
order_details_data = []
all_od = set()
for _ in range(NUM_ORDER_DETAILS):
    o = random.choice(orders_data)
    a = random.choice(activities_data)
    if (o['OrderID'], a['ActivityID']) not in all_od:
        all_od.add((o['OrderID'], a['ActivityID']))
        order_details_data.append({
            'OrderID': o['OrderID'],
            'ActivityID': a['ActivityID']
        })

# ============================================================================
# 33) SHOPPINGCART (PK: StudentID, ActivityID)
# ============================================================================
shoppingcart_data = []
all_sc = set()
for _ in range(NUM_SHOPPINGCART):
    st = random.choice(students_data)
    ac = random.choice(activities_data)
    if (st['StudentID'], ac['ActivityID']) not in all_sc:
        all_sc.add((st['StudentID'], ac['ActivityID']))
        shoppingcart_data.append({
            'StudentID': st['StudentID'],
            'ActivityID': ac['ActivityID']
        })

# ============================================================================
# 34) SUBJECTGRADES (PK: StudentID, SubjectID)
# ============================================================================
subject_grades_data = []
all_sg = set()
for _ in range(NUM_SUBJECTGRADES):
    sbj = random.choice(subject_data)
    st  = random.choice(students_data)
    if (st['StudentID'], sbj['SubjectID']) not in all_sg:
        all_sg.add((st['StudentID'], sbj['SubjectID']))
        grade_val = random.choice([2,3,3,3,4,4,4,5])
        subject_grades_data.append({
            'SubjectID': sbj['SubjectID'],
            'StudentID': st['StudentID'],
            'SubjectGrade': grade_val
        })

# ============================================================================
# 35) STUDIESCLASS
# ============================================================================
studiesclass_data = []
for i in range(1, NUM_STUDIES_CLASS+1):
    sbj = random.choice(subject_data)
    act = random.choice(activities_data)
    tch = random.choice(teachers_data)
    trn = random.choice(translators_data + [None]*3)
    lang = random.choice(languages_data + [None]*2)
    dt_s = faker.date_time_between(start_date='-30d', end_date='+30d')
    dur_h = random.randint(1,5)
    studiesclass_data.append({
        'StudyClassID': i,
        'SubjectID': sbj['SubjectID'],
        'ActivityID': act['ActivityID'],
        'TeacherID': tch['TeacherID'],
        'ClassName': f"SClass_{i}",
        'ClassPrice': random.uniform(80,400),
        'Date': dt_s,
        'DurationTime': f"{dur_h:02d}:00:00",
        'LanguageID': lang['LanguageID'] if lang else None,
        'TranslatorID': trn['TranslatorID'] if trn else None,
        'LimitClass': random.randint(10,25)
    })

# ============================================================================
# 36) STUDIESCLASSATTENDANCE (PK: StudentID, StudyClassID)
# ============================================================================
studiesclass_att_data = []
all_sca = set()
for _ in range(NUM_STUDIES_CLASS_ATT):
    sc = random.choice(studiesclass_data)
    st = random.choice(students_data)
    if (st['StudentID'], sc['StudyClassID']) not in all_sca:
        all_sca.add((st['StudentID'], sc['StudyClassID']))
        studiesclass_att_data.append({
            'StudyClassID': sc['StudyClassID'],
            'StudentID': st['StudentID'],
            'Attendance': random.choice([0,1])
        })

# ============================================================================
# 37) INTERNSHIP (PK: InternshipID)
# ============================================================================
internship_data = []
for i in range(1, NUM_INTERNSHIP+1):
    st = random.choice(studies_data)
    dt_i = faker.date_time_between(start_date='-60d', end_date='now')
    internship_data.append({
        'InternshipID': i,
        'StudiesID': st['StudiesID'],
        'StartDate': dt_i
    })

# ============================================================================
# 38) INTERNSHIPATTENDANCE (PK: InternshipID, StudentID)
# ============================================================================
internship_att_data = []
all_iatt = set()
for _ in range(NUM_INTERNSHIP_ATT):
    it = random.choice(internship_data)
    st = random.choice(students_data)
    if (it['InternshipID'], st['StudentID']) not in all_iatt:
        all_iatt.add((it['InternshipID'], st['StudentID']))
        internship_att_data.append({
            'InternshipID': it['InternshipID'],
            'StudentID': st['StudentID'],
            'Attendance': random.choice([0,1])
        })

# ============================================================================
#                   WYŚWIETLANIE INSERT-ÓW W ODPOWIEDNIEJ KOLEJNOŚCI
# ============================================================================
print("-- USE YourDatabaseNameHere;  -- jeśli potrzebujesz")
print("-- Wyłączanie constraints (opcjonalnie):")
print('EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";\n')

# 1) EmployeeTypes
print("\n-- 1) EmployeeTypes")
for et in employee_types_data:
    print(f"INSERT INTO EmployeeTypes (EmployeeTypeID, EmployeeTypeName) "
          f"VALUES ({et['EmployeeTypeID']}, '{quote_str(et['EmployeeTypeName'])}');")

# 2) EuroExchangeRate
print("\n-- 2) EuroExchangeRate")
for er in euro_rate_data:
    print(f"INSERT INTO EuroExchangeRate ([Date], Rate) "
          f"VALUES ({format_datetime(er['Date'])}, {er['Rate']});")

# 3) Countries
print("\n-- 3) Countries")
for c in countries_data:
    print(f"INSERT INTO Countries (CountryID, CountryName) "
          f"VALUES ({c['CountryID']}, '{quote_str(c['CountryName'])}');")

# 4) Cities
print("\n-- 4) Cities")
for ci in cities_data:
    print(f"INSERT INTO Cities (CityID, CityName, CountryID) "
          f"VALUES ({ci['CityID']}, '{quote_str(ci['CityName'])}', {ci['CountryID']});")

# 5) Languages
print("\n-- 5) Languages")
for l in languages_data:
    print(f"INSERT INTO Languages (LanguageID, LanguageName) "
          f"VALUES ({l['LanguageID']}, '{quote_str(l['LanguageName'])}');")

# 6) Employees
print("\n-- 6) Employees")
for emp in employees_data:
    hire_dt = format_date(emp['HireDate'])
    print(f"INSERT INTO Employees (EmployeeID, FirstName, LastName, HireDate, EmployeeTypeID, Phone, Email) "
          f"VALUES ({emp['EmployeeID']}, '{quote_str(emp['FirstName'])}', '{quote_str(emp['LastName'])}', "
          f"{hire_dt}, {emp['EmployeeTypeID']}, '{quote_str(emp['Phone'])}', '{quote_str(emp['Email'])}');")

# 7) Teachers
print("\n-- 7) Teachers")
for t in teachers_data:
    hd = format_date(t['HireDate'])
    print(f"INSERT INTO Teachers (TeacherID, FirstName, LastName, HireDate, Phone, Email) "
          f"VALUES ({t['TeacherID']}, '{quote_str(t['FirstName'])}', '{quote_str(t['LastName'])}', "
          f"{hd}, '{quote_str(t['Phone'])}', '{quote_str(t['Email'])}');")

# 8) Translators
print("\n-- 8) Translators")
for tr in translators_data:
    hd = format_date(tr['HireDate'])
    print(f"INSERT INTO Translators (TranslatorID, FirstName, LastName, HireDate, Phone, Email) "
          f"VALUES ({tr['TranslatorID']}, '{quote_str(tr['FirstName'])}', '{quote_str(tr['LastName'])}', "
          f"{hd}, '{quote_str(tr['Phone'])}', '{quote_str(tr['Email'])}');")

# 9) TeacherLanguages
print("\n-- 9) TeacherLanguages")
for tl in teacher_lang_data:
    print(f"INSERT INTO TeacherLanguages (TeacherID, LanguageID) "
          f"VALUES ({tl['TeacherID']}, {tl['LanguageID']});")

# 10) TranslatorsLanguages
print("\n-- 10) TranslatorsLanguages")
for tl in translator_lang_data:
    print(f"INSERT INTO TranslatorsLanguages (TranslatorID, LanguageID) "
          f"VALUES ({tl['TranslatorID']}, {tl['LanguageID']});")

# 11) Activities
print("\n-- 11) Activities")
for a in activities_data:
    print(f"INSERT INTO Activities (ActivityID, Price, Title, Active) "
          f"VALUES ({a['ActivityID']}, {format_money(a['Price'])}, "
          f"'{quote_str(a['Title'])}', {a['Active']});")

# 12) Studies
print("\n-- 12) Studies")
for s in studies_data:
    desc_str = quote_str(s['StudiesDescription']) if s['StudiesDescription'] else ""
    print(f"INSERT INTO Studies (StudiesID, ActivityID, StudiesName, StudiesDescription, "
          f"StudiesEntryFeePrice, Syllabus, StudiesEmployee, [Limit]) "
          f"VALUES ({s['StudiesID']}, {s['ActivityID']}, '{quote_str(s['StudiesName'])}', "
          f"'{desc_str}', {format_money(s['StudiesEntryFeePrice'])}, "
          f"'{quote_str(s['Syllabus'])}', {s['StudiesEmployee']}, {s['Limit']});")

# 13) Subject
print("\n-- 13) Subject")
for sb in subject_data:
    desc_str = quote_str(sb['SubjectDescription']) if sb['SubjectDescription'] else ""
    print(f"INSERT INTO Subject (SubjectID, StudiesID, CoordinatorID, SubjectName, SubjectDescription) "
          f"VALUES ({sb['SubjectID']}, {sb['StudiesID']}, {sb['CoordinatorID']}, "
          f"'{quote_str(sb['SubjectName'])}', '{desc_str}');")

# 14) Buildings
print("\n-- 14) Buildings")
for b in buildings_data:
    print(f"INSERT INTO Buildings (ClassID, BuildingName, RoomNumber) "
          f"VALUES ({b['ClassID']}, '{quote_str(b['BuildingName'])}', '{quote_str(b['RoomNumber'])}');")

# 15) Schedule
print("\n-- 15) Schedule")
for sc in schedule_data:
    cmid = sc['CourseModuleID'] if sc['CourseModuleID'] else 'NULL'
    sbid = sc['StudiesSubjectID'] if sc['StudiesSubjectID'] else 'NULL'
    tr   = sc['TranslatorID'] if sc['TranslatorID'] else 'NULL'
    print(f"INSERT INTO Schedule (ScheduleID, ClassID, CourseModuleID, StudiesSubjectID, "
          f"DayOfWeek, StartTime, EndTime, TeacherID, TranslatorID) "
          f"VALUES ({sc['ScheduleID']}, {sc['ClassID']}, {cmid}, {sbid}, "
          f"'{quote_str(sc['DayOfWeek'])}', '{sc['StartTime']}', '{sc['EndTime']}', "
          f"{sc['TeacherID']}, {tr});")

# 16) StationaryClass
print("\n-- 16) StationaryClass")
for sc in stationaryclass_data:
    print(f"INSERT INTO StationaryClass (StationaryClassID, ClassID, [Limit]) "
          f"VALUES ({sc['StationaryClassID']}, {sc['ClassID']}, {sc['Limit']});")

# 17) OnlineAsyncClass
print("\n-- 17) OnlineAsyncClass")
for oac in onlineasyncclass_data:
    print(f"INSERT INTO OnlineAsyncClass (OnlineAsyncClassID, Video) "
          f"VALUES ({oac['OnlineAsyncClassID']}, '{quote_str(oac['Video'])}');")

# 18) OnlineSyncClass
print("\n-- 18) OnlineSyncClass")
for osc in onlinesyncclass_data:
    print(f"INSERT INTO OnlineSyncClass (OnlineSyncClassID, Link) "
          f"VALUES ({osc['OnlineSyncClassID']}, '{quote_str(osc['Link'])}');")

# 19) StationaryModule
print("\n-- 19) StationaryModule")
for sm in stationarymodule_data:
    print(f"INSERT INTO StationaryModule (StationaryModuleID, ClassID, [Limit]) "
          f"VALUES ({sm['StationaryModuleID']}, {sm['ClassID']}, {sm['Limit']});")

# 20) OnlineAsyncModule
print("\n-- 20) OnlineAsyncModule")
for oam in onlineasyncmodule_data:
    print(f"INSERT INTO OnlineAsyncModule (OnlineAsyncModuleID, Video) "
          f"VALUES ({oam['OnlineAsyncModuleID']}, '{quote_str(oam['Video'])}');")

# 21) OnlineSyncModule
print("\n-- 21) OnlineSyncModule")
for osm in onlinesyncmodule_data:
    print(f"INSERT INTO OnlineSyncModule (OnlineSyncModuleID, Link) "
          f"VALUES ({osm['OnlineSyncModuleID']}, '{quote_str(osm['Link'])}');")

# 22) Students
print("\n-- 22) Students")
for st in students_data:
    print(f"INSERT INTO Students (StudentID, FirstName, LastName, [Address], CityID, PostalCode, Phone, Email) "
          f"VALUES ({st['StudentID']}, '{quote_str(st['FirstName'])}', '{quote_str(st['LastName'])}', "
          f"'{quote_str(st['Address'])}', {st['CityID']}, '{quote_str(st['PostalCode'])}', "
          f"'{quote_str(st['Phone'])}', '{quote_str(st['Email'])}');")

# 23) RODO_Table
print("\n-- 23) RODO_Table")
for rd in rodo_data:
    dt = format_date(rd['Date'])
    print(f"INSERT INTO RODO_Table (StudentID, [Date], Withdraw) "
          f"VALUES ({rd['StudentID']}, {dt}, {rd['Withdraw']});")

# 24) Webinars
print("\n-- 24) Webinars")
for w in webinars_data:
    dtw = format_datetime(w['WebinarDate'])
    desc = quote_str(w['WebinarDescription'])
    print(f"INSERT INTO Webinars (WebinarID, ActivityID, TeacherID, WebinarName, WebinarPrice, "
          f"VideoLink, WebinarDate, DurationTime, WebinarDescription, LanguageID) "
          f"VALUES ({w['WebinarID']}, {w['ActivityID']}, {w['TeacherID']}, '{quote_str(w['WebinarName'])}', "
          f"{format_money(w['WebinarPrice'])}, '{quote_str(w['VideoLink'])}', {dtw}, "
          f"'{w['DurationTime']}', '{desc}', {w['LanguageID']});")

# 25) WebinarDetails
print("\n-- 25) WebinarDetails")
for wd in webinardetails_data:
    ad = format_date(wd['AvailableDue'])
    print(f"INSERT INTO WebinarDetails (StudentID, WebinarID, Complete, AvailableDue) "
          f"VALUES ({wd['StudentID']}, {wd['WebinarID']}, {wd['Complete']}, {ad});")

# 26) Courses
print("\n-- 26) Courses")
for c in courses_data:
    desc = quote_str(c['CourseDescription']) if c['CourseDescription'] else ""
    print(f"INSERT INTO Courses (CourseID, ActivityID, CourseName, CourseDescription, CoursePrice, "
          f"CourseCoordinatorID) "
          f"VALUES ({c['CourseID']}, {c['ActivityID']}, '{quote_str(c['CourseName'])}', "
          f"'{desc}', {format_money(c['CoursePrice'])}, {c['CourseCoordinatorID']});")

# 27) CourseModules
print("\n-- 27) CourseModules")
for cm in course_modules_data:
    dtm = format_datetime(cm['Date'])
    tr = cm['TranslatorID'] if cm['TranslatorID'] else 'NULL'
    print(f"INSERT INTO CourseModules (ModuleID, CourseID, ModuleName, Date, DurationTime, "
          f"TeacherID, TranslatorID, LanguageID) "
          f"VALUES ({cm['ModuleID']}, {cm['CourseID']}, '{quote_str(cm['ModuleName'])}', "
          f"{dtm}, '{cm['DurationTime']}', {cm['TeacherID']}, {tr}, {cm['LanguageID']});")

# 28) CourseParticipants
print("\n-- 28) CourseParticipants")
for cp in course_participants_data:
    print(f"INSERT INTO CourseParticipants (CourseID, StudentID) "
          f"VALUES ({cp['CourseID']}, {cp['StudentID']});")

# 29) CoursesAttendance
print("\n-- 29) CoursesAttendance")
for ca in courses_attendance_data:
    print(f"INSERT INTO CoursesAttendance (ModuleID, StudentID, Attendance) "
          f"VALUES ({ca['ModuleID']}, {ca['StudentID']}, {ca['Attendance']});")

# 30) Orders
print("\n-- 30) Orders")
for o in orders_data:
    dt_o = format_datetime(o['OrderDate'])
    print(f"INSERT INTO Orders (OrderID, StudentID, OrderDate, PaymentURL, EmployeeHandling) "
          f"VALUES ({o['OrderID']}, {o['StudentID']}, {dt_o}, {o['PaymentURL']}, {o['EmployeeHandling']});")

# 31) OrderPaymentStatus
print("\n-- 31) OrderPaymentStatus")
for ops in orderpaymentstatus_data:
    pd = format_datetime(ops['PaidDate'])
    print(f"INSERT INTO OrderPaymentStatus (PaymentURL, OrderPaymentStatus, PaidDate) "
          f"VALUES ({ops['PaymentURL']}, '{quote_str(ops['OrderPaymentStatus'])}', {pd});")

# 32) OrderDetails
print("\n-- 32) OrderDetails")
for od in order_details_data:
    print(f"INSERT INTO OrderDetails (OrderID, ActivityID) "
          f"VALUES ({od['OrderID']}, {od['ActivityID']});")

# 33) ShoppingCart
print("\n-- 33) ShoppingCart")
for sc in shoppingcart_data:
    print(f"INSERT INTO ShoppingCart (StudentID, ActivityID) "
          f"VALUES ({sc['StudentID']}, {sc['ActivityID']});")

# 34) SubjectGrades
print("\n-- 34) SubjectGrades")
for sg in subject_grades_data:
    print(f"INSERT INTO SubjectGrades (SubjectID, StudentID, SubjectGrade) "
          f"VALUES ({sg['SubjectID']}, {sg['StudentID']}, {sg['SubjectGrade']});")

# 35) StudiesClass
print("\n-- 35) StudiesClass")
for sc in studiesclass_data:
    tr_id = sc['TranslatorID'] if sc['TranslatorID'] else 'NULL'
    lg_id = sc['LanguageID'] if sc['LanguageID'] else 'NULL'
    dt_s = format_datetime(sc['Date'])
    print(f"INSERT INTO StudiesClass (StudyClassID, SubjectID, ActivityID, TeacherID, ClassName, "
          f"ClassPrice, [Date], DurationTime, LanguageID, TranslatorID, LimitClass) "
          f"VALUES ({sc['StudyClassID']}, {sc['SubjectID']}, {sc['ActivityID']}, {sc['TeacherID']}, "
          f"'{quote_str(sc['ClassName'])}', {format_money(sc['ClassPrice'])}, {dt_s}, "
          f"'{sc['DurationTime']}', {lg_id}, {tr_id}, {sc['LimitClass']});")

# 36) StudiesClassAttendance
print("\n-- 36) StudiesClassAttendance")
for sa in studiesclass_att_data:
    print(f"INSERT INTO StudiesClassAttendance (StudentID, StudyClassID, Attendance) "
          f"VALUES ({sa['StudentID']}, {sa['StudyClassID']}, {sa['Attendance']});")

# 37) Internship
print("\n-- 37) Internship")
for it in internship_data:
    sdt = format_datetime(it['StartDate'])
    print(f"INSERT INTO Internship (InternshipID, StudiesID, StartDate) "
          f"VALUES ({it['InternshipID']}, {it['StudiesID']}, {sdt});")

# 38) InternshipAttendance
print("\n-- 38) InternshipAttendance")
for ia in internship_att_data:
    print(f"INSERT INTO InternshipAttendance (InternshipID, StudentID, Attendance) "
          f"VALUES ({ia['InternshipID']}, {ia['StudentID']}, {ia['Attendance']});")

print("\n-- (Opcjonalnie) Przywrócenie sprawdzania constraints:")
print('EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL";')
print("\n-- Gotowe! :)\n")

# Aby wygenerować plik SQL, uruchom:
# python dataGenerator.py > insert_data.sql