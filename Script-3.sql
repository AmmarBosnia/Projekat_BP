-- Dodavanje subote i nedjelje
INSERT INTO Dan (NazivDana)
VALUES 
('Subota'),
('Nedjelja');

-- Dodavanje nove kolone u tabelu StavkaRasporeda za radni dan i vikend
ALTER TABLE StavkaRasporeda
ADD COLUMN RadniDan BOOLEAN,
ADD COLUMN Vikend BOOLEAN;


-- Postavljanje vrijednosti za radni dan i vikend prema danu u nedelji
UPDATE StavkaRasporeda
SET 
    RadniDan = CASE WHEN Dan_id
    IN (1, 2, 3, 4, 5) THEN 1 ELSE 0 END,
    Vikend = CASE WHEN Dan_id IN (6, 7) THEN 1 ELSE 0 END;
    
   
-- Dodavanje ograničenja da svaki profesor može imati samo jedan čas u jednom terminu
ALTER TABLE StavkaRasporeda
ADD CONSTRAINT jedan_profesor_jedan_termin UNIQUE (Profesor_id, Dan_id, VrijemePocetka, VrijemeZavrsetka);


-- Dodavanje ograničenja da samo jedan profesor može biti u jednoj učionici u određenom terminu
ALTER TABLE StavkaRasporeda
ADD CONSTRAINT jedan_profesor_jedna_ucionica UNIQUE (Ucionica_id, Dan_id, VrijemePocetka, VrijemeZavrsetka);


-- Dodavanje ograničenja za izbjegavanje kolizije (isti predmet u isto vreme u različitim učionicama)
ALTER TABLE StavkaRasporeda
ADD CONSTRAINT izbegni_kolizije UNIQUE (Dan_id, VrijemePocetka, VrijemeZavrsetka, Predmet_id);


-- Upit za dohvatanje informacija o rasporedu nastave sa svim gore navedednim uslovima
-- ti uslovi služe za izbjegavanje kolizija
SELECT 
    Raspored.Sifra AS RasporedSifra,
    Dan.NazivDana,
    CONCAT(StavkaRasporeda.VrijemePocetka, ' - ', StavkaRasporeda.VrijemeZavrsetka) AS Vrijeme,
    Ucionica.BrojUcionice,
    Predmet.NazivPredmeta,
    CONCAT(Profesor.Ime, ' ', Profesor.Prezime) AS ImePrezimeProfesora
FROM StavkaRasporeda
JOIN Raspored ON StavkaRasporeda.Raspored_id = Raspored.Raspored_id
JOIN Dan ON StavkaRasporeda.Dan_id = Dan.Dan_id
JOIN Ucionica ON StavkaRasporeda.Ucionica_id = Ucionica.Ucionica_id
JOIN Predmet ON StavkaRasporeda.Predmet_id = Predmet.Predmet_id
JOIN Profesor ON StavkaRasporeda.Profesor_id = Profesor.Profesor_id
WHERE StavkaRasporeda.RadniDan = 1;


-- Unos u tabelu Predmet
 INSERT INTO Predmet (Predmet_id, NazivPredmeta, Opis)
VALUES
  ('A2', 'Analiza II', 'Još redova i nizova'),
  ('AI', 'Analiza I', 'Redovi i nizovi'),
  ('PR2', 'Programiranje II', 'Uvod u CPP'),
  ('AL2', 'Algebra II', 'Teorija prstena'),
  ('LOG', 'Logika', 'Uvod u matematicku logiku');
  
 -- Unos u tabelu Profesor
INSERT INTO Profesor (Ime, Prezime, Titula_id)
VALUES
('Aleksandar', 'Balasev Samarski', 1),
('Almasa', 'Odzak', 1),
('Lamija', 'Sceta', 2),
('Manuela', 'Muzika Dizdarevic', 1);

DELIMITER //

CREATE PROCEDURE UnesiNovogProfesora(
    IN ime_profesora VARCHAR(255),
    IN prezime_profesora VARCHAR(255),
    IN titula_id INT
)
BEGIN
    -- Unos novog profesora
    INSERT INTO Profesor (Ime, Prezime, Titula_id) VALUES (ime_profesora, prezime_profesora, titula_id);

    -- Prikaz informacija o poslednjem unesenom profesoru
    SELECT * FROM Profesor WHERE Profesor_id = LAST_INSERT_ID();
END //

DELIMITER ;


-- IV ITERACIJA

-- 1. ZADATAK
-- Tabela TehnickeKarakteristike koja pohranjuje sljedece podatke: tabla, pametna tabla, projektor, racunarski centar...
CREATE TABLE TehnickeKarakteristike (
    Karakteristika_id INT AUTO_INCREMENT PRIMARY KEY,
    SifraKarakteristike VARCHAR(10) NOT NULL,
    NazivKarakteristike VARCHAR(255) NOT NULL
);

-- 2. ZADATAK
-- Veza izmedju tabela Ucionica i TehnickeKarakteristike
CREATE TABLE Ucionica_TehnickeKarakteristike (
    Ucionica_id INT,
    Karakteristika_id INT,
    PRIMARY KEY (Ucionica_id, Karakteristika_id),
    FOREIGN KEY (Ucionica_id) REFERENCES Ucionica(Ucionica_id),
    FOREIGN KEY (Karakteristika_id) REFERENCES TehnickeKarakteristike(Karakteristika_id)
);

-- 3. ZADATAK
-- Tabela PredmetPreduslovi, ova tabela je zapravo veza izmedju Predmeta i TehnickeKarakteristike
CREATE TABLE PredmetPreduslovi (
    Predmet_id VARCHAR(10),
    Karakteristika_id INT,
    PRIMARY KEY (Predmet_id, Karakteristika_id),
    FOREIGN KEY (Predmet_id) REFERENCES Predmet(Predmet_id),
    FOREIGN KEY (Karakteristika_id) REFERENCES TehnickeKarakteristike(Karakteristika_id)
);

-- 9. ZADATAK
-- Dodavanje datuma u tabelu StavkaRasporeda, tj. dodavanje datumske komponente
ALTER TABLE StavkaRasporeda
ADD COLUMN Datum DATE;

-- 4. ZADATAK
-- Postavljanje datuma za postojece stavke rasporeda
UPDATE StavkaRasporeda
SET Datum = '2023-11-01' -- posto sam tek dodao ovo polje Datum, sve stavke rasporeda sam setovao na 
                         -- 2023-11-01 kako bih imao neke vrijednosti u tabeli

-- Racunanje ukupnog zauzetog vremena u sedmici za aktivnosti po ucionicama
SELECT 
    Ucionica_id,
    SUM(TIMESTAMPDIFF(MINUTE, VrijemePocetka, VrijemeZavrsetka)) AS UkupnoVrijeme
FROM StavkaRasporeda
WHERE Datum = '2023-11-01'
GROUP BY Ucionica_id;

-- 5. ZADATAK
-- Lista zauzetosti na sedmicnom nivou grupisana po danima i ucionicama
SELECT 
    Dan_id,
    Ucionica_id,
    SUM(TIMESTAMPDIFF(MINUTE, VrijemePocetka, VrijemeZavrsetka)) AS UkupnoVrijeme
FROM StavkaRasporeda
GROUP BY Dan_id, Ucionica_id;

-- 6. ZADATAK
-- Procedura za provjeru da li je ucionica slobodna
CREATE FUNCTION ProvjeriSlobodnuUcionicu(
    ucionica_id INT,
    datum DATE,
    vrijemePocetka TIME,
    vrijemeZavrsetka TIME
)
RETURNS BOOLEAN
    RETURN NOT EXISTS (
        SELECT 1
        FROM StavkaRasporeda
        WHERE Ucionica_id = ucionica_id
            AND Datum = datum
            AND NOT (VrijemePocetka >= vrijemeZavrsetka OR VrijemeZavrsetka <= vrijemePocetka)
    );
   
-- Izlistavanje ucionica koje zadovoljavaju sve karakteristike potrebne za predmet
SELECT DISTINCT Ucionica_id
FROM Ucionica_TehnickeKarakteristike
WHERE Karakteristika_id IN (
    SELECT Karakteristika_id
    FROM PredmetPreduslovi
    WHERE Predmet_id = 'A3'
);

-- 8. ZADATAK
-- Izlistavanje ucionica koje posjeduju sve navedene tehnicke karakteristike
SELECT Ucionica_id
FROM Ucionica_TehnickeKarakteristike
WHERE Karakteristika_id IN (1, 2, 5)
GROUP BY Ucionica_id
HAVING COUNT(DISTINCT Karakteristika_id) = 3;
