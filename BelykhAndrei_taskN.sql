--Автор: Белых Анжрей
--Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
--21.04.2025. Изменено с учетом задания №5 ("Условия").
--22.04.2025. Изменено с учетом задания №6 ("Модификаторы %type и %rowtype") и c учетом замечаний по заданию 5.
--29.04.2025. Изменено с учетом задания №9 ("Коллекции").
--            В блоки "1.Создание платежа" и "5.Данные платежа добавлены или обновлены" добавлена переменная типа t_payment_detail_array.
--            В блок "6.Детали платежа удалены" добавлена переменная типа t_number_array.
--30.04.2025. Изменено с учетом задания №10. ("Работа с коллекциями").
--            Добавлена проверка на пустую коллекцию и пустые эдементы коллекции в блоки: 1 и 5.
--05.05.2025  Исправил блок 6 (удаление платежей) по замечаниям к ДЗ №10.
--07.05.2025  Изменено с учетом задания ДЗ11 (SQL в PL/SQL).
--08.05.2025  Скорректировано с учетом замечаний задания ДЗ11 (SQL в PL/SQL).
--09.05.2025  Изменено с учтом ДЗ12 ("Процедуры и функции")
--13.05.2025  Скорректированы блоки 1, 5 и 6 c учетом замечаний ДЗ12 ("Процедуры и функции")
------------------------------------------------------------------------------------------------------------------------
--1.Создание платежа.
create or replace function create_payment(p_create_dtime payment.create_dtime%type,
                                          p_from_client_id payment.from_client_id%type,
                                          p_to_client_id payment.to_client_id%type,
                                          p_summa payment.summa%type,
                                          p_currency_id payment.currency_id%type := 643,
                                          p_payment_details t_payment_detail_array)
  return payment.payment_id%type is
  c_status_created constant payment.status%type := 0;
  --ID полей данных деталей платежа:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"
  --
  v_payment_id payment.payment_id%type := null; --ID созданного платежа
  v_current_dtime timestamp := systimestamp; --Дата операции
  v_is_error boolean := false; --Флаг ошибки проверки данных платежа
begin
  --Провека коллекции деталей платежа с установкой флага ошибки
  if p_payment_details is empty then
    dbms_output.put_line('Коллекция не содержит данных');
    v_is_error := true;
  else
    for i in p_payment_details.first .. p_payment_details.last loop
      if p_payment_details(i).field_id is null then
        dbms_output.put_line('Элемент коллекции №' || to_char(i) || ':');
        dbms_output.put_line('ID поля не может быть пустым');
        v_is_error := true;
      elsif p_payment_details(i).field_value is null then
        dbms_output.put_line('Элемент коллекции №' || to_char(i) || ':');
        dbms_output.put_line('Значение в поле не может быть пустым');
        v_is_error := true;
      end if;
    end loop;
  end if;

  --Создание платежа, если нет флага ошибки
  if not v_is_error then
    insert into payment(payment_id, create_dtime, summa, currency_id, from_client_id, to_client_id, status)
      values (
               payment_seq.nextval,
               p_create_dtime,
               p_summa,
               p_currency_id,
               p_from_client_id,
               p_to_client_id,
               c_status_created)
    returning payment_id
    into v_payment_id;

    --Создание деталей платежа
    insert into payment_detail(payment_id, field_id, field_value)
      select v_payment_id, pd.field_id, pd.field_value
      from table(p_payment_details) pd;

    --Сообщение об операции
    dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'DD.MM.YYYY HH24:MI:SS.FF'));
    dbms_output.put_line('Платеж создан. ' || 'Статус: ' || c_status_created);
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
  else
    dbms_output.put_line('Ошибка создания платежа');
  end if;

  dbms_output.put_line('');
  return v_payment_id;
end;
/

------------------------------------------------------------------------------------------------------------------------
--2.Сброс платежа в "ошибочный статус".
create or replace procedure fail_payment(
  p_payment_id payment.payment_id%type,
  p_status_change_reason payment.status_change_reason%type := 'недостаточно средств') is
  --Используемые статусы:
  c_status_created constant payment.status%type := 0;
  c_status_failed constant payment.status%type := 2;
  --
  v_current_dtime timestamp(6) := systimestamp; --Дата операции
begin
  if p_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  elsif p_status_change_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  else
    update payment
    set status = c_status_failed, status_change_reason = p_status_change_reason
    where payment_id = p_payment_id and status = c_status_created;

    if sql%rowcount = 0 then
      dbms_output.put_line(
        'Платеж ID=' ||
        to_char(p_payment_id)||
        ' не найден или находится не в статусе "Платеж создан"' ||
        c_status_created);
    else
      dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'DD/MM/YYYY HH24:MI:SS.FF6'));
      dbms_output.put_line(
        'Сброс платежа в "ошибочный статус" с указанием причины. ' ||
        ('Статус: ' || c_status_failed || '. ')||
        ('Причина: ' || p_status_change_reason));
      dbms_output.put_line('ID объекта: ' || to_char(p_payment_id));
    end if;
  end if;

  dbms_output.put_line('');
end;
/

------------------------------------------------------------------------------------------------------------------------
--3.Отмена платежа.
create or replace procedure cancel_payment(
  p_payment_id payment.payment_id%type,
  p_status_change_reason payment.status_change_reason%type := 'ошибка пользователя') is
  --Используемые статусы:
  c_status_created constant payment.status%type := 0;
  c_status_canceled constant payment.status%type := 3;
  --
  v_current_dtime timestamp(3) := systimestamp; --Дата операции
begin
  if p_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  elsif p_status_change_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  else
    update payment
    set status = c_status_canceled, status_change_reason = p_status_change_reason
    where payment_id = p_payment_id and status = c_status_created;

    if sql%rowcount = 0 then
      dbms_output.put_line(
        'Платеж ID=' ||
        to_char(p_payment_id)||
        ' не найден или находится не в статусе "Платеж создан"' ||
        c_status_created);
    else
      dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'YYYY-Mon-DDy HH24:MI:SS.FF3'));
      dbms_output.put_line(
        'Отмена платежа с указанием причины. ' ||
        ('Статус: ' || c_status_canceled || '. ')||
        ('Причина: ' || p_status_change_reason));
      dbms_output.put_line('ID объекта: ' || to_char(p_payment_id));
    end if;
  end if;

  dbms_output.put_line('');
end;
/

------------------------------------------------------------------------------------------------------------------------
--4.Успешное завершение платежа.
create or replace procedure successful_finish_payment(p_payment_id payment.payment_id%type) is
  --Используемые статусы:
  c_status_created constant payment.status%type := 0;
  c_status_completed constant payment.status%type := 1;
  --
  v_current_dtime timestamp(2) := systimestamp; --Дата операции
begin
  if p_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    update payment
    set status = c_status_completed
    where payment_id = p_payment_id and status = c_status_created;

    if sql%rowcount = 0 then
      dbms_output.put_line(
        'Платеж ID=' ||
        to_char(p_payment_id)||
        ' не найден или находится не в статусе "Платеж создан"' ||
        c_status_created);
    else
      dbms_output.put_line(
        'Дата операции: ' ||
        to_char(v_current_dtime, 'DD Month Year: "Quarter="Q "Week="W "DayOfYear="DDD "DayOfWeek"=Day HH24:MI:SS'));

      dbms_output.put_line(
        'Успешное завершение платежа. ' || 'Статус: ' || c_status_completed);
      dbms_output.put_line('ID объекта: ' || to_char(p_payment_id));
    end if;
  end if;

  dbms_output.put_line('');
end;
/

------------------------------------------------------------------------------------------------------------------------
--5.Данные платежа добавлены или обновлены.
create or replace procedure insert_or_update_payment_detail(p_payment_id payment.payment_id%type,
                                                            p_payment_details t_payment_detail_array) is
  v_current_date timestamp(2) := sysdate; --Дата операции
  v_is_error boolean := false; --Флаг наличия ошибки при проверке данных
  v_payment_id payment.payment_id%type; --ID найденного платежа
begin
  --Проверка задания платежа и наличия его в базе
  if p_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
    v_is_error := true;
  else
    select max(payment_id)
    into v_payment_id
    from payment
    where payment_id = p_payment_id;

    if v_payment_id is null then
      dbms_output.put_line('Платеж ID=' || to_char(p_payment_id) || ' не найден');
      v_is_error := true;
    end if;
  end if;

  --Провека на пустую коллекцию и на пустые поля коллекции
  if not v_is_error then
    if p_payment_details is empty then
      dbms_output.put_line('Коллекция не содержит данных');
      v_is_error := true;
    else
      for i in p_payment_details.first .. p_payment_details.last loop
        if p_payment_details(i).field_id is null then
          dbms_output.put_line('Элемент коллекции №' || to_char(i) || ':');
          dbms_output.put_line('ID поля не может быть пустым');
          v_is_error := true;
        end if;

        if p_payment_details(i).field_value is null then
          dbms_output.put_line('Элемент коллекции №' || to_char(i) || ':');
          dbms_output.put_line('Значение в поле не может быть пустым');
          v_is_error := true;
        end if;
      end loop;
    end if;
  end if;

  --Изменение данных платежа
  if not v_is_error then
    merge into payment_detail a
    using (select value(c).field_id as field_id, value(c).field_value as field_value
           from table(p_payment_details) c) b
    on (b.field_id = a.field_id and a.payment_id = p_payment_id)
    when matched then
      update set a.field_value = b.field_value
    when not matched then
      insert (a.payment_id, a.field_id, a.field_value)
      values (p_payment_id, b.field_id, b.field_value);

    dbms_output.put_line('Дата операции: ' || to_char(v_current_date, 'DL HH:MI:SS:AM'));
    dbms_output.put_line(
      'Данные платежа добавлены или обновлены по списку id_поля/значение');
    dbms_output.put_line('ID объекта: ' || to_char(p_payment_id));
  end if;

  dbms_output.put_line('');
end;
/

------------------------------------------------------------------------------------------------------------------------
--6.Детали платежа удалены.
create or replace procedure delete_payment_detail(p_payment_id payment.payment_id%type,
                                                  p_payment_detail_field_ids t_number_array) is
  --ID полей данных деталей платежа:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"
  --
  v_current_date timestamp(2) := sysdate; --Дата операции
  v_deleted_field_ids t_number_array := t_number_array(); --Коллекция удаленных деталей платежа
begin
  if p_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    delete from payment_detail
    where payment_id = p_payment_id and field_id in (select column_value from table(p_payment_detail_field_ids))
    returning field_id
    bulk collect into v_deleted_field_ids;

    dbms_output.put_line('Дата операции: ' || to_char(v_current_date, 'YYYYMMHH_HH24MISS'));
    dbms_output.put_line('Детали платежа удалены по списку id_полей');
    dbms_output.put_line('ID объекта: ' || to_char(p_payment_id));
    dbms_output.put_line('Кол-во удаленных полей: ' || to_char(v_deleted_field_ids.count));
  end if;

  dbms_output.put_line('');
end;
/