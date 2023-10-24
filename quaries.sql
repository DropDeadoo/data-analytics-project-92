/*Запрос считает общее количество покупателей из таблицы customers.*/
select COUNT(*) as customer_count
from customers;

/*Запрос находит кол-во всех продаж у продавцов и суммарную выручку каждого продавца.
    - name — имя и фамилия продавца
 	- operations - количество проведенных сделок
 	- income — суммарная выручка продавца за все время */

/*Создаем вспомогательную таблицу с подсчетом количества продаж и суммы продаж у каждого из продавцов*/
with total_sales as (
	 		select s.sales_person_id,
	 		count(s.sales_person_id) as operations,
	 		round(sum(p.price * s.quantity)) as income
	 		from sales s
	 		join products p 
	 		on s.product_id = p.product_id
	 		group by 1
	 		)
/* Берем имена продавцов и добавляем информацию из таблицы выше по кол-ву продаж и сумме, сортируем выручку по убыванию */			
select concat(e.first_name, ' ', e.last_name) as name, 
ts.operations, ts.income
from employees e
join total_sales ts 
on e.employee_id  = ts.sales_person_id
order by 3 desc
limit 10
;

/* Запрос находит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
 	- name — имя и фамилия продавца
 	- average_income — средняя выручка продавца за сделку с округлением до целого */
/*Создаем вспомогательную таблицу с подсчетом средней цены суммарных продаж у каждого из продавцов*/
with tab as(
			select s.sales_person_id,
			round(avg(p.price * s.quantity)) as avg_income
			from sales s
			join products p 
			on s.product_id = p.product_id
			group by 1
			)
/* Берем имена продавцов и добавляем информацию из таблицы выше по средней цене всех продаж, оставляем только те значения, которые меньше общей средней выручки
 * продавцов, сортируем среднюю по возрастанию */		
select concat(e.first_name, ' ', e.last_name) as name,
t.avg_income as average_income
from employees e 
join tab t
on e.employee_id = t.sales_person_id
group by 1, 2
having t.avg_income < (select sum(avg_income) / count(*) from tab)
order by 2; 

/* Запрос показывает суммарную выручку каждого продавца в конкретный день недели.
	 - name — имя и фамилия продавца
 	 - weekday — название дня недели на английском языке
	 - income — суммарная выручка продавца в определенный день недели, округленная до целого числа
*/
/* Создаем вспомогательную таблицу ФИО продавцов, названием дня недели, номером дня недели и суммой продаж, сортируем по номер дня недели*/
with total_sales as (
	 		select concat(e.first_name, ' ', e.last_name) as name, 
	 		to_char(s.sale_date, 'day') as weekday,
	 		to_char(s.sale_date, 'ID') num_of_day,
	 		round(sum(p.price * s.quantity)) as income
	 		from sales s
	 		join products p 
	 		on s.product_id = p.product_id
	 		join employees e 
	 		on s.sales_person_id = e.employee_id
	 		group by 1, 2, 3
	 		order by 3
	 		)
/* Достаем из таблицы выше только имя продавца, день недели и сумму продаж */		
select name, weekday, income
from total_sales;

/* Запрос делит покупателей по категориям и считает их кол-во.
 * age_category - возрастная группа
 * count - количество человек в группе
 */

select case when age >= 16 and age <= 25 then '16-25' when age >= 26 and age <= 40 then '26-40' else '40+' end as age_category,
count(age)
from customers 
group by 1
order by 1
;
/* Запрос находит количество уникальных пользователей и выручку в разрезе даты. 
 * date - дата в указанном формате
 * total_customers - количество покупателей
 * income - принесенная выручка
*/
/* Создаем вспомогательную таблицу с датой формата ГОД-МЕСЯЦ, кол-вом покупателей и выручкой в разрезе дат*/
with income as (
				select to_char(s.sale_date, 'YYYY-MM') as date,
				count(s.*) as total_customers,
				s.quantity * p.price as income
				from sales s
				join products p 
				on s.product_id = p.product_id 
				group by 1, 3
				)
/* Достаем из таблицы выше информацию и суммируем полученные значения в разрезе каждого месяца и года.*/
select date, sum(total_customers) as total_customers,
round(sum(income)) as income
from income
group by 1
order by 1;

/* Запрос выводит покупателей, ПЕРВАЯ покупка которых была в ходе проведения акций (товар = 0). 
 * customer - имя и фамилия покупателя
 * sale_date - дата покупки
 * seller - имя и фамилия продавца
*/
select concat(c.first_name, ' ', c.last_name) as customer, 
min(s.sale_date) as date,
concat(e.first_name, ' ', e.last_name) as seller
from sales s
join products p
on s.product_id = p.product_id
join customers c
on s.customer_id = c.customer_id
join employees e
on s.sales_person_id = e.employee_id
where p.price = 0
group by 1, 3
order by 1;
