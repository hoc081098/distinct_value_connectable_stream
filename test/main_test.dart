import 'distinct_value_connectable_stream_test.dart'
    as distinct_value_connectable_stream_test;
import 'distinct_value_subject_test.dart' as distinct_value_subject_test;
import 'distinct_value_test.dart' as distinct_value_test;
import 'single_subscription_to_broadcast_test.dart'
    as single_subscription_to_broadcast_test;

void main() {
  distinct_value_connectable_stream_test.main();
  distinct_value_subject_test.main();
  distinct_value_test.main();
  single_subscription_to_broadcast_test.main();
}
