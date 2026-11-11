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
	lower (to_char(s.sale_date, 'TMDay')) as day_of_week, --extrae el nombre de la día de la semana de la fecha
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

-- age_groups.csv — grupos de edad
select 
	--Ordena los clientes por rangos de edad
	case 
		when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        when age > 40 then '40+'
	end as age_category,
	COUNT (*) as age_count -- Cuenta la cantidad según el rango de edad
	from customers
	group by age_category
	order by age_category asc;

-- customers_by_month.csv — clientes e ingresos por mes
select 
	to_char (s.sale_date, 'YYYY-MM') as selling_month, -- Convierte la fecha en formato año-mes
	count (distinct s.customer_id) as total_customers, --cuenta los clientes diferentes
	floor (SUM (s.quantity * p.price)) as income -- determina la cantidad de ganancia generada
	from sales s
	inner join products p
	on s.product_id = p.product_id
	group by selling_month agrupa por fecha
	order by selling_month;

-- special_offer.csv — clientes con su primera compra promocional
--CTE de primera compra
with first_purchases as (
    select
        s.customer_id,
        s.product_id,
        s.sale_date,
        s.sales_person_id,
	--enumera las compras partiendo desde el id del cliente y ordenandolas de la primera a la última
        row_number() over (
            partition by s.customer_id
            ORDER BY s.sale_date asc
        ) as purchase_number
    from sales s
)
	
--Consulta principal
select
    concat (c.first_name, ' ', c.last_name) as customer,
    fp.sale_date,
    concat (e.first_name, ' ', e.last_name) as seller
from first_purchases fp
inner join customers c
    on fp.customer_id = c.customer_id
inner join products p
    on fp.product_id = p.product_id
inner join employees e
    on fp.sales_person_id = e.employee_id
where fp.purchase_number = 1 and p.price = 0 --filtra por la primera venta de cada cliente en donde el precio es 0
order by customer;
