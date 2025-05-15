--Тестовый модуль для задания HW12
------------------------------------------------------------------------------------------------------------------------

--Запрос для проверки валидности созданных процедур и функций:
select t.status, t.*
from user_objects t
where t.object_type in ('FUNCTION', 'PROCEDURE');
/


--Посмотреть, что сейчас в таблицах:
select * from payment
/
select * from payment_detail
/


--1.Создание платежа
declare
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"
  v_payment_id payment.payment_id%type;
begin
  v_payment_id := create_payment(
                    p_create_dtime => systimestamp,
                    p_from_client_id => 1,
                    p_to_client_id => 2,
                    p_summa => 30,
                    p_currency_id => 643,
                    p_payment_details => t_payment_detail_array(
                                          t_payment_detail(c_payment_detail_field_id_client_software,
                                                           'Клинет-банк какой-то'),
                                          t_payment_detail(c_payment_detail_field_id_ip, '172.173.120.300'),
                                          t_payment_detail(c_payment_detail_field_id_note,
                                                           'Тестовый переводик')));
end;
/

--2.Сброс платежа в "ошибочный статус".
begin
  fail_payment(63);
end;
/

--3.Отмена платежа.
begin
  cancel_payment(64);
end;
/

--4.Успешное завершение платежа.
begin
  successful_finish_payment(65);
end;
/

--5.Данные платежа добавлены или обновлены.
declare
  --ID полей данных деталей платежа:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"
begin
  insert_or_update_payment_detail(
    66,
    t_payment_detail_array(
      t_payment_detail(c_payment_detail_field_id_note, 'Изменение данных платежа'),
      t_payment_detail(c_payment_detail_field_id_ip, '172.173.1.2'),
      t_payment_detail(c_payment_detail_field_id_client_software, 'web-клиент')));
end;
/

--6.Детали платежа удалены.
declare
  --ID полей данных деталей платежа:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"
begin
  delete_payment_detail(66, t_number_array(c_payment_detail_field_id_ip, c_payment_detail_field_id_is_checked));
end;
/
