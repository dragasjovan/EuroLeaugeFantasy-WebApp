create database fantazija2
use fantazija2


create table ekipa (
	ID_ekipe int IDENTITY(1,1) PRIMARY KEY,
	Ime_ekipe varchar(20) not null,
	Krediti int not null,
	Bodovi int not null,
	ID_korisnika int not null,
	FOREIGN KEY (ID_korisnika) REFERENCES korisnik(ID),
)

create table korisnik (
	ID int IDENTITY(1,1) PRIMARY KEY,
	Ime_Korisnika varchar(255) not null,
	Email varchar(255) not null,
	Lozinka varchar(255) not null,
	Datum_registracije date,
)

create table liga (
	ID_lige int IDENTITY(1,1) PRIMARY KEY,
	Ime_lige varchar(255) not null,
	Pristupni_kod varchar(255) not null
)

create table ekipa_liga (
	ID_ekipe int,
	ID_lige int,
	PRIMARY KEY(ID_ekipe, ID_lige),
	FOREIGN KEY (ID_ekipe) REFERENCES ekipa(ID_Ekipe),
	FOREIGN KEY (ID_lige) REFERENCES liga(ID_lige),
)

create table tim (
	ID_tima int IDENTITY(1,1) PRIMARY KEY,
	Ime_tima varchar(255) not null,
	Grad varchar(255) not null,
	Trener varchar(255) not null
)

create table igraci (
	ID_igraca int IDENTITY(1,1) PRIMARY KEY,
	Ime varchar(255) not null,
	Prezime varchar(255) not null,
	Pozicija char not null check (Pozicija IN('G', 'F', 'C')),
	Cena int not null,
	ID_tima int,
	FOREIGN KEY (ID_tima) REFERENCES tim(ID_tima)
)

create table ekipa_igraci (
	ID_ekipe int,
	ID_igraca int,
	PRIMARY KEY(ID_ekipe, ID_igraca),
	FOREIGN KEY (ID_ekipe) REFERENCES ekipa(ID_Ekipe),
	FOREIGN KEY (ID_igraca) REFERENCES igraci(ID_igraca),
)

go
CREATE PROCEDURE korisnik_insert
    @ime VARCHAR(255),
    @email VARCHAR(255),
    @lozinka VARCHAR(255)
AS
BEGIN
    SET LOCK_TIMEOUT 3000;
    BEGIN TRY
        IF EXISTS (SELECT TOP 1 korisnik.Email FROM korisnik WHERE korisnik.Email = @email)
            RETURN 1;
        ELSE
        BEGIN
            INSERT INTO korisnik (Ime_Korisnika, Email, Lozinka, Datum_registracije)
            VALUES (@ime, @email, @lozinka, GETDATE());

            DECLARE @NoviID INT;
            SET @NoviID = SCOPE_IDENTITY();
        END
    END TRY
    BEGIN CATCH
		RETURN @@ERROR;
    END CATCH;
END;
go

go
create proc korisnik_update
	@ime varchar(255),
	@email varchar(255)
as
begin
	set lock_timeout 3000;
	begin try
		if exists (select top 1 korisnik.Email from korisnik
		 where korisnik.Email = @email)
		 begin
			update korisnik
			set korisnik.Ime_Korisnika = @ime where korisnik.Email = @email;
			return 0;
		 end
		 return -1;
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
create proc korisnik_delete
	@email varchar(255)
as
begin
	set lock_timeout 3000;
	declare @pom int
	declare @pom1 int
	begin try
		set @pom = (select ID from korisnik where korisnik.Email = @email)
		set @pom1 = (select ID_ekipe from ekipa where ekipa.ID_korisnika = @pom)
		delete from ekipa_igraci where ekipa_igraci.ID_ekipe = @pom1;
		delete from ekipa where ekipa.ID_korisnika = @pom;
		delete from korisnik where korisnik.Email = @email;
		return 0;
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
create proc tim_insert
	@ime varchar(255),
	@grad varchar(255),
	@trener varchar(255)
as
begin
	set lock_timeout 3000;
	begin try
		if exists (select top 1 tim.Ime_tima from tim
		where tim.Ime_tima = @ime)
		return 1;
		else
		insert into tim(Ime_tima, Grad, Trener)
		values(@ime, @grad, @trener)
		return 0;
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
create proc tim_update
	@ime varchar(255),
	@grad varchar(255),
	@trener varchar(255)
as
begin
	set lock_timeout 3000;
	begin try
		if exists (select top 1 tim.Ime_tima from tim
		where tim.Ime_tima = @ime)
		begin
			update tim
			set tim.Grad = @Grad where tim.Ime_tima = @ime;
			update tim
			set tim.Trener = @trener where tim.Ime_tima = @ime;
			return 0;
		end
		return -1;
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
create proc tim_delete
	@ime varchar(255)
as
begin
	set lock_timeout 3000;
	declare @pom int;
	declare @pom1 int;
	begin try
	set @pom1 = (select ID_tima from tim where Ime_tima = @ime)
	set @pom = (select ID_igraca from igraci where ID_tima = @pom1)
		delete from ekipa_igraci where ID_igraca = @pom;
		delete from igraci where ID_tima = @pom1;
		delete from tim where tim.Ime_tima = @ime
		return 0;
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
create proc liga_insert
	@ime varchar(255),
	@kod varchar(255)
as
begin
	set lock_timeout 3000;
	begin try
		if exists (select top 1 liga.Pristupni_kod from liga
		where liga.Pristupni_kod = @kod)
		return 1;
		else
		insert into liga(Ime_lige, Pristupni_kod)
		values (@ime, @kod);
		return 0;
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
create proc liga_update
	@ime varchar(255),
	@kod varchar(255)
as
begin
	set lock_timeout 3000;
	begin try
		if exists (select top 1 liga.Pristupni_kod from liga
		where liga.Pristupni_kod = @kod)
		begin
			update liga
			set liga.Ime_lige = @ime where liga.Pristupni_kod = @kod;
			return 0;
		end
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
create proc liga_delete
	@kod varchar(255)
as
begin
	set lock_timeout 3000;
	begin try
		delete from liga where liga.Pristupni_kod = @kod;
		return 0;
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
create proc ekipa_insert
	@email varchar(255),
	@ime varchar(255),
	@krediti int,
	@bodovi int,
	@fk int
as
begin
	set lock_timeout 3000;
	begin try
		if exists (select top 1 ekipa.ID_korisnika, korisnik.ID from ekipa
		inner join korisnik on ekipa.ID_korisnika = korisnik.ID
		where korisnik.Email = @Email)
		return 1;
		else
		insert into ekipa(Ime_ekipe, Krediti, Bodovi, ID_korisnika)
		values (@ime, @krediti, @bodovi, @fk);
		return 0;
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
create proc ekipa_update
	@ime varchar(255),
	@krediti varchar(255),
	@bodovi varchar(255)
as
begin
	set lock_timeout 3000;
	begin try
		if exists (select top 1 ekipa.Ime_ekipe from ekipa
		where ekipa.Ime_ekipe = @ime)
		begin
			update ekipa
			set ekipa.Krediti = @krediti where ekipa.Ime_ekipe = @ime;
			update ekipa
			set ekipa.Bodovi = @bodovi where ekipa.Ime_ekipe = @ime;
			return 0;
		end
		return -1;
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
create proc ekipa_delete
	@ime varchar(255)
as
begin
	set lock_timeout 3000;
	begin try
		delete from ekipa where ekipa.Ime_ekipe = @ime;
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
create proc igrac_insert
	@tim varchar(255),
	@ime varchar(255),
	@prezime varchar(255),
	@pozicija varchar(1),
	@cena int
as
begin
	set lock_timeout 3000;
	declare @fk int
	begin try
		set @fk = (select tim.ID_tima from tim where tim.Ime_tima = @tim);
		insert into igraci(Ime, Prezime, Pozicija, Cena, ID_tima)
		values (@ime, @prezime, @pozicija, @cena, @fk);
		PRINT '@fk = ' + CAST(@fk AS VARCHAR(10)); 
		return 0;
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
create proc igrac_update
	@ime varchar(255),
	@prezime varchar(255),
	@pozicija varchar,
	@cena int
as
begin
	set lock_timeout 3000;
	begin try
		if exists (select top 1 igraci.Ime, igraci.Prezime from igraci
		where igraci.Ime= @ime and igraci.prezime = @prezime)
		begin
			update igraci
			set igraci.Pozicija = @pozicija where igraci.Ime= @ime and igraci.prezime = @prezime;
			update igraci
			set igraci.Cena = @cena where igraci.Ime= @ime and igraci.prezime = @prezime;
			return 0;
		end
		return -1;
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
create proc igrac_delete
	@ime varchar(255),
	@prezime varchar(255)
as
begin
	declare @pom int;
	begin try
		set @pom = (select ID_igraca from igraci where igraci.Ime= @ime and igraci.prezime = @prezime)
		delete from ekipa_igraci where ID_igraca = @pom;
		delete from igraci where igraci.Ime= @ime and igraci.prezime = @prezime;
	end try
	begin catch
		return @@ERROR;
	end catch
end
go

go
INSERT INTO tim (Ime_tima, Grad, Trener) VALUES 
('Anadolu Efes', 'Istanbul', 'Ergin Ataman'),
('FC Barcelona', 'Barcelona', 'Sarunas Jasikevicius'),
('AX Armani Exchange Milan', 'Milan', 'Ettore Messina'),
('Olympiacos Piraeus', 'Piraeus', 'Kestutis Kemzura'),
('Real Madrid', 'Madrid', 'Pablo Laso'),
('CSKA Moscow', 'Moscow', 'Dimitris Itoudis'),
('Fenerbahce Beko Istanbul', 'Istanbul', 'Igor Kokoskov'),
('Maccabi Playtika Tel Aviv', 'Tel Aviv', 'Ioannis Sfairopoulos'),
('Zenit St Petersburg', 'St Petersburg', 'Xavi Pascual'),
('LDLC ASVEL Villeurbanne', 'Villeurbanne', 'T.J. Parker');
go

go
INSERT INTO igraci (Ime, Prezime, Pozicija, Cena, ID_tima) VALUES
('Shane', 'Larkin', 'G', 12, 1),
('Vasilije', 'Micic', 'G', 11, 1),
('Krunoslav', 'Simon', 'F', 10, 1),
('Bryant', 'Dunston', 'C', 9, 1),

-- FC Barcelona
('Nikola', 'Mirotic', 'F', 14, 2),
('Alex', 'Abrines', 'G', 10, 2),
('Brandon', 'Davies', 'C', 9, 2),
('Nigel', 'Hayes', 'F', 8, 2),

-- AX Armani Exchange Milan
('Malcolm', 'Delaney', 'G', 13, 3),
('Shavon', 'Shields', 'F', 11, 3),
('Zach', 'LeDay', 'F', 10, 3),
('Kaleb', 'Tarczewski', 'C', 8, 3),

-- Olympiacos Piraeus
('Vassilis', 'Spanoulis', 'G', 14, 4),
('Kostas', 'Sloukas', 'G', 12, 4),
('Hassan', 'Martin', 'F', 11, 4),
('Aaron', 'Harrison', 'G', 9, 4),

-- Real Madrid
('Sergio', 'Llull', 'G', 14, 5),
('Walter', 'Tavares', 'C', 13, 5),
('Rudy', 'Fernandez', 'F', 10, 5),
('Jeffery', 'Taylor', 'F', 9, 5),

-- CSKA Moscow
('Mike', 'James', 'G', 15, 6),
('Nikita', 'Kurbanov', 'F', 11, 6),
('Darrun', 'Hilliard', 'F', 10, 6),
('Joel', 'Bolomboy', 'C', 8, 6),

-- Fenerbahce Beko Istanbul
('Nando', 'De Colo', 'G', 14, 7),
('Jan', 'Vesely', 'F', 12, 7),
('Edgaras', 'Ulanovas', 'F', 10, 7),
('Jarell', 'Eddie', 'F', 9, 7),

-- Maccabi Playtika Tel Aviv
('Scottie', 'Wilbekin', 'G', 14, 8),
('Othello', 'Hunter', 'C', 12, 8),
('Tyler', 'Dorsey', 'G', 11, 8),
('Angelo', 'Caloiaro', 'F', 9, 8),

-- Zenit St Petersburg
('Kevin', 'Pangos', 'G', 13, 9),
('Will', 'Thomas', 'F', 12, 9),
('Alex', 'Poythress', 'F', 10, 9),
('Arturas', 'Gudaitis', 'C', 8, 9),

-- LDLC ASVEL Villeurbanne
('Norris', 'Cole', 'G', 13, 10),
('Moustapha', 'Fall', 'C', 12, 10),
('David', 'Lighty', 'F', 10, 10),
('Guerschon', 'Yabusele', 'F', 9, 10);
go

select * from korisnik
select * from ekipa

exec korisnik_delete '3'
select * from igraci

