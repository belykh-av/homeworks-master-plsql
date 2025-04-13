--Автор: Белых Анжрей
--Описание скрипта: API для сущностей “Платеж” и “Детали платежа”

declare
  c_status constant number := 0;
  v_couse varchar2(4000);
  v_message varchar2(4000) := 'Платеж создан.';
begin
  v_message := v_message || ' Статус: ' || c_status;
  dbms_output.put_line(v_message);
end;
/

--Сброс платежа в "ошибочный статус"
declare
  c_status constant number := 2;
  v_couse varchar2(4000) := 'недостаточно средств';
  v_message varchar2(4000)
    := 'Сброс платежа в "ошибочный статус" с указанием причины.';
begin
  v_message := v_message || ' Статус: ' || c_status || '.';
  v_message := v_message || ' Причина: ' || v_couse;
  dbms_output.put_line(v_message);
end;
/

--Отмена платежа
declare
  c_status constant number := 3;
  v_couse varchar2(4000) := 'ошибка пользователя';
  v_message varchar2(4000) := 'Отмена платежа с указанием причины.';
begin
  v_message := v_message || ' Статус: ' || c_status || '.';
  v_message := v_message || ' Причина: ' || v_couse;
  dbms_output.put_line(v_message);
end;
/

--Успешное завершение платежа
declare
  c_status constant number := 1;
  v_couse varchar2(4000);
  v_message varchar2(4000) := 'Успешное завершение платежа.';
begin
  v_message := v_message || ' Статус: ' || c_status;
  dbms_output.put_line(v_message);
end;
/

--Данные платежа добавлены или обновлены
declare
  c_status constant number := null;
  v_couse varchar2(4000);
  v_message varchar2(4000)
    := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
begin
  dbms_output.put_line(v_message);
end;
/

--Детали платежа удалены
declare
  c_status constant number := null;
  v_couse varchar2(4000);
  v_message varchar2(4000) := 'Детали платежа удалены по списку id_полей';
begin
  dbms_output.put_line(v_message);
end;
/