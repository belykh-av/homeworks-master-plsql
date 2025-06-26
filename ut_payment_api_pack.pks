CREATE OR REPLACE PACKAGE ut_payment_api_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: Тесты по платежу
  -- Автор: Белых Андрей
  -- 13.06.2025. Создано в ДЗ18
  ----------------------------------------------------------------------------------------------------------------------
  --%suite(Unit-tests for PAYMENT)

  --------------------- API: create_payment --------------------

  --%test(Создание платежа)
  procedure create_payment;

  --%test(Создание платежа с пустым ID детали платежа завершается ошибкой)
  procedure create_payment_with_empty_field_id_should_fail;

  --%test(Создание платежа c пустыми деталями платежа завершается ошибкой)
  procedure create_payment_with_empty_payment_details_should_fail;

  --------------------- API: fail_payment ------------------------

  --%test(Сброс платежа в "ошибочный статус")
  procedure fail_payment;

  --%test(Сброс платежа в "ошибочный статус" c пустым ID платежа завершается ошибкой)
  procedure fail_payment_with_empty_payment_id_should_fail;

  --%test(Сброс платежа в "ошибочный статус" c несуществующим ID платежа завершается ошибкой)
  procedure fail_payment_with_unknown_payment_id_should_fail;

  --%test(Сброс платежа в "ошибочный статус" находящегося не в статус "Создан" завершается с ошибкой)
  procedure fail_payment_with_not_created_status_should_fail;

  -------------------- API: cancel_payment ------------------------

  --%test(Отмена платежа)
  procedure cancel_payment;

  --%test(Отмена платежа c не заданым ID платежа завершается ошибкой)
  procedure cancel_payment_with_empty_payment_id_should_fail;

  --%test(Отмена платежа c несуществующим ID платежа завершается ошибкой)
  procedure cancel_payment_with_unknown_payment_should_fail;

  --%test(Отмена платежа находящегося не в статусе "Создан" завершается ошибкой)
  procedure cancel_payment_with_not_created_status_should_fail;

  --%test(Отмена платежа без указания причины завершается ошибкой)
  procedure cancel_payment_without_status_change_reason_should_fail;

  -------------------- API: successful_finish_payment --------------------------

  --%test(Успешное завершение платежа)
  procedure successful_finish_payment;

  --%test(Успешное завершение платежа c незаданным ID платежа завершается ошибкой)
  procedure successful_finish_payment_with_empty_payment_id_should_fail;

  --%test(Успешное завершение платежа с несуществующим ID платежа завершается ошибкой)
  procedure successful_finish_payment_with_unknown_payment_id_should_fail;

  --%test(Успешное завершение платежа находящегося не в статусе "Создан" завершается ошибкой)
  procedure successful_finish_payment_with_not_created_status_should_fail;

  ------------------------ Direct DML ------------------------------------------

  --%test(Прямое изменение записей в таблице PAYMENT при отключенном глобальном запрете)
  procedure direct_update_payment_with_disabled_api;

  --%test(Прямое удаление записей в таблице PAYMENT при отключенном глобальном запрете)
  procedure direct_delete_payment_with_disabled_api;

  --%test(Прямая вставка записей в таблицу PAYMENT при влюченном глобальном запрете завершается ошибкой)
  procedure direct_insert_payment_with_enabled_api_should_fail;

  --%test(Прямое изменение записей в таблице PAYMENT при влюченном глобальном запрете завершается ошибкой)
  procedure direct_update_payment_with_enabled_api_should_fail;

  --%test(Прямое изменение записей в таблице PAYMENT при влюченном глобальном запрете завершается ошибкой)
  procedure direct_delete_payment_with_enabled_api_should_fail;
end;
