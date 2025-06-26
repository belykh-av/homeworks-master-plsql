CREATE OR REPLACE PACKAGE BODY ut_payment_api_pack is
  ----------------------------------------------------------------------------------------------------------------------
  --Создание платежа.
  procedure create_payment is
    v_payment_id payment.payment_id%type;
    v_payment payment%rowtype;
  begin
    --Создать случайный платеж
    v_payment_id := ut_common_pack.create_random_payment_with_random_details();

    --Получаем данные созданного платежа
    v_payment := ut_common_pack.get_payment_record(v_payment_id);

    --Проверяем корректность статуса
    if v_payment.status <> common_pack.c_status_created then
      ut_common_pack.ut_failed;
    end if;

    --Проверка на одинаковость технической даты создания и даты изменения
    if v_payment.create_dtime_tech <> v_payment.update_dtime_tech then
      ut_common_pack.ut_failed;
    end if;
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Создание платежа с пустым ID детали платежа завершается ошибкой
  procedure create_payment_with_empty_field_id_should_fail is
    v_payment_id payment.payment_id%type;
  begin
    --Setup and API
    v_payment_id := ut_common_pack.create_random_payment(
                      p_payment_details => t_payment_detail_array(
                                            t_payment_detail(common_pack.c_payment_detail_field_id_client_software,
                                                             'Клинет-банк какой-то'),
                                            t_payment_detail(null, '123.1.2.3'),
                                            t_payment_detail(common_pack.c_payment_detail_field_id_note,
                                                             'Тестовый переводик')));
    ut_common_pack.ut_failed;
  exception
    when common_pack.e_empty_field_id then
      null;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Создание платежа c пустыми деталями платежа завершается ошибкой
  procedure create_payment_with_empty_payment_details_should_fail is
    v_payment_id payment.payment_id%type;
  begin
    --Setup and API
    v_payment_id := ut_common_pack.create_random_payment(p_payment_details => t_payment_detail_array());

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_empty_payment_details then
      null;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Сброс платежа в "ошибочный статус".
  procedure fail_payment is
    v_payment_id payment.payment_id%type;
    v_payment_before payment%rowtype;
    v_payment_after payment%rowtype;
  begin
    --Setup
    v_payment_id := ut_common_pack.create_random_payment_with_random_details();

    --Получаем данные платежа до изменения
    v_payment_before := ut_common_pack.get_payment_record(v_payment_id);

    --Тестовый API
    payment_api_pack.fail_payment(v_payment_id);

    --Получаем данные платежа после изменения
    v_payment_after := ut_common_pack.get_payment_record(v_payment_id);

    --Проверка изменения статуса
    if v_payment_after.status <> common_pack.c_status_failed then
      ut_common_pack.ut_failed;
    end if;

    --Проверка на то, что дата изменения поменялась
    if v_payment_after.update_dtime_tech = v_payment_before.update_dtime_tech then
      ut_common_pack.ut_failed;
    end if;
  end;



  ----------------------------------------------------------------------------------------------------------------------
  --Сброс платежа в "ошибочный статус" c пустым ID платежа завершается ошибкой
  procedure fail_payment_with_empty_payment_id_should_fail is
  begin
    --API
    payment_api_pack.fail_payment(null);

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_empty_payment_id then
      null;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Сброс платежа в "ошибочный статус" c несуществующим ID платежа завершается ошибкой
  procedure fail_payment_with_unknown_payment_id_should_fail is
  begin
    --API
    payment_api_pack.fail_payment(ut_common_pack.c_not_existing_payment_id);

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_payment_not_found then
      null;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Сброс платежа в "ошибочный статус" находящегося не в статус "Создан" завершается с ошибкой
  procedure fail_payment_with_not_created_status_should_fail is
    v_payment_id payment.payment_id%type;
  begin
    --Setup
    select max(payment_id)
    into v_payment_id
    from payment
    where status <> common_pack.c_status_created and rownum = 1;

    --Тестовый API
    if v_payment_id > 0 then
      payment_api_pack.fail_payment(v_payment_id);
    else
      raise_application_error(-20999, 'В базе нет платежей не в статусе "Создан"');
    end if;

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_payment_in_final_status then
      null;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Отмена платежа.
  procedure cancel_payment is
    v_payment_id payment.payment_id%type;
    v_payment_before payment%rowtype;
    v_payment_after payment%rowtype;
  begin
    --Setup
    v_payment_id := ut_common_pack.create_random_payment_with_random_details();

    --Получаем данные платежа до изменения
    v_payment_before := ut_common_pack.get_payment_record(v_payment_id);

    --Тестовый API
    payment_api_pack.cancel_payment(v_payment_id);

    --Получаем данные платежа после изменения
    v_payment_after := ut_common_pack.get_payment_record(v_payment_id);

    --Проверка изменения статуса
    if v_payment_after.status <> common_pack.c_status_canceled then
      ut_common_pack.ut_failed;
    end if;

    --Проверка на то, что дата изменения поменялась
    if v_payment_after.update_dtime_tech = v_payment_before.update_dtime_tech then
      ut_common_pack.ut_failed;
    end if;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Отмена платежа c не заданым ID платежа завершается ошибкой
  procedure cancel_payment_with_empty_payment_id_should_fail is
  begin
    --API
    payment_api_pack.cancel_payment(null);

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_empty_payment_id then
      null;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Отмена платежа c несуществующим ID платежа завершается ошибкой
  procedure cancel_payment_with_unknown_payment_should_fail is
  begin
    --API
    payment_api_pack.cancel_payment(ut_common_pack.c_not_existing_payment_id);

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_payment_not_found then
      null;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Отмена платежа находящегося не в статусе "Создан" завершается ошибкой
  procedure cancel_payment_with_not_created_status_should_fail is
    v_payment_id payment.payment_id%type;
  begin
    --Setup
    select max(payment_id)
    into v_payment_id
    from payment
    where status <> common_pack.c_status_created and rownum = 1;

    --Тестовый API
    if v_payment_id > 0 then
      payment_api_pack.cancel_payment(v_payment_id);
    else
      raise_application_error(-20999, 'В базе нет платежей не в статусе "Создан"');
    end if;

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_payment_in_final_status then
      null;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Отмена платежа без указания причины завершается ошибкой
  procedure cancel_payment_without_status_change_reason_should_fail is
    v_payment_id payment.payment_id%type;
  begin
    --Setup
    v_payment_id := ut_common_pack.create_random_payment_with_random_details();

    --API
    payment_api_pack.cancel_payment(v_payment_id, null);

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_empty_status_change_reason then
      null;
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Успешное завершение платежа.
  procedure successful_finish_payment is
    v_payment_id payment.payment_id%type;
    v_payment_before payment%rowtype;
    v_payment_after payment%rowtype;
  begin
    --Setup
    v_payment_id := ut_common_pack.create_random_payment_with_random_details();

    --Получаем данные платежа до изменения
    v_payment_before := ut_common_pack.get_payment_record(v_payment_id);

    --Тестовый API
    payment_api_pack.successful_finish_payment(v_payment_id);

    --Получаем данные платежа после изменения
    v_payment_after := ut_common_pack.get_payment_record(v_payment_id);

    --Проверка изменения статуса
    if v_payment_after.status <> common_pack.c_status_completed then
      ut_common_pack.ut_failed;
    end if;

    --Проверка на то, что дата изменения поменялась
    if v_payment_after.update_dtime_tech = v_payment_before.update_dtime_tech then
      ut_common_pack.ut_failed;
    end if;
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Успешное завершение платежа c незаданным ID платежа завершается ошибкой
  procedure successful_finish_payment_with_empty_payment_id_should_fail is
  begin
    --API
    payment_api_pack.successful_finish_payment(null);

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_empty_payment_id then
      null;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Успешное завершение платежа с несуществующим ID платежа завершается ошибкой
  procedure successful_finish_payment_with_unknown_payment_id_should_fail is
  begin
    --API
    payment_api_pack.successful_finish_payment(ut_common_pack.c_not_existing_payment_id);

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_payment_not_found then
      null;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Успешное завершение платежа находящегося не в статусе "Создан" завершается ошибкой
  procedure successful_finish_payment_with_not_created_status_should_fail is
    v_payment_id payment.payment_id%type;
  begin
    --Setup
    select max(payment_id)
    into v_payment_id
    from payment
    where status <> common_pack.c_status_created and rownum = 1;

    --Тестовый API
    if v_payment_id > 0 then
      payment_api_pack.successful_finish_payment(v_payment_id);
    else
      raise_application_error(-20999, 'В базе нет платежей не в статусе "Создан"');
    end if;

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_payment_in_final_status then
      null;
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Прямое изменение записей в таблице PAYMENT при отключенном глобальном запрете
  procedure direct_update_payment_with_disabled_api is
    v_payment_before payment%rowtype;
    v_payment_after payment%rowtype;
    v_payment_id payment.payment_id%type;
  begin
    --Setup
    v_payment_id := ut_common_pack.create_random_payment_with_random_details();

    --Получаем данные платежа до изменения
    v_payment_before := ut_common_pack.get_payment_record(v_payment_id);

    --Test
    common_pack.disable_api;

    update payment
    set payment_id = payment_id
    where payment_id = v_payment_id;

    common_pack.enable_api;

    --Получаем данные платежа после изменения
    v_payment_after := ut_common_pack.get_payment_record(v_payment_id);

    --Проверка на то, что дата изменения платежа поменялась
    if v_payment_after.update_dtime_tech = v_payment_before.update_dtime_tech then
      ut_common_pack.ut_failed;
    end if;
  exception
    when others then
      common_pack.enable_api;
      raise;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Прямое удаление записей в таблице PAYMENT при отключенном глобальном запрете
  procedure direct_delete_payment_with_disabled_api is
    v_payment_id payment.payment_id%type;
  begin
    --Setup
    v_payment_id := ut_common_pack.create_random_payment_with_random_details();

    --Удалить все детали платежа, иначе будет ошибка по внешнему ключу
    payment_detail_api_pack.delete_payment_detail(
      v_payment_id,
      t_number_array(common_pack.c_payment_detail_field_id_client_software,
                     common_pack.c_payment_detail_field_id_ip,
                     common_pack.c_payment_detail_field_id_is_checked,
                     common_pack.c_payment_detail_field_id_note));
    --Test
    common_pack.disable_api;

    delete from payment
    where payment_id = v_payment_id;

    common_pack.enable_api;

    --Проверка, что платеж удалился
    for r in (select 1
              from payment
              where payment_id = v_payment_id) loop
      ut_common_pack.ut_failed;
    end loop;
  exception
    when others then
      common_pack.enable_api;
      raise;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --(Прямая вставка записей в таблицу PAYMENT при влюченном глобальном запрете завершается ошибкой)
  procedure direct_insert_payment_with_enabled_api_should_fail is
    v_payment_id payment.payment_id%type;
    v_payment payment%rowtype;
  begin
    --Test
    insert into payment(payment_id, create_dtime, summa, currency_id, from_client_id, to_client_id, status)
      values (
               payment_seq.nextval,
               systimestamp,
               ut_common_pack.get_random_payment_summa(),
               ut_common_pack.get_random_currency_id,
               ut_common_pack.create_random_client(),
               ut_common_pack.create_random_client(),
               common_pack.c_status_created)
    returning payment_id
    into v_payment_id;

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_payment_api_restriction then
      null;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Прямое изменение записей в таблице PAYMENT при влюченном глобальном запрете завершается ошибкой)
  procedure direct_update_payment_with_enabled_api_should_fail is
    v_payment_id payment.payment_id%type;
  begin
    --Setup
    v_payment_id := ut_common_pack.create_random_payment_with_random_details();

    --Test
    update payment
    set payment_id = payment_id
    where payment_id = v_payment_id;

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_payment_api_restriction then
      null;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Прямое изменение записей в таблице PAYMENT при влюченном глобальном запрете завершается ошибкой)
  procedure direct_delete_payment_with_enabled_api_should_fail is
    v_payment_id payment.payment_id%type;
  begin
    --Setup
    v_payment_id := ut_common_pack.create_random_payment_with_random_details();

    --Test
    delete from payment
    where payment_id = v_payment_id;

    ut_common_pack.ut_failed;
  exception
    when common_pack.e_payment_deleting_restriction then
      null;
  end;
end ut_payment_api_pack;
