CREATE DATABASE devops_test_db;
GO

USE devops_test_db;
GO

CREATE TABLE employees (id INT PRIMARY KEY,name VARCHAR(100),role VARCHAR(100)); 
GO

INSERT INTO employees (id, name, role) VALUES (1, 'Youssef', 'DevOps Engineer'),(2, 'Moghazy', 'Cloud Engineer');
GO

SELECT * FROM employees;
GO
