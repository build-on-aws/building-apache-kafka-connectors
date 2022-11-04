package tutorial.buildon.aws.streaming.kafka;

import java.util.Map;

import org.apache.kafka.common.config.AbstractConfig;
import org.apache.kafka.common.config.ConfigDef;
import org.apache.kafka.common.config.ConfigDef.Importance;
import org.apache.kafka.common.config.ConfigDef.Type;

public class MyFirstKafkaConnectorConfig extends AbstractConfig {

    public MyFirstKafkaConnectorConfig(final Map<?, ?> originalProps) {
        super(CONFIG_DEF, originalProps);
    }

    public static final String FIRST_REQUIRED_PARAM_CONFIG = "first.required.param";
    private static final String FIRST_REQUIRED_PARAM_DOC = "This is the 1st required parameter";

    public static final String SECOND_REQUIRED_PARAM_CONFIG = "second.required.param";
    private static final String SECOND_REQUIRED_PARAM_DOC = "This is the 2nd required parameter";

    public static final String FIRST_NONREQUIRED_PARAM_CONFIG = "first.nonrequired.param";
    private static final String FIRST_NONREQUIRED_PARAM_DOC = "This is the 1st non-required parameter";
    private static final String FIRST_NONREQUIRED_PARAM_DEFAULT = "foo";

    public static final String SECOND_NONREQUIRED_PARAM_CONFIG = "second.nonrequired.param";
    private static final String SECOND_NONREQUIRED_PARAM_DOC = "This is the 2nd non-required parameter";
    private static final String SECOND_NONREQUIRED_PARAM_DEFAULT = "bar";

    public static final String TASK_SLEEP_TIMEOUT_CONFIG = "task.sleep.timeout";
    private static final String TASK_SLEEP_TIMEOUT_DOC = "Sleep timeout used by tasks during each poll";
    private static final int TASK_SLEEP_TIMEOUT_DEFAULT = 5000;

    public static final String MONITOR_THREAD_TIMEOUT_CONFIG = "monitor.thread.timeout";
    private static final String MONITOR_THREAD_TIMEOUT_DOC = "Timeout used by the monitoring thread";
    private static final int MONITOR_THREAD_TIMEOUT_DEFAULT = 10000;

    public static final ConfigDef CONFIG_DEF = createConfigDef();

    private static ConfigDef createConfigDef() {
        ConfigDef configDef = new ConfigDef();
        addParams(configDef);
        return configDef;
    }

    private static void addParams(final ConfigDef configDef) {
        configDef.define(
            FIRST_REQUIRED_PARAM_CONFIG,
            Type.STRING,
            Importance.HIGH,
            FIRST_REQUIRED_PARAM_DOC)
        .define(
            SECOND_REQUIRED_PARAM_CONFIG,
            Type.STRING,
            Importance.HIGH,
            SECOND_REQUIRED_PARAM_DOC)
        .define(
            FIRST_NONREQUIRED_PARAM_CONFIG,
            Type.STRING,
            FIRST_NONREQUIRED_PARAM_DEFAULT,
            Importance.HIGH,
            FIRST_NONREQUIRED_PARAM_DOC)
        .define(
            SECOND_NONREQUIRED_PARAM_CONFIG,
            Type.STRING,
            SECOND_NONREQUIRED_PARAM_DEFAULT,
            Importance.HIGH,
            SECOND_NONREQUIRED_PARAM_DOC)
        .define(
            TASK_SLEEP_TIMEOUT_CONFIG,
            Type.INT,
            TASK_SLEEP_TIMEOUT_DEFAULT,
            Importance.HIGH,
            TASK_SLEEP_TIMEOUT_DOC)
        .define(
            MONITOR_THREAD_TIMEOUT_CONFIG,
            Type.INT,
            MONITOR_THREAD_TIMEOUT_DEFAULT,
            Importance.LOW,
            MONITOR_THREAD_TIMEOUT_DOC);
    }

}
