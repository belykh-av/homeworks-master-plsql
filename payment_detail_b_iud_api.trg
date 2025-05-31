create or replace trigger payment_detail_b_iud_api
  before insert or update or delete
  on payment_detail
begin
  payment_detail_api_pack.api_restiction;
end;