--Автор: Белых Анжрей
--Создание типа t_number_array 

create or replace type t_number_array is table of number(38);
/

--Проверка
--select * from user_objects where lower(object_name) = 't_number_array'
--/