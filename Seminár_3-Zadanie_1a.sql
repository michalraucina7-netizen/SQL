CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100)
);

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) REFERENCES customers(customer_id),
    product_id VARCHAR(20) REFERENCES products(product_id),
    order_date DATE,
    ship_date DATE,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(10,2),
    profit DECIMAL(10,2)
);



/*
Úloha 1
Vytvorte databázový pohľad high_value_customers nad databázou superstore, ktorý bude poskytovať pripravený prehľad zákazníkov 
s celkovou hodnotou predaja vyššou ako 2 000.

Pohľad vytvorte nad tabuľkami customers a orders.

Vo výsledku pohľadu zobrazte:

identifikátor zákazníka (customer_id),
meno zákazníka (customer_name),
celkovú hodnotu jeho nákupov ako total_sales.
Pri výpočte najskôr prepojte zákazníkov s objednávkami, následne zoskupte údaje podľa zákazníka a vypočítajte jeho celkový predaj.

Do pohľadu zahrňte iba zákazníkov, ktorých výsledná hodnota total_sales je vyššia ako 2 000.

Po vytvorení pohľadu overte jeho obsah pomocou dotazu:

SELECT *
FROM high_value_customers;
Koľko zákazníkov sa nachádza vo vytvorenom pohľade high_value_customers? Do odpovede zadajte iba počet.*/

CREATE VIEW  high_value_customers AS
SELECT c.customer_id, c.customer_name, SUM(o.sales) AS total_sales
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.sales) > 2000; /*nezabúdať v postgre mi to nešlo lebo treba dať celé SUM(o.sales) a nie len total_sales*/

SELECT * FROM high_value_customers; /*boli 4*/

/*Vytvorte databázový pohľad regional_monthly_sales nad databázou superstore,
 ktorý bude poskytovať mesačný súhrn predaja pre jednotlivé regióny.

Pohľad vytvorte nad tabuľkami customers a orders.

Vo výsledku pohľadu zobrazte:

región zákazníka,
mesiac objednávky ako month,
celkový predaj za daný región a mesiac ako monthly_sales.
Na zoskupenie dát podľa mesiaca použite funkciu DATE_TRUNC().

Ktorá z nasledujúcich tabuliek zodpovedá výsledku dotazu pre región West?*/

CREATE OR REPLACE VIEW regional_monthly_sales AS /*OR REPLACE robím aby som sa vyhol errorom*/
SELECT c.region, DATE_TRUNC('MONTH',o.order_date) AS MONTH, SUM(o.sales) AS monthly_sales
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.region, DATE_TRUNC('MONTH',o.order_date)

/*Vytvorte databázový pohľad analyst_orders nad databázou superstore, 
ktorý bude analytikom poskytovať údaje o objednávkach, ale nebude obsahovať informáciu o zisku.

Pohľad vytvorte nad tabuľkou orders.

Vo výsledku pohľadu sprístupnite iba nasledujúce stĺpce:

order_id,
customer_id,
product_id,
sales,
quantity,
discount.
Stĺpec profit sa vo vytvorenom pohľade nesmie nachádzať.

Po vytvorení pohľadu overte jeho obsah:

SELECT *
FROM analyst_orders;
Predpokladajme, že používateľ analyst má povolený SELECT nad pohľadom analyst_orders. Ktoré tvrdenie najpresnejšie opisuje, 
čo ešte musí byť splnené, aby používateľ nemohol získať hodnoty stĺpca profit priamo zo zdrojovej tabuľky orders?*/

CREATE OR REPLACE VIEW analyst_orders AS
SELECT order_id, customer_id, product_id, sales, quantity, discount
FROM orders 

/*Vytvorte index nad stĺpcom customer_id v tabuľke orders v databáze superstore.

Cieľom je pripraviť databázu na efektívnejšie vyhľadávanie objednávok konkrétneho zákazníka.

Index pomenujte:

idx_orders_customer_id
Po vytvorení indexu zobrazte všetky objednávky zákazníka s identifikátorom C001.

Ktoré tvrdenie najlepšie opisuje vzťah medzi vytvoreným indexom a plánom vykonania dotazu?*/

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
SELECT * 
FROM orders 
WHERE customer_id = 'C001';

/*Vytvorte index nad stĺpcom order_date v tabuľke orders v databáze superstore.

Index pomenujte:

idx_orders_order_date
Následne vytvorte SQL dotaz, ktorý vypočíta celkový predaj za jednotlivé mesiace.

Vo výsledku zobrazte:

mesiac objednávky,
súčet hodnoty predaja za daný mesiac.
Na zoskupenie objednávok podľa mesiaca použite funkciu DATE_TRUNC() a výsledok zoraďte podľa mesiaca vzostupne.

Ktorá z nasledujúcich tabuliek zodpovedá výsledku vášho dotazu po zoradení podľa mesiaca vzostupne?*/

CREATE INDEX idx_orders_order_date ON orders(order_date);
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(sales) AS monthly_sales
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month ASC;

/*Vytvorte viacstĺpcový index nad tabuľkou orders, ktorý bude obsahovať stĺpce customer_id a order_date.

Index pomenujte:

idx_orders_region_category
Následne vytvorte SQL dotaz, ktorý prepojí tabuľky orders a customers a 
zobrazí iba objednávky zákazníkov z regiónu West, ktoré boli vytvorené od 2024-01-01.

Akú hodnotu profit má vo výsledku zákazník Customer_25? Do odpovede zadajte iba číselnú hodnotu.

💡 Pomôcka: Pri viacstĺpcovom indexe záleží na poradí stĺpcov. 
Index (customer_id, order_date) môže byť vhodný pre dotazy, 
ktoré najskôr pracujú so zákazníkom a následne s dátumovým obmedzením.*/

CREATE INDEX idx_orders_region_category ON orders(customer_id, order_date);

SELECT o.*, c.customer_name, c.region
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.region = 'West'
  AND o.order_date >= DATE '2024-01-01';

/*Manažment potrebuje opakovane zisťovať celkovú hodnotu predaja konkrétneho zákazníka.
 Namiesto opakovaného zapisovania agregačného SQL dotazu vytvorte uloženú procedúru, 
 ktorá túto operáciu vykoná na základe zadaného identifikátora zákazníka.

Vytvorte procedúru s názvom get_customer_sales.

Procedúra má:

prijímať ako vstupný parameter identifikátor zákazníka,
vypočítať súčet všetkých jeho predajov zo stĺpca sales,
uložiť vypočítanú hodnotu do lokálnej premennej,
vypísať identifikátor zákazníka a jeho celkový predaj pomocou RAISE NOTICE.
Pri vytváraní procedúry použite jazyk PL/pgSQL. 
Procedúru navrhnite tak, aby bolo možné rovnaký kód použiť pre ľubovoľného zákazníka iba zmenou hodnoty vstupného parametra.

Po vytvorení procedúry ju otestujte vytvorené riešenie pre zákazníka:

CALL get_customer_sales('C001');
Spustite procedúru pre zadaného zákazníka a do odpovede uveďte počet záznamov, ktoré procedúra vráti pomocou RAISE NOTICE.*/



CREATE OR REPLACE PROCEDURE get_customer_sales(
    IN p_customer_id VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    total_sales NUMERIC;
BEGIN
    SELECT SUM(sales)
    INTO total_sales
    FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Customer ID: %, Total sales: %',
        p_customer_id, total_sales;
END;
$$;

/*Manažment chce počas promo akcie vedieť hromadne znížiť hodnotu predaja všetkých objednávok zákazníkov 
z vybraného regiónu. Vytvorte uloženú procedúru, ktorá túto operáciu automatizuje.

Procedúru pomenujte:

apply_regional_discount
Procedúra musí prijímať dva vstupné parametre:

region_name – názov regiónu, pre ktorý sa má zľava aplikovať,
discount_rate – výška zľavy zapísaná ako desatinné číslo, napríklad 0.10 pre 10 %.
Procedúra má:

nájsť všetky objednávky zákazníkov patriacich do zadaného regiónu,
znížiť hodnotu sales podľa zadanej hodnoty zľavy,
po úspešnom vykonaní vypísať informačnú správu pomocou RAISE NOTICE, ktorá uvedie použitú zľavu a názov regiónu.
Pri výpočte novej hodnoty predaja použite princíp:

new_sales = sales × (1 - discount_rate)
Procedúru následne otestujte pre región West a zľavu 10 %.

Predpokladajme, že procedúru spustíte dvakrát po sebe s rovnakými parametrami:

CALL apply_regional_discount('West', 0.10);

Čo sa stane s hodnotami sales objednávok zákazníkov z regiónu West?*/

CREATE OR REPLACE PROCEDURE apply_regional_discount(
    IN region_name VARCHAR,
    IN discount_rate NUMERIC
)
LANGUAGE plpgSQL
AS $$
BEGIN
    UPDATE orders
    SET sales = sales * (1 - discount_rate)
    WHERE region = region_name;

    RAISE NOTICE 'Discount % applied to region %',
        discount_rate, region_name;

END;
$$;

/*Vytvorte uloženú procedúru, ktorá umožní zistiť celkovú hodnotu predaja za ľubovoľné
 časové obdobie bez potreby opakovane zapisovať celý agregačný SQL dotaz.
Procedúru pomenujte:
get_sales_between
Procedúra musí prijímať dva vstupné parametre:
- start_date – dátum začiatku sledovaného obdobia,
- end_date – dátum konca sledovaného obdobia.
Procedúra má:
- vybrať objednávky, ktorých dátum sa nachádza medzi zadanými hodnotami start_date a end_date,
- vypočítať súčet stĺpca sales pre vybrané obdobie,
- uložiť výsledok do lokálnej premennej,
- vypísať začiatok obdobia, koniec obdobia a vypočítanú hodnotu pomocou RAISE NOTICE.
Procedúru následne otestujte pre obdobie od 2024-01-01 do 2024-03-31.
Akú hodnotu celkového predaja vypíše procedúra pre obdobie od 2024-01-01 do 2024-03-31?
 Do odpovede zadajte iba číselnú hodnotu.*/

CREATE OR REPLACE PROCEDURE get_sales_between(
    IN start_date DATE,
    IN end_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    total_sales NUMERIC;
BEGIN
    SELECT SUM(sales)
    INTO total_sales
    FROM orders
    WHERE order_date BETWEEN start_date AND end_date;

    RAISE NOTICE 'Start: %, End: %, Total sales: %',
        start_date, end_date, total_sales;
END;
$$;

CALL get_sales_between('2024-01-01', '2024-03-31');
