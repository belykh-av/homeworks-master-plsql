create or replace package payment_api_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: API по платежу
  -- Автор: Белых Андрей
  -- 13.05.2025. Создано в ДЗ13 на основе процедур файла BelykhAndrei_TaskN.sql.
  -- 25.05.2025. ДЗ14. Добавлены исключения.
  -- 31.05.2025. ДЗ15. Добавлен флаг использования API и запрет на прямые DML-операции с таблицей PAYMENT.
  -- 04.06.2025. ДЗ16. Константы и исключения перенесены в COMMON_PAСK. Убраны лишние переменные и вывод в output
  ---------------------------------------------------------------------------------------------------------------------
  --МЕТОДЫ:
  
  --Проверка на внесение изменений через API
  procedure api_restiction;  
  
  --Проверка наличия платежа в базе данных
  procedure check_payment_exists(p_payment_id payment.payment_id%type);

  --Проверка наличия платежа и его статуса
  procedure check_payment_status(p_payment_id payment.payment_id%type, p_status payment.status%type);
  
  --Проверка на возможность удаления платежа
  procedure check_delete;

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
    p_status_change_reason payment.status_change_reason%type := common_pack.c_status_change_reason_no_money);

  --Отмена платежа.
  procedure cancel_payment(
    p_payment_id payment.payment_id%type,
    p_status_change_reason payment.status_change_reason%type := common_pack.c_status_change_reason_user_error);

  --Успешное завершение платежа.
  procedure successful_finish_payment(p_payment_id payment.payment_id%type);
end;