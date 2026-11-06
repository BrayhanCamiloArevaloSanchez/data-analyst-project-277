-- Cuenta el número total de clientes de la tabla customers.
SELECT COUNT(*) AS customers_count
FROM customers;

-- top_10_total_income.csv — los vendedores con mayor ingreso total
SELECT 
	CONCAT (e.first_name, ' ', e.last_name) AS seller, -- Concatena el nombre y el apellido de la tabla employees
	COUNT (s.sales_id) AS operations, -- cuenta la cantidad de ventas realizadas de la tabla sales
	FLOOR (SUM (p.price * s.quantity)) AS income -- saca la ganancia o ingresos redondeados hacia abajo
	--unión de tablas
  FROM employees e
	INNER JOIN sales s
	ON e.employee_id = s.sales_person_id
	INNER JOIN products p
	ON p.product_id = s.product_id
	GROUP BY seller --Agrupa por el nombre completo del vendedor
	ORDER BY income desc  --Ordena de mayor a menor por los ingresos generados
	LIMIT 10; --Solo muestra los 10 vendedores con mejores ingresos

-- lowest_average_income.csv — los vendedores con ingreso promedio más bajo
--CTE para identificar el promedio de los vendedores
WITH seller_averages AS (
    SELECT 
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        FLOOR(AVG(p.price * s.quantity)) AS average_income -- Determina el promedio de ingresos general
    FROM employees e
    INNER JOIN sales s ON e.employee_id = s.sales_person_id
    INNER JOIN products p ON p.product_id = s.product_id
    GROUP BY e.employee_id, e.first_name, e.last_name -- Agrupa por vendedor
)
  --Consulta principal
SELECT 
    seller,
    average_income
FROM seller_averages
WHERE average_income < (SELECT AVG(average_income) FROM seller_averages) -- hace una subconsulta para determinar los promedios inferiores al promedio general
ORDER BY average_income ASC; --Ordena de menor a mayor por promedio de ventas

--day_of_the_week_income.csv — resumen de ingresos por día de la semana
select  
	CONCAT (e.first_name, ' ', e.last_name) AS seller,
	to_char(s.sale_date, 'TMDay') as day_of_week, --extrae el nombre de la día de la semana de la fecha
	floor(SUM (p.price * s.quantity)) as income
	from employees e
	inner join sales s
	on e.employee_id = s.sales_person_id
	inner join products p 
	on p.product_id = s.product_id
	group by seller, day_of_week, EXTRACT(ISODOW FROM s.sale_date) --Agrupa por día de la semana y vendedor
	order by
    EXTRACT(ISODOW FROM s.sale_date) asc, --ordena por número de día de menor a mayor donde lunes es 1 y domingo es 7
    seller asc; --ordena alfabeticamente de menor a mayor (A-Z)


