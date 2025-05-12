--�������� ������ ��� ������� HW12
------------------------------------------------------------------------------------------------------------------------

--������ ��� �������� ���������� ��������� �������� � �������:
select t.status, t.*
from user_objects t
where t.object_type in ('FUNCTION', 'PROCEDURE');
/


--����������, ��� ������ � ��������:
select * from payment
/
select * from payment_detail
/


--1.�������� �������
declare
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --����, ����� ������� ���������� ������
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP ����� �����������
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --���������� � ��������
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --�������� �� ������ � ������� "��������"
  v_payment_id payment.payment_id%type;
begin
  v_payment_id := create_payment(
                    p_create_dtime => systimestamp,
                    p_from_client_id => 1,
                    p_to_client_id => 2,
                    p_summa => 30,
                    p_currency_id => 643,
                    p_payment_details => t_payment_detail_array(
                                          t_payment_detail(c_payment_detail_field_id_client_software,
                                                           '������-���� �����-��'),
                                          t_payment_detail(c_payment_detail_field_id_ip, '172.173.120.300'),
                                          t_payment_detail(c_payment_detail_field_id_note,
                                                           '�������� ���������')));
end;
/

--2.����� ������� � "��������� ������".
begin
  fail_payment(63);
end;
/

--3.������ �������.
begin
  cancel_payment(64);
end;
/

--4.�������� ���������� �������.
begin
  successful_finish_payment(65);
end;
/

--5.������ ������� ��������� ��� ���������.
declare
  --ID ����� ������ ������� �������:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --����, ����� ������� ���������� ������
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP ����� �����������
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --���������� � ��������
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --�������� �� ������ � ������� "��������"
begin
  insert_or_update_payment_detail(
    66,
    t_payment_detail_array(
      t_payment_detail(c_payment_detail_field_id_note, '��������� ������ �������'),
      t_payment_detail(c_payment_detail_field_id_ip, '172.173.1.2'),
      t_payment_detail(c_payment_detail_field_id_client_software, 'web-������')));
end;
/

--6.������ ������� �������.
declare
  --ID ����� ������ ������� �������:
  c_payment_detail_field_id_client_software constant payment_detail.field_id%type := 1; --����, ����� ������� ���������� ������
  c_payment_detail_field_id_ip constant payment_detail.field_id%type := 2; --IP ����� �����������
  c_payment_detail_field_id_note constant payment_detail.field_id%type := 3; --���������� � ��������
  c_payment_detail_field_id_is_checked constant payment_detail.field_id%type := 4; --�������� �� ������ � ������� "��������"
begin
  delete_payment_detail(66, t_number_array(c_payment_detail_field_id_ip, c_payment_detail_field_id_is_checked));
end;
/
