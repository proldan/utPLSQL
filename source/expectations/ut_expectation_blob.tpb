create or replace type body ut_expectation_blob as
  /*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */
  overriding member procedure to_equal(self in ut_expectation_blob, a_expected blob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_blob.to_equal(self in ut_expectation, a_expected blob)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;
  
  overriding member procedure not_to_equal(self in ut_expectation_blob, a_expected blob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_blob.not_to_equal(self in ut_expectation, a_expected blob)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;

end;
/
