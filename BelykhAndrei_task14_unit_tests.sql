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
  dbms_output.put_line('Test 1');
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
  when others then
    dbms_output.put_line(dbms_utility.format_error_stack);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
end;
/

--2.Сброс платежа в "ошибочный статус".
begin
  dbms_output.put_line('Test 2');
  payment_api_pack.fail_payment(634534564675686786879);
exception
  when others then
    dbms_output.put_line(dbms_utility.format_error_stack);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
end;
/

--3.Отмена платежа.
begin
  dbms_output.put_line('Test 3');
  payment_api_pack.cancel_payment(10);  
exception
  when others then
    dbms_output.put_line(dbms_utility.format_error_stack);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
end;
/

--4.Успешное завершение платежа.
begin
  dbms_output.put_line('Test 4');
  payment_api_pack.successful_finish_payment(null);  
exception
  when others then
    dbms_output.put_line(dbms_utility.format_error_stack);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
end;
/

--5.Данные платежа добавлены или обновлены.
begin
  dbms_output.put_line('Test 5');
  payment_detail_api_pack.insert_or_update_payment_detail(66, t_payment_detail_array());
exception
  when others then
    dbms_output.put_line(dbms_utility.format_error_stack);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
end;
/

--6.Детали платежа удалены.
begin
  dbms_output.put_line('Test 6');
  payment_detail_api_pack.delete_payment_detail(
    null,
    t_number_array(payment_detail_api_pack.c_payment_detail_field_id_ip,
                   payment_detail_api_pack.c_payment_detail_field_id_is_checked));
exception
  when others then
    dbms_output.put_line(dbms_utility.format_error_stack);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
end;
/