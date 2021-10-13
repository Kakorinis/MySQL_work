use rielty;

-- 1.Хотим посмотреть весь штат сотрудников с привязкой к оффисам, где они работают.
/*
select o_i.state as State, o_i.adress as 'Office adress', group_concat(p.name) as Personal
from offices_info as o_i join personal as p on o_i.id = p.office
group by o_i.id order by o_i.state;
*/


-- 2. Хотим посмотреть например у каких агентов общая цена объектов по типу продажа больше 3 млн. и посчитать кол-во объектов.
/*
set @start = 0;

select @start := @start +1 AS Number, t.name, t.num_objects, t.total_price
from (
	select p.name, count(*) as num_objects, sum(o_p.price) as total_price
	from objects as o join personal as p on o.personal_id = p.id
	join object_profile as o_p on o.id = o_p.id
	join deal_type as dt on o.deal_type_id = dt.id
	where dt.id = 2 and o.status = 'active'
	group by p.name order by total_price desc
	) as t
where t.total_price > 3000000;
*/

 
-- 3. Вывести все объекты в конкретном штате, например Огайо (OH) 
  /*
set @state = 'OH';
select o_p.city, d_t.type as 'Deal type', o_t.type as 'Object type', o_p.price as Price, o_p.square_meters, p.name as 'Rieltor', p.phone as 'Rieltors phone'
from object_profile as o_p join objects as o on o_p.id = o.id
join deal_type as d_t on o.deal_type_id = d_t.id
join object_type as o_t on o.object_type_id = o_t.id
join personal as p on o.personal_id = p.id
join offices_info as o_i on p.office = o_i.id
where o_i.state = @state group by o_p.id order by o_p.city, d_t.type, o_t.type;
*/

   
   -- 4. В данном пункте пример того, как перезаписывались данные. Необходимость перезаписи была вызвана тем, что 
   -- из-за использования некоторого сайта генерации данных, города логически не сочетались со штатами, встречались даже русские и города 
   -- из др. стран. В итоге было решено создать таблицу с двумя столбцами - штат и город
 /*
mysql> create table cities(
    -> state varchar(20),
    -> city varchar(20));
    
-- Таблица была наполнена строками Штат - город, по три города каждому штату:
mysql> insert into cities
    -> values ('CO', 'Denver'),('CO','Centennial'), ('CO','Arvada'),
    -> ('CT','Bristol'),('CT','Stamford'), ('CT', 'Derby'),
    -> ('IL', 'Springfield'), ('IL','Virginia'), ('IL', 'Bloomington'),
    -> ('KS', 'Kansas City'), ('KS', 'Lawrence'), ('KS', 'Coffeyville'),
    -> ('LA', 'Bossier'), ('LA', 'Monroe'), ('LA', 'St. Martinville'), ('LA', 'Thibodaux'),
    -> ('MA','Worcester'), ('MA', 'Southbridge'), ('MA', 'Boston'), ('MA', 'Barnstable');
    -> ('MI', 'Bay City'), ('MI', 'Kalamazoo'), ('MI', 'Livonia'),
    -> ('MS', 'Jackson'), ('MS', 'Meridian'), ('MS', 'Natchez'), ('MS', 'Yazoo');
    -> ('NE', 'Lincoln'), ('NE', 'Omaha'), ('NE', 'Papillion'), ('NE', 'Dakota'),
    -> ('NJ', 'Jersey City'), ('NJ', 'Trenton'), ('NJ', 'Hackensack'),
    -> ('NY', 'New York'), ('NY', 'Albany'), ('NY', 'Watertown'),
    -> ('OH', 'Akron'), ('OH','Columbus'), ('OH', 'Canton');
    -> ('OR', 'Corvallis'), ('OR', 'Canyon City'), ('OR', 'Bend'), ('OR', 'Portland'),
    -> ('PA', 'Harrisburg'), ('PA', 'Allentown'), ('PA', 'Pittsburgh'),
    -> ('TN', 'Knoxville'), ('TN', 'Memphis'), ('TN', 'Chattanooga'),
    -> ('TX', 'Mentone'), ('TX', 'Austin'), ('TX','Grapevine'), 
    -> ('VA', 'Richmond'), ('VA', 'Burkeville'), ('VA', 'Duffield'), ('VA', 'Jonesville'), ('VA', 'Maryland'),
    -> ('LA', 'Quenteen'), ('LA', 'Yeallosk'), ('LA', 'Mondrey');

   
   -- затем был сделан запрос на перезапись значений колонки city из таблицы object_profile значениями колонки city из новой таблицы
   -- sities. 
   
      mysql> update object_profile join objects as o on object_profile.id = o.id
    -> join personal as p on o.personal_id = p.id
    -> join offices_info as o_i on p.office = o_i.id
    -> set city = (SELECT city FROM cities where state = o_i.state ORDER BY RAND() LIMIT 1);
*/


-- 5. В агенство пришел клиент Jack, который хочет купить коммерческий объект до 500 тыс, рассматривает всю страну.
-- Здесь мы используем ранее заготовленную процедуру по отображению всех объектов в условиях подбора 
-- по типу сделки и лимиту цены


-- вот та заготовленная процедура:
/*
delimiter //
drop procedure find_info//
create  procedure find_info (IN type_o char(10), IN num INT)
begin
    declare cub_meters decimal(20,2);
    set @start = 0;
    select @start := @start +1 AS Number, comm.type, comm.id, comm.square_meters, comm.price, comm.one_cube_meter_costs,comm.state,comm.city
    from (
    select o_t.type, o.id, o_p.square_meters, o_p.price, round(@cub_meters := o_p.price / o_p.square_meters, 2) as one_cube_meter_costs,o_i.state, o_p.city
    from object_profile as o_p join objects as o on o_p.id = o.id
    join object_type as o_t on o.object_type_id = o_t.id
    join personal as p on o.personal_id = p.id
    join offices_info as o_i on p.office = o_i.id
    where o_t.type = type_o and o_p.price <= num 
    group by o_p.id order by o_p.price) as comm;
end//
*/

-- а вот мы ее используем применительно к ситуации
-- call find_info('commerce', 500000)//


 -- 6. Далее клиента заинтересовал 5-тый объект (id 347)с большей площадью и недорогой стоимостью за кв. метр.
 --  На этот случай у нас была заготовлена др. процедура:

/*
delimiter //
drop procedure object_info//
CREATE PROCEDURE `object_info`(IN num INT)
begin
	declare cub_meters decimal(20,2);
	select o_t.type,o.id, o_p.square_meters, o_p.price, round(@cub_meters := o_p.price / o_p.square_meters,2) as one_cube_meter_costs,o_i.state, o_p.city, o_p.adress,p.name as rieltor, p.phone as "rieltor's phone"
	from object_profile as o_p join objects as o on o_p.id = o.id
	join object_type as o_t on o.object_type_id = o_t.id
	join personal as p on o.personal_id = p.id
	join offices_info as o_i on p.office = o_i.id
	where o_p.id = num;
end//
*/

-- распечатываем ему инфу и теперь он может связаться с агентом для просмотра
-- call object_info(5)//

  
 /*
-- Eсли клиенту понравилось несколько объектов с конкретными id, то формируем следующий запрос
    select o_t.type,o.id, o_p.square_meters, o_p.price, @cub_meters := o_p.price / o_p.square_meters as one_cube_meter_costs,o_i.state, o_p.city, o_p.adress,p.name as rieltor, p.phone as "rieltor's phone"
    from object_profile as o_p join objects as o on o_p.id = o.id
    join object_type as o_t on o.object_type_id = o_t.id
    join personal as p on o.personal_id = p.id
    join offices_info as o_i on p.office = o_i.id
    where o_p.id in (402,201,333,332) \G
    */

-- 7.Допустим, нужно выбрать топ 10 риелторов кто приносит компании больше всего денег.
-- Справедливой оценкой считается кол-во отработанных каждым сотрудником дней разделенных на принесенную компании доход. 
-- Иными словами кто в среднем сколько денег в день приносил компании в определенном периоде времени (полугодие например).
-- Берем инфу из таблицы closed_deals

-- Т.к. база изначально была новая (только активные сделки), нужно было сформировать закрытые сделки, чтобы было из чего считать (closed_deals пустая таблица).
-- Принято решение заполнить через консоль посредством комманд, а не инсертом сгенерированных данных.
-- В условиях бизнес-процессов таблица closed_deals была бы уже заполненной (для этого реализован триггер) и эту часть выполнять не нужно.

/*
-- для начала правим дату создания у всех объектов. Сделать это нужно т.к. хочу закрыть сделки за первые 2 квартала 2021 методом rand(), важно чтобы не было дат созданий после 2го квартала иначе будет
-- противоречие к дате создания.
update objects
SET created_at = TIMESTAMPADD(SECOND, FLOOR(RAND()* TIMESTAMPDIFF(SECOND,'2020-01-11','2021-06-30')),
'2020-01-11');
*/

/*
-- теперь закрываем сделки:
update objects 
set status = 'closed',
closing_date = TIMESTAMPADD(SECOND, FLOOR(RAND()* TIMESTAMPDIFF(SECOND,created_at,'2021-06-30')),
created_at)
where id order by rand() limit 150;
*/

-- итак, в таблице closed_deals у нас есть 150 записей по закрытым сделкам, теперь можем вычислить самого эффективного сотрудника.
-- Поскольку действие предполагает быть регулярным в бизнес процессах, например для определения перечня сотрудников к премированию либо доски почета, 
-- используем ранее созданную процедуру:
/*
delimiter //
create procedure top_10 (IN date_from DATE, IN date_to DATE)
begin
	select p.name, round((sum(c_d.company_encome)/TIMESTAMPDIFF(day, date_from, date_to)),2) as encome
	from closed_deals as c_d join objects as o on c_d.objects_id = o.id 
	join personal as p on o.personal_id = p.id
	where o.closing_date between date_from and date_to
	group by p.name order by encome desc limit 10;
end//

-- Т.к. объекты заводились с января 2020г., хотим посмотреть результаты за полтора года:
-- call top_10('2020-01-10','2021-06-30')//
/* пример:
+--------------------+--------+
| name               | encome |
+--------------------+--------+
| Gae Brandrick      | 218.30 |
| Cornelle Grave     | 179.85 |
| Allard Ainscow     | 153.67 |
| Nani Tresise       | 153.24 |
| Lindsey de Villier | 150.12 |
| Adelind Leamon     | 148.57 |
| Allyson Loody      | 147.85 |
| Alena Stiffell     | 142.34 |
| Rita Strongitharm  | 141.17 |
| Karena Scatchar    | 141.05 |
+--------------------+--------+
*/


-- для автоматизации наполнения таблицы closed_deals создан триггер, который наполняет таблицу данными в момент внесения 
-- в колонку Статус таблицы objects значения 'closed':
/*
delimiter //
create trigger add_data_closed_deals after update on objects
for each row
begin
	if old.status = 'active' and NEW.status = 'closed' then
    	insert into closed_deals (objects_id, comission, personal_encome, company_encome)
		values (old.id, 
			(select price from object_profile as o_p join objects as o on o_p.id = o.id where o.id = old.id) * 0.03,
		comission * 0.3, comission * 0.7);
	end if;
end//
*/

-- 8. В агенство пришел клиент Jack. Он хочет купить дом в Массачусетсе (штат MS) не дороже 1 млн. и площадью не меньше 200 кв.м. 
-- для разнообразия поиск оформлен именно в виде запроса:
/*
select o_t.type, o_p.square_meters, o_p.price, o_i.state, o_p.city, o_p.adress
from object_profile as o_p join objects as o on o_p.id = o.id
join object_type as o_t on o.object_type_id = o_t.id
join personal as p on o.personal_id = p.id
join offices_info as o_i on p.office = o_i.id
where o_t.type = 'house' and o_p.price <= 1000000 AND  o_i.state = 'MS' and o_p.square_meters > 200
group by o_p.id order by o_p.price;

-- показываем фотки
select * from photos where object_profile_id = 449;
*/


-- 9. Сделка заключена и клиент спрашивает не можем ли мы помочь ему с перевозом вещей.
-- Открываем таблицу partner_companies и даем ему контакты corp. Man:
-- select * from partner_companies;

-- 10. При завершении сделок допустим важно удалять имеющиеся фото.
-- Для этого реализован триггер на автоудаление фоток при изменении в объектах статуса объекат на закрыто:
/*
-- через селект каунт можем проверить кол-во фоток, потом в таблице objects закрыть объект и проверить заново кол-во фото
 * select count(*) from photos where object_profile_id = 500//

 /*
create trigger delete_photo after insert on closed_deals
for each row
begin
    delete from photos where object_profile_id = NEW.objects_id;
end//
*/

-- 11. Созданные триггеры для таблицы top_deals
/*
delimiter //

create trigger the_fustest_deal after insert on closed_deals
for each ROW 
begin 
	set @x = TIME_TO_SEC((TIMEDIFF((select closing_date from objects where id = new.objects_id), (select created_at from objects where id = new.objects_id)))) / 3600; 
	if @x < (select the_result from top_deals where about_deal = 'The fustest deal')
	then 
	update top_deals
	set the_result = @x,
	personal_name = (select name from personal as p join objects as o on p.id = o.personal_id where o.id = new.objects_id)
	where about_deal = 'The fustest deal';
	end if;
end//


create trigger the_biggest_encome after insert on closed_deals
for each ROW 
begin 
	if new.company_encome  > (select the_result from top_deals where about_deal = 'The biggest encome')
	then 
	update top_deals
	set the_result = new.company_encome,
	personal_name = (select name from personal as p join objects as o on p.id = o.personal_id where o.id = new.objects_id)
	where about_deal = 'The biggest encome';
	end if;
end//
*/
