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
--
------------------------------------------------------------------------------------------------------------------------
--1.Создание платежа.
declare
  c_status_created constant payment.status%type := 0;
  --ID полей данных деталей платежа:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"
  --Данные платежа: (я бы сделал одну переменную v_payment payment%rowtype, но в задании сказано что переменные должны быть разные)
  v_payment_id payment.payment_id%type := null;
  v_current_dtime timestamp := systimestamp;
  v_summa payment.summa%type := 1000;
  v_currency_id payment.currency_id%type := 643; --RUB
  v_from_client_id payment.from_client_id%type := 1;
  v_to_client_id payment.to_client_id%type := 2;
  --Детали платежа:
  v_payment_details t_payment_detail_array
    := t_payment_detail_array(t_payment_detail(c_payment_detail_field_id_client_software, 'Онлайн банк'),
                              t_payment_detail(c_payment_detail_field_id_ip, '172.173.1.2'),
                              t_payment_detail(c_payment_detail_field_id_note, 'Просто перевод'));
  v_is_error boolean := false; --Флаг ошибки проверки данных платежа
begin
  --Провека коллекции деталей платежа с установкой флага ошибки
  if v_payment_details is empty then
    dbms_output.put_line('Коллекция не содержит данных');
    v_is_error := true;
  else
    for i in v_payment_details.first .. v_payment_details.last loop
      if v_payment_details(i).field_id is null then
        dbms_output.put_line('Элемент коллекции №' || to_char(i) || ':');
        dbms_output.put_line('ID поля не может быть пустым');
        v_is_error := true;
      elsif v_payment_details(i).field_value is null then
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
               v_current_dtime,
               v_summa,
               v_currency_id,
               v_from_client_id,
               v_to_client_id,
               c_status_created)
    returning payment_id
    into v_payment_id;

    --Создание деталей платежа
    if v_payment_details is empty then
      for i in v_payment_details.first .. v_payment_details.last loop
        insert into payment_detail(payment_id, field_id, field_value)
        values (v_payment_id, v_payment_details(i).field_id, v_payment_details(i).field_value);
      end loop;
    end if;

    --Сообщение об операции
    dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'DD.MM.YYYY HH24:MI:SS.FF'));
    dbms_output.put_line('Платеж создан. ' || 'Статус: ' || c_status_created);
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
  else
    dbms_output.put_line('Ошибка создания платежа');
  end if;

  dbms_output.put_line('');
end;
/

------------------------------------------------------------------------------------------------------------------------
--2.Сброс платежа в "ошибочный статус".
declare
  --Используемые статусы:
  c_status_created constant payment.status%type := 0;
  c_status_failed constant payment.status%type := 2;
  --
  v_payment_id payment.payment_id%type := 10; --ID платежа для операции
  v_updated_id payment.payment_id%type; --ID найденного платежа (для проверки изменений)
  v_status_change_reason payment.status_change_reason%type := 'недостаточно средств';
  v_current_dtime timestamp(6) := systimestamp;
begin
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  elsif v_status_change_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  else
    update payment
    set status = c_status_failed, status_change_reason = v_status_change_reason
    where payment_id = v_payment_id and status = c_status_created
    returning payment_id
    into v_updated_id;

    if v_updated_id is null then
      dbms_output.put_line(
        'Платеж ID=' ||
        to_char(v_payment_id)||
        ' не найден или находится не в статусе "Платеж создан"' ||
        c_status_created);
    else
      dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'DD/MM/YYYY HH24:MI:SS.FF6'));
      dbms_output.put_line(
        'Сброс платежа в "ошибочный статус" с указанием причины. ' ||
        ('Статус: ' || c_status_failed || '. ')||
        ('Причина: ' || v_status_change_reason));
      dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
    end if;
  end if;

  dbms_output.put_line('');
end;
/

------------------------------------------------------------------------------------------------------------------------
--3.Отмена платежа.
declare
  --Используемые статусы:
  c_status_created constant payment.status%type := 0;
  c_status_canceled constant payment.status%type := 3;
  --
  v_payment_id payment.payment_id%type := 11; --ID платежа для операции
  v_updated_id payment.payment_id%type; --ID найденного платежа (для проверки изменений)
  v_status_change_reason payment.status_change_reason%type := 'ошибка пользователя';
  v_current_dtime timestamp(3) := systimestamp;
begin
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  elsif v_status_change_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  else
    update payment
    set status = c_status_canceled, status_change_reason = v_status_change_reason
    where payment_id = v_payment_id and status = c_status_created
    returning payment_id
    into v_updated_id;

    if v_updated_id is null then
      dbms_output.put_line(
        'Платеж ID=' ||
        to_char(v_payment_id)||
        ' не найден или находится не в статусе "Платеж создан"' ||
        c_status_created);
    else
      dbms_output.put_line('Дата операции: ' || to_char(v_current_dtime, 'YYYY-Mon-DDy HH24:MI:SS.FF3'));
      dbms_output.put_line(
        'Отмена платежа с указанием причины. ' ||
        ('Статус: ' || c_status_canceled || '. ')||
        ('Причина: ' || v_status_change_reason));
      dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
    end if;
  end if;

  dbms_output.put_line('');
end;
/

------------------------------------------------------------------------------------------------------------------------
--4.Успешное завершение платежа.
declare
  --Используемые статусы:
  c_status_created constant payment.status%type := 0;
  c_status_completed constant payment.status%type := 1;
  --
  v_payment_id payment.payment_id%type := 12; --ID платежа для операции
  v_updated_id payment.payment_id%type; --ID найденного платежа (для проверки изменений)
  v_current_dtime timestamp(2) := systimestamp;
  v_message varchar2(100 char) := 'Успешное завершение платежа.';
begin
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    update payment
    set status = c_status_completed
    where payment_id = v_payment_id and status = c_status_created
    returning payment_id
    into v_updated_id;

    if v_updated_id is null then
      dbms_output.put_line(
        'Платеж ID=' ||
        to_char(v_payment_id)||
        ' не найден или находится не в статусе "Платеж создан"' ||
        c_status_created);
    else
      dbms_output.put_line(
        'Дата операции: ' ||
        to_char(v_current_dtime, 'DD Month Year: "Quarter="Q "Week="W "DayOfYear="DDD "DayOfWeek"=Day HH24:MI:SS'));

      dbms_output.put_line(
        'Успешное завершение платежа. ' || 'Статус: ' || c_status_completed);
      dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
    end if;
  end if;

  dbms_output.put_line('');
end;
/

------------------------------------------------------------------------------------------------------------------------
--5.Данные платежа добавлены или обновлены.
declare
  --ID полей данных деталей платежа:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"
  --
  v_payment_id payment.payment_id%type := 10; --ID платежа для операции
  v_updated_id payment.payment_id%type; --ID найденного платежа (для проверки наличия платежа)
  v_current_date timestamp(2) := sysdate;
  --Детали платежа:
  v_payment_details t_payment_detail_array
    := t_payment_detail_array(
         t_payment_detail(c_payment_detail_field_id_note, 'Изменение данных платежа'),
         t_payment_detail(c_payment_detail_field_id_ip, '172.173.1.2'),
         t_payment_detail(c_payment_detail_field_id_client_software, 'web-клиент'));
  v_is_error boolean := false; --Флаг наличия ошибки при проверке данных
begin
  --Проверка данных
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
    v_is_error := true;
  else
    select max(payment_id)
    into v_updated_id
    from payment
    where payment_id = v_payment_id;

    if v_updated_id is null then
      dbms_output.put_line('Платеж ID=' || to_char(v_payment_id) || ' не найден');
      v_is_error := true;
    end if;
  end if;

  --Провека на пустую коллекцию и на пустые поля коллекции
  if not v_is_error then
    if v_payment_details is empty then
      dbms_output.put_line('Коллекция не содержит данных');
      v_is_error := true;
    else
      for i in v_payment_details.first .. v_payment_details.last loop
        if v_payment_details(i).field_id is null then
          dbms_output.put_line('Элемент коллекции №' || to_char(i) || ':');
          dbms_output.put_line('ID поля не может быть пустым');
          v_is_error := true;
        end if;

        if v_payment_details(i).field_value is null then
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
           from table(v_payment_details) c) b
    on (b.field_id = a.field_id and a.payment_id = v_payment_id)
    when matched then
      update set a.field_value = b.field_value
    when not matched then
      insert (a.payment_id, a.field_id, a.field_value)
      values (v_payment_id, b.field_id, b.field_value);

    dbms_output.put_line('Дата операции: ' || to_char(v_current_date, 'DL HH:MI:SS:AM'));
    dbms_output.put_line(
      'Данные платежа добавлены или обновлены по списку id_поля/значение');
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
  end if;

  dbms_output.put_line('');
end;
/

------------------------------------------------------------------------------------------------------------------------
--6.Детали платежа удалены.
declare
  --ID полей данных деталей платежа:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --Софт, через который совершался платеж
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP адрес плательщика
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --Примечание к переводу
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --Проверен ли платеж в системе "АнтиФрод"
  --
  v_payment_id payment.payment_id%type := 10; --ID платежа для удаления деталей
  v_current_date timestamp(2) := sysdate;
  --Коллекция ID деталей для удаления:
  v_payment_detail_field_ids t_number_array
    := t_number_array(c_payment_detail_field_id_note, c_payment_detail_field_id_is_checked);
  --Коллекция удаленных деталей:s
  v_deleted_field_ids t_number_array := t_number_array();
begin
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    delete from payment_detail
    where payment_id = v_payment_id and field_id in (select column_value from table(v_payment_detail_field_ids))
    returning field_id
    bulk collect into v_deleted_field_ids;

    dbms_output.put_line('Дата операции: ' || to_char(v_current_date, 'YYYYMMHH_HH24MISS'));
    dbms_output.put_line('Детали платежа удалены по списку id_полей');
    dbms_output.put_line('ID объекта: ' || to_char(v_payment_id));
    dbms_output.put_line('Кол-во удаленных полей: ' || to_char(v_deleted_field_ids.count));
  end if;

  dbms_output.put_line('');
end;
/