create or replace package test_metadata is

  --%suite(metadata)
  --%suitepath(ut_plsql.core)

  --%test
  procedure test_form_name;

end test_metadata;
/
create or replace package body test_metadata is

  procedure test_form_name is
    l_expected varchar2(2000) := 'some_procedure';
    l_result   varchar2(2000);
  begin
    l_result := ut_metadata.form_name(null, ' ' || l_expected || ' ');
    ut.expect(l_result).to_equal(l_expected);
  end;
end test_metadata;
/
