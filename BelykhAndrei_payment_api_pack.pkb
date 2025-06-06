create or replace package body payment_api_pack is
  --Флаг использования API для венения изменений в таблицу payment
  g_is_api boolean := false;

  ----------------------------------------------------------------------------------------------------------------------
  --Проверка на внесение изменений через API
  procedure api_restiction is
  begin
    if not g_is_api then
      raise_application_error(common_pack.c_error_code_payment_api_restriction,
                              common_pack.c_error_message_payment_api_restriction);
    end if;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Проверка наличия платежа
  procedure check_payment_exists(p_payment_id in payment.payment_id%type) is
    v_payment_id payment.payment_id%type;
  begin
    if p_payment_id is null then
      raise common_pack.e_empty_payment_id;
    end if;

    --Найти платеж
    select max(payment_id)
    into v_payment_id
    from payment
    where payment_id = p_payment_id;

    if v_payment_id is null then
      raise common_pack.e_payment_not_found;
    end if;
  exception
    when common_pack.e_empty_payment_id then
      raise_application_error(common_pack.c_error_code_empty_payment_id, common_pack.c_error_message_empty_payment_id);
    when common_pack.e_payment_not_found then
      raise_application_error(common_pack.c_error_code_payment_not_found,
                              common_pack.c_error_message_payment_not_found);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Проверка наличия платежа и его статуса
  procedure check_payment_status(p_payment_id in payment.payment_id%type, p_status in payment.status%type) is
    v_payment_id payment.payment_id%type;
    v_status payment.status%type;
  begin
    if p_payment_id is null then
      raise common_pack.e_empty_payment_id;
    end if;

    if p_status is null then
      raise common_pack.e_empty_status;
    end if;

    --Найти платеж и его статус
    select max(payment_id), max(status)
    into v_payment_id, v_status
    from payment
    where payment_id = p_payment_id;

    if v_payment_id is null then
      raise common_pack.e_payment_not_found;
    end if;

    if v_status <> p_status then
      raise common_pack.e_payment_status_error;
    end if;
  exception
    when common_pack.e_empty_payment_id then
      raise_application_error(common_pack.c_error_code_empty_payment_id, common_pack.c_error_message_empty_payment_id);
    when common_pack.e_empty_status then
      raise_application_error(common_pack.c_error_code_empty_status, common_pack.c_error_message_empty_status);
    when common_pack.e_payment_not_found then
      raise_application_error(common_pack.c_error_code_payment_not_found,
                              common_pack.c_error_message_payment_not_found);
    when common_pack.e_payment_status_error then
      raise_application_error(common_pack.c_error_code_status_error, common_pack.c_error_message_status_error);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Проверка на возможность удаления платежа
  procedure check_delete is
  begin
    --Запретить удаление
    raise_application_error(common_pack.c_error_code_delete_restriction,
                            common_pack.c_error_message_delete_restriction);
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Создание платежа.
  function create_payment(p_create_dtime in payment.create_dtime%type,
                          p_from_client_id in payment.from_client_id%type,
                          p_to_client_id in payment.to_client_id%type,
                          p_summa in payment.summa%type,
                          p_currency_id in payment.currency_id%type := common_pack.c_currency_id_rub,
                          p_payment_details in t_payment_detail_array)
    return payment.payment_id%type is
    v_payment_id payment.payment_id%type := null; --ID созданного платежа
  begin
    --Провека коллекции деталей платежа
    payment_detail_api_pack.check_payment_details(p_payment_details);

    g_is_api := true;

    --Создание платежа, если нет флага ошибки
    insert into payment(payment_id, create_dtime, summa, currency_id, from_client_id, to_client_id, status)
      values (
               payment_seq.nextval,
               p_create_dtime,
               p_summa,
               p_currency_id,
               p_from_client_id,
               p_to_client_id,
               common_pack.c_status_created)
    returning payment_id
    into v_payment_id;

    g_is_api := false;

    --Создание деталей платежа
    payment_detail_api_pack.insert_payment_detail(p_payment_id => v_payment_id, p_payment_details => p_payment_details);

    return v_payment_id;
  exception
    when others then
      g_is_api := false;
      raise;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Сброс платежа в "ошибочный статус".
  procedure fail_payment(
    p_payment_id in payment.payment_id%type,
    p_status_change_reason in payment.status_change_reason%type := common_pack.c_status_change_reason_no_money) is
  begin
    if p_status_change_reason is null then
      raise common_pack.e_empty_status_change_reason;
    end if;

    --Проверить, что платеж существует и находится в статусе "Создан"
    check_payment_status(p_payment_id, common_pack.c_status_created);

    g_is_api := true;

    update payment
    set status = common_pack.c_status_failed, status_change_reason = p_status_change_reason
    where payment_id = p_payment_id;

    g_is_api := false;
  exception
    when common_pack.e_empty_status_change_reason then
      raise_application_error(common_pack.c_error_code_empty_status_change_reason,
                              common_pack.c_error_message_empty_status_change_reason);
    when others then
      g_is_api := false;
      raise;
  end;

  ------------------------------------------------------------------------------------------------------------------------
  --Отмена платежа.
  procedure cancel_payment(
    p_payment_id in payment.payment_id%type,
    p_status_change_reason in payment.status_change_reason%type := common_pack.c_status_change_reason_user_error) is
  begin
    if p_status_change_reason is null then
      raise common_pack.e_empty_status_change_reason;
    end if;

    --Проверить, что платеж существует и находится в статусе "Создан"
    check_payment_status(p_payment_id, common_pack.c_status_created);

    g_is_api := true;

    update payment
    set status = common_pack.c_status_canceled, status_change_reason = p_status_change_reason
    where payment_id = p_payment_id;

    g_is_api := false;
  exception
    when common_pack.e_empty_status_change_reason then
      raise_application_error(common_pack.c_error_code_empty_status_change_reason,
                              common_pack.c_error_message_empty_status_change_reason);
    when others then
      g_is_api := false;
      raise;
  end;

  ------------------------------------------------------------------------------------------------------------------------
  --Успешное завершение платежа.
  procedure successful_finish_payment(p_payment_id in payment.payment_id%type) is
  begin
    --Проверить, что платеж существует и находится в статусе "Создан"
    check_payment_status(p_payment_id, common_pack.c_status_created);

    g_is_api := true;

    update payment
    set status = common_pack.c_status_completed
    where payment_id = p_payment_id;

    g_is_api := false;
  exception
    when others then
      g_is_api := false;
      raise;
  end;
end;