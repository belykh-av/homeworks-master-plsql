CREATE OR REPLACE PACKAGE BODY ut_common_pack is
  ---------------------------------------------------------------------------------------------------------------------
  --Сгенерировать случайное значение детали платежа "Клиентское ПО"
  function get_random_payment_detail_client_software
    return payment_detail.field_value%type is
  begin
    return dbms_random.string('A', 20);
  end;

  ---------------------------------------------------------------------------------------------------------------------
  --Сгенерировать случайное значение детали платежа "IP-адрес"
  function get_random_payment_detail_ip
    return payment_detail.field_value%type is
  begin
    return round(dbms_random.value(100, 999))||
           '.' ||
           round(dbms_random.value(100, 999))||
           '.' ||
           round(dbms_random.value(100, 999))||
           '.' ||
           round(dbms_random.value(100, 999));
  end;

  ---------------------------------------------------------------------------------------------------------------------
  --Сгенерировать случайное значение детали платежа "Примечание"
  function get_random_payment_detail_note
    return payment_detail.field_value%type is
  begin
    return dbms_random.string('p', 100);
  end;

  ---------------------------------------------------------------------------------------------------------------------
  --Сгенерировать случайное ID валюты
  function get_random_currency_id
    return currency.currency_id%type is
    v_currency_id currency.currency_id%type;
    v_rownum number;
  begin
    for r in (select count(1) as cnt
              from currency) loop
      v_rownum := round(dbms_random.value(1, r.cnt));

      select currency_id
      into v_currency_id
      from (select rownum as row_num, currency_id from currency)
      where row_num = v_rownum;
    end loop;

    return v_currency_id;
  end;

  ---------------------------------------------------------------------------------------------------------------------
  --Сгенерировать случайное значение суммы платежа
  function get_random_payment_summa
    return payment.summa%type is
  begin
    return round(dbms_random.value(100, 1000000), 2);
  end;

  ---------------------------------------------------------------------------------------------------------------------
  --Создать случайного клиента
  function create_random_client
    return client.client_id%type is
    v_client_id client.client_id%type;
  begin
    insert into client(client_id, is_active, is_blocked)
    values (client_seq.nextval, 1, 0)
    returning client_id
    into v_client_id;

    return v_client_id;
  end;

  ---------------------------------------------------------------------------------------------------------------------
  --Создать случайный платеж с заданными деталями
  function create_random_payment(p_payment_details in t_payment_detail_array)
    return payment.payment_id%type is
  begin
    return payment_api_pack.create_payment(p_create_dtime => systimestamp,
                                           p_from_client_id => create_random_client(),
                                           p_to_client_id => create_random_client(),
                                           p_summa => get_random_payment_summa(),
                                           p_currency_id => get_random_currency_id,
                                           p_payment_details => p_payment_details);
  end;

  ---------------------------------------------------------------------------------------------------------------------
  --Создать случайный платеж со случайными деталями
  function create_random_payment_with_random_details
    return payment.payment_id%type is
  begin
    return payment_api_pack.create_payment(
             p_create_dtime => systimestamp,
             p_from_client_id => create_random_client(),
             p_to_client_id => create_random_client(),
             p_summa => get_random_payment_summa(),
             p_currency_id => get_random_currency_id,
             p_payment_details => t_payment_detail_array(
                                   t_payment_detail(common_pack.c_payment_detail_field_id_client_software,
                                                    get_random_payment_detail_client_software()),
                                   t_payment_detail(common_pack.c_payment_detail_field_id_ip,
                                                    get_random_payment_detail_ip()),
                                   t_payment_detail(common_pack.c_payment_detail_field_id_note,
                                                    get_random_payment_detail_note())));
  end;


  ---------------------------------------------------------------------------------------------------------------------
  --Создать платеж по умолчанию и сохранить его в шлобальной переменной
  procedure create_default_payment is
  begin
    g_payment_id := create_random_payment_with_random_details();
  end;

  ---------------------------------------------------------------------------------------------------------------------
  --Найти в базе случаный платеж не в статусе "Создан" и записать его в глобальну переменную
  procedure get_payment_in_no_created_status is
  begin
    select max(payment_id)
    into g_payment_id
    from payment
    where status <> common_pack.c_status_created and rownum = 1;

    --Тестовый API
    if g_payment_id is null then
      raise_application_error(-20999, 'В базе нет платежей не в статусе "Создан"');
    end if;
  end;

  ---------------------------------------------------------------------------------------------------------------------
  --Получить данные о платеже
  function get_payment_record(p_payment_id in payment.payment_id%type := null)
    return payment%rowtype is
    v_payment payment%rowtype;
  begin
    select *
    into v_payment
    from payment
    where payment_id = p_payment_id;

    return v_payment;
  exception
    when no_data_found then
      --Не найден заданный платеж в базе
      raise_application_error(common_pack.c_error_code_payment_not_found,
                              common_pack.c_error_message_payment_not_found);
  end;

  ---------------------------------------------------------------------------------------------------------------------
  --Получить значение заданной детали платежа
  function get_payment_detail_field_value(p_payment_id in payment.payment_id%type,
                                          p_payment_detail_field_id payment_detail.field_id%type)
    return payment_detail.field_value%type is
    v_payment_detail_field_value payment_detail.field_value%type;
  begin
    select max(field_value)
    into v_payment_detail_field_value
    from payment_detail
    where payment_id = p_payment_id and field_id = p_payment_detail_field_id;

    return v_payment_detail_field_value;
  end;


  ---------------------------------------------------------------------------------------------------------------------
  --Возбудить исключение об ошибке unit-теста
  procedure ut_failed is
  begin
    raise_application_error(c_error_code_ut_failed, c_error_message_ut_failed);
  end;
end;
