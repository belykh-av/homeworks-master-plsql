CREATE OR REPLACE PACKAGE ut_payment_api_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: Тесты по платежу
  -- Автор: Белых Андрей
  -- 13.06.2025. Создано в ДЗ18
  -- 29.06.2025. Изменено в ДЗ19. Переделка под utPL/SQL
  -- 29.06.2025. Скорретировано с учетом замечаний в ДЗ19.
  ----------------------------------------------------------------------------------------------------------------------
  --%suite(Unit-tests for PAYMENT)

  --------------------- API: create_payment --------------------

  --%test(Создание платежа)
  procedure create_payment;

  --%test(Создание платежа с пустым ID детали платежа завершается ошибкой)
  --%throws(payment_detail_api_pack.c_error_code_empty_field_id)
  procedure create_payment_with_empty_field_id_should_fail;

  --%test(Создание платежа c пустыми деталями платежа завершается ошибкой)
  --%throws(payment_detail_api_pack.c_error_code_empty_payment_details)
  procedure create_payment_with_empty_payment_details_should_fail;

  --------------------- API: fail_payment ------------------------

  --%test(Сброс платежа в "ошибочный статус")
  --%beforetest(ut_common_pack.create_default_payment)
  procedure fail_payment;

  --%test(Сброс платежа в "ошибочный статус" c пустым ID платежа завершается ошибкой)
  --%throws(payment_api_pack.c_error_code_empty_payment_id)
  procedure fail_payment_with_empty_payment_id_should_fail;

  --%test(Сброс платежа в "ошибочный статус" c несуществующим ID платежа завершается ошибкой)
  --%throws(payment_api_pack.c_error_code_payment_not_found)
  procedure fail_payment_with_unknown_payment_id_should_fail;

  --%test(Сброс платежа в "ошибочный статус" находящегося не в статус "Создан" завершается с ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_api_pack.c_error_code_payment_in_final_status)
  procedure fail_payment_with_not_created_status_should_fail;

  -------------------- API: cancel_payment ------------------------

  --%test(Отмена платежа)
  --%beforetest(ut_common_pack.create_default_payment)
  procedure cancel_payment;

  --%test(Отмена платежа c не заданым ID платежа завершается ошибкой)
  --%throws(payment_api_pack.c_error_code_empty_payment_id)
  procedure cancel_payment_with_empty_payment_id_should_fail;

  --%test(Отмена платежа c несуществующим ID платежа завершается ошибкой)
  --%throws(payment_api_pack.c_error_code_payment_not_found)
  procedure cancel_payment_with_unknown_payment_should_fail;

  --%test(Отмена платежа находящегося не в статусе "Создан" завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_api_pack.c_error_code_payment_in_final_status)
  procedure cancel_payment_with_not_created_status_should_fail;

  --%test(Отмена платежа без указания причины завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_api_pack.c_error_code_empty_status_change_reason)
  procedure cancel_payment_without_status_change_reason_should_fail;

  -------------------- API: successful_finish_payment --------------------------

  --%test(Успешное завершение платежа)
  --%beforetest(ut_common_pack.create_default_payment)
  procedure successful_finish_payment;

  --%test(Успешное завершение платежа c незаданным ID платежа завершается ошибкой)
  --%throws(payment_api_pack.c_error_code_empty_payment_id)
  procedure successful_finish_payment_with_empty_payment_id_should_fail;

  --%test(Успешное завершение платежа с несуществующим ID платежа завершается ошибкой)
  --%throws(payment_api_pack.c_error_code_payment_not_found)
  procedure successful_finish_payment_with_unknown_payment_id_should_fail;

  --%test(Успешное завершение платежа находящегося не в статусе "Создан" завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_api_pack.c_error_code_payment_in_final_status)
  procedure successful_finish_payment_with_not_created_status_should_fail;

  ------------------------ Direct DML ------------------------------------------

  --%test(Прямое изменение записей в таблице PAYMENT при отключенном глобальном запрете)
  --%beforetest(ut_common_pack.create_default_payment)
  procedure direct_update_payment_with_disabled_api;

  --%test(Прямое удаление записей в таблице PAYMENT при отключенном глобальном запрете)
  --%beforetest(ut_common_pack.create_default_payment)
  procedure direct_delete_payment_with_disabled_api;

  --%test(Прямая вставка записей в таблицу PAYMENT при влюченном глобальном запрете завершается ошибкой)
  --%throws(payment_api_pack.c_error_code_payment_api_restriction)
  procedure direct_insert_payment_with_enabled_api_should_fail;

  --%test(Прямое изменение записей в таблице PAYMENT при влюченном глобальном запрете завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_api_pack.c_error_code_payment_api_restriction)
  procedure direct_update_payment_with_enabled_api_should_fail;

  --%test(Прямое удаление записей в таблице PAYMENT при влюченном глобальном запрете завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%throws(payment_api_pack.c_error_code_deleting_restriction)
  procedure direct_delete_payment_with_enabled_api_should_fail;
end;
/
