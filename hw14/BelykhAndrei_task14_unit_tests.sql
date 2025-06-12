--Тестовый модуль для задания HW14
------------------------------------------------------------------------------------------------------------------------
--Посмотреть, что сейчас в таблицах:
--select * from payment
--select * from payment_detail


------------------------------------------------------------------------------------------------------------------------
--1.Создание платежа. Test-1
declare
  c_api constant varchar2(100 char) := upper('payment_api_pack.create_payment');
  c_test constant varchar2(100 char) := 'Пустое значение детали платежа';
  v_payment_id payment.payment_id%type;
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
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
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
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
end;
/

--1.Создание платежа. Test-2
declare
  c_api constant varchar2(100 char) := upper('payment_api_pack.create_payment');
  c_test constant varchar2(100 char) := 'Пустой ID детали платежа';
  v_payment_id payment.payment_id%type;
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
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
                                          t_payment_detail(null, '123.1.2.3'),
                                          t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_note,
                                                           'Тестовый переводик')));
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
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
end;
/

--1.Создание платежа. Test-3
declare
  c_api constant varchar2(100 char) := upper('payment_api_pack.create_payment');
  c_test constant varchar2(100 char) := 'Не заданы детали платежа';
  v_payment_id payment.payment_id%type;
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
  v_payment_id := payment_api_pack.create_payment(p_create_dtime => systimestamp,
                                                  p_from_client_id => 1,
                                                  p_to_client_id => 2,
                                                  p_summa => 30,
                                                  p_currency_id => 643,
                                                  p_payment_details => t_payment_detail_array());
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
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
end;
/

------------------------------------------------------------------------------------------------------------------------
--2.Сброс платежа в "ошибочный статус". Test-1
declare
  c_api constant varchar2(100 char) := upper('payment_api_pack.fail_payment');
  c_test constant varchar2(100 char) := 'Не задан платеж';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
  payment_api_pack.fail_payment(null);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
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
end;
/

--2.Сброс платежа в "ошибочный статус". Test-2
declare
  c_api constant varchar2(100 char) := upper('payment_api_pack.fail_payment');
  c_test constant varchar2(100 char) := 'Задан несуществующий платеж';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
  payment_api_pack.fail_payment(634534564675686786879);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
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
end;
/

--2.Сброс платежа в "ошибочный статус". Test-3
declare
  c_api constant varchar2(100 char) := upper('payment_api_pack.fail_payment');
  c_test constant varchar2(100 char) := 'Платеж находится не в статус "Создан"';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);

  for r in (select payment_id
            from payment
            where status <> 0 and rownum = 1) loop
    payment_api_pack.fail_payment(r.payment_id);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  end loop;
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
end;
/

------------------------------------------------------------------------------------------------------------------------
--3.Отмена платежа. Test-1
declare
  c_api constant varchar2(100 char) := upper('payment_api_pack.cancel_payment');
  c_test constant varchar2(100 char) := 'Не задан платеж';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
  payment_api_pack.cancel_payment(null);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
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
end;
/

--3.Отмена платежа. Test-2
declare
  c_api constant varchar2(100 char) := upper('payment_api_pack.cancel_payment');
  c_test constant varchar2(100 char) := 'Задан несуществующий платеж';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
  payment_api_pack.cancel_payment(634534564675686786879);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
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
end;
/

--3.Отмена платежа. Test-3
declare
  c_api constant varchar2(100 char) := upper('payment_api_pack.cancel_payment');
  c_test constant varchar2(100 char) := 'Платеж находится не в статус "Создан"';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);

  for r in (select payment_id
            from payment
            where status <> 0 and rownum = 1) loop
    payment_api_pack.cancel_payment(r.payment_id);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  end loop;
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
end;
/

--3.Отмена платежа. Test-4
declare
  c_api constant varchar2(100 char) := upper('payment_api_pack.cancel_payment');
  c_test constant varchar2(100 char) := 'Не задана причина отмены платежа';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);

  for r in (select payment_id
            from payment
            where status = 0 and rownum = 1) loop
    payment_api_pack.cancel_payment(r.payment_id, null);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  end loop;
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
end;
/


------------------------------------------------------------------------------------------------------------------------
--4.Успешное завершение платежа. Test-1
declare
  c_api constant varchar2(100 char) := upper('payment_api_pack.successful_finish_payment');
  c_test constant varchar2(100 char) := 'Не задан платеж';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
  payment_api_pack.successful_finish_payment(null);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
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
end;
/

--4.Успешное завершение платежа. Test-2
declare
  c_api constant varchar2(100 char) := upper('payment_api_pack.successful_finish_payment');
  c_test constant varchar2(100 char) := 'Задан несуществующий платеж';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
  payment_api_pack.successful_finish_payment(634534564675686786879);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
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
end;
/

--4.Успешное завершение платежа. Test-3
declare
  c_api constant varchar2(100 char) := upper('payment_api_pack.successful_finish_payment');
  c_test constant varchar2(100 char) := 'Платеж находится не в статус "Создан"';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);

  for r in (select payment_id
            from payment
            where status <> 0 and rownum = 1) loop
    payment_api_pack.successful_finish_payment(r.payment_id);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  end loop;
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
end;
/

------------------------------------------------------------------------------------------------------------------------
--5.Данные платежа добавлены или обновлены. Test-1
declare
  c_api constant varchar2(100 char) := upper('payment_detail_api_pack.insert_or_update_payment_detail');
  c_test constant varchar2(100 char) := 'Не задан платеж';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
  payment_detail_api_pack.insert_or_update_payment_detail(
    null,
    t_payment_detail_array(
      t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_note, 'Юнит-Тест')));
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
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
end;
/

--5.Данные платежа добавлены или обновлены. Test-2
declare
  c_api constant varchar2(100 char) := upper('payment_detail_api_pack.insert_or_update_payment_detail');
  c_test constant varchar2(100 char) := 'Задан несуществующий платеж';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
  payment_detail_api_pack.insert_or_update_payment_detail(
    123345345345345,
    t_payment_detail_array(
      t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_note, 'Юнит-Тест')));
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
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
end;
/

--5.Данные платежа добавлены или обновлены. Test-3
declare
  c_api constant varchar2(100 char) := upper('payment_detail_api_pack.insert_or_update_payment_detail');
  c_test constant varchar2(100 char) := 'Не заданы детали платежа';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);

  for r in (select payment_id
            from payment
            where rownum = 1) loop
    payment_detail_api_pack.insert_or_update_payment_detail(r.payment_id, t_payment_detail_array());
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  end loop;
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
end;
/

--5.Данные платежа добавлены или обновлены. Test-4
declare
  c_api constant varchar2(100 char) := upper('payment_detail_api_pack.insert_or_update_payment_detail');
  c_test constant varchar2(100 char) := 'Не задан ID детали платежа';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);

  for r in (select payment_id
            from payment
            where rownum = 1) loop
    payment_detail_api_pack.insert_or_update_payment_detail(
      r.payment_id,
      t_payment_detail_array(t_payment_detail(null, 'Юнит-Тест')));
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  end loop;
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
end;
/

--5.Данные платежа добавлены или обновлены. Test-5
declare
  c_api constant varchar2(100 char) := upper('payment_detail_api_pack.insert_or_update_payment_detail');
  c_test constant varchar2(100 char) := 'Не задано значения детали платежа';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);

  for r in (select payment_id
            from payment
            where rownum = 1) loop
    payment_detail_api_pack.insert_or_update_payment_detail(
      r.payment_id,
      t_payment_detail_array(t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_note, '')));
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  end loop;
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
end;
/



------------------------------------------------------------------------------------------------------------------------
--6.Детали платежа удалены. Test-1
declare
  c_api constant varchar2(100 char) := upper('payment_detail_api_pack.delete_payment_detail');
  c_test constant varchar2(100 char) := 'Не задан платеж';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
  payment_detail_api_pack.delete_payment_detail(
    null,
    t_number_array(payment_detail_api_pack.c_payment_detail_field_id_ip,
                   payment_detail_api_pack.c_payment_detail_field_id_is_checked));
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
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
end;
/

--6.Детали платежа удалены. Test-2
declare
  c_api constant varchar2(100 char) := upper('payment_detail_api_pack.delete_payment_detail');
  c_test constant varchar2(100 char) := 'Задан несуществующий платеж';
begin
  dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
  payment_detail_api_pack.delete_payment_detail(
    1111122222233334444,
    t_number_array(payment_detail_api_pack.c_payment_detail_field_id_ip,
                   payment_detail_api_pack.c_payment_detail_field_id_is_checked));
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
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
end;
/