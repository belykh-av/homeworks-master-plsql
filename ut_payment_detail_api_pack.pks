CREATE OR REPLACE PACKAGE ut_payment_detail_api_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: Тесты по деталям платежа
  -- Автор: Белых Андрей
  -- 13.06.2025. Создано в ДЗ18
  -- 29.06.2025. Изменено в ДЗ19. Переделка под utPL/SQL
  -- 29.06.2025. Скорретировано с учетом замечаний в ДЗ19.
  ---------------------------------------------------------------------------------------------------------------------
  --%suite(Unit-tests for PAYMENT_DETAIL)

  ------------------ API: insert_or_update_payment_detail ------------------------------------

  --%test(Добавление или обновление данных платежа)
  procedure insert_or_update_payment_detail;

  --%test(Добавление или обновление данных платежа с пустым ID платежа завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_api_pack.c_error_code_empty_payment_id)
  procedure insert_or_update_payment_detail_with_empty_payment_id_should_fail;

  --%test(Добавление или обновление данных платежа с несуществующим ID платежа завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_api_pack.c_error_code_payment_not_found)
  procedure insert_or_update_payment_detail_with_unknown_payment_id_should_fail;

  --%test(Добавление или обновление данных платежа с пустыми деталями платежа завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_detail_api_pack.c_error_code_empty_payment_details)
  procedure insert_or_update_payment_detail_with_empty_payment_details_should_fail;

  --%test(Добавление или обновление данных платежа с пустым ID деталей платежа завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_detail_api_pack.c_error_code_empty_field_id)
  procedure insert_or_update_payment_detail_with_empty_field_id_should_fail;

  --%test(Добавление или обновление данных платежа с пустым значением деталей платежа завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_detail_api_pack.c_error_code_empty_field_value)
  procedure insert_or_update_payment_detail_with_empty_field_value_should_fail;

  ------------------- API: delete_payment_detail ----------------------------------------------

  --%test(Удаление деталей платежа)
  --%beforetest(ut_common_pack.create_default_payment)
  procedure delete_payment_detail;

  --%test(Удаление деталей платежа с пустым ID платежа завершается с ошибкой)
  --%throws(payment_api_pack.c_error_code_empty_payment_id)
  procedure delete_payment_detail_with_empty_payment_id_should_fail;

  --%test(Удаление деталей платежа с несуществующем ID платежа завершается с ошибкой)
  --%throws(payment_api_pack.c_error_code_payment_not_found)
  procedure delete_payment_detail_with_unknown_payment_should_fail;


  -------------------- Direct DML -------------------------------------------------------

  --%test(Прямая вставка записей в таблицу PAYMENT_DETAIL при отключенном глобальном запрете)
  --%beforetest(ut_common_pack.create_default_payment)
  procedure direct_insert_payment_with_disabled_api;

  --%test(Прямое изменение записей в таблице PAYMENT_DETAIL при отключенном глобальном запрете)
  --%beforetest(ut_common_pack.create_default_payment)
  procedure direct_update_payment_with_disabled_api;

  --%test(Прямое удаление записей в таблице PAYMENT_DETAIL при отключенном глобальном запрете)
  --%beforetest(ut_common_pack.create_default_payment)
  procedure direct_delete_payment_with_disabled_api;

  --%test(Прямая вставка записей в таблицу PAYMENT_DETAIL при включенном глобальном запрете завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_detail_api_pack.c_error_code_payment_detail_api_restriction)
  procedure direct_insert_payment_with_enabled_api;

  --%test(Прямое изменение записей в таблице PAYMENT_DETAIL при включенном глобальном запрете завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_detail_api_pack.c_error_code_payment_detail_api_restriction)
  procedure direct_update_payment_with_enabled_api;

  --%test(Прямое удаление записей в таблице PAYMENT_DETAIL при включенном глобальном запрете завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_detail_api_pack.c_error_code_payment_detail_api_restriction)
  procedure direct_delete_payment_with_enabled_api;
end;
/
