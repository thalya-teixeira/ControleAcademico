/*Criar banco de dados*/
CREATE DATABASE CursoAcademico;

USE CursoAcademico;

/*Criar tabelas*/
CREATE TABLE Aluno(
	RA int NOT NULL,
	Nome varchar(50) NOT NULL,
	CONSTRAINT PK_Aluno PRIMARY KEY (RA)
);

/*Populando a tabela*/
INSERT INTO Aluno (RA, Nome)
VALUES (1, 'Thalya'),
		(2, 'Vinicius'),
		(3, 'Louise'),
		(4, 'Pestana'),
		(5, 'Julia'),
		(6, 'Larissa'),
		(7, 'Gabi'),
		(8, 'Helo'),
		(9, 'Fernanda'),
		(10, 'Livia');

CREATE TABLE Disciplina(
	Sigla char(3) NOT NULL,
	Nome varchar(50) NOT NULL,
    Carga_Horaria int NOT NULL,
	CONSTRAINT PK_Disciplina PRIMARY KEY (Sigla)
);

/*Inserir as tabelas*/
INSERT INTO Disciplina (Sigla, Nome, Carga_Horaria)
    VALUES ('MAT', 'Matemática', 100),
		('ALG','Algebra', 100),
		('CA1', 'Calculo 1', 100),
		('CA2', 'Calculo 2', 100),
		('CA3', 'Calculo 3', 100),
		('CA4', 'Calculo 4', 100),
		('AOC', 'Arquitetura e Organização de Computadores', 80),
		('TRC', 'Tecnologias de Redes de Computadores', 80),
		('SBD', 'Segurança em Banco de Dados', 100),
		('TCC', 'Trabalho de Conclusão de Curso', 100);
       
CREATE TABLE Matricula(
	RA int NOT NULL,
    Sigla char(3) NOT NULL,
    Data_Ano int NOT NULL,
    Data_Semestre int NOT NULL,
    Falta int NULL,
    Nota_N1 float,
    Nota_N2 float,
    Nota_Sub float,
    Nota_Media float,
    Situacao bit,

	CONSTRAINT PK_Matricula PRIMARY KEY (RA, Sigla, Data_Ano, Data_Semestre),
	FOREIGN KEY (RA) REFERENCES Aluno(RA),
	FOREIGN KEY (Sigla) REFERENCES Disciplina(Sigla)
);

INSERT INTO Matricula (RA, Sigla, Data_Ano, Data_Semestre)
    VALUES ('1', 'AOC', 2021, 2),
	    ('2', 'TCC', 2021, 2),
		('5', 'SBD', 2021, 2),
		('3', 'SBD', 2021, 2),
		('4', 'AOC', 2021, 2),
		('7', 'ALG', 2021, 2)

/*Criar trigger*/
CREATE TRIGGER MEDIA
ON Matricula
AFTER UPDATE
AS
BEGIN
	DECLARE
	@Nota1 DECIMAL(10,1),
	@Nota2 DECIMAL(10,1),
	@Media DECIMAL(10,1),
	@Sub DECIMAL(10,1),
	@Ra int,
	@Sigla char(3),
	@Falta int,
	@Carga_Horaria int,
	@Situacao bit
	
	/* Atualiza a frequencia do aluno e situação*/
	SELECT @Nota1 = Nota_N1, @Nota2 = Nota_N2, @Ra = RA, @Sigla = Sigla, @Sub = Nota_Sub, @Falta = Falta FROM INSERTED
	SELECT @Carga_Horaria = Carga_Horaria FROM Disciplina WHERE Disciplina.Sigla = @Sigla
	UPDATE Matricula SET Situacao = 1
	WHERE RA = @Ra AND Sigla = @Sigla AND Falta < @Carga_Horaria * 0.25 AND Data_Ano = 2021	

	UPDATE Matricula SET Situacao = 0, Nota_Media = NULL
	WHERE RA = @Ra AND Sigla = @Sigla AND Falta > @Carga_Horaria * 0.25 AND Data_Ano = 2021	

	/*Atualiza todas as notas e situação do aluno*/
	SELECT @Nota1 = Nota_N1, @Nota2 = Nota_N2, @Ra = RA, @Sigla = Sigla, @Sub = Nota_Sub FROM INSERTED
	UPDATE Matricula SET Nota_Media = (@Nota1 + @Nota2) / 2
	WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 1
	
	SELECT @Media = Nota_Media, @Nota1 = Nota_N1, @Nota2 = Nota_N2, @Ra = RA, @Sigla = Sigla, @Sub = Nota_Sub FROM INSERTED
	UPDATE Matricula SET Nota_Media = (@Nota1 + @Sub) /2
	WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 1 AND Nota_Sub > 0 AND Nota_Media < 5 AND Nota_N1 > Nota_N2 OR Nota_N1 = Nota_N2 
	
	UPDATE Matricula SET Nota_Media = (@Nota2 + @Sub) /2
	WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 1 AND Nota_Sub > 0 AND Nota_Media < 5 AND Nota_N1 < Nota_N2
	
	UPDATE Matricula SET Situacao = 0
	WHERE RA = @Ra AND Sigla = @Sigla AND Nota_Media < 5 AND Data_Ano = 2021	

	/*Rematricula o aluno reprovado*/
	INSERT INTO Matricula(RA, Sigla, Data_Ano, Data_Semestre)
		(SELECT RA, Sigla, 2022, 2 FROM Matricula WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 0 )

END

/*para inserir as notas e faltas*/
UPDATE Matricula
	SET Nota_N1 = 10, Nota_N2 = 9, Falta = 10, Nota_Sub = 0
	WHERE RA = 1 AND Sigla = 'AOC'

UPDATE Matricula
	SET Nota_N1 = 8, Nota_N2 = 7, Falta = 10, Nota_Sub = 3
	WHERE RA = 2 AND Sigla = 'TCC'

UPDATE Matricula
	SET Nota_N1 = 0, Nota_N2 = 5.5, Falta = 70, Nota_Sub = 6.5
	WHERE RA = 3 AND Sigla = 'SBD'

UPDATE Matricula
	SET Nota_N1 = 5, Nota_N2 = 8.5, Falta = 20, Nota_Sub = 0
	WHERE RA = 4 AND Sigla = 'AOC'

UPDATE Matricula
	SET Nota_N1 = 7.5, Nota_N2 = 9, Falta = 10, Nota_Sub = 9
	WHERE RA = 5 AND Sigla = 'SBD'

UPDATE Matricula
	SET Nota_N1 = 4.5, Nota_N2 = 9, Falta = 50, Nota_Sub = 6
	WHERE RA = 7 AND Sigla = 'ALG'

/*Consultar cada tabela inteira*/
SELECT * FROM Aluno;

SELECT * FROM Disciplina;

SELECT * FROM Matricula;

/*Busca os alunos matriculados de uma determinada disciplina*/
SELECT a.RA, a.Nome AS 'Aluno', d.Nome 'Disciplina', m.Falta, m.Nota_N1, m.Nota_N2, m.Nota_Sub, m.Nota_Media, m.Situacao
	FROM Aluno a, Matricula m, Disciplina d
	WHERE a.RA = m.RA AND m.Sigla = d.Sigla AND m.Sigla = 'AOC'

/*busca o aluno pelo RA*/
SELECT a.RA, a.Nome AS 'Aluno', d.Nome 'Disciplina', m.Falta, m.Nota_N1, m.Nota_N2, m.Nota_Sub, m.Nota_Media, m.Situacao
	FROM Aluno a, Matricula m, Disciplina d
	WHERE a.RA = m.RA AND m.Sigla = d.Sigla AND a.RA = 1 AND Data_Ano = 2021

/*Busca alunos reprovados por nota*/
SELECT a.RA, a.Nome AS 'Aluno', d.Nome 'Disciplina', m.Falta, m.Nota_N1, m.Nota_N2, m.Nota_Sub, m.Nota_Media, m.Situacao
	FROM Aluno a, Matricula m, Disciplina d
	WHERE a.RA = m.RA AND m.Sigla = d.Sigla AND m.Situacao = 0 AND m.Nota_Media < 5


/*Alterar os dadas de um campo da tabela */
UPDATE Aluno SET Nome = 'Weslen' WHERE RA = 2;

UPDATE Disciplina SET Nome = 'Calculo Diferencial e Integral' WHERE Sigla = 'CA4';



