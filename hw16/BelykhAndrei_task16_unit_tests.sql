--Тестовый модуль для задания HW15
------------------------------------------------------------------------------------------------------------------------
--Посмотреть, что сейчас в таблицах:
--select * from payment
--select * from payment_detail

--Валидность объектов:
select status, t.*
from user_objects t
where t.object_type in ('TRIGGER', 'PACKAGE', 'PACKAGE BODY')
order by t.object_type, t.object_name;
/

--
declare
  ----------------------------------------------------------------------------------------------------------------------
  --Positive. Создание платежа.
  procedure pos_create_payment is
    c_api constant varchar2(100 char) := upper('payment_api_pack.create_payment');
    c_test constant varchar2(100 char) := 'Создание платежа';
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
                                            t_payment_detail(common_pack.c_payment_detail_field_id_client_software,
                                                             'Клинет-банк какой-то'),
                                            t_payment_detail(common_pack.c_payment_detail_field_id_ip,
                                                             '172.173.120.300'),
                                            t_payment_detail(common_pack.c_payment_detail_field_id_note,
                                                             'Тестовый переводик')));
    dbms_output.put_line('ID платежа: ' || to_char(v_payment_id));

    --Проверка на одинаковость технической даты создания и даты изменения
    for r in (select *
              from payment
              where payment_id = v_payment_id) loop
      --dbms_output.put_line('create_dtime_tech=' || to_char(r.create_dtime_tech));
      --dbms_output.put_line('update_dtime_tech=' || to_char(r.update_dtime_tech));

      if r.create_dtime_tech = r.update_dtime_tech then
        dbms_output.put_line(
          'Дата создания записи и дата изменения записи одинаковые');
      else
        raise_application_error(
          -20999,
          'Unit-тест или API выполнены не верно' ||
          ' Дата создания записи и дата изменнния записи отличаются!');
      end if;
    end loop;

    dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Positive. Сброс платежа в "ошибочный статус".
  procedure pos_fail_payment is
    c_api constant varchar2(100 char) := upper('payment_api_pack.fail_payment');
    c_test constant varchar2(100 char) := 'Сброс платежа в "ошибочный статус"';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);

    for r in (select payment_id
              from payment
              where status = common_pack.c_status_created and rownum = 1) loop
      payment_api_pack.fail_payment(r.payment_id);

      --Проверка на разницу технической даты создания и даты изменения
      for r2 in (select *
                 from payment
                 where payment_id = r.payment_id) loop
        dbms_output.put_line('ID платежа: ' || to_char(r2.payment_id));

        if r2.status <> common_pack.c_status_failed then
          raise_application_error(
            -20999,
            'Unit-тест или API выполнены не верно.' ||
            ' Статус платежа не равен ' ||
            common_pack.c_status_failed);
        end if;

        --dbms_output.put_line('create_dtime_tech=' || to_char(r2.create_dtime_tech));
        --dbms_output.put_line('update_dtime_tech=' || to_char(r2.update_dtime_tech));

        if r2.create_dtime_tech <> r2.update_dtime_tech then
          dbms_output.put_line(
            'Дата создания записи и дата изменения записи разные');
        else
          raise_application_error(
            -20999,
            'Unit-тест или API выполнены не верно.' ||
            ' Дата создания записи и дата изменнния записи одинаковые!');
        end if;
      end loop;
    end loop;

    dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Positive. Отмена платежа.
  procedure pos_cancel_payment is
    c_api constant varchar2(100 char) := upper('payment_api_pack.cancel_payment');
    c_test constant varchar2(100 char) := 'Отмена платежа';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);

    for r in (select payment_id
              from payment
              where status = common_pack.c_status_created and rownum = 1) loop
      payment_api_pack.cancel_payment(r.payment_id);

      for r2 in (select *
                 from payment
                 where payment_id = r.payment_id) loop
        dbms_output.put_line('ID платежа: ' || to_char(r2.payment_id));

        if r2.status <> common_pack.c_status_canceled then
          raise_application_error(
            -20999,
            'Unit-тест или API выполнены не верно.' ||
            ' Статус платежа не равен ' ||
            common_pack.c_status_canceled);
        end if;
      end loop;
    end loop;

    dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Positive. Успешное завершение платежа.
  procedure pos_successful_finish_payment is
    c_api constant varchar2(100 char) := upper('payment_api_pack.successful_finish_payment');
    c_test constant varchar2(100 char) := 'Успешное завершение платежа.';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);

    for r in (select payment_id
              from payment
              where status = common_pack.c_status_created and rownum = 1) loop
      payment_api_pack.successful_finish_payment(r.payment_id);

      for r2 in (select *
                 from payment
                 where payment_id = r.payment_id) loop
        dbms_output.put_line('ID платежа: ' || to_char(r2.payment_id));

        if r2.status <> common_pack.c_status_completed then
          raise_application_error(
            -20999,
            'Unit-тест или API выполнены не верно.' ||
            ' Статус платежа не равен ' ||
            common_pack.c_status_completed);
        end if;
      end loop;
    end loop;

    dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Positive. Данные платежа добавлены или обновлены.
  procedure pos_insert_or_update_payment_detail is
    c_api constant varchar2(100 char) := upper('payment_detail_api_pack.insert_or_update_payment_detail');
    c_test constant varchar2(100 char) := 'Данные платежа добавлены или обновлены.';
    v_payment_detail_array t_payment_detail_array
      := t_payment_detail_array(
           t_payment_detail(common_pack.c_payment_detail_field_id_note,
                            'Изменение данных платежа'),
           t_payment_detail(common_pack.c_payment_detail_field_id_ip, '172.173.1.2'),
           t_payment_detail(common_pack.c_payment_detail_field_id_client_software, 'web-клиент'));
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);

    for r in (select payment_id
              from payment_detail
              where rownum = 1) loop
      payment_detail_api_pack.insert_or_update_payment_detail(r.payment_id, v_payment_detail_array);

      dbms_output.put_line('ID платежа: ' || to_char(r.payment_id));
      dbms_output.put_line('Кол-во деталей платежа: ');

      for r2
        in (select count(*) as cnt
            from payment_detail a
                 join table(v_payment_detail_array) b on b.field_id = a.field_id and b.field_value = a.field_value
            where a.payment_id = r.payment_id) loop
        dbms_output.put_line(r2.cnt);

        if r2.cnt <> v_payment_detail_array.count then
          raise_application_error(
            -20999,
            'Unit-тест или API выполнены не верно.' ||
            ' Кол-во элементов результирующей и исходной коллекций не сходятся');
        end if;
      end loop;
    end loop;

    dbms_output.put_line('--');
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Positive. Детали платежа удалены.
  procedure pos_delete_payment_detail is
    c_api constant varchar2(100 char) := upper('payment_detail_api_pack.delete_payment_detail');
    c_test constant varchar2(100 char) := 'Заданные детали платежа удалены.';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);

    for r in (select payment_id
              from payment_detail
              where rownum = 1) loop
      payment_detail_api_pack.delete_payment_detail(
        r.payment_id,
        t_number_array(common_pack.c_payment_detail_field_id_ip, common_pack.c_payment_detail_field_id_is_checked));

      dbms_output.put_line('ID платежа: ' || to_char(r.payment_id));

      for r2 in (select count(*) as cnt
                 from payment_detail
                 where payment_id = r.payment_id) loop
        dbms_output.put_line(
          'Кол-во деталей платежа после удаления: ' || to_char(r2.cnt));
      end loop;
    end loop;

    dbms_output.put_line('--');
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Создание платежа. Пустое значение детали платежа
  procedure neg_create_payment__empty_field_value is
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
                                            t_payment_detail(common_pack.c_payment_detail_field_id_client_software,
                                                             'Клинет-банк какой-то'),
                                            t_payment_detail(common_pack.c_payment_detail_field_id_ip, null),
                                            t_payment_detail(common_pack.c_payment_detail_field_id_note,
                                                             'Тестовый переводик')));
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_empty_field_value then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Создание платежа. Пустой ID детали платежа
  procedure neg_create_payment__empty_field_id is
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
                                            t_payment_detail(common_pack.c_payment_detail_field_id_client_software,
                                                             'Клинет-банк какой-то'),
                                            t_payment_detail(null, '123.1.2.3'),
                                            t_payment_detail(common_pack.c_payment_detail_field_id_note,
                                                             'Тестовый переводик')));
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_empty_field_id then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Создание платежа. Не заданы детали платежа
  procedure neg_create_payment__empty_payment_details is
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
    when common_pack.e_empty_payment_details then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Сброс платежа в "ошибочный статус". Не задан платеж
  procedure neg_fail_payment__empty_payment_id is
    c_api constant varchar2(100 char) := upper('payment_api_pack.fail_payment');
    c_test constant varchar2(100 char) := 'Не задан платеж';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
    payment_api_pack.fail_payment(null);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_empty_payment_id then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Сброс платежа в "ошибочный статус". Задан несуществующий платеж
  procedure neg_fail_payment__payment_not_found is
    c_api constant varchar2(100 char) := upper('payment_api_pack.fail_payment');
    c_test constant varchar2(100 char) := 'Задан несуществующий платеж';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
    payment_api_pack.fail_payment(634534564675686786879);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_payment_not_found then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Сброс платежа в "ошибочный статус". Платеж находится не в статус "Создан"
  procedure neg_fail_payment__payment_status_error is
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
    when common_pack.e_payment_status_error then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Отмена платежа. Не задан платеж
  procedure neg_cancel_payment__empty_payment_id is
    c_api constant varchar2(100 char) := upper('payment_api_pack.cancel_payment');
    c_test constant varchar2(100 char) := 'Не задан платеж';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
    payment_api_pack.cancel_payment(null);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_empty_payment_id then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Отмена платежа. Задан несуществующий платеж
  procedure neg_cancel_payment__payment_not_found is
    c_api constant varchar2(100 char) := upper('payment_api_pack.cancel_payment');
    c_test constant varchar2(100 char) := 'Задан несуществующий платеж';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
    payment_api_pack.cancel_payment(634534564675686786879);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_payment_not_found then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Отмена платежа. Платеж находится не в статус "Создан"
  procedure neg_cancel_payment__payment_status_error is
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
    when common_pack.e_payment_status_error then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Отмена платежа. Не задана причина отмены платежа
  procedure neg_cancel_payment__empty_status_change_reason is
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
    when common_pack.e_empty_status_change_reason then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Успешное завершение платежа. Не задан платеж
  procedure neg_successful_finish_payment__empty_payment_id is
    c_api constant varchar2(100 char) := upper('payment_api_pack.successful_finish_payment');
    c_test constant varchar2(100 char) := 'Не задан платеж';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
    payment_api_pack.successful_finish_payment(null);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_empty_payment_id then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Успешное завершение платежа. Задан несуществующий платеж
  procedure neg_successful_finish_payment__payment_not_found is
    c_api constant varchar2(100 char) := upper('payment_api_pack.successful_finish_payment');
    c_test constant varchar2(100 char) := 'Задан несуществующий платеж';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
    payment_api_pack.successful_finish_payment(634534564675686786879);
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_payment_not_found then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Успешное завершение платежа. Платеж находится не в статус "Создан"
  procedure neg_successful_finish_payment__payment_status_error is
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
    when common_pack.e_payment_status_error then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Данные платежа добавлены или обновлены. Не задан платеж
  procedure neg_insert_or_update_payment_detail__empty_payment_id is
    c_api constant varchar2(100 char) := upper('payment_detail_api_pack.insert_or_update_payment_detail');
    c_test constant varchar2(100 char) := 'Не задан платеж';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
    payment_detail_api_pack.insert_or_update_payment_detail(
      null,
      t_payment_detail_array(t_payment_detail(common_pack.c_payment_detail_field_id_note, 'Юнит-Тест')));
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_empty_payment_id then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Данные платежа добавлены или обновлены. Задан несуществующий платеж
  procedure neg_insert_or_update_payment_detail__payment_not_found is
    c_api constant varchar2(100 char) := upper('payment_detail_api_pack.insert_or_update_payment_detail');
    c_test constant varchar2(100 char) := 'Задан несуществующий платеж';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
    payment_detail_api_pack.insert_or_update_payment_detail(
      123345345345345,
      t_payment_detail_array(t_payment_detail(common_pack.c_payment_detail_field_id_note, 'Юнит-Тест')));
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_payment_not_found then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Данные платежа добавлены или обновлены. Не заданы детали платежа
  procedure neg_insert_or_update_payment_detail__empty_payment_details is
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
    when common_pack.e_empty_payment_details then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Данные платежа добавлены или обновлены. Не задан ID детали платежа
  procedure neg_insert_or_update_payment_detail__empty_field_id is
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
    when common_pack.e_empty_field_id then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Данные платежа добавлены или обновлены. Не задано значения детали платежа
  procedure neg_insert_or_update_payment_detail__empty_field_value is
    c_api constant varchar2(100 char) := upper('payment_detail_api_pack.insert_or_update_payment_detail');
    c_test constant varchar2(100 char) := 'Не задано значения детали платежа';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);

    for r in (select payment_id
              from payment
              where rownum = 1) loop
      payment_detail_api_pack.insert_or_update_payment_detail(
        r.payment_id,
        t_payment_detail_array(t_payment_detail(common_pack.c_payment_detail_field_id_note, '')));
      raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
    end loop;
  exception
    when common_pack.e_empty_field_value then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Детали платежа удалены. Не задан платеж
  procedure neg_delete_payment_detail__empty_payment_id is
    c_api constant varchar2(100 char) := upper('payment_detail_api_pack.delete_payment_detail');
    c_test constant varchar2(100 char) := 'Не задан платеж';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
    payment_detail_api_pack.delete_payment_detail(
      null,
      t_number_array(common_pack.c_payment_detail_field_id_ip, common_pack.c_payment_detail_field_id_is_checked));
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_empty_payment_id then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Детали платежа удалены. Задан несуществующий платеж
  procedure neg_delete_payment_detail__payment_not_found is
    c_api constant varchar2(100 char) := upper('payment_detail_api_pack.delete_payment_detail');
    c_test constant varchar2(100 char) := 'Задан несуществующий платеж';
  begin
    dbms_output.put_line('API: ' || c_api || '. Test: ' || c_test);
    payment_detail_api_pack.delete_payment_detail(
      1111122222233334444,
      t_number_array(common_pack.c_payment_detail_field_id_ip, common_pack.c_payment_detail_field_id_is_checked));
    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_payment_not_found then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;



  ----------------------------------------------------------------------------------------------------------------------
  --Positive. Таблица PAYMENT. Прямое удаление записей при отключенном глобальном запрете
  procedure pos_direct_dml__payment_delete is
    c_api constant varchar2(100 char) := upper('delete from payment');
    c_test constant varchar2(100 char)
      := 'Прямое удаление записей при отключенном глобальном запрете' ;
  begin
    dbms_output.put_line('Operation: ' || c_api || '. Test: ' || c_test);

    common_pack.disable_api;

    for r in (select a.payment_id
              from payment a
              where not exists
                      (select 1
                       from payment_detail b
                       where b.payment_id = a.payment_id)
                    and rownum = 1) loop
      delete from payment
      where payment_id = r.payment_id;

      if sql%rowcount = 1 then
        dbms_output.put_line('Платеж PAYMENT_ID=' || r.payment_id || ' удален');
      else
        raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
      end if;
    end loop;

    common_pack.enable_api;
  exception
    when common_pack.e_payment_api_restriction then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
      common_pack.enable_api;
    when others then
      common_pack.enable_api;
      raise;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Positive. Таблица PAYMENT. Прямое изменение записей при отключенном глобальном запрете
  procedure pos_direct_dml__payment_update is
    c_api constant varchar2(100 char) := upper('update payment');
    c_test constant varchar2(100 char)
      := 'Прямое изменение записей при отключенном глобальном запрете' ;
  begin
    dbms_output.put_line('Operation: ' || c_api || '. Test: ' || c_test);

    common_pack.disable_api;

    for r in (select a.payment_id
              from payment a
              where rownum = 1) loop
      update payment
      set payment_id = payment_id
      where payment_id = r.payment_id;

      if sql%rowcount = 1 then
        dbms_output.put_line('Платеж PAYMENT_ID=' || r.payment_id || ' изменен');
      else
        raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
      end if;
    end loop;

    common_pack.enable_api;
  exception
    when common_pack.e_payment_api_restriction then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
      common_pack.enable_api;
    when others then
      common_pack.enable_api;
      raise;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Positive. Таблица PAYMENT_DETAIL. Прямое изменение записей при отключенном глобальном запрете
  procedure pos_direct_dml__payment_detail_update is
    c_api constant varchar2(100 char) := upper('update payment_detail');
    c_test constant varchar2(100 char)
      := 'Прямое изменение записей при отключенном глобальном запрете' ;
  begin
    dbms_output.put_line('Operation: ' || c_api || '. Test: ' || c_test);

    common_pack.disable_api;

    for r in (select a.payment_id, a.field_id, a.field_value
              from payment_detail a
              where rownum = 1) loop
      update payment_detail
      set payment_id = payment_id
      where payment_id = r.payment_id and field_id = r.field_id and field_value = r.field_value;

      if sql%rowcount = 1 then
        dbms_output.put_line('Деталь платежа PAYMENT_ID=' || r.payment_id || ' изменена');
      else
        raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
      end if;
    end loop;

    common_pack.enable_api;
  exception
    when common_pack.e_payment_api_restriction then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
      common_pack.enable_api;
    when others then
      common_pack.enable_api;
      raise;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Таблица PAYMENT. Прямая вставка записей
  procedure neg_direct_dml__payment_insert is
    c_api constant varchar2(100 char) := upper('insert into payment');
    c_test constant varchar2(100 char) := 'Прямая вставка записей запрещена';
  begin
    dbms_output.put_line('Operation: ' || c_api || '. Test: ' || c_test);

    insert into payment(payment_id)
    values (1234456345455);

    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_payment_api_restriction then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Таблица PAYMENT_DETAIL. Прямое изменение записей
  procedure neg_direct_dml__payment_update is
    c_api constant varchar2(100 char) := upper('update payment');
    c_test constant varchar2(100 char) := 'Прямое изменение записей запрещено';
  begin
    dbms_output.put_line('Operation: ' || c_api || '. Test: ' || c_test);

    update payment
    set payment_id = payment_id
    where payment_id = 12355345345;


    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_payment_api_restriction then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Таблица PAYMENT_DETAIL. Прямое удаление записей
  procedure neg_direct_dml__payment_delete is
    c_api constant varchar2(100 char) := upper('delete from payment');
    c_test constant varchar2(100 char) := 'Удаление записей запрещено';
  begin
    dbms_output.put_line('Operation: ' || c_api || '. Test: ' || c_test);

    update payment
    set payment_id = payment_id
    where payment_id = 12355345345;

    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_payment_api_restriction then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Таблица PAYMENT_DETAIL. Прямая вставка записей
  procedure neg_direct_dml__payment_detail_insert is
    c_api constant varchar2(100 char) := upper('insert into payment_detail');
    c_test constant varchar2(100 char) := 'Прямая вставка записей запрещена';
  begin
    dbms_output.put_line('Operation: ' || c_api || '. Test: ' || c_test);

    insert into payment_detail(payment_id)
    values (1234453446);

    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_payment_detail_api_restriction then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Таблица PAYMENT_DETAIL. Прямое изменение записей
  procedure neg_direct_dml__payment_detail_update is
    c_api constant varchar2(100 char) := upper('update payment_detail');
    c_test constant varchar2(100 char) := 'Прямое изменение записей запрещено';
  begin
    dbms_output.put_line('Operation: ' || c_api || '. Test: ' || c_test);

    update payment_detail
    set payment_id = payment_id
    where payment_id = 13346485665;

    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_payment_detail_api_restriction then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Negative. Таблица PAYMENT_DETAIL. Прямое удаление записей
  procedure neg_direct_dml__payment_detail_delete is
    c_api constant varchar2(100 char) := upper('delete from payment_detail');
    c_test constant varchar2(100 char) := 'Прямое удаление записей запрещено';
  begin
    dbms_output.put_line('Operation: ' || c_api || '. Test: ' || c_test);

    delete from payment_detail
    where payment_id = 133333335;

    raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  exception
    when common_pack.e_payment_detail_api_restriction then
      dbms_output.put_line(sqlerrm);
      dbms_output.put_line('--');
  end;
begin
  --API.Positive:
  if 1 = 1 then
    dbms_output.put_line('============ Positive Tests for API ============');
    pos_create_payment;
    pos_fail_payment;
    pos_cancel_payment;
    pos_successful_finish_payment;
    pos_insert_or_update_payment_detail;
    pos_delete_payment_detail;
  end if;

  if 1 = 1 then
    dbms_output.put_line('============ Negative Tests for API ============');

    --create_payment:
    if 1 = 1 then
      dbms_output.put_line('============ 1.create_payment ============');
      neg_create_payment__empty_field_value;
      neg_create_payment__empty_field_id;
      neg_create_payment__empty_payment_details;
    end if;

    --fail_payment:
    if 1 = 1 then
      dbms_output.put_line('============ 2.fail_payment ============');
      neg_fail_payment__empty_payment_id;
      neg_fail_payment__payment_not_found;
      neg_fail_payment__payment_status_error;
    end if;

    --cancel_payment:
    if 1 = 1 then
      dbms_output.put_line('============ 3.cancel_payment ============');
      neg_cancel_payment__empty_payment_id;
      neg_cancel_payment__payment_not_found;
      neg_cancel_payment__payment_status_error;
      neg_cancel_payment__empty_status_change_reason;
    end if;

    --successful_finish_payment:
    if 1 = 1 then
      dbms_output.put_line('============ 4.successful_finish_payment ============');
      neg_successful_finish_payment__empty_payment_id;
      neg_successful_finish_payment__payment_not_found;
      neg_successful_finish_payment__payment_status_error;
    end if;

    --insert_or_update_payment_detail:
    if 1 = 1 then
      dbms_output.put_line('============ 5.insert_or_update_payment_detail ============');
      neg_insert_or_update_payment_detail__empty_payment_id;
      neg_insert_or_update_payment_detail__payment_not_found;
      neg_insert_or_update_payment_detail__empty_payment_details;
      neg_insert_or_update_payment_detail__empty_field_id;
      neg_insert_or_update_payment_detail__empty_field_value;
    end if;

    --delete_payment_detail:
    if 1 = 1 then
      dbms_output.put_line('============ 6.delete_payment_detail ============');
      neg_delete_payment_detail__empty_payment_id;
      neg_delete_payment_detail__payment_not_found;
    end if;
  end if;

  --DIRECT_DML.Positive
  if 1 = 1 then
    dbms_output.put_line('============ Positive Tests for Direct DML ============');
    pos_direct_dml__payment_delete;
    pos_direct_dml__payment_update;
    pos_direct_dml__payment_detail_update;
  end if;

  --DIRECT_DML.Negative
  if 1 = 1 then
    dbms_output.put_line('============ Negative Tests for Direct DML ============');
    neg_direct_dml__payment_insert;
    neg_direct_dml__payment_update;
    neg_direct_dml__payment_delete;
    neg_direct_dml__payment_detail_insert;
    neg_direct_dml__payment_detail_update;
    neg_direct_dml__payment_detail_delete;
  end if;
end;
/