CREATE DATABASE example;

USE example;

CREATE TABLE users(
id INT NOT NULL,
Name VARCHAR(20),
PRIMARY KEY(id)
);

INSERT INTO users(id, Name)  
VALUES (1, 'Kakorin Ilya');

INSERT INTO users(id, Name)  
VALUES (2, 'Orlov Denis');

