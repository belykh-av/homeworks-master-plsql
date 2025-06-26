CREATE OR REPLACE PACKAGE ut_payment_detail_api_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: Тесты по деталям платежа
  -- Автор: Белых Андрей
  -- 13.06.2025. Создано в ДЗ18
  ---------------------------------------------------------------------------------------------------------------------
  --%suite(Unit-tests for PAYMENT_DETAIL)

  ------------------ API: insert_or_update_payment_detail ------------------------------------

  --%test(Добавление или обновление данных платежа)
  procedure insert_or_update_payment_detail;

  --%test(Добавление или обновление данных платежа с пустым ID платежа завершается ошибкой)
  procedure insert_or_update_payment_detail_with_empty_payment_id_should_fail;

  --%test(Добавление или обновление данных платежа с несуществующим ID платежя завершается ошибкой)
  procedure insert_or_update_payment_detail_with_unknown_payment_id_should_fail;

  --%test(Добавление или обновление данных платежа с пустыми деталями платежа завершается ошибкой)
  procedure insert_or_update_payment_detail_with_empty_payment_details_should_fail;

  --%test(Добавление или обновление данных платежа с пустым ID деталей платежа завершается ошибкой)
  procedure insert_or_update_payment_detail_with_empty_field_id_should_fail;

  --%test(Добавление или обновление данных платежа с пустым значением деталей платежа завершается ошибкой)
  procedure insert_or_update_payment_detail_with_empty_field_value_should_fail;

  ------------------- API: delete_payment_detail ----------------------------------------------

  --%test(Удаление деталей платежа)
  procedure delete_payment_detail;

  --%test(Удаление деталей платежа с пустым ID платежа завершается с ошибкой)
  procedure delete_payment_detail_with_empty_payment_id_should_fail;

  --%test(Удаление деталей платежа с несуществующем ID платежа завершается с ошибкой
  procedure delete_payment_detail_with_unknown_payment_should_fail;


  -------------------- Direct DML -------------------------------------------------------

  --%test(Прямая вставка записей в таблицу PAYMENT_DETAIL при отключенном глобальном запрете)
  procedure direct_insert_payment_with_disabled_api;

  --%test(Прямое изменение записей в таблице PAYMENT_DETAIL при отключенном глобальном запрете)
  procedure direct_update_payment_with_disabled_api;

  --%test(Прямое удаление записей в таблице PAYMENT_DETAIL при отключенном глобальном запрете)
  procedure direct_delete_payment_with_disabled_api;

  --%test(Прямая вставка записей в таблицу PAYMENT_DETAIL при включенном глобальном запрете завершается ошибкой)
  procedure direct_insert_payment_with_enabled_api;

  --%test(Прямое изменение записей в таблице PAYMENT_DETAIL при включенном глобальном запрете завершается ошибкой)
  procedure direct_update_payment_with_enabled_api;

  --%test(Прямое удаление записей в таблице PAYMENT_DETAIL при включенном глобальном запрете завершается ошибкой)
  procedure direct_delete_payment_with_enabled_api;
end;
