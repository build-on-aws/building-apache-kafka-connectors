package tutorial.buildon.aws.streaming.kafka;

import java.util.HashMap;
import java.util.Map;

import org.apache.kafka.common.config.ConfigException;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static tutorial.buildon.aws.streaming.kafka.MyFirstKafkaConnectorConfig.*;

public class MyFirstConnectorConfigTest {

    @Test
    public void basicParamsAreMandatory() {
        assertThrows(ConfigException.class, () -> {
            Map<String, String> props = new HashMap<>();
            new MyFirstKafkaConnectorConfig(props);
        });
    }

    public void checkingNonRequiredDefaults() {
        Map<String, String> props = new HashMap<>();
        MyFirstKafkaConnectorConfig config = new MyFirstKafkaConnectorConfig(props);
        assertEquals("foo", config.getString(FIRST_NONREQUIRED_PARAM_CONFIG));
        assertEquals("bar", config.getString(SECOND_NONREQUIRED_PARAM_CONFIG));
    }

}
