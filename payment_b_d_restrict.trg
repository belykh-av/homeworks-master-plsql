create or replace trigger payment_b_d_restrict
  before delete
  on payment
  for each row
begin
  raise_application_error(payment_api_pack.c_error_code_delete_restriction,
                          payment_api_pack.c_error_message_delete_restriction);
end;