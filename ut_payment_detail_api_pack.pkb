CREATE OR REPLACE PACKAGE BODY ut_payment_detail_api_pack is
  ----------------------------------------------------------------------------------------------------------------------
  --Добавление или обновление данных платежа
  procedure insert_or_update_payment_detail is
    v_payment_detail_field_value_note payment_detail.field_value%type
      := ut_common_pack.get_random_payment_detail_note();
    v_payment_detail_field_value_ip payment_detail.field_value%type := ut_common_pack.get_random_payment_detail_ip();
    v_payment_detail_field_value_client_software payment_detail.field_value%type
      := ut_common_pack.get_random_payment_detail_client_software();
    --
    v_payment_detail_array t_payment_detail_array
      := t_payment_detail_array(
           t_payment_detail(common_pack.c_payment_detail_field_id_note, v_payment_detail_field_value_note),
           t_payment_detail(common_pack.c_payment_detail_field_id_ip, v_payment_detail_field_value_ip),
           t_payment_detail(common_pack.c_payment_detail_field_id_client_software,
                            v_payment_detail_field_value_client_software));
    v_payment_id payment.payment_id%type;
  begin
    --Setup и тестовый API
    v_payment_id := ut_common_pack.create_random_payment(v_payment_detail_array);

    --Получить детали платежа и сравнить с тем, что передавали при создании
    ut.expect(v_payment_detail_field_value_note,
              'Значения поля "Примечание" отличаются').to_equal(
      ut_common_pack.get_payment_detail_field_value(v_payment_id, common_pack.c_payment_detail_field_id_note));

    ut.expect(v_payment_detail_field_value_ip,
              'Значения поля "IP-адрес плательщика" отличаются').to_equal(
      ut_common_pack.get_payment_detail_field_value(v_payment_id, common_pack.c_payment_detail_field_id_ip));

    ut.expect(v_payment_detail_field_value_client_software,
              'Значения поля "Клиентское ПО" отличаются').to_equal(
      ut_common_pack.get_payment_detail_field_value(v_payment_id,
                                                    common_pack.c_payment_detail_field_id_client_software));
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Добавление или обновление данных платежа с пустым ID платежа завершается ошибкой
  procedure insert_or_update_payment_detail_with_empty_payment_id_should_fail is
    v_payment_detail_array t_payment_detail_array
      := t_payment_detail_array(
           t_payment_detail(common_pack.c_payment_detail_field_id_note,
                            ut_common_pack.get_random_payment_detail_note()),
           t_payment_detail(common_pack.c_payment_detail_field_id_ip, ut_common_pack.get_random_payment_detail_note()));
    v_payment_id payment.payment_id%type;
  begin
    payment_detail_api_pack.insert_or_update_payment_detail(null, v_payment_detail_array);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Добавление или обновление данных платежа с несуществующим ID платежа завершается ошибкой
  procedure insert_or_update_payment_detail_with_unknown_payment_id_should_fail is
    v_payment_id payment.payment_id%type := ut_common_pack.g_payment_id;
  begin
    --Тестовый API
    payment_detail_api_pack.insert_or_update_payment_detail(
      ut_common_pack.c_not_existing_client_id,
      t_payment_detail_array(
        t_payment_detail(common_pack.c_payment_detail_field_id_note, ut_common_pack.get_random_payment_detail_note())));
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Добавление или обновление данных платежа с пустыми деталями платежа завершается ошибкой
  procedure insert_or_update_payment_detail_with_empty_payment_details_should_fail is
    v_payment_id payment.payment_id%type := ut_common_pack.g_payment_id;
  begin
    payment_detail_api_pack.insert_or_update_payment_detail(v_payment_id, t_payment_detail_array());
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Добавление или обновление данных платежа с пустым ID деталей платежа завершается ошибкой
  procedure insert_or_update_payment_detail_with_empty_field_id_should_fail is
    v_payment_id payment.payment_id%type := ut_common_pack.g_payment_id;
  begin
    payment_detail_api_pack.insert_or_update_payment_detail(
      v_payment_id,
      t_payment_detail_array(t_payment_detail(null, 'Юнит-Тест')));
  --exception
  --  when common_pack.e_empty_field_id then
  --    null;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Добавление или обновление данных платежа с пустым значением деталей платежа завершается ошибкой
  procedure insert_or_update_payment_detail_with_empty_field_value_should_fail is
    v_payment_id payment.payment_id%type := ut_common_pack.g_payment_id;
  begin
    payment_detail_api_pack.insert_or_update_payment_detail(
      v_payment_id,
      t_payment_detail_array(t_payment_detail(common_pack.c_payment_detail_field_id_note, '')));
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Удаление деталей платежа
  procedure delete_payment_detail is
    v_payment_id payment.payment_id%type := ut_common_pack.g_payment_id;
  begin
    payment_detail_api_pack.delete_payment_detail(
      v_payment_id,
      t_number_array(common_pack.c_payment_detail_field_id_ip, common_pack.c_payment_detail_field_id_is_checked));

    --Проверяем, что значения удаленных полей нулевые
    ut.expect(ut_common_pack.get_payment_detail_field_value(v_payment_id, common_pack.c_payment_detail_field_id_ip),
              'Значение поля "IP-адрес" ненулевое').to_equal('');

    ut.expect(
      ut_common_pack.get_payment_detail_field_value(v_payment_id, common_pack.c_payment_detail_field_id_is_checked),
      'Значение поля "Метка" ненулевое').to_equal('');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Удаление деталей платежа с пустым ID платежа завершается с ошибкой
  procedure delete_payment_detail_with_empty_payment_id_should_fail is
  begin
    payment_detail_api_pack.delete_payment_detail(
      null,
      t_number_array(common_pack.c_payment_detail_field_id_ip, common_pack.c_payment_detail_field_id_is_checked));
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Удаление деталей платежа с несуществующем ID платежа завершается с ошибкой
  procedure delete_payment_detail_with_unknown_payment_should_fail is
  begin
    payment_detail_api_pack.delete_payment_detail(
      ut_common_pack.c_not_existing_payment_id,
      t_number_array(common_pack.c_payment_detail_field_id_ip, common_pack.c_payment_detail_field_id_is_checked));
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Прямая вставка записей в таблицу PAYMENT_DETAIL при отключенном глобальном запрете
  procedure direct_insert_payment_with_disabled_api is
    v_payment_id payment.payment_id%type := ut_common_pack.g_payment_id;
  begin
    payment_detail_api_pack.delete_payment_detail(v_payment_id,
                                                  t_number_array(common_pack.c_payment_detail_field_id_note));

    common_pack.disable_api;

    insert into payment_detail(payment_id, field_id, field_value)
    values (v_payment_id, common_pack.c_payment_detail_field_id_note, 'Test');

    if sql%rowcount <> 1 then
      ut_common_pack.ut_failed;
    end if;

    common_pack.enable_api;
  exception
    when others then
      common_pack.enable_api;
      raise;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Прямое изменение записей в таблице PAYMENT_DETAIL при отключенном глобальном запрете
  procedure direct_update_payment_with_disabled_api is
    v_payment_id payment.payment_id%type := ut_common_pack.g_payment_id;
  begin
    common_pack.disable_api;

    update payment_detail
    set field_value = 'Test'
    where payment_id = v_payment_id and field_id = common_pack.c_payment_detail_field_id_note;


    if sql%rowcount <> 1 then
      ut_common_pack.ut_failed;
    end if;

    common_pack.enable_api;
  exception
    when others then
      common_pack.enable_api;
      raise;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Прямое удаление записей в таблице PAYMENT_DETAIL при отключенном глобальном запрете
  procedure direct_delete_payment_with_disabled_api is
    v_payment_id payment.payment_id%type := ut_common_pack.g_payment_id;
  begin
    common_pack.disable_api;

    delete from payment_detail
    where payment_id = v_payment_id and field_id = common_pack.c_payment_detail_field_id_note;

    if sql%rowcount <> 1 then
      ut_common_pack.ut_failed;
    end if;

    common_pack.enable_api;
  exception
    when others then
      common_pack.enable_api;
      raise;
  end;


  ----------------------------------------------------------------------------------------------------------------------
  --Прямая вставка записей в таблицу PAYMENT_DETAIL при включенном глобальном запрете завершается оибкой
  procedure direct_insert_payment_with_enabled_api is
    v_payment_id payment.payment_id%type := ut_common_pack.g_payment_id;
  begin
    --Удалить "Примечание"
    payment_detail_api_pack.delete_payment_detail(v_payment_id,
                                                  t_number_array(common_pack.c_payment_detail_field_id_note));

    insert into payment_detail(payment_id, field_id, field_value)
    values (v_payment_id, common_pack.c_payment_detail_field_id_note, 'Test');
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Прямое изменение записей в таблице PAYMENT_DETAIL при включенном глобальном запрете завершается ошибкой
  procedure direct_update_payment_with_enabled_api is
    v_payment_id payment.payment_id%type := ut_common_pack.g_payment_id;
  begin
    update payment_detail
    set field_value = 'Test'
    where payment_id = v_payment_id and field_id = common_pack.c_payment_detail_field_id_note;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Прямое удаление записей в таблице PAYMENT_DETAIL при включенном глобальном запрете завершается ошибкой
  procedure direct_delete_payment_with_enabled_api is
    v_payment_id payment.payment_id%type := ut_common_pack.g_payment_id;
  begin
    --Надо сначала удалить существующую деталь
    payment_detail_api_pack.delete_payment_detail(v_payment_id,
                                                  t_number_array(common_pack.c_payment_detail_field_id_note));

    delete payment_detail
    where payment_id = v_payment_id and field_id = common_pack.c_payment_detail_field_id_note;
  end;
end ut_payment_detail_api_pack;
