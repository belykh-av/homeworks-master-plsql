create or replace package body payment_api_pack is
  --Флаг использования API для венения изменений в таблицу payment
  g_is_api boolean := false;

  ----------------------------------------------------------------------------------------------------------------------
  --Проверка на внесение изменений через API
  procedure api_restiction is
  begin
    --Проверка локального API срабатывает, если установлен глобальный API
    if common_pack.is_api and not g_is_api then
      raise_application_error(common_pack.c_error_code_payment_api_restriction,
                              common_pack.c_error_message_payment_api_restriction);
    end if;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Запрет на удаление платежей через API
  procedure deleting_restriction is
  begin
    --Если установлен глобальный API, то запретить удаление платежей
    if common_pack.is_api then
      raise_application_error(common_pack.c_error_code_deleting_restriction,
                              common_pack.c_error_message_deleting_restriction);
    end if;
  end;

  ----------------------------------------------------------------------------------------------------------------------
  --Блокировка платежа
  procedure try_lock_payment(p_payment_id in payment.payment_id%type) is
    v_payment_id payment.payment_id%type;
    v_status payment.status%type;
  begin
    --Не задан ID платежа
    if p_payment_id is null then
      --raise common_pack.e_empty_payment_id;
      raise_application_error(common_pack.c_error_code_empty_payment_id, common_pack.c_error_message_empty_payment_id);
    end if;

    --Получить необходимые поля платежа и заблокировать его
    select t.payment_id, t.status
    into v_payment_id, v_status
    from payment t
    where t.payment_id = p_payment_id
    for update nowait;

    --Если платеж в финальном статусе (любой кроме "created"), то ошибка - операции с ним проводить нельзя
    if v_status <> common_pack.c_status_created then
      raise_application_error(common_pack.c_error_code_payment_in_final_status,
                              common_pack.c_error_message_payment_in_final_status);
    end if;
  exception
    when no_data_found then
      --Не найден заданный платеж в базе
      raise_application_error(common_pack.c_error_code_payment_not_found,
                              common_pack.c_error_message_payment_not_found);
    when common_pack.e_system_resource_busy then
      --Объект уже заблокирован
      raise_application_error(common_pack.c_error_code_payment_is_locked,
                              common_pack.c_error_message_payment_is_locked);
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

    --Проверить и заблокировать платеж
    try_lock_payment(p_payment_id);

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

    --Проверить и заблокировать платеж
    try_lock_payment(p_payment_id);

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
    --Проверить и заблокировать платеж
    try_lock_payment(p_payment_id);

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