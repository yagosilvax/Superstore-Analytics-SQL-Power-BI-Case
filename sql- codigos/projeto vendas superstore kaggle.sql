--Importando dados CSV:
CREATE TABLE superstore_sales(
row_id text,
order_id text,
order_date date,
ship_date date,
ship_mode text,
customer_id text,
customer_name text,
segment text,
country text,
city text,
"state" text,
postal_code text,
region text,
product_id text,
category text,
sub_category text,
product_name text,
sales text

)
COPY superstore_sales(
row_id,
order_id,
order_date,
ship_date,
ship_mode,
customer_id,
customer_name,
segment,
country,
city,
"state",
postal_code,
region,
product_id,
category,
sub_category,
product_name,
sales)

FROM 'C:\Dados\Projetos pra portifolio\train.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
)

--Verificando se existem duplicatas:

WITH duplicados as(
	SELECT 
		*,
		ROW_NUMBER() OVER(partition by row_id ORDER BY row_id) as rn
	FROM superstore_sales 
)
SELECT * FROM duplicados WHERE rn > 1



SELECT 
    order_id, customer_id, product_id, order_date, sales, COUNT(*)
FROM superstore_sales
GROUP BY order_id, customer_id, product_id, order_date, sales
HAVING COUNT(*) > 1


--Verificando nulos:
SELECT 
	*
FROM superstore_sales
WHERE NOT(superstore_sales IS NOT NULL)


--Modelagem de dados

--Clientes
CREATE VIEW vw_dcliente as

	SELECT DISTINCT
		customer_id as id_cliente,
		customer_name as nome_cliente,
		segment as segmento
	FROM superstore_sales
	
--Região

CREATE OR REPLACE VIEW vw_dregiao as
	SELECT DISTINCT
		COALESCE(postal_code,'00000') as codigo_postal,
		country as pais,
		city as cidade,
		state as estado,
		region as regiao
	FROM superstore_sales


--Produtos
CREATE VIEW vw_dproduto as
	SELECT 
		DISTINCT product_id,
		product_name,
		category,
		sub_category
	FROM superstore_sales

--Vendas
CREATE OR REPLACE VIEW vw_fatvendas as

WITH fato_limpa as(
	SELECT 
		order_date,
		ship_date,
		(ship_date - order_date)::int as qtde_dias_envio,
		ship_mode as modo_envio,
		order_id,
		customer_id as id_cliente,
		product_id as id_produto,
		COALESCE(postal_code,'00000') as codigo_postal,
		sales::float as venda,
		ROW_NUMBER() OVER(partition by order_id, customer_id, product_id, order_date, sales 
		ORDER BY row_id) as rn
	FROM superstore_sales)

SELECT * FROM fato_limpa WHERE rn = 1

SELECT MAX(order_date), min(order_date) from superstore_sales

