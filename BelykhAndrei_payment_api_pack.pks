CREATE OR REPLACE PACKAGE payment_api_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: API по платежу
  -- Автор: Белых Андрей
  -- 13.05.2025. Создано в ДЗ13 на основе процедур файла BelykhAndrei_TaskN.sql.
  -- 25.05.2025. ДЗ14. Добавлены исключения.
  -- 31.05.2025. ДЗ15. Добавлен флаг использования API и запрет на прямые DML-операции с таблицей PAYMENT.
  -- 04.06.2025. ДЗ16. Константы и исключения перенесены в COMMON_PAСK. Убраны лишние переменные и вывод в output
  -- 07.06.2025. ДЗ17. Учтены замечания по ДЗ16.
  --                   Добавлена процедура блокировка платежа try_lock_payment.
  --                   Процедуры check_payment_exists и check_payment_status удалены, их функционал теперь в try_lock_payment.
  --                   Процедура check_delete переименована в deleting_restriction.
  -- 29.06.2025. ДЗ19. По замечаниям перенес сюда из COMMON_PACK константы и исключения, касающиеся API PAYMENT
  --
  ---------------------------------------------------------------------------------------------------------------------
  --КОНСТАНТЫ:

  --Статус платежа:
  c_status_created constant payment.status%type := 0; --Создан
  c_status_completed constant payment.status%type := 1; --Проведен
  c_status_failed constant payment.status%type := 2; --Ошибка проведения
  c_status_canceled constant payment.status%type := 3; --Отмена платежа

  --Статус изменения платежа:
  c_status_change_reason_no_money constant payment.status_change_reason%type
    := 'недостаточно средств' ;
  c_status_change_reason_user_error constant payment.status_change_reason%type
    := 'ошибка пользователя' ;

  --Коды ошибок:
  c_error_code_payment_api_restriction constant number := -20100;
  c_error_code_empty_payment_id constant number := -20101;
  c_error_code_empty_status constant number := -20102;
  c_error_code_empty_status_change_reason constant number := -20103;
  c_error_code_payment_in_final_status constant number := -20104;
  c_error_code_payment_not_found constant number := -20105;
  c_error_code_payment_is_locked constant number := -20106;
  c_error_code_deleting_restriction constant number := -20107;

  --Сообщения об ошибках:
  c_error_message_payment_api_restriction constant varchar2(100 char)
    := 'Изменения в таблицу PAYMENT можно вносить только через API' ;
  c_error_message_empty_payment_id constant varchar2(100 char)
    := 'ID объекта не может быть пустым' ;
  c_error_message_empty_status constant varchar2(100 char) := 'Не задан статус';
  c_error_message_empty_status_change_reason constant varchar2(100 char)
    := 'Причина не может быть пустой' ;
  c_error_message_payment_in_final_status constant varchar2(100 char)
    := 'Объект в конечном статусе. Изменения невозможны' ;
  c_error_message_payment_not_found constant varchar2(100 char) := 'Объект не найден';
  c_error_message_payment_is_locked constant varchar2(100 char) := 'Объект уже заблокирован';
  c_error_message_deleting_restriction constant varchar2(100 char)
    := 'Удаление платежей запрещено' ;

  ---------------------------------------------------------------------------------------------------------------------
  --ИСКЛЮЧЕНИЯ:
  --
  e_payment_api_restriction exception; --Внесение изменений в PAYMENT только через API
  pragma exception_init(e_payment_api_restriction, c_error_code_payment_api_restriction);
  --
  e_empty_payment_id exception; --Не задан id платежа
  pragma exception_init(e_empty_payment_id, c_error_code_empty_payment_id);
  --
  e_empty_status_change_reason exception; --Не задана причина изменения платежа
  pragma exception_init(e_empty_status_change_reason, c_error_code_empty_status_change_reason);
  --
  e_payment_in_final_status exception; --Объект в конечном статусе. Изменения невозможны
  pragma exception_init(e_payment_in_final_status, c_error_code_payment_in_final_status);
  --
  e_payment_not_found exception; --Объект не найден
  pragma exception_init(e_payment_not_found, c_error_code_payment_not_found);
  --
  e_payment_is_locked exception; --Объект уже заблокирован
  pragma exception_init(e_payment_is_locked, c_error_code_payment_is_locked);
  --
  e_payment_deleting_restriction exception; --Удаление платежей запрещено
  pragma exception_init(e_payment_deleting_restriction, c_error_code_deleting_restriction);
  --

  ---------------------------------------------------------------------------------------------------------------------
  --МЕТОДЫ:

  --Проверка на внесение изменений через API
  procedure api_restiction;

  --Запрет на удаление платежей через API
  procedure deleting_restriction;

  --Блокировка платежа
  procedure try_lock_payment(p_payment_id in payment.payment_id%type);

  --Создание платежа.
  function create_payment(p_create_dtime payment.create_dtime%type,
                          p_from_client_id payment.from_client_id%type,
                          p_to_client_id payment.to_client_id%type,
                          p_summa payment.summa%type,
                          p_currency_id payment.currency_id%type := common_pack.c_currency_id_rub,
                          p_payment_details t_payment_detail_array)
    return payment.payment_id%type;

  --Сброс платежа в "ошибочный статус".
  procedure fail_payment(
    p_payment_id payment.payment_id%type,
    p_status_change_reason payment.status_change_reason%type := c_status_change_reason_no_money);

  --Отмена платежа.
  procedure cancel_payment(
    p_payment_id payment.payment_id%type,
    p_status_change_reason payment.status_change_reason%type := c_status_change_reason_user_error);

  --Успешное завершение платежа.
  procedure successful_finish_payment(p_payment_id payment.payment_id%type);
end;
/
