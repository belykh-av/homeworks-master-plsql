--Тестовый модуль для задания HW13
------------------------------------------------------------------------------------------------------------------------

--Запрос для проверки валидности пакетов:
select t.status, t.*
from user_objects t
where t.object_type like 'PACKAGE%';
/


--Посмотреть, что сейчас в таблицах:
select * from payment
/
select * from payment_detail
/


--1.Создание платежа
declare
  v_payment_id payment.payment_id%type;
begin
  v_payment_id := payment_api_pack.create_payment(
                    p_create_dtime => systimestamp,
                    p_from_client_id => 1,
                    p_to_client_id => 2,
                    p_summa => 30,
                    p_currency_id => 643,
                    p_payment_details => t_payment_detail_array(
                                          t_payment_detail(
                                            payment_detail_api_pack.c_payment_detail_field_id_client_software,
                                            'Клинет-банк какой-то'),
                                          t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_ip,
                                                           '172.173.120.300'),
                                          t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_note,
                                                           'Тестовый переводик')));
end;
/

--2.Сброс платежа в "ошибочный статус".
begin
  payment_api_pack.fail_payment(63);
end;
/

--3.Отмена платежа.
begin
  payment_api_pack.cancel_payment(64);
end;
/

--4.Успешное завершение платежа.
begin
  payment_api_pack.successful_finish_payment(65);
end;
/

--5.Данные платежа добавлены или обновлены.
begin
  payment_detail_api_pack.insert_or_update_payment_detail(
    66,
    t_payment_detail_array(
      t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_note,
                       'Изменение данных платежа'),
      t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_ip, '172.173.1.2'),
      t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_client_software, 'web-клиент')));
end;
/

--6.Детали платежа удалены.
begin
  payment_detail_api_pack.delete_payment_detail(
    66,
    t_number_array(payment_detail_api_pack.c_payment_detail_field_id_ip,
                   payment_detail_api_pack.c_payment_detail_field_id_is_checked));
end;
/