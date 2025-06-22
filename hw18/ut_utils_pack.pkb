CREATE OR REPLACE PACKAGE BODY ut_utils_pack is
  --Поиск и запуск тестовых процедур заданного пакета
  procedure run_tests(p_package_name user_objects.object_name%type := null) is
    v_sql varchar2(4000);
  begin
   <<package_loop>>
    for r_pack
      in (select a.name as package_name
          from user_source a
          where a.type = 'PACKAGE'
                and a.name = nvl(upper(p_package_name), a.name)
                and instr(a.text, '--%suite(', 1) > 0
          order by 1) loop
      dbms_output.put_line('=== Тесты в пакете: ' || lower(r_pack.package_name));

     <<procedure_loop>>
      for r_proc
        in (select lower(c.package_name) as package_lower_name, c.test_name, lower(c.proc_name) as proc_lower_name
            from (select b.name as package_name,
                         trim(replace(replace(text, '--%test('), ')' || chr(10))) as test_name,
                         trim(replace(replace(upper(b.next_text), 'PROCEDURE'), ';' || chr(10))) as proc_name
                  from (select a.name, a.text, lead(a.text) over (order by a.name, a.line) as next_text
                        from user_source a
                        where a.type = 'PACKAGE' and a.name = r_pack.package_name
                        order by a.line) b
                  where instr(b.text, '--%test(') > 0 and instr(upper(b.next_text), 'PROCEDURE') > 0) c
            where exists
                    (select 1
                     from user_procedures up
                     where up.object_name = c.package_name and up.procedure_name = c.proc_name)) loop
        begin
          savepoint sp1;
          v_sql := 'begin ' || r_proc.package_lower_name || '.' || r_proc.proc_lower_name || '; end;';

          --Запуск процедуры теста
          execute immediate v_sql;

          --Тест успешно прошел
          dbms_output.put_line('Тест: "' || r_proc.test_name || '"' || ' успешно прошел =)');

          --Откат
          rollback to sp1;
        exception
          when others then
            --Тест не прошел
            dbms_output.put_line('Тест: "' || r_proc.test_name || '"' || ' не был пройден.');
            dbms_output.put_line(
              '  Возникла ошибка в ' ||
              r_proc.package_lower_name ||
              '.' ||
              r_proc.proc_lower_name ||
              '. Errm: ' ||
              sqlerrm);
            rollback to sp1;
        end;
      end loop;
    end loop;
  end;
end ut_utils_pack;
