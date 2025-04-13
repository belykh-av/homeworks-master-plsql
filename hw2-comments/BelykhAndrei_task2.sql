begin
  dbms_output.put_line('Платеж создан. Статус: 0');
end;
/

begin
  dbms_output.put_line(
    'Сброс платежа в "ошибочный статус" с указанием причины. Статус: 2. Причина: недостаточно средств');
end;
/

begin
  dbms_output.put_line(
    'Отмена платежа с указанием причины. Статус: 3. Причина: ошибка пользователя');
end;
/

begin
  dbms_output.put_line('Успешное завершение платежа. Статус: 1');
end;
/

begin
  dbms_output.put_line(
    'Данные платежа добавлены или обновлены по списку id_поля/значение');
end;
/

begin
  dbms_output.put_line('Детали платежа удалены по списку id_полей');
end;
/