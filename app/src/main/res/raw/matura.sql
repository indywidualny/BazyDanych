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
Haslo VARCHAR(50)  NOT NULL);

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
SELECT O.Pierwsze_imie, O.Nazwisko, COUNT(R.[Nr egzaminu]) AS [Ilosc egzaminow], COUNT(R.Zdany) AS [Zdane], AVG(R.[Wynik proc]) AS [Sredni wynik %]
FROM Osoby O, Uczniowie U JOIN Rezultaty R ON U.ID=R.Zdajacy where O.PESEL=U.PESEL GROUP BY U.ID

CREATE VIEW statPrzedmiot AS
SELECT E.Przedmiot, AVG(R.[Wynik proc]) AS [Sredni wynik %], COUNT(R.Zdajacy) AS [Ilosc egzaminow],
(SElect COUNT(Zdany)from Rezultaty where Zdany=1) AS [Ilosc zaliczonych], (SElect COUNT(Zdany)from Rezultaty where Zdany=1)*100.0/COUNT(R.Zdajacy) AS [Zdawalnosc]
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

