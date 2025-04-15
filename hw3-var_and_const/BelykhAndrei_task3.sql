--Автор: Белых Анжрей
--Описание скрипта: API для сущностей “Платеж” и “Детали платежа”

declare
  c_status_created constant number := 0;
  v_message varchar2(4000) := 'Платеж создан.';
begin
  v_message := v_message || ' Статус: ' || c_status_created;
  dbms_output.put_line(v_message);
end;
/

--Сброс платежа в "ошибочный статус"
declare
  c_status_failed constant number := 2;
  v_cause varchar2(4000) := 'недостаточно средств';
  v_message varchar2(4000)
    := 'Сброс платежа в "ошибочный статус" с указанием причины.';
begin
  v_message := v_message || ' Статус: ' || c_status_failed || '. Причина: ' || v_cause;
  dbms_output.put_line(v_message);
end;
/

--Отмена платежа
declare
  c_status_canceled constant number := 3;
  v_cause varchar2(4000) := 'ошибка пользователя';
  v_message varchar2(4000) := 'Отмена платежа с указанием причины.';
begin
  v_message := v_message || ' Статус: ' || c_status_canceled || '. Причина: ' || v_cause;
  dbms_output.put_line(v_message);
end;
/

--Успешное завершение платежа
declare
  c_status_completed constant number := 1;
  v_message varchar2(4000) := 'Успешное завершение платежа.';
begin
  v_message := v_message || ' Статус: ' || c_status_completed;
  dbms_output.put_line(v_message);
end;
/

--Данные платежа добавлены или обновлены
declare
  v_message varchar2(4000)
    := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
begin
  dbms_output.put_line(v_message);
end;
/

--Детали платежа удалены
declare
  v_message varchar2(4000) := 'Детали платежа удалены по списку id_полей';
begin
  dbms_output.put_line(v_message);
end;
/