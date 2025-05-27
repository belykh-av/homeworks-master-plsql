--Тестовый модуль для задания HW14
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
  dbms_output.put_line('Test API: payment_api_pack.create_payment');
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
                                          t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_ip, null),
                                          t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_note,
                                                           'Тестовый переводик')));
exception
  when payment_api_pack.e_empty_payment_id
       or payment_api_pack.e_empty_status
       or payment_api_pack.e_empty_status_change_reason
       or payment_api_pack.e_payment_not_found
       or payment_api_pack.e_payment_status_error
       or payment_detail_api_pack.e_empty_payment_details
       or payment_detail_api_pack.e_empty_field_id
       or payment_detail_api_pack.e_empty_field_value then
    dbms_output.put_line(sqlerrm);
    dbms_output.put_line('');
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
end;
/

--2.Сброс платежа в "ошибочный статус".
begin
  dbms_output.put_line('Test API: payment_api_pack.fail_payment');
  payment_api_pack.fail_payment(634534564675686786879);
exception
  when payment_api_pack.e_empty_payment_id
       or payment_api_pack.e_empty_status
       or payment_api_pack.e_empty_status_change_reason
       or payment_api_pack.e_payment_not_found
       or payment_api_pack.e_payment_status_error
       or payment_detail_api_pack.e_empty_payment_details
       or payment_detail_api_pack.e_empty_field_id
       or payment_detail_api_pack.e_empty_field_value then
    dbms_output.put_line(sqlerrm);
    dbms_output.put_line('');
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
end;
/

--3.Отмена платежа.
begin
  dbms_output.put_line('Test API: payment_api_pack.cancel_payment');
  payment_api_pack.cancel_payment(10);
exception
  when payment_api_pack.e_empty_payment_id
       or payment_api_pack.e_empty_status
       or payment_api_pack.e_empty_status_change_reason
       or payment_api_pack.e_payment_not_found
       or payment_api_pack.e_payment_status_error
       or payment_detail_api_pack.e_empty_payment_details
       or payment_detail_api_pack.e_empty_field_id
       or payment_detail_api_pack.e_empty_field_value then
    dbms_output.put_line(sqlerrm);
    dbms_output.put_line('');
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
end;
/

--4.Успешное завершение платежа.
begin
  dbms_output.put_line('Test API: payment_api_pack.successful_finish_payment');
  payment_api_pack.successful_finish_payment(null);
exception
  when payment_api_pack.e_empty_payment_id
       or payment_api_pack.e_empty_status
       or payment_api_pack.e_empty_status_change_reason
       or payment_api_pack.e_payment_not_found
       or payment_api_pack.e_payment_status_error
       or payment_detail_api_pack.e_empty_payment_details
       or payment_detail_api_pack.e_empty_field_id
       or payment_detail_api_pack.e_empty_field_value then
    dbms_output.put_line(sqlerrm);
    dbms_output.put_line('');
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
end;
/

--5.Данные платежа добавлены или обновлены.
begin
  dbms_output.put_line('Test API: payment_detail_api_pack.insert_or_update_payment_detail');
  payment_detail_api_pack.insert_or_update_payment_detail(66, t_payment_detail_array());
exception
  when payment_api_pack.e_empty_payment_id
       or payment_api_pack.e_empty_status
       or payment_api_pack.e_empty_status_change_reason
       or payment_api_pack.e_payment_not_found
       or payment_api_pack.e_payment_status_error
       or payment_detail_api_pack.e_empty_payment_details
       or payment_detail_api_pack.e_empty_field_id
       or payment_detail_api_pack.e_empty_field_value then
    dbms_output.put_line(sqlerrm);
    dbms_output.put_line('');
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
end;
/

--6.Детали платежа удалены.
begin
  dbms_output.put_line('Test API: payment_detail_api_pack.delete_payment_detail');
  payment_detail_api_pack.delete_payment_detail(
    null,
    t_number_array(payment_detail_api_pack.c_payment_detail_field_id_ip,
                   payment_detail_api_pack.c_payment_detail_field_id_is_checked));
exception
  when payment_api_pack.e_empty_payment_id
       or payment_api_pack.e_empty_status
       or payment_api_pack.e_empty_status_change_reason
       or payment_api_pack.e_payment_not_found
       or payment_api_pack.e_payment_status_error
       or payment_detail_api_pack.e_empty_payment_details
       or payment_detail_api_pack.e_empty_field_id
       or payment_detail_api_pack.e_empty_field_value then
    dbms_output.put_line(sqlerrm);
    dbms_output.put_line('');
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
end;
/