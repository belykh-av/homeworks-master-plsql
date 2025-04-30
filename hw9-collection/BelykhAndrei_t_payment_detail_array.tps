--Автор: Белых Анжрей
--Создание типа t_payment_detail_array

create or replace type t_payment_detail_array is table of t_payment_detail;
/

--Проверка
--select * from user_objects where lower(object_name) = 't_payment_detail_array'
--/
