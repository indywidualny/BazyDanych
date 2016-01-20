CREATE DATABASE MATURA
GO
USE MATURA

DROP TABLE Egzaminy;
GO
DROP TABLE nauczyciele;
GO
DROP TABLE osoby;
GO
DROP TABLE [Rozklad Punktow];
GO
DROP TABLE rezultaty;
GO
DROP TABLE punkty;
GO
DROP TABLE szkoly;
GO
DROP TABLE uczniowie;
GO

CREATE TABLE Egzaminy (ID INTEGER Primary key,
Przedmiot VARCHAR(15) NOT NULL,
Poziom Bit not null,
Rok INTEGER not null,
Termin Bit not null default 0,
Punkty INTEGER not null,
[Ilosc zadan] INTEGER not null)

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
Haslo VARCHAR(50)  NOT NULL)

CREATE TABLE Szkoly (ID INTEGER PRIMARY KEY  IDENTITY(1,1),
[Nr Szkoly] INTEGER,
Nazwa VARCHAR(60) NOT NULL ,
Miasto VARCHAR(15) NOT NULL ,
Ulica VARCHAR(40) NOT NULL ,
[Kod pocztowy] INTEGER NOT NULL ,
Telefon INTEGER,
Dyrektor VARCHAR(50) NOT NULL ,
[Rok zalozenia] INTEGER)


CREATE TABLE Nauczyciele (ID INTEGER PRIMARY KEY  IDENTITY(1,1),
 PESEL INTEGER NOT NULL  CONSTRAINT FK_OSB REFERENCES Osoby(PESEL) ON DELETE CASCADE ,
Szkola INTEGER  CONSTRAINT FK_SZK REFERENCES Szkoly(ID) ON UPDATE CASCADE,
Staz INTEGER NOT NULL  DEFAULT 0,
Uprawnienia BIT NOT NULL  DEFAULT 0)

CREATE TABLE Uczniowie (ID INTEGER PRIMARY KEY  IDENTITY(1,1) ,
PESEL INTEGER NOT NULL CONSTRAINT FK_OSOBY REFERENCES Osoby(PESEL) ON DELETE CASCADE ,
Szkola INTEGER NOT NULL CONSTRAINT FK_SZKOLA REFERENCES Szkoly(ID),
Wychowawca INTEGER NOT NULL CONSTRAINT FK_NAUCZY REFERENCES Nauczyciele(ID) ON UPDATE CASCADE ,
[Rok rozpoczecia] DATE NOT NULL ,
[Rok zakonczenia] DATE)

CREATE TABLE Rezultaty ([Nr egzaminu] INTEGER PRIMARY KEY,
Egzamin INTEGER NOT NULL CONSTRAINT FK_EGZAM REFERENCES EGZAMINY(ID)  ON UPDATE CASCADE,
Zdajacy INTEGER NOT NULL  CONSTRAINT FK_ZDAJ REFERENCES UCZNIOWIE(ID) ON DELETE CASCADE,
Wynik INTEGER,
[Wynik proc] FLOAT,
Zdany BIT NOT NULL  DEFAULT 0)

CREATE TABLE Punkty ([Nr egzaminu] INTEGER NOT NULL CONSTRAINT FK_REZULT REFERENCES REZULTATY([Nr egzaminu])  ON DELETE CASCADE,
[Nr zadania] INTEGER NOT NULL ,
Punkty FLOAT NOT NULL  DEFAULT 0,
[Opis oceny] TEXT,
Ocenuajacy INTEGER NOT NULL CONSTRAINT  FK_OCEN REFERENCES NAUCZYCIELE(ID),
PRIMARY KEY ([Nr egzaminu], [Nr zadania]))

CREATE TABLE [Rozklad Punktow] (Egzamin INTEGER NOT NULL CONSTRAINT FK_EGZ REFERENCES EGZAMINY(ID) ON UPDATE CASCADE ,
[Nr zadania] INTEGER NOT NULL ,
[Max pkt] INTEGER NOT NULL ,
Przyznawanie TEXT NOT NULL ,
PRIMARY KEY (Egzamin, [Nr zadania]))


CREATE PROCEDURE nowaOsoba @Imie varchar(15), @Drugie varchar(15), @Nazwisko varchar(40),
	@Data date, @Ulica varchar(30), @Nr_domu varchar(4), @Nr_mieszkania varchar(4),
	@Kod integer, @Miasto varchar(15),@PESEL integer, @Telefon Integer, @uczen bit,
	@Szkola varchar(60), @Wychowawca integer, @Poczatek Date, @upr bit, @Nr integer,
	@UlicaS varchar(40), @MiastoS varchar(15), @KodS integer, @Dyrektor varchar(50), @Rok integer
AS
	Insert Into Osoby Values(@PESEL, @Imie, @Drugie, @Nazwisko, @Data, @Ulica, @Nr_domu, @Nr_mieszkania, @Miasto, @Kod, @Telefon, @PESEL);
	DECLARE @Szkola_id integer
	IF (SELECT COUNT(*) FROM Szkoly WHERE Nazwa = @Szkola)=0
		INSERT INTO Szkoly("Nr Szkoly", Nazwa, Miasto, Ulica, "Kod pocztowy", Dyrektor, "Rok zalozenia") VALUES(@Nr, @Szkola,
			@MiastoS, @UlicaS, @KodS, @Dyrektor, @Rok);
	SET @Szkola_id=(SELECT ID FROM Szkoly WHERE Nazwa=@Szkola);
	IF @uczen=1
		INSERT INTO Uczniowie(PESEL, Szkola, Wychowawca, "Rok rozpoczecia" ) Values(@Pesel, @Szkola_id, @Wychowawca, @Poczatek);
	IF @uczen=0
		INSERT INTO Nauczyciele(Pesel, Szkola, Staz, Uprawnienia) Values(@Pesel, @Szkola_id, @Wychowawca, @upr);

--nie wiem dlaczego nie dziala
CREATE PROCEDURE noweZadanie @Egz integer, @Przedmiot varchar(15), @Poziom bit, @Rok integer, @Termin bit, @zadanie integer,
				@max integer, @opis text, @Punkty integer, @Ilosc integer
AS
	IF (SELECT COUNT(*) FROM Egzaminy WHERE ID=@Egz) =0
		INSERT INTO Egzaminy VALUES(@Egz, @Przedmiot, @Poziom, @Rok, @Punkty, @Ilosc);
	INSERT INTO [Rozklad Punktow] VALUES(@Egz, @zadanie, @max, @opis);
--nie wiem czemu nie dzia³a
CREATE PROCEDURE nowyEgzamin @Egz integer, @Przedmiot varchar(15), @Poziom bit, @Rok integer, @Termin bit, @Punkty integer, @Ilosc integer
AS
	INSERT INTO Egzaminy VALUES(@Egz, @Przedmiot, @Poziom, @Rok, @Punkty, @Ilosc);

CREATE PROCEDURE nowaSzkola @Nr INTEGER, @Nazwa VARCHAR(60), @Miasto VARCHAR(15) , @Ulica VARCHAR(40), @Kod INTEGER,
				@Telefon INTEGER, @Dyrektor VARCHAR(50), @Rok INTEGER
AS
	INSERT INTO Szkoly("Nr Szkoly", Nazwa, Miasto, Ulica, "Kod pocztowy", Telefon, Dyrektor, "Rok zalozenia") VALUES(@Nr, @Nazwa, @Miasto,
		@Ulica, @Kod, @Telefon, @Dyrektor, @Rok);

CREATE PROCEDURE wstawPunkty @egz integer, @egzamin integer, @PESEL integer, @zadanie integer, @punkty float, @opis text,
				@oceniajacy integer, @wynik integer, @zdany bit
AS
	IF (SELECT COUNT(*) FROM Rezultaty WHERE "Nr egzaminu"=@egzamin)=0
		EXEC 	wstawRezultat @egzamin, @egz, @PESEL, @wynik, @zdany;
	INSERT INTO Punkty Values(@egzamin, @zadanie, @punkty, @opis, @oceniajacy);

CREATE PROCEDURE wstawRezultat @egz integer, @egzamin integer, @PESEL integer, @wynik integer, @zdany bit
AS
	DECLARE @proc float
	DECLARE @Id integer
	SET @proc=@wynik*100.0/(SELECT Punkty FROM Egzamin WHERE ID =@egzamin)
	SET @Id = (SELECT ID FROM Uczniowie WHERE PESEL= @PESEL)
	INSERT INTO Rezultaty VALUES(@egz, @egzamin, @Id, @wynik, @proc, @zdany);
--nie dziala
CREATE VIEW statEgzamin AS
SELECT E.Rok, E.Przedmiot, E.Poziom, (E.Termin)+1 As Termin,  COUNT(R.Zdajacy) AS [Ilosc zdajacych],
AVG(R.Wynik) AS [Sredni wynik], AVG(R.[Wynik proc]) AS [Sredni wynik %], SUM(R.Zdany)*100.0/COUNT(R.Zdajacy) AS [Zdawalnosc]
FROM Egzaminy E JOIN Rezultaty R ON E.ID= R.Egzamin GROUP BY E.ID ORDER BY E.Rok, E.Przedmiot

--nie dziala
CREATE VIEW statUczen AS
SELECT O.Pierwsze_imie, O.Nazwisko, COUNT(R.[Nr egzaminu]) AS [Ilosc egzaminow], COUNT(R.Zdany) AS [Zdane], AVG(R.[Wynik proc]) AS [Sredni wynik %]
FROM Osoby O, Uczniowie U JOIN Rezultaty R ON U.ID=R.Zdajacy where O.PESEL=U.PESEL GROUP BY U.ID

CREATE VIEW statPrzedmiot AS
SELECT E.Przedmiot, AVG(R.[Wynik proc]) AS [Sredni wynik %], COUNT(R.Zdajacy) AS [Ilosc egzaminow],
(SElect COUNT(Zdany)from Rezultaty where Zdany=1) AS [Ilosc zaliczonych], (SElect COUNT(Zdany)from Rezultaty where Zdany=1)*100.0/COUNT(R.Zdajacy) AS [Zdawalnosc]
FROM Egzaminy E JOIN Rezultaty R ON E.ID= R.Egzamin GROUP BY E.Przedmiot


--co jest nie tak
CREATE VIEW statNauczyciel AS
SELECT O.Pierwsze_Imie, O.nazwisko, COUNT(R.Zdany)/COUNT(R.[Nr egzaminu])*100.0 AS [Skutecznosc]
FROM Osoby O, Nauczyciele N, Uczniowie U  JOIN Rezultaty R ON R.Zdajacy=U.ID
WHERE N.PESEL=O.PESEL AND U.Wychowawca=N.ID GROUP BY N.PESEL

--co jest nie tak
CREATE 	VIEW statSzkola AS
SELECT S.Nazwa, S.[Nr Szkoly], S.Miasto, COUNT(R.Zdany)/COUNT(R.[Nr egzaminu])*100.0 AS [Zdawalnosc]
FROM Szkoly S, Uczniowie U  JOIN Rezultaty R ON R.Zdajacy=U.ID where S.ID=U.Szkola GROUP BY S.ID

CREATE VIEW statMiasto AS
SELECT Miasto, Zdawalnosc FROM statSzkola GROUP BY Miasto

--trigery minimum 5
/* dziala
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
AFTER DELETE
AS
	DELETE FROM Rezultaty WHERE Egzamin IN (SELECT ID FROM deleted)
	DELETE FROM [Rozklad Punktow] WHERE Egzamin IN (SELECT ID FROM deleted)
	PRINT('Pomyslnie usunieto egzamin.')

*/


/*   TEGO NIE JESTEM PEWNA JAK DOKONCZYC
CREATE TRIGGER usuwanieRozkladu ON [Rozklad Punktow]
AFTER DELETE
AS
	DELETE FROM Punkty WHERE [Nr egzaminu] IN (SELECT [Nr egzaminu] FROM Rezultaty WHERE Egzamin IN (SELECT Egzamin FROM deleted))
*/
COMMIT