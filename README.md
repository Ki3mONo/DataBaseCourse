# Podstawy Baz Danych - Projekt

## Opis projektu

Celem projektu jest zaprojektowanie oraz implementacja systemu bazodanowego dla firmy oferującej różnego rodzaju kursy i szkolenia. System został zaprojektowany, aby wspierać hybrydowy model świadczenia usług edukacyjnych, obejmujący zajęcia stacjonarne, kursy online (synchroniczne i asynchroniczne) oraz webinary. Projekt uwzględnia specyficzne wymagania dotyczące rejestracji uczestników, integracji z systemem płatności, generowania raportów.
Implementacja została przeprowadzona w środowisku MS SQL Server, a system oparty jest o zaawansowane mechanizmy, takie jak:
- Rozbudowana struktura tabel z precyzyjnie zdefiniowanymi relacjami (klucze główne, klucze obce),
- Procedury przechowywane, funkcje użytkownika, widoki oraz triggery zapewniające integralność i automatyzację operacji na danych,
- Indeksy optymalizujące wydajność zapytań.

---

## Funkcjonalności systemu

Projekt oferuje następujące funkcjonalności:
- **Rejestracja i zarządzanie kursami oraz webinarami:** Umożliwia tworzenie, edycję i usuwanie kursów, zarządzanie modułami kursów, przypisywanie studentów do kursów i monitorowanie frekwencji.
- **Obsługa danych studenckich:** Przechowywanie oraz aktualizacja danych osobowych studentów, zarządzanie ich zgłoszeniami, zamówieniami i płatnościami.
- **Zarządzanie personelem dydaktycznym:** System ról oraz uprawnień umożliwia precyzyjne rozdzielenie kompetencji między administratorami, nauczycielami, tłumaczami oraz pracownikami administracyjnymi.
- **Raportowanie i analizy:** Wbudowane widoki, funkcje oraz procedury umożliwiają generowanie raportów dotyczących zamówień, frekwencji, ocen czy płatności.
- **Integracja z systemem płatności i konwersja walut:** Dzięki mechanizmom przeliczania cen oraz tabeli kursu wymiany, system obsługuje płatności w różnych walutach.

---

## Struktura projektu

Projekt został podzielony na logiczne moduły, których kod źródłowy znajduje się w katalogu **Kod**.

Każdy z modułów odpowiada za określony aspekt systemu – od inicjalizacji struktury bazy, przez definiowanie ról i uprawnień, implementację funkcji i procedur, aż po indeksowanie, tworzenie triggerów, widoków oraz generowanie danych testowych.

---

## Technologie

W projekcie wykorzystano następujące technologie:
- **MS SQL Server** – jako system zarządzania bazą danych, umożliwiający wykorzystanie zaawansowanych mechanizmów administracyjnych, procedur, funkcji, widoków, triggerów oraz indeksowania.
- **Python** – język skryptowy użyty do automatycznego generowania danych testowych przy pomocy biblioteki [Faker](https://github.com/joke2k/faker).
- **SQL** – standardowy język do definiowania, modyfikacji i operowania na strukturze bazy danych.

---

## Autorzy

- **Maciej Kmąk**
- **Jakub Stachecki**
- **Kacper Wdowiak**

Projekt został zrealizowany w ramach przedmiotu **Podstawy Baz Danych** na kierunku **Informatyka** na **Akademii Górniczo-Hutniczej w Krakowie**.
