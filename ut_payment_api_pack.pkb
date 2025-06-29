CREATE OR REPLACE PACKAGE BODY ut_payment_api_pack is
  ----------------------------------------------------------------------------------------------------------------------
  --Создание платежа.
  procedure create_payment is
    v_payment_id payment.payment_id%type;
    v_payment payment%rowtype;
  begin
    --Создать платеж со случайными данными
    v_payment_id := payment_api_pack.create_payment(
                      p_create_dtime => systimestamp,
                      p_from_client_id => ut_common_pack.create_random_client(),
                      p_to_client_id => ut_common_pack.create_random_client(),
                      p_summa => ut_common_pack.get_random_payment_summa(),
                      p_currency_id => ut_common_pack.get_random_currency_id,
                      p_payment_details => t_payment_detail_array(
                                            t_payment_detail(
                                              payment_detail_api_pack.c_payment_detail_field_id_client_software,
                                              ut_common_pack.get_random_payment_detail_client_software()),
                                            t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_ip,
                                                             ut_common_pack.get_random_payment_detail_ip()),
                                            t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_note,
                                                             ut_common_pack.get_random_payment_detail_note())));


    --Получаем данные созданного платежа
    v_payment := ut_common_pack.get_payment_record(v_payment_id);

    --Проверяем корректность статуса
    ut.expect(v_payment.status, 'Статус платежа не равен статусу "Создан"').to_equal(
      payment_api_pack.c_status_created);

    --Проверка на одинаковость технической даты создания и даты изменения
    ut.expect(
      v_payment.create_dtime_tech,
      'Дата создания платежа и дата изменения платежа отличаются').to_equal(
      v_payment.update_dtime_tech);
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Создание платежа с пустым ID детали платежа завершается ошибкой
  procedure create_payment_with_empty_field_id_should_fail is
    v_payment_id payment.payment_id%type;
  begin
    ut_common_pack.create_default_payment(
      p_payment_details => t_payment_detail_array(
                            t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_client_software,
                                             'Клинет-банк какой-то'),
                            t_payment_detail(null, '123.1.2.3'),
                            t_payment_detail(payment_detail_api_pack.c_payment_detail_field_id_note,
                                             'Тестовый переводик')));
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Создание платежа c пустыми деталями платежа завершается ошибкой
  procedure create_payment_with_empty_payment_details_should_fail is
    v_payment_id payment.payment_id%type;
  begin
    ut_common_pack.create_default_payment(p_payment_details => t_payment_detail_array());
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Сброс платежа в "ошибочный статус".
  procedure fail_payment is
    v_payment_id payment.payment_id%type := ut_common_pack.get_default_payment_id;
    v_payment_before payment%rowtype;
    v_payment_after payment%rowtype;
  begin
    --Получаем данные платежа до изменения
    v_payment_before := ut_common_pack.get_payment_record(v_payment_id);

    --Тестовый API
    payment_api_pack.fail_payment(v_payment_id);

    --Получаем данные платежа после изменения
    v_payment_after := ut_common_pack.get_payment_record(v_payment_id);

    --Проверка изменения статуса
    ut.expect(v_payment_after.status,
              'Статус платежа не равен статусу "Ошибочный статус"').to_equal(
      payment_api_pack.c_status_failed);

    --Проверка на то, что дата изменения поменялась
    ut.expect(v_payment_after.update_dtime_tech,
              'Дата изменения платежа не поменялась').not_to_equal(
      v_payment_before.update_dtime_tech);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Сброс платежа в "ошибочный статус" c пустым ID платежа завершается ошибкой
  procedure fail_payment_with_empty_payment_id_should_fail is
  begin
    payment_api_pack.fail_payment(null);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Сброс платежа в "ошибочный статус" c несуществующим ID платежа завершается ошибкой
  procedure fail_payment_with_unknown_payment_id_should_fail is
  begin
    payment_api_pack.fail_payment(ut_common_pack.c_not_existing_payment_id);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Сброс платежа в "ошибочный статус" находящегося не в статус "Создан" завершается с ошибкой
  procedure fail_payment_with_not_created_status_should_fail is
    v_payment_id payment.payment_id%type := ut_common_pack.get_default_payment_id;
  begin
    --Setup. Перевести созданный платеж в статус "Успешно исполнен" (как пример, можно и в любой другой статус)
    payment_api_pack.successful_finish_payment(v_payment_id);

    --API
    payment_api_pack.fail_payment(v_payment_id);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Отмена платежа.
  procedure cancel_payment is
    v_payment_id payment.payment_id%type := ut_common_pack.get_default_payment_id;
    v_payment_before payment%rowtype;
    v_payment_after payment%rowtype;
  begin
    --Получаем данные платежа до изменения
    v_payment_before := ut_common_pack.get_payment_record(v_payment_id);

    --Тестовый API
    payment_api_pack.cancel_payment(v_payment_id);

    --Получаем данные платежа после изменения
    v_payment_after := ut_common_pack.get_payment_record(v_payment_id);

    --Проверка изменения статуса
    ut.expect(v_payment_after.status, 'Статус платежа не равен статусу "Отменен"').to_equal(
      payment_api_pack.c_status_canceled);

    --Проверка на то, что дата изменения поменялась
    ut.expect(v_payment_after.update_dtime_tech,
              'Дата изменения платежа не поменялась').not_to_equal(
      v_payment_before.update_dtime_tech);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Отмена платежа c не заданым ID платежа завершается ошибкой
  procedure cancel_payment_with_empty_payment_id_should_fail is
  begin
    payment_api_pack.cancel_payment(null);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Отмена платежа c несуществующим ID платежа завершается ошибкой
  procedure cancel_payment_with_unknown_payment_should_fail is
  begin
    payment_api_pack.cancel_payment(ut_common_pack.c_not_existing_payment_id);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Отмена платежа находящегося не в статусе "Создан" завершается ошибкой
  procedure cancel_payment_with_not_created_status_should_fail is
    v_payment_id payment.payment_id%type := ut_common_pack.get_default_payment_id;
  begin
    --Setup. Перевести созданный платеж в статус "Успешно исполнен" (как пример, можно и в любой другой статус)
    payment_api_pack.successful_finish_payment(v_payment_id);

    --API
    payment_api_pack.cancel_payment(v_payment_id);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Отмена платежа без указания причины завершается ошибкой
  procedure cancel_payment_without_status_change_reason_should_fail is
    v_payment_id payment.payment_id%type := ut_common_pack.get_default_payment_id;
  begin
    payment_api_pack.cancel_payment(v_payment_id, null);
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Успешное завершение платежа.
  procedure successful_finish_payment is
    v_payment_id payment.payment_id%type := ut_common_pack.get_default_payment_id;
    v_payment_before payment%rowtype;
    v_payment_after payment%rowtype;
  begin
    --Получаем данные платежа до изменения
    v_payment_before := ut_common_pack.get_payment_record(v_payment_id);

    --Тестовый API
    payment_api_pack.successful_finish_payment(v_payment_id);

    --Получаем данные платежа после изменения
    v_payment_after := ut_common_pack.get_payment_record(v_payment_id);

    --Проверка изменения статуса
    ut.expect(v_payment_after.status,
              'Статус платежа не равен статусу "Успешно завершен"').to_equal(
      payment_api_pack.c_status_completed);

    --Проверка на то, что дата изменения поменялась
    ut.expect(v_payment_after.update_dtime_tech,
              'Дата изменения платежа не поменялась').not_to_equal(
      v_payment_before.update_dtime_tech);
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Успешное завершение платежа c незаданным ID платежа завершается ошибкой
  procedure successful_finish_payment_with_empty_payment_id_should_fail is
  begin
    payment_api_pack.successful_finish_payment(null);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Успешное завершение платежа с несуществующим ID платежа завершается ошибкой
  procedure successful_finish_payment_with_unknown_payment_id_should_fail is
  begin
    payment_api_pack.successful_finish_payment(ut_common_pack.c_not_existing_payment_id);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Успешное завершение платежа находящегося не в статусе "Создан" завершается ошибкой
  procedure successful_finish_payment_with_not_created_status_should_fail is
    v_payment_id payment.payment_id%type := ut_common_pack.get_default_payment_id;
  begin
    --Setup. Перевести созданный платеж в статус "Успешно исполнен" (как пример, можно и в любой другой статус)
    payment_api_pack.successful_finish_payment(v_payment_id);

    payment_api_pack.successful_finish_payment(v_payment_id);
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Прямое изменение записей в таблице PAYMENT при отключенном глобальном запрете
  procedure direct_update_payment_with_disabled_api is
    v_payment_id payment.payment_id%type := ut_common_pack.get_default_payment_id;
    v_payment_before payment%rowtype;
    v_payment_after payment%rowtype;
  begin
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
    ut.expect(v_payment_after.update_dtime_tech,
              'Дата изменения платежа не поменялась').not_to_equal(
      v_payment_before.update_dtime_tech);
  exception
    when others then
      common_pack.enable_api;
      raise;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Прямое удаление записей в таблице PAYMENT при отключенном глобальном запрете
  procedure direct_delete_payment_with_disabled_api is
    v_payment_id payment.payment_id%type := ut_common_pack.get_default_payment_id;
  begin
    --Удалить все детали платежа, иначе будет ошибка по внешнему ключу
    payment_detail_api_pack.delete_payment_detail(
      v_payment_id,
      t_number_array(payment_detail_api_pack.c_payment_detail_field_id_client_software,
                     payment_detail_api_pack.c_payment_detail_field_id_ip,
                     payment_detail_api_pack.c_payment_detail_field_id_is_checked,
                     payment_detail_api_pack.c_payment_detail_field_id_note));
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
               payment_api_pack.c_status_created)
    returning payment_id
    into v_payment_id;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Прямое изменение записей в таблице PAYMENT при влюченном глобальном запрете завершается ошибкой)
  procedure direct_update_payment_with_enabled_api_should_fail is
    v_payment_id payment.payment_id%type := ut_common_pack.get_default_payment_id;
  begin
    update payment
    set payment_id = payment_id
    where payment_id = v_payment_id;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Прямое изменение записей в таблице PAYMENT при влюченном глобальном запрете завершается ошибкой)
  procedure direct_delete_payment_with_enabled_api_should_fail is
    v_payment_id payment.payment_id%type := ut_common_pack.get_default_payment_id;
  begin
    delete from payment
    where payment_id = v_payment_id;
  end;
end ut_payment_api_pack;
/
