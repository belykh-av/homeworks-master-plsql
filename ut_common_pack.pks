CREATE OR REPLACE PACKAGE ut_common_pack is
  ---------------------------------------------------------------------------------------------------------------------
  -- Описание: Общий пакет для юнит-тестов.
  -- Автор: Белых Андрей
  -- 13.06.2025. Создано в ДЗ18
  -- 29.06.2025. Изменено в ДЗ19. Добавлена глобальная переменная g_payment_id и процедуры ее заполнения
  ---------------------------------------------------------------------------------------------------------------------
  --КОНСТАНТЫ:

  --Коды и сообщения об ошибках:
  c_error_code_ut_failed constant number := -20999;
  c_error_message_ut_failed constant varchar2(100 char)
    := 'Unit-тест или API выполнены не верно' ;

  --Несуществующие ID объектов
  c_not_existing_client_id constant client.client_id%type := -123456789; --Несуществующий клиент
  c_not_existing_payment_id constant payment.payment_id%type := -987654321; --Несуществующий платеж

  ---------------------------------------------------------------------------------------------------------------------
  --ИСКЛЮЧЕНИЯ:
  e_ut_failed exception; --Unit-тест или API выполнены не верно
  pragma exception_init(e_ut_failed , c_error_code_ut_failed);

  ---------------------------------------------------------------------------------------------------------------------
  --ПРОЦЕДУРЫ И ФУНКЦИИ:

  --Сгенерировать случайное значение детали платежа "Клиентское ПО"
  function get_random_payment_detail_client_software
    return payment_detail.field_value%type;

  --Сгенерировать случайное значение детали платежа "IP-адрес"
  function get_random_payment_detail_ip
    return payment_detail.field_value%type;

  --Сгенерировать случайное значение детали платежа "Примечание"
  function get_random_payment_detail_note
    return payment_detail.field_value%type;

  --Сгенерировать случайное ID валюты
  function get_random_currency_id
    return currency.currency_id%type;

  --Создать случайного клиента
  function create_random_client
    return client.client_id%type;

  --Сгенерировать случайное значение суммы платежа
  function get_random_payment_summa
    return payment.summa%type;

  --Создать платеж по умолчанию с деталями по умолчанию и сохранить его в глобальной переменной
  procedure create_default_payment;

  --Создать платеж по умолчанию с указаннми деталями и сохранить его в глобальной переменной
  procedure create_default_payment(p_payment_details in t_payment_detail_array);

  --Получить ID платежа, созданного в setup-процедуре
  function get_default_payment_id return payment.payment_id%type;

  --Получить данные о платеже
  function get_payment_record(p_payment_id in payment.payment_id%type := null)
    return payment%rowtype;

  --Получить значение заданной детали платежа
  function get_payment_detail_field_value(p_payment_id in payment.payment_id%type,
                                          p_payment_detail_field_id payment_detail.field_id%type)
    return payment_detail.field_value%type;

  --Возбудить исключение об ошибке unit-теста
  procedure ut_failed;
end;
/
