CREATE TABLE Egzaminy (ID INTEGER Primary key,
Przedmiot VARCHAR(15) NOT NULL,
Poziom Bit not null,
Rok INTEGER not null,
Termin Bit not null default 0,
Punkty INTEGER not null,
[Ilosc zadan] INTEGER not null);

CREATE TABLE Osoby (PESEL INTEGER PRIMARY KEY,
Pierwsze_Imie VARCHAR(15) NOT NULL ,
Drugie_Imie VARCHAR(15),
Nazwisko VARCHAR(40) NOT NULL ,
Data_Urodzenia DATETIME NOT NULL ,
Ulica Varchar(30) NOT NULL ,
[Nr domu] VARCHAR(4),
[Nr mieszkania] VARCHAR(4),
Miasto Varchar(15) NOT NULL ,
[Kod pocztowy] INTEGER NOT NULL ,
Telefon INTEGER,
Haslo VARCHAR(40)  NOT NULL);

CREATE TABLE Szkoly (ID INTEGER PRIMARY KEY   AUTOINCREMENT  NOT NULL  UNIQUE, --IDENTITY(1,1),
[Nr Szkoly] INTEGER,
Nazwa VARCHAR(60) NOT NULL ,
Miasto VARCHAR(15) NOT NULL ,
Ulica VARCHAR(40) NOT NULL ,
[Kod pocztowy] INTEGER NOT NULL ,
Telefon INTEGER,
Dyrektor VARCHAR(50) NOT NULL ,
[Rok zalozenia] INTEGER);

CREATE TABLE Nauczyciele (ID INTEGER PRIMARY KEY   AUTOINCREMENT  NOT NULL  UNIQUE,--IDENTITY(1,1),
 PESEL INTEGER NOT NULL  CONSTRAINT FK_OSB REFERENCES Osoby(PESEL) ON DELETE CASCADE ,
Szkola INTEGER  CONSTRAINT FK_SZK REFERENCES Szkoly(ID) ON UPDATE CASCADE,
Staz INTEGER NOT NULL  DEFAULT 0,
Uprawnienia BIT NOT NULL  DEFAULT 0);

CREATE TABLE Uczniowie (ID INTEGER PRIMARY KEY   AUTOINCREMENT  NOT NULL  UNIQUE, --IDENTITY(1,1) ,
PESEL INTEGER NOT NULL CONSTRAINT FK_OSOBY REFERENCES Osoby(PESEL) ON DELETE CASCADE ,
Szkola INTEGER NOT NULL CONSTRAINT FK_SZKOLA REFERENCES Szkoly(ID),
Wychowawca INTEGER NOT NULL CONSTRAINT FK_NAUCZY REFERENCES Nauczyciele(ID) ON UPDATE CASCADE ,
[Rok rozpoczecia] DATE NOT NULL ,
[Rok zakonczenia] DATE);

CREATE TABLE Rezultaty ([Nr egzaminu] INTEGER PRIMARY KEY,
Egzamin INTEGER NOT NULL CONSTRAINT FK_EGZAM REFERENCES EGZAMINY(ID)  ON UPDATE CASCADE,
Zdajacy INTEGER NOT NULL  CONSTRAINT FK_ZDAJ REFERENCES UCZNIOWIE(ID) ON DELETE CASCADE,
Wynik INTEGER,
[Wynik proc] FLOAT,
Zdany BIT NOT NULL  DEFAULT 0);

CREATE TABLE Punkty ([Nr egzaminu] INTEGER NOT NULL CONSTRAINT FK_REZULT REFERENCES REZULTATY([Nr egzaminu])  ON DELETE CASCADE,
[Nr zadania] INTEGER NOT NULL ,
Punkty FLOAT NOT NULL  DEFAULT 0,
[Opis oceny] TEXT,
Ocenuajacy INTEGER NOT NULL CONSTRAINT  FK_OCEN REFERENCES NAUCZYCIELE(ID),
PRIMARY KEY ([Nr egzaminu], [Nr zadania]));

CREATE TABLE [Rozklad Punktow] (Egzamin INTEGER NOT NULL CONSTRAINT FK_EGZ REFERENCES EGZAMINY(ID) ON UPDATE CASCADE ,
[Nr zadania] INTEGER NOT NULL ,
[Max pkt] INTEGER NOT NULL ,
Przyznawanie TEXT NOT NULL ,
PRIMARY KEY (Egzamin, [Nr zadania]));


CREATE VIEW statEgzamin AS
SELECT E.Rok, E.Przedmiot, E.Poziom, (E.Termin)+1 As Termin,  COUNT(R.Zdajacy) AS [Ilosc zdajacych],
AVG(R.Wynik) AS [Sredni wynik], AVG(R.[Wynik proc]) AS [Sredni wynik %], SUM(R.Zdany)*100.0/COUNT(R.Zdajacy) AS [Zdawalnosc]
FROM Egzaminy E JOIN Rezultaty R ON E.ID= R.Egzamin GROUP BY E.ID ORDER BY E.Rok, E.Przedmiot

CREATE VIEW statUczen AS
SELECT O.PESEL, O.Pierwsze_imie, O.Nazwisko, COUNT(R.[Nr egzaminu]) AS [Ilosc egzaminow], COUNT(R.Zdany) AS [Zdane], AVG(R.[Wynik proc]) AS [Sredni wynik %]
FROM Osoby O, Uczniowie U JOIN Rezultaty R ON U.ID=R.Zdajacy where O.PESEL=U.PESEL GROUP BY U.ID

CREATE VIEW statPrzedmiot AS
SELECT E.Przedmiot, AVG(R.[Wynik proc]) AS [Sredni wynik %], COUNT(R.Zdajacy) AS [Ilosc egzaminow],
(Select COUNT(Zdany)from Rezultaty where Zdany=1) AS [Ilosc zaliczonych], (SElect COUNT(Zdany)from Rezultaty where Zdany=1)*100.0/COUNT(R.Zdajacy) AS [Zdawalnosc]
FROM Egzaminy E JOIN Rezultaty R ON E.ID= R.Egzamin GROUP BY E.Przedmiot

CREATE VIEW statNauczyciel AS
SELECT O.Pierwsze_Imie, O.nazwisko, COUNT(R.Zdany)/COUNT(R.[Nr egzaminu])*100.0 AS [Skutecznosc]
FROM Osoby O, Nauczyciele N, Uczniowie U  JOIN Rezultaty R ON R.Zdajacy=U.ID
WHERE N.PESEL=O.PESEL AND U.Wychowawca=N.ID GROUP BY N.PESEL

CREATE 	VIEW statSzkola AS
SELECT S.Nazwa, S.[Nr Szkoly], S.Miasto, COUNT(R.Zdany)/COUNT(R.[Nr egzaminu])*100.0 AS [Zdawalnosc]
FROM Szkoly S, Uczniowie U  JOIN Rezultaty R ON R.Zdajacy=U.ID where S.ID=U.Szkola GROUP BY S.ID

CREATE VIEW statMiasto AS
SELECT Miasto, Zdawalnosc FROM statSzkola GROUP BY Miasto


CREATE TRIGGER usuwanieRezultat ON Rezultaty
AFTER DELETE
AS
	DELETE FROM Punkty WHERE  [Nr egzaminu] IN (SELECT [Nr egzaminu] FROM deleted)
	PRINT('Pomyslnie Usunieto Rezultat')
go

CREATE TRIGGER dodawaniePunktow ON Punkty
AFTER INSERT, UPDATE
AS
	UPDATE Punkty
	SET [Opis oceny]='Brak bledow.'
	WHERE [Opis oceny] IS NULL AND Punkty>0
	UPDATE Punkty
	SET [Opis oceny]='Brak rozwiazania.'
	WHERE [Opis oceny] IS NULL AND Punkty=0

CREATE TRIGGER usuwanieNauczyciela ON Nauczyciele
AFTER DELETE
AS
	UPDATE Uczniowie
	SET Wychowawca = 0
	WHERE Wychowawca IN (SELECT ID FROM deleted)
	UPDATE Punkty
	SET Ocenuajacy = 0
	WHERE Ocenuajacy IN (SELECT ID FROM deleted)
	PRINT('Pomyslnie usunieto nauczyciela.')

CREATE TRIGGER usuwanieUcznia ON Uczniowie
AFTER DELETE
AS
	DELETE FROM Rezultaty WHERE Zdajacy in (SELECT ID FROM deleted)
	PRINT('Pomyslnie sunieto ucznia i jego rezultaty.')

CREATE TRIGGER usuwanieEgzamin ON Egzaminy
After DELETE
AS
	DELETE FROM Rezultaty WHERE Egzamin IN (SELECT ID FROM deleted)
	DELETE FROM [Rozklad Punktow] WHERE Egzamin IN (SELECT ID FROM deleted)
	PRINT('Pomyslnie usunieto egzamin.')


INSERT INTO  Egzaminy Values(102, "Matematyka", 0, 2010, 0, 40, 25);
INSERT INTO  Egzaminy Values(202, "Matematyka", 0, 2011, 0, 40, 25);
INSERT INTO  Egzaminy Values(302, "Matematyka", 0, 2012, 0, 40, 25);
INSERT INTO  Egzaminy Values(402, "Matematyka", 0, 2013, 0, 40, 25);
INSERT INTO  Egzaminy Values(502, "Matematyka", 0, 2014, 0, 40, 25);
INSERT INTO  Egzaminy Values(602, "Matematyka", 0, 2015, 0, 40, 25);
INSERT INTO  Egzaminy Values(103, "Polski", 0, 2010, 0, 50, 15);
INSERT INTO  Egzaminy Values(203, "Polski", 0, 2011, 0, 50, 15);
INSERT INTO  Egzaminy Values(303, "Polski", 0, 2012, 0, 50, 15);
INSERT INTO  Egzaminy Values(403, "Polski", 0, 2013, 0, 50, 15);
INSERT INTO  Egzaminy Values(503, "Polski", 0, 2014, 0, 50, 15);
INSERT INTO  Egzaminy Values(603, "Polski", 0, 2015, 0, 50, 15);
INSERT INTO  Egzaminy Values(104, "Angielski", 0, 2010, 1, 40, 17);
INSERT INTO  Egzaminy Values(204, "Angielski", 0, 2011, 1, 40, 17);
INSERT INTO  Egzaminy Values(304, "Angielski", 0, 2012, 1, 40, 17);
INSERT INTO  Egzaminy Values(404, "Angielski", 0, 2013, 1, 40, 17);
INSERT INTO  Egzaminy Values(504, "Angielski", 0, 2014, 1, 40, 17);
INSERT INTO  Egzaminy Values(604, "Angielski", 0, 2015, 1, 40, 17);
INSERT INTO [Rozklad Punktow] Values(104, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(104, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(104, 3, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(104, 4, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(104, 5, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(104, 6, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(104, 7, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(104, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(104, 9, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(104, 10, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(204, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(204, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(204, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(204, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(204, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(204, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(204, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(204, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(204, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(204, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(304, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(304, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(304, 3, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(304, 4, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(304, 5, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(304, 6, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(304, 7, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(304, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(304, 9, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(304, 10, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(404, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(404, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(404, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(404, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(404, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(404, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(404, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(404, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(404, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(404, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(504, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(504, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(504, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(504, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(504, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(504, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(504, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(504, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(504, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(504, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(604, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(604, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(604, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(604, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(604, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(604, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(604, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(604, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(604, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(604, 10, 1, "Odpowiedz A");

INSERT INTO  Egzaminy Values(112, "Matematyka", 0, 2010, 1, 40, 25);
INSERT INTO  Egzaminy Values(212, "Matematyka", 0, 2011, 1, 40, 25);
INSERT INTO  Egzaminy Values(312, "Matematyka", 0, 2012, 1, 40, 25);
INSERT INTO  Egzaminy Values(412, "Matematyka", 0, 2013, 1, 40, 25);
INSERT INTO  Egzaminy Values(512, "Matematyka", 0, 2014, 1, 40, 25);
INSERT INTO  Egzaminy Values(612, "Matematyka", 0, 2015, 1, 40, 25);
INSERT INTO  Egzaminy Values(113, "Polski", 0, 2010, 1, 50, 15);
INSERT INTO  Egzaminy Values(213, "Polski", 0, 2011, 1, 50, 15);
INSERT INTO  Egzaminy Values(313, "Polski", 0, 2012, 1, 50, 15);
INSERT INTO  Egzaminy Values(413, "Polski", 0, 2013, 1, 50, 15);
INSERT INTO  Egzaminy Values(513, "Polski", 0, 2014, 1, 50, 15);
INSERT INTO  Egzaminy Values(613, "Polski", 0, 2015, 1, 50, 15);
INSERT INTO  Egzaminy Values(114, "Angielski", 0, 2010, 0, 40, 17);
INSERT INTO  Egzaminy Values(214, "Angielski", 0, 2011, 0, 40, 17);
INSERT INTO  Egzaminy Values(314, "Angielski", 0, 2012, 0, 40, 17);
INSERT INTO  Egzaminy Values(414, "Angielski", 0, 2013, 0, 40, 17);
INSERT INTO  Egzaminy Values(514, "Angielski", 0, 2014, 0, 40, 17);
INSERT INTO  Egzaminy Values(614, "Angielski", 0, 2015, 0, 40, 17);
INSERT INTO  Egzaminy Values(107, "Matematyka", 1, 2010, 0, 40, 7);
INSERT INTO  Egzaminy Values(207, "Matematyka", 1, 2011, 0, 40, 7);
INSERT INTO  Egzaminy Values(307, "Matematyka", 1, 2012, 0, 40, 7);
INSERT INTO  Egzaminy Values(407, "Matematyka", 1, 2013, 0, 40, 7);
INSERT INTO  Egzaminy Values(507, "Matematyka", 1, 2014, 0, 40, 7);
INSERT INTO  Egzaminy Values(607, "Matematyka", 1, 2015, 0, 40, 7);

INSERT INTO [Rozklad Punktow] Values(102, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(102, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(102, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(102, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(102, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(102, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(102, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(102, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(102, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(102, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(102, 11, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(102, 12, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(102, 13, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(102, 14, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(102, 15, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(102, 16, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(102, 17, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(102, 18, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(102, 19, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(102, 20, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(202, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(202, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(202, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(202, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(202, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(202, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(202, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(202, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(202, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(202, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(202, 11, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(202, 12, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(202, 13, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(202, 14, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(202, 15, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(202, 16, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(202, 17, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(202, 18, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(202, 19, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(202, 20, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(302, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(302, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(302, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(302, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(302, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(302, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(302, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(302, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(302, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(302, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(302, 11, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(302, 12, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(302, 13, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(302, 14, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(302, 15, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(302, 16, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(302, 17, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(302, 18, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(302, 19, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(302, 20, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(402, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(402, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(402, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(402, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(402, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(402, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(402, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(402, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(402, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(402, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(402, 11, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(402, 12, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(402, 13, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(402, 14, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(402, 15, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(402, 16, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(402, 17, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(402, 18, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(402, 19, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(402, 20, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(502, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(502, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(502, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(502, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(502, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(502, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(502, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(502, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(502, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(502, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(502, 11, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(502, 12, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(502, 13, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(502, 14, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(502, 15, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(502, 16, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(502, 17, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(502, 18, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(502, 19, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(502, 20, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(602, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(602, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(602, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(602, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(602, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(602, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(602, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(602, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(602, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(602, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(602, 11, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(602, 12, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(602, 13, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(602, 14, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(602, 15, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(602, 16, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(602, 17, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(602, 18, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(602, 19, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(602, 20, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(112, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(112, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(112, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(112, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(112, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(112, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(112, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(112, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(112, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(112, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(112, 11, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(112, 12, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(112, 13, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(112, 14, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(112, 15, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(112, 16, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(112, 17, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(112, 18, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(112, 19, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(112, 20, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(212, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(212, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(212, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(212, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(212, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(212, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(212, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(212, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(212, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(212, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(212, 11, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(212, 12, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(212, 13, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(212, 14, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(212, 15, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(212, 16, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(212, 17, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(212, 18, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(212, 19, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(212, 20, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(312, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(312, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(312, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(312, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(312, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(312, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(312, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(312, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(312, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(312, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(312, 11, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(312, 12, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(312, 13, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(312, 14, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(312, 15, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(312, 16, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(312, 17, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(312, 18, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(312, 19, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(312, 20, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(412, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(412, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(412, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(412, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(412, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(412, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(412, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(412, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(412, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(412, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(412, 11, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(412, 12, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(412, 13, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(412, 14, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(412, 15, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(412, 16, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(412, 17, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(412, 18, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(412, 19, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(412, 20, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(512, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(512, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(512, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(512, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(512, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(512, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(512, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(512, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(512, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(512, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(512, 11, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(512, 12, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(512, 13, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(512, 14, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(512, 15, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(512, 16, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(512, 17, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(512, 18, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(512, 19, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(512, 20, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(612, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(612, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(612, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(612, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(612, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(612, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(612, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(612, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(612, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(612, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(612, 11, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(612, 12, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(612, 13, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(612, 14, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(612, 15, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(612, 16, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(612, 17, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(612, 18, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(612, 19, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(612, 20, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(114, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(114, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(114, 3, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(114, 4, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(114, 5, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(114, 6, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(114, 7, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(114, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(114, 9, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(114, 10, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(214, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(214, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(214, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(214, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(214, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(214, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(214, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(214, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(214, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(214, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(314, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(314, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(314, 3, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(314, 4, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(314, 5, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(314, 6, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(314, 7, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(314, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(314, 9, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(314, 10, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(414, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(414, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(414, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(414, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(414, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(414, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(414, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(414, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(414, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(414, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(514, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(514, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(514, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(514, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(514, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(514, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(514, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(514, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(514, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(514, 10, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(614, 1, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(614, 2, 1, "Odpowiedz D");
INSERT INTO [Rozklad Punktow] Values(614, 3, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(614, 4, 1, "Odpowiedz B");
INSERT INTO [Rozklad Punktow] Values(614, 5, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(614, 6, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(614, 7, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(614, 8, 1, "Odpowiedz C");
INSERT INTO [Rozklad Punktow] Values(614, 9, 1, "Odpowiedz A");
INSERT INTO [Rozklad Punktow] Values(614, 10, 1, "Odpowiedz A");

INSERT INTO [Rozklad Punktow] Values(202, 25, 7, "1 - dane i szukane, 2-rysunek, 1- poprawna odpowiedz, 2- dobry tok rozumowania, 1- brak b³êdów rachunkowych");
INSERT INTO [Rozklad Punktow] Values(202, 21, 2, "1-odpowiedz,dane i szukane, 1-obliczenia");
INSERT INTO [Rozklad Punktow] Values(202, 22, 3, "Po 1 za zaznacznie prawidlowego wyniku");
INSERT INTO [Rozklad Punktow] Values(202, 23, 3, "Po 1 za dobry wynik w ka¿dym podpunkcie");
INSERT INTO [Rozklad Punktow] Values(202, 24, 5, "2- podpunkt a, 3- podpunkt b");
INSERT INTO [Rozklad Punktow] Values(302, 25, 7, "1 - dane i szukane, 2-rysunek, 1- poprawna odpowiedz, 2- dobry tok rozumowania, 1- brak b³êdów rachunkowych");
INSERT INTO [Rozklad Punktow] Values(302, 21, 2, "1-odpowiedz,dane i szukane, 1-obliczenia");
INSERT INTO [Rozklad Punktow] Values(302, 22, 3, "Po 1 za zaznacznie prawidlowego wyniku");
INSERT INTO [Rozklad Punktow] Values(302, 23, 3, "Po 1 za dobry wynik w ka¿dym podpunkcie");
INSERT INTO [Rozklad Punktow] Values(302, 24, 5, "2- podpunkt a, 3- podpunkt b");
INSERT INTO [Rozklad Punktow] Values(402, 25, 7, "1 - dane i szukane, 2-rysunek, 1- poprawna odpowiedz, 2- dobry tok rozumowania, 1- brak b³êdów rachunkowych");
INSERT INTO [Rozklad Punktow] Values(402, 21, 2, "1-odpowiedz,dane i szukane, 1-obliczenia");
INSERT INTO [Rozklad Punktow] Values(402, 22, 3, "Po 1 za zaznacznie prawidlowego wyniku");
INSERT INTO [Rozklad Punktow] Values(402, 23, 3, "Po 1 za dobry wynik w ka¿dym podpunkcie");
INSERT INTO [Rozklad Punktow] Values(402, 24, 5, "2- podpunkt a, 3- podpunkt b");
INSERT INTO [Rozklad Punktow] Values(502, 25, 7, "1 - dane i szukane, 2-rysunek, 1- poprawna odpowiedz, 2- dobry tok rozumowania, 1- brak b³êdów rachunkowych");
INSERT INTO [Rozklad Punktow] Values(502, 21, 2, "1-odpowiedz,dane i szukane, 1-obliczenia");
INSERT INTO [Rozklad Punktow] Values(502, 22, 3, "Po 1 za zaznacznie prawidlowego wyniku");
INSERT INTO [Rozklad Punktow] Values(502, 23, 3, "Po 1 za dobry wynik w ka¿dym podpunkcie");
INSERT INTO [Rozklad Punktow] Values(502, 24, 5, "2- podpunkt a, 3- podpunkt b");
INSERT INTO [Rozklad Punktow] Values(602, 25, 7, "1 - dane i szukane, 2-rysunek, 1- poprawna odpowiedz, 2- dobry tok rozumowania, 1- brak b³êdów rachunkowych");
INSERT INTO [Rozklad Punktow] Values(602, 21, 2, "1-odpowiedz,dane i szukane, 1-obliczenia");
INSERT INTO [Rozklad Punktow] Values(602, 22, 3, "Po 1 za zaznacznie prawidlowego wyniku");
INSERT INTO [Rozklad Punktow] Values(602, 23, 3, "Po 1 za dobry wynik w ka¿dym podpunkcie");
INSERT INTO [Rozklad Punktow] Values(602, 24, 5, "2- podpunkt a, 3- podpunkt b");
INSERT INTO [Rozklad Punktow] Values(102, 25, 7, "1 - dane i szukane, 2-rysunek, 1- poprawna odpowiedz, 2- dobry tok rozumowania, 1- brak b³êdów rachunkowych");
INSERT INTO [Rozklad Punktow] Values(102, 21, 2, "1-odpowiedz,dane i szukane, 1-obliczenia");
INSERT INTO [Rozklad Punktow] Values(102, 22, 3, "Po 1 za zaznacznie prawidlowego wyniku");
INSERT INTO [Rozklad Punktow] Values(102, 23, 3, "Po 1 za dobry wynik w ka¿dym podpunkcie");
INSERT INTO [Rozklad Punktow] Values(102, 24, 5, "2- podpunkt a, 3- podpunkt b");
INSERT INTO [Rozklad Punktow] Values(212, 25, 7, "1 - dane i szukane, 2-rysunek, 1- poprawna odpowiedz, 2- dobry tok rozumowania, 1- brak b³êdów rachunkowych");
INSERT INTO [Rozklad Punktow] Values(212, 21, 2, "1-odpowiedz,dane i szukane, 1-obliczenia");
INSERT INTO [Rozklad Punktow] Values(212, 22, 3, "Po 1 za zaznacznie prawidlowego wyniku");
INSERT INTO [Rozklad Punktow] Values(212, 23, 3, "Po 1 za dobry wynik w ka¿dym podpunkcie");
INSERT INTO [Rozklad Punktow] Values(212, 24, 5, "2- podpunkt a, 3- podpunkt b");
INSERT INTO [Rozklad Punktow] Values(312, 25, 7, "1 - dane i szukane, 2-rysunek, 1- poprawna odpowiedz, 2- dobry tok rozumowania, 1- brak b³êdów rachunkowych");
INSERT INTO [Rozklad Punktow] Values(312, 21, 2, "1-odpowiedz,dane i szukane, 1-obliczenia");
INSERT INTO [Rozklad Punktow] Values(312, 22, 3, "Po 1 za zaznacznie prawidlowego wyniku");
INSERT INTO [Rozklad Punktow] Values(312, 23, 3, "Po 1 za dobry wynik w ka¿dym podpunkcie");
INSERT INTO [Rozklad Punktow] Values(312, 24, 5, "2- podpunkt a, 3- podpunkt b");
INSERT INTO [Rozklad Punktow] Values(412, 25, 7, "1 - dane i szukane, 2-rysunek, 1- poprawna odpowiedz, 2- dobry tok rozumowania, 1- brak b³êdów rachunkowych");
INSERT INTO [Rozklad Punktow] Values(412, 21, 2, "1-odpowiedz,dane i szukane, 1-obliczenia");
INSERT INTO [Rozklad Punktow] Values(412, 22, 3, "Po 1 za zaznacznie prawidlowego wyniku");
INSERT INTO [Rozklad Punktow] Values(412, 23, 3, "Po 1 za dobry wynik w ka¿dym podpunkcie");
INSERT INTO [Rozklad Punktow] Values(412, 24, 5, "2- podpunkt a, 3- podpunkt b");
INSERT INTO [Rozklad Punktow] Values(512, 25, 7, "1 - dane i szukane, 2-rysunek, 1- poprawna odpowiedz, 2- dobry tok rozumowania, 1- brak b³êdów rachunkowych");
INSERT INTO [Rozklad Punktow] Values(512, 21, 2, "1-odpowiedz,dane i szukane, 1-obliczenia");
INSERT INTO [Rozklad Punktow] Values(512, 22, 3, "Po 1 za zaznacznie prawidlowego wyniku");
INSERT INTO [Rozklad Punktow] Values(512, 23, 3, "Po 1 za dobry wynik w ka¿dym podpunkcie");
INSERT INTO [Rozklad Punktow] Values(512, 24, 5, "2- podpunkt a, 3- podpunkt b");
INSERT INTO [Rozklad Punktow] Values(612, 25, 7, "1 - dane i szukane, 2-rysunek, 1- poprawna odpowiedz, 2- dobry tok rozumowania, 1- brak b³êdów rachunkowych");
INSERT INTO [Rozklad Punktow] Values(612, 21, 2, "1-odpowiedz,dane i szukane, 1-obliczenia");
INSERT INTO [Rozklad Punktow] Values(612, 22, 3, "Po 1 za zaznacznie prawidlowego wyniku");
INSERT INTO [Rozklad Punktow] Values(612, 23, 3, "Po 1 za dobry wynik w ka¿dym podpunkcie");
INSERT INTO [Rozklad Punktow] Values(612, 24, 5, "2- podpunkt a, 3- podpunkt b");
INSERT INTO [Rozklad Punktow] Values(112, 25, 7, "1 - dane i szukane, 2-rysunek, 1- poprawna odpowiedz, 2- dobry tok rozumowania, 1- brak b³êdów rachunkowych");
INSERT INTO [Rozklad Punktow] Values(112, 21, 2, "1-odpowiedz,dane i szukane, 1-obliczenia");
INSERT INTO [Rozklad Punktow] Values(112, 22, 3, "Po 1 za zaznacznie prawidlowego wyniku");
INSERT INTO [Rozklad Punktow] Values(112, 23, 3, "Po 1 za dobry wynik w ka¿dym podpunkcie");
INSERT INTO [Rozklad Punktow] Values(112, 24, 5, "2- podpunkt a, 3- podpunkt b");
INSERT INTO [Rozklad Punktow] Values(104, 11, 3, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(104, 12, 5, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(104, 13, 4, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(104, 14, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(104, 16, 6, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(104, 15, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(104, 17, 8, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(204, 11, 3, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(204, 12, 5, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(204, 13, 4, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(204, 14, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(204, 16, 6, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(204, 15, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(204, 17, 8, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(304, 11, 3, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(304, 12, 5, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(304, 13, 4, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(304, 14, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(304, 16, 6, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(304, 15, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(304, 17, 8, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(404, 11, 3, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(404, 12, 5, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(404, 13, 4, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(404, 14, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(404, 16, 6, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(404, 15, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(404, 17, 8, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(504, 11, 3, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(504, 12, 5, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(504, 13, 4, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(504, 14, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(504, 16, 6, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(504, 15, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(504, 17, 8, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(604, 11, 3, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(604, 12, 5, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(604, 13, 4, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(604, 14, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(604, 16, 6, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(604, 15, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(604, 17, 8, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(114, 11, 3, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(114, 12, 5, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(114, 13, 4, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(114, 14, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(114, 16, 6, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(114, 15, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(114, 17, 8, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(214, 11, 3, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(214, 12, 5, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(214, 13, 4, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(214, 14, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(214, 16, 6, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(214, 15, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(214, 17, 8, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(314, 11, 3, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(314, 12, 5, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(314, 13, 4, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(314, 14, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(314, 16, 6, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(314, 15, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(314, 17, 8, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(414, 11, 3, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(414, 12, 5, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(414, 13, 4, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(414, 14, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(414, 16, 6, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(414, 15, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(414, 17, 8, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(514, 11, 3, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(514, 12, 5, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(514, 13, 4, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(514, 14, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(514, 16, 6, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(514, 15, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(514, 17, 8, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(614, 11, 3, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(614, 12, 5, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(614, 13, 4, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(614, 14, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(614, 16, 6, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(614, 15, 2, "Wed³ug oceniaj¹cego");
INSERT INTO [Rozklad Punktow] Values(614, 17, 8, "Wed³ug oceniaj¹cego");

INSERT INTO [Rozklad Punktow] Values(103, 1, 3, "Po 1 za dopasowanie 2 wyrazen");
INSERT INTO [Rozklad Punktow] Values(103, 2, 6, "Po 2 za definicje");
INSERT INTO [Rozklad Punktow] Values(103, 3, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(103, 4, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(103, 5, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(103, 6, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(103, 7, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(103, 8, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(103, 9, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(103, 10, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(103, 11, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(103, 12, 2, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(103, 13, 4, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(103, 14, 6, "2-ortografia, 1-forma, 3-tresc");
INSERT INTO [Rozklad Punktow] Values(103, 15, 20, "13-po 1 za uwzgledniony problem z klucza, 3-ortografia, 2- poprawnosc jezykowa, 2-zgodnosc z tematem");
INSERT INTO [Rozklad Punktow] Values(203, 1, 3, "Po 1 za dopasowanie 2 wyrazen");
INSERT INTO [Rozklad Punktow] Values(203, 2, 6, "Po 2 za definicje");
INSERT INTO [Rozklad Punktow] Values(203, 3, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(203, 4, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(203, 5, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(203, 6, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(203, 7, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(203, 8, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(203, 9, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(203, 10, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(203, 11, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(203, 12, 2, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(203, 13, 4, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(203, 14, 6, "2-ortografia, 1-forma, 3-tresc");
INSERT INTO [Rozklad Punktow] Values(203, 15, 20, "13-po 1 za uwzgledniony problem z klucza, 3-ortografia, 2- poprawnosc jezykowa, 2-zgodnosc z tematem");
INSERT INTO [Rozklad Punktow] Values(303, 1, 3, "Po 1 za dopasowanie 2 wyrazen");
INSERT INTO [Rozklad Punktow] Values(303, 2, 6, "Po 2 za definicje");
INSERT INTO [Rozklad Punktow] Values(303, 3, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(303, 4, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(303, 5, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(303, 6, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(303, 7, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(303, 8, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(303, 9, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(303, 10, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(303, 11, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(303, 12, 2, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(303, 13, 4, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(303, 14, 6, "2-ortografia, 1-forma, 3-tresc");
INSERT INTO [Rozklad Punktow] Values(303, 15, 20, "13-po 1 za uwzgledniony problem z klucza, 3-ortografia, 2- poprawnosc jezykowa, 2-zgodnosc z tematem");
INSERT INTO [Rozklad Punktow] Values(403, 1, 3, "Po 1 za dopasowanie 2 wyrazen");
INSERT INTO [Rozklad Punktow] Values(403, 2, 6, "Po 2 za definicje");
INSERT INTO [Rozklad Punktow] Values(403, 3, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(403, 4, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(403, 5, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(403, 6, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(403, 7, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(403, 8, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(403, 9, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(403, 10, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(403, 11, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(403, 12, 2, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(403, 13, 4, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(403, 14, 6, "2-ortografia, 1-forma, 3-tresc");
INSERT INTO [Rozklad Punktow] Values(403, 15, 20, "13-po 1 za uwzgledniony problem z klucza, 3-ortografia, 2- poprawnosc jezykowa, 2-zgodnosc z tematem");
INSERT INTO [Rozklad Punktow] Values(503, 1, 3, "Po 1 za dopasowanie 2 wyrazen");
INSERT INTO [Rozklad Punktow] Values(503, 2, 6, "Po 2 za definicje");
INSERT INTO [Rozklad Punktow] Values(503, 3, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(503, 4, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(503, 5, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(503, 6, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(503, 7, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(503, 8, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(503, 9, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(503, 10, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(503, 11, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(503, 12, 2, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(503, 13, 4, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(503, 14, 6, "2-ortografia, 1-forma, 3-tresc");
INSERT INTO [Rozklad Punktow] Values(503, 15, 20, "13-po 1 za uwzgledniony problem z klucza, 3-ortografia, 2- poprawnosc jezykowa, 2-zgodnosc z tematem");
INSERT INTO [Rozklad Punktow] Values(603, 1, 3, "Po 1 za dopasowanie 2 wyrazen");
INSERT INTO [Rozklad Punktow] Values(603, 2, 6, "Po 2 za definicje");
INSERT INTO [Rozklad Punktow] Values(603, 3, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(603, 4, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(603, 5, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(603, 6, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(603, 7, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(603, 8, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(603, 9, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(603, 10, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(603, 11, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(603, 12, 2, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(603, 13, 4, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(603, 14, 6, "2-ortografia, 1-forma, 3-tresc");
INSERT INTO [Rozklad Punktow] Values(603, 15, 20, "13-po 1 za uwzgledniony problem z klucza, 3-ortografia, 2- poprawnosc jezykowa, 2-zgodnosc z tematem");
INSERT INTO [Rozklad Punktow] Values(113, 1, 3, "Po 1 za dopasowanie 2 wyrazen");
INSERT INTO [Rozklad Punktow] Values(113, 2, 6, "Po 2 za definicje");
INSERT INTO [Rozklad Punktow] Values(113, 3, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(113, 4, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(113, 5, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(113, 6, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(113, 7, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(113, 8, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(113, 9, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(113, 10, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(113, 11, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(113, 12, 2, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(113, 13, 4, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(113, 14, 6, "2-ortografia, 1-forma, 3-tresc");
INSERT INTO [Rozklad Punktow] Values(113, 15, 20, "13-po 1 za uwzgledniony problem z klucza, 3-ortografia, 2- poprawnosc jezykowa, 2-zgodnosc z tematem");
INSERT INTO [Rozklad Punktow] Values(213, 1, 3, "Po 1 za dopasowanie 2 wyrazen");
INSERT INTO [Rozklad Punktow] Values(213, 2, 6, "Po 2 za definicje");
INSERT INTO [Rozklad Punktow] Values(213, 3, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(213, 4, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(213, 5, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(213, 6, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(213, 7, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(213, 8, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(213, 9, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(213, 10, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(213, 11, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(213, 12, 2, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(213, 13, 4, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(213, 14, 6, "2-ortografia, 1-forma, 3-tresc");
INSERT INTO [Rozklad Punktow] Values(213, 15, 20, "13-po 1 za uwzgledniony problem z klucza, 3-ortografia, 2- poprawnosc jezykowa, 2-zgodnosc z tematem");
INSERT INTO [Rozklad Punktow] Values(313, 1, 3, "Po 1 za dopasowanie 2 wyrazen");
INSERT INTO [Rozklad Punktow] Values(313, 2, 6, "Po 2 za definicje");
INSERT INTO [Rozklad Punktow] Values(313, 3, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(313, 4, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(313, 5, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(313, 6, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(313, 7, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(313, 8, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(313, 9, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(313, 10, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(313, 11, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(313, 12, 2, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(313, 13, 4, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(313, 14, 6, "2-ortografia, 1-forma, 3-tresc");
INSERT INTO [Rozklad Punktow] Values(313, 15, 20, "13-po 1 za uwzgledniony problem z klucza, 3-ortografia, 2- poprawnosc jezykowa, 2-zgodnosc z tematem");
INSERT INTO [Rozklad Punktow] Values(413, 1, 3, "Po 1 za dopasowanie 2 wyrazen");
INSERT INTO [Rozklad Punktow] Values(413, 2, 6, "Po 2 za definicje");
INSERT INTO [Rozklad Punktow] Values(413, 3, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(413, 4, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(413, 5, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(413, 6, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(413, 7, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(413, 8, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(413, 9, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(413, 10, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(413, 11, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(413, 12, 2, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(413, 13, 4, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(413, 14, 6, "2-ortografia, 1-forma, 3-tresc");
INSERT INTO [Rozklad Punktow] Values(413, 15, 20, "13-po 1 za uwzgledniony problem z klucza, 3-ortografia, 2- poprawnosc jezykowa, 2-zgodnosc z tematem");
INSERT INTO [Rozklad Punktow] Values(513, 1, 3, "Po 1 za dopasowanie 2 wyrazen");
INSERT INTO [Rozklad Punktow] Values(513, 2, 6, "Po 2 za definicje");
INSERT INTO [Rozklad Punktow] Values(513, 3, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(513, 4, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(513, 5, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(513, 6, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(513, 7, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(513, 8, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(513, 9, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(513, 10, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(513, 11, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(513, 12, 2, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(513, 13, 4, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(513, 14, 6, "2-ortografia, 1-forma, 3-tresc");
INSERT INTO [Rozklad Punktow] Values(513, 15, 20, "13-po 1 za uwzgledniony problem z klucza, 3-ortografia, 2- poprawnosc jezykowa, 2-zgodnosc z tematem");
INSERT INTO [Rozklad Punktow] Values(613, 1, 3, "Po 1 za dopasowanie 2 wyrazen");
INSERT INTO [Rozklad Punktow] Values(613, 2, 6, "Po 2 za definicje");
INSERT INTO [Rozklad Punktow] Values(613, 3, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(613, 4, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(613, 5, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(613, 6, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(613, 7, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(613, 8, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(613, 9, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(613, 10, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(613, 11, 1, "1- prawidlowa odpowiedz");
INSERT INTO [Rozklad Punktow] Values(613, 12, 2, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(613, 13, 4, "Po 1 za poprawna odpowiedz");
INSERT INTO [Rozklad Punktow] Values(613, 14, 6, "2-ortografia, 1-forma, 3-tresc");
INSERT INTO [Rozklad Punktow] Values(613, 15, 20, "13-po 1 za uwzgledniony problem z klucza, 3-ortografia, 2- poprawnosc jezykowa, 2-zgodnosc z tematem");

INSERT INTO [Rozklad Punktow] Values(107, 1, 5, "1- odpowiedz, 1- dane, 1- rysunek, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(107, 2, 4, "1- odpowiedz, 1- dane, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(107, 3, 7, "1- odpowiedz, 1- dane,  2- obliczenia podpunkt a, 3-obliczenia podpunkt b");
INSERT INTO [Rozklad Punktow] Values(107, 4, 6, "1- odpowiedz, 1- dane, 1- rysunek, 3- obliczenia");
INSERT INTO [Rozklad Punktow] Values(107, 5, 5, "1- odpowiedz, 1- dane, 1- rysunek, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(107, 6, 8, "1-zdefiniwanie tezy i zalozen, 7-dowód");
INSERT INTO [Rozklad Punktow] Values(107, 1, 5, "1- odpowiedz, 1- dane, 3- obliczenia");
INSERT INTO [Rozklad Punktow] Values(207, 1, 5, "1- odpowiedz, 1- dane, 1- rysunek, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(207, 2, 4, "1- odpowiedz, 1- dane, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(207, 3, 7, "1- odpowiedz, 1- dane,  2- obliczenia podpunkt a, 3-obliczenia podpunkt b");
INSERT INTO [Rozklad Punktow] Values(207, 4, 6, "1- odpowiedz, 1- dane, 1- rysunek, 3- obliczenia");
INSERT INTO [Rozklad Punktow] Values(207, 5, 5, "1- odpowiedz, 1- dane, 1- rysunek, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(207, 6, 8, "1-zdefiniwanie tezy i zalozen, 7-dowód");
INSERT INTO [Rozklad Punktow] Values(207, 1, 5, "1- odpowiedz, 1- dane, 3- obliczenia");
INSERT INTO [Rozklad Punktow] Values(307, 1, 5, "1- odpowiedz, 1- dane, 1- rysunek, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(307, 2, 4, "1- odpowiedz, 1- dane, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(307, 3, 7, "1- odpowiedz, 1- dane,  2- obliczenia podpunkt a, 3-obliczenia podpunkt b");
INSERT INTO [Rozklad Punktow] Values(307, 4, 6, "1- odpowiedz, 1- dane, 1- rysunek, 3- obliczenia");
INSERT INTO [Rozklad Punktow] Values(307, 5, 5, "1- odpowiedz, 1- dane, 1- rysunek, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(307, 6, 8, "1-zdefiniwanie tezy i zalozen, 7-dowód");
INSERT INTO [Rozklad Punktow] Values(307, 1, 5, "1- odpowiedz, 1- dane, 3- obliczenia");
INSERT INTO [Rozklad Punktow] Values(407, 1, 5, "1- odpowiedz, 1- dane, 1- rysunek, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(407, 2, 4, "1- odpowiedz, 1- dane, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(407, 3, 7, "1- odpowiedz, 1- dane,  2- obliczenia podpunkt a, 3-obliczenia podpunkt b");
INSERT INTO [Rozklad Punktow] Values(407, 4, 6, "1- odpowiedz, 1- dane, 1- rysunek, 3- obliczenia");
INSERT INTO [Rozklad Punktow] Values(407, 5, 5, "1- odpowiedz, 1- dane, 1- rysunek, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(407, 6, 8, "1-zdefiniwanie tezy i zalozen, 7-dowód");
INSERT INTO [Rozklad Punktow] Values(407, 1, 5, "1- odpowiedz, 1- dane, 3- obliczenia");
INSERT INTO [Rozklad Punktow] Values(507, 1, 5, "1- odpowiedz, 1- dane, 1- rysunek, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(507, 2, 4, "1- odpowiedz, 1- dane, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(507, 3, 7, "1- odpowiedz, 1- dane,  2- obliczenia podpunkt a, 3-obliczenia podpunkt b");
INSERT INTO [Rozklad Punktow] Values(507, 4, 6, "1- odpowiedz, 1- dane, 1- rysunek, 3- obliczenia");
INSERT INTO [Rozklad Punktow] Values(507, 5, 5, "1- odpowiedz, 1- dane, 1- rysunek, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(507, 6, 8, "1-zdefiniwanie tezy i zalozen, 7-dowód");
INSERT INTO [Rozklad Punktow] Values(507, 1, 5, "1- odpowiedz, 1- dane, 3- obliczenia");
INSERT INTO [Rozklad Punktow] Values(607, 1, 5, "1- odpowiedz, 1- dane, 1- rysunek, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(607, 2, 4, "1- odpowiedz, 1- dane, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(607, 3, 7, "1- odpowiedz, 1- dane,  2- obliczenia podpunkt a, 3-obliczenia podpunkt b");
INSERT INTO [Rozklad Punktow] Values(607, 4, 6, "1- odpowiedz, 1- dane, 1- rysunek, 3- obliczenia");
INSERT INTO [Rozklad Punktow] Values(607, 5, 5, "1- odpowiedz, 1- dane, 1- rysunek, 2- obliczenia");
INSERT INTO [Rozklad Punktow] Values(607, 6, 8, "1-zdefiniwanie tezy i zalozen, 7-dowód");
INSERT INTO [Rozklad Punktow] Values(607, 1, 5, "1- odpowiedz, 1- dane, 3- obliczenia");

-- Szkoly
INSERT INTO Szkoly (Nazwa, Miasto, Ulica, [Kod pocztowy], Dyrektor) VALUES("I LO w Krakowie", "Krakow", "Ogrodowa 14", 13521, "Amanda Niziolek");
INSERT INTO Szkoly (Nazwa, Miasto, Ulica, [Kod pocztowy], Dyrektor) VALUES("II LO w Krawowie", "Krakow", "Warszawska 3", 13534, "Klaudia Likier");
INSERT INTO Szkoly (Nazwa, Miasto, Ulica, [Kod pocztowy], Dyrektor) VALUES("I Liceum Matematyczno-Informatyczne w Krakowie", "Krakow", "Warszawska 3", 13534, "Klaudia Likier");
INSERT INTO Szkoly (Nazwa, [Nr Szkoly], Miasto, Ulica, [Kod pocztowy], Dyrektor) VALUES("Technikum Informatyczne", 2, "Zamosc", "Krakowska 1", 17221, "Piotr Niedzwiadek");
INSERT INTO Szkoly (Nazwa, Miasto, Ulica, [Kod pocztowy], Dyrektor) VALUES("III LO w Krakowie", "Krakow", "Lodowa 2", 13514, "Krzysztof Grawczyk");
INSERT INTO Szkoly (Nazwa, [Nr Szkoly], Miasto, Ulica, [Kod pocztowy], Dyrektor) VALUES("Technikum Budowlane", 1, "Krakow", "Ogrodowa 8", 13521, "Adrian Kowalski");
INSERT INTO Szkoly (Nazwa, Miasto, Ulica, [Kod pocztowy], Dyrektor) VALUES("I LO w Poznaniu", "Poznan", "Horacego 14", 25361, "Aleksandra Fikus");
INSERT INTO Szkoly (Nazwa, Miasto, Ulica, [Kod pocztowy], Dyrektor) VALUES("I LO w Warszawie", "Warszawa", "Ogrodowa 11", 31152, "Krzysztof Roman");
INSERT INTO Szkoly (Nazwa, Miasto, Ulica, [Kod pocztowy], Dyrektor) VALUES("II LO w Warszawie", "Warszawa", "Ró¿ana 3", 31154, "Roman Aniol");
INSERT INTO Szkoly (Nazwa, Miasto, Ulica, [Kod pocztowy], Dyrektor) VALUES("III LO w Warszawie", "Warszawa", "Klasztorna 11", 31172, "Klara Dom");
INSERT INTO Szkoly (Nazwa, [Nr Szkoly], Miasto, Ulica, [Kod pocztowy], Dyrektor) VALUES("Technikum Gastronomiczne w Poznaniu", 1, "Poznan", "Wodna 3", 25265, "Magdelena Kapusta");

--Osoby
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(159624, "Anna", "Tetmajer", date("1966-03-11"), "Zamkowa", "Krakow", 13685, "e2e0f55b0b1530297c439a5066ac0723562eda06") ;
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(126842, "Zuzanna", "Lament", date("1996-02-21"), "Wilhelmia", "Krakow", 13355, "10fea34ec858803b5560ed710af8a371d0d5dd05") ;
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(137891, "Tomasz", "Lodowik", date("1970-11-01"), "Warszawska", "Krakow", 13534, "e2c3b00cebe8deb8f858ed0aebedefe5c4410060") ;
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(189145, "Krystian", "Samotnik", date("1993-05-07"), "Biala", "Poznan", 25115, "0f043dbba797a023317ac213218cbdc6b8fb4817") ;
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(185542, "Anna", "Rusalek", date("1991-04-16"), "Niecala", "Poznan", 25485, "6ade7c9881751c2cd5bf40fc5d707b6bfed9810d") ;
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(176583, "Filip", "Kowalski", date("1973-07-14"), "Fiolkowa", "Poznan", 25637, "1a45b52587e6b7beec0652498c72e2c4d71082d7") ;
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(179942, "Karolina", "Samotnik", date("1980-03-11"), "Kosciuszki", "Zamosc", 17215, "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8") ;
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Drugie_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(209561, "Franciszek", "Karol","Komos", date("2000-01-12"), "Lazurowa", "Zamosc", 17263, "96eccd072d5cd24e2cb2250ec34fc69e2542a4e1") ;
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(115472, "Renata", "Guzik", date("1959-02-12"), "Zimowa", "Warszawa", 31255, "6f9251cccaaeb8c79dbaf865b6ac18ebabaa06ab") ;
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(175986, "Beata", "Guzik", date("1996-09-30"), "Zimowa", "Warszawa", 31255, "080ec52cd229721b99bc27bbee72f23430b5401d") ;
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(118556, "Sandra", "Janik", date("1960-03-12"), "Rozana", "Warszawa", 31257, "24efdd62497228d037e53e7e0a0e2a1f01fa8106") ;
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(193651, "Bartlomiej", "Filar", date("1992-08-25"), "Zlota", "Warszawa", 31259, "41e34fb6279f7a5048d3eecd244f5010742954d4") ;
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(119235, "Ryszard", "Michalski", date("1998-08-16"), "Judy", "Warszawa", 31269, "6b1bcb0947073332c837542e887f1554fd17c639") ;
INSERT INTO Osoby(PESEL, Pierwsze_Imie, Nazwisko, Data_Urodzenia, Ulica, Miasto, [Kod pocztowy], haslo) VALUES(192856, "Luiza", "Szara", date("1996-04-21"), "Konwaliowa", "Warszawa", 31245, "549f81acdfe221bb7fa16f9b5f8287e439a8dde0") ;

--Nauczyciele
INSERT INTO Nauczyciele(PESEL, Staz, Szkola, Uprawnienia)  VALUES(159624, 20, 3, 1) ;
INSERT INTO Nauczyciele(PESEL, Staz, Szkola, Uprawnienia) VALUES(137891, 15, null, 1) ;
INSERT INTO Nauczyciele(PESEL, Staz, Szkola, Uprawnienia) VALUES(176583, 12, 7, 1) ;
INSERT INTO Nauczyciele(PESEL, Staz, Szkola, Uprawnienia) VALUES(179942, 5, 4, 0) ;
INSERT INTO Nauczyciele(PESEL, Staz, Szkola, Uprawnienia) VALUES(115472, 30, 9, 1) ;
INSERT INTO Nauczyciele(PESEL, Staz, Szkola, Uprawnienia) VALUES(118556, 21, 10, 1) ;

--Uczniowie
INSERT INTO Uczniowie(PESEL, Wychowawca, Szkola, [Rok rozpoczecia]) VALUES(209561, 4, 4, date("2015-09-01")) ;
INSERT INTO Uczniowie(PESEL, Wychowawca, Szkola, [Rok rozpoczecia], [Rok zakonczenia]) VALUES(126842, 1, 3, date("2011-09-01"), date("2015-04-30")) ;
INSERT INTO Uczniowie(PESEL, Wychowawca, Szkola, [Rok rozpoczecia]) VALUES(189145, 3, 7, date("2009-09-01")) ;
INSERT INTO Uczniowie(PESEL, Wychowawca, Szkola, [Rok rozpoczecia]) VALUES(185542, 3, 7, date("2007-09-01")) ;
INSERT INTO Uczniowie(PESEL, Wychowawca, Szkola, [Rok rozpoczecia]) VALUES(175986, 5, 9, date("2012-09-01")) ;
INSERT INTO Uczniowie(PESEL, Wychowawca, Szkola, [Rok rozpoczecia]) VALUES(193651, 5, 9, date("2008-09-01")) ;
INSERT INTO Uczniowie(PESEL, Wychowawca, Szkola, [Rok rozpoczecia]) VALUES(119235, 6, 10, date("2014-08-16")) ;
INSERT INTO Uczniowie(PESEL, Wychowawca, Szkola, [Rok rozpoczecia]) VALUES(192856, 6, 10, date("2012-09-01"));

--Rezultaty
INSERT INTO Rezultaty VALUES(25, 602, 2, 38, 95, 1);
INSERT INTO Rezultaty VALUES(36, 604, 2, 11, 27.5, 0);
INSERT INTO Rezultaty VALUES(136, 614, 2, 15, 37.5, 1);
INSERT INTO Rezultaty VALUES(525, 607, 2, 30, 75, 1);
INSERT INTO Rezultaty VALUES(21, 402, 3, 8, 20, 0);
INSERT INTO Rezultaty VALUES(11, 403, 3, 42, 84, 1);
INSERT INTO Rezultaty VALUES(34, 404, 3, 30, 75, 1);
INSERT INTO Rezultaty VALUES(60, 502, 3, 31, 77.5, 1);
INSERT INTO Rezultaty VALUES(20, 202, 4, 38, 95, 1);
INSERT INTO Rezultaty VALUES(19, 203, 4, 34, 68, 1);
INSERT INTO Rezultaty VALUES(32, 204, 4, 11, 27.5, 0);
INSERT INTO Rezultaty VALUES(125, 214, 4, 15, 37.5, 1);
INSERT INTO Rezultaty VALUES(14, 302, 6, 8, 20, 0);
INSERT INTO Rezultaty VALUES(652, 303, 6, 42, 84, 1);
INSERT INTO Rezultaty VALUES(7, 304, 6, 30, 75, 1);
INSERT INTO Rezultaty VALUES(425, 402, 6, 31, 77.5, 1);

--Punkty
INSERT INTO Punkty Values(207, 1, 4, "brak rysunku", 5);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(207, 2, 4, 5);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(207, 3, 7, 5);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(207, 4, 6, 5);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(207, 5, 0, 5);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(207, 6, 8, 5);
INSERT INTO Punkty Values(207, 1, 1, "Za dane", 5);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 1, 3, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 2, 6, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 3, 0, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 4, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 5, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 6, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 7, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 8, 0, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 9, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 10, 0, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 11, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 12, 6, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 13, 4, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(11, 14, 0, 1);
INSERT INTO Punkty Values(11, 15, 19, ", 12- zawarte informacje", 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 1, 3, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 2, 6, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 3, 0, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 4, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 5, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 6, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 7, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 8, 0, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 9, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 10, 0, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 11, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 12, 6, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 13, 4, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(652, 14, 0, 1);
INSERT INTO Punkty Values(652, 15, 19, ", 12- zawarte informacje", 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 1, 3, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 2, 6, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 3, 0, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 4, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 5, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 6, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 7, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 8, 0, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 9, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 10, 0, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 11, 1, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 12, 0, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 13, 4, 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(19, 14, 0, 1);
INSERT INTO Punkty Values(19, 15, 15, "1-poprawnosc jezykowa, 2- ortografia, 10- zawarte informacje", 1);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 25, 0, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 21, 2, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 22, 3, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 23, 3, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 24, 5, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 25, 7, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 21, 0, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 22, 3, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 23, 3, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 24, 0, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 25, 7, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 21, 2, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 22, 3, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 23, 3, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 24, 5, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 25, 0, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 21, 0, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 22, 0, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 23, 0, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 24, 0, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 25, 7, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 21, 2, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 22, 3, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 23, 3, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 24, 5, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 25, 0, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 21, 0, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 22, 0, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 23, 0, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 24, 0, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 1, 1, 6);
INSERT INTO Punkty Values(60, 2, 0, "Zaznaczono odpowiedz C", 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 3, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 4, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 5, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 6, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 7, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 8, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 9, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 10, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 11, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 12, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 13, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 14, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 15, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 16, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 17, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 18, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(60, 19, 1, 6);
INSERT INTO Punkty Values(60, 20, 0, "Zaznaczono odpowiedz B", 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 1, 1, 6);
INSERT INTO Punkty Values(425, 2, 0, "Zaznaczono odpowiedz C", 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 3, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 4, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 5, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 6, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 7, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 8, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 9, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 10, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 11, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 12, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 13, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 14, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 15, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 16, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 17, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 18, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(425, 19, 1, 6);
INSERT INTO Punkty Values(425, 20, 0, "Zaznaczono odpowiedz B", 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 1, 1, 6);
INSERT INTO Punkty Values(25, 2, 0, "Zaznaczono odpowiedz C", 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 3, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 4, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 5, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 6, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 7, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 8, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 9, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 10, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 11, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 12, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 13, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 14, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 15, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 16, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 17, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 18, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(25, 19, 1, 6);
INSERT INTO Punkty Values(25, 20, 0, "Zaznaczono odpowiedz B", 6);
INSERT INTO Punkty Values(14, 1, 0, "Odpowiedz B", 3);
INSERT INTO Punkty Values(14, 2, 0, "Odpowiedz C", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 3, 1, 3);
INSERT INTO Punkty Values(14, 4, 0, "Odpowiedz A", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 5, 1, 3);
INSERT INTO Punkty Values(14, 6, 0, "Odpowiedz D", 3);
INSERT INTO Punkty Values(14, 7, 0, "Odpowiedz C", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 8, 1, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 9, 1, 3);
INSERT INTO Punkty Values(14, 10, 0, "Odpowiedz D", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 11, 1, 3);
INSERT INTO Punkty Values(14, 12, 0, "Odpowiedz A", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 13, 1, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 14, 1, 3);
INSERT INTO Punkty Values(14, 15, 0, "Odpowiedz B", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 16, 0, 3);
INSERT INTO Punkty Values(14, 17, 0, "Odpowiedz B", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 18, 1, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(14, 19, 0, 3);
INSERT INTO Punkty Values(14, 20, 0, "Odpowiedz A", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 1, 1, 6);
INSERT INTO Punkty Values(20, 2, 0, "Zaznaczono odpowiedz C", 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 3, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 4, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 5, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 6, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 7, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 8, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 9, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 10, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 11, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 12, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 13, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 14, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 15, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 16, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 17, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 18, 1, 6);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(20, 19, 1, 6);
INSERT INTO Punkty Values(20, 20, 0, "Zaznaczono odpowiedz B", 6);
INSERT INTO Punkty Values(21, 1, 0, "Odpowiedz B", 3);
INSERT INTO Punkty Values(21, 2, 0, "Odpowiedz C", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 3, 1, 3);
INSERT INTO Punkty Values(21, 4, 0, "Odpowiedz A", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 5, 1, 3);
INSERT INTO Punkty Values(21, 6, 0, "Odpowiedz D", 3);
INSERT INTO Punkty Values(21, 7, 0, "Odpowiedz C", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 8, 1, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 9, 1, 3);
INSERT INTO Punkty Values(21, 10, 0, "Odpowiedz D", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 11, 1, 3);
INSERT INTO Punkty Values(21, 12, 0, "Odpowiedz A", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 13, 1, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 14, 1, 3);
INSERT INTO Punkty Values(21, 15, 0, "Odpowiedz B", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 16, 0, 3);
INSERT INTO Punkty Values(21, 17, 0, "Odpowiedz B", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 18, 1, 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(21, 19, 0, 3);
INSERT INTO Punkty Values(21, 20, 0, "Odpowiedz A", 3);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 1, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 2, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 3, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 4, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 5, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 6, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 7, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 8, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 9, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 10, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy)  Values(125, 11, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 12, 5, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 13, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 14, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 16, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 15, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(125, 17, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 1, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 2, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 3, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 4, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 5, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 6, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 7, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 8, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 9, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 10, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy)  Values(136, 11, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 12, 5, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 13, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 14, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 16, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 15, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(136, 17, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(36, 1, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(36, 2, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(36, 3, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(36, 4, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(36, 5, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(36, 6, 1, 2);
INSERT INTO Punkty Values(36, 7, 1, " Zaznaczon0 odpowiedz C", 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(36, 8, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(36, 9, 1, 2);
INSERT INTO Punkty Values(36, 10, 0, "Zaznaczono odpowiedz B", 2);
INSERT INTO Punkty Values(36, 11, 2, Nie ma jednej definicji", 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(36, 12, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(36, 13, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(36, 14, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(36, 16, 0, 2);
INSERT INTO Punkty Values(36, 15, 1, "Spelniono polowe wymagan", 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(36, 17, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 1, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 2, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 3, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 4, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 5, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 6, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 7, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 8, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 9, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 10, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy)  Values(34, 11, 3, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 12, 5, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 13, 4, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 14, 2, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 16, 6, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 15, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(34, 17, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(32, 1, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(32, 2, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(32, 3, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(32, 4, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(32, 5, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(32, 6, 1, 2);
INSERT INTO Punkty Values(32, 7, 1, " Zaznaczon0 odpowiedz C", 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(32, 8, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(32, 9, 1, 2);
INSERT INTO Punkty Values(32, 10, 0, "Zaznaczono odpowiedz D", 2);
INSERT INTO Punkty Values(32, 11, 2, Nie ma jednej definicji", 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(32, 12, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(32, 13, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(32, 14, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(32, 16, 0, 2);
INSERT INTO Punkty Values(32, 15, 1, "Spelniono polowe wymagan", 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(32, 17, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 1, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 2, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 3, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 4, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 5, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 6, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 7, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 8, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 9, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 10, 1, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy)  Values(7, 11, 3, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 12, 5, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 13, 4, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 14, 2, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 16, 6, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 15, 0, 2);
INSERT INTO Punkty([Nr egzaminu], [Nr zadania], Punkty, Oceniajacy) Values(7, 17, 0, 2);
